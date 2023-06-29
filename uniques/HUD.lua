HUD = {}

HUD.width = 0
HUD.height = 0
HUD.weaponPositionX = 0
HUD.weaponPositionY = 0
HUD.proportion = 1
HUD.weaponImg = nil
HUD.font = love.graphics.newFont("assets/fonts/seven.ttf", 24)
HUD.font_big = love.graphics.newFont("assets/fonts/seven.ttf", 40)
HUD.healthImage = love.graphics.newImage("assets/HUD/health_new.png")

function HUD:load()
    self:loadWeapon()
end

function HUD:loadWeapon()
    self.weaponImg = Player.weapon.AnimatedSprite:getSpriteImage()
    self.weaponPositionX = (self.width - self.weaponImg:getWidth() * self.proportion * 3)/2
    self.weaponPositionY = self.height - self.weaponImg:getHeight() * self.proportion * 3
end

function HUD:resize(w, h)
    self.width = w
    self.height = h
    self.weaponPositionX = self.width/2
    self.weaponPositionY = self.height
    self.proportion = self.width/D_SCREEN_RESOLUTION
end

function HUD:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.weaponImg, self.weaponPositionX + Player:getAltitude()/2, self.weaponPositionY, 0, 3 * self.proportion, 3 * self.proportion)
    love.graphics.setColor(1,0,0,0.5) --Crosshair Color
    love.graphics.circle("fill", Screen.width/2, Screen.height/2, 5) --Crosshair
    love.graphics.setFont(self.font)
    love.graphics.setColor(1,1,1)
    love.graphics.print("ENEMIES LEFT: " .. Level.enemyCounter, 10, Screen.height - 30)
    love.graphics.setFont(self.font_big)
    if Player.health > 70 then
        love.graphics.setColor(0,1,0)
    elseif Player.health > 30 then
        love.graphics.setColor(1,1,0)
    else
        love.graphics.setColor(1,0,0)
    end
    love.graphics.print(Player.health, Screen.width - 80, Screen.height - 60)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.healthImage, Screen.width - 140, Screen.height - 40, 0, 0.4, 0.4, self.healthImage:getHeight()/2, self.healthImage:getWidth()/2)
end

function HUD:drawDeathScreen()
    love.graphics.setFont(self.font_big)
    love.graphics.setColor(1, 0, 0)
    local textBig = 'GAME OVER!'
    local textWidth = self.font_big:getWidth(textBig)
    local textHeight = self.font_big:getHeight(textBig)
    love.graphics.print('GAME OVER!', (Screen.width - textWidth)/2, (Screen.height - textHeight)/2)
    love.graphics.setFont(self.font)
    local textSmall = 'Press "R" to restart'
    local textSWidth = self.font:getWidth(textSmall)
    local textSHeight = self.font:getHeight(textSmall)
    love.graphics.print('Press "R" to restart', (Screen.width - textSWidth)/2, (Screen.height - textSHeight)/2 + textHeight + 10)
end

function HUD:drawWinScreen()
    love.graphics.setFont(self.font_big)
    love.graphics.setColor(1, 1, 0)
    local textBig = 'GAME OVER!'
    local textWidth = self.font_big:getWidth(textBig)
    local textHeight = self.font_big:getHeight(textBig)
    love.graphics.print('YOU WIN!', (Screen.width - textWidth)/2, (Screen.height - textHeight)/2)
    love.graphics.setFont(self.font)
    local textSmall = 'Press "R" to restart'
    local textSWidth = self.font:getWidth(textSmall)
    local textSHeight = self.font:getHeight(textSmall)
    love.graphics.print('Press "R" to restart', (Screen.width - textSWidth)/2, (Screen.height - textSHeight)/2 + textHeight + 10)
end