local layers = require 'data.layers'
local TriggerBase = require 'entity.TriggerBase'

local M = { }

local function activate(self, activator)
    jd.soundManager:playSound "lever"
    self.data.on = not self.data.on
    self.data.map:set(self.data.pos.tilePosition,
        self.data.on and self.data.TID_ON or self.data.TID_OFF)
    local cons = self.data.connections
    for i = 1, #cons  do
        local s = self.data.on
        if cons[i].negate then
            s = not s
        end
        cons[i].dst:setState(s)
    end
end

function M.createSubstitute(name, id, pos, data, props)
    local tids = data.tileMapping.byName

    local TID_ON  = tids['lever#2']
    local TID_OFF = tids['lever#1']

    local entity, actcomp = TriggerBase.createSubstitute(
        activate, layers.LOCKS, name, id, pos, data, props)

    actcomp.data.on = id == TID_ON
    actcomp.data.TID_ON = TID_ON
    actcomp.data.TID_OFF = TID_OFF

    entity:finish()

    return entity
end -- function M.substitute

return M
