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
    return storageGrid
end
