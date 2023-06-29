--=GENERIC BONUS CLASS=--
BonusObject = GameObject:new()
BonusObject.NAME = "GenericBonusObject"
BonusObject.TYPE = "GameObject"

BonusObject.radius = 20
BonusObject.SpriteObject = nil
BonusObject.isActive = true

function BonusObject:respawn()
    self:setPosition({x = self.startPosition.x, y = self.startPosition.y})
    self.SpriteObject:setPosition({x = self.startPosition.x, y = self.startPosition.y})
    self.isActive = true
end

--==HEALTH BONUS==--
HealthBonus = BonusObject:new()
HealthBonus.NAME = "HealthBonus"
HealthBonus.TYPE = "Bonus"

HealthBonus.startPosition = {}
HealthBonus.spriteImage = love.graphics.newImage("assets/sprites/objects/static/health/health.png")
HealthBonus.healthAmmount = 15

function HealthBonus:new(x, y)
    local newHealthBonus = genericConstructor(self)
    newHealthBonus:setPosition({x = x, y = y})
    newHealthBonus.startPosition = {x = x, y = y}
    newHealthBonus.SpriteObject = StaticSprite:new()
    newHealthBonus.SpriteObject:setSpriteImage(newHealthBonus.spriteImage)
    newHealthBonus.SpriteObject:setPosition({x = x, y = y})
    newHealthBonus.SpriteObject.customScaleMultiplier = 1
    ObjectsHandler:Add(newHealthBonus)
    return newHealthBonus
end

function HealthBonus:apply()
    if not (Player.health == Player.maxHealth) then
        Player.health = math.min(Player.maxHealth, Player.health + self.healthAmmount)
        self.isActive = false
        self.SpriteObject:setPosition({x = 0, y = 0})
    end
end
