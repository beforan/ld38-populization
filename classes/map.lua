local Class = require "lib.hump.class"
local Vector = require "lib.hump.vector"

local Params = require "classes.params"
local Tile = require "classes.tile"

local Map = Class {
    init = function(self)
        self:_clear()
    end,
    Width = Params.Map.Width,
    Height = Params.Map.Height,
    Tiles = {}
}


-- "public" methods

function Map:Hover(posx, y)
    local x
    if type(posx) == "table" then
        x, y = posx.x, posx.y
    else x = posx end

    local tx, ty = self:GetTileCoords(x, y)

    if not self:OutOfBounds(tx, ty) then self.HoverTile = self.Tiles[ty][tx]
    else self.HoverTile = nil end
end

function Map:GetTileCoords(posx, y)
    local x
    if type(posx) == "table" then
        x, y = posx.x, posx.y
    else x = posx end

    return math.floor(x / Params.Tile.Size) + 1, math.floor(y / Params.Tile.Size) + 1
end

function Map:OutOfBounds(posx, y)
    local x
    if type(posx) == "table" then
        x, y = posx.x, posx.y
    else x = posx end

    if self.Tiles[y] == nil then return true end
    if x < 1 or x > self.Width then return true end --can't nil check x because it may not be populated yet
    return false
end

function Map:Spawn()
    local excludeQ = {}
    for _, v in ipairs(Gamestate.current().Players) do
        local done = false
        while not done do
            local q = self:_getRandomQuadrant(excludeQ)
            local pos = self:_getRandomTile(q)
            if self.Tiles[pos.y][pos.x]:BuildHouse(v, Params.Game.Start.Pop) then
                table.insert(excludeQ, q)
                done = true
            end
        end
    end
end

function Map:GetAdjacentCoords(posx, y)
    local results = {}    
    local x
    if type(posx) == "table" then
        x, y = posx.x, posx.y
    else x = posx end

    for dx = -1, 1 do
        for dy = -1, 1 do
            if not self:OutOfBounds(x + dx, y + dy) and not (dx == 0 and dy == 0) then
                table.insert(results, { x = x + dx, y = y + dy })
            end
        end
    end

    return results
end

function Map:GetAdjacentTiles(posx, y)
    local results = {}    
    for _, v in ipairs(self:GetAdjacentCoords(posx, y)) do
        table.insert(results, self.Tiles[v.y][v.x])
    end
    return results
end

function Map:Generate()
    self:_clear()

    self:_generateRiver() --river first

    -- then distribute grass, woodland and grain
    
    -- we'll use n points, in our defined ratio, as randomly picked (non-river) centres
    -- then voronoi distribution against these nodes for the rest
    -- then weighting of the center points should guarantee the weighting we want in the final map
    
    -- keep a dictionary of points so we can check if that location is already one
    -- also keep a list we can iterate to find the nearest, as this will be more efficient
    local nPoints = Params.Map.Centres
    local points = {} --we can use the same table for the dictionary and the list, because lua
    for i=1, self.Height > nPoints and self.Height or nPoints do
        points[i] = {}
    end

    local nWoodland, nGrain = Params.Map.Woodland / 100 * nPoints, Params.Map.Grain / 100 * nPoints

    self:_pickCentres(points, 1, nWoodland, Params.Tile.Type.Woodland) -- Woodland nodes
    self:_pickCentres(points, nWoodland +1, nWoodland+nGrain, Params.Tile.Type.Grain) -- Grain nodes
    self:_pickCentres(points, nWoodland+nGrain+1, nPoints, Params.Tile.Type.Grass) -- Grass nodes

    -- now iterate the tile map and populate tiles based on centres
    for y=1, #self.Tiles do
        for x=1, self.Width do
            if self.Tiles[y][x] == nil then -- don't overwrite the river
                self.Tiles[y][x] = Tile(x, y, self:_getNearestCentreType(points, x, y))
            end
        end
    end
end


-- callbacks

function Map:draw()
    if self.HoverTile then
        love.graphics.print(self.HoverTile.X .. ", " .. self.HoverTile.Y, 100, 10)
    end
    for y=1, #self.Tiles do
        for x=1, #self.Tiles[y] do
            local t = self.Tiles[y][x]
            t:draw(t == self.HoverTile)
        end
    end
end


-- Helpers

function Map:_clear()
    for y=1, self.Height do
        self.Tiles[y] = {}
    end
    self.HoverTile = nil
end

