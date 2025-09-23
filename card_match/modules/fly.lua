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

return fly


