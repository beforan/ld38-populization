local Suit = require "lib.suit"

local Params = require "classes.params"
local Assets = require "assets.assets"

local Pause = {}

function Pause:enter(from)
    self.background = love.graphics.newImage(love.graphics.newScreenshot())
end

function Pause:leave()
    self.background = nil
end

function Pause:keyreleased(key)
	if(key == "escape") then
		Gamestate.pop()
	end
end

function Pause:draw()
    --draw the "game" background
    love.graphics.draw(self.background)

    --draw the overlay on top :)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill",0,0,w,h)

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setFont(Assets.Fonts.OverlayBanner)
    love.graphics.printf({ Params.Ui.TextColours.Warning, "Paused" }, 0, 200, love.graphics.getWidth(), "center")
    love.graphics.setFont(Assets.Fonts.Default)

    Suit.draw()
end

function Pause:update(dt)
    Suit.layout:reset(love.graphics.getWidth() / 2 - 100, 350, 10, 10)
    
    if Suit.Button("Resume Game", Suit.layout:row(200, 30)).hit then
        return Gamestate:pop()
    end

    if Suit.Button("Help", Suit.layout:row(200, 30)).hit then
        return Gamestate.push(Gamestate.States.Help)
    end

    if Suit.Button("Controls", Suit.layout:row(200, 30)).hit then
        return Gamestate.push(Gamestate.States.Controls)
    end
    
    if Suit.Button("New Game", Suit.layout:row()).hit then
        return Gamestate:pop("new")
    end

    if Suit.Button("Quit to Menu", Suit.layout:row()).hit then
        return Gamestate:pop("switch", Gamestate.States.Menu)
    end

    if Suit.Button("Quit to Desktop", Suit.layout:row()).hit then
        love.event.quit()
    end
end

return Pause