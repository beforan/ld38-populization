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
    local houseCount, map = 0, Gamestate.current().Map
    for dir, ct in ipairs(map:GetCardinalTiles(self.Site.X, self.Site.Y)) do
        -- and then for every NEWS tile, we need to know where there is a house in the same direction
        local t = map:GetAdjacentTile(ct.X, ct.Y, dir)
        if t then
            print(t:CanBuild(), t.House, t.Homestead)
            if not t:CanBuild() then houseCount = houseCount + 1 end
        else --out of bounds - counts as surrounded :|
            houseCount = houseCount + 1
        end
    end
    self.Surrounded = houseCount == 4
end

function House:BuildHouse(player)
    local targets, map = {}, Gamestate.current().Map
    for dir, ct in ipairs(map:GetCardinalTiles(self.Site.X, self.Site.Y)) do
        local t = map:GetAdjacentTile(ct.X, ct.Y, dir)
        if t:CanBuild() then table.insert(targets, t) end
    end
    targets[math.random(#targets)]:BuildHouse(player)
end

return House