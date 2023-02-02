--Add at beginning of file
if arg[2] == "debug" then
    require("lldebugger").start()
end

--Write your code here
function love.load()
    lume = require "lume"
    Object = require "classic"
    require "entity"
    require "player"
    require "bullet"
    require "enemy"
    require "textbox"
    require "button"

    cash = 50

    damageLevel = 0
    healthLevel = 0
    reloadLevel = 0
    movementLevel = 0

    playerSize = 15
    playerSpeed = 300 + 5 * movementLevel
    playerHealth = 100 + 5 * healthLevel
    invincibilityBaseDuration = 0.2
    invincibilityCurrentDuration = 0

    player = Player(0, 0, playerSize, playerSpeed, playerHealth)

    enemySize = 15
    enemySpeed = 200
    enemyHealth = 10
    enemyDamage = 5

    bulletSize = 8
    bulletSpeed = 400
    bulletDamage = 10 + damageLevel

    bullets = {}
    bulletBaseCooldown = 0.5 / (1 + reloadLevel / 20)
    bulletCurrentCooldown = bulletBaseCooldown -- Keeping the longer cooldown at the beginning is fine

    scaleTimer = 0
    scaleFactor = 1
    kills = 0

    enemies = {}
    enemySpawnRate = 0.5
    enemySpawnTimer = enemySpawnRate

    loadGame()

    translate_x = -player.x + love.graphics.getWidth() / 2
    translate_y = -player.y + love.graphics.getHeight() / 2

    mapSize = 4096
    floorTile = love.graphics.newImage("assets/Ground_Tile_01_A.png")
    wallTile = love.graphics.newImage("assets/Block_C_01.png")

    isMenuOpen = true
    isShopOpen = false
    isControlsOpen = false

    menuButtons = {}
    local menuButtonNames = {"Play", "Shop", "Controls", "Quit"}
    font = love.graphics.newFont(39)
    love.graphics.setFont(font)
    for i,name in ipairs(menuButtonNames) do
        local button = Button(name, love.graphics.getWidth() * (2/7), 200 + i * 70, love.graphics.getWidth() * (3/7), 60, font)
        table.insert(menuButtons, button)
    end

    shopTextboxes = {}
    valueTextboxes = {}
    shopButtons = {}
    local shopTextboxNames = {"Damage: ", "Health: ", "Attack Speed: ", "Movement Speed: "}
    for i,name in ipairs(shopTextboxNames) do
        local textbox = Textbox(name, love.graphics.getWidth() * (1/10), 200 + i * 70, love.graphics.getWidth() * (3/5), 60, font)
        table.insert(shopTextboxes, textbox)

        local value
        local price
        if name == "Damage: " then
            value = bulletDamage
            price = math.floor(9 + 2^(damageLevel / 10))
        elseif name == "Health: " then
            value = playerHealth
            price = math.floor(9 + 2^(healthLevel / 10))
        elseif name == "Attack Speed: " then
            value = math.floor(bulletBaseCooldown * 10000 + 0.5) / 10000
            price = math.floor(9 + 2^(reloadLevel / 10))
        elseif name == "Movement Speed: " then
            value = playerSpeed
            price = math.floor(9 + 2^(movementLevel / 10))
        end

        local valueTextbox = Textbox(value, textbox.x + font:getWidth(textbox.text), 200 + i * 70, love.graphics.getWidth() * (1/10), 60, font)
        local buyButton = Button(price, textbox.x + textbox.width + 10, 200 + i * 70, love.graphics.getWidth() * (1/6), 60, font)
        table.insert(valueTextboxes, valueTextbox)
        table.insert(shopButtons, buyButton)
    end

    controlsTextboxes = {}
    local controlsTextboxNames = {"Shoot", "Move Up", "Move Down", "Move Left", "Move Right"}
    local controlsButtons = {"Left Mouse", "W", "S", "A", "D"}
    for i,name in ipairs(controlsTextboxNames) do
        local textbox = Textbox(name, love.graphics.getWidth() / 8, 100 + i * 70, love.graphics.getWidth() / 3, 60, font)
        local newTextbox = Textbox(controlsButtons[i], love.graphics.getWidth() / 2 - 20, 100 + i * 70, love.graphics.getWidth() * (2/5), 60, font)
        table.insert(controlsTextboxes, textbox)
        table.insert(controlsTextboxes, newTextbox)
    end

    backButton = Button("Back", love.graphics.getWidth() / 20, love.graphics.getWidth() / 20, love.graphics.getWidth() / 6, love.graphics.getHeight() / 10, love.graphics.newFont(39))

    seconds = 0
    minutes = 0

    showCoordinates = false
end

