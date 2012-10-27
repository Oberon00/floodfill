require 'comp.Graphic'
require 'comp.CollisionInfo'
require 'comp.InputMoved'

require 'comp.Activateable' -- Make sure component is registered.

local tiles = require 'data.tiles'
local layers = require 'data.layers'
local util = require 'util'
local allEnterable = (require 'collisionutil').allEnterable

local M = { }

local PLAYER_SIZE = jd.Vec2(22, 22)
local ACTIVATE_DISTANCE = 2
local ACTIVATE_SIZE = jd.Vec2(1, 1)


local function activateAll(collisions, entity)
	for c in collisions:iter() do
		local act = c.entity:component 'ActivateableComponent'
		if act then
			act:activate(entity)
		end
	end -- for c in collisions
end

function M.load(info, layerInfo, data)
	assert(info.objectType == jd.mapInfo.Object.TILE)
	local tile = tiles[data.tileMapping.byId[info.tileId]]
	local entity = jd.Entity()
	local pos = jd.PositionComponent(entity)
	local map = data.map
	local tileset = map.tileset
	local sprite = jd.Sprite(map.group)
	sprite.texture = tileset.texture
	sprite.textureRect = jd.Rect(
		tileset:texturePosition(info.tileId - 1), tileset.size)
	sprite.origin = jd.Vec2(5, 5)
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
			end -- for each layer between PLAYER_GROUND - 1 downto 0
		end -- if not tileFound
	end) -- tilestackcg filter callback
	
	cgg:add(tilestackcg)
	
	InputMovedComponent(entity, function (r, oldr, d0, d, comp)
		local collisions = cgg:colliding(oldr.center, r.center)
		local way = {oldr}
		local collisionsInWay = 0
		local aborted = false
		for i = 1, collisions.count do
		
			local c = collisions:get(i)
			local cinfo = c.entity:component 'CollisionInfoComponent'
			
			if i > collisionsInWay then
				way[#way] = c.rect
				collisionsInWay = collisions.count
				for j = i + 1, collisionsInWay do
					if collisions:get(j).rect ~= c.rect then
						assert(j > 1)
						collisionsInWay = j - 1
						break
					end -- if rect is new
				end -- for j = i + 1, collisionsInWay
			end -- if i > collisionsInWay
						
			if cinfo and (c.rect:intersection(oldr) or
			   cinfo:canEnter(entity, d0, oldr.xy, r.xy)) then
				if not cinfo:canLeave(entity, d0, oldr.xy, r.xy) then
					aborted = true
					break
				else -- if i < collisionsInWay
				end  -- if i < collisionsInWay/else
			else -- if canEnter and ...
				aborted = true
				break
			end -- if canEnter and .../else
		end -- for c in collisions
		
		if not aborted then
			way[#way] = nil -- remove last rect (target rect)
		end
		
		local rcolliding
		local function updateRcolliding()
			rcolliding = cgg:colliding(r)
			util.inplaceMap(rcolliding, function(c)
				if c.rect:intersection(oldr) then
					return nil
				end
				return c
			end)
		end
		
		updateRcolliding()
		while not allEnterable(rcolliding, entity, d0, oldr.xy, r.xy) do
		    if not way[#way] then
				r.xy = oldr.xy
				break
			end
			r.xy = way[#way]:outermostPoint(d0, oldr)
			way[#way] = nil
			updateRcolliding()
		end -- while not allEnterable which touch r
		
		if comp.firstMove or r ~= oldr then
			local activateRect = jd.Rect(
				r.xy + d0 * ACTIVATE_DISTANCE, r.size)
			activateAll(cgg:colliding(activateRect), entity)
		end
		return r.xy
	end) -- InputMovedComponent callback
	
	entity:finish()
	return entity
end

return M
