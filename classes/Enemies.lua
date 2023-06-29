require("libs.math_helpers")

--=ABSTRACT ENEMY CLASS=--
Enemy = Entity:new()
Enemy.TYPE = "DynamicEntity"
Enemy.NAME = "GenericEnemyClass"

Enemy.health = 100
Enemy.meleeDamage = 25
Enemy.meleeRange = 30
Enemy.shootingRange = 128
Enemy.weapon = nil

Enemy.spriteObject = nil
Enemy.painSprite = nil
Enemy.idleSprite = nil
Enemy.idleFrame = 1
Enemy.deadSprite = nil
Enemy.meleeSprite = nil
Enemy.shootSprite = nil
Enemy.idleSpriteSet = {}

Enemy.inPain = false
Enemy.isAttacking = false
Enemy.isIdle = true
Enemy.inMelee = false
Enemy.lastStepTime = 0
Enemy.statusChanged = false

Enemy.painTime = 0.8
Enemy.statusTime = 0
Enemy.stepTime = 0.2
Enemy.meleeDuration = 1
Enemy.lastMeleeAttack = 0
Enemy.shootingDuration = 1
Enemy.lastRangeAttack = 0
Enemy.shootingCooldown = 2

Enemy.painSound = nil
Enemy.deathSound = nil
Enemy.meleeSound = nil
Enemy.shootSound = nil
Enemy.alertSound = nil

function Enemy:setSpriteObject(sprite)
    self.spriteObject = sprite
end

function Enemy:respawn()
    self.health = self.maxHealth
    self.inPain = false
    self.isAttacking = false
    self.isIdle = true
    self.inMelee = false
    self.lastStepTime = 0
    self.statusChanged = false
    self.lastMeleeAttack = 0
    self.lastRangeAttack = 0
    self.spriteObject:setSpriteImage(self.idleSpriteSet[1])
    self.isDead = false
    self.lastPlayerPos = {}

    self:setPosition({x = self.startPosition.x, y = self.startPosition.y})
    self.lastX = self.x
    self.lastY = self.y
    self:updateCollider()
    self:updateSprite()
    self:updateSpriteObject()
    self:think()
end

function Enemy:getSpriteObject(sprite)
    return self.spriteObject
end

function Enemy:updateSprite()
    self.spriteObject:setPosition({x = self.x, y = self.y})
end

function Enemy:move(direction)
    local directionRad = directionDictionary[direction]
    local rad = getPositiveRad(getRad(self.angle))
    --translate
    self.x = self.x + math.cos(rad + directionRad) * self.speed * deltaTime
    self.y = self.y + math.sin(rad + directionRad) * self.speed * deltaTime
    self:updateCollider()
    self:updateSprite()
end

function Enemy:spawn(tile)
    self.x = Tiles[tile].x + TILE_SIZE/2
    self.y = Tiles[tile].y + TILE_SIZE/2
    self.lastX = self.x
    self.lastY = self.y
    self:updateCollider()
    self:updateSprite()
end

function Enemy:checkHit()
    if Player.weapon.justShot and not Player.isDead then
        local halfScreen = Screen.width/2
        local halfEnemy = (self.spriteObject.projectionWidth * self.spriteObject.customScaleMultiplier)/2
        if (self.spriteObject.screenX - halfEnemy < halfScreen) and (self.spriteObject.screenX + halfEnemy > halfScreen) and not self.isDead and self:castRayToPlayer() then
            self:receiveDamage(Player.weapon.damage)
            Player.weapon.justShot = false
            if self.health < 1 then
                self:die()
                self.statusChanged = true
                return
            end
            self.inPain = true
            self.statusChanged = true
        end
    end
end

