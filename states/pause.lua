local Pause = {}

function Pause:enter(from)
    self.background = love.graphics.newImage(love.graphics.newScreenshot())
end

function Pause:leave()
    self.background = nil
end

function Pause:draw()
    --draw the "game" background
    love.graphics.draw(self.background)

    --draw the pause overlay on top :)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill",0,0,w,h)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("PAUSED!", 500, 500)
end

function Pause:update(dt)
end

function Pause:keyreleased(key)
	if(key == "escape") then
		Gamestate.pop()
	end
end

return Pause