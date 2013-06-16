local M = { }

local WaterActivated = require 'entity.WaterActivated'
local surrounding = (require 'vecutil').surroundingPositions4

local MIN_FLOODED = 2

function M.createSubstitute(name, id, pos, data, props)
    local tidClosed = data.tileMapping.byName['fount_and_closed']
    local tidOpen   = data.tileMapping.byName['fount_and_open']
    return WaterActivated.createSubstitute(function(data, pos, flood)
        local sur = surrounding(pos)
        local floodedCount = 0
        for i = 1, #sur do
            if flood:isFlooded(sur[i]) and flood:canFlow(sur[i], pos) then
                floodedCount = floodedCount + 1
            end
        end
        data.map:set(pos, floodedCount >= MIN_FLOODED and tidOpen or tidClosed)
    end, name, id, pos, data, props)
end -- function M.createSubstitute

return M
