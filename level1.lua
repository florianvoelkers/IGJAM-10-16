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
local fireWorld
local score
local goToEnd
local fireCounter
local fires = {}


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
    numFrames = 10,
    sheetContentWidth = 600,
    sheetContentHeight = 75
}

local devilSummonSheetOptions = {
    width = 60,
    height = 75,
    numFrames = 2,
    sheetContentWidth = 160,
    sheetContentHeight = 75
}


local fireBurnSheetOptions = {
    width = 80,
    height = 100,
    numFrames = 5,
    sheetContentWidth = 400,
    sheetContentHeight = 100
}


local devilIdleSequence = {
	{name = "devilIdle", frames = { 1, 2, 3, 4, 5, 6 }, time = 2000 },
	{name = "devilFire", frames = { 7,8,9,10 }, time = 1600 }

}

local devilSummonSequence = {
	{name = "devilSummon", frames = {1, 2}, time = 500}
}

local fireBurnSequence = {
	{name = "fireBurn", frames = {1, 2,3,4,5}, time = 1600}
}






local devilIdleFireSheet = graphics.newImageSheet( "assets/character/spritesheets/devil_Idle_fire_spritesheet.png", devilIdleSheetOptions )
local devilSummonSheet = graphics.newImageSheet( "assets/character/spritesheets/devil_flying_spritesheet.png", devilSummonSheetOptions)
local fireBurnSheet = graphics.newImageSheet( "assets/map/fire/fire_small_spritesheet.png", fireBurnSheetOptions)

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
		composer.gotoScene( "end" )
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

local function createFire( angle )
	local fireAngle = angle
	fires[#fires+1] = {}
	fires[#fires] = display.newSprite( fireBurnSheet, fireBurnSequence )
	fires[#fires].x, fires[#fires].y = world.x, world.y
	fires[#fires].anchorX, fires[#fires].anchorY = 0.4, 2.5
	if math.random( ) == 1 then
		fireAngle = fireAngle - 12
	else
		fireAngle = fireAngle +12
	end
	fires[#fires].rotation = fireAngle
	fires[#fires]:setSequence( "fireBurn" )
	fires[#fires]:play()
	fires[#fires].fireCounter = math.random( 300,400 )
	sceneGroup:insert(fires[#fires])
end


local function createDevil(...)
	local devilIdle = display.newSprite( devilIdleFireSheet, devilIdleSequence )
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
	devils[devilsCounter].fireCounter = math.random( 200,300 )
	devils[devilsCounter].fireOn = false
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


	for k,v in pairs (fires) do
		fires[k].fireCounter =fires[k].fireCounter -1
		if fires[k].fireCounter < 0 then
			fires[k].fireCounter = math.random(200,300)
			print ("neues feuer aus feuer", k)
			createFire(fires[k].rotation)
		end
	end

	for k,v in pairs(devils) do
		if devils[k] then
			if devils[k].rotation then
				if devils[k].fireOn then
					if fireWorld.alpha < 1 then
						fireWorld.hits = fireWorld.hits + 0.0001
						--fireWorld.hits = fireWorld.hits + 0.02*#devils
						fireWorld.alpha = fireWorld.hits
					elseif fireWorld.alpha > 0.98  then
						print ("go to end")
						if goToEnd == false then
							goToEnd = true
							for k,v in pairs(devils) do
								table.remove(devils, k)
							end
							display.remove( particleSystem )
							composer.gotoScene( "end","fade",500)
							composer.removeHidden( )
							composer.removeScene("level1")
						end
					end
				end
				if devils[k].fireCounter >= 1 then
					devils[k].fireCounter = devils[k].fireCounter - 1
					if devils[k].fireCounter <= 0 and  devils[k].fireOn == false then
						devils[k].fireOn = true
						devils[k]:setSequence( "devilFire" )
						devils[k]:play()
						devils[k].fireCounter = math.random(100,200)
					elseif devils[k].fireCounter <= 0 and  devils[k].fireOn then
						print ("create fire dämon")
						createFire(devils[k].rotation)
						devils[k]:setSequence( "devilIdle" )
						devils[k]:play()
					end
				end

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
					if devils[k].isVisible then
						devils[k].hp = devils[k].hp - 1
						if devils[k].hp < 1 then
							devils[k].isVisible = false
							table.remove(devils, k)
							score = score+1
							print ("score:",score)
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

end



function scene:create( event )

	left = false
	right = false
	speed = 0
	maxspeed = 0.3
	score = 0
	goToEnd = false

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

	world = display.newImageRect( worldGroup, "assets/map/earth.png", 350, 350 )
	world.x = display.contentCenterX + 18
	world.y = display.contentCenterY
	physics.addBody( world, "static",{radius=178}  )

	moon = display.newImageRect( worldGroup, "assets/map/moon.png", 123, 123 )
	moon.x,moon.y = world.x,world.y
	moon.anchorX = 0.5
	moon.anchorY = -2.3

	fireWorld = display.newImageRect( worldGroup, "assets/world_fire_dummy.png", 350, 350 )
	fireWorld.x = display.contentCenterX + 18
	fireWorld.y = display.contentCenterY
	fireWorld.alpha = 0

	fireWorld.hits = 0


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
	Runtime:removeEventListener( "enterFrame", onMove)
	Runtime:removeEventListener( "enterFrame", spawnDevil)
	Runtime:removeEventListener( "enterFrame", onFrame )
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