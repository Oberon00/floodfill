-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local layers = require 'data.layers'
local ButtonBase = require 'entity.ButtonBase'

local M = { }

local function processConnection(data, con)
    con.dst:setState(not con.negate)
end

function M.createSubstitute(...)
    return ButtonBase.createSubstitute(processConnection, ...)
end -- function M.substitute

return M
