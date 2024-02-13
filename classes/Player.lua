require("libs.math_helpers")
require("libs.utilities")
require("handlers.control_handler")

require("classes.Entities")
require("classes.Render")
require("classes.Collider")
require("classes.WeaponObjects")


--FAZER PLAYER SE TORNAR ÚNICO

--==Player class=--
Player = Entity:new()
Player.TYPE = "DynamicEntity"
Player.NAME = "Player"

--Properties
Player.FOV = PI / 3 --RAD
Player.WALK_SPEED = 128
Player.SPRINT_SPEED = 160
Player.painSound = love.audio.newSource("assets/audio/player/audio/pain.wav","static")
Player.deathSound = love.audio.newSource("assets/audio/player/audio/death.wav","static")
Player.width = 10
Player.height = 10
Player.speed = 40
Player.angle = -90
Player.walkTime = 0
Player.altitude = 0
Player.sensitivity = 0.2
Player.collider = BoxCollider:new(Player)
Player.weapon = Pistol:new()
Player.maxHealth = 100

ObjectsHandler:Add(Player)

function Player:getAltitude()
    return self.altitude
end

function Player:renderLevel(level, sprites)
    return Render:getRenderObjects(self, level, sprites)
end

function Player:shoot()
    if not Player.isDead and not Level.win then
        self.weapon:shoot()
    end
end

function Player:updateAnimation()
    self.weapon:updateAnimation()
end

function Player:checkHealth()
    if self.health < 1 then
        self:die()
    end
end