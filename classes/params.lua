-- this is a bit of a weird table;
-- it's a catch-all for non-variable parameters that define game behaviour,
-- providing a single point of truth for a lot of mechanics, to avoid magic numbers,
-- but it also contains some enums to avoid magic strings...
--
-- as such, some values (mostly mechanics-y numbers) can be changed without breaking things,
-- just changing the game balance
-- but other things (like Type enums) are tied into other settings elsewhere (like assets)
-- so shouldn't be changed
--
-- oh well, game jams, amirite?

return {
    Ui = {
        TextColours = {
            Title = { 180, 180, 255, 255 },
            Good = { 180, 255, 180, 255 },
            Warning = { 255, 240, 150, 255 },
            Bad = { 255, 180, 180, 255 },
            Text = { 255, 255, 255, 255 }
        },
        IconWidth = 40,
        ButtonHeight = 40,
        TipHeight = 200,
        SideBar = { --suit layout definition
            Colour = { 64, 96, 128, 255 },
            Width = 200,
            min_height = 670, -- window height - statusbar height
            pos = { 0, 30 }, --y should be the height of the statusbar
            padding = { 10, 10 },
            { 200, 200 }, --info tip (width should match SideBar, height should match TipHeight)
            { nil, "fill"}, -- selected item area
            { nil, 50 } -- menu button?
        },
        StatusBar = { --suit layout definition
            Colour = { 32, 64, 96, 255  },
            Height = 30,
            pos = { 0, 0 },
            padding = { 5, 5 },
            { 100, 30 }, -- pop
            { 100, 30 }, -- food
            { 100, 30 } -- lumber
        },
        DebugStats = true
    },
    Camera = {
        ScrollSpeed = 400,
        ZoomIncrement = 1.1,
        ZoomExcrement = 0.9, -- couldn't resist
        MinZoom = 0.9,
        MaxZoom = 2,
        ZoomPositionAdjust = 0.2,
        EdgeScrollZone = 1 -- percentage of the viewport dimensions
    },
    Game = {
        Players = { -- more than 4 players will break, but technically up to 4 should work if assets are provided, even though only 2 is intended
            [1] = "Blue",
            [2] = "Red"
        },
        Start = {
            Food = 50,
            Lumber = 50,
            Pop = 4
        },
        Population = {
            BuildTrigger = 4,
            HouseCapacity = 4,
            HouseLimit = 8
        }
        
    },
    Tile = {
        Size = 32,
        Type = {
            Grass = "Grass",
            Woodland = "Woodland",
            Deforested = "Deforested",
            Grain = "Grain",
            River = "River",
            Riverside = "Riverside"
        }
    },
    House = {
        Type = {
            Standard = "Standard",
            Builder = "Builder",
            Lumberjack = "Lumberjack",
            Farmer = "Farmer",
            Fisher = "Fisher"
        }
    },
    Map = {
        Width = 90,
        Height = 50,
        -- these are ratios of tiles for woodland and grain
        -- for the tiles remaining after the river (and riverside)
        -- everything else if grass
        Woodland = 20,
        Grain = 20,
        Centres = 100, -- how many centre nodes used for procgen
        Direction = {
            North = 1,
            East = 2,
            South = 3,
            West = 4
        },
        Quadrant = {
            NW = 1,
            NE = 2,
            SE = 3,
            SW = 4
        },
        RiverStartZone = 60 -- central percentage of an edge the river can start in
    }
}