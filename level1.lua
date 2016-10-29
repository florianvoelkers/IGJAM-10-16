-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local score = require( "score" )


local sceneGroup

-- include Corona's "physics" library
local physics = require "physics"
local moon 
local speed
local devils = {}
local flyingDevils = {}
local world
local earth2
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
local scorePoints
local goToEnd
local fireCounter
local fires
local steams

local deamonDieSound
local flameDieSound

local background1
local background2
local background3
local clouds


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

local devilFlySheetOptions = {
    width = 60,
    height = 60,
    numFrames = 2,
    sheetContentWidth = 120,
    sheetContentHeight = 60
}

local explosionSheetOptions = {
	width = 50,
    height = 60,
    numFrames = 6,
    sheetContentWidth = 300,
    sheetContentHeight = 60
}


local fireBurnSheetOptions = {
    width = 80,
    height = 100,
    numFrames = 5,
    sheetContentWidth = 400,
    sheetContentHeight = 100
}


local waterSteamSheetOptions = {
    width = 140,
    height = 80,
    numFrames = 7,
    sheetContentWidth = 980,
    sheetContentHeight = 80
}

local devilDieSheetOptions = {
	width = 60,
    height = 75,
    numFrames = 14,
    sheetContentWidth = 840,
    sheetContentHeight = 75
}


local earthDestructionOptions = {
    width = 350,
    height = 350,
    numFrames = 5,
    sheetContentWidth = 1750,
    sheetContentHeight = 350
}

local cloudSheetOptions = {
    width = 350,
    height = 350,
    numFrames = 11,
    sheetContentWidth = 3850,
    sheetContentHeight = 350
}




local devilIdleSequence = {
	{name = "devilIdle", frames = { 1, 2, 3, 4, 5, 6 }, time = 2000 },
	{name = "devilFire", frames = { 7,8,9,10 }, time = 1600 }

}

local devilFlySequence = {
	{name = "devilFly", frames = {1, 2}, time = 200}
}

local explosionSequence = {
	{name = "explosion", frames = {1, 2, 3, 4, 5, 6}, time = 1200, loopCount = 1}
}
local fireBurnSequence = {
	{name = "fireBurn", frames = {1, 2,3,4,5}, time = 1600}
}

local waterSteamSequence = {
	{name = "waterSteam", frames = {1, 2,3,4,5,6,7}, time = 1800}
}


local develDieSequence = {
	{name = "dieDevilDie", frames = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, time = 1400, loopCount = 1}
}

local earthDestructionSequence = {
	{name = "stage1", frames = {1}},
	{name = "stage2", frames = {2}},
	{name = "stage3", frames = {3}},
	{name = "stage4", frames = {4}},
	{name = "stage5", frames = {5}}
}

local cloudSheetSequence = {
	{name = "cloudMove", frames = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}, time = 2500}
}

