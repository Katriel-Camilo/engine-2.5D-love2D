require("libs.utilities")

require("classes.GameObject")
require("classes.Screen")

--=GENERIC SPRITE OBJECT CLASS=--
SpriteObject = GameObject:new()
SpriteObject.NAME = "GenericSpriteObject"
SpriteObject.TYPE = "GameObject"

SpriteObject.aspectRatio = 0
SpriteObject.spriteImage = nil
SpriteObject.scale = 1
SpriteObject.projectionScale = 1
SpriteObject.width = 0  --Comprimento da imagem ao ser escalada para a tela
SpriteObject.height = 0 --Altura da imagem ao ser escalada para a tela
SpriteObject.screenX = 0
SpriteObject.projectionHeight = 0
SpriteObject.projectionWidth = 0
SpriteObject.customScaleMultiplier = 100

function SpriteObject:getWidth()
    return self.width
end

function SpriteObject:getHeight()
    return self.height
end

function SpriteObject:setAspectRatio()
    local image = self:getSpriteImage()
    self.aspectRatio = image:getWidth()/image:getHeight()
end

function SpriteObject:getAspectRatio()
    return self.aspectRatio
end

function SpriteObject:getCenter()
    local image = self:getSpriteImage()
    local x = image:getWidth()/2
    local y = image:getHeight()/2
    return {x = x, y = y}
end

function SpriteObject:scaleToScreen()
    local image = self:getSpriteImage()
    self.scale = Screen.width/D_SCREEN_RESOLUTION
    self.width = image:getWidth() * self.scale
    self.height = image:getHeight() * self.scale
end

function SpriteObject:setProjectionSize(distanceToScreen)
    local imageHeight = self.height
    self.projectionScale = imageHeight/distanceToScreen
    self.projectionHeight = imageHeight * self.projectionScale
    self.projectionWidth = self.aspectRatio * self.projectionHeight
end

--=STATIC SPRITE CLASS=-
StaticSprite = SpriteObject:new()
StaticSprite.NAME = "StaticSprite"
StaticSprite.TYPE = "SpriteObject"

function StaticSprite:new()
    local newStaticSprite = genericConstructor(self)
    ObjectsHandler:Add(newStaticSprite)
    return newStaticSprite
end

function StaticSprite:setSpriteImage(image)
    self.spriteImage = image
    self.width = self.spriteImage:getWidth()
    self.height = self.spriteImage:getHeight()
    self:setAspectRatio()
end

function StaticSprite:getSpriteImage()
    return self.spriteImage
end


--=ANIMATED SPRITE CLASS=-
AnimatedSprite = SpriteObject:new()
AnimatedSprite.NAME = "AnimatedSprite"
AnimatedSprite.TYPE = "SpriteObject"

AnimatedSprite.animationDuration = 1    --in seconds
AnimatedSprite.spritesSet = nil
AnimatedSprite.currentFrame = 1
AnimatedSprite.timePerFrame = 0
AnimatedSprite.animationTime = 0
AnimatedSprite.numOfFrames = 0

function AnimatedSprite:new()
    local newAnimatedSprite = genericConstructor(self)
    ObjectsHandler:Add(newAnimatedSprite)
    return newAnimatedSprite
end

function AnimatedSprite:setSpritesSet(sprite_set_path)
    self.spritesSet = {}
    self.spritesSet = love.filesystem.getDirectoryItems(sprite_set_path)
    table.sort(self.spritesSet)
    for k, v in pairs(self.spritesSet) do
        self.spritesSet[k] = love.graphics.newImage(sprite_set_path .. '/' .. v)
    end
    self.numOfFrames = table.getn(self.spritesSet)
    self.timePerFrame = self.animationDuration/self.numOfFrames
    self.animationTime = 0
    self.spriteImage = self.spritesSet[1]
    self.width = self.spriteImage:getWidth()
    self.height = self.spriteImage:getHeight()
    self:setAspectRatio()
end

function AnimatedSprite:getSpritesSet()
    return self.spritesSet
end

function AnimatedSprite:getSpriteImage()
    return self.spriteImage
end

function AnimatedSprite:Animate()
    self.animationTime = self.animationTime + deltaTime
    if self.animationTime >= self.timePerFrame then
        if self.currentFrame < self.numOfFrames then
            self.currentFrame = self.currentFrame + 1
        else
            self.currentFrame = 1
        end
        self.spriteImage = self.spritesSet[self.currentFrame]
        self.width = self.spriteImage:getWidth()
        self.height = self.spriteImage:getHeight()
        self.animationTime = 0
    end
end
