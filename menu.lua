-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local score = require( "score" )




-- include Corona's "widget" library
local widget = require "widget"

local world
local moon
local playButton
local highscoreButton
local leftSide
local rightSide
local middleBar
local particleSystem
local left
local right
local speed
local maxspeed
local leftTouchArea
local rightTouchArea

local sceneNotCalled = true


--------------------------------------------

local function onTouchLeft(event)
	if event.phase == "began" then
		left = true
		right = false
	elseif event.phase == "ended" then
		left = false
		right = false
	end
end
local function onTouchRight(event)
	if event.phase == "began" then
		left = false
		right = true
	elseif event.phase == "ended" then
		left = false
		right = false
	end
end

local function onFrame(event)
	if 	left == false and right == false and (speed > 0 or speed < 0) then
		if speed >0.01 then
			speed = speed -0.005
		elseif speed < - 0.01 then
			speed = speed +0.005
		else
			speed = 0
		end
	elseif left == true and right == false and speed < maxspeed then
		speed = speed + 0.008
	elseif left == false and right == true and speed > -maxspeed then
		speed = speed - 0.008
	elseif left == true or right == true then
		speed = speed
	end

	leftSide.rotation = leftSide.rotation + speed
	rightSide.rotation = rightSide.rotation + speed
	middleBar.rotation = middleBar.rotation + speed
	if leftSide.rotation < -225 then
		middleBar.rotation = 0
		leftSide.rotation = 135
		rightSide.rotation = -135
	elseif leftSide.rotation > 135 then
		middleBar.rotation = 0
		leftSide.rotation = -224.9
		rightSide.rotation = -494.9
	end
	moon.rotation = moon.rotation +speed

	local gravityY 
	if leftSide.rotation <= 135 and leftSide.rotation >= -45 then
		gravityY = -1 * (leftSide.rotation - 45) / 9
	else
		gravityY = (leftSide.rotation + 135) / 9
	end
	local gravityX
	if leftSide.rotation <= 135 and leftSide.rotation >= 45 then
		gravityX = (leftSide.rotation - 135) / 9
	elseif leftSide.rotation < 45 and leftSide.rotation >= -135 then
		gravityX = -1 * (leftSide.rotation + 45) / 9
	else
		gravityX = (leftSide.rotation + 225) / 9
	end

	physics.setGravity(gravityX, gravityY)

	gravityY = nil
	gravityX = nil


	playButton.hit = particleSystem:rayCast( 0, display.contentCenterY ,display.contentCenterX, display.contentCenterY)
	if playButton.hit then
		playButton.hp = playButton.hp - 1
		playButton:setFillColor( playButton.hp/100, playButton.hp/100,  playButton.hp/100)
		if playButton.hp == 0 then
			Runtime:removeEventListener( "enterFrame", onFrame )
			physics.setGravity(0, 0)
			display.remove(particleSystem)
			particleSystem = nil
			physics.stop()
			if sceneNotCalled then
				sceneNotCalled = false
				playButton:removeSelf( )
				leftTouchArea.isHitTestable = false
				rightTouchArea.isHitTestable = false
				timer.performWithDelay( 500, function (...)
					composer.gotoScene( "level1", "fade", 500)
				end )
			end
		end
	end

end

function scene:create( event )
	local sceneGroup = self.view
	

	local scoreText = score.init({
	   filename = "scorefile.txt",
	})

	local highscore = score.load()

	print(highscore)

	left = false
	right = false
	speed = 0
	maxspeed = 0.5

	display.setDefault("isAnchorClamped",false)

	physics.start()
	physics.setGravity( 0, 0)
	physics.setDrawMode( "normal" )

	local background = display.newImageRect( "assets/map/background.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	world = display.newImageRect("assets/map/earth.png", 346, 346 )
	world.x = display.contentCenterX
	world.y = display.contentCenterY
	world.myName = "world"
	physics.addBody( world, "static",{radius=178}  )

	moon = display.newImageRect( "assets/map/moon.png", 123, 123 )
	moon.x,moon.y = world.x,world.y
	moon.anchorX = 0.5
	moon.anchorY = -2.3
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "logo.png", 692, 110 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = display.contentCenterY - world.height * 0.5 - 55

	playButton = display.newImageRect( "assets/play.png", 100, 100 )
	playButton.x, playButton.y = display.contentCenterX - world.width * 0.5 - 25, display.contentCenterY
	playButton.hp = 100

	leftSide = display.newRect( world.x,world.y, 600, 90 )
	leftSide.alpha=0
	leftSide.rotation = 135
	leftSide.anchorX = 0.6
	leftSide.anchorY = 2.8
	leftSide.myName = "leftSide"

	physics.addBody( leftSide, "static" )

	rightSide = display.newRect( world.x,world.y, 600, 90 )
	rightSide.alpha=0
	rightSide.rotation = -135
	rightSide.anchorX = 0.4
	rightSide.anchorY = 2.8
	rightSide.myName = "rightSide"

	physics.addBody( rightSide, "static" )


	middleBar = display.newRect(world.x,world.y,600,90)
	middleBar.alpha=0
	middleBar.rotation = 0
	middleBar.anchorX = 0.5
	middleBar.anchorY = -0.9
	middleBar.myName = "middleBar"

	physics.addBody( middleBar, "static" )

	particleSystem = physics.newParticleSystem{
		filename = "assets/liquidParticle.png",
		radius = 3,
		imageRadius = 5,
		gravityScale = 1.0,
		strictContactCheck = true
	}
	particleSystem:createGroup(
	    {
	        flags = { "water" , "fixtureContactListener"},
	        x = world.x,
	        y = world.y+world.height/2 + 4,
	        halfWidth = 18,
	        halfHeight = 18
	   	    }
	)
	particleSystem.myName = "Wasser"

	Runtime:addEventListener( "enterFrame", onFrame )

	leftTouchArea = display.newRect( 0, 0, display.actualContentWidth * 0.5, display.actualContentHeight )
	leftTouchArea.anchorX, leftTouchArea.anchorY = 0, 0
	leftTouchArea.isVisible = false
	leftTouchArea.isHitTestable = true
	leftTouchArea:setFillColor( 1, 1, 1 )
	leftTouchArea:addEventListener( "touch", onTouchLeft )

	rightTouchArea = display.newRect( display.actualContentWidth, 0, display.actualContentWidth * 0.5, display.actualContentHeight )
	rightTouchArea.anchorX, rightTouchArea.anchorY = 1, 0
	rightTouchArea.isVisible = false
	rightTouchArea.isHitTestable = true
	rightTouchArea:setFillColor( 1, 1, 1 )
	rightTouchArea:addEventListener( "touch", onTouchRight )

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( world )
	sceneGroup:insert( playButton)
	sceneGroup:insert( moon )
	sceneGroup:insert( leftSide )
	sceneGroup:insert( rightSide )
	sceneGroup:insert( middleBar )
	
	
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		physics.start()
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene