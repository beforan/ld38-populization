local Camera = require "lib.hump.camera"
local Vector = require "lib.hump.vector"

local Map = require "classes.map"
local Params = require "classes.params"
local Player = require "classes.player"
local Assets = require "assets.assets"
local Ui = require "classes.ui"
local utf8 = require "utf8"

local Game = {}

local cameraViewPort = { -- bounding box of the viewport
    x = Params.Ui.SideBar.Width,
    y = Params.Ui.StatusBar.Height,
    w = love.graphics.getWidth() - Params.Ui.SideBar.Width,
    h = love.graphics.getHeight() - Params.Ui.StatusBar.Height
}

local debugStats = Params.Ui.DebugStats

function Game:init()
    self.Ui = Ui()
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

function Game:draw()
    self.Camera:attach(cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, cameraViewPort.h)
    self.Map:draw()
    self.Camera:detach()

    if debugStats then
        local mx, my = love.mouse.getPosition()
        local cmx, cmy = self.Camera:mousePosition()
        local cx, cy = self.Camera:position()

        love.graphics.printf(
            "Mouse: " .. mx .. ", " .. my,
            cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, "right")
    end

    self.Ui:draw()
end

function Game:update(dt)
    self:_keyScroll(dt)
    self:_mouseScroll(dt)
    self:_clampCamera()

    self.Ui:update(dt)
end

function Game:_toggleDebugStats()
    if love.keyboard.allDown("lctrl", "d") then debugStats = not debugStats end
end

function Game:_clampCamera()
    local s = 1/self.Camera.scale
    local viewWidth, viewHeight = cameraViewPort.w / 2, cameraViewPort.h / 2
    local mapWidth, mapHeight = self.Map.Width * Params.Tile.Size, self.Map.Height * Params.Tile.Size
    -- i thought staging this into local variables would make it clearer, but it kinda doesn't make a difference...
    self.Camera.x = math.clamp(self.Camera.x, viewWidth * s, mapWidth - viewWidth * s)
    self.Camera.y = math.clamp(self.Camera.y, viewHeight * s, mapHeight - viewHeight * s)
end

function Game:_keyScroll(dt)
    if love.keyboard.isDown("up") then
        self.Camera:move(0, -Params.Camera.ScrollSpeed * dt)
    end
    if love.keyboard.isDown("down") then
        self.Camera:move(0, Params.Camera.ScrollSpeed * dt)
    end
    if love.keyboard.isDown("left") then
        self.Camera:move(-Params.Camera.ScrollSpeed * dt, 0)
    end
    if love.keyboard.isDown("right") then
        self.Camera:move(Params.Camera.ScrollSpeed * dt, 0)
    end
end

function Game:_mouseScroll(dt)
    local x, y = love.mouse.getPosition()
    
    if y >= cameraViewPort.y + cameraViewPort.h * (100 - Params.Camera.EdgeScrollZone) / 100
        and y < love.graphics.getHeight() and x < love.graphics.getWidth() then
        self.Camera:move(0, Params.Camera.ScrollSpeed * dt)
    end
    if y <= cameraViewPort.y + cameraViewPort.h * Params.Camera.EdgeScrollZone / 100
        and y > cameraViewPort.y and x > cameraViewPort.x then
        self.Camera:move(0, -Params.Camera.ScrollSpeed * dt)
    end
    if x >= cameraViewPort.x + cameraViewPort.w * (100 - Params.Camera.EdgeScrollZone) / 100
        and y < love.graphics.getHeight() and x < love.graphics.getWidth() then
        self.Camera:move(Params.Camera.ScrollSpeed * dt, 0)
    end
    if x <= cameraViewPort.x + cameraViewPort.w * Params.Camera.EdgeScrollZone / 100
        and y > cameraViewPort.y and x > cameraViewPort.x then
        self.Camera:move(-Params.Camera.ScrollSpeed * dt, 0)
    end
end

function Game:keypressed(key)
    if key == "m" then
        print("Reticulating splines")
        self:_newGame()
        return
    end

    self:_toggleDebugStats()
end

function Game:wheelmoved(x, y)
    local zoomVector = (Vector(self:vMousePosition()) - Vector(self.Camera:position())) *
                Params.Camera.ZoomPositionAdjust
    if y > 0 then
        if self.Camera.scale < Params.Camera.MaxZoom then
            self.Camera:zoom(Params.Camera.ZoomIncrement)
            self.Camera:move(zoomVector.x, zoomVector.y)
        end
    elseif y < 0 then
        if self.Camera.scale > Params.Camera.MinZoom then
            self.Camera:zoom(Params.Camera.ZoomExcrement)
            self.Camera:move(zoomVector.x, zoomVector.y)
        end
    end
    self.Map:Hover(self:vMousePosition())
end

function Game:mousereleased(x, y, b)
    local mx, my = self:vMousePosition()
    if b == 3 then self.Camera:lookAt(mx, my) end
end

function Game:mousemoved(x, y)
    if x > cameraViewPort.x and x < cameraViewPort.x + cameraViewPort.w
        and y > cameraViewPort.y and y < cameraViewPort.y + cameraViewPort.h then
        self.Map:Hover(self:vMousePosition())
    else
        self.Map:Hover(-1, -1) -- force an "unhover" by passing out of bounds coords
    end
end

-- camera viewport offset helpers
function Game:vCameraCoords()
    return self.Camera:cameraCoords(cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, cameraViewPort.h)
end
function Game:vMousePosition()
    return self.Camera:mousePosition(cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, cameraViewPort.h)
end
function Game:vWorldCoords()
    return self.Camera:worldCoords(cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, cameraViewPort.h)
end

return Game