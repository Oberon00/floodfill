local oo = require 'oo'
local evt = require 'evt'
local levelnamelist = require 'data.levels'
local LevelList = require 'LevelList'
local Level = require 'Level'
local text = require 'text'
local strings = require 'data.strings'
local ContinueScreen = require 'ContinueScreen'

local C = oo.cppclass('GameState', jd.State)

local maplayer = jd.drawService:layer(2)

local nextLevel

local function clearMessage(self)
	if self.message then
		self.message:release()
		self.message = nil
	end
end

local function startLoadedLevel(self)
	self.level:start()
	function self.level.world.winLevel()
		nextLevel(self)
	end
end

local function startLevel(self)
	local levelEntry = self.levels:currentLevel()
	levelEntry.unlocked = true
	self.level = Level(levelEntry.name, maplayer.group)
	evt.connectToKeyPress(jd.kb.F5, function()
		self.level:stop()
		startLoadedLevel(self)
	end)
	startLoadedLevel(self)
	maplayer.view.rect = self.level.world.map.bounds
	
	-- Show "Level %i" message and fade out
	local tx = text.create(strings.level_i:format(self.levels.currentIndex))
	self.message = tx
	tx.color = jd.Color.GREEN
	tx.characterSize = 200
	tx.bold = true
	text.center(tx)
	
	jd.timer:callAfter(jd.seconds(2), function()
		local tm = jd.Clock()
		local con
		con = jd.connect(jd.mainloop, 'update', function()
			local a = 255 - tm.elapsedTime:asSeconds() * (255 / 2)
			if a < 0 or not self.message then
				con:disconnect()
				clearMessage(self)
			end
			local cl = tx.color
			cl.a = a
			tx.color = cl
		end)
	end)
end

--[[local]] function nextLevel(self)
	clearMessage(self)
	evt.connectToKeyPress(jd.kb.F5, nil)
	self.level:stop()
	if not self.levels:advance() then
		self.winningScreen = ContinueScreen()
		evt.connectToKeyPress(jd.kb.ESCAPE, nil)
		self.winningScreen:show(
			function()
				jd.stateManager:pop() -- pop game
				jd.stateManager:switchTo('Splash') -- replace menu with splash
				jd.stateManager:push('Credits')
			end,
			jd.Texture.request "win")
	else
		startLevel(self)
	end
end

function C:__init()
	jd.State.__init(self)
	self.levels = LevelList.default
	jd.Image.keepLoaded "tileset.png"
	jd.Texture.keepLoaded "tileset.png"
end

function C:prepare()
	evt.connectToKeyPress(jd.kb.ESCAPE, function() jd.stateManager:pop() end)
	startLevel(self)
end

function C:pause()
	if self.winningScreen then
		self.winningScreen:reset()
		self.winningScreen = nil
	end
	
	evt.connectToKeyPress(jd.kb.F5, nil)
	evt.connectToKeyPress(jd.kb.ESCAPE, nil)
	clearMessage(self)
end

function C:stop()
	self.levels.currentIndex = 1
	self.level:stop()
	self.level = nil
end

return GameState()
