require "images"

function areTwoGridPointsConnected(gp1, gp2, grid, connectorTile)
    local visited = {}
    for i = 1, #grid do
        visited[i] = {}
        for j = 1, #grid[i] do
            visited[i][j] = false
        end
    end
    local queue = {}
    table.insert(queue, gp1)
    visited[gp1[1]][gp1[2]] = true
    while #queue > 0 do
        local current = table.remove(queue, 1)
        if current[1] == gp2[1] and current[2] == gp2[2] then
            return true
        end
        for i = -1, 1 do
            for j = -1, 1 do
                if (i == 0 or j == 0) and (i ~= 0 or j ~= 0) then
                    local x = current[1] + i
                    local y = current[2] + j
                    if x >= 1 and x <= #grid and y >= 1 and y <= #grid[x] and not visited[x][y] and
                        (grid[x][y] == connectorTile or (x == gp2[1] and y == gp2[2])) then
                        table.insert(queue, {x, y})
                        visited[x][y] = true
                    end
                end
            end
        end
    end
    return false
end

function getStorageGrid(grid)
    local storageGrid = {1, 1}
    for i = 1, #grid do
        for j = 1, #grid[i] do
            if grid[i][j] == 6 then
                storageGrid = {i, j}
                break
            end
        end
    end
    print(storageGrid[1] .. " " .. storageGrid[2])
    return storageGrid
end

--- Game module
game = {}

--- Game version
game.version = "0.1.13-proto"

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
            if globalclock % love.math.random(7, 10) < 0.1 then
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
            if globalclock % love.math.random(7, 10) < 0.1 then
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

game.randomSize = 10000
game.continentality = 30

-- Uncomment seed for fully deterministic generation. Seed is any number between 0 and 2^32.
-- game.seed =

game.mobile = false
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' or game.mobile then
    game.mobile = true
end
