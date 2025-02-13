instructionsM = {}

instructionsM.default = {"Left click to place a tile", "Right click or 'Q' to cycle through tiles",
                         "- and + or scroll to zoom", "Arrow keys to pan", "'Z' to reset camera",
                         "Press 'C' to bring up the crafting menu", "Press 'Esc' to quit",
                         "Press 'D' to toggle debug mode"}

function instructionsM.test()
    print("InstructionsM loaded")
end

function instructionsM.draw(text)
    for i, instruction in ipairs(text) do
        if i == 9 then
            love.graphics.setColor(1, 0, 0)
        end
        love.graphics.print(instruction, 10, 10 + 20 * i)
        if i == 9 then
            love.graphics.setColor(1, 1, 1)
        end
    end
end

function instructionsM.drawStorage(storage)
    love.graphics.print("Storage", 10, 230)
    local y = 250
    for item, count in pairs(storage) do
        love.graphics.print(item .. ": " .. count, 10, y)
        y = y + 20
    end
end
