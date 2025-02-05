function love.load()
    love.math.setRandomSeed(os.time()) -- Seed the random number generator with the current time

    grid = {}
    grid.width = 30
    grid.height = 30
    -- Create a 10x10 grid
    for i = 1, grid.width do
        grid[i] = {}
        for j = 1, grid.height do
            grid[i][j] = 0
        end
    end

    mouseHeld = false
    currentCellMouseHeld = {0, 0}
    currentCellMouseHover = {0, 0}

    -- Use perlin noise to generate a random grid
    local offsetX = love.math.random() * 1000
    local offsetY = love.math.random() * 1000
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
end

function love.update(dt)
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
                grid[i][j] = 1
            end
            currentCellMouseHeld = {i, j}
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
end

function love.draw()
    -- Draw the grid screen height by screen height in the center of the screen
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local grid_size = screen_height
    local cell_size = grid_size / grid.width
    local grid_x = (screen_width - grid_size) / 2
    local grid_y = (screen_height - grid_size) / 2
    for i = 1, grid.width do
        for j = 1, grid.height do
            if grid[i][j] == 0 then
                love.graphics.setColor(0, 0, 1) -- Water
                love.graphics.rectangle("fill", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
                love.graphics.setColor(0, 0, 0)
            elseif grid[i][j] == 1 then
                love.graphics.setColor(0, 0.7, 0) -- Land
                love.graphics.rectangle("fill", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
                love.graphics.setColor(0, 0, 0)
            elseif grid[i][j] == 2 then
                love.graphics.setColor(0.9, 0.8, 0.5) -- Beach
                love.graphics.rectangle("fill", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
                love.graphics.setColor(0, 0, 0)
            elseif grid[i][j] == 100 then
                love.graphics.setColor(0.3, 0.3, 1)
                love.graphics.rectangle("fill", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
                love.graphics.setColor(0, 0, 0)
            elseif grid[i][j] == 101 then
                love.graphics.setColor(0.3, 0.8, 0.3)
                love.graphics.rectangle("fill", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
                love.graphics.setColor(0, 0, 0)
            elseif grid[i][j] == 102 then
                love.graphics.setColor(1, 0.9, 0.6)
                love.graphics.rectangle("fill", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
                love.graphics.setColor(0, 0, 0)
            end

            -- Get the width and height of the text
            local text = tostring(grid[i][j])
            local text_width = love.graphics.getFont():getWidth(text)
            local text_height = love.graphics.getFont():getHeight(text)

            -- Calculate the position to center the text
            local text_x = grid_x + (i - 1) * cell_size + (cell_size - text_width) / 2
            local text_y = grid_y + (j - 1) * cell_size + (cell_size - text_height) / 2

            love.graphics.print(text, text_x, text_y)
        end
    end
end
