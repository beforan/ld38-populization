local Class = require "lib.hump.class"
local Suit = require "lib.suit"
local Assets = require "assets.assets"
local Params = require "classes.params"

local tooltip
local infotip
local selectip

local colours = Params.Ui.TextColours

local Ui = Class {}

function Ui:_getTileContent(t)
    local text = {}

    table.insert(text, colours.Title)
    table.insert(text, "Terrain: ")
    table.insert(text, colours.Text)
    table.insert(text, t.Type .. "\n")

    
    if t:CanBuild() then
        table.insert(text, colours.Good)
        table.insert(text, "Can build here\n")
    else
        table.insert(text, colours.Bad)
        table.insert(text, "Can't build here\n")
    end

    local h = t.House
    if h then
        table.insert(text, colours.Title)
        table.insert(text, "House: ")
        table.insert(text, colours.Text)
        table.insert(text, h.Type .. "\n")

        table.insert(text, colours.Title)
        table.insert(text, "Occupants: ")
        if h.Population == Params.Game.Population.HouseLimit then
            table.insert(text, colours.Bad)
        elseif h.Population > Params.Game.Population.HouseCapacity then
            table.insert(text, colours.Warning)
        else table.insert(text, colours.Text) end
        table.insert(text, h.Population .. "/" .. Params.Game.Population.HouseCapacity .. "\n")

        --type specific info?
    end

    if t.Homestead then
        table.insert(text, colours.Text)
        table.insert(text, "I'm a homestead!\n") --add house counts?
    end

    return text
end

function Ui:_initTip(x, y, w, h, padx, pady)
    return {
        title = "",
        x = x + padx,
        y = y + pady,
        w = w - padx * 2,
        h = h,
        contentw = w - padx * 4,
        titlex = x + padx * 2,
        titley = y + pady * 2,
        iconMargin = 20,
        contentx = x + padx * 2,
        contenty = y + pady * 2 + 20 -- offset from the title too
    }
end

function Ui:_infoTip(x, y, w, h)
    local padx, pady = unpack(Params.Ui.SideBar.padding)
    infotip = self:_initTip(x, y, w, h, padx, pady)

    --provide an empty Suit widget just for input handling ;)
    Suit.layout:push(infotip.x, infotip.y)
    if Suit.Label("", { id = "sidebarInfoTip" }, Suit.layout:row(infotip.w, infotip.h)).hovered then
        tooltip = Params.Ui.InfoTips.InfoTip end
    Suit.layout:pop()

    local text = {}

    local gs = Gamestate.current()
    local map = gs.Map

    if not map then return end -- game isn't the current state for some 

    local t = map.HoverTile
    if t then
        text = self:_getTileContent(t)
    else
        if tooltip then
            text = tooltip
        end
    end

    infotip.icon = Assets.Icons.InfoCircle
    infotip.title = "Information"
    infotip.text = text
end

function Ui:_drawTip(tip)
    if not tip then return end

    -- background
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("fill", tip.x, tip.y, tip.w, tip.h)
    love.graphics.setColor(255, 255, 255, 255)

    --title
    if tip.icon then
        love.graphics.setFont(Assets.Fonts.StatusIcons)
        love.graphics.print(tip.icon, tip.titlex, tip.titley)
    end
    love.graphics.setFont(Assets.Fonts.Default)
    love.graphics.print(tip.title, tip.titlex + (tip.icon and tip.iconMargin or 0), tip.titley)

    -- content
    love.graphics.printf(tip.text, tip.contentx, tip.contenty, tip.contentw)
end

function Ui:draw()
    --background for ui zones
    love.graphics.setColor(unpack(Params.Ui.SideBar.Colour))
    love.graphics.rectangle("fill", 0, Params.Ui.StatusBar.Height, Params.Ui.SideBar.Width, love.graphics.getHeight() - Params.Ui.StatusBar.Height)
    love.graphics.setColor(unpack(Params.Ui.StatusBar.Colour))
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Params.Ui.StatusBar.Height)
    love.graphics.setColor(255, 255, 255, 255)

    Suit.draw()

    self:_drawTip(infotip) -- not a widget so Suit won't draw it
    self:_drawTip(selectip)
end

