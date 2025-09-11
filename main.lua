function love.load()
    gameState = 1


    love.window.setMode(800, 600, { resizable = true, vsync = 0, minwidth = 400, minheight = 300 })
    love.graphics.setBackgroundColor(1, 1, 1)
    screenWidth, screenHeight = love.graphics.getDimensions()

    cardDisplayDuration = 2
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


    -- add spritesheet as quad
    for i = 0, 4 do
        deck.sprites[i + 1] = love.graphics.newQuad(i * spriteWidth, 0, spriteWidth, spriteHeight,
            deck.spriteSheet:getWidth(), deck.spriteSheet:getHeight())
    end

    -- Render 4 of each type from the sprite sheet and enter into a table with fields.
    for card_id, task in ipairs({ 'keyboard', 'fly', 'asteroids', 'hockey', 'ghost' }) do
        for index = 1, 4 do
            table.insert(deck, { task = task, index = index, card_id = card_id })
        end
    end

    -- Shuffling the deck and insert into new deck.
    local rowCount = 0
    local colCount = 1
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
end

function love.draw()
    local xPosition = 0
    local yPosition = 0
    columnIndex = 0
    rowIndex = 0

    if gameState == 1 then
        love.graphics.setBackgroundColor(95, 148, 228)
        love.graphics.setColor(0, 0, 0)
        local menuWidth = 450
        local menuHeight = 300
        local buttonWidth = 100
        local buttonHeight = 65
        local menuX = (screenWidth / 2) - (menuWidth / 2)
        local menuY = (screenHeight / 2) - (menuHeight / 2)
        local buttonX = (buttonWidth / 2) - (menuWidth / 2)
        local buttonY = (buttonHeight / 2) - (menuHeight / 2)

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", menuX, menuY, menuWidth, menuHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
    end
    if gameState == 2 then
        ---- DRAW GAME ----
        --Drawing cards to the screen from the shuffledDeck. We are also drawing a
        --flipped over image in the same place when card hasn't been selected.
        for cardIndex, card in ipairs(shuffledDeck) do
            -- print("Card_id: "..card.card_id)

            if columnIndex == 4 then
                rowIndex = rowIndex + 1
                columnIndex = 0
            end
            xPosition = (columnIndex) * 64 * xCardOffset
            yPosition = (rowIndex) * 98 * yCardOffset


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
end

function love.update(dt)
    hoverMouseX = math.floor(love.mouse.getX() / (spriteWidth * xCardOffset)) + 1
    hoverMouseY = math.floor(love.mouse.getY() / (spriteHeight * yCardOffset))

    if selectedCards ~= nil and #selectedCards == 2 then
        if isCorrectSelection then
            selectedCards[1].inPlay = false
            selectedCards[2].inPlay = false
            selectedCards = {}
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
        love.event.quit()
    end
end

function compareMatch()
    if #selectedCards == 2 then
        if selectedCards[1].card_id == selectedCards[2].card_id then
            -- Need to figure out how to remove from deck and not re render the cards in different positions on the screen.
            -- table.remove(shuffledDeck, selectedCards[1].index)
            -- table.remove(shuffledDeck, selectedCards[2].index)
            isCorrectSelection = true
            -- selectedCards[1].inPlay = false
            -- selectedCards[2].inPlay = false
        else
            isCorrectSelection = false
            -- selectedCards[1].inPlay = true
            -- selectedCards[2].inPlay = true
        end
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