function Map:_getRandomTile(quad)
    local q, xMin, yMin, xMax, yMax = Params.Map.Quadrant, 1, 1, self.Width, self.Height
    if     quad == q.NW then xMax, yMax = self.Width / 2, self.Height / 2
    elseif quad == q.NE then xMin, yMax = self.Width / 2, self.Height / 2
    elseif quad == q.SE then xMin, yMin = self.Width / 2, self.Height / 2
    elseif quad == q.SW then xMax, yMin = self.Width / 2, self.Height / 2 end
    return { x = math.random(xMin, xMax), y = math.random(yMin, yMax) }
end

function Map:_pickCentres(points, start, limit, type)
    for i=start, limit do
        local pick = true
        while pick do
            local x = math.random(self.Width)
            local y = math.random(self.Height)

            if points[y][x] == nil then
                points[y][x] = type
                points[i].point = Vector(x, y)
                pick = false
            end
        end
    end
end

function Map:_getNearestCentreType(points, x, y)
    local distances = {}
    local pointsByDist = {}
    -- get vector magnitude between our point and all the centres
    -- (theoretically you could probably cull some centres but w/e)
    for i=1, Params.Map.Centres do
        local p = Vector(x, y)
        local c = points[i].point
        if p == c then return points[y][x] end --shortcut if we ARE a point
        local d = c:dist(p)
        pointsByDist[d] = c
        table.insert(distances, d)
    end
    local r = pointsByDist[math.min(unpack(distances))]
    return points[r.y][r.x]
end

function Map:_getRandomMapDirection()
    return math.random(4)
end
function Map:_getRandomQuadrant(excludeQ)
    local result
    while not result do --yay, hideously inefficient! but few values, so whatever
        result = math.random(4)
        for _, v in ipairs(excludeQ) do
            if result == v then result = nil end
        end
    end
    return result
end

function Map:_isNorthSouth(dir)
    return (dir == Params.Map.Direction.North or dir == Params.Map.Direction.South)
end

function Map:_isEastWest(dir)
    return (dir == Params.Map.Direction.East or dir == Params.Map.Direction.West)
end

function Map:_getRiverStart(dir)
    local deadzone = (100 - Params.Map.RiverStartZone / 2) --we don't want to start too near a corner as it increases the chances of dumb rivers
    local x, y = 1, 1
    if self:_isEastWest(dir) then
        y = math.random(
            self.Height * deadzone / 100,
            self.Height * (100 - deadzone) / 100) -- pick a random y for horizontal
    else
        x = math.random(
            self.Width * deadzone / 100,
            self.Width * (100 - deadzone) / 100) -- or a random x for vertical
    end
    -- handle the directions that don't the perpendicular coord as 1
    if dir == Params.Map.Direction.North then y = self.Height end
    if dir == Params.Map.Direction.West then x = self.Width end
    return { x = x, y = y }
end

function Map:_getOppositeDir(dir)
    if dir == Params.Map.Direction.North then return Params.Map.Direction.South end
    if dir == Params.Map.Direction.South then return Params.Map.Direction.North end
    if dir == Params.Map.Direction.West then return Params.Map.Direction.East end
    if dir == Params.Map.Direction.East then return Params.Map.Direction.West end
end

function Map:_generateRiver()
    --we'll use this recursively to plot the river
    local function nextRiverTile(pos, oldDir, favourDir)
        self.Tiles[pos.y][pos.x] = Tile(pos.x, pos.y, Params.Tile.Type.River) --render the current tile

        -- set all adjacent tiles to riverside
        for _, v in ipairs(self:GetAdjacentCoords(pos)) do
            if not self.Tiles[v.y][v.x] then
                self.Tiles[v.y][v.x] = Tile(v.x, v.y, Params.Tile.Type.Riverside)
            end
        end

        --then choose the next tile
        local dir = Map:_getRandomMapDirection()
        if dir == self:_getOppositeDir(oldDir) then dir = favourDir end -- can't double back on ourselves; use this to weight the favoured direction
        if dir == self:_getOppositeDir(favourDir) then dir = favourDir end -- also can't go back towards the start (river flowing uphill?)

        if dir == Params.Map.Direction.North then pos.y = pos.y - 1 end
        if dir == Params.Map.Direction.South then pos.y = pos.y + 1 end
        if dir == Params.Map.Direction.East then pos.x = pos.x + 1 end
        if dir == Params.Map.Direction.West then pos.x = pos.x - 1 end

        if not self:OutOfBounds(pos) then
            nextRiverTile(pos, dir, favourDir)
        end
    end

    -- pick a direction
    local dir = self:_getRandomMapDirection()

    -- go!
    nextRiverTile(self:_getRiverStart(dir), dir, dir)
end

return Map