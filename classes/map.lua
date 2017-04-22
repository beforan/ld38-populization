local Const = require "classes.const"
local Tile = require "classes.tile"

local Map = require "lib.hump.class" {
    init = function(self)

    end,
    Width = Const.Map.Width,
    Height = Const.Map.Height,
    Tiles = {}
}

function Map:Generate()
    for i=1, Const.Map.Height do
        self.Tiles[i] = {} -- initialise the row
        for j=1, Const.Map.Width do
            self.Tiles[i][j] = Tile(j, i)
        end
    end
end

function Map:draw()
    for y=1, #self.Tiles do
        for x=1, #self.Tiles[y] do
            self.Tiles[y][x]:draw()
        end
    end
end

return Map