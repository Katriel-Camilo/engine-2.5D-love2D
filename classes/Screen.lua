require("uniques.HUD")

Screen = {}
Screen.fullscreen = false
Screen.width, Screen.height = love.graphics.getDimensions()

function Screen:loadGameScreen(player)
    HUD:load()
    HUD:resize(self.width, self.height)
end

function Screen:toggleFullscreen()
    self.fullscreen = not self.fullscreen
    love.window.setFullscreen( self.fullscreen )
    self.width, self.height = love.graphics.getDimensions()
    HUD:resize(self.width, self.height)
end