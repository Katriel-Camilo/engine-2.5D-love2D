require("libs.math_helpers")
require("classes.Screen")
require("handlers.objects_handler")

Render = {}

Render.camera = nil

function Render:getWallsInfo(camera) 
    local column = math.ceil(camera.x/TILE_SIZE)
    local line = math.ceil(camera.y/TILE_SIZE)

    local rayRad
    local playerRad = getRad(camera.angle)
    local positivePlayerRad = getPositiveRad(getRad(camera.angle))

    local column_position_x = 0
    
    local endPoints = {}
    --Para cada raio
    for rayRad = playerRad - camera.FOV/2, playerRad + camera.FOV/2, camera.FOV/Screen.width do
        local positiveRayRad = getPositiveRad(rayRad)
        
        local epX_v = 0
        local epY_v = 0
        local isWall = false
        local counter = 0
        local incrementX = 1
        local tile
        local hitAxis
        --Para cada linha vertical cruzada pelo raio
        while not isWall and
            epX_v < TILE_SIZE * Level.xSize and
            epX_v >= 0 and epY_v < TILE_SIZE * Level.ySize(Level) and
            epY_v >= 0 do
            if positiveRayRad <= PI/2 or positiveRayRad >= 3 * PI/2 then
                epX_v = (column + counter) * TILE_SIZE
            else
                epX_v = (column - 1 - counter) * TILE_SIZE
                incrementX = 0
            end

            --MULTIPLICAÇÃO: direção * distância X
            epY_v = camera.y + math.tan(rayRad) * (epX_v - camera.x)

            tileX = epX_v/TILE_SIZE + incrementX
            tileY = math.floor(epY_v/TILE_SIZE)

            counter = counter + 1
            tile = tileY * Level.xSize + tileX

            if not (Level.map[tile] == 0) and not (Level.map[tile] == nil) then
                isWall = true
                valueV = Level.map[tile]
            end
        end

        isWall = false
        local epX_h = 0
        local epY_h = 0
        counter = 0
        local decrementY = 0
        --Para cada linha horizontal cruzada pelo raio
        while not isWall and
        epX_h >= 0 and
        epY_h >= 0 and
        epX_h <= Level.xSize * TILE_SIZE and
        epY_h <= Level.ySize(Level) * TILE_SIZE do

            if positiveRayRad < PI then
                epY_h = (line + counter) * TILE_SIZE
            else
                epY_h = (line - 1 - counter) * TILE_SIZE
                decrementY = -1
            end

            epX_h = camera.x + (epY_h - camera.y)/math.tan(rayRad)

            tileY = epY_h/TILE_SIZE + decrementY
            tileX = math.ceil(epX_h/TILE_SIZE)

            counter = counter + 1
            tile = tileY * Level.xSize + tileX

            if not (Level.map[tile] == 0) and not (Level.map[tile] == nil) then
                isWall = true
                valueH = Level.map[tile]
            end

        end

        --Radiano positivo do raio em relação ao vetor de rotação (heading) do jogador
        local relativeRayRad = math.abs(positivePlayerRad - positiveRayRad)

        if positivePlayerRad < camera.FOV or positivePlayerRad > 2 * PI - camera.FOV then
            if math.abs(positiveRayRad - positivePlayerRad) > camera.FOV then
                relativeRayRad = 2 * PI - math.abs(positiveRayRad - positivePlayerRad)
            end
        end

        --Arredondamento forçado do primeiro ângulo
        if relativeRayRad > camera.FOV then
            relativeRayRad = camera.FOV
        end

        --Ajuste do efeito de olho de peixe
        local cosValue = math.abs(math.cos(relativeRayRad))

        --Distância entre o ponto final do raio (parede) e o plano (linha) da tela
        local v_distance = getPointsDistance(epX_v, epY_v, camera.x, camera.y) * cosValue
        local h_distance = getPointsDistance(epX_h, epY_h, camera.x, camera.y) * cosValue

        if h_distance < v_distance then
            table.insert(endPoints, {value = valueH, x = epX_h, y = epY_h, distance = h_distance, hitAxis='x', rad = positiveRayRad, column_position_x = column_position_x, renderType="wall"})
        else
            table.insert(endPoints, {value = valueV, x = epX_v, y = epY_v, distance = v_distance, hitAxis='y', rad = positiveRayRad, column_position_x = column_position_x, renderType="wall"})
        end
        column_position_x = column_position_x + 1
    end
    return endPoints
end

