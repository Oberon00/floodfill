local layers = require 'data.layers'
local TriggerBase = require 'entity.TriggerBase'

local M = { }

local function activate(self, activator)
	local cons = self.data.connections
	for i = 1, #cons  do
		self.data:processConnection(cons[i])
	end
end

function M.createSubstitute(processConnection, name, id, pos, data, props)
	local entity, actcomp = TriggerBase.createSubstitute(
		activate, layers.LOCKS, name, id, pos, data, props)
	actcomp.data.processConnection = processConnection
	entity:finish()
	return entity
end -- function M.substitute

return M
