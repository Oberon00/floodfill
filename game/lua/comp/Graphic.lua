local C = component 'GraphicComponent'

function C:init(drawable)
	self._drawable = drawable
end

function C:drawable()
	return self._drawable
end

function C:setDrawable(drawable)
	self._drawable = drawable
	if drawable and self.pos then
		self._drawable.position = self.pos.position
	end
end

function C:initComponent()
	self.pos = self.parent:require 'PositionComponent'
	if self._drawable then
		self._drawable.position = self.pos.position
	end
	self.evts:connect(self.pos, "rectChanged", function(r)
		if self._drawable then
			self._drawable.position = r.position
		end
	end)
end

function C:cleanup()
	self.pos = nil
	if self._drawable then
		self._drawable:release()
		self._drawable = nil
	end
end

return C
