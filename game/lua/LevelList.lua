local C = lclass 'LevelList'

local function validIndex(self, i)
	return i > 0 and i <= #self.levels
end

-- Pass level names (strings) as arguments.
function C:__init(...)
	local levels = {...}
	self.levels = { }
	for i = 1, #levels do
		self.levels[i] = C.Entry(levels[i])
	end
	self.currentIndex = validIndex(self, 1) and 1 or -1
end

function C:currentLevel()
	return self.levels[self.currentIndex]
end

function C:advance()
	if not validIndex(self.currentIndex) then
		return false
	end
	self.currentIndex = self.currentIndex + 1
	return validIndex(self.currentIndex)
end
	
lclass('Entry', C)
	function C.Entry:__init(name, unlocked)
		self.name = name
		self.unlocked = unlocked
	end
	
return C
