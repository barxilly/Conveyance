require "images"

--- Game module
game = {}

--- Game version
game.version = "0.1.4-proto"

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

game.tiles = {
    [0] = {
        name = "Water",
        image = waterimage,
        func = nil,
        immutable = false
    },
    [1] = {
        name = "Dirt",
        image = dirtimage,
        func = nil,
        immutable = false
    },
    [2] = {
        name = "Sand",
        image = sandimage,
        func = nil,
        immutable = false
    },
    [3] = {
        name = "Stone",
        image = stoneimage,
        func = nil,
        immutable = false
    },
    [4] = {
        name = "Tree",
        image = treeimage,
        func = nil,
        immutable = false
    },
    [5] = {
        name = "Quarry",
        image = quarryimage,
        func = function(globalclock, grid, storage)
            if globalclock % love.math.random(7, 10) < 0.1 then
                for i = 1, grid.width do
                    for j = 1, grid.height do
                        if grid[i][j] == 5 or grid[i][j] == 105 then
                            storage["Stone"] = storage["Stone"] + math.floor(1, 2)
                        end
                    end
                end
            end
        end,
        immutable = false
    },
    [6] = {
        name = "Storage",
        image = storageimage,
        func = nil,
        immutable = true
    },
    [-1] = {
        name = "Error",
        image = errorimage,
        func = nil,
        immutable = false
    }
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
    game.grid.width = 20
    game.grid.height = 20

end
