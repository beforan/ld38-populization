local Suit = require "lib.suit"

local Params = require "classes.params"
local Assets = require "assets.assets"

local Help = {}

function Help:enter(from)
    self.old = from
end

function Help:keyreleased(key)
	if(key == "escape") then
		Gamestate.pop()
	end
end

function Help:draw()
    self.old:draw()
    
    --draw the overlay
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill",0,0,w,h)
	
    -- then the "window" with drop shadow
    local pad = 80
	love.graphics.setColor(0, 0, 0,200)
	love.graphics.rectangle("fill", pad+pad/4, pad+pad/4, w - pad*2, h - pad*2)
    love.graphics.setColor(60, 80, 100,255)
	love.graphics.rectangle("fill", pad, pad, w - pad*2, h - pad*2)

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setFont(Assets.Fonts.OverlayBanner)
    love.graphics.printf({ Params.Ui.TextColours.Warning, "Help" }, 0, 100, love.graphics.getWidth(), "center")
    love.graphics.setFont(Assets.Fonts.Default)

    -- draw the window content!

    Suit.draw()
end

function Help:update(dt)
    Suit.layout:reset(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() - 150)
    
    if Suit.Button("Back", Suit.layout:row(200, 30)).hit then
        return Gamestate.pop()
    end
end

return Help