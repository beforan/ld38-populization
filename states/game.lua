local Game = {}
local Map = require "classes.map"

function Game:init()
    self.Map = Map()
    Map:Generate()
end

function Game:draw()
    Map:draw()
end

return Game