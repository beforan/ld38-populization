local Class = require "lib.hump.class"
local Assets = require "assets.assets"
local Params = require "classes.params"

local Player = Class {
    init = function(self, player, human)
        self.Human = human or false
        self.Colour = player
        self.Sprites = Assets.Sprites[player .. "Player"]
        self.Houses = {}
        self.VitalStatistix = {
            Food = Params.Game.Start.Food,
            Lumber = Params.Game.Start.Lumber,
            Population = Params.Game.Start.Pop
        }
        self.Progress = {
            Growth = 0,
            Death = 0,
            Build = 0
        }
    end
}

return Player