function love.update(dt)
    mouse_x, mouse_y = love.mouse.getPosition()

    if isMenuOpen then

        if not isShopOpen and not isControlsOpen then
            menuUpdate()
        elseif isShopOpen then
            shopUpdate()
        elseif isControlsOpen then
            controlsUpdate()
        end

    else

        translate_x = -player.x + love.graphics.getWidth() / 2
        translate_y = -player.y + love.graphics.getHeight() / 2

        player:update(dt)
        player:wallCollision(mapSize)
        player.angle = math.atan2(mouse_y - love.graphics.getHeight() / 2, mouse_x - love.graphics.getWidth() / 2)

        -- Bullets

        if bulletCurrentCooldown > 0 then
            bulletCurrentCooldown = bulletCurrentCooldown - dt
        end

        if love.mouse.isDown(1) then
            if bulletCurrentCooldown <= 0 then
                local bullet = Bullet(player.x, player.y, bulletSize, bulletSpeed, "assets/Spells Effect.png", math.atan2(mouse_y - love.graphics.getHeight() / 2, mouse_x - love.graphics.getWidth() / 2), bulletDamage)
                table.insert(bullets, bullet)
                bulletCurrentCooldown = bulletBaseCooldown
            end
        end

        for i=#bullets,1,-1 do
            -- If bullets go offscreen, remove them
            if bullets[i].x + bullets[i].size < player.x - love.graphics.getWidth() / 2 or bullets[i].x - bullets[i].size > player.x + love.graphics.getWidth() / 2 or
            bullets[i].y + bullets[i].size < player.y - love.graphics.getHeight() / 2 or bullets[i].y - bullets[i].size > player.y + love.graphics.getHeight() / 2 then
                table.remove(bullets, i)
            else
                bullets[i]:update(dt)

                if bullets[i]:wallCollision(mapSize) then
                    table.remove(bullets, i)
                end
            end
        end

        -- Enemies

        scaleTimer = scaleTimer + dt
        if scaleTimer >= 20 then
            scaleFactor = scaleFactor + 0.1
            enemyDamage = enemyDamage * scaleFactor
            enemyHealth = enemyHealth * scaleFactor
            scaleTimer = 0
        end

        if enemySpawnTimer > 0 then
            enemySpawnTimer = enemySpawnTimer - dt
        end

        if enemySpawnTimer <= 0 then
            local x = love.math.random(-mapSize / 2 + enemySize, mapSize / 2 - enemySize)
            local y = love.math.random(-mapSize / 2 + enemySize, mapSize / 2 - enemySize)

            -- Makes sure enemy spawns offscreen
            while x + enemySize > player.x - love.graphics.getWidth() / 2 and x - enemySize < player.x + love.graphics.getWidth() / 2 do
                x = love.math.random(-mapSize / 2 + enemySize, mapSize / 2 - enemySize)
            end
            while y + enemySize > player.y - love.graphics.getHeight() / 2 and y - enemySize < player.y + love.graphics.getHeight() / 2 do
                y = love.math.random(-mapSize / 2 + enemySize, mapSize / 2 - enemySize)
            end

            local enemy = Enemy(x, y, enemySize, enemySpeed, "assets/Golem_01_Idle_000.png", math.atan2(player.y - x, player.x - y), enemyHealth, enemyDamage)
            table.insert(enemies, enemy)
            enemySpawnTimer = enemySpawnRate
        end

        if invincibilityCurrentDuration > 0 then
            invincibilityCurrentDuration = invincibilityCurrentDuration - dt
        end

        for i=#enemies,1,-1 do
            enemies[i].angle = math.atan2(player.y - enemies[i].y, player.x - enemies[i].x)
            enemies[i]:update(dt)
            enemies[i]:wallCollision(mapSize)

            for j=i-1,1,-1 do
                enemies[i]:entityCollision(enemies[j])
            end

            for j=#bullets,1,-1 do
                if enemies[i]:entityCollision(bullets[j]) then
                    enemies[i].health = enemies[i].health - bullets[j].damage
                    if enemies[i].health <= 0 then
                        table.remove(enemies, i)
                        kills = kills + 1
                    end
                    table.remove(bullets, j)
                end
            end

            if enemies[i]:entityCollision(player) and invincibilityCurrentDuration <= 0 then
                player.health = player.health - enemies[i].damage
                invincibilityCurrentDuration = invincibilityBaseDuration
            end
        end

        if player.health <= 0 then
            cash = cash + (scaleFactor - 0.9) * 2 * kills
            saveGame()
            isMenuOpen = true
        end

        timerUpdate(dt)

    end
end

