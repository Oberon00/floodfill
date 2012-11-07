local M = { }

require 'comp.TwoStateTile'
require 'comp.CollisionInfo'

function M.createSubstitute(name, id, pos, data, props)
	local maploader = require 'maploader'
	local tiles = require 'data.tiles'
	local map = data.map
	
	local entity = jd.Entity()
	local poscomp = jd.PositionComponent(entity)
	poscomp.rect = map:tileRect(jd.Vec2(pos))
	local tposcomp = jd.TilePositionComponent(entity, map, pos.z)
	jd.TileCollisionComponent(entity, data.tileCollisionInfo)
	
	local cinfo = CollisionInfoComponent(entity, tiles[name])
	local canEnter, canLeave = cinfo.canEnter, cinfo.canLeave
	local function updateTile(self)
		self.tile =
			tiles[data.tileMapping.byId[map:get(tposcomp.tilePosition)]]
	end
	function cinfo.canEnter(self, ...)
		updateTile(self)
		return canEnter(self, ...)
	end
	function cinfo.canLeave(self, ...)
		updateTile(self)
		return canLeave(self, ...)
	end
	
	local tids = data.tileMapping.byName
	local lockedTid = map:get(pos)
	if lockedTid == tids.lock_open then
		lockedTid = tids.lock_nesw
	end
	local statecomp = TwoStateTileComponent(
		entity, map, tids.lock_open, lockedTid)
	entity:finish()
	
	local tags = maploader.findTagObjects(poscomp.rect,
		map, props.objectGroups:get('connections').objects)
	if #tags > 0 then
		statecomp:setState(true) -- open if a tagobject is on the lock
	end
	
	return entity
end -- function M.createSubstitutes

return M
