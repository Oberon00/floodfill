local M = { }

-- If you can ignore false, then you should prefer the "v or default" syntax
-- over this function: it's faster and more readable.
function M.default(v, default)
	if v ~= nil then
		return v
	end
	return default
end

function M.callopt(f, ...)
	if f then
		return f(...)
	end
end

-- Beware: nil vs. { } 
function M.forward(fn, args)
	local targs = type(args)
	if targs == 'table' then
		return fn(table.unpack(args))
	elseif targs == 'nil' then
		return fn()
	end
	return fn(args)
end

--[[ -- dont't use: deprecated
package.datapath = package.datapath or "res/lua/?.lua;res/lua/?.luac"

local function daterr(op, result, err)
	if result == nil then
		error("Could not " .. op .. " datafile: " .. err)
	end
	assert(err == nil, "both result and err non-nil")
	return result
end

function M.loaddatafile(name)
	local chunk = daterr("load", loadfile(
		daterr("find", package.searchpath(name, package.datapath))))
	return chunk()
end
--]]
return M
