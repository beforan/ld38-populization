local Camera = require "lib.hump.camera"
local Vector = require "lib.hump.vector"

local Map = require "classes.map"
local Params = require "classes.params"
local Player = require "classes.player"
local Assets = require "assets.assets"
local Ui = require "classes.ui"
local utf8 = require "utf8"

local ticker = 0

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
    self.ticks = 0
    self.GameOver = nil

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
            "Mouse: " .. mx .. ", " .. my .. "\n" ..
            "Ticks: " .. self.ticks,
            cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, "right")
    end

    self.Ui:draw()
end

function Game:update(dt)
    if self.GameOver then return Gamestate.push(Gamestate.States.GameOver) end
    
    ticker = ticker + dt
    
    --run the game tick
    if ticker >= Params.Game.Heartbeat then
        self:_tick(dt)
        ticker = 0
    end
    
    self:_keyScroll(dt)
    self:_mouseScroll(dt)
    self:_clampCamera()

    self.Ui:update(dt)
end

function Game:_tick(dt)
    self.ticks = self.ticks + 1

    -- so what do we do on a tick?

    -- iterate through each players houses, assessing income and expenses of all resources
    for _, player in ipairs(self.Players) do
        -- special buildings?

        -- persistent stats (not purely recalculated every frame)
        local food, lumber = player.VitalStatistix.Food, player.VitalStatistix.Lumber
        local growthProgress, deathProgress, buildProgress = player.Progress.Growth, player.Progress.Death, player.Progress.Build

        -- general
        local pop, housing = 0, 0
        
        -- specialists
        local builders, farmers, lumberjacks = 0, 0, 0
        
        -- food
        local harvest, consumption = 0, 0

        -- lumber
        local buildCost, buildSpeed, lumberDens, buildDens = Params.Game.Progress.Build.Cost, 0, {}, {}

        -- growth
        local growthCost, growthDens = Params.Game.Progress.Growth.Cost, {}
        local deathCost, deathDens, fullHouses = Params.Game.Progress.Death.Cost, {}, {}
        
        -- migration
        local destinations = {}

        -- welfare
        local happiness, hunger, disease = 0, 0, 0

        -- evaluate special buildings before houses, for modifiers?

        for _, house in ipairs(player.Houses) do
            pop = pop + house.Population
            housing = housing + Params.Game.Population.HouseCapacity

            -- specialists
            if house.Type == Params.House.Type.Lumberjack then
                lumberjacks = lumberjacks + house.Population
            end
            if house.Type == Params.House.Type.Builder then
                builders = builders + house.Population
            end
            if house.Type == Params.House.Type.Farmer then
                farmers = farmers + house.Population
            end

            -- eligibility for growth
            if house.Population > 1 and house.Population < Params.Game.Population.HouseLimit then
                table.insert(growthDens, house)
            end

            -- eligibility for migration or death
            if house.Population >= Params.Game.Population.HouseCapacity then
                if house.Population == Params.Game.Population.HouseLimit then
                    table.insert(deathDens, house)
                else table.insert(fullHouses, house) end
            end
            if house.Population < Params.Game.Population.HouseCapacity then
                table.insert(destinations, house)
            end

            -- eligibility for building or gathering from
            if not house.Surrounded then
                house:CheckSurrounded() -- in case we or somebody nearby built last tick
                print(house.Surrounded)
                if not house.Surrounded then --still good?
                    table.insert(lumberDens, house)
                    table.insert(buildDens, house)
                end
            end
        end

        -- calculate food and lumber since it affects growth and building
        harvest = farmers * 3 -- params
        consumption = pop + farmers + lumberjacks + builders -- params
        food = food + harvest - consumption
        if food < 0 then
            hunger = math.abs(food)
            food = 0
        end
        -- lumber is more complicated

        -- build?
        if #buildDens <= 0 then
            self.GameOver = {
                Score = true,
                Reason = "No more room left on this small world!\n"
            }
        end
        -- update build progress
        buildProgress = buildProgress + Params.Game.Progress.Build.Tick
        buildProgress = buildProgress + builders * Params.Game.Progress.Build.BuilderModifier
        -- modifiers to buildCost?
        if buildProgress > buildCost then
            local den = buildDens[math.random(#buildDens)]
            den:BuildHouse(player)
            housing = housing + Params.Game.Population.HouseCapacity
            buildProgress = 0
        end

        -- growth?
        -- update growth progress
        growthProgress = growthProgress + food
        if #growthDens > 0 then
            -- modifiers to growthCost?
            if growthProgress > growthCost then
                local den = growthDens[math.random(#growthDens)]
                den.Population = den.Population + 1
                pop = pop + 1
                growthProgress = 0
            end
        end
        -- death?
        deathProgress = deathProgress + Params.Game.Progress.Death.Tick
        deathProgress = deathProgress + hunger * Params.Game.Progress.Death.HungryModifier
        deathProgress = deathProgress + disease * Params.Game.Progress.Death.UnhealthyModifier
        if deathProgress > deathCost then
            local den
            if #deathDens > 0 then
                den = deathDens[math.random(#deathDens)]
            elseif #fullHouses > 0 then
                den = fullHouses[math.random(#fullHouses)]
            else
                den = player.Houses[math.random(#player.Houses)]
            end
            if den.Population > 0 then --guess they're lucky if not, we'll try again next tick
                den.Population = den.Population - 1
                pop = pop - 1
                deathProgress = 0
                if pop == 0 then
                    self.GameOver = {
                        Player = player,
                        Lose = true,
                        Reason = "Everyone in " .. player.Colour .. " player's civilization has perished!"
                    }
                end -- game over
            end
        end

        -- move house?
        if #fullHouses > 0 and #destinations > 0 then

        end

        -- update woodland yield

        -- then update each player's vital statistix
        player.VitalStatistix.Population = pop
        player.VitalStatistix.Food = food
        
        -- and progress
        player.Progress.Growth = growthProgress
        player.Progress.Death = deathProgress
        player.Progress.Build = buildProgress
    end
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
    self:mousemoved(love.mouse.getPosition()) --well, it did move in the game world
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
    self:mousemoved(x, y) --well, it did move in the game world
end

function Game:keypressed(key)
    self:_toggleDebugStats()
end

function Game:keyreleased(key)
    if key == "m" then
        print("Reticulating splines")
        self:_newGame()
        return
    end

    if key == "escape" then Gamestate.push(Gamestate.States.Pause) end
end

function Game:wheelmoved(x, y)
    local zoomVector = (Vector(self:vMousePosition()) - Vector(self.Camera:position())) *
                Params.Camera.ZoomPositionAdjust
    if y > 0 then
        if self.Camera.scale < Params.Camera.MaxZoom then
            self.Camera:zoom(Params.Camera.ZoomIncrement)
            self.Camera:move(zoomVector.x, zoomVector.y)
            self:mousemoved(love.mouse.getPosition()) --well, it did move in the game world
        end
    elseif y < 0 then
        if self.Camera.scale > Params.Camera.MinZoom then
            self.Camera:zoom(Params.Camera.ZoomExcrement)
            self.Camera:move(zoomVector.x, zoomVector.y)
            self:mousemoved(love.mouse.getPosition()) --well, it did move in the game world
        end
    end
    self.Map:Hover(self:vMousePosition())
end

function Game:mousereleased(x, y, b)
    local mx, my = self:vMousePosition()

    -- move camera
    if b == 3 then
        self.Camera:lookAt(mx, my)
        self:mousemoved(love.mouse.getPosition()) --well, it did move in the game world
    end

    -- select a tile
    if b == 1 then
        if x > cameraViewPort.x and x < cameraViewPort.x + cameraViewPort.w
            and y > cameraViewPort.y and y < cameraViewPort.y + cameraViewPort.h then
            self.Map:Select(mx, my)
        end
    end

    -- deselect a tile
    if b == 2 then
        if x > cameraViewPort.x and x < cameraViewPort.x + cameraViewPort.w
            and y > cameraViewPort.y and y < cameraViewPort.y + cameraViewPort.h then
            self.Map:Select()
        end
    end
end

function Game:mousemoved(x, y)
    if x > cameraViewPort.x and x < cameraViewPort.x + cameraViewPort.w
        and y > cameraViewPort.y and y < cameraViewPort.y + cameraViewPort.h then
        self.Map:Hover(self:vMousePosition())
    else
        self.Map:Hover() --hover nothing is effectively no hover
    end
end

-- camera viewport offset helpers
function Game:vMousePosition()
    return self.Camera:mousePosition(cameraViewPort.x, cameraViewPort.y, cameraViewPort.w, cameraViewPort.h)
end

return Game