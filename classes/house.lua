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

function House:CanBecomeFarmer()
    if self.Type ~= Params.House.Type.Standard then return false end
    local function isFarmerTile(tile) return tile.Type == Params.Tile.Type.Grain end

    if isFarmerTile(self.Site) then return true end
    for _, t in ipairs(Gamestate.current().Map:GetAdjacentTiles(self.Site.X, self.Site.Y)) do
        if t then
            if isFarmerTile(t) then return true end
        end
    end
end

function House:CanBecomeFisher()
    if self.Type ~= Params.House.Type.Standard then return false end
    local function isFisherTile(tile) return tile.Type == Params.Tile.Type.Riverside or tile.Type == Params.Tile.Type.River end

    if isFisherTile(self.Site) then return true end
    for _, t in ipairs(Gamestate.current().Map:GetAdjacentTiles(self.Site.X, self.Site.Y)) do
        if t then
            if isFisherTile(t) then return true end
        end
    end
end

function House:CanBecomeLumberjack()
    if self.Type ~= Params.House.Type.Standard then return false end
    local function isFarmerTile(tile) return tile.Type == Params.Tile.Type.Grain end

    if isFarmerTile(self.Site) then return true end
    for _, t in ipairs(Gamestate.current().Map:GetAdjacentTiles(self.Site.X, self.Site.Y)) do
        if t then
            if isFarmerTile(self.Site) then return true end
        end
    end
end

function House:Convert(type)
    self.Type = type
end

function House:CanBecomeBuilder()
    return self.Type == Params.House.Type.Standard
end

function House:draw()
    love.graphics.draw(self.Owner.Sprites[self.Type], self.Site:RealX(), self.Site:RealY())
end

function House:_getBuildableNeighbours()
    local buildables, map = {}, Gamestate.current().Map
    for dir, ct in ipairs(map:GetCardinalTiles(self.Site.X, self.Site.Y)) do
        -- and then for every NEWS tile, we need to know when we can build in the same direction
        local t = map:GetAdjacentTile(ct.X, ct.Y, dir)
        if t then
            if t:CanBuild() then table.insert(buildables, t) end
        end
    end
    return buildables
end

function House:CheckSurrounded()
    local buildables = self:_getBuildableNeighbours()
    self.Surrounded = #buildables == 0 -- if there's nowhere we can build, we're surrounded
end

function House:BuildHouse(player)
    local buildables = self:_getBuildableNeighbours()
    buildables[math.random(#buildables)]:BuildHouse(player)
end

return House