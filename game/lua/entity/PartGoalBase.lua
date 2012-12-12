local M = { }

local WaterActivated = require 'entity.WaterActivated'
local tabutil = require 'tabutil'
local util = require 'util'
local ensureFlood = (require 'proc.Flood').ensureFlood

function M.createSubstitute(onFlooded, tag, name, id, pos, data, props)
    assert(util.isCallable(onFlooded))
    local registry = tabutil.default(data, tag)
    registry[#registry + 1] = pos
    local flood = ensureFlood(data)
	return WaterActivated.createSubstitute(function()
        if registry.done then
            return
        end
        for i = 1, #registry do
            if not flood:isFlooded(registry[i]) then
                return
            end
        end
        registry.done = true
        onFlooded(data)
    end, name, id, pos, data, props)
end -- function M.createSubstitute

return M
