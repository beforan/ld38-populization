local GameOver = {}

function GameOver:enter(from)
    self.background = love.graphics.newImage(love.graphics.newScreenshot())
    self.GameOver = from.GameOver
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

    if self.GameOver.Win then
        if self.GameOver.Player.Human then humanWin = true end
    elseif self.GameOver.Lose then
        if not self.GameOver.Player.Human then humanWin = true end
    elseif self.GameOver.Score then
        love.graphics.print("We've totted up your scores", 500, 400)
        --TODO score totting and determining human victory
    else
        love.graphics.print("Result Inconclusive!", 500, 400)
        result = true
    end

    -- print a message to the human about whether they won
    if not result then
        if humanWin then
            love.graphics.print("YOU WIN!", 500, 400)
        else
            love.graphics.print("YOU LOSE!", 500, 400)
        end
    end
    
    love.graphics.print(self.GameOver.Reason or "Who knows why?", 500, 500)
end

function GameOver:keyreleased(key)
	if(key == "escape") then
		Gamestate.switch(Gamestate.States.Game) -- start a new game
	end
end

return GameOver