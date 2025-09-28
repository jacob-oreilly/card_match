local matchGame = {}

function matchGame.setupMatchGame() 
    matchGame.cardDisplayDuration = 1
    matchGame.shuffledDeck = {}
    matchGame.selectedCards = {}
    matchGame.spriteWidth = 64
    matchGame.spriteHeight = 96
    matchGame.xCardOffset = 1.3
    matchGame.yCardOffset = 1.2
    matchGame.isCorrectSelection = false
    matchGame.startTask = false
    matchGame.deck = {}
    matchGame.deck.sprites = {}
    matchGame.deck.spriteSheet = love.graphics.newImage("/assets/match_cards.png")
    matchGame.deck.card_cover = love.graphics.newImage("/assets/card_cover.png")

    -- add spritesheet as quad
    for i = 0, 4 do
        matchGame.deck.sprites[i + 1] = love.graphics.newQuad(i * matchGame.spriteWidth, 0, matchGame.spriteWidth, matchGame.spriteHeight,
            matchGame.deck.spriteSheet:getWidth(), matchGame.deck.spriteSheet:getHeight())
    end

    matchGame.createUnshuffledDeck()

    -- Shuffling the deck and insert into new deck.
    matchGame.createShuffledDeck()
end

function matchGame.createUnshuffledDeck()
    -- Render 4 of each type from the sprite sheet and enter into a table with fields.
    for card_id, task in ipairs({ 'keyboard', 'fly', 'asteroids', 'hockey', 'ghost' }) do
        for index = 1, 4 do
            table.insert(matchGame.deck, { task = task, index = index, card_id = card_id })
        end
    end
end

function matchGame.createShuffledDeck()
    local rowCount = 0
    local colCount = 1
    matchGame.shuffledDeck = {}
    for i = 1, #matchGame.deck do
        local randIndex = love.math.random(#matchGame.deck)
        table.insert(matchGame.shuffledDeck,
            { task = matchGame.deck[randIndex].task, card_id = matchGame.deck[randIndex].card_id, index = i, vecPos = { colCount, rowCount }, inPlay = true })
        table.remove(matchGame.deck, randIndex)

        --sets column index back to 1 and increases the row index for the new row.
        if colCount == 4 then
            colCount = 1
            rowCount = rowCount + 1
        else
            colCount = colCount + 1
        end
    end
    -- Set number of cards in play to start with --
    cardsLeftInPlay = #matchGame.shuffledDeck
    print("Cards left in play: " .. cardsLeftInPlay)
    print("shuffledDeck: " .. #matchGame.shuffledDeck)
end

function matchGame.drawMatchingGame()
    --Drawing cards to the screen from the shuffledDeck. We are also drawing a
    --flipped over image in the same place when card hasn't been selected.
    for cardIndex, card in ipairs(matchGame.shuffledDeck) do
        -- print("Card_id: "..card.card_id)

        if columnIndex == 4 then
            rowIndex = rowIndex + 1
            columnIndex = 0
        end
        local xPosition = (columnIndex) * 64 * matchGame.xCardOffset
        local yPosition = (rowIndex) * 98 * matchGame.yCardOffset


        love.graphics.setColor(1, 1, 1)
        --If None selected and none right we display card_cover
        if card.inPlay then
            love.graphics.draw(matchGame.deck.card_cover, xPosition, yPosition)
        else
            love.graphics.draw(matchGame.deck.spriteSheet, matchGame.deck.sprites[card.card_id], xPosition, yPosition)
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
    if matchGame.isCorrectSelection then
        love.graphics.print("Correct Selection!", 350, 55)
    else
        love.graphics.print("Incorrect Selection.... :(", 350, 55)
    end
end

function matchGame.compareMatch()
    if #matchGame.selectedCards == 2 then
        if matchGame.selectedCards[1].card_id == matchGame.selectedCards[2].card_id then
            matchGame.isCorrectSelection = true
        else
            matchGame.startTask = true
            -- startTask()
            matchGame.isCorrectSelection = false
        end
    end
end

function matchGame.getSelectedCard(selectedVector)
    for index, card in ipairs(matchGame.shuffledDeck) do
        local isSelectedCard = compareVector(card.vecPos, selectedVector)
        if isSelectedCard then
            return card
        end
    end
end


function compareVector(a, b)
    return a[1] == b[1] and a[2] == b[2]
end




return matchGame