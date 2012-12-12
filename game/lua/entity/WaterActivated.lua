local M = { }

local ensureFlood = (require 'proc.Flood').ensureFlood
local util = require 'util'

function M.createSubstitute(onFlooded, name, id, pos, data, props)
    assert(util.isCallable(onFlooded))
	local flood = ensureFlood(data)
	flood.onFlow:connect(function()
		if flood:isFlooded(pos) then
			onFlooded(data, pos, flood)
		end -- if flood:isFlooded(pos)
	end) -- flood.onFlow callback
end -- function M.createSubstitute

return M
