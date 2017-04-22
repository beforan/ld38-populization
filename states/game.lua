local Map = require "classes.map"

local Game = {}

function Game:init()
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