local C = lclass 'Flood'

local evt = require 'evt'
local layers = require 'data.layers'
local colutil = require 'collisionutil'

local UPDATE_TIMEOUT = jd.DEBUG and jd.seconds(0.5) or jd.seconds(0.2)

local function vec2(v)
	return jd.Vec2(v.x, v.y)
end

local function canFlow(map, collider, proxy, from, to)
	assert(map:isValidPosition(from))
	if not map:isValidPosition(to) then
		return false
	end
	from = vec2(from)
	to = vec2(to)
	local d = to - from
	local gfrom, gto = map:tilePos(from), map:tilePos(to)
	return
		colutil.allLeaveable(
			collider:colliding(gfrom, gfrom), proxy, d, gfrom, gto)
		and colutil.allEnterable(
			collider:colliding(gto, gto), proxy, d, gfrom, gto)
end

local function surroundingPositions8(p)
	-- 123
	-- 4p5
	-- 678
	return {
		jd.Vec3(p.x - 1, p.y - 1, p.z), -- 1
		jd.Vec3(p.x,     p.y - 1, p.z), -- 2
		jd.Vec3(p.x + 1, p.y - 1, p.z), -- 3
		jd.Vec3(p.x - 1, p.y,     p.z), -- 4
		jd.Vec3(p.x + 1, p.y,     p.z), -- 5
		jd.Vec3(p.x - 1, p.y + 1, p.z), -- 6
		jd.Vec3(p.x,     p.y + 1, p.z), -- 7
		jd.Vec3(p.x + 1, p.y + 1, p.z)  -- 8
	}
end

local function surroundingPositions4(p)
	--  1 
	-- 2p3
	--  4 
	return {
		jd.Vec3(p.x,     p.y - 1, p.z), -- 1
		jd.Vec3(p.x - 1, p.y,     p.z), -- 2
		jd.Vec3(p.x + 1, p.y,     p.z), -- 3
		jd.Vec3(p.x,     p.y + 1, p.z), -- 4
	}
end

local function markPoint(t, p)	
	local column = t[p.x]
	if not column then
		t[p.x] = {[p.y] = true}
	else
		column[p.y] = true
	end
end

local function isPointMarked(t, p)
	local column = t[p.x]
	return column and column[p.y]
end



local function floodFillLayer(
	map, collider, waterTid, waterProxy, start, isWater, waterBorderPositions)
	isWater = isWater or { }
	waterBorderPositions = waterBorderPositions or { }
	local open = {start}
	local openLen = 1
	local done = { }
		
	markPoint(done, start)
		
	while openLen > 0 do
		local p = open[openLen]
		openLen = openLen - 1
		local surrounding = surroundingPositions4(p)
		for i = 1, 4 do
			local n = surrounding[i]
			if not isPointMarked(done, n) then
				markPoint(done, n)
				if canFlow(map, collider, waterProxy, p, n) then
					if map:get(n) == waterTid then
						openLen = openLen + 1
						open[openLen] = n
						markPoint(isWater, n)
					else
						waterBorderPositions[#waterBorderPositions + 1] = n
					end
				end
			end
		end
	end
	return isWater, waterBorderPositions
end

function C:__init(world)
	local waterProxy
	world.postLoad[#world.postLoad + 1] = function(world)
		waterProxy =  world.tileProxies.water
		local cinfo = waterProxy:require 'CollisionInfoComponent'
		local canEnter, canLeave = cinfo.canEnter, cinfo.canLeave
		function cinfo.canEnter(self, entity, ...)
			return entity == waterProxy or canEnter(self, entity, ...)
		end
		function cinfo.canLeave(self, entity, ...)
			return entity == waterProxy or canLeave(self, entity, ...)
		end
	end
	local map = world.map
	self.founts = { }
	local evts = evt.Table()
	local waterTid = world.tileMapping.byName.water
	local collider = jd.TileLayersCollideableGroup(
		world.tileCollisionInfo, layers.WATER_GROUND, layers.LOCKS + 1)
	evts:add(jd.timer:callEvery(UPDATE_TIMEOUT, function()
		local isConnectedWater = { }
		local newWater = { }
		for i = 1, #self.founts do
			floodFillLayer(
				map, collider, waterTid, waterProxy, self.founts[i],
				isConnectedWater, newWater)
		end
		
		for x = 0, map.size.x - 1 do
			for y = 0, map.size.y - 1 do
				local p = jd.Vec3(x, y, layers.WATER)
				local tid = map:get(p)
				if tid == waterTid and
				   not isPointMarked(isConnectedWater, p)
				   and math.random(2) == 1 then
					map:set(p, 0)
				end -- if unconnected water found
			end -- for y
		end -- for x
		
		for i = 1, #newWater do
			map:set(newWater[i], waterTid)
		end		
	end))
	evts:add(world.onStop:connect(function() evts:disconnect() end))
end

function C:registerFount(position)
	self.founts[#self.founts + 1] = position
end

function C:unregisterFount(position)
	tabutil.erase(self.founts, position)
end

return C
