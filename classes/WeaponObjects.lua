require("classes.GameObject")
require("classes.SpriteObjects")

--=GENERIC WEAPON CLASS=--
WeaponObject = GameObject:new()
WeaponObject.NAME = "GenericWeaponObject"
WeaponObject.TYPE = "GameObject"

WeaponObject.damage = 25
WeaponObject.shootSound = nil
WeaponObject.reloadSound = nil
WeaponObject.interval = 1  --in seconds
WeaponObject.AnimatedSprite = nil
WeaponObject.StaticSprite = nil
WeaponObject.lastShotTime = 0
WeaponObject.shotsFired = 0
WeaponObject.isShooting = false --Informa se a arma está em processo de animação
WeaponObject.justShot = false

function WeaponObject:getHUDObject()
    return self.AnimatedSprite
end

function WeaponObject:shoot()
    if not (self.isShooting) and (((levelTime - self.lastShotTime) >= (self.interval)) or (levelTime <= self.interval)) then
        love.audio.stop(self.shootSound)
        self.isShooting = true
        self.lastShotTime = levelTime
        self.justShot = true
        self.shotsFired = self.shotsFired + 1
        self.AnimatedSprite.spriteImage = self.AnimatedSprite.spritesSet[1]
        self.AnimatedSprite.currentFrame = 1
        love.audio.play(self.shootSound)
    end
end

function WeaponObject:updateAnimation()
    if self.isShooting then
        self.AnimatedSprite:Animate()
        if (levelTime - self.lastShotTime) >= (self.interval) then
            love.audio.stop(self.reloadSound)
            self.isShooting = false
            self.AnimatedSprite.spriteImage = self.AnimatedSprite.spritesSet[1]
            self.AnimatedSprite.currentFrame = 1
            love.audio.play(self.reloadSound)
        end
    end
end

--=PISTOL CLASS==-
Pistol = WeaponObject:new()
Pistol.NAME = "Pistol"
Pistol.TYPE = "WeaponObject"

Pistol.damage = 15
Pistol.shootSound = love.audio.newSource("assets/audio/weapons/revolver/revolver_shot.mp3", "static")
Pistol.reloadSound = love.audio.newSource("assets/audio/weapons/revolver/revolver_reload.mp3", "static")
Pistol.interval = 0.5
Pistol.AnimatedSprite = nil

function Pistol:new()
    local newPistol = genericConstructor(self)
    local pAnimatedSprite = AnimatedSprite:new()
    pAnimatedSprite.animationDuration = self.interval
    pAnimatedSprite:setSpritesSet("assets/sprites/weapons/pistol/animated")
    newPistol.AnimatedSprite = pAnimatedSprite
    newPistol.AnimatedSprite.attrs = {"DONT_RENDER"}
    ObjectsHandler:Add(newPistol)
    return newPistol
end