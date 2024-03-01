require ("libs.math_helpers")
require("handlers.control_handler")
require("handlers.collision_handler")
require("uniques.HUD")
require("GameConfig")

require("classes.Screen")
require("classes.SpriteObjects")
require("classes.Player")
require("classes.Enemies")
require("classes.Scenario")
require("classes.Bonus")

--Global Variables--
deltaTime = 0
levelTime = 0
num_rays = 0
Level = {}
Tiles = {}

--Local Variables--
local column_width
local texture

--Flags--
local isResized = false

--Retorna a matriz equivalente ao mapa
local function generateWorld(level)
    local counter = 1
    for i = 0, level.ySize(level) - 1  do
        for j = 0, level.xSize - 1 do
            Tiles[counter] = {x = j * TILE_SIZE,
            y = i * TILE_SIZE,
            isFilled = not(level.map[counter] == 0)}
            counter = counter + 1
        end
    end
end

--Chamada de carregamento
function love.load()
    local icon = love.image.newImageData("assets/icon.png")
    love.window.setTitle("KILLFRAME")
    love.window.setIcon(icon)
    love.mouse.setRelativeMode(true)
    love.graphics.setLineWidth( 0 )
    justRestarted = false
    fpsC = 0

    Level = {

        map = {
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
            1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,1,0,0,1,0,1,
            1,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,
            1,0,0,1,0,0,0,1,0,0,0,0,1,0,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,1,
            1,0,0,1,0,3,0,1,0,0,3,0,0,0,1,1,0,3,0,1,0,0,1,0,1,0,0,0,0,1,
            1,0,0,1,1,1,1,1,0,0,3,0,1,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,1,
            1,0,1,0,0,0,0,0,0,0,3,0,1,0,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,0,0,0,3,0,0,0,1,1,1,1,1,1,0,0,1,0,0,1,1,1,0,1,
            1,0,0,1,1,1,0,0,0,0,3,0,1,0,1,1,0,3,0,1,0,0,1,0,0,1,0,1,0,1,
            1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,1,0,0,0,0,0,0,1,0,1,1,0,1,0,1,
            1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,0,0,1,0,1,0,1,
            1,0,0,0,0,0,0,0,5,5,5,5,5,0,1,1,0,0,0,0,0,0,1,1,1,1,0,1,0,1,
            1,0,0,4,4,4,0,0,0,0,0,0,5,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,
            1,0,0,4,0,0,0,0,5,5,5,0,5,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,
            1,0,0,4,0,0,4,0,0,0,5,0,5,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,
            1,0,0,4,0,4,0,0,0,0,5,0,5,0,1,1,0,0,0,0,5,0,0,0,5,0,0,0,1,1,
            1,0,0,0,4,0,0,0,0,0,5,0,5,0,1,1,0,0,5,0,0,0,0,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,0,0,0,5,0,5,0,1,1,0,0,0,0,0,5,0,0,5,0,0,0,0,1,
            1,0,0,0,0,0,0,0,0,0,5,0,5,0,1,1,0,0,0,5,0,0,0,0,0,0,0,0,0,1,
            1,3,4,4,4,4,3,3,1,1,5,0,5,0,1,1,0,0,5,0,0,0,5,0,0,5,5,0,0,1,
            1,0,0,0,0,0,0,0,5,5,5,0,5,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,5,0,0,0,0,0,1,1,1,0,0,5,0,5,0,5,0,0,5,0,5,0,1,
            1,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,1,
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        },
        
        textures = {
            love.graphics.newImage('assets/textures/green_metal.jpg'),
            love.graphics.newImage('assets/textures/missing_texture.jpg'),
            love.graphics.newImage('assets/textures/circuit.jpg'),
            love.graphics.newImage('assets/textures/cyber_orange.jpg'),
            love.graphics.newImage('assets/textures/cyber.jpg'),
        },

        music = love.audio.newSource("assets/audio/levels/theme.mp3", "static"),

        xSize = 30,

        ySize = function (self)
            return table.getn(self.map)/self.xSize
        end,

        enemyCounter = 0,

        win = false,
    }

    generateWorld(Level)

    enemies = {BeastMan:new(75), BeastMan:new(84), BeastMan:new(243), BeastMan:new(160),  BeastMan:new(407),BeastMan:new(377),BeastMan:new(208),BeastMan:new(414),BeastMan:new(355), SharpShooter:new(289), SharpShooter:new(290),SharpShooter:new(205), SharpShooter:new(419), SharpShooter:new(254), BeastMan:new(56), SharpShooter:new(115), SharpShooter:new(475), SharpShooter:new(471), SharpShooter:new(535), SharpShooter:new(713), BeastMan:new(629), BeastMan:new(477), BeastMan:new(592), BeastMan:new(716), BeastMan:new(528), BeastMan:new(432), BeastMan:new(492), BeastMan:new(582),  BeastMan:new(35), SharpShooter:new(409),}
    bonuses = {HealthBonus:new(350 , 85), HealthBonus:new(1030 , 350), HealthBonus:new(1487 , 302), HealthBonus:new(1502 , 69), HealthBonus:new(1116 , 1503), HealthBonus:new(267 , 903), HealthBonus:new(268 , 973), HealthBonus:new(270 , 1047)}

    sprites = ObjectsHandler:getByType("SpriteObject")
    animatedObjects = ObjectsHandler:getByType("DynamicScenarioObject")

    for _, v in pairs(sprites) do
        v:scaleToScreen()
    end
    
    Player:spawn(96)
    Player.startPosition = {x = Player.x, y = Player.y}

    Screen:loadGameScreen()

    isResized = true

    numberOfEnemies = table.getn(enemies)
    Level.enemyCounter = numberOfEnemies
    --love.audio.play(Level.music)
