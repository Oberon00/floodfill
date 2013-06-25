-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local C = component 'CollisionInfoComponent'

local util = require 'util'

local function checkVec(v, ok)
    local result = true
    if v.x < 0 then
        result = result and ok.e
    elseif v.x > 0 then
        result = result and ok.w
    end
    if v.y < 0 then
        result = result and ok.s
    elseif v.y > 0 then
        result = result and ok.n
    end
    return result
end

function C:init(tile)
    self.tile = tile
end

function C:canEnter(entity, dir, from, to)
    return checkVec(dir, self.tile.enterable)
end

function C:canLeave(entity, dir, from, to)
    return checkVec(dir * -1, self.tile.leaveable)
end

return C
