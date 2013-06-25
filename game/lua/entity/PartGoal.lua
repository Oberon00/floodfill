-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local M = { }

local PartGoalBase = require 'entity.PartGoalBase'
local tag = { }
function M.createSubstitute(...)
    return PartGoalBase.createSubstitute(function(data)
        data.winLevel()
    end, tag, ...)
end -- function M.createSubstitute

return M