function Render:getSpritesInfo(camera, spriteObjects)
    local dx
    local dy
    local theta --Camera Angle
    local gamma -- Sprite direction in relation to player angle
    local delta -- Angle between the sprite and the player direction
    local delta_rays

    local screenX
    local dist
    local proj_dist

    local imgHalf
    local spriteInfo = {}
    for _, sprite in pairs(spriteObjects) do
        dx = sprite.x - camera.x
        dy = sprite.y - camera.y
        theta = getPositiveRad(getRad(camera:getAngle()))
        gamma = math.atan2(dy, dx)

        delta = gamma - theta
        if (dx > 0 and theta > PI) or (dx < 0 and dy < 0) then delta = delta + 2 * PI end
        
        delta_rays = delta/(camera:getFOV()/num_rays)
        screenX = (math.floor(num_rays/2) + delta_rays) --Screen X offset
        proj_dist = getPointsDistance(camera.x, camera.y, sprite.x, sprite.y) * math.cos(delta)

        imgHalf = (sprite:getHeight()/proj_dist) * (sprite:getWidth())/2
        
        if (screenX > -imgHalf) and (screenX < Screen.width + imgHalf) and (proj_dist > 25) then
            sprite.screenX = screenX
            table.insert(spriteInfo, {sprite = sprite, screenX = screenX, distance = proj_dist, renderType="sprite"})
        end
    end
    return spriteInfo
end

function Render:getRenderObjects(camera, spriteObjects)
    local walls = self:getWallsInfo(camera)
    local sprites = self:getSpritesInfo(camera, spriteObjects)
    local renderObjects = concatTables(walls, sprites)
    table.sort(renderObjects, function (obj1, obj2)
    if obj1.distance > obj2.distance then return true end return false    
    end )
    return renderObjects
end

function Render:draw(spriteObjects)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0, Screen.height/2, Screen.width, Screen.height/2)
    love.graphics.setColor(1,1,1)
    local renderInfo = Render:getRenderObjects(Player, spriteObjects)

    --Walls Variables
    local column_height
    local column_width = 1
    local column_position_y
    local quad
    local column_position_x = 0
    local decrement --This value change the texture drawing direction

    --Sprites Variables
    local spriteX
    local spriteHeight
    local scale
    local centerPoint
    local spriteImg
    local realSpriteHeight

    local dont_render = false
    for _, v in pairs(renderInfo) do
        if(v.renderType == "sprite") then
            dont_render = false

            for _, attr in pairs(v.sprite.attrs) do
                if attr == "DONT_RENDER" then
                    dont_render = true
                    break
                end
            end

            if not dont_render then
                love.graphics.setColor(0.8 - v.distance * 5e-4, 0.8 - v.distance * 5e-4, 0.8 - v.distance * 5e-4)
                v.sprite:setProjectionSize(v.distance)
                spriteX = v.screenX
                scale = v.sprite.projectionScale * v.sprite.customScaleMultiplier
                centerPoint = v.sprite:getCenter()
                spriteImg = v.sprite:getSpriteImage()
                realSpriteHeight = spriteImg:getHeight()
                love.graphics.draw(spriteImg, spriteX, (Screen.height + Player:getAltitude())/2 + (realSpriteHeight/4) * scale, 0, scale, scale, centerPoint.x, centerPoint.y)
            end
        else
            decrement = 0
            column_height = clamp(0, (TILE_SIZE/v.distance) * (Screen.width/2) / math.tan(Player:getFOV()/2), Screen.height + 100000)
            column_position_y = (Screen.height-column_height + Player:getAltitude())/2
            
            if v.hitAxis == 'x' then
                love.graphics.setColor(1 - v.distance * 5e-4,1 - v.distance * 5e-4, 1 - v.distance * 5e-4)
                if v.rad < PI then decrement = -1 end
                quad = love.graphics.newQuad(math.abs(decrement + math.fmod(v.x / TILE_SIZE, 1)) * column_height, 0, column_width, column_height, column_height, column_height)
            else
                love.graphics.setColor(0.8 - v.distance * 5e-4, 0.8 - v.distance * 5e-4, 0.8 - v.distance * 5e-4)
                if v.rad > PI/2 and v.rad < 3 * PI/2 then decrement = -1 end
                quad = love.graphics.newQuad(math.abs(decrement + math.fmod(v.y / TILE_SIZE, 1)) * column_height, 0, column_width, column_height, column_height, column_height)
            end
            love.graphics.draw(Level.textures[v.value], quad, v.column_position_x, column_position_y)
        end
    end

end