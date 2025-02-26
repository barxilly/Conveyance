require "images"

--- Game module
game = {}

--- Game version
game.version = "0.1.2-proto"

--- Whether to show the FPS counter
game.showFPS = true

--- Testing if the module has been loaded
function game.test()
    print("Game loaded")
end

function game.openCraftingMenu(text, cmOpen)

end

--- Load Grid
game.grid = {}
game.grid.width = 30
game.grid.height = 30

--- Load the list of available tiles
game.tileList = {0, 1, 2, 3, 4, 5, 6}

--- Load the tile map
game.tileMap = {
    [0] = waterimage, -- Water
    [1] = dirtimage, -- Dirt
    [2] = sandimage, -- Sand
    [3] = stoneimage, -- Stone
    [4] = treeimage, -- Tree
    [5] = quarryimage, -- Quarry
    [6] = storageimage, -- Storage
    [-1] = errorimage, -- Error
    ["Water"] = waterimage,
    ["Dirt"] = dirtimage,
    ["Sand"] = sandimage,
    ["Stone"] = stoneimage,
    ["Tree"] = treeimage,
    ["Quarry"] = quarryimage,
    ["Storage"] = storageimage,
    ["Error"] = errorimage
}

--- Tiles that cannot be removed
game.immutableTiles = {
    [0] = false,
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = true,
    [-1] = false
}
game.startStorage = {
    Water = 20,
    Dirt = 20,
    Sand = 20,
    Tree = 20,
    Stone = 0,
    Wood = 0,
    Quarry = 1,
    Storage = 0,
    Logger = 0
}

game.invMap = {
    [0] = "Water",
    [1] = "Dirt",
    [2] = "Sand",
    [3] = "Stone",
    [4] = "Tree",
    [5] = "Quarry",
    [6] = "Storage",
    [-1] = "Error"
}

game.cmOpen = false

game.randomSize = 10000
game.continentality = 30

-- Uncomment seed for fully deterministic generation. Seed is any number between 0 and 2^32.
-- game.seed =

game.weight = {
    dirt = 0.5,
    sand = 0.35,
    stone = 0.8,
    tree = 0.6
}

game.mobile = false
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    game.mobile = true
end
