require 'comp.Activateable'
require 'comp.CollisionInfo'
local layers = require 'data.layers'

local M = { }

local LAYER_LOCK = layers.LOCKS
local OBJT_LINE = jd.mapInfo.Object.LINE

local function activate(self, activator)
	self.data.opened = not self.data.opened
	self.data:apply()
end

local function apply(self)
	if self.lockp then
		self.map:set(
			self.lockp, self.opened and self.TID_OPEN or self.lockedTid)
	end
	self.map:set(self.selfp, self.opened and self.TID_ON or self.TID_OFF)
end

function M.createSubstitute(name, id, pos, data, props)
	local tiles = require 'data.tiles' 
	local tids = data.tileMapping.byName
	
	local TID_ON  = tids['lever#2']
	local TID_OFF = tids['lever#1']

	local entity = jd.Entity()
	CollisionInfoComponent(entity, tiles[name])
	local poscomp = jd.PositionComponent(entity)
	poscomp.rect = data.map:tileRect(jd.Vec2(pos.x, pos.y))
	jd.TilePositionComponent(entity, data.map, pos.z)
	jd.TileCollisionComponent(entity, data.tileCollisionInfo)
	
	local actData = {
		apply = apply,
		
		opened = false,
		lockedTid = false,
		selfp = pos,
		lockp = false,
		map = data.map,
		TID_OPEN = tids.lock_open,
		TID_ON = TID_ON,
		TID_OFF = TID_OFF
	}
	
	local connections = props.objectGroups:get 'connections'
	if not connections then
		jd.log.w "Lever.substitute: object group 'connections' missing"
		return nil
	end

	local r = data.map:localTileRect(jd.Vec2(pos.x, pos.y))

	for c in connections.objects:iter() do
		if c.objectType == OBJT_LINE then
			local points = c.absolutePoints
			local p1 = points:get(1)
			local p2 = points:get(points.count)
			local lockp = r:contains(p1) and p2 or r:contains(p2) and p1
			if lockp then
				lockp = data.map:tilePosFromLocal(lockp)
				actData.lockp = jd.Vec3(lockp.x, lockp.y, LAYER_LOCK)
				local locktid = data.map:get(actData.lockp)
				actData.lockedTid = locktid == tids.lock_open and
					tids.lock_nesw or locktid
				actData.opened = id == TID_ON
				break
			end -- if lockp
		end -- if c.objectType == OBJT_LINE
	end -- for each c in connections
	
	ActivateableComponent(entity, activate, actData)
	entity:finish()

	actData:apply()
	
	return entity
end -- function M.substitute

return M
