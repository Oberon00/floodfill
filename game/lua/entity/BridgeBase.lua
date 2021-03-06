-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

require 'comp.CollisionInfo'
local Flood = require 'proc.Flood'

local M = { }

function M.createSubstitute(canEnter, name, id, pos, data, props)
    local tiles = require 'data.tiles'
    local entity = jd.Entity()
    local cinfo = CollisionInfoComponent(entity, tiles[name])
    local poscomp = jd.PositionComponent(entity)
    poscomp.rect = data.map:tileRect(jd.Vec2(pos))
    local tposcomp = jd.TilePositionComponent(entity, data.map, pos.z)
    jd.TileCollisionComponent(entity, data.tileCollisionInfo)
    local oldCanEnter = cinfo.canEnter
    local flood = Flood.ensureFlood(data)
    function cinfo.canEnter(self, entity, ...)
        return canEnter(flood:isFlooded(tposcomp.tilePosition))
               and oldCanEnter(self, entity, ...)
    end
    entity:finish()
    return entity
end -- function M.substitute

return M
