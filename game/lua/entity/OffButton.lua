local layers = require 'data.layers'
local ButtonBase = require 'entity.ButtonBase'

local M = { }

local function processConnection(data, con)
	con.dst:setState(con.negate)
end

function M.createSubstitute(...)
	return ButtonBase.createSubstitute(processConnection, ...)
end -- function M.substitute

return M
