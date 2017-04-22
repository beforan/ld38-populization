local Class = require "lib.hump.class"
local Assets = require "assets.assets"
local Params = require "classes.params"

local Player = Class {
    init = function(self, player)
        self.Colour = player
        self.Sprites = Assets.Sprites[player .. "Player"]
        self.Houses = {}
        self.VitalStatistix = {
            Food = Params.Game.Start.Food,
            Lumber = Params.Game.Start.Lumber,
            Population = Params.Game.Start.Pop
        }
    end
}

return Player