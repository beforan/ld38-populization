local Const = require "classes.const"

local Tile = require "lib.hump.class" {
    init = function(self, x, y, type)
        self.Name = "tile" -- think hump.class can use this?
        self.X = x -- tilemap coords
        self.Y = y
        self.Type = type or "grass"
    end,
    Width = Const.TileSize,
    Height = Const.TileSize,
    RealX = function(self) return (self.X - 1) * self.Width end, -- pixel coords top
    RealY = function(self) return (self.Y - 1) * self.Height end -- and left
}

function Tile:draw()
    love.graphics.printf(self.Type, self:RealX(), self:RealY(), self.Width, "center")
    love.graphics.rectangle("line", self:GetBoundingBox())
end

function Tile:GetBoundingBox()
    return self:RealX(), self:RealY(), self.Width, self.Height
end

return Tile