local Class = require "lib.hump.class"
local Suit = require "lib.suit"
local Assets = require "assets.assets"
local Params = require "classes.params"

local tooltip
local infotip

local Ui = Class {}

function Ui:_infoTip(x, y, w, h, padx, pady)
    infotip = {
        x = x + padx,
        y = y + pady,
        w = w - padx * 2,
        h = h - padx * 2,
        contentw = w - padx * 4,
        titlex = x + padx * 2,
        titley = y + pady * 2,
        iconMargin = 20,
        contentx = x + padx * 2,
        contenty = y + pady * 2 + 20 -- offset from the title too
    }

    local tooltipText = "This area provides useful information on elements of the game world and the user interface!"

    --provide an empty Suit widget just for input handling ;)
    Suit.layout:push(infotip.x, infotip.y)
    if Suit.Label("", Suit.layout:row(infotip.w, infotip.h)).hovered then
        tooltip = tooltipText end
    Suit.layout:pop()
    
    -- get the content
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
    else
        if tooltip then
            text = tooltip
        end
    end

    infotip.text = text
end

function Ui:_drawInfoTip()
    -- background
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("fill", infotip.x, infotip.y, infotip.w, infotip.h)
    love.graphics.setColor(255, 255, 255, 255)

    --title
    love.graphics.setFont(Assets.Fonts.StatusIcons)
    love.graphics.print(Assets.Icons.InfoCircle, infotip.titlex, infotip.titley)
    love.graphics.setFont(Assets.Fonts.Default)
    love.graphics.print("Information", infotip.titlex + infotip.iconMargin, infotip.titley)

    -- content
    love.graphics.printf(infotip.text, infotip.contentx, infotip.contenty, infotip.contentw)
end

function Ui:draw()
    --background for ui zones
    love.graphics.setColor(unpack(Params.Ui.SideBar.Colour))
    love.graphics.rectangle("fill", 0, Params.Ui.StatusBar.Height, Params.Ui.SideBar.Width, love.graphics.getHeight() - Params.Ui.StatusBar.Height)
    love.graphics.setColor(unpack(Params.Ui.StatusBar.Colour))
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Params.Ui.StatusBar.Height)
    love.graphics.setColor(255, 255, 255, 255)

    Suit.draw()
    self:_drawInfoTip() -- not a widget so Suit won't draw it
end

function Ui:update(dt)
    Suit.layout:reset()
    tooltip = nil

    local statusBar = Suit.layout:cols(Params.Ui.StatusBar)
    self:_statusBar(statusBar)

    local sideBar = Suit.layout:rows(Params.Ui.SideBar)
    self:_sideBar(sideBar)
end

function Ui:_statusBar(layout)
    self:_population(layout:cell(1))
    self:_food(layout:cell(2))
    self:_lumber(layout:cell(3))
end

function Ui:_sideBar(layout)
    local infoCell = layout[1]
    self:_infoTip(
        infoCell[1], infoCell[2],
        infoCell[3], infoCell[4],
        unpack(Params.Ui.SideBar.padding))
    self:_selectedInfo(layout:cell(2))
    self:_menu(layout:cell(3))
end

function Ui:_selectedInfo(x, y, w, h)
    -- Suit.layout:push(x, y)
    
    -- Suit.layout:pop()
end
function Ui:_menu(x, y, w, h)
    Suit.layout:push(x, y)
    Suit.layout:padding(unpack(Params.Ui.SideBar.padding))
    
    local tooltipText = "Open the pause menu"

    local button = Suit.Button("Menu", Suit.layout:row(w, h))

    if button.hovered then tooltip = tooltipText end

    if button.hit then Gamestate.push(Gamestate.States.Pause, self) end
    
    Suit.layout:pop()
end

function Ui:_population(x, y, w, h)
    Suit.layout:push(x, y)
    
    local id = "statusPop" --abuse same id to only writ the handler once in spite of multiple widgets
    local tooltipText = "Population"

    Suit.Label(Assets.Icons.Population,
        {
            id = id,
            align = "center",
            font = Assets.Fonts.StatusIcons
        },
        Suit.layout:col(Params.Ui.IconWidth, h))
    
    if Suit.Label(Gamestate.current().Players[1].VitalStatistix.Population,
        {
            id = id,
            align = "left"
        },
        Suit.layout:col(w - Params.Ui.IconWidth, h))
    .hovered then tooltip = tooltipText end
    
    Suit.layout:pop()
end

function Ui:_food(x, y, w, h)
    Suit.layout:push(x, y)
    
    local id = "statusFood" --abuse same id to only writ the handler once in spite of multiple widgets
    local tooltipText = "Food"

    Suit.Label(Assets.Icons.Food,
        {
            id = id,
            align = "center",
            font = Assets.Fonts.StatusIcons
        },
        Suit.layout:col(Params.Ui.IconWidth, h))
    
    if Suit.Label(Gamestate.current().Players[1].VitalStatistix.Food,
        {
            id = id,
            align = "left"
        },
        Suit.layout:col(w - Params.Ui.IconWidth, h))
    .hovered then tooltip = tooltipText end
    
    Suit.layout:pop()
end

function Ui:_lumber(x, y, w, h)
    Suit.layout:push(x, y)
    
    local id = "statusLumber" --abuse same id to only writ the handler once in spite of multiple widgets
    local tooltipText = "Lumberrrrrr"

    Suit.Label(Assets.Icons.Lumber,
        {
            id = id,
            align = "center",
            font = Assets.Fonts.StatusIcons
        },
        Suit.layout:col(Params.Ui.IconWidth, h))
    
    if Suit.Label(Gamestate.current().Players[1].VitalStatistix.Lumber,
        {
            id = id,
            align = "left"
        },
        Suit.layout:col(w - Params.Ui.IconWidth, h))
    .hovered then tooltip = tooltipText end
    
    Suit.layout:pop()
end

return Ui