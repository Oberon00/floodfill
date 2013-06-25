-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local layers = require 'data.layers'
local TriggerBase = require 'entity.TriggerBase'

local M = { }

local function activate(self, activator)
    jd.soundManager:playSound "button"
    local cons = self.data.connections
    for i = 1, #cons  do
        self.data:processConnection(cons[i])
    end
end

function M.createSubstitute(processConnection, name, id, pos, data, props)
    local entity, actcomp = TriggerBase.createSubstitute(
        activate, layers.LOCKS, name, id, pos, data, props)
    actcomp.data.processConnection = processConnection
    entity:finish()
    return entity
end -- function M.substitute

return M
