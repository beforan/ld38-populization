return {
    Game = {
        Players = 2
    },
    Tile = {
        Size = 10,
        Type = {
            Grass = "Grass",
            Woodland = "Woodland",
            Deforested = "Deforested",
            Grain = "Grain",
            River = "River",
            Riverside = "Riverside"
        }
    },
    Map = {
        Width = 50,
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