local Class = require "lib.hump.class"
local Params = require "classes.params"

local House = Class {
    init = function(self, owner, site, prepopulate)
        self.Owner = owner
        self.Site = site
        self.Population = prepopulate or 0
        self.Type = Params.House.Type.Standard
    end
}

function House:draw()
    love.graphics.draw(self.Owner.Sprites.Standard, self.Site:RealX(), self.Site:RealY())
end

return House