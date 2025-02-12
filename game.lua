require "images"

game = {}

game.showFPS = true

function game.test()
    print("Game loaded")
end

function game.openCraftingMenu(text)

end

game.grid = {}
game.grid.width = 30
game.grid.height = 30

game.tileList = {0, 1, 2, 3, 4, 5}
game.tileMap = {
    [0] = waterimage, -- Water
    [1] = landimage, -- Land
    [2] = beachimage, -- Beach
    [3] = stoneimage, -- Stone
    [4] = forestimage, -- Forest
    [5] = quarryimage -- Quarry
}

game.startInventory = {
    Stone = 0,
    Quarries = 1
}

game.randomSize = 10000
game.continentality = 40
-- game.seed = 12345
game.weight = {
    land = 0.5,
    beach = 0.35,
    stone = 0.8,
    forest = 0.6
}