--Atualiza a imagem da sprite do inimigo
function Enemy:updateSpriteObject()
    if self.statusChanged then
        --Na morte
        if self.isDead then
            self.spriteObject.spriteImage = self.deadSprite
        --Na agonia
        elseif self.inPain then
            self.spriteObject.spriteImage = self.painSprite
            if self.statusTime >= self.painTime then
                self.inPain = false
                self.statusChanged = false
                self.spriteObject.spriteImage = self.idleSprite
                self.statusTime = 0
            end
        self.statusTime = self.statusTime + deltaTime
        --No ataque corporal
        elseif self.inMelee then
            self.spriteObject.spriteImage = self.meleeSprite
            if self.statusTime >= self.meleeDuration then
                self.inMelee = false
                self.statusChanged = false
                self.spriteObject.spriteImage = self.idleSprite
                self.statusTime = 0
            end
        self.statusTime = self.statusTime + deltaTime
        elseif self.inRangeAttack then
            self.spriteObject.spriteImage = self.shootSprite
            if self.statusTime >= self.shootingDuration then
                self.inRangeAttack = false
                self.statusChanged = false
                self.spriteObject.spriteImage = self.idleSprite
                self.statusTime = 0
            end
        self.statusTime = self.statusTime + deltaTime
        --No estado padrão
        elseif self.isIdle then
            self.spriteObject = self.idleSprite
            self.statusChanged = false
        end
    end
end


function Enemy:castRayToPlayer()    --Apenas se o inimigo estiver vendo o jogador a partir do seu centro!
    if Player:getCurrentTile() == self:getCurrentTile() then
        return true
    end

    local column = self:getTileX()
    local line = self:getTileY()

    local dx = Player:getX() - self:getX()
    local dy = Player:getY() - self:getY()
    local playerDistance = getPointsDistance(self:getX(), self:getY(), Player:getX(), Player:getY())

    local rayRad = math.atan(dy/dx) --Menor ângulo positivo em relação ao eixo horizontal

    --Para apenas um raio
    local epX_v = 0
    local epY_v = 0
    local isWall = false
    local counter = 0
    local incrementX = 1
    local tile
    local hitAxis
    local distanceH = 1e9
    local distanceV = 1e9

    local camera  = self
    --Para cada linha vertical cruzada pelo raio
    while not isWall and epX_v < TILE_SIZE * Level.xSize and epX_v >= 0 and epY_v < TILE_SIZE * Level.ySize(Level) and epY_v >= 0 do

        if self.x == Player:getX() then
            break
        end

        if self.x < Player:getX() then
            epX_v = (column + counter) * TILE_SIZE
        else
            epX_v = (column - 1 - counter) * TILE_SIZE
            incrementX = 0
        end

        --MULTIPLICAÇÃO: direção * distância X
        epY_v = self.y + math.tan(rayRad) * (epX_v - self.x)

        tileX = epX_v/TILE_SIZE + incrementX
        tileY = math.floor(epY_v/TILE_SIZE)

        counter = counter + 1
        tile = tileY * Level.xSize + tileX

        if not (Level.map[tile] == 0) and not (Level.map[tile] == nil) then
            isWall = true
            distanceV = getPointsDistance(self:getX(), self:getY(), epX_v, epY_v)
        end
    end

    isWall = false
    local epX_h = 0
    local epY_h = 0
    counter = 0
    local decrementY = 0
    --Para cada linha horizontal cruzada pelo raio
    while not isWall and
    epX_h >= 0 and
    epY_h >= 0 and
    epX_h <= Level.xSize * TILE_SIZE and
    epY_h <= Level.ySize(Level) * TILE_SIZE do

        if self.y == Player:getY() then
            break
        end

        if self.y < Player:getY() then
            epY_h = (line + counter) * TILE_SIZE
        else
            epY_h = (line - 1 - counter) * TILE_SIZE
            decrementY = -1
        end

        epX_h = self.x + (epY_h - self.y)/math.tan(rayRad)

        tileY = epY_h/TILE_SIZE + decrementY
        tileX = math.ceil(epX_h/TILE_SIZE)

        counter = counter + 1
        tile = tileY * Level.xSize + tileX

        if not (Level.map[tile] == 0) and not (Level.map[tile] == nil) then
            isWall = true
            distanceH = getPointsDistance(self:getX(), self:getY(), epX_h, epY_h)
        end
    end

    local wallDistance = math.min(distanceH, distanceV)
    if wallDistance < playerDistance then return false else return true end
