return {
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
    Map = {
        Width = 50,
        Height = 50,
        -- these are ratios of tiles for woodland and grain
        -- for the tiles remaining after the river (and riverside)
        -- everything else if grass
        Woodland = 20,
        Grain = 20,
        Centres = 100
    }
}