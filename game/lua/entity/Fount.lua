-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local M = { }

local ensureFlood = (require 'proc.Flood').ensureFlood

function M.createSubstitute(name, id, pos, data, props)
    ensureFlood(data):registerFount(pos)
end -- function M.createSubstitute

return M
