local asteroids = {}



function asteroids.drawAsteroidsTask(font)
    love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.polygon(mode, -length/2, -width /2, -length/2, width /2, length/2, 0)
    love.graphics.polygon("fill", 100,100, 200,100, 150,200)
    love.graphics.setFont(font)
    local text = "asteroids Game"
    local textW = font:getWidth(text)
    local textH = font:getHeight(text)
    love.graphics.print(text, font, (screenWidth * 0.5) - textW * 0.5, textH * 0.5)
end

return asteroids