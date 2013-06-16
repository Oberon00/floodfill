local M = { }

local ensureFlood = (require 'proc.Flood').ensureFlood

function M.createSubstitute(name, id, pos, data, props)
    ensureFlood(data):registerFount(pos)
end -- function M.createSubstitute

return M
