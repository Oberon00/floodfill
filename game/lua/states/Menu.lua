local oo = require 'oo'
local text = require 'text'
local strings = require 'data.strings'
local evt = require 'evt'

local C = oo.cppclass('MenuState', jd.State)

local function enterStateF(state)
	return function()
		return jd.stateManager:push(state)
	end
end

local PADDING_TOP = 30 + text.defaultFont:lineSpacing(30)

local CHAR_H = 50
local LINE_H = CHAR_H + text.defaultFont:lineSpacing(CHAR_H)

local COLOR_DEF = jd.Color(220, 180,   0)
local COLOR_HL  = jd.Color(  0, 150, 255)

local SCALE_HL = jd.Vec2(1.3, 1.3)

local function createEntry(self, s, y)
	local tx = text.create(s, jd.Vec2(0, y), self.menulayer.group)
	tx.characterSize = CHAR_H
	tx.color = COLOR_DEF
	text.centerX(tx)
	return tx
end

local function entrySpace(self)
	return self.menulayer.view.rect.h - PADDING_TOP
end

local function paginate(self, menu)
	local entrySpace = entrySpace(self)
	local itemCount = #menu
	local pageCount = math.ceil(itemCount * LINE_H / entrySpace)
	local itemsPerPage = math.ceil(itemCount / pageCount)
	
	local pages = { }
	for p = 1, pageCount do
		local page = { }
		pages[p] = page
		for i = 1, itemsPerPage do
			local idx = (p - 1) * itemsPerPage + i
			print(idx)
			page[i] = menu[idx]
			if idx == itemCount then
				return pages
			end
		end
	end
	assert(false, "did not process all menu items")
end

local function clearMenuPage(self)
	if not self.texts then
		return
	end
	for i = 1, #self.texts do
		self.texts[i]:release()
	end
	self.texts = nil
	self.currentIndex = nil
	self.currentPageIndex = nil
end

local function clearMenu(self)
	clearMenuPage(self)
	if self.navText then
		self.navText:release()
		self.navText = nil
	end
	self.menu = nil
	self.pages = nil
end

local function updateNavText(self)
	if not self.navText then
		self.navText = text.create("")
	end
	
	local pageCount = #self.pages
	local idx = self.currentPageIndex
	local str = ""
	if pageCount > 1 then
		str = idx >= pageCount and "<%i/%i" or
			  idx <= 1 and "%i/%i>" or "<%i/%i>"
	end
	if #self.parentMenus > 0 then
		str = "^ " .. str
	end
	self.navText.string = str:format(idx, pageCount)
end

local function selectEntry(self, idx)

	local newTx = self.texts[idx]
	if not newTx then
		return
	end
	
	if self.currentIndex then
		local oldTx = self.texts[self.currentIndex]
		oldTx.color = COLOR_DEF
		oldTx.scale = jd.Vec2(1, 1)
		oldTx.bold = false
		text.centerX(oldTx)
	end
	self.currentIndex = idx
	newTx.color = COLOR_HL
	newTx.scale = SCALE_HL
	newTx.bold = true
	text.centerX(newTx)
	return true
end

local function setPage(self, idx)
	local page = self.pages[idx]
	if not page then
		return
	end
	clearMenuPage(self)
	self.currentPageIndex = idx
	local entryH = entrySpace(self) / #self.pages[1]
	self.texts = { }
	for i = 1, #page do
		self.texts[i] = createEntry(
			self, page[i].text, PADDING_TOP + (i - 1) * entryH)
	end
	updateNavText(self)
	selectEntry(self, 1)
end

local function setMenu(self, menu)
	self.pages = paginate(self, menu)
	setPage(self, 1)
	self.menu = menu
end

function C.MenuOption(s, f)
	local r = {text = strings[s], action = f}
	assert(type(r.text) == 'string', "invalid text")
	return r
end

function C:enterSubmenu(menu)
	table.insert(self.parentMenus, {
		menu = self.menu,
		pageIdx = self.currentPageIndex,
		idx = self.currentIndex
	})
	clearMenu(self)
	setMenu(self, menu)
end

function C:__init()
	jd.State.__init(self)
	self.menulayer = text.defaultLayer
end

local MAINMENU
function C:prepare()
	self.parentMenus = { }
	
	-- set background --
	local bglayer = jd.drawService:layer(1)
	self.background = jd.Sprite(bglayer.group)
	self.background.texture = jd.Texture.request "menubg"
	self.background.color = jd.Color(127, 127, 127)
	bglayer.view.rect = self.background.bounds
	
	-- setup events --
	local function selectNextEntry()
		selectEntry(self, self.currentIndex + 1)
	end
	local function selectPreviousEntry()
		selectEntry(self, self.currentIndex - 1)
	end
	
	local function nextPage()
		setPage(self, self.currentPageIndex + 1)
	end
	
	local function previousPage()
		setPage(self, self.currentPageIndex - 1)
	end
	
	local function doCurrentEntry()
		local act = self.menu[self.currentIndex].action
		if type(act) == 'table' then
			self:enterSubmenu(act)
		else
			act(self)
		end
	end
	
	local function toParentMenu()
		local parent = self.parentMenus[#self.parentMenus]
		if not parent then
			return
		end
		self.parentMenus[#self.parentMenus] = nil
		clearMenu(self)
		setMenu(self, parent.menu)
		setPage(self, parent.pageIdx)
		selectEntry(self, parent.idx)
	end
	
	local function e(k, f) evt.connectToKeyPress(jd.kb[k], f) end
	e('UP',     selectPreviousEntry)
	e('W',      selectPreviousEntry)
	e('DOWN',   selectNextEntry)
	e('S',      selectNextEntry)
	e('LEFT',   previousPage)
	e('A',      previousPage)
	e('RIGHT',  nextPage)
	e('D',      nextPage)
	e('RETURN', doCurrentEntry)
	e('SPACE',  doCurrentEntry)
	e('ESCAPE', toParentMenu)
	
	
	-- initialize menu --
	setMenu(self, MAINMENU)	
end

function C:pause()
	local function d(k) evt.connectToKeyPress(jd.kb[k], nil) end
	d 'UP' d 'W' d 'DOWN' d 'S'
	d 'LEFT' d 'A' d 'RIGHT' d 'D'
	d 'RETURN' d 'SPACE'
	d 'ESCAPE'
	self.background:release()
	clearMenu(self)
end

local O = C.MenuOption
--[[local]] MAINMENU = {
	O('new_game', enterStateF 'Game'),
	O('exit_program', function() return jd.mainloop:quit() end)
}


return MenuState()
