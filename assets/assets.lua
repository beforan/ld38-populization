local utf8 = require "utf8" -- for fa icons

return {
    Sprites = {
        Grass = love.graphics.newImage("/assets/jon/grass.png"),
        Woodland = love.graphics.newImage("/assets/jon/woodland.png"),
        Riverside = love.graphics.newImage("/assets/jon/riverside.png"),
        Grain = love.graphics.newImage("/assets/jon/grain.png"),
        River = love.graphics.newImage("/assets/jon/river.png"),
        BluePlayer = {
            Standard = love.graphics.newImage("/assets/jon/standard_blue.png"),
            Farmer = love.graphics.newImage("/assets/jon/farmer_blue.png"),
            Fisher = love.graphics.newImage("/assets/jon/farmer_blue.png"),
            Builder = love.graphics.newImage("/assets/jon/builder_blue.png"),
            Lumberjack = love.graphics.newImage("/assets/jon/lumberjack_blue.png")
        },
        RedPlayer = {
            Standard = love.graphics.newImage("/assets/jon/standard_red.png"),
            Farmer = love.graphics.newImage("/assets/jon/farmer_red.png"),
            Fisher = love.graphics.newImage("/assets/jon/farmer_red.png"),
            Builder = love.graphics.newImage("/assets/jon/builder_red.png"),
            Lumberjack = love.graphics.newImage("/assets/jon/lumberjack_red.png")
        }
    },
    Fonts = {
        Default = love.graphics.getFont(),
        StatusIcons = love.graphics.newFont("/assets/font-awesome/fontawesome-webfont.ttf", 14)
    },
    Icons = { --Oh yes a unicode lookup for the fa icons i'm actually using
        Population = utf8.char(0xf0c0),
        InfoCircle = utf8.char(0xf05a),
        Food = utf8.char(0xf0f5),
        Lumber = utf8.char(0xf1bb),
        Selected = utf8.char(0xf00c)
    }
}