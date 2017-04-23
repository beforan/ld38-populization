local Class = require "lib.hump.class"
local Params = require "classes.params"
local House = require "classes.house"
local Assets = require "assets.assets"

local Tile = Class {
    init = function(self, x, y, type)
        self.X = x -- tilemap coords
        self.Y = y
        self.Type = type or Params.Tile.Type.Grass
        self.House = nil
    end,
    Width = Params.Tile.Size,
    Height = Params.Tile.Size,
    RealX = function(self) return (self.X - 1) * self.Width end, -- pixel coords top
    RealY = function(self) return (self.Y - 1) * self.Height end, -- and left
    Buildable = function(self) return self.Type ~= Params.Tile.Type.Woodland and self.Type ~= Params.Tile.Type.River end
}

function Tile:draw(hover)
    local x, y, w, h = self:GetBoundingBox() -- if we need them this way

    if self.Type == Params.Tile.Type.Grass       then love.graphics.draw(Assets.Sprites.Grass, x, y) end
    if self.Type == Params.Tile.Type.Woodland    then love.graphics.draw(Assets.Sprites.Woodland, x, y) end
    if self.Type == Params.Tile.Type.Deforested  then love.graphics.setColor(139, 69, 19, 255) end
    if self.Type == Params.Tile.Type.Grain       then love.graphics.draw(Assets.Sprites.Grain, x, y) end
    if self.Type == Params.Tile.Type.River       then love.graphics.draw(Assets.Sprites.River, x, y) end
    if self.Type == Params.Tile.Type.Riverside   then love.graphics.draw(Assets.Sprites.Riverside, x, y) end

    if self.House then
        self.House:draw()
    end

    if hover then
        love.graphics.setColor(255, 255, 255, 100)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function Tile:BuildHouse(player, pop)
    if not self:Buildable() then return false end
    self.House = House(player, self, pop)
    table.insert(player.Houses, self.House)
    return self.House
end

function Tile:GetBoundingBox()
    return self:RealX(), self:RealY(), self.Width, self.Height
end

return Tile