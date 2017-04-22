local Map = require "classes.map"
local Const = require "classes.const"

local Game = {}

PlayerHouses = {} -- ugh, fix this

function Game:init()
    -- init player data
    for i=1, Const.Game.Players do
        PlayerHouses[i] = {}
    end

    self.Map = Map()
    self:_mapInit()
end

function Game:_mapInit()
    self.Map:Generate()
    self.Map:Spawn()
end

function Game:draw()
    self.Map:draw()
end

function Game:keypressed(key)
    if key == "m" then
        print("Reticulating splines")
        self:_mapInit()
    end
end

return Game