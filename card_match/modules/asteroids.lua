local asteroids = {}

asteroids.vertices = {}
asteroids.x = 0
asteroids.y = 0

function asteroids.startTask()
    asteroids.x = screenWidth * 0.5
    asteroids.y = screenHeight * 0.7
end

function asteroids.drawAsteroidsTask(font, shipVertices)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.polygon("fill", shipVertices)
    love.graphics.setFont(font)
    local text = "asteroids Game"
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    love.graphics.print(text, font, (screenWidth * 0.5) - textW * 0.5, textH * 0.5)
end

return asteroids