end

function Enemy:chase()

    local chase = false
    local distX
    local distY
    local canSeePlayer = false

    if self:castRayToPlayer() then
        if self.lastPlayerPos.x == nil then
            self.alertSound:play()
            self.lastRangeAttack = levelTime
        end
        distX = Player:getX() - self:getX()
        distY = Player:getY() - self:getY()
        self.lastPlayerPos.x = Player:getX()
        self.lastPlayerPos.y = Player:getY()
        canSeePlayer = true
        chase = true
    
    elseif not (self.lastPlayerPos.x == nil or self.lastPlayerPos.y == nil) then
        distX = self.lastPlayerPos.x - self:getX()
        distY = self.lastPlayerPos.y - self:getY()
        chase = true
    end
    if chase then
        if (math.abs(distX) > self.meleeRange or math.abs(distY) > self.meleeRange) then

            if math.abs(distX) < self.shootingRange and canSeePlayer and levelTime - self.lastRangeAttack > self.shootingCooldown and not self.inPain then
                self:rangeAttack()
            else
                local posX = self:getX()
                local posY = self:getY()

                local angle = math.atan(distY/distX)

                if not (distX == 0) then posX = self:getX() + self.speed * math.abs(math.cos(angle)) * deltaTime * distX/math.abs(distX) end
                if not (distY == 0) then posY = self:getY() + self.speed * math.abs(math.sin(angle)) * deltaTime * distY/math.abs(distY) end

                --Anda até o jogador
                self:setPosition({x = posX, y = posY})

                if(levelTime - self.lastStepTime >= self.stepTime) then
                    self.idleFrame = self.idleFrame + 1
                    if self.idleFrame > table.getn(self.idleSpriteSet) then self.idleFrame = 1 end
                    self.spriteObject.spriteImage = self.idleSpriteSet[self.idleFrame]
                    self.lastStepTime = levelTime
                end

                self:updateCollider()
                self:updateSprite()
            end
        elseif canSeePlayer then
            self:meleeAttack()
        end
    end
end

function Enemy:meleeAttack()
    if levelTime - self.lastMeleeAttack >= self.meleeDuration and not Player.isDead then
        self.meleeSound:play()
        self.inMelee = true
        self.statusChanged = true
        Player:receiveDamage(self.meleeDamage)
        self.lastMeleeAttack = levelTime
        Player:checkHealth()
    end
end

function Enemy:rangeAttack()
    if levelTime - self.lastRangeAttack >= self.shootingDuration and not Player.isDead then
        self.shootSound:play()
        self.inRangeAttack = true
        self.statusChanged = true
        Player:receiveDamage(self.weapon.damage)
        self.lastRangeAttack = levelTime
        Player:checkHealth()
    end
end

function Enemy:think()
    if not self.isDead then
        self:checkHit()
        self:chase()
        self:updateSpriteObject()
    end
end

--=BEAST MAN (BRUTAMONTES)=-- 
BeastMan = Enemy:new()
BeastMan.TYPE = "DynamicEntity"
BeastMan.NAME = "BeastMan"

BeastMan.maxHealth = 60
BeastMan.health = 60
BeastMan.width = 25
BeastMan.height = 25
BeastMan.speed = 128
BeastMan.shootingRange = 0
BeastMan.meleeDamage = 20

BeastMan.idleSpriteSet = {}
BeastMan.idleSpriteSet[1] = love.graphics.newImage("assets/sprites/entities/imp/idle/imp.png")
BeastMan.idleSpriteSet[2] = love.graphics.newImage("assets/sprites/entities/imp/idle/imp02.png")
BeastMan.idleSprite = BeastMan.idleSpriteSet[1]

BeastMan.painSprite = love.graphics.newImage("assets/sprites/entities/imp/pain/pain01.png")
BeastMan.deadSprite = love.graphics.newImage("assets/sprites/entities/imp/death/death01.png")
BeastMan.meleeSprite = love.graphics.newImage("assets/sprites/entities/imp/melee/melee03.png")

