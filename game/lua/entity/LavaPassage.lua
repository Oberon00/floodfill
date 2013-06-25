-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local BridgeBase = require 'entity.BridgeBase'

local M = { }

function M.createSubstitute(...)
    return BridgeBase.createSubstitute(
        function(flooded)
            return flooded
        end,
        ...)
end -- function M.substitute

return M
