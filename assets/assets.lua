local utf8 = require "utf8" -- for fa icons

return {
    Sprites = {
        Grass = love.graphics.newImage("/assets/jon/grass.png"),
        Woodland = love.graphics.newImage("/assets/jon/woodland.png"),
        Riverside = love.graphics.newImage("/assets/jon/riverside.png"),
        Grain = love.graphics.newImage("/assets/jon/grain.png"),
        River = love.graphics.newImage("/assets/jon/river.png"),
        BluePlayer = {
            Standard = love.graphics.newImage("/assets/jon/standard_blue.png")
        },
        RedPlayer = {
            Standard = love.graphics.newImage("/assets/jon/standard_red.png")
        }
    },
    Fonts = {
        Default = love.graphics.getFont(),
        StatusIcons = love.graphics.newFont("/assets/font-awesome/fontawesome-webfont.ttf", 14)
    },
    Icons = { --Oh god yes a unicode lookup for the fa icons i'm actually using
        Population = utf8.char(0xf0c0),
        InfoCircle = utf8.char(0xf05a)
    }
}