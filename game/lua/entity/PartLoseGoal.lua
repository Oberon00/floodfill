local M = { }

local PartGoalBase = require 'entity.PartGoalBase'

local tag = { }

function M.createSubstitute(...)
    return PartGoalBase.createSubstitute(function(data)
        data.loseLevel()
    end, tag, ...)
end -- function M.createSubstitute

return M
