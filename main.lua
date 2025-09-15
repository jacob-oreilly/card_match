local buttons = {}
local font = nil
cardsLeftInPlay = 0


function love.load()
    gameState = 1

    love.window.setMode(800, 600, { resizable = true, vsync = 0, minwidth = 400, minheight = 300 })
    -- love.graphics.setBackgroundColor(1, 1, 1)
    screenWidth, screenHeight = love.graphics.getDimensions()
    font = love.graphics.newFont(32)

    cardDisplayDuration = 1
    timer = 0

    deck = {}
    deck.sprites = {}
    deck.spriteSheet = love.graphics.newImage("assets/match_cards.png")
    deck.card_cover = love.graphics.newImage("assets/card_cover.png")
    shuffledDeck = {}
    selectedCards = {}
    spriteWidth = 64
    spriteHeight = 96
    xCardOffset = 1.3
    yCardOffset = 1.2
    isCorrectSelection = false
    fly = {}

    ---- SETUP MENU ----
    table.insert(buttons, newButton(
        "Start",
        function()
            gameState = 2
            print("start")
        end
    ))
    table.insert(buttons, newButton(
        "Quit",
        function()
            love.event.quit(0)
        end
    ))

    -- add spritesheet as quad
    for i = 0, 4 do
        deck.sprites[i + 1] = love.graphics.newQuad(i * spriteWidth, 0, spriteWidth, spriteHeight,
            deck.spriteSheet:getWidth(), deck.spriteSheet:getHeight())
    end

    createUnshuffledDeck()

    -- Shuffling the deck and insert into new deck.
    createShuffledDeck()
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
        ---- DRAW MENU ----
        drawMenu()
    elseif gameState == 2 then
        ---- DRAW GAME ----
        drawMatchingGame()
    elseif gameState == 3 then
        drawFlyTask()
    end
end

function drawMenu()
    local buttonWidth = screenWidth * (1 / 3)
    local buttonHeight = 65
    local total_height = (buttonHeight + 16) * #buttons
    local yIndex = 0
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    for i, button in ipairs(buttons) do
        button.last = button.now

        local buttonX = (screenWidth * 0.5) - (buttonWidth * 0.5)
        local buttonY = (screenHeight * 0.5) - (total_height * 0.5) + yIndex

        local color = { 0.4, 0.4, 0.5, 1.0 }

        local buttonIsHover = mouseX > buttonX and mouseX < buttonX + buttonWidth and
            mouseY > buttonY and mouseY < buttonY + buttonHeight
        if buttonIsHover then
            color = { 0.8, 0.8, 0.9, 1.0 }
        end

        button.now = love.mouse.isDown(1)
        if button.now and not button.last and buttonIsHover then
            button.fn()
        end

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
        yIndex = yIndex + (buttonHeight + 16)

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(font)
        local textW = font:getWidth(button.label)
        local textH = font:getHeight(button.label)
        love.graphics.print(button.label, font, (screenWidth * 0.5) - textW * 0.5, buttonY + textH * 0.5)
    end
end

function drawMatchingGame()
    --Drawing cards to the screen from the shuffledDeck. We are also drawing a
    --flipped over image in the same place when card hasn't been selected.
    for cardIndex, card in ipairs(shuffledDeck) do
        -- print("Card_id: "..card.card_id)

        if columnIndex == 4 then
            rowIndex = rowIndex + 1
            columnIndex = 0
        end
        local xPosition = (columnIndex) * 64 * xCardOffset
        local yPosition = (rowIndex) * 98 * yCardOffset


        love.graphics.setColor(1, 1, 1)
        --If None selected and none right we display card_cover
        if card.inPlay then
            love.graphics.draw(deck.card_cover, xPosition, yPosition)
        else
            love.graphics.draw(deck.spriteSheet, deck.sprites[card.card_id], xPosition, yPosition)
        end

        columnIndex = columnIndex + 1
        -- Temp printing text for development. Might use hover mouse for some hover effects eventually.
        if hoverMouseX == columnIndex and hoverMouseY == rowIndex then
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("mouse over: " .. card.task .. " with card_id: " .. card.card_id, 350, 0)
            love.graphics.print('hoverMouseX: ' .. hoverMouseX .. ' hoverMouseY: ' .. hoverMouseY, 350, 15)
            love.graphics.print('columnIndex: ' .. columnIndex .. ' rowIndex: ' .. rowIndex, 350, 35)
        end
    end

    -- Temp printing text for development.
    love.graphics.setColor(0, 0, 0)
    if isCorrectSelection then
        love.graphics.print("Correct Selection!", 350, 55)
    else
        love.graphics.print("Incorrect Selection.... :(", 350, 55)
    end