BeastMan.painSound = love.audio.newSource("assets/audio/npcs/imp/pain.wav", "static")
BeastMan.deathSound = love.audio.newSource("assets/audio/npcs/imp/death.wav", "static")
BeastMan.meleeSound = love.audio.newSource("assets/audio/npcs/imp/melee.wav", "static")
BeastMan.painSound:setPitch(0.8)
BeastMan.deathSound:setPitch(0.8)

function BeastMan:new(tile)
    local newBeastMan = genericConstructor(self)
    newBeastMan.spriteObject = StaticSprite:new()
    newBeastMan.spriteObject.customScaleMultiplier = 14.5
    newBeastMan.spriteObject:setSpriteImage(self.idleSpriteSet[1])
    local eBoxCollider = BoxCollider:new(newBeastMan)
    newBeastMan.collider = eBoxCollider
    newBeastMan.alertSound = love.audio.newSource("assets/audio/npcs/imp/alert.wav", "static")
    newBeastMan.lastPlayerPos = {}
    newBeastMan:spawn(tile)
    newBeastMan.startPosition = {x = newBeastMan.x, y = newBeastMan.y}
    ObjectsHandler:Add(newBeastMan)
    return newBeastMan
end

function BeastMan:rangeAttack() end

--=SHARPSHOOTER (ATIRADOR)=-- 
SharpShooter = Enemy:new()
SharpShooter.TYPE = "DynamicEntity"
SharpShooter.NAME = "SharpShooter"

SharpShooter.maxHealth = 50
SharpShooter.health = 50
SharpShooter.width = 25
SharpShooter.height = 25
SharpShooter.speed = 50
SharpShooter.shootingDuration = 1
SharpShooter.shootingRange = 128

SharpShooter.idleSpriteSet = {}
SharpShooter.idleSpriteSet[1] = love.graphics.newImage("assets/sprites/entities/sharpshooter/idle/sharp01.png")
SharpShooter.idleSpriteSet[2] = love.graphics.newImage("assets/sprites/entities/sharpshooter/idle/sharp02.png")
SharpShooter.idleSprite = SharpShooter.idleSpriteSet[1]

SharpShooter.painSprite = love.graphics.newImage("assets/sprites/entities/sharpshooter/pain/pain01.png")
SharpShooter.deadSprite = love.graphics.newImage("assets/sprites/entities/sharpshooter/death/death01.png")
SharpShooter.shootSprite = love.graphics.newImage("assets/sprites/entities/sharpshooter/shoot/shoot01.png")

SharpShooter.painSound = love.audio.newSource("assets/audio/npcs/sharpshooter/pain.wav", "static")
SharpShooter.deathSound = love.audio.newSource("assets/audio/npcs/sharpshooter/death.wav", "static")
SharpShooter.shootSound = love.audio.newSource("assets/audio/npcs/sharpshooter/shoot.wav", "static")
SharpShooter.painSound:setPitch(0.8)
SharpShooter.deathSound:setPitch(0.8)

function SharpShooter:new(tile)
    local newSharpShooter = genericConstructor(self)
    newSharpShooter.spriteObject = StaticSprite:new()
    newSharpShooter.weapon = Pistol:new()
    newSharpShooter.spriteObject:setSpriteImage(self.idleSpriteSet[1])
    newSharpShooter.spriteObject.customScaleMultiplier = 16
    local eBoxCollider = BoxCollider:new(newSharpShooter)
    newSharpShooter.collider = eBoxCollider
    newSharpShooter.alertSound = love.audio.newSource("assets/audio/npcs/sharpshooter/alert.wav", "static")
    newSharpShooter.lastPlayerPos = {}
    newSharpShooter:spawn(tile)
    newSharpShooter.startPosition = {x = newSharpShooter.x, y = newSharpShooter.y}
    ObjectsHandler:Add(newSharpShooter)
    return newSharpShooter
end

function SharpShooter:meleeAttack() end
