-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local C = lclass 'LevelList'
local zload = (require 'persistence').zload

local function validIndex(self, i)
    return i > 0 and i <= #self.levels
end

-- Pass level names (strings) as arguments.
function C:__init(levels)
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
    if not validIndex(self, self.currentIndex) then
        return false
    end
    self.currentIndex = self.currentIndex + 1
    if not validIndex(self, self.currentIndex) then
        self.currentIndex = self.currentIndex - 1
        return false
    end
    return true
end

lclass('Entry', C)
    function C.Entry:__init(name, unlocked)
        self.name = name
        self.unlocked = unlocked
    end

C.default = C(require 'data.levels')
for i = 1, zload("unlocked") do
    if not C.default.levels[i] then
        jd.log.w "Too many unlocked levels!"
        break
    end
    C.default.levels[i].unlocked = true
end

return C