function love.draw()
    if isMenuOpen then

        if not isShopOpen and not isControlsOpen then
            menuDraw()
        end

        if isShopOpen then
            shopDraw()
        end

        if isControlsOpen then
            controlsDraw()
        end

    else

        love.graphics.translate(translate_x, translate_y)

        --Floor
        for i=1,mapSize / floorTile:getWidth() do
            for j=1,mapSize / floorTile:getHeight() do
                love.graphics.draw(floorTile, 256 * i - (mapSize / 2 + floorTile:getWidth()), 256 * j - (mapSize / 2 + floorTile:getHeight()))
            end
        end

        for i=1,mapSize / wallTile:getWidth() do
            love.graphics.draw(wallTile, 256 * i - (mapSize / 2 + wallTile:getWidth()), -mapSize / 2 - wallTile:getHeight())
            love.graphics.draw(wallTile, 256 * i - (mapSize / 2 + wallTile:getWidth()), mapSize / 2)
        end

        for i=1,mapSize / wallTile:getWidth() do
            love.graphics.draw(wallTile, -mapSize / 2, 256 * i - (mapSize / 2 + wallTile:getWidth()), math.pi / 2)
            love.graphics.draw(wallTile, mapSize / 2 + wallTile:getHeight(), 256 * i - (mapSize / 2 + wallTile:getWidth()), math.pi / 2)
        end

        cursorDraw()
        player:draw()

        for i,bullet in ipairs(bullets) do
            bullet:draw()
        end

        for i,enemy in ipairs(enemies) do
            enemy:draw()
        end

        healthDraw()

        if showCoordinates then
            displayCoordinates()
        end

        timerDraw()

    end
end

function love.keypressed(key)
    if key == "escape" then
        back()
    end

    if key == "f3" then
        showCoordinates = not showCoordinates
    end
end

function cursorDraw()
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(player.x, player.y, mouse_x - translate_x, mouse_y - translate_y)
end

function displayCoordinates()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Player coordinates: " .. math.floor(player.x) .. ", " .. math.floor(player.y), 10 - translate_x, 10 - translate_y)
    love.graphics.print("Mouse coordinates: " .. mouse_x .. ", " .. mouse_y, 10 - translate_x, 30 - translate_y)
    love.graphics.print("Mouse angle: " .. math.atan2(mouse_y - love.graphics.getHeight() / 2, mouse_x - love.graphics.getWidth() / 2), 10 - translate_x, 50 - translate_y)
end

