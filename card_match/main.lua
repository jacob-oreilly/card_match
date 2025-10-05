-- Add path to all other Scripts:
package.path = "modules/?.lua;" .. package.path
local fly = require("modules/fly")
local menu = require("modules/menu")
local matchGame = require("modules/matchGame")
local asteroids = require("modules/asteroids")
-- local buttons = {}
local font = nil
cardsLeftInPlay = 0


function love.load()
    gameState = 4

    love.window.setMode(800, 600, { resizable = true, vsync = 0, minwidth = 400, minheight = 300 })
    love.mouse.setGrabbed(true)
    -- love.graphics.setBackgroundColor(1, 1, 1)
    screenWidth, screenHeight = love.graphics.getDimensions()
    font = love.graphics.newFont(32)
    
    sceneTransitionDuration = 1
    timer = 0

    matchGame.setupMatchGame()

    menu.setupMenu()
end

------------------------
---- DRAW FUNCTIONS ----
------------------------

function love.draw()
    local xPosition = 0
    local yPosition = 0
    columnIndex = 0
    rowIndex = 0

    if gameState == 1 then
        menu.drawMenu(font)
    elseif gameState == 2 then
        matchGame.drawMatchingGame()
    elseif gameState == 3 then
        fly.drawFlyTask(font)
    elseif gameState == 4 then
        asteroids.drawAsteroidsTask(font)
    end
end

function love.update(dt)
    hoverMouseX = math.floor(love.mouse.getX() / (matchGame.spriteWidth * matchGame.xCardOffset)) + 1
    hoverMouseY = math.floor(love.mouse.getY() / (matchGame.spriteHeight * matchGame.yCardOffset))

    if matchGame.selectedCards ~= nil and #matchGame.selectedCards == 2 then
        if matchGame.isCorrectSelection then
            matchGame.selectedCards[1].inPlay = false
            matchGame.selectedCards[2].inPlay = false
            matchGame.selectedCards = {}
            cardsLeftInPlay = cardsLeftInPlay - 2
        else
            timer = timer + dt
            if timer >= matchGame.cardDisplayDuration then
                matchGame.selectedCards[1].inPlay = true
                matchGame.selectedCards[2].inPlay = true
                matchGame.selectedCards = {}
                timer = 0
                matchGame.startTask = false
            end
        end
    end

    if cardsLeftInPlay == 0 and gameState == 2 then
        gameState = 1
        matchGame.createUnshuffledDeck()
        matchGame.createShuffledDeck()
    end

    if gameState == 3 then
        local isTaskOver = fly.update(dt)
        if isTaskOver then
            matchGame.startTask = false
        end
    end
end

function love.mousereleased(mouseX, mouseY)
    if gameState == 2 then
        if timer == 0 then
            selectedX = math.floor(mouseX / (matchGame.spriteWidth * matchGame.xCardOffset)) + 1
            selectedY = math.floor(mouseY / (matchGame.spriteHeight * matchGame.yCardOffset))
            local selectedVector = { selectedX, selectedY }
            local selectedCard = matchGame.getSelectedCard(selectedVector)
            if selectedCard ~= nil and selectedCard.inPlay then
                table.insert(matchGame.selectedCards, selectedCard)
                selectedCard.inPlay = false
                print(selectedCard.task)
            end
            matchGame.compareMatch()
            print("start task: ", matchGame.startTask)
            if matchGame.startTask then
                print("start task")
                startTask()
            end
        end
    end
end

function love.keyreleased(key)
    print("key pressed: " .. key)
    if key == "return" then
        gameState = 2
    elseif key == "escape" then
        gameState = 1
    end
end

function startTask()
    if matchGame.selectedCards[1].task == "fly" then
        fly.x = screenWidth * 0.5
        fly.y = screenHeight * 0.7
        fly.width = 10
        fly.height = 10
        gameState = 3
    elseif matchGame.selectedCards[1].task == "asteroids" then
        asteroids.x = screenWidth * 0.5
        asteroids.y = screenHeight * 0.7
        asteroids.vertices = {100,100, 200,100, 150,200}
    end
end

function newButton(label, fn)
    print(label)
    return {
        label = label,
        fn = fn,
        now = false,
        last = false
    }
end
