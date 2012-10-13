--[[
	module evt
	
	Contains various helper functions and types for connecting events.
--]]

local tabutil = require 'tabutil'
local util = require 'util'

local M = { }

do
	local persistedEvts = { } -- Shields connections from garbage collection

	function M.persistConnection(ev)
		persistedEvts[#persistedEvts + 1] = ev
	end -- function M.persistConnection
end -- do (persistConnection)

function M.connectForever(...)
	M.persistConnection(jd.connect(...))
end


--[[
	Functions connectToKeyPress, connectToKeyRelease:
		Arguments:
			key: The keycode (jd.kb.*) at which f is called (depending on the
				 connection-function either if the key is pressed or released)
			f:   A callback which is called with the key event (as emitted by
			     jd) as arg#1 and the string 'keyPressed' or 'keyReleased' as
				 arg#2.
				 nil is valid and will disconnect the callback for the
				 specified key.
		Note: If there is already a function connected to key and the same event
		      (keyPressed or keyReleased), it is overriden and a warning is
			  printed to the logfile.
--]]
do
	local callbacks = { keyPressed = false, keyReleased = false }
	local function connectToKeyEvent(event, key, f)
		if not callbacks[event] then
			if not f then
				jd.log.w "Attempt to disconnect a key event"
						 " when none was registered."
				return
			end
			M.connectForever(jd.eventDispatcher, event, function(keyEvt)
				util.callopt(callbacks[event][keyEvt.code], keyEvt, event)
			end)
			callbacks[event] = { }
		elseif f and keyPressCallbacks[key] then
			jd.log.w(("%s event: overriding key %s"):format(
				event, jd.kb.keyName(key)))
		end
		callbacks[event][key] = f
	end -- local function connectToKeyEvent
	
	function M.connectToKeyPress(key, f)
		connectToKeyEvent('keyPressed', key, f)
	end
	function M.connectToKeyRelease(...)
		connectToKeyEvent('keyReleased', key, f)
	end
end -- do (connectToKeyPress, connectToKeyRelease)

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
			for _, v in pairs(evt) do
				self:add(v)
			end
		else
			assert(evt.disconnect, "evt (arg#1) has no disconnect method")
			self.evts[#self.evts + 1] = evt
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
