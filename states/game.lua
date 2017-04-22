local Camera = require "lib.hump.camera"

local Map = require "classes.map"
local Const = require "classes.const"

local Game = {}

PlayerHouses = {} -- ugh, fix this

function Game:init()
    love.keyboard.setKeyRepeat(true)
    
    -- init player data
    for i=1, Const.Game.Players do
        PlayerHouses[i] = {}
    end

    -- init map
    self.Map = Map()
    self:_mapInit()

    -- ui?

    -- camera
    self.Camera = Camera(1, 1)
end

function Game:_mapInit()
    self.Map:Generate()
    self.Map:Spawn()
end

function Game._CameraViewPort()
    love.graphics.rectangle("fill",
        Const.Ui.SideBar,
        Const.Ui.StatusBar,
        love.graphics.getWidth() - Const.Ui.SideBar,
        love.graphics.getHeight() - Const.Ui.StatusBar)
end

function Game:draw()
    -- ui
    love.graphics.setColor(64, 64, 64, 255)
    love.graphics.rectangle("fill", 0, Const.Ui.StatusBar, Const.Ui.SideBar, love.graphics.getHeight() - Const.Ui.StatusBar)
    love.graphics.setColor(32, 32, 32, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Const.Ui.StatusBar)
    love.graphics.setColor(255, 255, 255, 255)

    -- camera viewport
    love.graphics.stencil(self._CameraViewPort, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.translate(Const.Ui.SideBar, Const.Ui.StatusBar)
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
        self.Camera:move(0, -Const.Ui.CameraScroll)
    end
    if key == "down" then
        self.Camera:move(0, Const.Ui.CameraScroll)
    end
    if key == "left" then
        self.Camera:move(-Const.Ui.CameraScroll, 0)
    end
    if key == "right" then
        self.Camera:move(Const.Ui.CameraScroll, 0)
    end
end

return Game