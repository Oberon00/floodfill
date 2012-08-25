local util = require 'util'
local tabutil = require 'tabutil'

local M = { }

M.tiledata = require 'tiles'

local function createObject(name, properties, defaultModule, ...)
	local Object = require(properties.module or defaultModule or
						       'entity.obj.' .. name)
	return Object[properties.maploader or 'fromProperties'](properties, ...)
end

local function createTile(name, properties, ...)
	return createObject(name, properties, 'entity.tile.' .. name, ...)
end

local function addEntities(mapdata, props)
	-- global (adds proxyEntities to jd.entityRoot)
	result.proxyEntities = jd.EntityCollection(jd.entityRoot)
	-- global (adds tileCollider to jd.collisionManager)
	mapdata.tileCollider = jd.TileCollisionGroup('tiles', mapdata.map)
	for k, v in pairs(mapdata.data.tiles) do
		local collisionProxy = createTile(k, v, mapdata)
		mapdata.tileCollider.setProxy(
			v.id, collisionproxy.require 'TileCollisionComponent')
		
	end
	
end

-- If addprops is given, it is modified in place (must be a table).
-- The transformed tile properties are returned in any case.
local function transformTileProps(props, addprops)
	local result = addprops or { }
	for i = 1, props.count do
		local tprops = props:get(i)
		local name = tprops:get 'name'
		if name then
			local out = tabutil.default(result, name, {})
			out.id = i - 1
			for kv in tprops.iter() do
				-- tprops supports only strings, so try to convert it to
				-- boolean, number and at last string.
				-- Tables are not supported.
				local ivalue = kv.value.lower()
				if ivalue == 'true' then
					out[kv.key] = true
				elseif ivalue == 'false' then
					out[kv.key] = false
				else
					out[kv.key] = tonumber(kv.value) or kv.value
				end -- if convertible to boolean / else
			end -- for kv in trops.iter()
			setmetatable(out, {__index = M.tiledata[name]})
		end -- if name
	end -- for each tprops in props
	return result
end

function M.loadMap(name, mapargs)
	local result = {}
	result.map = util.forward(jd.Tilemap, mapargs)
	result.data = require('data.maps. ' .. name)
	local props = result.map:loadFromFile(result.data.filename)
	transformTileProps(props.tileProperties, result.data.tiles)
	addEntities(result, props)
	return result
end

return M
