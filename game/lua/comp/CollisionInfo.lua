component 'CollisionInfoComponent'

local Cic = CollisionInfoComponent

-- override this function to fit your needs
function Cic:canEnter(entity)
	return true
end

return Cic
