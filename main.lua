function love.load()
    grid = {}
    grid.width = 10
    grid.height = 10
    -- Create a 10x10 grid
    for i = 1, grid.width do
        grid[i] = {}
        for j = 1, grid.height do
            grid[i][j] = 0
        end
    end

    mouseHeld = false
end

function love.update(dt)
    -- If the mouse is pressed, change the value of the cell under the mouse and invert colors
    if love.mouse.isDown(1) then
        if not mouseHeld then
            local screen_width = love.graphics.getWidth()
            local screen_height = love.graphics.getHeight()
            local grid_size = screen_height
            local cell_size = grid_size / 10
            local grid_x = (screen_width - grid_size) / 2
            local grid_y = (screen_height - grid_size) / 2
            local mouse_x, mouse_y = love.mouse.getPosition()
            local i = math.floor((mouse_x - grid_x) / cell_size) + 1
            local j = math.floor((mouse_y - grid_y) / cell_size) + 1
            if i >= 1 and i <= 10 and j >= 1 and j <= 10 then
                grid[i][j] = 1 - grid[i][j]
            end
        end
        mouseHeld = true
    else
        mouseHeld = false
    end
end

function love.draw()
    -- Draw the grid screen height by screen height in the center of the screen
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local grid_size = screen_height
    local cell_size = grid_size / 10
    local grid_x = (screen_width - grid_size) / 2
    local grid_y = (screen_height - grid_size) / 2
    for i = 1, grid.width do
        for j = 1, grid.height do
            if grid[i][j] == 0 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                    cell_size)
            else
                love.graphics.setColor(0.8, 0, 0)
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
