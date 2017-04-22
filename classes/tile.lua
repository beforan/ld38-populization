local Class = require "lib.hump.class"
local Const = require "classes.const"
local House = require "classes.house"

local Tile = Class {
    init = function(self, x, y, type)
        self.X = x -- tilemap coords
        self.Y = y
        self.Type = type or Const.Tile.Type.Grass
    end,
    Width = Const.Tile.Size,
    Height = Const.Tile.Size,
    RealX = function(self) return (self.X - 1) * self.Width end, -- pixel coords top
    RealY = function(self) return (self.Y - 1) * self.Height end, -- and left
    House = nil,
    Buildable = function(self) return self.Type ~= Const.Tile.Type.Woodland and self.Type ~= Const.Tile.Type.River end
}

function Tile:draw()
    
    if self.House then -- set colour based on house sprite
        love.graphics.setColor(0, 0, 0, 255)
    else -- set colour (sprite later?) based on type
        if self.Type == Const.Tile.Type.Grass then love.graphics.setColor(76, 153, 0, 255) end
        if self.Type == Const.Tile.Type.Woodland then love.graphics.setColor(0, 102, 51, 255) end
        if self.Type == Const.Tile.Type.Deforested then love.graphics.setColor(139, 69, 19, 255) end
        if self.Type == Const.Tile.Type.Grain then love.graphics.setColor(245, 222, 179, 255) end
        if self.Type == Const.Tile.Type.River then love.graphics.setColor(0, 76, 153, 255) end
        if self.Type == Const.Tile.Type.Riverside then love.graphics.setColor(51, 102, 0, 255) end
    end
    
    love.graphics.rectangle("fill", self:GetBoundingBox())

    love.graphics.setColor(255, 255, 255, 255) -- reset
end

function Tile:BuildHouse(player, type)
    if not self:Buildable() then return false end
    self.House = House(player, type)
    table.insert(PlayerHouses[player], self.House)
    return self.House
end

function Tile:GetBoundingBox()
    return self:RealX(), self:RealY(), self.Width, self.Height
end

return Tile