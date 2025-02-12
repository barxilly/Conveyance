require "instructionsM"
require "game"
instructionsM.test()
game.test()

function love.load()
    debugmode = false

    waterimage = love.graphics.newImage("assets/water.png")
    landimage = love.graphics.newImage("assets/land.png")
    beachimage = love.graphics.newImage("assets/sand.png")
    stoneimage = love.graphics.newImage("assets/stone.png")
    forestimage = love.graphics.newImage("assets/forest.png")

    quarryimage = love.graphics.newImage("assets/quarry.png")
    -- beltile = love.graphics.newImage("belt.png")

    instructions = instructionsM.default

    inventory = game.startInventory

    love.math.setRandomSeed(game.seed or (os.time() + love.math.random()))

    grid = game.grid
    -- Create a 10x10 grid
    for i = 1, grid.width do
        grid[i] = {}
        for j = 1, grid.height do
            grid[i][j] = 0
        end
    end

    availableTiles = game.tileList
    loadedTileInd = 1

    mouseHeld = false
    keyHeld = false
    currentCellMouseHeld = {0, 0}
    currentCellMouseHover = {0, 0}

    -- Use perlin noise to generate a random grid
    local offsetX = love.math.random() * game.randomSize
    local offsetY = love.math.random() * game.randomSize
    for i = 1, grid.width do
        for j = 1, grid.height do
            local noiseValue = love.math.noise(i / 10 + offsetX, j / 10 + offsetY)
            if noiseValue > 0.6 then
                grid[i][j] = 1 -- Land
            elseif noiseValue > 0.4 then
                grid[i][j] = 2 -- Beach
            else
                grid[i][j] = 0 -- Water
            end
        end
    end

    -- Use perlin noise as a biome map, with 2 biomes, 1 being land, 2 being stone
    local offsetX = love.math.random() * 1000
    local offsetY = love.math.random() * 1000
    for i = 1, grid.width do
        for j = 1, grid.height do
            local noiseValue = love.math.noise(i / 10 + offsetX, j / 10 + offsetY)
            if noiseValue > 0.8 and grid[i][j] == 1 then -- Increased threshold to 0.8
                grid[i][j] = 3 -- Stone
            end
        end
    end

    local offsetX = love.math.random() * 1000
    local offsetY = love.math.random() * 1000
    for i = 1, grid.width do
        for j = 1, grid.height do
            local noiseValue = love.math.noise(i / 10 + offsetX, j / 10 + offsetY)
            if noiseValue > 0.3 and grid[i][j] == 1 then -- Increased threshold to 0.8
                grid[i][j] = 4 -- Forest
            end
        end
    end
end

