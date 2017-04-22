local Class = require "lib.hump.class"
local Const = require "classes.const"

local House = Class {
    init = function(self, owner, type)
        self.Owner = owner
        self.Type = type or Const.House.Type.Standard
    end
}

return House