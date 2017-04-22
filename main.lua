Gamestate = require "lib.hump.gamestate"

-- oh ho! piggyback the global GS object to avoid making a new one
Gamestate.States = {
    Game = require "states.game"
}

function love.load(arg)
    math.randomseed(os.time())

    Gamestate.registerEvents()
    Gamestate.switch(Gamestate.States.Game)
end

-- misc helper functions

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end