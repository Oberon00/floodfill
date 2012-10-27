local oo = require 'oo'
local evt = require 'evt'
local loadMap = (require 'maploader').loadMap
local levelnamelist = require 'data.levels'
local LevelList = require 'LevelList'
local Level = require 'Level'

oo.cppclass('GameState', jd.State)

function GameState:__init()
	jd.State.__init(self)
	self.levels = LevelList(levelnamelist)
end

function GameState:prepare()
	local maplayer = jd.drawService:layer(2)
	
	self.level = Level(self.levels:currentLevel().name, maplayer.group)
	evt.connectToKeyPress(jd.kb.F5, function() self.level:restart() end)
	self.level:start()
	maplayer.view.rect = self.level.world.map.bounds

end

function GameState:stop()
	self.level:stop()
	self.level = nil
end

_G.states = _G.states or { }
_G.states.game = GameState()

return states.game
