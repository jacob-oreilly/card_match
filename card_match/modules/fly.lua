local fly = {}

-- fly = {}
fly.directionState = {
    "left",
    "right",
    "up",
    "down",
    "up_L",
    "up_R",
    "down_L",
    "down_R"
}
fly.directionStateSelected = ""
fly.directionChangeDuration = math.random(0, 1)
fly.speed = 800
fly.flyWasHit = false

function fly.drawFlyTask(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", fly.x, fly.y, fly.width, fly.height)
    love.graphics.setFont(font)
    local text = "fly game"
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    love.graphics.print(text, font, (screenWidth * 0.5) - textW * 0.5, textH * 0.5)
end

function fly.hasHitFly()
    local mouseBuffer = 10
    local flyIsHover = love.mouse.getX() > fly.x - mouseBuffer and love.mouse.getX() < fly.x + fly.width + mouseBuffer and
        love.mouse.getY() > fly.y - mouseBuffer and love.mouse.getY() < fly.y + fly.height + mouseBuffer
    if flyIsHover and love.mouse.isDown(1) then
        fly.flyWasHit = true
    end
end

function fly.update(dt)
    if not fly.flyWasHit then
        if fly.directionStateSelected == "" then
            fly.directionStateSelected = fly.directionState[math.random(1, #fly.directionState)]
        end

        local screenLeft = 0
        local screenRight = screenWidth - fly.width
        local screenUp = 0
        local screenDown = screenHeight - fly.height

        local flyReachedEdge = fly.x <= screenLeft or fly.x >= screenRight or fly.y <= screenUp or
            fly.y >= screenDown
        timer = timer + dt
        if timer >= fly.directionChangeDuration or flyReachedEdge then
            fly.directionStateSelected = fly.directionState[math.random(1, #fly.directionState)]
            timer = 0
            fly.directionChangeDuration = math.random(0, 1)
        end
        if fly.directionStateSelected == "left" then
            fly.x = fly.x - fly.speed * dt
        elseif fly.directionStateSelected == "right" then
            fly.x = fly.x + fly.speed * dt
        elseif fly.directionStateSelected == "up" then
            fly.y = fly.y - fly.speed * dt
        elseif fly.directionStateSelected == "down" then
            fly.y = fly.y + fly.speed * dt
        elseif fly.directionStateSelected == "up_L" then
            fly.y = fly.y - fly.speed * dt
            fly.x = fly.x - fly.speed * dt
        elseif fly.directionStateSelected == "up_R" then
            fly.y = fly.y + fly.speed * dt
            fly.x = fly.x + fly.speed * dt
        elseif fly.directionStateSelected == "down_L" then
            fly.y = fly.y + fly.speed * dt
            fly.x = fly.x - fly.speed * dt
        elseif fly.directionStateSelected == "down_R" then
            fly.y = fly.y - fly.speed * dt
            fly.x = fly.x + fly.speed * dt
        end
        fly.hasHitFly()
    else
        timer = timer + dt
        if timer >= sceneTransitionDuration then
            timer = 0
            fly.flyWasHit = false
            gameState = 2
        end
    end
    return fly.flyWasHit
end

return fly
