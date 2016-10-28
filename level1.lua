-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
local speed

--------------------------------------------

display.setStatusBar( display.HiddenStatusBar )


-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentCenterX

local pressedTimer = 0

local function onMove (event)
	pressedTimer = pressedTimer + 1
end

local function onKeyEvent (event)
	if event.keyName == "left" then
		if event.phase == "down" then
			Runtime:addEventListener( "enterFrame", onMove )
		elseif event.phase == "up" then
			Runtime:removeEventListener( "enterFrame", onMove )
			print(pressedTimer)
			pressedTimer = 0
		end
	elseif event.keyName == "right" then
		if event.phase == "down" then
			Runtime:addEventListener( "enterFrame", onMove )
		elseif event.phase == "up" then
			Runtime:removeEventListener( "enterFrame", onMove )
			print(pressedTimer)
			pressedTimer = 0
		end
	elseif event.keyName == "escape" then
		composer.gotoScene( "menu" )
		Runtime:removeEventListener( "key", onKeyEvent )
		composer.removeHidden() 
		composer.removeScene( "level1" )
	end
end

local function onTouchLeft(event)
	if event.phase == "began" then
		speed = 1
	elseif event.phase == "ended" then
		speed = 0
	end
end

local function onTouchRight(event)
	if event.phase == "began" then
		speed = -1
	elseif event.phase == "ended" then
		speed = 0
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	display.setDefault("isAnchorClamped",false)
	speed = 0

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setGravity( 0, 0)
	physics.setDrawMode( "normal" )


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newImageRect( "assets/concept_size.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )

	Runtime:addEventListener( "key", onKeyEvent )

	local worldGroup = display.newGroup()

	local world = display.newImageRect( worldGroup, "assets/world_size.png", 346, 346 )
	world.x = display.contentCenterX + 18
	world.y = display.contentCenterY
	physics.addBody( world, "static",{radius=178}  )

	local moon = display.newImageRect( worldGroup, "assets/moon_size.png", 123, 123 )
	moon.x,moon.y = world.x,world.y
	moon.anchorX = 0.5
	moon.anchorY = -2.3


	local leftSide = display.newRect( worldGroup, world.x,world.y, 600, 90 )
	--leftSide.alpha=0
	leftSide.rotation = 135
	leftSide.anchorX = 0.6
	leftSide.anchorY = 2.8

	physics.addBody( leftSide, "static" )

	local rightSide = display.newRect( worldGroup, world.x,world.y, 600, 90 )
	--rightSide.alpha=0
	rightSide.rotation = -135
	rightSide.anchorX = 0.4
	rightSide.anchorY = 2.8

	physics.addBody( rightSide, "static" )

	local particleSystem = physics.newParticleSystem{
		filename = "assets/liquidParticle.png",
		radius = 3,
		imageRadius = 5,
		gravityScale = 1.0,
		strictContactCheck = true,
		pressureStrength = 0.1
	}

	-- Create a "block" of water (LiquidFun group)
	particleSystem:createGroup(
	    {
	        flags = { "water" },
	        x = world.x,
	        y = world.y+world.height/2 + 4,
	        --color = { 0.1, 0.1, 1, 0.5 },
	        halfWidth = 16,
	        halfHeight = 16
	    }
	)


	local function rotateBars( )
		leftSide.rotation = leftSide.rotation + speed
		rightSide.rotation = rightSide.rotation + speed
		if leftSide.rotation < -225 then
			leftSide.rotation = 135
			rightSide.rotation = -135
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
	end

	Runtime:addEventListener( "enterFrame", rotateBars )


	local function particleSystemCollision( self, event )
	 	print(event.phase)
	   --print( "Collision with particleSystem." )
	   if ( event.phase == "began" ) then
	 	print ("collision", "begin")
	   end
	end
	 
	particleSystem.particleCollision = particleSystemCollision
	particleSystem:addEventListener( "particleCollision" ,particleSystemCollision)




	local leftTouchArea = display.newRect( 0, 0, display.actualContentWidth * 0.5, display.actualContentHeight )
	leftTouchArea.anchorX, leftTouchArea.anchorY = 0, 0
	leftTouchArea.isVisible = false
	leftTouchArea.isHitTestable = true
	leftTouchArea:setFillColor( 1, 1, 1 )
	leftTouchArea:addEventListener( "touch", onTouchLeft )

	local rightTouchArea = display.newRect( display.actualContentWidth, 0, display.actualContentWidth * 0.5, display.actualContentHeight )
	rightTouchArea.anchorX, rightTouchArea.anchorY = 1, 0
	rightTouchArea.isVisible = false
	rightTouchArea.isHitTestable = true
	rightTouchArea:setFillColor( 1, 1, 1 )
	rightTouchArea:addEventListener( "touch", onTouchRight )

	sceneGroup:insert(leftTouchArea)
	sceneGroup:insert(rightTouchArea)
end


function scene:show( event )
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

function scene:hide( event )
	local sceneGroup = self.view
	Runtime:removeEventListener( "key", onKeyEvent )
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

function scene:destroy( event )
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	--package.loaded[physics] = nil
	--physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene