require 'comp.Graphic'
require 'comp.CollisionInfo'
require 'comp.InputMoved'

local M = { }

local PLAYER_SIZE = jd.Vec2(28, 28)

function M.load(info, layerInfo, data)
	assert(info.objectType == jd.mapInfo.Object.TILE)
	local tile = data.tileMapping.byId[info.tileId]
	local entity = jd.Entity()
	local pos = jd.PositionComponent(entity)
	local tileset = data.map.tileset
	local sprite = jd.Sprite(data.map.group)
	sprite.texture = tileset.texture
	sprite.textureRect = jd.Rect(
		tileset:texturePosition(info.tileId - 1), tileset.size)
	pos.rect = jd.Rect(info.position, PLAYER_SIZE)
	CollisionInfoComponent(entity, tile)
	GraphicComponent(entity, sprite)
	table.insert(data.postLoad, function(data)
		local cgg = jd.CollideableGroupGroup()
		cgg:add(data.tileProxyCollider)
		InputMovedComponent(entity, function(r)
			print(r)
			return cgg:colliding(r, jd.NIL_ENTITY)
		end)
		entity:finish()
	end)
	return entity
end

return M
