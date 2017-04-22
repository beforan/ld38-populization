Gamestate = require "lib.hump.gamestate"

local game = require "states.game"

function love.load(arg)
    math.randomseed(os.time())

    Gamestate.registerEvents()
    Gamestate.switch(game)
end
