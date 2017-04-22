local Const = require "classes.const"

Tile = require "lib.hump.class" {
    init = function(self, x, y)
        self.name = "tile" -- think hump.class can use this?
        self.x = x -- tilemap coords
        self.y = y
    end,
    width = Const.tileSize,
    height = Const.tileSize,
    RealX = function(self) return self.x * self.width end, -- pixel coords top
    RealY = function(self) return self.y * self.height end -- and left
}

function Tile:getBoundingBox()
    return self:RealX(), self:RealY, self.width, self.height
end