end

function drawFlyTask()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", fly.x, fly.y, fly.width, fly.height)
    love.graphics.setFont(font)
    local text = "fly game"
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    love.graphics.print(text, font, (screenWidth * 0.5) - textW * 0.5, textH * 0.5)
end

function hasHitFly()
    local flyIsHover = love.mouse.getX() > fly.x and love.mouse.getX() < fly.x + fly.width and
                        love.mouse.getY() > fly.y and love.mouse.getY() < fly.y + fly.height
    if flyIsHover and love.mouse.isDown(1) then
        gameState = 2
    end
end

function love.update(dt)
    hoverMouseX = math.floor(love.mouse.getX() / (spriteWidth * xCardOffset)) + 1
    hoverMouseY = math.floor(love.mouse.getY() / (spriteHeight * yCardOffset))

    if selectedCards ~= nil and #selectedCards == 2 then
        if isCorrectSelection then
            selectedCards[1].inPlay = false
            selectedCards[2].inPlay = false
            selectedCards = {}
            cardsLeftInPlay = cardsLeftInPlay - 2
        else
            timer = timer + dt
            if timer >= cardDisplayDuration then
                selectedCards[1].inPlay = true
                selectedCards[2].inPlay = true
                selectedCards = {}
                timer = 0
            end
        end
    end

    if cardsLeftInPlay == 0 and gameState == 2 then
        gameState = 1
        createUnshuffledDeck()
        createShuffledDeck()
    end

    if gameState == 3 then
        hasHitFly()
    end
end

function love.mousereleased(mouseX, mouseY)
    if gameState == 2 then
        if timer == 0 then
            selectedX = math.floor(mouseX / (spriteWidth * xCardOffset)) + 1
            selectedY = math.floor(mouseY / (spriteHeight * yCardOffset))
            local selectedVector = { selectedX, selectedY }
            local selectedCard = getSelectedCard(selectedVector)
            if selectedCard ~= nil and selectedCard.inPlay then
                table.insert(selectedCards, selectedCard)
                selectedCard.inPlay = false
                print(selectedCard.task)
            end
            compareMatch()
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

function createUnshuffledDeck()
    -- Render 4 of each type from the sprite sheet and enter into a table with fields.
    for card_id, task in ipairs({ 'keyboard', 'fly', 'asteroids', 'hockey', 'ghost' }) do
        for index = 1, 4 do
            table.insert(deck, { task = task, index = index, card_id = card_id })
        end
    end
end

function createShuffledDeck()
    local rowCount = 0
    local colCount = 1
    shuffledDeck = {}
    for i = 1, #deck do
        local randIndex = love.math.random(#deck)
        table.insert(shuffledDeck,
            { task = deck[randIndex].task, card_id = deck[randIndex].card_id, index = i, vecPos = { colCount, rowCount }, inPlay = true })
        table.remove(deck, randIndex)

        --sets column index back to 1 and increases the row index for the new row.
        if colCount == 4 then
            colCount = 1
            rowCount = rowCount + 1
        else
            colCount = colCount + 1
        end
    end
    -- Set number of cards in play to start with --
    cardsLeftInPlay = #shuffledDeck
    print("Cards left in play: " .. cardsLeftInPlay)
    print("shuffledDeck: " .. #shuffledDeck)
end

function compareMatch()
    if #selectedCards == 2 then
        if selectedCards[1].card_id == selectedCards[2].card_id then
            isCorrectSelection = true
        else
            startTask()
            isCorrectSelection = false
        end
    end
end

function startTask()
    if selectedCards[1].task == "fly" then
        fly.x = screenWidth * 0.5
        fly.y = screenHeight * 0.7
        fly.width = 10
        fly.height = 10
        gameState = 3
    end
end

function compareVector(a, b)
    return a[1] == b[1] and a[2] == b[2]
end

function getSelectedCard(selectedVector)
    for index, card in ipairs(shuffledDeck) do
        local isSelectedCard = compareVector(card.vecPos, selectedVector)
        if isSelectedCard then
            return card
        end
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
