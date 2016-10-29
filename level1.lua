-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup

-- include Corona's "physics" library
local physics = require "physics"
local moon 
local speed
local devils = {}
local flyingDevils = {}
local world
local left
local right
local speed
local leftSide
local rightSide
local middleBar
local devilIdle
local particleSystem
local ray = {}


--------------------------------------------

display.setStatusBar( display.HiddenStatusBar )


-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentCenterX

local pressedTimer = 0
local spawnTimer = 0
local spawnAfter = 300
local devilsCounter = 0
local flyingDevilsCounter = 0

local devilIdleSheetOptions = {
    width = 60,
    height = 75,
    numFrames = 6,
    sheetContentWidth = 360,
    sheetContentHeight = 75
}

local devilSummonSheetOptions = {
    width = 60,
    height = 75,
    numFrames = 2,
    sheetContentWidth = 160,
    sheetContentHeight = 75
}

local devilIdleSequence = {
	{name = "devilIdle", frames = { 1, 2, 3, 4, 5, 6 }, time = 2000 }
}

local devilSummonSequence = {
	{name = "devilSummon", frames = {1, 2}, time = 500}
}

local devilIdleSheet = graphics.newImageSheet( "assets/character/spritesheets/devil_Idle_spritesheet.png", devilIdleSheetOptions )
local devilSummonSheet = graphics.newImageSheet( "assets/character/spritesheets/devil_flying_spritesheet.png", devilSummonSheetOptions)

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


local function createDevil(...)
	local devilIdle = display.newSprite( devilIdleSheet, devilIdleSequence )
	devilIdle.x, devilIdle.y = world.x, world.y
	devilIdle.anchorX, devilIdle.anchorY = 0.4, 3
	local randomSpawn = math.random(360)
	devilIdle.rotation = randomSpawn
	return devilIdle
end

local function setDevil()
	devilsCounter = devilsCounter + 1
	devils[devilsCounter] = createDevil()
	devils[devilsCounter].hp = 100
	sceneGroup:insert(devils[devilsCounter])
	devils[devilsCounter]:setSequence( "devilIdle" )
	devils[devilsCounter]:play()
end

local function createFlyingDevil(...)
	local flyingDevil = display.newSprite( devilSummonSheet, devilSummonSequence)
	flyingDevil.x, flyingDevil.y = world.x, display.actualContentHeight + 100
	return flyingDevil
end

local function flyingDevil( devilObject )
	transition.to( devilObject, {time = 3000, x = world.x, y = world.y, onComplete = setDevil} )
end

local function spawnDevil (event)
	spawnTimer = spawnTimer + 1
	if spawnTimer >= spawnAfter then
		flyingDevilsCounter = flyingDevilsCounter + 1		
		flyingDevils[flyingDevilsCounter] = createFlyingDevil()
		flyingDevil(flyingDevils[flyingDevilsCounter])
		spawnTimer = 0
	end	
end



local drawHitLine = function( x1,y1,x2,y2)
	ray[#ray+1] = display.newLine(x1,y1,x2,y2)
end

local function onFrame( )
	if 	left == false and right == false and (speed > 0 or speed < 0) then
		if speed >0.01 then
			speed = speed -0.01
		elseif speed < - 0.01 then
			speed = speed +0.01
		else
			speed = 0
		end
	elseif left == true and right == false and speed < maxspeed then
		speed = speed + 0.01
	elseif left == false and right == true and speed > -maxspeed then
		speed = speed - 0.01
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



	------------------------------------------------------------
	for i = 1,#ray do
		display.remove( ray[i] ) ; ray[i] = nil
	end

	local hits = {}
	local toDelete = {}
	for k,v in pairs(devils) do
		if devils[k] then
			if devils[k].rotation then
				angle = devils[k].rotation - 90
				x = world.x + (world.width/2 * math.cos(math.rad(angle)))
				y = world.y + (world.width/2 * math.sin(math.rad(angle)))
				if devils[k].rotation > 180 and devils[k].rotation < 270 then
					devils[k].hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
				elseif devils[k].rotation > 0 and devils[k].rotation < 90  then
					devils[k].hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
				else
					devils[k].hit = particleSystem:rayCast( x-20, y-20, x+20, y+20 )
				end

				if devils[k].hit then
					print ("auauauauau")
					--print ("auauauauau")
					if devils[k].isVisible then
						devils[k].hp = devils[k].hp - 1
						if devils[k].hp < 1 then
							print ("remove")
							devils[k].isVisible = false
							table.remove(devils, k)
						end
					end
				else
					-- if devils[k].rotation > 180 and devils[k].rotation < 270 then
					-- 	drawHitLine( x-20, y+20, x+20, y-20 )
					-- elseif devils[k].rotation > 0 and devils[k].rotation < 90  then
					-- 	drawHitLine( x-20, y+20, x+20, y-20 )
					-- else
					-- 	drawHitLine( x-20, y-20, x+20, y+20 )
					-- end
				end
			end
		end
	end

	local hits = nil
	local toDelete = nil

end



function scene:create( event )

	left = false
	right = false
	speed = 0
	maxspeed = 0.3

	sceneGroup = self.view

	display.setDefault("isAnchorClamped",false)
	

	physics.start()
	physics.setGravity( 0, 0)
	physics.setDrawMode( "normal" )


	local background = display.newImageRect( "assets/map/background.png", display.contentWidth, display.contentHeight )

	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	sceneGroup:insert( background )

	Runtime:addEventListener( "key", onKeyEvent )

	local worldGroup = display.newGroup()

	world = display.newImageRect( worldGroup, "assets/map/earth.png", 346, 346 )
	world.x = display.contentCenterX + 18
	world.y = display.contentCenterY
	physics.addBody( world, "static",{radius=178}  )

	moon = display.newImageRect( worldGroup, "assets/map/moon.png", 123, 123 )
	moon.x,moon.y = world.x,world.y
	moon.anchorX = 0.5
	moon.anchorY = -2.3


	leftSide = display.newRect( worldGroup, world.x,world.y, 600, 90 )
	leftSide.alpha=0
	leftSide.rotation = 135
	leftSide.anchorX = 0.6
	leftSide.anchorY = 2.8

	physics.addBody( leftSide, "static" )

	rightSide = display.newRect( worldGroup, world.x,world.y, 600, 90 )
	rightSide.alpha=0
	rightSide.rotation = -135
	rightSide.anchorX = 0.4
	rightSide.anchorY = 2.8

	physics.addBody( rightSide, "static" )


	middleBar = display.newRect(worldGroup, world.x,world.y,600,90)
	middleBar.alpha=0
	middleBar.rotation = 0
	middleBar.anchorX = 0.5
	middleBar.anchorY = -0.9

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

	Runtime:addEventListener( "enterFrame", spawnDevil)

	Runtime:addEventListener( "enterFrame", onFrame )

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
	sceneGroup:insert(worldGroup)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	elseif phase == "did" then

		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	Runtime:removeEventListener( "key", onKeyEvent )
	Runtime:removeEventListener( "enterFrame", rotateBars )
	Runtime:removeEventListener( "enterFrame", onMove)
	local phase = event.phase
	
	if event.phase == "will" then

		physics.stop()
	elseif phase == "did" then

	end	
	
end

function scene:destroy( event )

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