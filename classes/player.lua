local Class = require "lib.hump.class"
local Assets = require "assets.assets"

local Player = Class {
    init = function(self, player)
        self.Colour = player
        self.Sprites = Assets.Sprites[player .. "Player"]
    end,
    Houses = {}
}

return Player