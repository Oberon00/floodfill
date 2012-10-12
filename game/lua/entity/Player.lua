require 'comp.Graphic'
require 'comp.CollisionInfo'
require 'comp.InputMoved'
local tiles = require 'data.tiles'
local layers = require 'data.layers'
local util = require 'util'

local M = { }

local PLAYER_SIZE = jd.Vec2(22, 22)

local function allEnterable(collisions, entity, dir, from, to)
	for c in collisions:iter() do
		local cinfo = c.entity:component 'CollisionInfoComponent'
		if cinfo and not cinfo:canEnter(entity, dir, from, to) then
			return false
		end -- if cinfo and cinfo:canEnter
	end -- for c in collisions
	return true
end

function M.load(info, layerInfo, data)
	assert(info.objectType == jd.mapInfo.Object.TILE)
	local tile = tiles[data.tileMapping.byId[info.tileId]]
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
	data.objectColliders.objects:add(pos)
	local cgg = jd.CollideableGroupGroup()
	local tilestackcg = jd.TileStackCollideableGroup(data.tileCollisionInfo)
	entity.tilestackcg = tilestackcg -- ensure tilestackcg stays alife
	
	tilestackcg:setFilter(function (p, stack)
		local tileFound = false
		for i = 0, layers.PLAYER_GROUND - 1 do
			stack:get(i + 1).discard = true
		end
		for i = layers.PLAYER_GROUND, layers.OBJECTS do
			if stack:get(i + 1).entity then
				tileFound = true
				break
			end
		end
		if not tileFound then
			for i = layers.PLAYER_GROUND - 1, 0, -1 do
				stack:get(i + 1).discard = false
			end
		end
	end)
	
	cgg:add(tilestackcg)
	InputMovedComponent(entity, function (r, oldr, d0, d)
		local collisions = tilestackcg:colliding(oldr.center, r.center)
		local way = {oldr}
		local collisionsInWay = 0
		
		for i = 1, collisions.count do
			local c = collisions:get(i)
			
			local cinfo = c.entity:component 'CollisionInfoComponent'
			if cinfo then
				if c.rect:intersection(oldr) or
				   cinfo:canEnter(entity, d0, oldr.xy, r.xy) then
					if i < collisionsInWay and
					   not cinfo:canLeave(entity, d0, oldr.xy, r.xy) then
						r.xy = c.rect:outermostPoint(d0, r)
						break
					else -- if p ~= lastCheckedPos/elseif not (canLeave or last)
						if i > collisionsInWay then
							way[#way] = c.rect
							collisionsInWay = collisions.count
							for j = i + 1, collisionsInWay do
								if collisions:get(j).rect ~= c.rect then
									assert(j > 1)
									collisionsInWay = j - 1
									break
								end -- if new rect
							end -- for j = i + 1, collisionsInWay
						end -- if i > collisionsInWay
					end -- if p ~= lastCheckedPos/else
				else -- if canEnter
					r.xy = way[#way]:outermostPoint(d0, r)
					break
				end -- if canEnter/else
			end -- if cinfo
		end -- for c in collisions
		
		local rcolliding = tilestackcg:colliding(r)
		util.inplaceMap(rcolliding, function(c)
			if c.rect:intersection(oldr) then
				return nil
			end
			return c
		end)
		
		while not allEnterable(rcolliding, entity, d0, oldr.xy, r.xy) do
		    if not way[#way] then
				r.xy = oldr.xy
				break
			end
			r.xy = way[#way]:outermostPoint(d0, oldr)
			way[#way] = nil
		end -- while not allEnterable which touch r
		return r.xy
	end)
	entity:finish()
	return entity
end

return M
