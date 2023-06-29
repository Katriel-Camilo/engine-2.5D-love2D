require("libs.utilities")
require("handlers.objects_handler")

--Abstract class inherited by all game objects--
GameObject = {}

GameObject.x = 0   
GameObject.y = 0

GameObject.NAME = "GameObject"
GameObject.TYPE = "GenericGameObject"

GameObject.attrs = {}

function GameObject:new()
    return genericConstructor(self)
end

function GameObject:getPosition()
    return {x = self.x, y = self.y}
end

function GameObject:getX()
    return self.x
end

function GameObject:getY()
    return self.y
end

function GameObject:setPosition(point)
    self.x = point.x
    self.y = point.y
end

function GameObject:getType()
    return self.type
end