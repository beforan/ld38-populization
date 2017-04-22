local Class = require "lib.hump.class"
local Vector = require "lib.hump.vector"

local Const = require "classes.const"
local Tile = require "classes.tile"


local points

local Map = Class {
    init = function(self)
        self:_clear()
    end,
    Width = Const.Map.Width,
    Height = Const.Map.Height,
    Tiles = {}
}

function Map:_clear()
    for y=1, self.Height do
        self.Tiles[y] = {}
    end
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
    for i=1, Const.Map.Centres do
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

function Map:_isNorthSouth(dir)
    return (dir == Const.Map.Direction.North or dir == Const.Map.Direction.South)
end

function Map:_isEastWest(dir)
    return (dir == Const.Map.Direction.East or dir == Const.Map.Direction.West)
end

function Map:_getRiverStart(dir)
    local deadzone = (100 - Const.Map.RiverStartZone / 2) --we don't want to start too near a corner as it increases the chances of dumb rivers
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
    if dir == Const.Map.Direction.North then y = self.Height end
    if dir == Const.Map.Direction.West then y = self.Width end
    return { x = x, y = y }
end

function Map:_outOfBounds(posx, y)
    local x
    if type(posx) == "table" then
        x, y = posx.x, posx.y
    else x = posx end

    if self.Tiles[y] == nil then return true end
    if x < 1 or x > self.Width then return true end --can't nil check x because it may not be populated yet
    return false
end

function Map:_getOppositeDir(dir)
    if dir == Const.Map.Direction.North then return Const.Map.Direction.South end
    if dir == Const.Map.Direction.South then return Const.Map.Direction.North end
    if dir == Const.Map.Direction.West then return Const.Map.Direction.East end
    if dir == Const.Map.Direction.East then return Const.Map.Direction.West end
end

function Map:_generateRiver()
    --we'll use this recursively to plot the river
    local function nextRiverTile(pos, oldDir, favourDir)
        print(pos.x, pos.y, self:_outOfBounds(pos))
        self.Tiles[pos.y][pos.x] = Tile(pos.x, pos.y, Const.Tile.Type.River) --render the current tile
        --then choose the next tile
        local dir = Map:_getRandomMapDirection()
        if dir == self:_getOppositeDir(oldDir) then dir = favourDir end -- can't double back on ourselves; use this to weight the favoured direction
        if dir == self:_getOppositeDir(favourDir) then dir = favourDir end -- also can't go back towards the start (river flowing uphill?)

        if dir == Const.Map.Direction.North then pos.y = pos.y - 1 end
        if dir == Const.Map.Direction.South then pos.y = pos.y + 1 end
        if dir == Const.Map.Direction.East then pos.x = pos.x + 1 end
        if dir == Const.Map.Direction.West then pos.x = pos.x - 1 end

        print(pos.x, pos.y, self:_outOfBounds(pos))

        if not self:_outOfBounds(pos) then
            nextRiverTile(pos, dir, favourDir)
        end
    end

    -- pick a direction
    local dir = self:_getRandomMapDirection()

    -- go!
    nextRiverTile(self:_getRiverStart(dir), dir, dir)
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
    local nPoints = Const.Map.Centres
    points = {} --we can use the same table for the dictionary and the list, because lua
    for i=1, self.Height > nPoints and self.Height or nPoints do
        points[i] = {}
    end

    local nWoodland, nGrain = Const.Map.Woodland / 100 * nPoints, Const.Map.Grain / 100 * nPoints

    self:_pickCentres(points, 1, nWoodland, Const.Tile.Type.Woodland) -- Woodland nodes
    self:_pickCentres(points, nWoodland +1, nWoodland+nGrain, Const.Tile.Type.Grain) -- Grain nodes
    self:_pickCentres(points, nWoodland+nGrain+1, nPoints, Const.Tile.Type.Grass) -- Grass nodes

    -- now iterate the tile map and populate tiles based on centres
    for y=1, #self.Tiles do
        for x=1, self.Width do
            if self.Tiles[y][x] == nil then -- don't overwrite the river
                self.Tiles[y][x] = Tile(x, y, self:_getNearestCentreType(points, x, y))
            end
        end
    end
end

function Map:draw()
    for y=1, #self.Tiles do
        for x=1, #self.Tiles[y] do
            self.Tiles[y][x]:draw()
        end
    end
end

return Map