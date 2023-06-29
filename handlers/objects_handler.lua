--=OBJECT HANDLER=--
ObjectsHandler = {}

ObjectsHandler.CurrentGameObjects = {}

function ObjectsHandler:getAllObjects()
    return self.CurrentGameObjects
end

function ObjectsHandler:getByType(type)
    local objsOfType = {}
    for _, obj in pairs(self:getAllObjects()) do
        if obj.TYPE == type then table.insert(objsOfType, obj) end
    end
    return objsOfType
end

function ObjectsHandler:getByClassName(className)
    local objsOfClass = {}
    for _, obj in pairs(self:getAllObjects()) do
        if obj.NAME == className then table.insert(objsOfClass, obj) end
    end
    return objsOfClass
end

function ObjectsHandler:Add(newObject)
    table.insert(self.CurrentGameObjects, newObject)
end