Gamestate = require "lib.hump.gamestate"

local game = require "states.game"

function love.load(arg)
    Gamestate.registerEvents()
    Gamestate.switch(game)
end
