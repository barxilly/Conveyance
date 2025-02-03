function love.load()
    grid = {}
    -- Create a 10x10 grid
    for i = 1, 10 do
        grid[i] = {}
        for j = 1, 10 do
            grid[i][j] = 0
        end
    end
end

function love.update(dt)
    for i = 1, 10 do
        for j = 1, 10 do
            if grid[i][j] == 0 then
                grid[i][j] = 1
            else
                grid[i][j] = grid[i][j] + 1
            end
        end
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
    for i = 1, 10 do
        for j = 1, 10 do
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", grid_x + (i - 1) * cell_size, grid_y + (j - 1) * cell_size, cell_size,
                cell_size)

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
