local Camera = require "lib.hump.camera"

local Map = require "classes.map"
local Params = require "classes.params"
local Player = require "classes.player"
local Assets = require "assets.assets"
local utf8 = require "utf8"

local Game = {}

local cameraViewPort = { -- bounding box of the viewport
    x = Params.Ui.SideBar,
    y = Params.Ui.StatusBar,
    w = love.graphics.getWidth() - Params.Ui.SideBar,
    h = love.graphics.getHeight() - Params.Ui.StatusBar
}

function Game:init()
    love.keyboard.setKeyRepeat(true)
    self.Map = Map()
    self.Camera = Camera()
end

function Game:enter()
    self:_newGame()
end

function Game:_newGame()
    -- player data
    self.Players = {}
    for i, v in ipairs(Params.Game.Players) do
        self.Players[i] = Player(v) -- index it
        self.Players[v] = self.Players[i] -- and key it
    end
    
    -- init map
    self.Map:Generate()
    self.Map:Spawn()

    -- init camera
    local humanSpawn = self.Players[1].Houses[1].Site
    self.Camera:lookAt(humanSpawn:RealX(), humanSpawn:RealY())
end

function Game._CameraViewPort()
    love.graphics.rectangle("fill",
        cameraViewPort.x, cameraViewPort.y,
        cameraViewPort.w, cameraViewPort.h)
end

function Game:drawStatus()
    -- Population
    love.graphics.setFont(Assets.Fonts.StatusIcons)
    love.graphics.print(Assets.Icons.Population, 10, 10)
    love.graphics.setFont(Assets.Fonts.Default)
    love.graphics.print(self.Players[1].VitalStatistix.Population, 30, 10)
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
    love.graphics.translate(Params.Ui.SideBar / 2, Params.Ui.StatusBar / 2)
    self.Camera:attach()
    self.Map:draw()
    self.Camera:detach()

    -- reset
    love.graphics.origin()
    love.graphics.setStencilTest()
end

function Game:update(dt)
    --let's try camera clamping!
    self.Camera.x = math.clamp(self.Camera.x, cameraViewPort.w / 2 * 1/self.Camera.scale, self.Map.Width * Params.Tile.Size - cameraViewPort.w / 2 * 1/self.Camera.scale)
    self.Camera.y = math.clamp(self.Camera.y, cameraViewPort.h / 2 * 1/self.Camera.scale, self.Map.Height * Params.Tile.Size - cameraViewPort.h / 2 * 1/self.Camera.scale)
end

function Game:keypressed(key)
    if key == "m" then
        print("Reticulating splines")
        self:_newGame()
        return
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

-- function Game:mousemoved(x, y)
--     self.Camera:lockPosition(x, y)
-- end

return Game