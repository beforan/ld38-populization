local Class = require "lib.hump.class"
local Params = require "classes.params"

local House = Class {
    init = function(self, owner, prepopulate)
        self.Owner = owner
        self.Population = prepopulate or self.Population
    end,
    Type = Params.House.Type.Standard,
    Population = 1
}

function House:draw(x, y)
    love.graphics.draw(self.Owner.Sprites.Standard, x, y)
end

return House