instructionsM = {}

instructionsM.default = {"Left click to place a tile", "Right click to cycle through tiles",
                         "Press 'C' to bring up the crafting menu", "Press 'D' to toggle debug mode",
                         "Press 'Esc' to quit"}

function instructionsM.test()
    print("InstructionsM loaded")
end

function instructionsM.draw(text)
    for i, instruction in ipairs(text) do
        if i == 5 then
            love.graphics.setColor(1, 0, 0)
        end
        love.graphics.print(instruction, 10, 10 + 20 * i)
        if i == 5 then
            love.graphics.setColor(1, 1, 1)
        end
    end
end

function instructionsM.drawInventory(inventory)
    love.graphics.print("Inventory", 10, 200)
    local y = 220
    for item, count in pairs(inventory) do
        love.graphics.print(item .. ": " .. count, 10, y)
        y = y + 20
    end
end
