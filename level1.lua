-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create(event)

    -- Called when the scene's view does not exist.
    --
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

    local sceneGroup = self.view

    -- We need physics started to add bodies, but we don't want the simulaton
    -- running until the scene is on the screen.
    physics.start()
    physics.pause()


    -- create a grey rectangle as the backdrop
    -- the physical screen will likely be a different shape than our defined content area
    -- since we are going to position the background from it's top, left corner, draw the
    -- background at the real top, left corner.
    local background = display.newRect(display.screenOriginX, display.screenOriginY, screenW, screenH)
    background.anchorX = 0
    background.anchorY = 0
    background:setFillColor(.5)

    local speedText = display.newText( "Speed: 0", 150, 50, 240, 30, native.systemFont, 16 )
    speedText:setFillColor( 0, 0, 0 )

    -- make a crate (off-screen), position it, and rotate slightly
    local crate = display.newImageRect("assets/img/bunny.png", 26, 37)
    crate.x, crate.y = 160, screenH - 100
    crate.rotation = 0

    local direction = 1
    local maxAngle = 55
    local maxVel = 3
    local vx = 1

    local function onTouch(event)
        if (event.phase == "began") then
            direction = -direction
        end
    end

    local function onUpdate(event)
        if crate.x < 0 then
            crate.x = screenW
        end
        if crate.x > screenW then
            crate.x = 0
        end
        if (crate.rotation < maxAngle and direction > 0 or crate.rotation > -maxAngle and direction < 0) then
            crate.rotation = crate.rotation + ( 5 * direction)
        end
        if (vx < maxVel and crate.rotation < 0 or vx > -maxVel and crate.rotation > 0) then
            vx = vx + math.sin(crate.rotation) / 20
        end

        camera.y = camera.y + 1

        crate.x = crate.x - vx
        speedText.text = "speed: " .. math.round(vx*100)/100 .. " | r: " .. crate.rotation
    end

    Runtime:addEventListener("enterFrame", onUpdate)
    background:addEventListener("touch", onTouch)

    -- all display objects must be inserted into group
    sceneGroup:insert(background)
    sceneGroup:insert(crate)
    sceneGroup:insert(speedText)
end


function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        -- Called when the scene is now on screen
        --
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc.
        physics.start()
    end
end

function scene:hide(event)
    local sceneGroup = self.view

    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
        physics.stop()
    elseif phase == "did" then
        -- Called when the scene is now off screen
    end
end

function scene:destroy(event)

    -- Called prior to the removal of scene's "view" (sceneGroup)
    --
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc.
    local sceneGroup = self.view

    package.loaded[physics] = nil
    physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

return scene