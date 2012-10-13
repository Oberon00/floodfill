--[[
	component module comp.Activateable
	
	Provides an interface for activateable entities such as levers. Primarly
	intented for interaction with a player-entity.
--]]

local C = component 'ActivateableComponent'

--[[
	Constructor. onActivate (arg#1) should be a function, which should be
	called as a method and with the calling entity as first argument (apart
	from self).
	So when act is an ActivateableComponent, it should look like
		act:activate(callingEntity) (== act.activate(act, callingEntity))
	Don't add new members to ActivateableComponent, this could result in future
	name conflicts. You can, however freely use the data member.
--]]
function C:init(onActivate, data)
	self.activate = onActivate
	self.data = data or { }
end

return C