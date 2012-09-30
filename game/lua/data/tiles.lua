local T = require 'Tile'

local tiles = {
    --               enter   leave
	-- name      = T('nesw', 'nesw', replObj  ),
	lock_open    = T('nesw', nil,    nil      ),
	fount        = T('nesw', nil,    nil      ), --?
	bridge_h     = T('ew',   nil,    nil      ),
    bridge_low_h = T('ew',   nil,    LowBridge),
	bridge_low_v = T('ns',   nil,    LowBridge),
	bridge_v     = T('ns',   nil,    nil      ),
	lever        = T('',     nil,    Lever    ),
    water_ground_rough = T('', nil,  nil      ),
	water        = T('',     nil,    nil      ),
	goal         = T('nesw', nil,    Goal     ),
	ground       = T('nesw', nil,    nil      ),
	player       = T('',     nil,    nil      ),
	water_ground = T('nesw', nil,    nil      ),
	barrage      = T('',     nil,    nil      )
}

setmetatable(tiles, {__index = function(t, name)
	local lname, hasLname = T.logicalName(name)
	return hasLname and rawget(t, lname) or nil
end})

local function negate(sides)
	result = { }
	local function ng(dir)
		if not sides:find(dir, 1, true) then
			result[#result + 1] = dir
		end
	end
	ng 'n' ng 'e' ng 's' ng 'w'
end

local function l(sides) -- lever
	tiles["lock_" .. sides] = T(negate(sides), nil, Lock)
end

l 'n' l 'e' l 's' l 'w' --4x1
l 'ne' l 'ns' l 'nw' l 'es' l 'ew' l 'se' l 'sw' l 'ew' -- 8x2
l 'nes' l 'new' l 'nsw' l 'esw' -- 4x3
l 'nesw' -- 1x4

for k, v in pairs(tiles) do
	v.name = k
end

return tiles
