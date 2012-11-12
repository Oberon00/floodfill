local oo = require 'oo'
local evt = require 'evt'
local loadMap = (require 'maploader').loadMap
local levelnamelist = require 'data.levels'
local LevelList = require 'LevelList'
local Level = require 'Level'

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
