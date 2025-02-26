require "instructionsM"
require "game"
require "images"
require "debug"
reloads = 0

screens = {
    game = {},
    title = {}
}

--- TITLE
-- LOAD

function screens.title.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    title = love.graphics.newImage("assets/dirt.png")
    title:setFilter("nearest", "nearest")
    -- start playing bg1.waV
    bgm = {}
    bgm[1] = love.audio.newSource("assets/bg1.wav", "stream")
    bgm[1]:setLooping(true)
    bgm[1]:play()
    bgm[1]:setVolume(0.5)
end

-- UPDATE

function screens.title.update(dt)
    if love.keyboard.isDown("return") then
        screens.game.load()
        currentScreen = screens.game
    end
end

function screens.title.wheel(x, y)
end

-- DRAW
function screens.title.draw()
    love.graphics.draw(title, 0, 0, 0, love.graphics.getWidth() / title:getWidth(),
        love.graphics.getHeight() / title:getHeight())
end

--- GAME
-- LOAD

function mobileActions()
    if game.mobile then
        love.graphics.setFont(love.graphics.newFont(11))
    end
end

function loadRandomness()
    seed = game.seed or (os.time() + love.math.random())
    love.math.setRandomSeed(seed)
    if reloads > 5 then
        seed = 101
        love.math.setRandomSeed(seed)
    end
end

