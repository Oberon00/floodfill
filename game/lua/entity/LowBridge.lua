require 'comp.CollisionInfo'
local Flood = require 'proc.Flood'

local M = { }

function M.createSubstitute(name, id, pos, data, props)
	local tiles = require 'data.tiles' 
	local entity = jd.Entity()
	local cinfo = CollisionInfoComponent(entity, tiles[name])
	local poscomp = jd.PositionComponent(entity)
	poscomp.rect = data.map:tileRect(jd.Vec2(pos))
	local tposcomp = jd.TilePositionComponent(entity, data.map, pos.z)
	jd.TileCollisionComponent(entity, data.tileCollisionInfo)
	local canEnter = cinfo.canEnter
	local flood = Flood.ensureFlood(data)
	function cinfo.canEnter(self, entity, ...)
		return not flood:isFlooded(tposcomp.tilePosition)
		       and canEnter(self, entity, ...)
	end
	entity:finish()
	return entity
end -- function M.substitute

return M
