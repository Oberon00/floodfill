local T = require 'Tile'

local function reqe(e) return require('entity.' .. e) end
local Lock = reqe 'Lock'
local Lever = reqe 'Lever'
local Fount = reqe 'Fount'
local LowBridge = reqe 'LowBridge'
local Goal = reqe 'Goal'
local OnButton = reqe 'OnButton'
local OffButton = reqe 'OffButton' 
local ToggleButton = reqe 'ToggleButton'
local LavaPassage = reqe 'LavaPassage'


local tiles = {
    --               enter   leave
	-- name      = T('nesw', 'nesw', replObj,      doSetProxy),
	lock_open    = T('nesw', nil,    Lock,         true ),
	fount        = T('nesw', nil,    Fount,        true ),
	bridge_h     = T('ew',   nil,    nil,          true ),
    bridge_low_h = T('ew',   nil,    LowBridge,    false),
	bridge_low_v = T('ns',   nil,    LowBridge,    false),
	lava_passage = T('nesw', nil,    LavaPassage,  false),
	bridge_v     = T('ns',   nil,    nil,          true ),
	lever        = T('',     nil,    Lever,        false),
	button_toggle= T('',     nil,    ToggleButton, false),
	button_on    = T('',     nil,    OnButton,     false),
	button_off   = T('',     nil,    OffButton,    false),
    water_ground_rough = T('', nil,  nil,          true ),
	water        = T('',     nil,    nil,          true ),
	goal         = T('nesw', nil,    Goal,         true ),
	ground       = T('nesw', nil,    nil,          true ),
	player       = T('',     nil,    nil,          true ),
	water_ground = T('nesw', nil,    nil,          true ),
	barrage      = T('',     nil,    nil,          true ),
	oneway_n     = T('esw',  'nesw', nil,          true ),
	oneway_e     = T('nsw',  'nesw', nil,          true ),
	oneway_s     = T('new',  'nesw', nil,          true ),
	oneway_w     = T('nes',  'nesw', nil,          true )
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
	return table.concat(result)
end

local function l(sides) -- lever
	tiles['lock_' .. sides] = T(negate(sides), nil, Lock, true)
end

l 'n' l 'e' l 's' l 'w' --4x1
l 'ne' l 'ns' l 'nw' l 'es' l 'ew' l 'se' l 'sw' l 'ew' -- 8x2
l 'nes' l 'new' l 'nsw' l 'esw' -- 4x3
l 'nesw' -- 1x4

for k, v in pairs(tiles) do
	v.name = k
end

return tiles
