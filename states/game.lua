local Map = require "classes.map"

local Game = {}

function Game:init()
    self.Map = Map()
    self.Map:Generate()
end

function Game:draw()
    self.Map:draw()
end

function Game:keypressed(key)
    if key == "m" then
        print("Reticulating splines")
        self.Map:Generate()
    end
end

return Game