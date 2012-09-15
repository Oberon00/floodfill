local C = component 'GraphicComponent'

function C:_init(drawable)
	self.drawable = drawable
end

function C:initComponent()
	local pos = self.parent:require 'PositionComponent'
	self.evts:connect(pos, "rectChanged", function(r)
		if self.drawable then
			self.drawable.position = r.position
		end
	end)
end

function C:cleanup()
	if self.drawable then
		self.drawable:release()
	end
end