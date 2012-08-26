local T = require 'Tile'
local Lock = require 'Lock'
local Fount = require 'Fount'
local LowBridge = require 'LowBridge'

local tiles = {
    --               enter   leave
	-- name      = T('nesw', 'nesw', replObj  )
	lock_open    = T('',     '',     nil      )
	fount        = T('nesw', 'nesw', Fount    )
	bridge_h     = T('ew',   nil,    nil      )
    bridge_low_h = T('ew',   nil,    LowBridge)
	bridge_v     = T('ns',   nil,    nil      )
}

local function negate(sides)
	result = { }
	local function ng(dir)
		if not sides:find(dir, 1 true) then
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
return tiles