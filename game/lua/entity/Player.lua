require 'comp.Graphic'
require 'comp.CollisionInfo'
require 'comp.InputMoved'

require 'comp.Activateable' -- Make sure component is registered.

local tiles = require 'data.tiles'
local layers = require 'data.layers'
local util = require 'util'
local colutil = require 'collisionutil'

local M = { }

local PLAYER_SIZE = jd.Vec2(22, 22)
local ACTIVATE_DISTANCE = 2
local ACTIVATE_SIZE = jd.Vec2(1, 1)


local function activateAll(collisions, entity)
    local activated = false
    for c in collisions:iter() do
        local act = c.entity:component 'ActivateableComponent'
        if act then
            act:activate(entity)
            activated = true
        end
    end -- for c in collisions
    return activated
end

local function nearestPoint(to, p1, p2)
    return to:manhattanDistance(p1) < to:manhattanDistance(p2) and p1 or p2
end

local function mostDistantPoint(to, p1, p2)
    return to:manhattanDistance(p1) > to:manhattanDistance(p2) and p1 or p2
end

local function cutMovementFrom(from, to, at)
    local p1, p2 = at:clipLine(from, to)
    return p1 and mostDistantPoint(from, p1, p2) or to
end

local function cutMovementTo(from, to, at)
    local p1, p2 = at:clipLine(from, to)
    return p1 and nearestPoint(from, p1, p2) or to
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
    pos.rect = jd.Rect(info.position + sprite.origin, PLAYER_SIZE)
    CollisionInfoComponent(entity, tile)
    GraphicComponent(entity, sprite)
    data.objectColliders.objects:add(pos)
    local cgg = jd.CollideableGroupGroup()
    local tilestackcg = jd.TileStackCollideableGroup(data.tileCollisionInfo)
    local tilew = math.min(map.tileset.size.x, map.tileset.size.y)
    entity.tilestackcg = tilestackcg -- ensure that tilestackcg stays alife

    tilestackcg:setFilter(function(p, stack)
        local tileFound = false
        for i = 0, layers.PLAYER - 1 do
            stack:get(i + 1).discard = true
        end
        for i = layers.PLAYER, layers.OBJECTS do
            local entity = stack:get(i + 1).entity
            if entity then
                local cinfo = entity:component 'CollisionInfoComponent'
                if not cinfo or cinfo.tile.bridging then
                    tileFound = true
                    break
                end
            end
        end
        if not tileFound then
            for i = layers.PLAYER - 1, 0, -1 do
                stack:get(i + 1).discard = false
            end -- for each layer between PLAYER_GROUND - 1 downto 0
        end -- if not tileFound
    end) -- tilestackcg filter callback

    cgg:add(tilestackcg)

    local function canMoveEnter(oldr, r, d, from, to)
        local bounds = map.bounds
        if r.x < bounds.x or r.x > bounds.right or
           r.y < bounds.y or r.y > bounds.bottom
        then
            return false
        end

        local oldc = cgg:colliding(oldr)
        local newc = cgg:colliding(r)
        local newOnly = newc:differenceTo(oldc)
        return colutil.allEnterable(newOnly, entity, d, from, to)
    end

    local function canMoveLeave(oldr, r, d, from, to)
        local oldc = cgg:colliding(oldr)
        local newc = cgg:colliding(r)
        local newOnly = newc:differenceTo(oldc)
        return colutil.allLeaveable(oldc, entity, d, from, to) or
               newOnly.count == 0
    end

    local actTimer = jd.Clock()
    local inputMoved = InputMovedComponent(entity,
        function (destr, oldr, d0, d, comp)
            local step = d0 * tilew
            local steplen = #step
            local dlen = #d -- oldr.xy -- destr.xy
            if dlen < steplen then
                step = d
                steplen = dlen
            end

            local mlen = 0 -- oldr.xy -- r.xy
            local r = jd.Rect(oldr.xy, oldr.wh)

            local function maybeActivate()
                if comp.firstMove or
                   r ~= oldr and actTimer.elapsedTime:asSeconds() > 0.1 then
                    local activateRect = jd.Rect(
                        r.xy + d0 * ACTIVATE_DISTANCE, r.size)
                    if activateAll(cgg:colliding(activateRect), entity) then
                        actTimer:restart()
                    end -- if any activation happened
                end -- if comp.firstMove
            end -- local function maybeActivate()


            while mlen ~= dlen do
                mlen = mlen + steplen

                local newr
                if mlen > dlen then
                    mlen = dlen
                    newr = destr
                else
                    newr = jd.Rect(r.xy + step, r.wh)
                end
                local ok = canMoveEnter(r, newr, d, oldr.xy, destr.xy)
                if not ok then
                    step = step / 2
                    steplen = #step
                    if steplen < 1 and steplen < dlen then
                        maybeActivate()
                        return r.xy
                    end
                    mlen = mlen - steplen
                elseif canMoveLeave(r, newr, d, oldr.xy, destr.xy) then
                    r = newr
                else
                    local outp = r:outermostPoint(d0, r)
                    return cutMovementFrom(
                        r.xy, outp, map:tileRect(
                            map:tilePosFromGlobal(r.center))
                    ) - outp + r.xy
                end
            end
            maybeActivate()
            return r.xy
        end -- InputMovedComponent callback
    )

    local walkSound = jd.Sound(jd.SoundBuffer.request('walk'))
    walkSound.looped = true

    inputMoved.onStart:connect(function() walkSound:play() end)
    inputMoved.onStop:connect(function() walkSound:stop() end)

    entity:finish()
    return entity
end

return M
