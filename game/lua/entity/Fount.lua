local M = { }

local Flood = require 'proc.Flood'

function M.createSubstitute(name, id, pos, data, props)
	if not data.procs.flood then
		data.procs.flood = Flood(data)
	end
	data.procs.flood:registerFount(pos)
	return nil
end -- function M.substitute

return M
