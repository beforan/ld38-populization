local Class = require "lib.hump.class"
local Suit = require "lib.suit"
local Assets = require "assets.assets"
local Params = require "classes.params"

local status

local Ui = Class {}

function Ui:_drawStatus()
    -- Population
    love.graphics.setFont(Assets.Fonts.StatusIcons)
    love.graphics.print(Assets.Icons.Population, 10, 10)
    love.graphics.setFont(Assets.Fonts.Default)
    love.graphics.print(Gamestate.current().Players[1].VitalStatistix.Population, 30, 10)
end

function Ui:_drawInfoTip()
    -- background
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("fill", 10, Params.Ui.StatusBar.Height + 10, Params.Ui.SideBar.Width - 20, 200)
    love.graphics.setColor(255, 255, 255, 255)

    --title
    love.graphics.setFont(Assets.Fonts.StatusIcons)
    love.graphics.print(Assets.Icons.InfoCircle, 20, Params.Ui.StatusBar.Height + 20)
    love.graphics.setFont(Assets.Fonts.Default)
    love.graphics.print("Information", 40, Params.Ui.StatusBar.Height + 20)

    --infotip
    local gs = Gamestate.current()
    local map = gs.Map
    local cTitle = { 180, 180, 255, 255 }
    local cGood = { 180, 255, 180, 255 }
    local cWarning = { 255, 240, 150, 255 }
    local cBad = { 255, 180, 180, 255 }
    local cText = { 255, 255, 255, 255 }
    local text = {}

    local t = map.HoverTile
    if t then
        table.insert(text, cTitle)
        table.insert(text, "Terrain: ")
        table.insert(text, cText)
        table.insert(text, t.Type .. "\n")

        
        if t:CanBuild() then
            table.insert(text, cGood)
            table.insert(text, "Can build here\n")
        else
            table.insert(text, cBad)
            table.insert(text, "Can't build here\n")
        end

        local h = t.House
        if h then
            table.insert(text, cTitle)
            table.insert(text, "House: ")
            table.insert(text, cText)
            table.insert(text, h.Type .. "\n")

            table.insert(text, cTitle)
            table.insert(text, "Occupants: ")
            if h.Population == Params.Game.Population.HouseLimit then
                table.insert(text, cBad)
            elseif h.Population > Params.Game.Population.HouseCapacity then
                table.insert(text, cWarning)
            else table.insert(text, cText) end
            table.insert(text, h.Population .. "/" .. Params.Game.Population.HouseCapacity .. "\n")

            --type specific info?
        end

        if t.Homestead then
            table.insert(text, cText)
            table.insert(text, "I'm a homestead!\n") --add house counts?
        end
    end

    love.graphics.printf(text, 20, Params.Ui.StatusBar.Height + 40, Params.Ui.SideBar.Width - 40)
end

function Ui:draw()
    --background for ui zones
    love.graphics.setColor(64, 64, 64, 255)
    love.graphics.rectangle("fill", 0, Params.Ui.StatusBar.Height, Params.Ui.SideBar.Width, love.graphics.getHeight() - Params.Ui.StatusBar.Height)
    love.graphics.setColor(32, 32, 32, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Params.Ui.StatusBar.Height)
    love.graphics.setColor(255, 255, 255, 255)
    
    self:_drawStatus()
    self:_drawInfoTip()
end

function Ui:update(dt)

end

return Ui