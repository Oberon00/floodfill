local C = lclass 'Level'

local maploader = require 'maploader'
local evt = require 'evt'
local tabutil = require 'tabutil'

function C:__init(name, drawgroup)
	self.onStart = evt.Signal()
	self.onStop  = evt.Signal()
	
	local map = jd.Tilemap(drawgroup)
	map.visible = false
	self._levelData = {
		name = name,
		map = map,
		props = map:loadFromFile(maploader.mapFile(name)),
		onStart = self.onStart,
		onStop = self.onStop,
	}
end

function C:start()
	local world = tabutil.copy(self._levelData)
	
	-- add self reference here and not in ctor, to speed up the GC
	world.level = self
	
	world.map = jd.Tilemap(world.map)

	world.procs = { }
	world.map.visible = true

	self.world = maploader.initializeMap(world)
	
	self.onStart()
end

function C:stop()
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

function C:restart()
	self:stop()
	self:start()
end

return C
