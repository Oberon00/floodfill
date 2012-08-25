component 'GraphicComponent'

function GraphicComponent:_init(drawable)
	self.drawable = drawable
end

function GraphicComponent:initComponent()
	local pos = self.parent:require 'PositionComponent'
	self.evts:connect(pos, "rectChanged", function(r)
		if self.drawable then
			self.drawable.position = r.position
		end
	end)
end

function GraphicComponent:cleanup()
	if self.drawable then
		self.drawable:release()
	end
end