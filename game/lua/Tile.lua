-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local oo = require 'oo'
local util = require 'util'
local tabutil = require 'tabutil'
require 'comp.CollisionInfo'

local C = lclass 'Tile'

local function parseDirections(dirs)
    if dirs == true then
        return {n = true, e = true, s = true, w = true}
    end
    if not dirs then
        return { }
    end

    local result = { }
    local function entry(dir)
        if dirs:find(dir, 1, true) then
            result[dir] = true
        end
    end
    entry 'n' entry 'e' entry 's' entry 'w'
    return result
end

function C:__init(enter, leave, replObj, doSetProxy, bridging, name)
    self.name = name
    self.enterable = parseDirections(enter)
    self.bridging = bridging == nil or not not bridging
    if leave ~= nil then
        self.leaveable = parseDirections(leave)
    else
         self.leaveable = tabutil.copy(self.enterable)
    end

    if replObj then
        self.doSubstitute = true
        if type(replObj) == 'function' then
            self.substitute = replObj
        else
            self.substitute = replObj.createSubstitute
        end
        assert(util.isCallable(self.substitute),
            "replObj is not a valid substitute")
    end
    if doSetProxy == nil then
        self.doSetProxy = not self.doSubstitute
    else
        self.doSetProxy = doSetProxy
    end
end

function C:__call(group, name, id, map) -- create proxy entity
    local entity = jd.Entity()
    local tcinfo = jd.TileCollisionComponent(entity)
    local cinfo = CollisionInfoComponent(entity, self)
    entity:finish()
    return entity, tcinfo, cinfo
end

function C:__tostring()
    if self.name then
        return "Tile: " .. self.name
    end
    return oo.objectToString(self)
end

function C.logicalName(name)
    -- split at '#', when only digits are after it
    local result = name:match("([^#]+)#%d+")
    return result, result ~= nil
end

return C