function Ui:update(dt)
    Suit.layout:reset()
    tooltip = nil
    selectip = nil

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
    self:_selectedInfo(layout:cell(2))
    self:_menu(layout:cell(3))
    self:_infoTip(layout:cell(1))
end

function Ui:_selectedInfo(x, y, w, h, padx, pady)
    -- this section is entirely on the condition a tile is selected
    local gs = Gamestate.current()
    local map = gs.Map

    local t = map.SelectedTile
    if t then
        local padx, pady = unpack(Params.Ui.SideBar.padding)
        
        selectip = self:_initTip(x, y, w, Params.Ui.TipHeight, padx, pady)

        selectip.icon = Assets.Icons.Selected
        selectip.title = "Selected Tile"
        selectip.text = self:_getTileContent(t)
        
        Suit.layout:push(selectip.x, selectip.y)

        --provide an empty Suit widget just for input handling ;)
        if Suit.Label("", { id = "sidebarSelecTip" }, Suit.layout:row(selectip.w, selectip.h))
            .hovered then tooltip = Params.Ui.InfoTips.SelecTip end

        -- use this to modify padding, since it's broken
        local function getNextButton() local x, y, w, h = Suit.layout:row(nil, Params.Ui.ButtonHeight); return { x, y + pady, w, h - pady } end

        if t.House then
            -- Specialists
            if t.House:CanBecomeLumberjack() then
                local lumberjack = Suit.Button("Upgrade: Lumberjack", unpack(getNextButton()))
                if lumberjack.hovered then tooltip = Params.Ui.InfoTips.Buttons.Lumberjack end
                if lumberjack.hit then t.House:Convert(Params.House.Type.Lumberjack) end
            end
            
            if t.House:CanBecomeFarmer() then
                local farmer = Suit.Button("Upgrade: Farmer", unpack(getNextButton()))
                if farmer.hovered then tooltip = Params.Ui.InfoTips.Buttons.Farmer end
                if farmer.hit then t.House:Convert(Params.House.Type.Farmer) end
            end
            if t.House:CanBecomeFisher() then
                local fisher = Suit.Button("Upgrade: Fisher", unpack(getNextButton()))
                if fisher.hovered then tooltip = Params.Ui.InfoTips.Buttons.Fisher end
                if fisher.hit then t.House:Convert(Params.House.Type.Fisher) end
            end

            if t.House:CanBecomeBuilder() then
                local builder = Suit.Button("Upgrade: Builder", unpack(getNextButton()))
                if builder.hovered then tooltip = Params.Ui.InfoTips.Buttons.Builder end
                if builder.hit then t.House:Convert(Params.House.Type.Builder) end
            end
        end
        
        -- cancel selection
        local cancel = Suit.Button("Cancel Selection", unpack(getNextButton()))
        if cancel.hovered then tooltip = Params.Ui.InfoTips.Buttons.Cancel end
        if cancel.hit then map:Select() end

        Suit.layout:pop()
    end
end
function Ui:_menu(x, y, w, h)
    local padx, pady = unpack(Params.Ui.SideBar.padding) -- layout padding is broken I think?

    local button = Suit.Button("Menu", x + padx, y + pady, w - padx*2, h - pady*2)

    if button.hovered then tooltip = Params.Ui.InfoTips.Buttons.Menu end
    if button.hit then Gamestate.push(Gamestate.States.Pause) end -- this is somehow broken
end

function Ui:_population(x, y, w, h)
    Suit.layout:push(x, y)
    
    local id = "statusPop" --abuse same id to only writ the handler once in spite of multiple widgets

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
    .hovered then tooltip = Params.Ui.InfoTips.StatusBar.Population end
    
    Suit.layout:pop()
end

function Ui:_food(x, y, w, h)
    Suit.layout:push(x, y)
    
    local id = "statusFood" --abuse same id to only writ the handler once in spite of multiple widgets

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
    .hovered then tooltip = Params.Ui.InfoTips.StatusBar.Food end
    
    Suit.layout:pop()
end

function Ui:_lumber(x, y, w, h)
    Suit.layout:push(x, y)
    
    local id = "statusLumber" --abuse same id to only writ the handler once in spite of multiple widgets

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
    .hovered then tooltip = Params.Ui.InfoTips.StatusBar.Lumber end
    
    Suit.layout:pop()
end

return Ui