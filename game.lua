require "images"
require "utils"

--- Game module
game = {}

--- Game version
game.version = "0.1.16-proto"

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
game.grid.width = 20
game.grid.height = 15

game.tiles = {
    [0] = {
        name = "Water",
        image = waterimage,
        func = nil,
        immutable = false,
        weight = 0.8,
        requires = -1
    },
    [1] = {
        name = "Dirt",
        image = dirtimage,
        func = nil,
        immutable = false,
        weight = 0.5,
        requires = -1
    },
    [2] = {
        name = "Sand",
        image = sandimage,
        func = nil,
        immutable = false,
        weight = 0.35,
        requires = -1
    },
    [3] = {
        name = "Stone",
        image = stoneimage,
        func = nil,
        immutable = false,
        weight = 0.8,
        requires = -1
    },
    [4] = {
        name = "Wood",
        image = treeimage,
        func = nil,
        immutable = false,
        weight = 0.6,
        requires = -1
    },
    [5] = {
        name = "Quarry",
        image = quarryimage,
        func = function(globalclock, grid, storage)
            if globalclock % love.math.random(3, 10) < 0.1 then
                for i = 1, grid.width do
                    for j = 1, grid.height do
                        local storageGrid = getStorageGrid(grid)
                        if (grid[i][j] == 5 or grid[i][j] == 105) and
                            areTwoGridPointsConnected({i, j}, storageGrid, grid, 7) then
                            storage["Stone"] = storage["Stone"] + math.floor(1, 2)
                        end
                    end
                end
            end
        end,
        immutable = false,
        weight = 0,
        requires = 3
    },
    [6] = {
        name = "Storage",
        image = storageimage,
        func = nil,
        immutable = true,
        weight = 0,
        requires = -1
    },
    [7] = {
        name = "Conveyor",
        image = conveyorimage,
        func = nil,
        immutable = false,
        weight = 0,
        requires = -1
    },
    [8] = {
        name = "Logger",
        image = loggerimage,
        func = function(globalclock, grid, storage)
            if globalclock % love.math.random(3, 10) < 0.1 then
                for i = 1, grid.width do
                    for j = 1, grid.height do
                        local storageGrid = getStorageGrid(grid)
                        if (grid[i][j] == 8 or grid[i][j] == 108) and
                            areTwoGridPointsConnected({i, j}, storageGrid, grid, 7) then
                            storage["Wood"] = storage["Wood"] + math.floor(1, 2)
                        end
                    end
                end
            end
        end,
        immutable = false,
        weight = 0,
        requires = 4
    },
    [-1] = {
        name = "Error",
        image = errorimage,
        func = nil,
        immutable = false,
        weight = 0,
        requires = -1
    }
}

game.startStorage = {
    Water = 20,
    Dirt = 20,
    Sand = 20,
    Stone = 0,
    Wood = 20,
    Quarry = 1,
    Storage = 0,
    Logger = 1,
    Conveyor = 200
}
game.cmOpen = false
game.smOpen = false
game.menuOpen = false

game.randomSize = 10000
game.continentality = 30

-- Uncomment seed for fully deterministic generation. Seed is any number between 0 and 2^32.
-- game.seed =

game.mobile = false
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' or game.mobile then
    game.mobile = true
end
