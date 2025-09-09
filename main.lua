function love.load()
    love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
    love.graphics.setBackgroundColor(1, 1, 1)

    deck = {}
    deck.sprites = {}
    deck.spriteSheet = love.graphics.newImage("assets/match_cards.png")
    shuffledDeck = {}
    selectedCards = {}
    spriteWidth = 64
    spriteHeight = 96
    xCardOffset = 1.3
    yCardOffset = 1.2
    isCorrectSelection = false
    

    -- Example for a row of 4 sprites
    for i = 0, 4 do
        deck.sprites[i + 1] = love.graphics.newQuad(i * spriteWidth, 0, spriteWidth, spriteHeight,
            deck.spriteSheet:getWidth(), deck.spriteSheet:getHeight())
    end
    for card_id, task in ipairs({ 'keyboard', 'fly', 'asteroids', 'hockey', 'ghost' }) do
        for index = 1, 4 do
            table.insert(deck, { task = task, index = index, card_id = card_id })
        end
    end

    
    local rowCount = 0
    local colCount = 1
    for i = 1, #deck do
        local randIndex = love.math.random(#deck)
        table.insert(shuffledDeck, {task = deck[randIndex].task, card_id = deck[randIndex].card_id, index = i, vecPos = {colCount, rowCount}})
        table.remove(deck, randIndex)

        --sets column index back to 1 and increases the row index for the new row.
        if colCount == 4 then
            colCount = 1
            rowCount = rowCount + 1
        else
            colCount = colCount + 1
        end
    end
    for index, card in ipairs(deck) do
        print('task: ' .. card.task .. ', card_id: ' .. card.card_id)
    end
    print("Deck Count: "..#deck)
    print('Total number of cards in deck: ' .. #deck)
end

function love.draw()
    local xPosition = 0
    local yPosition = 0
    columnIndex = 0
    rowIndex = 0
    for cardIndex, card in ipairs(shuffledDeck) do
        -- print("Card_id: "..card.card_id)
        
        if columnIndex == 4 then
            rowIndex = rowIndex + 1
            columnIndex = 0
        end
        xPosition = (columnIndex) * 64 * xCardOffset
        yPosition = (rowIndex) * 98 * yCardOffset

       
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(deck.spriteSheet, deck.sprites[card.card_id],  xPosition, yPosition)
        columnIndex = columnIndex + 1

        if hoverMouseX == columnIndex and hoverMouseY == rowIndex then
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("mouse over: "..card.task.." with card_id: "..card.card_id, 350, 0)
            love.graphics.print('hoverMouseX: '..hoverMouseX..' hoverMouseY: '..hoverMouseY, 350, 15)
            love.graphics.print('columnIndex: '..columnIndex..' rowIndex: '..rowIndex, 350, 35)
        end
        
        
        -- print("-----------------------")
        -- print("card: "..card.task)
        -- print("xPosition: "..xPosition)
        -- print("yPosition: "..yPosition)
        -- print("columnIndex: "..columnIndex)
        -- print("rowIndex: "..rowIndex)
        -- print("card_id: "..card.card_id)
    end
    love.graphics.setColor(0, 0, 0)
    if isCorrectSelection then
        love.graphics.print("Correct Selection!", 350, 55)
    else
        love.graphics.print("Incorrect Selection.... :(", 350, 55)
    end
    -- love.graphics.setColor(0, 0, 0)
    -- love.graphics.print('selected x: '..selectedX..' selected y: '..selectedY)
end

function love.update(dt)
    hoverMouseX = math.floor(love.mouse.getX() / (spriteWidth * xCardOffset)) + 1
    hoverMouseY = math.floor(love.mouse.getY() / (spriteHeight * yCardOffset))
    
end

function love.mousereleased(mouseX, mouseY)
    selectedX = math.floor(mouseX / (spriteWidth * xCardOffset)) + 1
    selectedY = math.floor(mouseY / (spriteHeight * yCardOffset))
    local selectedVector = {selectedX, selectedY}
    local selectedCard = getSelectedCard(selectedVector)
    if selectedCard ~= nil then
        table.insert(selectedCards, selectedCard)
        print(selectedCard.task)
    end
    compareMatch()
end

function compareMatch()
    
    if #selectedCards == 2 then
        if selectedCards[1].card_id == selectedCards[2].card_id then
            -- Need to figure out how to remove from deck and not re render the cards in different positions on the screen.
            -- table.remove(shuffledDeck, selectedCards[1].index)
            -- table.remove(shuffledDeck, selectedCards[2].index)
            isCorrectSelection = true
        else
            isCorrectSelection = false
        end
        selectedCards = {}
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