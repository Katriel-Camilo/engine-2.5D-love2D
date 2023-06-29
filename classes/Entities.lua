require("libs.utilities")
require("libs.math_helpers")

require("classes.GameObject")

--=ABSTRACT ENTITY CLASS=--
Entity = GameObject:new()
Entity.NAME = "Entity"
Entity.TYPE = "GameObject"

Entity.FOV = 0 --RAD
Entity.WALK_SPEED = 40
Entity.SPRINT_SPEED = 80

Entity.painSound = nil
Entity.deathSound = nil

Entity.health = 100
Entity.isDead = false
Entity.speed = 40
Entity.angle = 0
Entity.width = 10
Entity.height = 10

Entity.collider = nil
Entity.lastX = 0
Entity.lastY = 0

function Entity:new()
    return genericConstructor(self)
end

--Getters & Setters
function Entity:getHealth()
    return self.health
end

function Entity:setHealth(health)
    self.health = health
end

function Entity:getFOV()
    return self.FOV
end

function Entity:setFOV(fov)
    self.FOV = fov
end

function Entity:getRadius()
    return self.RADIUS
end

function Entity:getAngle()
    return self.angle
end

function Entity:setAngle(angle)
    self.angle = angle
end

function Entity:getWidth()
    return self.width
end

function Entity:setWidth(width)
    self.width = width
end

function Entity:setHeight(height)
    self.height = height
end

function Entity:getHeight()
    return self.height
end

--Methods
function Entity:walk()
    self.speed = self.WALK_SPEED
end

function Entity:sprint()
    self.speed = self.SPRINT_SPEED
end

function Entity:move(direction)
    if not self.isDead or Level.win then
        local directionRad = directionDictionary[direction]
        local rad = getPositiveRad(getRad(self.angle))
        --translate
        self.x = self.x + math.cos(rad + directionRad) * self.speed * deltaTime
        self.y = self.y + math.sin(rad + directionRad) * self.speed * deltaTime
        self.walkTime = self.walkTime + deltaTime
        self.altitude = 20 * math.sin(5 * self.walkTime)
        if self.walkTime >= 2.5 then self.walkTime = 0 end
        self:updateCollider()
    end
end

function Entity:rotate(deltaX)
    if not self.isDead or Level.Win then
        self.angle = self.angle + deltaX * self.sensitivity
        if math.abs(self.angle) > 360 then
            self.angle = 0
        end
    end
end

function Entity:spawn(tile)
    self.x = Tiles[tile].x + TILE_SIZE/2
    self.y = Tiles[tile].y + TILE_SIZE/2
    self.lastX = self.x
    self.lastY = self.y
    self:updateCollider()
end

function Entity:getTileX()
    return math.ceil((self.x - Tiles[1].x)/TILE_SIZE)
end

function Entity:getTileY()
    return math.ceil((self.y - Tiles[1].y)/TILE_SIZE)
end

function Entity:getCurrentTile()
    local pTileX = self:getTileX()
    local pTileY = self:getTileY()
    return (pTileY - 1) * Level.xSize + pTileX
end

function Entity:updateCollider()
    self.collider:setRelativePosition({x = self.x, y = self.y})
end

function Entity:getVelocityX()
    return (self.x - self.lastX)/deltaTime
end

function Entity:getVelocityY()
    return (self.y - self.lastY)/deltaTime
end

function Entity:getVelocityMagnitude()
    local velX = self:getVelocityX()
    local velY = self:getVelocityY()
    return getPointsDistance(0, 0, velX, velY)
end

function Entity:recordLastPos()
    self.lastX = self.x
    self.lastY = self.y
end

function Entity:receiveDamage(dmg)
    self.painSound:stop()
    self.health = self.health - dmg
    self.painSound:play()
end

function Entity:die()
    self.isDead = true
    if self.TYPE=="DynamicEntity" then Level.enemyCounter = Level.enemyCounter - 1 end
    self.deathSound:play()
end

function Entity:respawn()
    self.health = self.maxHealth
    self.isDead = false
    self:setPosition({x = self.startPosition.x, y = self.startPosition.y})
end