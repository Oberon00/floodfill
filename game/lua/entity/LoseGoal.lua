-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local M = { }

local WaterActivated = require 'entity.WaterActivated'

function M.createSubstitute(...)
    return WaterActivated.createSubstitute(function(data)
        data.loseLevel()
    end, ...)
end -- function M.createSubstitute

return M
