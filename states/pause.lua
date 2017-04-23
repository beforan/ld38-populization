local Pause = {}

function Pause:enter(game)
	self.Game = game
end

function Pause:draw()
    self.Game:draw()
    
    --draw the pause overlay on top :)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill",0,0,w,h)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("PAUSED!", 500, 500)
end

function Pause:keyreleased(key)
	if(key == "escape") then
		Gamestate.pop()
	end
end

return Pause