end

function love.keyreleased(k)
    --FullScreen Control
    if k == "f" then
        Screen:toggleFullscreen()
        isResized = true
        for _, v in pairs(sprites) do
            v:scaleToScreen()
        end
    --Restart Control
    elseif k == "r" and (Player.isDead or Level.win) then
        Level.win = false
        restart()
        for _, v in pairs(sprites) do
            v:scaleToScreen()
        end
    end
end

--Mouse Control
function love.mousemoved(x, y, dx, dy, isTouch)
    Player:rotate(dx)
end

--Called every frame (1s/60)
function love.update(dt)
    deltaTime = dt
    levelTime = levelTime + deltaTime

    fpsC = math.floor(1 / dt)

    for _, aObject in pairs(animatedObjects) do
        local aSprite = aObject.SpriteObject
        aSprite:Animate()
        aSprite:scaleToScreen()
    end

    if isResized then
        num_rays = Screen.width
        isResized = false
    end

    if love.mouse.isDown(1) then
        Player:shoot()
    end

    if love.keyboard.isDown("lshift") then
        Player:sprint()       
    end
    --transform--
    if love.keyboard.isDown("up", "w") then
        Player:move("forward")
    end
    if love.keyboard.isDown("down", "s") then
        Player:move("backwards")
    end
    --strafe
    if love.keyboard.isDown("e", "d") then
        Player:move("right")
    end
    if love.keyboard.isDown("q", "a") then
        Player:move("left")
    end
    --rotation
    if love.keyboard.isDown("right") then
        Player:rotate(10)
    end
    if love.keyboard.isDown("left") then
        Player:rotate(-10)
    end

    Player:walk()

    for _, enemy in pairs(enemies) do
        enemy:think()
    end
    
    if not justRestarted then
        CollisionHandler:checkBoxCollision()    --Check wall collisions
    end
    Player:updateAnimation()
    HUD:loadWeapon()

    Player:recordLastPos()

    for _, v in pairs(enemies) do 
        v:recordLastPos()
    end

    table.sort(enemies, function (enemy1, enemy2)
        return getPointsDistance(enemy1.x, enemy1.y, Player.x, Player.y) < getPointsDistance(enemy2.x, enemy2.y, Player.x, Player.y)
    end
    )

    for _, bonus in pairs(bonuses) do
        if bonus.isActive and Player.x < bonus.x + bonus.radius and Player.y < bonus.y + bonus.radius
        and Player.x > bonus.x - bonus.radius and Player.y > bonus.y - bonus.radius then
            bonus:apply()
        end
    end

    justRestarted = false
    Player.weapon.justShot = false
    win()
end

--Runs every single frame, used only for drawings
function love.draw()

    love.graphics.setBackgroundColor(0, 0, 0)
    
    if Level.win then
        HUD:drawWinScreen()
    elseif not Player.isDead then
        love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
        Render:draw(sprites)
        HUD:draw()
    else
        HUD:drawDeathScreen()
    end

    local collisionMessage = "No Collision"

    if Player.collider.onCollision then
        collisionMessage = "OnCollision"
    end

    love.graphics.print(love.timer.getFPS(), 0, 0)
    love.graphics.print(Player.angle, 0, 40)
    love.graphics.print(collisionMessage, 0, 80)

end

function restart()
    local entities = ObjectsHandler:getByType("DynamicEntity")
    local bonuses = ObjectsHandler:getByType("Bonus")
    for _, entity in pairs(entities) do
        entity:respawn()
    end

    for _, bonus in pairs(bonuses) do
        bonus:respawn()
    end
    justRestarted = true
    Level.enemyCounter = numberOfEnemies
end

function win()
    if Level.enemyCounter == 0 then
        --Level.win = true
    end
end