function loadGrid()
    grid = {}
    grid.width = game.grid.width
    grid.height = game.grid.height
    for i = 1, game.grid.width do
        grid[i] = {}
        for j = 1, game.grid.height do
            grid[i][j] = 0
        end
    end
    availableTiles = game.tiles
    loadedTileInd = 1
    local offsetX = love.math.random() * game.randomSize
    local offsetY = love.math.random() * game.randomSize
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            local noiseValue = love.math.noise(i / game.continentality + offsetX, j / game.continentality + offsetY)
            if noiseValue > game.tiles[1].weight then
                grid[i][j] = 1 -- Dirt
            elseif noiseValue > game.tiles[2].weight then
                grid[i][j] = 2 -- Sand
            else
                grid[i][j] = 0 -- Water
            end
        end
    end
    local offsetX = love.math.random() * 1000
    local offsetY = love.math.random() * 1000
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            local noiseValue = love.math.noise(i / 10 + offsetX, j / 10 + offsetY)
            if noiseValue > game.tiles[3].weight and grid[i][j] == 1 then
                grid[i][j] = 3 -- Stone
            end
        end
    end
    local offsetX = love.math.random() * 1000
    local offsetY = love.math.random() * 1000
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            local noiseValue = love.math.noise(i / 10 + offsetX, j / 10 + offsetY)
            if noiseValue > game.tiles[4].weight and grid[i][j] == 1 then
                grid[i][j] = 4 -- Tree
            end
        end
    end
    local waterCount = 0
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            if grid[i][j] == 0 then
                waterCount = waterCount + 1
            end
        end
    end
    if waterCount > game.grid.width * game.grid.height * game.tiles[0].weight then
        print("Reloading due to too much water")
        reloads = reloads + 1
        love.load()
    end
    local landTiles = {}
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            if grid[i][j] ~= 0 then
                table.insert(landTiles, {i, j})
            end
        end
    end
    local storageTile = landTiles[love.math.random(1, #landTiles)]
    grid[storageTile[1]][storageTile[2]] = 6
    local storageCount = 0
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            if grid[i][j] == 6 then
                storageCount = storageCount + 1
            end
        end
    end
    if storageCount > 1 then
        print("Reloading due to too many storage tiles")
        reloads = reloads + 1
        love.load()
    end

    -- Must have at least 3 distinct tile types in the grid
    local tileTypes = {}
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            if not tileTypes[grid[i][j]] then
                tileTypes[grid[i][j]] = true
            end
        end
    end
    if #tileTypes < 3 then
        print("Reloading due to too few tile types")
        reloads = reloads + 1
        love.load()
    end
end

function loadInputVars()
    mouseHeld = false
    keyHeld = {
        escape = false,
        d = false,
        c = false,
        r = false,
        q = false
    }
    currentCellMouseHeld = {0, 0}
    currentCellMouseHover = {0, 0}
end

function initVars()
    initial = {}
    tile = 0
    clock = 0
    prev = false
    globalclock = 0
    laststone = 0
    cameraOffsetX = 0
    cameraOffsetY = 0
    cameraSpeed = 200
    zoomFactor = 1
    zoomSpeed = 0.3
    lasttouches = {}
    previewShake = {
        duration = 0.5,
        intensity = 5,
        time = 0
    }
    hoverpvShake = {
        duration = 0.5,
        intensity = 5,
        time = 0
    }
    lastOne = -1
end

function screens.game.load()
    initVars()
    mobileActions()
    love.graphics.setDefaultFilter("nearest", "nearest")
    for _, tiles in pairs(game.tiles) do
        if tiles.image then
            tiles.image:setFilter("nearest", "nearest")
        end
    end
    instructions = instructionsM.default
    storage = game.startStorage
    loadRandomness()
    loadGrid()
    loadInputVars()
end

-- UPDATE

function selectNextTile()
    loadedTileInd = loadedTileInd + 1
    if loadedTileInd > (#availableTiles) then
        loadedTileInd = 0
    end
    tile = loadedTileInd
    clock = 2
    prev = true
end

function touchZoom()
    touches = love.touch.getTouches()
    if #touches == 2 then
        local touch1 = touches[1]
        local touch2 = touches[2]
        local x1, y1 = love.touch.getPosition(touch1)
        local x2, y2 = love.touch.getPosition(touch2)
        local lasttouch1 = lasttouches[1]
        local lasttouch2 = lasttouches[2]
        local lx1, ly1 = lasttouch1 and love.touch.getPosition(lasttouch1) or x1,
            lasttouch1 and love.touch.getPosition(lasttouch1) or y1
        local lx2, ly2 = lasttouch2 and love.touch.getPosition(lasttouch2) or x2,
            lasttouch2 and love.touch.getPosition(lasttouch2) or y2
        local dx = x1 - x2
        local dy = y1 - y2
        local ldx = lx1 - lx2
        local ldy = ly1 - ly2
        local dist = math.sqrt(dx * dx + dy * dy)
        local ldist = math.sqrt(ldx * ldx + ldy * ldy)
        if ldist > dist then
            zoomFactor = zoomFactor + zoomSpeed * dt
        elseif ldist < dist then
            zoomFactor = zoomFactor - zoomSpeed * dt
            if zoomFactor < 0.1 then
                zoomFactor = 0.1
            end
        end
    end
end

function timers()
    if previewShake.time > 0 then
        previewShake.time = previewShake.time - gdt
    elseif previewShake.time < 0 then
        previewShake.time = 0
    end
    if hoverpvShake.time > 0 then
        hoverpvShake.time = hoverpvShake.time - gdt
    elseif hoverpvShake.time < 0 then
        hoverpvShake.time = 0
    end
end

function mousePress()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local cell_size = screen_height * zoomFactor / game.grid.height
    local grid_width = cell_size * game.grid.width
    local grid_height = screen_height * zoomFactor
    local grid_x = (screen_width - grid_width) / 2 + cameraOffsetX
    local grid_y = cameraOffsetY
    local mouse_x, mouse_y = love.mouse.getPosition()
    local i = math.floor((mouse_x - grid_x) / cell_size) + 1
    local j = math.floor((mouse_y - grid_y) / cell_size) + 1
    if love.mouse.isDown(1) and not game.cmOpen then
        if not mouseHeld or (currentCellMouseHeld[1] ~= i or currentCellMouseHeld[2] ~= j) then
            if i >= 1 and i <= game.grid.width and j >= 1 and j <= game.grid.height then
                if grid[i][j] > 100 then
                    grid[i][j] = grid[i][j] - 100
                end
                if loadedTileInd == 5 and not (grid[i][j] == 3 or grid[i][j] == 103) then
                    hoverpvShake.time = 0.5
                elseif storage[game.tiles[loadedTileInd].name] > 0 then
                    print(grid[i][j])
                    if loadedTileInd == grid[i][j] then
                        previewShake.time = 0.5
                    elseif (game.tiles[grid[i][j]] or game.tiles[grid[i][j] - 100]).immutable or false then
                        hoverpvShake.time = 0.5
                    else
                        grid[i][j] = loadedTileInd
                        storage[game.tiles[loadedTileInd].name] = storage[game.tiles[loadedTileInd].name] - 1
                    end
                elseif previewShake.time == 0 then
                    previewShake.time = 1.2
                end
            end
            currentCellMouseHeld = {i, j}
        end

        -- Get area of preview tile
        local preview_size = 40
        local preview_x = screen_width - preview_size - 65
        local preview_y = screen_height - preview_size - 25
        local preview_tile_x = preview_x
        local preview_tile_y = preview_y
        local preview_tile_size = 40
        local preview_tile_i = math.floor((mouse_x - preview_tile_x) / preview_tile_size) + 1
        local preview_tile_j = math.floor((mouse_y - preview_tile_y) / preview_tile_size) + 1

        -- If the mouse is pressed on the preview tile, change the value of the preview tile
        if preview_tile_i == 1 and preview_tile_j == 1 then
            if not mouseHeld then
                selectNextTile()
            end
        end

        mouseHeld = true
    elseif (love.mouse.isDown(2) or (love.keyboard.isDown("q") and not keyHeld.q)) and not game.cmOpen then
        if not mouseHeld then
            selectNextTile()
        end
        mouseHeld = true
    else
        if (not mouseHeld or (currentCellMouseHeld[1] ~= i or currentCellMouseHeld[2] ~= j)) and not game.cmOpen then
            if i >= 1 and i <= game.grid.width and j >= 1 and j <= game.grid.height then
                if grid[i][j] < 100 then
                    grid[i][j] = grid[i][j] + 100
                end
            end
            currentCellMouseHover = {i, j}
        end
        mouseHeld = false
    end
end

function mouseHoverGrid()
    for i = 1, grid.width do
        for j = 1, grid.height do
            if grid[i][j] >= 100 and not (currentCellMouseHover[1] == i and currentCellMouseHover[2] == j) then
                grid[i][j] = grid[i][j] - 100
            end
        end
    end
end

function keyPress()
    if love.keyboard.isDown("escape") then
        if not keyHeld.escape then
            love.event.quit()
            keyHeld.escape = true
        end
    else
        keyHeld.escape = false
    end
    if love.keyboard.isDown("d") then
        if not keyHeld.d then
            debugmode = not debugmode
            keyHeld.d = true
            if love.keyboard.isDown("lctrl") then
                debug.debug()
            end
        end
    else
        keyHeld.d = false
    end
    if love.keyboard.isDown("c") then
        if not keyHeld.c then
            game.openCraftingMenu()
            game.cmOpen = not game.cmOpen
            keyHeld.c = true
        end
    else
        keyHeld.c = false
    end
    if love.keyboard.isDown("r") then
        if not keyHeld.r and debugmode then
            screens.game.load()
            keyHeld.r = true
        end
    else
        keyHeld.r = false
    end
    if love.keyboard.isDown("z") then
        cameraOffsetX = 0
        cameraOffsetY = 0
        zoomFactor = 1
    end
    if love.keyboard.isDown("right") then
        cameraOffsetX = cameraOffsetX - cameraSpeed * gdt
    end
    if love.keyboard.isDown("left") then
        cameraOffsetX = cameraOffsetX + cameraSpeed * gdt
    end
    if love.keyboard.isDown("down") then
        cameraOffsetY = cameraOffsetY - cameraSpeed * gdt
    end
    if love.keyboard.isDown("up") then
        cameraOffsetY = cameraOffsetY + cameraSpeed * gdt
    end
    if love.keyboard.isDown("-") then
        zoomFactor = zoomFactor - zoomSpeed * gdt
        if zoomFactor < 0.1 then
            zoomFactor = 0.1
        end
    end
    if love.keyboard.isDown("=") then
        zoomFactor = zoomFactor + zoomSpeed * gdt
    end
end

function screens.game.update(dt)
    gdt = dt
    touchZoom()
    timers()
    globalclock = globalclock + dt
    for item = 0, #game.tiles do
        if game.tiles[item].func then
            game.tiles[item].func(globalclock, grid, storage)
        end
    end
    mousePress()
    mouseHoverGrid()
    keyPress()
end

function screens.game.wheel(x, y)
    if y > 0 then
        zoomFactor = zoomFactor + (zoomSpeed - 0.2)
    elseif y < 0 then
        zoomFactor = zoomFactor - (zoomSpeed - 0.2)
        if zoomFactor < 0.1 then
            zoomFactor = 0.1
        end
    end
end

-- DRAW

function textDraw()
    todraw = instructions

    if debugmode and not todraw[9] then
        table.insert(todraw, "Debug mode enabled.\nPress 'R' to reload the game's grid.")
    elseif not debugmode and todraw[9] then
        table.remove(todraw, 9)
    end

    instructionsM.draw(todraw)
    instructionsM.drawStorage(storage)
end

function drawGrid()
    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()
    local cell_size = screen_height * zoomFactor / game.grid.height
    local grid_width = cell_size * game.grid.width
    local grid_height = screen_height * zoomFactor
    local grid_x = (screen_width - grid_width) / 2 + cameraOffsetX
    local grid_y = cameraOffsetY
    for i = 1, game.grid.width do
        for j = 1, game.grid.height do
            local tile = grid[i][j]
            local texture = tileMappings[tile] or waterimage
            if tile >= 100 then
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            texture = tileMappings[tile % 100] or waterimage
            love.graphics.draw(texture, grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, 0,
                cell_size / texture:getWidth(), cell_size / texture:getHeight())
            love.graphics.setColor(1, 1, 1)
            local text = tostring(tile)
            local text_width = love.graphics.getFont():getWidth(text)
            local text_height = love.graphics.getFont():getHeight(text)
            local text_x = grid_x + (i - 1) * cell_size + (cell_size - text_width) / 2
            local text_y = grid_y + (j - 1) * cell_size + (cell_size - text_height) / 2
            if debugmode then
                love.graphics.setColor(0.6, 0, 0)
                love.graphics.print(text, text_x, text_y)
                love.graphics.setColor(1, 1, 1)
            end
        end
    end
end

function drawPreview()
    local preview_size = 40
    local preview_x = screen_width - preview_size - 65
    local preview_y = screen_height - preview_size - 25
    if previewShake.time > 0 then
        local shake_offset_x = love.math.random(-previewShake.intensity, previewShake.intensity)
        local shake_offset_y = love.math.random(-previewShake.intensity, previewShake.intensity)
        preview_x = preview_x + shake_offset_x
        preview_y = preview_y + shake_offset_y
        love.graphics.setColor(1, 0.3, 0.3)
    end
    local tile = tileMappings[loadedTileInd]
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
    if debugmode then
        text_x =
            preview_x + tile_width / 2 - love.graphics.getFont():getWidth(string.format("%.1f", previewShake.time)) / 2
        text_y = preview_y + tile_height / 2 - love.graphics.getFont():getHeight() / 2
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(string.format("%.1f", previewShake.time), text_x, text_y)
    end
    love.graphics.setColor(1, 1, 1)
end

function drawHoverTile()
    local hoverpv_size = 20
    local hoverpv_x = screen_width - hoverpv_size - 65
    local hoverpv_y = screen_height - hoverpv_size - 65
    if hoverpvShake.time > 0 then
        local shake_offset_x = love.math.random(-hoverpvShake.intensity, hoverpvShake.intensity)
        local shake_offset_y = love.math.random(-hoverpvShake.intensity, hoverpvShake.intensity)
        hoverpv_x = hoverpv_x + shake_offset_x
        hoverpv_y = hoverpv_y + shake_offset_y
        love.graphics.setColor(1, 0.3, 0.3)
    end
    local tilehv = tileMappings[-1]
    local tileno = -1
    for i = 1, grid.width do
        for j = 1, grid.height do
            if grid[i][j] >= 100 then
                tilehv = tileMappings[grid[i][j] - 100]
                tileno = grid[i][j] - 100
            end
        end
    end
    if tileno == -1 then
        tilehv = tileMappings[lastOne] or game.tiles[-1].image
        tileno = lastOne or -1
    end
    local scale_x = hoverpv_size / tilehv:getWidth()
    local scale_y = hoverpv_size / tilehv:getHeight()
    local tilehv_width = tilehv:getWidth() * scale_x
    local tilehv_height = tilehv:getHeight() * scale_y
    local circle_x = hoverpv_x + tilehv_width / 2
    local circle_y = hoverpv_y + tilehv_height / 2
    love.graphics.draw(tilehv, hoverpv_x, hoverpv_y, 0, scale_x, scale_y)
    love.graphics.rectangle("line", hoverpv_x, hoverpv_y, tilehv_width, tilehv_height)
    local tilehvName = tileNames[tileno] or tostring(tileno)
    love.graphics.print(tilehvName, hoverpv_x + tilehv_width + 10,
        hoverpv_y + tilehv_height / 2 - love.graphics.getFont():getHeight() / 2)
    lastOne = tileno
    if debugmode then
        text_x = hoverpv_x + tilehv_width / 2 -
                     love.graphics.getFont():getWidth(string.format("%.1f", hoverpvShake.time)) / 2
        text_y = hoverpv_y + tilehv_height / 2 - love.graphics.getFont():getHeight() / 2
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(string.format("%.1f", hoverpvShake.time), text_x, text_y)
    end
end

function drawFPS()
    if game.showFPS then
        local fps = love.timer.getFPS()
        love.graphics.print("FPS: " .. fps, screen_width - 70, 10)
    end
end

function tileNameToID(name)
    for i = 0, #game.tiles do
        if game.tiles[i].name == name then
            return i
        end
    end
    return -1
end

function drawCraftingMenu()
    if game.cmOpen then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", screen_width / 4, screen_height / 4, screen_width / 2, screen_height / 2)
        -- Show storage at top and crafting menu at bottom
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Storage", screen_width / 4 + 10, screen_height / 4 + 10)
        local i = 0
        for item, count in pairs(storage) do
            i = i + 1
            love.graphics.setColor(1, 1, 1)
            -- love.graphics.setNewFont("assets/Minecraft.ttf", 15)
            love.graphics.draw(game.tiles[tileNameToID(item)].image or game.tiles[-1].image, screen_width / 4 + 10,
                screen_height / 4 + 10 + i * 20)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(item .. ": " .. count, screen_width / 4 + 40, screen_height / 4 + 10 + i * 20)
            love.graphics.setFont(love.graphics.newFont(12))
        end
        love.graphics.print("Crafting Menu", screen_width / 4 + 10, screen_height / 2 + 10)
        love.graphics.setColor(0.7, 0, 0)
        love.graphics.print("In Development", screen_width / 4 + 10, screen_height / 2 + 30)
        love.graphics.setColor(1, 1, 1)
    end
end

function screens.game.draw()
    textDraw()
    -- tileMappings = game.tileMap
    tileMappings = {}
    for i = 0, #game.tiles do
        tileMappings[i] = game.tiles[i].image
    end
    -- tileNames = game.invMap
    tileNames = {}
    for i = 0, #game.tiles do
        tileNames[i] = game.tiles[i].name
    end
    drawGrid()
    drawPreview()
    love.graphics.setColor(1, 1, 1)
    drawHoverTile()
    love.graphics.setColor(1, 1, 1)
    drawFPS()
    drawCraftingMenu()
end

function love.load()
    currentScreen = screens.title
    currentScreen.load()
end

function love.update(dt)
    currentScreen.update(dt)
end

function love.wheelmoved(x, y)
    currentScreen.wheel(x, y)
end

function love.draw()
    currentScreen.draw()
end