local devilFlySheet = graphics.newImageSheet( "assets/character/spritesheets/devil_fly_cube.png", devilFlySheetOptions)
local explosionSheet = graphics.newImageSheet( "assets/map/explosion/explosion_spritesheet.png", explosionSheetOptions)
local devilIdleFireSheet = graphics.newImageSheet( "assets/character/spritesheets/devil_Idle_fire_spritesheet.png", devilIdleSheetOptions )
local fireBurnSheet = graphics.newImageSheet( "assets/map/fire/fire_small_spritesheet.png", fireBurnSheetOptions)
local waterSteamSheet = graphics.newImageSheet( "assets/character/spritesheets/wasserdampf/wasserdampf_spritesheet.png", waterSteamSheetOptions)
local develDieSheet = graphics.newImageSheet( "assets/character/spritesheets/dying/deathanim_devil_spritesheet.png", devilDieSheetOptions)
local earthDestructionSheet = graphics.newImageSheet("assets/map/earth_destruction_sheet.png", earthDestructionOptions)
local cloudSheet = graphics.newImageSheet("assets/map/clouds/clouds_spritesheet.png", cloudSheetOptions)



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
		physics.stop( )
		Runtime:removeEventListener( "key", onKeyEvent )
		timer.performWithDelay( 5000, function (...)
			composer.gotoScene( "end" )
			composer.removeHidden() 
			composer.removeScene( "level1" )
		end )
		
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
		fireAngle = fireAngle - 10
	else
		fireAngle = fireAngle +10
	end
	fires[#fires].rotation = fireAngle
	fires[#fires]:setSequence( "fireBurn" )
	fires[#fires]:play()
	fires[#fires].fireCounter = math.random( 300,400 )
	fires[#fires].hp = 50
	sceneGroup:insert(fires[#fires])
end



local function mySpriteListener( event )
	if ( event.phase == "loop" ) then
		if event.target then
			steams[event.target.id]:remove( )
			steams[event.target.id] = nil
		end
	end
end

      
local function createSteam( angle )
	steams[#steams+1] = {}
	steams[#steams] = display.newSprite( waterSteamSheet,waterSteamSequence )
	steams[#steams].x, steams[#steams].y = world.x, world.y
	steams[#steams].anchorX, steams[#steams].anchorY = 0.4, 3
	steams[#steams].rotation = angle
	steams[#steams].id = #steams
	steams[#steams]:setSequence( "waterSteam" )
	steams[#steams]:play()
	sceneGroup:insert(steams[#steams])
	steams[#steams]:addEventListener( "sprite", mySpriteListener )  
end



local function createDevil(rotation)
	local devilIdle = display.newSprite( devilIdleFireSheet, devilIdleSequence )
	devilIdle.x, devilIdle.y = world.x, world.y
	devilIdle.anchorX, devilIdle.anchorY = 0.4, 3
	--local randomSpawn = math.random(360)
	devilIdle.rotation = rotation
	return devilIdle
end

local function setDevil(rotation)
	devilsCounter = devilsCounter + 1
	devils[devilsCounter] = createDevil(rotation)
	devils[devilsCounter].hp = 100
	sceneGroup:insert(devils[devilsCounter])
	devils[devilsCounter]:setSequence( "devilIdle" )
	devils[devilsCounter]:play()
	devils[devilsCounter].fireCounter = math.random( 200,300 )
	devils[devilsCounter].fireOn = false
end

local function createFlyingDevil(...)
	local flyingDevil = display.newSprite( devilFlySheet, devilFlySequence)
	local spawnArea = math.random( 4 ) -- 1 = left, 2 = bottom, 3 = right, 4 = top
	local posX
	local posY
	if spawnArea == 1 then
		posX = -1 * math.random(100, 200)
		posY = math.random(display.contentHeight)
		local difY = posY - world.y
		flyingDevil.rotation = 1/8 * -1 * difY + 270 + 180
	elseif spawnArea == 2 then
		posX = math.random(display.contentWidth)
		posY = math.random (display.contentHeight + 100, display.contentHeight + 200)
		local difX = posX - world.x
		flyingDevil.rotation = 9/128 * -1 * difX
	elseif spawnArea == 3 then
		posX = math.random(display.contentWidth + 100, display.contentWidth + 200)
		posY = math.random(display.contentHeight)
		local difY = posY - world.y
		flyingDevil.rotation = 1/8 * difY + 90 + 180
	elseif spawnArea == 4 then
		posX = math.random(display.contentHeight)
		posY = -1 * math.random(100, 200)
		local difX = posX - world.x
		flyingDevil.rotation = 9/128 * difX + 180
	end
	flyingDevil.x, flyingDevil.y = posX, posY
	return flyingDevil
end

local function explosionListener (event)
	if event.phase == "ended" then
		setDevil(event.target.rotation)
		event.target:removeSelf()
		event.target = nil
	end
end

local function setOfExplosion(devilObject, otherObject)
	local explosion = display.newSprite( explosionSheet, explosionSequence)
	explosion.x, explosion.y = earth2.x, earth2.y
	explosion.anchorX, explosion.anchorY = 0.5, 3.6
	local difX = devilObject.x - otherObject.x
	local difY = devilObject.y - otherObject.y
	if difY <= 0 then
		difY = difY + 30
	else
		difY = difY - 30
	end
	if difX >= 0 then
		difX = difX - 30
		explosion.rotation = 0.6 * difY + 90
	elseif difX <= 0 then
		difX = difX + 30
		explosion.rotation = -0.6 * difY + 270
	end
	sceneGroup:insert(explosion)
	explosion:setSequence( "explosion" )
	explosion:play()
	audio.play(landingSound)
	explosion:addEventListener( "sprite", explosionListener )
	devilObject:removeSelf()
	devilObject = nil
end

local function flyingDevil( devilObject )
	transition.to( devilObject, {time = 3000, x = world.x, y = world.y} )
end

local function onFlyingDevilCollision (self, event)
	if event.other.myName then
		if event.other.myName == "earth2" then
			setOfExplosion(self, event.other)
		end
	end
end

local function spawnDevil (event)
	spawnTimer = spawnTimer + 1
	if spawnTimer >= spawnAfter then
		flyingDevilsCounter = flyingDevilsCounter + 1		
		flyingDevils[flyingDevilsCounter] = createFlyingDevil()
		sceneGroup:insert(flyingDevils[flyingDevilsCounter])
		flyingDevils[flyingDevilsCounter]:setSequence( "devilFly" )
		flyingDevils[flyingDevilsCounter]:play()
		flyingDevil(flyingDevils[flyingDevilsCounter])
		physics.addBody( flyingDevils[flyingDevilsCounter], "dynamic", { isSensor = true } )
		flyingDevils[flyingDevilsCounter].collision = onFlyingDevilCollision
		flyingDevils[flyingDevilsCounter].myName = "devil"
		flyingDevils[flyingDevilsCounter]:addEventListener( "collision")
		spawnTimer = 0
	end	
end



local drawHitLine = function( x1,y1,x2,y2)
	ray[#ray+1] = display.newLine(x1,y1,x2,y2)
end

local function onDevilDeadListener(event)
	if event.phase == "ended" then
		print("he dead")
		event.target:removeSelf()
		event.target = nil
	end
end

local function dieDevilDie (devil)
	print("die")
	local dyingDevil = display.newSprite( develDieSheet, develDieSequence )
	dyingDevil.x, dyingDevil.y = devil.x, devil.y
	dyingDevil.anchorX, dyingDevil.anchorY = devil.anchorX, devil.anchorY
	dyingDevil.rotation = devil.rotation
	sceneGroup:insert(dyingDevil)
	dyingDevil:setSequence( "dieDevilDie" )
	dyingDevil:play()
	dyingDevil:addEventListener( "sprite", onDevilDeadListener )
end

local function onFrame( )
	background1.x = background1.x -0.5
	background2.x = background2.x -0.5
	background3.x = background3.x -0.5

	if background1.x < -display.contentCenterX then
		background1.x = 2*display.contentCenterX
	end
	if background2.x < -display.contentCenterX then
		background2.x = 2*display.contentCenterX
	end
	if background3.x < -display.contentCenterX then
		background3.x = 2*display.contentCenterX
	end





	if 	left == false and right == false and (speed > 0 or speed < 0) then
		if speed >0.01 then
			speed = speed -0.005
		elseif speed < - 0.01 then
			speed = speed +0.005
		else
			if clouds.isPlaying then
				clouds:pause()
			end
			speed = 0
		end
	elseif left == true and right == false and speed < maxspeed then
		speed = speed + 0.008
		if not clouds.isPlaying then
			clouds:play()
		end
	elseif left == false and right == true and speed > -maxspeed then
		speed = speed - 0.008
		if not clouds.isPlaying then
			clouds:play()
		end
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

	------------------------------------------------------------
	for i = 1,#ray do
		display.remove( ray[i] ) ; ray[i] = nil
	end


	for k,v in pairs (fires) do
		fires[k].fireCounter =fires[k].fireCounter -1
		fireWorld.hits = fireWorld.hits + 0.00001
		if fires[k].fireCounter == 0 then
			fires[k].fireCounter = math.random(300,400)
			createFire(fires[k].rotation)
		end

		angle = fires[k].rotation - 90
		x = world.x + (world.width/2 * math.cos(math.rad(angle)))
		y = world.y + (world.width/2 * math.sin(math.rad(angle)))
		if fires[k].rotation > 180 and fires[k].rotation < 270 then
			fires[k].hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
		elseif fires[k].rotation > 0 and fires[k].rotation < 90  then
			fires[k].hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
		else
			fires[k].hit = particleSystem:rayCast( x-20, y-20, x+20, y+20 )
		end

		if fires[k].hit then
			if fires[k].isVisible then
				fires[k].hp = fires[k].hp - 1
				if fires[k].hp == 5 then
					createSteam(fires[k].rotation)
					audio.play(flameDieSound)
				elseif fires[k].hp < 1 then
					fires[k].isVisible = false
					table.remove(fires, k)
					scorePoints = scorePoints+0.5
					print ("score:",scorePoints)
				end
			end
		end
	end

	for k,v in pairs(devils) do
		if devils[k] then
			if devils[k].rotation then
				if devils[k].fireOn then
					fireWorld.hits = fireWorld.hits + 0.00002
					fireWorld.alpha = fireWorld.hits
					if fireWorld.alpha > 0.15 and fireWorld.alpha < 0.2 then
						world:setSequence( "stage2" )
					elseif fireWorld.alpha > 0.35 and fireWorld.alpha < 0.5 then
						world:setSequence( "stage3" )
					elseif fireWorld.alpha > 0.50 and fireWorld.alpha < 0.60 then
						world:setSequence( "stage4" )
					elseif fireWorld.alpha > 0.75 and fireWorld.alpha < 0.80 then
						world:setSequence( "stage5" )
					end


					if fireWorld.alpha > 0.99  then
						Runtime:removeEventListener( "enterFrame", onFrame )
						if goToEnd == false then
							goToEnd = true
							for k,v in pairs(devils) do
								table.remove(devils, k)
							end
							for i =1 , #steams do
								if steams[i] then
									steams[i]:remove()
									steams[i] = nil
								end
							end 
							audio.dispose() 
							score.set( scorePoints )
							score.save()
							display.remove( particleSystem )
							Runtime:removeEventListener( "key", onKeyEvent )
							Runtime:removeEventListener( "enterFrame", onMove)
							Runtime:removeEventListener( "enterFrame", spawnDevil)
							print("Game Over")
							local gameOver = display.newImageRect( "assets/gameOver.png", display.contentWidth, display.contentHeight )
							gameOver.x, gameOver.y = display.contentCenterX, display.contentCenterY
							transition.blink( gameOver, {time = 500} )
							timer.performWithDelay( 5000, function (...)
								gameOver:removeSelf( )
								gameOver = nil
								composer.gotoScene( "end","fade",100)
								composer.removeHidden( )
								composer.removeScene("level1")
							end )
							
						end
					end
				end
				if devils then
					if devils[k]then
						if devils[k].fireCounter >= 1 then
							devils[k].fireCounter = devils[k].fireCounter - 1
							if devils[k].fireCounter <= 0 and  devils[k].fireOn == false then
								devils[k].fireOn = true
								devils[k]:setSequence( "devilFire" )
								devils[k]:play()
								devils[k].fireCounter = math.random(100,200)
							elseif devils[k].fireCounter <= 0 and  devils[k].fireOn then
								createFire(devils[k].rotation)
								devils[k]:setSequence( "devilIdle" )
								devils[k]:play()
							end
						end
					end
				end
				if not goToEnd then
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
							if devils[k].hp == 10 then
								createSteam(devils[k].rotation)
							elseif devils[k].hp == 1 then
								audio.play(deamonDieSound)
								dieDevilDie(devils[k])
								devils[k].isVisible = false
								table.remove(devils, k)
								scorePoints = scorePoints + 1
								print ("score:",scorePoints)
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
	end
end



function scene:create( event )

	left = false
	right = false
	speed = 0
	maxspeed = 0.5
	scorePoints = 0
	goToEnd = false
	fires = {}
	steams = {}
	deamonDieSound = audio.loadSound( "assets/sound/effects/dmonDie.wav" )
	flameDieSound = audio.loadSound( "assets/sound/effects/flameDie.wav" )
	landingSound = audio.loadSound( "assets/sound/effects/landingDmon.wav" )
	musik = audio.loadStream("assets/sound/music/theme.mp3")
	local optionsSound ={loops = -1}
	audio.play(musik, optionsSound)


	audio.setVolume( 0.5 ) 

	sceneGroup = self.view

	display.setDefault("isAnchorClamped",false)

	background1 = display.newImageRect( "assets/map/background/1.png", display.contentWidth, display.contentHeight )
	background1.x = display.contentCenterX
	background1.y = display.contentCenterY


	background2 = display.newImageRect( "assets/map/background/2.png", display.contentWidth, display.contentHeight )
	background2.x = display.contentCenterX*2
	background2.y = display.contentCenterY

	background3 = display.newImageRect( "assets/map/background/3.png", display.contentWidth, display.contentHeight )
	background3.x = display.contentCenterX*3
	background3.y = display.contentCenterY
	
	sceneGroup:insert( background1 )
	sceneGroup:insert( background2 )
	sceneGroup:insert( background3 )

	Runtime:addEventListener( "key", onKeyEvent )

	local worldGroup = display.newGroup()

	print("physics")

	physics.start()
	physics.setGravity( 0, 0)
	physics.setDrawMode( "normal" )

	earth2 = display.newImageRect (worldGroup, "assets/map/earth.png", 300, 300 )
	earth2.x, earth2.y = display.contentCenterX, display.contentCenterY
	earth2.myName = "earth2"
	physics.addBody( earth2, "static", { radius = 150, isSensor = true})
	earth2.alpha = 0

	world = display.newSprite( earthDestructionSheet, earthDestructionSequence)
	world:setSequence( "stage1" )
	world:play()
	world.x = display.contentCenterX
	world.y = display.contentCenterY
	world.myName = "world"
	worldGroup:insert(world)
	physics.addBody( world, "static",{radius=178}  )


	moon = display.newImageRect( worldGroup, "assets/map/moon.png", 123, 123 )
	moon.x,moon.y = world.x,world.y
	moon.anchorX = 0.5
	moon.anchorY = -2.3

	fireWorld = display.newImageRect( worldGroup, "assets/map/earth_shadow.png", 355, 355 )
	fireWorld.x = display.contentCenterX
	fireWorld.y = display.contentCenterY
	fireWorld.alpha = 0
	fireWorld.hits = 0

	clouds = display.newSprite( cloudSheet, cloudSheetSequence)
	clouds:setSequence( "cloudMove" )
	--clouds:play()
	clouds.x = display.contentCenterX
	clouds.y = display.contentCenterY
	worldGroup:insert(clouds)




	leftSide = display.newRect( worldGroup, world.x,world.y, 600, 90 )
	leftSide.alpha=0
	leftSide.rotation = 135
	leftSide.anchorX = 0.6
	leftSide.anchorY = 2.8
	leftSide.myName = "leftSide"

	physics.addBody( leftSide, "static" )

	rightSide = display.newRect( worldGroup, world.x,world.y, 600, 90 )
	rightSide.alpha=0
	rightSide.rotation = -135
	rightSide.anchorX = 0.4
	rightSide.anchorY = 2.8
	rightSide.myName = "rightSide"

	physics.addBody( rightSide, "static" )


	middleBar = display.newRect(worldGroup, world.x,world.y,600,90)
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
	print("show")
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		print("will")
	elseif phase == "did" then
		print("did")
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
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