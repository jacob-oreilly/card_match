local menu = {}
menu.buttons = {}

---- SETUP MENU ----
function menu.setupMenu() 
    table.insert(menu.buttons, newButton(
        "Start",
        function()
            gameState = 2
            print("start")
        end
    ))
    table.insert(menu.buttons, newButton(
        "Quit",
        function()
            love.event.quit(0)
        end
    ))
end

function menu.drawMenu(font)
    local buttonWidth = screenWidth * (1 / 3)
    local buttonHeight = 65
    local total_height = (buttonHeight + 16) * #menu.buttons
    local yIndex = 0
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    for i, button in ipairs(menu.buttons) do
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


return menu