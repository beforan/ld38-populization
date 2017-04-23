local Class = require "lib.hump.class"
local Params = require "classes.params"

local House = Class {
    init = function(self, owner, site, prepopulate)
        self.Owner = owner
        self.Site = site
        self.Population = prepopulate or 0
        self.Type = Params.House.Type.Standard
        self.Surrounded = false
    end
}

function House:draw()
    love.graphics.draw(self.Owner.Sprites.Standard, self.Site:RealX(), self.Site:RealY())
end

function House:CheckSurrounded()
    for _, at in ipairs(Gamestate.current().Map:GetAdjacentTiles(self.Site.X, self.Site.Y)) do
        -- and then for every adjacent tile, we need to know where there are houses
        -- culling would be good here...
    end
end

function House:BuildHouse()
    for _, v in ipairs(Gamestate.current().Map:GetAdjacentTiles(self.X, self.Y)) do
        v.Homestead = true
    end
end

return House