function genericConstructor(class)
    newClass = {}
    setmetatable(newClass, class)
    class.__index = class
    return newClass
end

function concatTables(t1, t2)
    for _, v in pairs(t2) do
        table.insert(t1, v)
    end
    return t1
end