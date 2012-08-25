--[[
	module evt
	
	Contains various helper functions and types for connecting events.
--]]

require 'oo'

local M = { }

local persistedEvts = { } -- Shields connections from garbage collection

function M.persistConnection(ev)
	table.insert(persistedEvts, ev)
end
function M.connectForever(...)
	M.persistConnection(jd.connect(...))
end

lclass('Table', M)

function M.Table:__init(evt)
	self.evts = { }
	if (evt) then
		self:add(evt)
	end
end

function M.Table:__gc()
	self:disconnect()
end

function M.Table:add(evt)
	if type(evt) == 'table' and not evt.disconnect then
		for k, v in pairs(evt) do
			assert(type(k) == 'number',
				"custom keys in table argument to evt.Table:add make no sense")
			self:add(v)
		end
	else
		assert(evt.disconnect, "evt has no disconnect method")
		table.insert(self.evts, evt)
	end
end

function M.Table:connect(...)
	self:add(jd.connect(...))
end

function M.Table:disconnect()
	if jd.CLOSING then
		return
	end
	
	for _, v in pairs(self.evts) do
		local connected = v.isConnected
		if type(connected) == "function" then
			connected = connected()
		end
		if connected then
			v:disconnect()
		end
	end
	self.evts = { }
end

return M
