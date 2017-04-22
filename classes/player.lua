local Class = require "lib.hump.class"
local Assets = require "assets.assets"
local Params = require "classes.params"

local Player = Class {
    init = function(self, player)
        self.Colour = player
        self.Sprites = Assets.Sprites[player .. "Player"]
    end,
    Houses = {},
    Vitalstatistix = {
        Food = Params.Game.StartingFood
    }
}

return Player