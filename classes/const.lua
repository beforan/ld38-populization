return {
    Ui = {
        SideBar = 200, -- width in px
        StatusBar = 30 -- height in px
    },
    Camera = {
        ScrollSpeed = 10,
        ZoomIncrement = 1.1,
        ZoomExcrement = 0.9, -- couldn't resist
        MinZoom = 0.9,
        MaxZoom = 2
    },
    Game = {
        Players = {
            [1] = "Blue",
            [2] = "Red"
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