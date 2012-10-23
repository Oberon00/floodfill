require 'comp.CollisionInfo'
local layers = require 'data.layers'

local M = { }

function M.createSubstitute(name, id, pos, data, props)
	local tiles = require 'data.tiles' 
	local waterTid = data.tileMapping.byName.water
	local map = data.map
	local entity = jd.Entity()
	local cinfo = CollisionInfoComponent(entity, tiles[name])
	local poscomp = jd.PositionComponent(entity)
	poscomp.rect = map:tileRect(jd.Vec2(pos.x, pos.y))
	jd.TilePositionComponent(entity, map, pos.z)
	jd.TileCollisionComponent(entity, data.tileCollisionInfo)
	local canEnter = cinfo.canEnter
	function cinfo.canEnter(self, entity, ...)
		return map:get(jd.Vec3(pos.x, pos.y, layers.WATER)) ~= waterTid
		       and canEnter(self, entity, ...)
	end
	entity:finish()
	return entity
end -- function M.substitute

return M
