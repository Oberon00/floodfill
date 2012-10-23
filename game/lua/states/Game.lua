local oo = require 'oo'
local evt = require 'evt'
local loadMap = (require 'maploader').loadMap

oo.cppclass('GameState', jd.State)

function GameState:__init()
	jd.State.__init(self)
	self.onStart = evt.Signal()
	self.onStop  = evt.Signal()
end

function GameState:prepare()
	local maplayer = jd.drawService:layer(2)
	local tilemap = jd.Tilemap(maplayer.group)
	
	self.world = loadMap(tilemap, "level1", {
		onStart = self.onStart,
		onStop = self.onStop,
		procs = { }
	})
	maplayer.view.rect = tilemap.bounds
	self.onStart()
end

function GameState:stop()
	self.onStop()
	for _, entity in pairs(self.world.tileProxies) do
		entity:kill()
	end
	for _, entity in ipairs(self.world.substituteObjects) do
		entity:kill()
	end
	for _, group in pairs(self.world.mapObjects) do
		for _, entity in ipairs(group) do
			entity:kill()
		end
	end
	self.world = nil
end

_G.states = _G.states or { }
_G.states.game = GameState()

return states.game
