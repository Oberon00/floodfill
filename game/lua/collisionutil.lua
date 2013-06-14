local M = { }

local function all(collisions, memfn, ...)
    for c in collisions:iter() do
        local cinfo = c.entity:component 'CollisionInfoComponent'
        if cinfo and not cinfo[memfn](cinfo, ...) then
            return false
        end -- if cinfo and cinfo:canEnter
    end -- for c in collisions
    return true

end

function M.allEnterable(collisions, entity, dir, from, to)
    return all(collisions, 'canEnter', entity, dir, from, to)
end

function M.allLeaveable(collisions, entity, dir, from, to)
    return all(collisions, 'canLeave', entity, dir, from, to)
end


return M
