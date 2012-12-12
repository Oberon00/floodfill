local M = { }

local PartGoalBase = require 'entity.PartGoalBase'
local tag = { }
function M.createSubstitute(...)
	return PartGoalBase.createSubstitute(function(data)
        print("winLevel", data)
        data.winLevel()
    end, tag, ...)
end -- function M.createSubstitute

return M
