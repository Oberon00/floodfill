local oo = require 'oo'
local evt = require 'evt'
local loadMap = (require 'maploader').loadMap
local levelnamelist = require 'data.levels'
local LevelList = require 'LevelList'
local Level = require 'Level'
local text = require 'text'

local C = oo.cppclass('GameState', jd.State)

local maplayer = jd.drawService:layer(2)

local nextLevel

local function startLoadedLevel(self)
	self.level:start()
	function self.level.world.winLevel()
		nextLevel(self)
	end
end

local function startLevel(self)
	self.level = Level(self.levels:currentLevel().name, maplayer.group)
	evt.connectToKeyPress(jd.kb.F5, function()
		self.level:stop()
		startLoadedLevel(self)
	end)
	startLoadedLevel(self)
	maplayer.view.rect = self.level.world.map.bounds
	
	-- Show "Level %i" message and fade out
	local tx = text.create(("Level %i"):format(self.levels.currentIndex))
	tx.color = jd.Color.GREEN
	tx.characterSize = 100
	tx.bold = true
	text.center(tx)
	
	jd.timer:callAfter(jd.seconds(2), function()
		local tm = jd.Clock()
		local con
		con = jd.connect(jd.mainloop, 'update', function()
			local a = 255 - tm.elapsedTime:asSeconds() * (255 / 2)
			if a < 0 then
				tx:release()
				con:disconnect()
			end
			local cl = tx.color
			cl.a = a
			tx.color = cl
		end)
	end)
end

--[[local]] function nextLevel(self)
	evt.connectToKeyPress(jd.kb.F5, nil)
	self.level:stop()
	if not self.levels:advance() then
		self.levels.currentIndex = 1 -- restart from first level
		-- TODO: Show "winning-screen"
	end
	startLevel(self)
end

function C:__init()
	jd.State.__init(self)
	self.levels = LevelList(levelnamelist)
	jd.Image.keepLoaded "tileset.png"
	jd.Texture.keepLoaded "tileset.png"
end

function C:prepare()
	startLevel(self)
end

function C:stop()
	self.level:stop()
	self.level = nil
end

_G.states = _G.states or { }
_G.states.game = GameState()

return states.game
