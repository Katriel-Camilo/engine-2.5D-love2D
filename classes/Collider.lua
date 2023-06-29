BoxCollider = GameObject:new()
BoxCollider.NAME = "BoxCollider"
BoxCollider.TYPE = "Collider"

BoxCollider.width = 0
BoxCollider.height = 0
BoxCollider.onCollision = false

function BoxCollider:new(entity)
    local newBoxCollider = genericConstructor(self)
    ObjectsHandler:Add(newBoxCollider)
    local w = entity:getWidth()
    local h = entity:getHeight()
    newBoxCollider.width = w
    newBoxCollider.height = h
    newBoxCollider:setRelativePosition({x = entity:getX(), y = entity:getY()})
    return newBoxCollider
end

function BoxCollider:setSize(width, height)
    self.width = width
    self.height = height
end

function BoxCollider:getWidth()
    return self.width
end

function BoxCollider:getHeight()
    return self.height
end

function BoxCollider:setRelativePosition(point)
    self.x = point.x - self.width/2
    self.y = point.y - self.height/2
end