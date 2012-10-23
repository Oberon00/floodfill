local oo = require 'oo'
local loadMap = (require 'maploader').loadMap

oo.cppclass('GameState', jd.State)

function Game:prepare()
	local maplayer = jd.drawService:layer(2)
	local tilemap = jd.Tilemap(maplayer.group)
	self.world = loadMap(tilemap, "level1")
	maplayer.view.rect = tilemap.bounds
end

function Game:stop()
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
