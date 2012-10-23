--[[
	module maploader: loads tilemaps, tilesets and populates them with Entities
	
	The public interface consists only of the function loadmap.

	# Where does data come from? #
	
		* the tilemap file itself (tmx) and the associated tilemap file (tsx;
		  this is handled transparently by jd, as if the tsx was directly
		  embedded in the tmx)
		* the tile database (data.tiles, ie. lua/data/tiles.lua)
		* the entity modules (lua/entity/<objecttype>.lua
	
	The tsx contains just the names of the tiles, so that a mapping
	tile-ID <--> tile-name --> tile-data can be etablished. Other properties
	are ignored.
	
	Since the tile-ID <--> tile-name mapping can change on a per-tileset basis,
	it is reloaded for every map.
	
	# What is done? #
	
	 1. The tilemap is loaded with loadFromFile (see mapFile() for details about
	    the name --> filename mapping).
	 2. Using the returned information, especially the 'name' properties of the
	    tiles in the tileset, the tile-ID <--> tile-name mapping is established
	    (see above).
	 3. A TileCollisionGroup and a table (name --> entity) containing
	    proxy-entities for each tile-ID are set up, skipping those who have an
	    objectReplacement property.
	 4. Each tile which is on the map and has an objectReplacement, is replaced
	    by the corresponding object by calling the property, threating it as a
	    constructor. However, the tile-ID at the map position isn't changed.
	    If this is neccessary, it's the responsibility of the ctor.
	 5. A table of the following form is returned:
	    {
			map = the jd.Tilemap passed as arg#1, loaded
			name = arg#2: string
			tileProxies = {name = proxy: jd.Entity}
			substituteObjects = {sequence: jd.Entity}
			tileCollisionInfo = jd.TileCollideableInfo
			mapObjects = {groupname = {sequence: jd.Entity}}
			objectColliders = {groupname or # = jd.RectCollideableGroup}
			tileMapping = {byName = {name = id}, byId = {id = name}}
	    }
--]]


local util = require 'util'
local tabutil = require 'tabutil'

local M = { }

local tiledata = require 'data.tiles'

local function mapFile(name)
	return "maps/" .. name .. ".tmx"
end

local function createTile(name, id, map)
	-- some tiles have multiple names (eg. Fount#1, #2, ...), so pass the name
	-- in order to distinguish them.
	return tiledata[name](name, id, map)
end

local function createObject(objectInfo, layerInfo, mapdata, props)
	if objectInfo.type == '' then
		return nil
	end
	local Entity = require('entity.' .. objectInfo.type)
	return Entity.load(objectInfo, layerInfo, mapdata)
end

local function substituteObject(name, id, position, mapdata, props)
	return tiledata[name].substitute(name, id, position, mapdata, props)
end

local function findTileIdMapping(props)
	local result = {byName = { }, byId = { }}
	for id = 1, props.count do
		local tprops = props:get(id)
		local name = tprops:get 'name'
		if name then
			result.byName[name] = id
			result.byId[id] = name
		end -- if name
	end -- for each tprops in props
	return result
end

local function setupProxies(tileMapping, collisionInfo, map)
	local proxies = { }
	for tname, tid in pairs(tileMapping.byName) do
		local tile = tiledata[tname]
		if not tile then
			jd.log.w(("No data for tile '%s' (#%i) available")
				:format(tname, tid))
		elseif not tile.isPlaceholder then
			local entity, proxy = createTile(tname, tid, map)
			proxies[tname] = entity
			collisionInfo:setProxy(tid, proxy)
		end -- if is no placeholder
	end -- for each mapdata.data.tiles
	return proxies
end

local function setupObjects(props, mapdata)
	mapdata.objectColliders = { }
	local objects = { }
	local groups = props.objectGroups
	for kv in groups:iter() do
		local groupInfo = kv.value
		local group = { }
		assert(groupInfo.name == kv.key)
		local hasName = groupInfo.name ~= ''
		local groupId = hasName and groupInfo.name or #objects + 1
		objects[groupId] = group
		local collider = jd.RectCollideableGroup()
		mapdata.objectColliders[groupId] = collider
		for i = 1, groupInfo.objects.count do
			local objectInfo = groupInfo.objects:get(i)
			local obj = createObject(objectInfo, groupInfo, mapdata, props)
			if obj then
				group[i] = obj
				local objPos = obj:component 'PositionComponent'
				if objPos then
					collider:add(objPos)
				end -- if objPos
			end -- if obj
		end -- for each object in layer
	end -- for each layer
	return objects
end

local function substituteObjects(props, mapdata)
	local objects = { }
	local map = mapdata.map
	local tileMapping = mapdata.tileMapping
	local mapsz = map.size
	local i = 1
	for z = 0, mapsz.z - 1 do
		for x = 0, mapsz.x - 1 do
			for y = 0, mapsz.y - 1 do
				local position = jd.Vec3(x, y, z)
				local tid = map:get(position)
				local tname = tileMapping.byId[tid]
				if tname then
					local tile = tiledata[tname]
					if tile and tile.isPlaceholder then
						local obj = substituteObject(
							tname, tid, position, mapdata, props)
						if obj then -- skip nil
							objects[i] = obj
							i = i + 1
						end -- if obj
					end -- if map[x, y, z] is placeholder
				end -- if tname
			end -- for y
		end -- for x
	end -- for z
	return objects
end
	
function M.loadMap(map, name, result)
	result = result or { }
	local props = map:loadFromFile(mapFile(name))
	local tileCollisionInfo = jd.TileCollideableInfo(map)
	local result = {
	
	result.map = map
	result.name = name
	result.tileMapping = findTileIdMapping(props.tileProperties)
	result.tileCollisionInfo = tileCollisionInfo
	result.postLoad = { }
	result.tileProxies = setupProxies(
		result.tileMapping, tileCollisionInfo, map)
	result.substituteObjects = substituteObjects(props, result)
	result.mapObjects = setupObjects(props, result)
	
	for _, postLoadCallback in ipairs(result.postLoad) do
		postLoadCallback(result, props)
	end
	result.postLoad = nil
	return result
end

return M
