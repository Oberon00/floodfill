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
