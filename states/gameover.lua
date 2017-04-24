local Suit = require "lib.suit"

local Params = require "classes.params"
local Assets = require "assets.assets"

local GameOver = {}

function GameOver:enter(from)
    self.background = love.graphics.newImage(love.graphics.newScreenshot())
    self.GameOver = from.GameOver or {}
    self.Players = from.Players
end

function GameOver:leave()
    self.background = nil
end

function GameOver:draw()
    --draw the "game" background
    love.graphics.draw(self.background)

    --draw the pause overlay on top :)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill",0,0,w,h)

    love.graphics.setColor(255, 255, 255, 255)
    
    -- calculate winner from gameover result
    local result = false
    local humanWin = false

    local function bannerText(text)
        love.graphics.setFont(Assets.Fonts.OverlayBanner)
        love.graphics.printf(text, 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setFont(Assets.Fonts.Default)
    end

    

    if self.GameOver.Win then
        if self.GameOver.Player == self.Players[1] then humanWin = true end
    elseif self.GameOver.Lose then
        if not self.GameOver.Player.Human then humanWin = true end
    elseif self.GameOver.Score then
        self.GameOver.Reason = self.GameOver.Player.Colour " had the higher score!"
        --TODO score totting and determining human victory
    else
        bannerText({ Params.Ui.TextColours.Warning, "Result inconclusive..." })
        result = true
    end

    -- print a message to the human about whether they won
    if not result then
        if humanWin then
            bannerText({ Params.Ui.TextColours.Good, "YOU WIN!" })
        else
            bannerText({ Params.Ui.TextColours.Bad, "YOU LOSE!" })
        end
    end
    
    love.graphics.setFont(Assets.Fonts.OverlaySubtext)
    love.graphics.printf(self.GameOver.Reason or "Who knows why?", 0, 350, love.graphics.getWidth(), "center")
    love.graphics.setFont(Assets.Fonts.Default)

    Suit.draw()
end

function GameOver:update(dt)
    Suit.layout:reset(love.graphics.getWidth() / 2 - 100, 450, 10, 10)
    
    
    if Suit.Button("Play Again", Suit.layout:row(200, 30)).hit then
        return Gamestate:pop("new")
    end

    if Suit.Button("Quit to Menu", Suit.layout:row()).hit then
        return Gamestate:pop("switch", Gamestate.States.Menu)
    end

    if Suit.Button("Quit to Desktop", Suit.layout:row()).hit then
        love.event.quit()
    end
end

return GameOver