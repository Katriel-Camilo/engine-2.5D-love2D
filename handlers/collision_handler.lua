require("handlers.objects_handler")
--=COLLISION HANDLER=--
CollisionHandler = {}

function CollisionHandler:checkBoxCollision()
    local dEntities =  ObjectsHandler:getByType("DynamicEntity")
    local collider = nil
    local cTile = 0

    --Check for walls collisions every frame around each entity
    for _, entity in pairs(dEntities) do
        local entX = entity:getX()
        local entY = entity:getY()
        local entTileX = entity:getTileX()
        local entTileY = entity:getTileY()
        local cTile = entity:getCurrentTile()
        local collider = entity.collider
        local entDeltaX = entity.x - entity.lastX
        local entDeltaY =  entity.y - entity.lastY
        collider.onCollision = false

        local colX = collider:getX()
        local colY = collider:getY()
        local colWidth = collider:getWidth()
        local colHeight = collider:getWidth()

        local xCollision = (colX <= (entTileX - 1) * TILE_SIZE) and not(Level.map[cTile - 1] == 0) or (colX + colWidth) >= entTileX * TILE_SIZE and not(Level.map[cTile + 1] == 0)
        local yCollision = (colY <= (entTileY - 1) * TILE_SIZE) and not(Level.map[cTile - Level.xSize] == 0) or (colY + colHeight >= (entTileY) * TILE_SIZE) and not(Level.map[cTile + Level.xSize] == 0)

        --X-axis Collision
        if xCollision then
            collider.onCollision = true
            entity:setPosition({x = entX - entDeltaX, y = entY})
            entX = entity:getX()
        end

        --Y-axis Collision
        if yCollision then
            collider.onCollision = true
            entity:setPosition({x = entX, y = entY - entDeltaY})
            entY = entity:getY()
        end

        --Diagonal Collisions
        if not collider.onCollision then

            local lastColYup = entity.lastY - collider.height/2 
            local lastColYDown = entity.lastY + collider.height/2 

            if(colX <= (entTileX - 1) * TILE_SIZE and colY <= (entTileY - 1) * TILE_SIZE) and not(Level.map[cTile - Level.xSize - 1] == 0) then
                --Top-left Collision
                collider.onCollision = true
                if lastColYup < (entTileY - 1) * TILE_SIZE then
                    entity:setPosition({x = entX - entDeltaX, y = entY})
                else
                    entity:setPosition({x = entX, y = entY - entDeltaY})
                end
            elseif(colX + colWidth >= (entTileX) * TILE_SIZE and colY <= (entTileY - 1) * TILE_SIZE) and not(Level.map[cTile - Level.xSize + 1] == 0) then
                --Top-right Collision
                collider.onCollision = true
                if lastColYup < (entTileY - 1) * TILE_SIZE then
                    entity:setPosition({x = entX - entDeltaX, y = entY})
                else
                    entity:setPosition({x = entX, y = entY - entDeltaY})
                end
            elseif(colX <= (entTileX - 1) * TILE_SIZE and colY + colHeight >= (entTileY) * TILE_SIZE) and not(Level.map[cTile + Level.xSize - 1] == 0) then
                --Bottom-right Collision
                collider.onCollision = true
                if lastColYDown > (entTileY) * TILE_SIZE then
                    entity:setPosition({x = entX - entDeltaX, y = entY})
                else
                    entity:setPosition({x = entX, y = entY - entDeltaY})
                end
            elseif(colX + colWidth >= (entTileX) * TILE_SIZE and colY + colHeight >= (entTileY) * TILE_SIZE) and not(Level.map[cTile + Level.xSize + 1] == 0) then
                --Bottom-left Collision
                collider.onCollision = true
                if lastColYDown > (entTileY) * TILE_SIZE then
                    entity:setPosition({x = entX - entDeltaX, y = entY})
                else
                    entity:setPosition({x = entX, y = entY - entDeltaY})
                end
            end
        end
    end
end