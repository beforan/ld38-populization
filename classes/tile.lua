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
    RealX = function(self) return self.X * self.Width end, -- pixel coords top
    RealY = function(self) return self.Y * self.Height end -- and left
}

function Tile:draw()
    love.graphics.printf(self.Type, self:RealX(), self:RealY() + self.Height / 2, self.Width, "center")
end

function Tile:getBoundingBox()
    return self:RealX(), self:RealY(), self.Width, self.Height
end

return Tile