function healthDraw()
    local font = love.graphics.newFont(26)
    love.graphics.setFont(font)

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", -translate_x, love.graphics.getHeight() - 30 - translate_y, love.graphics.getWidth(), 30)
    love.graphics.setColor(0, 0.4, 0.1)
    love.graphics.rectangle("fill", -translate_x, love.graphics.getHeight() - 30 - translate_y, love.graphics.getWidth() * (player.health / player.maxHealth), 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(math.floor(player.health) .. " / " .. player.maxHealth, (love.graphics.getWidth() - font:getWidth(math.floor(player.health) .. " / " .. player.maxHealth)) / 2 - translate_x, love.graphics.getHeight() - font:getHeight() - translate_y)
end

function menuDraw()
    local font = love.graphics.newFont(65)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Horde", love.graphics.getWidth() / 2 - font:getWidth("Horde") / 2, 100 - font:getHeight() / 2)
    love.graphics.print("Survival", love.graphics.getWidth() / 2 - font:getWidth("Survival") / 2, 175 - font:getHeight() / 2)

    for i,button in ipairs(menuButtons) do
        button:draw()
    end
end

function menuUpdate()
    local buttonFunctions = {}

    local play = function () loadGame(); isMenuOpen = false end
    table.insert(buttonFunctions, play)

    local shop = function () isShopOpen = true end
    table.insert(buttonFunctions, shop)

    local controls = function () isControlsOpen = true end
    table.insert(buttonFunctions, controls)

    local quit = function () saveGame(); love.event.quit() end
    table.insert(buttonFunctions, quit)

    for i,button in ipairs(menuButtons) do
        button:update(mouse_x, mouse_y, buttonFunctions[i])
    end
end

function shopDraw()
    local font = love.graphics.newFont(65)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Shop", love.graphics.getWidth() / 2 - font:getWidth("Shop") / 2, 100 - font:getHeight() / 2)

    font = love.graphics.newFont(52)
    love.graphics.setFont(font)
    love.graphics.print("Cash: " .. math.floor(cash), love.graphics.getWidth() / 2 - font:getWidth("Cash: " .. math.floor(cash)) / 2, 175 - font:getHeight() / 2)

    for i,textbox in ipairs(shopTextboxes) do
        textbox:draw()
    end

    for i,textbox in ipairs(valueTextboxes) do
        if shopTextboxes[i].text == "Attack Speed: " then
            textbox.text = math.floor(10000 * textbox.text + 0.5) / 10000
        end
        textbox:draw()
    end

    for i,button in ipairs(shopButtons) do
        button:draw()
    end

    backButton:draw()
end

function shopUpdate()
    local buttonFunctions = {}

    local damageIncrease = function ()
        if cash >= shopButtons[1].text then
            cash = cash - shopButtons[1].text
            damageLevel = damageLevel + 1
            bulletDamage = 10 + damageLevel
            valueTextboxes[1].text = bulletDamage
            shopButtons[1].text = math.floor(9 + 2^(damageLevel / 10))
            saveGame()
        end
    end
    table.insert(buttonFunctions, damageIncrease)

    local healthIncrease = function ()
        if cash >= shopButtons[2].text then
            cash = cash - shopButtons[2].text
            healthLevel = healthLevel + 1
            playerHealth = 100 + 5 * healthLevel
            valueTextboxes[2].text = playerHealth
            shopButtons[2].text = math.floor(9 + 2^(healthLevel / 10))
            saveGame()
        end
    end
    table.insert(buttonFunctions, healthIncrease)

    local reloadIncrease = function ()
        if cash >= shopButtons[3].text then
            cash = cash - shopButtons[3].text
            reloadLevel = reloadLevel + 1
            bulletBaseCooldown = 0.5 / (1 + reloadLevel / 20)
            valueTextboxes[3].text = bulletBaseCooldown
            shopButtons[3].text = math.floor(9 + 2^(reloadLevel / 10))
            saveGame()
        end
    end
    table.insert(buttonFunctions, reloadIncrease)

    local movementIncrease = function ()
        if cash >= shopButtons[4].text then
            cash = cash - shopButtons[4].text
            movementLevel = movementLevel + 1
            playerSpeed = 300 + 5 * movementLevel
            valueTextboxes[4].text = playerSpeed
            shopButtons[4].text = math.floor(9 + 2^(movementLevel / 10))
            saveGame()
        end
    end
    table.insert(buttonFunctions, movementIncrease)

    for i,button in ipairs(shopButtons) do
        button:update(mouse_x, mouse_y, buttonFunctions[i])
    end

    backButton:update(mouse_x, mouse_y, back)
end

function controlsDraw()
    local font = love.graphics.newFont(65)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Controls", love.graphics.getWidth() / 2 - font:getWidth("Controls") / 2, 100 - font:getHeight() / 2)

    for i,textbox in ipairs(controlsTextboxes) do
        textbox:draw()
    end

    backButton:draw()
end

function controlsUpdate()
    backButton:update(mouse_x, mouse_y, back)
end

function back()
    if isMenuOpen == false then
        isMenuOpen = true
    elseif isShopOpen or isControlsOpen then
        isShopOpen = false
        isControlsOpen = false
    else
        saveGame()
        love.event.quit()
    end
end

function saveGame()
    local data = {}
    data.levels = {
        damage = damageLevel,
        health = healthLevel,
        reload = reloadLevel,
        movement = movementLevel
    }
    data.cash = cash

    local serialized = lume.serialize(data)
    love.filesystem.write("savedata.txt", serialized)
end

function loadGame()
    if love.filesystem.getInfo("savedata.txt") then
        local file = love.filesystem.read("savedata.txt")
        local data = lume.deserialize(file)

        damageLevel = data.levels.damage
        healthLevel = data.levels.health
        reloadLevel = data.levels.reload
        movementLevel = data.levels.movement

        cash = data.cash

        for i=#bullets,1,-1 do
            table.remove(bullets, i)
        end

        for i=#enemies,1,-1 do
            table.remove(enemies, i)
        end

        bulletDamage = 10 + damageLevel
        playerHealth = 100 + 5 * healthLevel
        bulletBaseCooldown = 0.5 / (1 + reloadLevel / 20)
        playerSpeed = 300 + 5 * movementLevel

        bulletCurrentCooldown = 0.5

        scaleTimer = 0
        scaleFactor = 1
        kills = 0

        enemyHealth = 10
        enemyDamage = 5

        seconds = 0
        minutes = 0
    end

    player = Player(0, 0, playerSize, playerSpeed, "assets/Wraith_01_Idle_000.png", 0, playerHealth)
end

function timerUpdate(dt)
    seconds = seconds + dt

    if math.floor(seconds / 60) == 1 then
        minutes = minutes + 1
        seconds = seconds - 60
    end
end

function timerDraw()
    local font = love.graphics.newFont(39)
    love.graphics.setFont(font)

    if minutes < 10 then
        printedMinutes = "0" .. math.floor(minutes)
    else
        printedMinutes = math.floor(minutes)
    end

    if seconds < 10 then
        printedSeconds = "0" .. math.floor(seconds)
    else
        printedSeconds = math.floor(seconds)
    end

    love.graphics.print(printedMinutes .. ":" .. printedSeconds, love.graphics.getWidth() - translate_x - font:getWidth(printedMinutes .. ":" .. printedSeconds), -translate_y)
end

--Add at end of file
local love_errorhandler = love.errhand

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end