require("classes.SpriteObjects")

--=GENERIC STATIC SCENARIO OBJECT CLASS=--
StaticScenarioObject = GameObject:new()
StaticScenarioObject.NAME = "GenericStaticScenarioObject"
StaticScenarioObject.TYPE = "GameObject"

StaticScenarioObject.soSprite = nil

function StaticScenarioObject:updateSprite(sprite)
    self.soSprite = sprite
end

--=GENERIC DYNAMIC SCENARIO OBJECT CLASS=--
DynamicScenarioObject = GameObject:new()
DynamicScenarioObject.NAME = "GenericDynamicScenarioObject"
DynamicScenarioObject.TYPE = "GameObject"

DynamicScenarioObject.SpriteObject = nil

function DynamicScenarioObject:getSprite()
    return self.SpriteObject:getSpriteImage()
end

--=FIRE OBJECT=--
Fire = DynamicScenarioObject:new()
Fire.NAME = "Fire"
Fire.TYPE = "DynamicScenarioObject"

function Fire:new(x, y)
    newFire = genericConstructor(self)
    newFire:setPosition({x = x,  y = y})
    newFire.SpriteObject = AnimatedSprite:new()
    newFire.SpriteObject.animationDuration = 1
    newFire.SpriteObject:setSpritesSet("assets/sprites/objects/animated/fire")
    newFire.SpriteObject:setPosition({x = x, y = y})
    ObjectsHandler:Add(newFire)
    return newFire
end