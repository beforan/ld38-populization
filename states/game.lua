local Camera = require "lib.hump.camera"

local Map = require "classes.map"
local Params = require "classes.params"
local Player = require "classes.player"
local Assets = require "assets.assets"
local utf8 = require "utf8"

local Game = {}

function Game:init()
    love.keyboard.setKeyRepeat(true)
    
    -- init player data
    self.Players = {}
    for i, v in ipairs(Params.Game.Players) do
        self.Players[i] = Player(v) -- index it
        self.Players[v] = self.Players[i] -- and key it
    end

    

    -- ui?

    -- camera
    self.Camera = Camera(1, 1)
end

function Game:enter()
    -- init map
    self.Map = Map()
    self:_mapInit()
end

function Game:_mapInit()
    self.Map:Generate()
    self.Map:Spawn()
end

function Game._CameraViewPort()
    love.graphics.rectangle("fill",
        Params.Ui.SideBar,
        Params.Ui.StatusBar,
        love.graphics.getWidth() - Params.Ui.SideBar,
        love.graphics.getHeight() - Params.Ui.StatusBar)
end

function Game:drawStatus()
    -- Population
    love.graphics.setFont(Assets.Fonts.StatusIcons)
    love.graphics.print(utf8.char(0xf0c0), 10, 10)
end

function Game:draw()
    -- ui
    love.graphics.setColor(64, 64, 64, 255)
    love.graphics.rectangle("fill", 0, Params.Ui.StatusBar, Params.Ui.SideBar, love.graphics.getHeight() - Params.Ui.StatusBar)
    love.graphics.setColor(32, 32, 32, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Params.Ui.StatusBar)
    love.graphics.setColor(255, 255, 255, 255)
    self:drawStatus()

    -- camera viewport
    love.graphics.stencil(self._CameraViewPort, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.translate(Params.Ui.SideBar, Params.Ui.StatusBar)
    self.Camera:attach()
    self.Map:draw()
    self.Camera:detach()

    -- reset
    love.graphics.origin()
    love.graphics.setStencilTest()
end

function Game:keypressed(key)
    if key == "m" then
        print("Reticulating splines")
        self:_mapInit()
    end

    if key == "up" then
        self.Camera:move(0, -Params.Camera.ScrollSpeed)
    end
    if key == "down" then
        self.Camera:move(0, Params.Camera.ScrollSpeed)
    end
    if key == "left" then
        self.Camera:move(-Params.Camera.ScrollSpeed, 0)
    end
    if key == "right" then
        self.Camera:move(Params.Camera.ScrollSpeed, 0)
    end
end

function Game:wheelmoved(x, y)
    if y > 0 then
        if self.Camera.scale < Params.Camera.MaxZoom then
            self.Camera:zoom(Params.Camera.ZoomIncrement)
        end
    elseif y < 0 then
        if self.Camera.scale > Params.Camera.MinZoom then
            self.Camera:zoom(Params.Camera.ZoomExcrement)
        end
    end
end

return Game