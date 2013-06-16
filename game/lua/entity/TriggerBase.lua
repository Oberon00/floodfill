require 'comp.Activateable'
require 'comp.CollisionInfo'

local M = { }

function M.createSubstitute(onActivate, dstLayer, name, id, pos, data, props)
    local maploader = require 'maploader'
    local tiles = require 'data.tiles'

    local entity = jd.Entity()
    CollisionInfoComponent(entity, tiles[name])
    local poscomp = jd.PositionComponent(entity)

    local map = data.map
    poscomp.rect = map:tileRect(jd.Vec2(pos))
    local tposcomp = jd.TilePositionComponent(entity, map, pos.z)
    jd.TileCollisionComponent(entity, data.tileCollisionInfo)

    local actData = {
        pos = tposcomp,
        map = data.map,
        connections = { }
    }

    local connections = props.objectGroups:get 'connections'
    if not connections then
        jd.log.w "TriggerBase.createSubstitute: group 'connections' missing"
        return nil
    end
    local conobjs, points = maploader.findConnections(
        poscomp.rect, map, connections.objects)
    local actCons = actData.connections
    data.postLoad:connect(function(data)
        for i = 1, #points do
            local p = data.map:tilePosFromGlobal(points[i])
            local dst = data.tileCollisionInfo:colliding(
                jd.Vec3(p.x, p.y, dstLayer))
            if dst then
                dst = dst.parent:component 'TwoStateTileComponent'
                if dst then
                    actCons[#actCons + 1] = {
                        dst = dst,
                        negate = not not conobjs[i].properties:get 'negate'
                    }
                end -- if dst (TwoStateTileComponent)
            end -- if dst
        end -- for each in points
    end) -- data.postLoad callback
    local actcomp = ActivateableComponent(entity, onActivate, actData)

    -- dont finish entity
    return entity, actcomp
end -- function M.substitute

return M
