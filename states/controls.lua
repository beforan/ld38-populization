local Suit = require "lib.suit"

local Params = require "classes.params"
local Assets = require "assets.assets"

local Controls = {}

function Controls:enter(from)
    self.old = from
end

function Controls:keyreleased(key)
	if(key == "escape") then
		Gamestate.pop()
	end
end

function Controls:draw()
    self.old:draw()
    
    --draw the overlay
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill",0,0,w,h)
	
    -- then the "window"
    local pad = 30
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill", pad, pad, w - pad*2, h - pad*2)

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setFont(Assets.Fonts.OverlayBanner)
    love.graphics.printf({ Params.Ui.TextColours.Warning, "Controls" }, 0, 100, love.graphics.getWidth(), "center")
    love.graphics.setFont(Assets.Fonts.Default)

    -- draw the window content!

    Suit.draw()
end

function Controls:update(dt)
    Suit.layout:reset(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() - 50)
    
    if Suit.Button("Back", Suit.layout:row(200, 30)).hit then
        return Gamestate.pop()
    end
end

return Controls