initial = {}
tile = 0
clock = 0
prev = false
function selectNextTile()
    loadedTileInd = loadedTileInd + 1
    if loadedTileInd > (#availableTiles - 1) then
        loadedTileInd = 0
    end
    tile = loadedTileInd
    clock = 2
    prev = true
end

globalclock = 0
laststone = 0
function love.update(dt)
    -- Every 2 seconds, add a stone to the inventory for each quarry
    globalclock = globalclock + dt
    if globalclock % 2 < 0.1 then
        for i = 1, grid.width do
            for j = 1, grid.height do
                if grid[i][j] == 5 then
                    inventory["Stone"] = inventory["Stone"] + 1
                end
            end
        end
    end

    -- If the mouse is pressed, change the value of the cell under the mouse and invert colors
    if love.mouse.isDown(1) then
        local screen_width = love.graphics.getWidth()
        local screen_height = love.graphics.getHeight()
        local grid_size = screen_height
        local cell_size = grid_size / grid.width
        local grid_x = (screen_width - grid_size) / 2
        local grid_y = (screen_height - grid_size) / 2
        local mouse_x, mouse_y = love.mouse.getPosition()
        local i = math.floor((mouse_x - grid_x) / cell_size) + 1
        local j = math.floor((mouse_y - grid_y) / cell_size) + 1
        if not mouseHeld or (currentCellMouseHeld[1] ~= i or currentCellMouseHeld[2] ~= j) then
            if i >= 1 and i <= grid.width and j >= 1 and j <= grid.height then
                if loadedTileInd == 5 and ((not (grid[i][j] == 3 or grid[i][j] == 103)) or inventory["Quarries"] == 0) then
                else
                    grid[i][j] = loadedTileInd
                    if loadedTileInd == 5 then
                        inventory["Quarries"] = inventory["Quarries"] - 1
                    end
                end
            end
            currentCellMouseHeld = {i, j}
        end
        mouseHeld = true
    elseif love.mouse.isDown(2) then
        if not mouseHeld then
            selectNextTile()
        end
        mouseHeld = true
    else
        local screen_width = love.graphics.getWidth()
        local screen_height = love.graphics.getHeight()
        local grid_size = screen_height
        local cell_size = grid_size / grid.width
        local grid_x = (screen_width - grid_size) / 2
        local grid_y = (screen_height - grid_size) / 2
        local mouse_x, mouse_y = love.mouse.getPosition()
        local i = math.floor((mouse_x - grid_x) / cell_size) + 1
        local j = math.floor((mouse_y - grid_y) / cell_size) + 1
        if not mouseHeld or (currentCellMouseHeld[1] ~= i or currentCellMouseHeld[2] ~= j) then
            if i >= 1 and i <= grid.width and j >= 1 and j <= grid.height then
                if grid[i][j] < 100 then
                    grid[i][j] = grid[i][j] + 100
                end
            end
            currentCellMouseHover = {i, j}
        end
        mouseHeld = false
    end

    for i = 1, grid.width do
        for j = 1, grid.height do
            if grid[i][j] >= 100 and not (currentCellMouseHover[1] == i and currentCellMouseHover[2] == j) then
                grid[i][j] = grid[i][j] - 100
            end
        end
    end

    -- If Esc is pressed, exit the game
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if love.keyboard.isDown("d") and not keyHeld then
        debugmode = not debugmode
        keyHeld = true
        -- debug.debug()
    elseif not love.keyboard.isDown("d") then
        keyHeld = false
    end

    if love.keyboard.isDown("c") and not keyHeld then
        keyHeld = true
        game.openCraftingMenu()
    elseif not love.keyboard.isDown("c") then
        keyHeld = false
    end
end

function love.draw()
    todraw = instructions

    if debugmode and not todraw[5] then
        table.insert(todraw, "Debug mode enabled")
    elseif not debugmode and todraw[5] then
        table.remove(todraw, 5)
    end

    instructionsM.draw(todraw)
    instructionsM.drawInventory(inventory)

    tileMappings = game.tileMap
    tileNames = game.tileNames
    -- Draw the grid screen height by screen height in the center of the screen
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local grid_size = screen_height
    local cell_size = grid_size / grid.width
    local grid_x = (screen_width - grid_size) / 2
    local grid_y = (screen_height - grid_size) / 2

    for i = 1, grid.width do
        for j = 1, grid.height do
            local tile = grid[i][j]
            local texture = tileMappings[tile] or waterimage
            if tile >= 100 then
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            texture = tileMappings[tile % 100] or waterimage
            love.graphics.draw(texture, grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, 0,
                cell_size / texture:getWidth(), cell_size / texture:getHeight())

            -- Reset color to white before drawing the image
            love.graphics.setColor(1, 1, 1)

            -- Get the width and height of the text
            local text = tostring(tile)
            local text_width = love.graphics.getFont():getWidth(text)
            local text_height = love.graphics.getFont():getHeight(text)

            -- Calculate the position to center the text
            local text_x = grid_x + (i - 1) * cell_size + (cell_size - text_width) / 2
            local text_y = grid_y + (j - 1) * cell_size + (cell_size - text_height) / 2

            if debugmode then
                love.graphics.setColor(0, 0, 0)
                love.graphics.print(text, text_x, text_y)
                -- Reset color to white after drawing the text
                love.graphics.setColor(1, 1, 1)
            end
        end
    end

    -- Preview the next tile in a circle
    local preview_size = 40
    local preview_x = screen_width - preview_size - 65
    local preview_y = screen_height - preview_size - 25
    local tile = tileMappings[loadedTileInd]

    -- Calculate scale factors to fit the preview size
    local scale_x = preview_size / tile:getWidth()
    local scale_y = preview_size / tile:getHeight()

    local tile_width = tile:getWidth() * scale_x
    local tile_height = tile:getHeight() * scale_y
    local circle_x = preview_x + tile_width / 2
    local circle_y = preview_y + tile_height / 2

    love.graphics.draw(tile, preview_x, preview_y, 0, scale_x, scale_y)
    love.graphics.rectangle("line", preview_x, preview_y, tile_width, tile_height)
    local tileName = tileNames[loadedTileInd] or "Unknown"
    love.graphics.print(tileName, preview_x + tile_width + 10,
        preview_y + tile_height / 2 - love.graphics.getFont():getHeight() / 2)
end
