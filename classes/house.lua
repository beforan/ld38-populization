local Class = require "lib.hump.class"
local Const = require "classes.const"

local House = Class {
    init = function(self, owner, type)
        self.Owner = owner
        self.Type = type or Const.House.Type.Standard
    end
}

function House:draw()
    love.graphics.draw(owner.Sprites.Standard, x, y)
end

return House