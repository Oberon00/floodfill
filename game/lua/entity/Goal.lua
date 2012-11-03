local M = { }

local ensureFlood = (require 'proc.Flood').ensureFlood

function M.createSubstitute(name, id, pos, data, props)
	local flood = ensureFlood(data)
	flood.onFlow:connect(function()
		if flood:isFlooded(pos) then
			data.winLevel()
		end -- if flood:isFlooded(pos)
	end) -- flood.onFlow callback
end -- function M.createSubstitute

return M
