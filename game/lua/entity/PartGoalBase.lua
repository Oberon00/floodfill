local M = { }

local WaterActivated = require 'entity.WaterActivated'
local tabutil = require 'tabutil'
local util = require 'util'

function M.createSubstitute(onFlooded, tag, name, id, pos, data, props)
    assert(util.isCallable(onFlooded))
    local registry = tabutil.default(data, tag)
    registry[#registry + 1] = pos
	return WaterActivated.createSubstitute(function(data, pos, flood)
        if registry.done then
            return
        end
        for i = 1, #registry do
            if not flood:isFlooded(registry[i]) then
                return
            end
        end
        registry.done = true
        onFlooded(data, pos, flood)
    end, name, id, pos, data, props)
end -- function M.createSubstitute

return M
