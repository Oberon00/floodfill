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
			map: jd.Tilemap = the map passed as arg#1, loaded
			name: string = arg#2
			collisionManager: jd.CollisionManager =
				the CollisionManager passed as [arg#3] or a new one
			tileProxies: table = {name = proxy: jd.Entity}
			substituteObjects: table = {sequence: jd.Entity}
			tileProxyCollider: jd.TileCollideableGroup
			mapObjects: table = {groupname = {sequence: jd.Entity}}
			objectCollider: jd.RectCollideableGroup
			tileMapping: table = {byName = {name = id}, byId = {id = name}}
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

local function createObject(objectInfo, layerInfo, mapdata)
	if objectInfo.type == "" then
		return nil
	end
	local Entity = require 'entity.' .. objectInfo.type
	return Entity.load(objectInfo, layerInfo, mapdata)
end

local function substituteObject(name, id, position, map)
	return tiledata[name].substitute(id, position, map)
end

local function findTileIdMapping(props)
	local result = {byName = { }, byId = { }}
	for i = 1, props.count do
		local tprops = props:get(i)
		local name = tprops:get 'name'
		if name then
			local id = i - 1
			result.byName[name] = id
			result.byId[id] = name
		end -- if name
	end -- for each tprops in props
	return result
end

local function setupProxies(tileMapping, collider)
	local proxies = { }
	for tname, tid in pairs(tileMapping.byName) do
		local tile = tiledata[tname]
		if not tile then
			jd.log.w(("No data for tile '%s' (#%i) available")
				:format(tname, tid))
		elseif not tile.isPlaceholder then
			local entity, collisionProxy = createTile(
				tname, tid, collider.tilemap)
			collider:setProxy(tid, proxy)
			proxies[tname] = entity
		end -- if is no placeholder
	end -- for each mapdata.data.tiles
	return proxies
end

local function setupObjects(props, mapdata)
	local objects = { }
	local groups = props.objectGroups
	for kv in groups:iter() do
		local groupInfo = kv.value
		local group = { }
		objects[groupInfo.name or #objects + 1] = group
		for i = 1, groupInfo.objects.count do
			local objectInfo = groupInfo.objects:get(i)
			group[i] = createObject(objectInfo, groupInfo, mapdata)
		end -- for each object in layer
	end -- for each layer
	return objects
end

local function substituteObjects(tileMapping, collider)
	local objects = { }
	local map = collider.tilemap
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
						local obj = substituteObject(tid, tname, position, map)
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
	
function M.loadMap(map, name, collisionMangager)
	collisionManager = collisionManager or jd.CollisionManager()
	local tileProxyCollider = jd.TileCollideableGroup(
		collisionManager, 'tileProxies', map)
	local objectCollider = jd.RectCollideableGroup(
		collisionManager, 'mapObjects')
	local props = map:loadFromFile(mapFile(name))
	local result = {
		map = map,
		name = name,
		collisionManager = collisionManager,
		tileProxyCollider = tileProxyCollider,
		objectCollider = objectCollider,
		tileMapping = findTileIdMapping(props.tileProperties)
	}
	result.tileProxies = setupProxies(result.tileMapping, tileProxyCollider)
	result.substituteObjects = substituteObjects(
		result.tileMapping, tileProxyCollider)
	result.mapObjects = setupObjects(props, result)
	return result
end

return M
