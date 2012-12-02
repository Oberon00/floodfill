local M = { }

local WaterActivated = require 'entity.WaterActivated'

function M.createSubstitute(...)
	return WaterActivated.createSubstitute(function(data)
        data.winLevel()
    end, ...)
end -- function M.createSubstitute

return M
