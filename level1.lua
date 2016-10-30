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
local devils
local flyingDevils
local flowerPowerUps
local powerUps
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
local ray
local fireWorld
local scorePoints
local goToEnd
local fireCounter
local fires
local steams
local angle

local deamonDieSound
local flameDieSound

local background1
local background2
local background3
local scoreText
local clouds

local dmnonDamage
local dmonMaxDamage


--------------------------------------------

display.setStatusBar( display.HiddenStatusBar )


-- forward declarations and other locals
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentCenterX, display.contentCenterY

local spawnTimer
local spawnAfter

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

local flowerPowerUpOptions = {
	width = 68,
    height = 58,
    numFrames = 3,
    sheetContentWidth = 204,
    sheetContentHeight = 58
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

local flowerPowerUpSequence = {
	{name = "flowerPowerUp", frames = {1, 2, 3}, time = 600}
}

local devilFlySheet = graphics.newImageSheet( "assets/character/spritesheets/devil_fly_cube.png", devilFlySheetOptions)
local explosionSheet = graphics.newImageSheet( "assets/map/explosion/explosion_spritesheet.png", explosionSheetOptions)
local devilIdleFireSheet = graphics.newImageSheet( "assets/character/spritesheets/devil_Idle_fire_spritesheet.png", devilIdleSheetOptions )
local fireBurnSheet = graphics.newImageSheet( "assets/map/fire/fire_small_spritesheet.png", fireBurnSheetOptions)
local waterSteamSheet = graphics.newImageSheet( "assets/character/spritesheets/wasserdampf/wasserdampf_spritesheet.png", waterSteamSheetOptions)
local develDieSheet = graphics.newImageSheet( "assets/character/spritesheets/dying/deathanim_devil_spritesheet.png", devilDieSheetOptions)
local earthDestructionSheet = graphics.newImageSheet("assets/map/earth_destruction_sheet.png", earthDestructionOptions)
local cloudSheet = graphics.newImageSheet("assets/map/clouds/clouds_spritesheet.png", cloudSheetOptions)
local flowerPowerUpSheet = graphics.newImageSheet( "assets/powerups/blume_powerup_spritesheet.png", flowerPowerUpOptions )

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

local function createFire( givenAngle )
	local fireAngle = givenAngle
	fires[#fires+1] = {}
	fires[#fires] = display.newSprite( fireBurnSheet, fireBurnSequence )
	fires[#fires].x, fires[#fires].y = world.x, world.y
	fires[#fires].anchorX, fires[#fires].anchorY = 0.4, 2.5
	if math.random() == 1 then
		fireAngle = fireAngle - 10
	else
		fireAngle = fireAngle + 10
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
			if event.target.id then
				if steams[event.target.id] then
					if steams[event.target.id]:removeSelf( ) then
						steams[event.target.id]:removeSelf( )
						steams[event.target.id] = nil
					end
				end
			end
		end
	end
end

      
local function createSteam( givenAngle )
	steams[#steams+1] = {}
	steams[#steams] = display.newSprite( waterSteamSheet,waterSteamSequence )
	steams[#steams].x, steams[#steams].y = world.x, world.y
	steams[#steams].anchorX, steams[#steams].anchorY = 0.4, 3
	steams[#steams].rotation = givenAngle
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
	devilIdle.rotation = rotation
	return devilIdle
end

local function setDevil(rotation)
	devils[#devils+1] = createDevil(rotation)
	devils[#devils].hp = 100
	sceneGroup:insert(devils[#devils])
	devils[#devils]:setSequence( "devilIdle" )
	devils[#devils]:play()
	devils[#devils].fireCounter = math.random( 200,300 )
	devils[#devils].fireOn = false
end

local function createFlyingDevil()
	local flyingDevil = display.newSprite( devilFlySheet, devilFlySequence)
	local spawnArea = math.random( 400 ) -- 1 = left, 2 = bottom, 3 = right, 4 = top
	local posX
	local posY
	if spawnArea < 100 then
		posX = -1 * math.random(100, 200)
		posY = math.random(screenH)
		local difY = posY - world.y
		flyingDevil.rotation = 0.125 * -difY + 450
	elseif spawnArea <200 then
		posX = math.random(screenW)
		posY = math.random (screenH + 100, screenH + 200)
		local difX = posX - world.x
		flyingDevil.rotation = 9/128 * -difX
	elseif spawnArea < 300 then
		posX = math.random(screenW + 100, screenW + 200)
		posY = math.random(screenH)
		local difY = posY - world.y
		flyingDevil.rotation = 0.125 * difY + 270
	elseif spawnArea < 400 then
		posX = math.random(screenH)
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

local function createFlowerPowerUp(...)
	local flowerPowerUp = display.newSprite( flowerPowerUpSheet, flowerPowerUpSequence)
	local spawnArea = math.random( 4 ) -- 1 = left, 2 = bottom, 3 = right, 4 = top
	local posX
	local posY
	if spawnArea == 1 then
		posX = -1 * math.random(100, 200)
		posY = math.random(screenH)
		local difY = posY - world.y
		flowerPowerUp.rotation = 0.125 * - difY + 270
	elseif spawnArea == 2 then
		posX = math.random(screenW)
		posY = math.random (screenH + 100, screenH + 200)
		local difX = posX - world.x
		flowerPowerUp.rotation = 9/128 * - difX - 180
	elseif spawnArea == 3 then
		posX = math.random(screenW + 100, screenW + 200)
		posY = math.random(screenH)
		local difY = posY - world.y
		flowerPowerUp.rotation = 0.125 * difY + 90
	elseif spawnArea == 4 then
		posX = math.random(screenH)
		posY = -1 * math.random(100, 200)
		local difX = posX - world.x
		flowerPowerUp.rotation = 9/128 * difX
	end
	flowerPowerUp.x, flowerPowerUp.y = posX, posY
	return flowerPowerUp
end

local function flyingFlower(flower)
	transition.to( flower, {time = 6000, x = world.x, y = world.y} )
end

local function spawnFlower(flower)
	powerUps[#powerUps+1] = display.newSprite( flowerPowerUpSheet, flowerPowerUpSequence )
	powerUps[#powerUps].x, powerUps[#powerUps].y = flower.x, flower.y
	powerUps[#powerUps].rotation = flower.rotation 
	powerUps[#powerUps].lifeTime = math.random( 300, 420 )
	sceneGroup:insert(powerUps[#powerUps])
	powerUps[#powerUps]:setSequence( "flowerPowerUp" )
	powerUps[#powerUps]:play()
	flower:removeSelf()
	flower = nil
end

local function spawnPowerUp(powerUp)
	local powerUpType = powerUp.type 
	if powerUpType == "flowerPowerUp" then
		spawnFlower(powerUp)
	end
end

local function onFlyingFlowerPowerUpCollision(self, event)
	if event.other.myName then
		if event.other.myName == "earth2" then
			spawnPowerUp(self)
		end
	end
end

local function spawnDevil (event)	
	spawnTimer = spawnTimer + 1
	if spawnTimer >= spawnAfter then
		if math.random( 10 ) <= 9 then		
			flyingDevils[#flyingDevils+1] = createFlyingDevil()
			sceneGroup:insert(flyingDevils[#flyingDevils])
			flyingDevils[#flyingDevils]:setSequence( "devilFly" )
			flyingDevils[#flyingDevils]:play()
			flyingDevil(flyingDevils[#flyingDevils])
			physics.addBody( flyingDevils[#flyingDevils], "dynamic", { isSensor = true } )
			flyingDevils[#flyingDevils].collision = onFlyingDevilCollision
			flyingDevils[#flyingDevils].myName = "devil"
			flyingDevils[#flyingDevils]:addEventListener( "collision")
		else
			flowerPowerUps[#flowerPowerUps+1] = createFlowerPowerUp()
			sceneGroup:insert(flowerPowerUps[#flowerPowerUps])
			flowerPowerUps[#flowerPowerUps]:setSequence( "flowerPowerUp" )
			flowerPowerUps[#flowerPowerUps]:play()
			flyingFlower(flowerPowerUps[#flowerPowerUps])
			physics.addBody( flowerPowerUps[#flowerPowerUps], "dynamic", { isSensor = true } )
			flowerPowerUps[#flowerPowerUps].type = "flowerPowerUp"
			flowerPowerUps[#flowerPowerUps].collision = onFlyingFlowerPowerUpCollision
			flowerPowerUps[#flowerPowerUps].myName = "flowerPowerUp"
			flowerPowerUps[#flowerPowerUps]:addEventListener( "collision")
		end
		spawnTimer = 0
	end	
end



local drawHitLine = function( x1,y1,x2,y2)
	ray[#ray+1] = display.newLine(x1,y1,x2,y2)
end

local function onDevilDeadListener(event)
	if event.phase == "ended" then
		event.target:removeSelf()
		event.target = nil
	end
end

local function dieDevilDie (devil)
	local dyingDevil = display.newSprite( develDieSheet, develDieSequence )
	dyingDevil.x, dyingDevil.y = devil.x, devil.y
	dyingDevil.anchorX, dyingDevil.anchorY = devil.anchorX, devil.anchorY
	dyingDevil.rotation = devil.rotation
	sceneGroup:insert(dyingDevil)
	dyingDevil:setSequence( "dieDevilDie" )
	dyingDevil:play()
	dyingDevil:addEventListener( "sprite", onDevilDeadListener )
end

local function onFrame(event)

	if event.time/1000 < 20 then
		spawnAfter = 300
	elseif event.time/1000 < 40 then
		spawnAfter = 250 
	elseif event.time/1000 < 60 then
		spawnAfter = 200
	elseif event.time/1000 < 80 then
		spawnAfter = 150
	elseif event.time/1000 < 100 then
		spawnAfter = 100
	end

	background1.x = background1.x -0.5
	background2.x = background2.x -0.5
	background3.x = background3.x -0.5

	if background1.x < -halfW then
		background1.x = 2*halfW
	end
	if background2.x < -halfW then
		background2.x = 2*halfW
	end
	if background3.x < -halfW then
		background3.x = 2*halfW
	end

	for k,v in pairs(powerUps) do
		v.lifeTime = v.lifeTime - 1
		if v.lifeTime == 0 then
			v:removeSelf( )
			v = nil
		elseif v.lifeTime == 200 then
			transition.blink( v, {time = 1000} )
		end
	end

	if 	left == false and right == false and (speed > 0 or speed < 0) then
		if speed >0.01 then
			speed = speed -0.005
		elseif speed < - 0.01 then
			speed = speed +0.005
		else
			clouds.timeScale = 0.5
			speed = 0
		end
	elseif left == true and right == false and speed < maxspeed then
		speed = speed + 0.008
		clouds.timeScale = 1
	elseif left == false and right == true and speed > -maxspeed then
		speed = speed - 0.008
		clouds.timeScale = 1
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
		v.fireCounter = v.fireCounter -1
		fireWorld.hits = fireWorld.hits + dmonDamage/2
		if v.fireCounter == 0 then
			v.fireCounter = math.random(300,400)
			createFire(v.rotation)
		end

		angle = v.rotation - 90
		local x = world.x + (world.width/2 * math.cos(math.rad(angle)))
		local y = world.y + (world.width/2 * math.sin(math.rad(angle)))
		if v.rotation > 180 and v.rotation < 270 then
			v.hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
		elseif v.rotation > 0 and v.rotation < 90  then
			v.hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
		else
			v.hit = particleSystem:rayCast( x-20, y-20, x+20, y+20 )
		end

		if v.hit then
			if v.isVisible then
				v.hp = v.hp - 1
				if v.hp == 5 then
					createSteam(v.rotation)
					audio.play(flameDieSound)
				elseif v.hp < 1 then
					v.isVisible = false
					v:removeSelf( )
					v = nil
					table.remove(fires, k)
					scorePoints = scorePoints+0.5
					scoreText.text = "Score: " .. scorePoints
				end
			end
		end
	end

	for k,v in pairs(devils) do
		if v then
			if v.rotation then
				if v.fireOn then
					fireWorld.hits = fireWorld.hits + dmonDamage
					fireWorld.alpha = fireWorld.hits
					if fireWorld.alpha > 0.15 and fireWorld.alpha < 0.2 then
						world:setSequence( "stage2" )
					elseif fireWorld.alpha > 0.35 and fireWorld.alpha < 0.5 then
						world:setSequence( "stage3" )
					elseif fireWorld.alpha > 0.55 and fireWorld.alpha < 0.65 then
						world:setSequence( "stage4" )
					elseif fireWorld.alpha > 0.80 and fireWorld.alpha < 0.85 then
						world:setSequence( "stage5" )
					end

					if fireWorld.alpha > 0.99  then
						Runtime:removeEventListener( "enterFrame", onFrame )
						if goToEnd == false then
							goToEnd = true	
							Runtime:removeEventListener( "enterFrame", spawnDevil)
							score.set( scorePoints )
							score.save()
							display.remove( particleSystem )						
							local gameOver = display.newImageRect( "assets/gameOver.png", screenW, screenH )
							gameOver.x, gameOver.y = halfW, halfH
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
					if v then
						if v.fireCounter >= 1 then
							v.fireCounter = v.fireCounter - 1
							if v.fireCounter <= 0 and  v.fireOn == false then
								v.fireOn = true
								v:setSequence( "devilFire" )
								v:play()
								v.fireCounter = math.random(100,200)
							elseif v.fireCounter <= 0 and  v.fireOn then
								createFire(v.rotation)
								v:setSequence( "devilIdle" )
								v:play()
							end
						end
					end
				end

				if not goToEnd then
					angle = v.rotation - 90
					x = world.x + (world.width/2 * math.cos(math.rad(angle)))
					y = world.y + (world.width/2 * math.sin(math.rad(angle)))
					if v.rotation > 180 and v.rotation < 270 then
						v.hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
					elseif v.rotation > 0 and v.rotation < 90  then
						v.hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
					else
						v.hit = particleSystem:rayCast( x-20, y-20, x+20, y+20 )
					end

					if v.hit then
						if v.isVisible then
							v.hp = v.hp - 1
							if v.hp == 10 then
								createSteam(v.rotation)
							elseif v.hp == 1 then
								audio.play(deamonDieSound)
								dieDevilDie(v)
								v.isVisible = false
								table.remove(devils, k)
								scorePoints = scorePoints + 1
								scoreText.text = "Score: " .. scorePoints
							end
						end
					end
				end

			end
		end
	end

	-- for k,v in pairs(powerUps) do
	-- 	if not goToEnd then
	-- 		if v.rotation then
	-- 			print(v.rotation, v.x, v.y)
	-- 			local posX = math.cos(math.rad(v.rotation + 90)) * world.width * 0.5 + world.x
	-- 			local posY = math.sin(math.rad(v.rotation - 90)) * world.width * 0.5 + world.y
	-- 			print(posX, posY)
	-- 			drawHitLine( posX - 50, posY - 50, posX + 50, posY + 50)
	-- 			v.hasHitLine = true
	-- 			print("has hitline")
				
	-- 		end
	-- 		-- powerUps[k].hit = particleSystem
	-- 		-- angle = powerUps[k].rotation - 90
	-- 		-- x = world.x + (world.width/2 * math.cos(math.rad(angle)))
	-- 		-- y = world.y + (world.width/2 * math.sin(math.rad(angle)))
	-- 		-- if v.rotation > 180 and v.rotation < 270 then
	-- 		-- 	v.hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
	-- 		-- elseif v.rotation > 0 and v.rotation < 90  then
	-- 		-- 	v.hit = particleSystem:rayCast( x-20, y+20, x+20, y-20 )
	-- 		-- else
	-- 		-- 	v.hit = particleSystem:rayCast( x-20, y-20, x+20, y+20 )
	-- 		-- end

	-- 		-- if v.hit then
	-- 		-- 	if v.isVisible then
	-- 		-- 		v.hp = v.hp - 1
	-- 		-- 		if v.hp == 10 then
	-- 		-- 			createSteam(v.rotation)
	-- 		-- 		elseif v.hp == 1 then
	-- 		-- 			audio.play(deamonDieSound)
	-- 		-- 			dieDevilDie(v)
	-- 		-- 			v.isVisible = false
	-- 		-- 			table.remove(devils, k)
	-- 		-- 			scorePoints = scorePoints + 1
	-- 		-- 			print ("score:",scorePoints)
	-- 		-- 		end
	-- 		-- 	else
	-- 		-- 		if v.rotation > 180 and v.rotation < 270 then
	-- 		-- 			drawHitLine( x-20, y+20, x+20, y-20 )
	-- 		-- 		elseif v.rotation > 0 and v.rotation < 90  then
	-- 		-- 			drawHitLine( x-20, y+20, x+20, y-20 )
	-- 		-- 		else
	-- 		-- 			drawHitLine( x-20, y-20, x+20, y+20 )
	-- 		-- 		end
	-- 		-- 	end
	-- 		-- end
	-- 	end
	-- end
end

local function initScene(...)
	devils = {}
	flyingDevils = {}
	flowerPowerUps = {}
	powerUps = {}
	ray = {}
	spawnTimer = 0
	spawnAfter = 350
	left = false
	right = false
	speed = 0
	maxspeed = 0.42
	scorePoints = 0
	goToEnd = false
	fires = {}
	steams = {}
	dmonMaxDamage = 0.000035
	dmonDamage = dmonMaxDamage
	
	deamonDieSound = audio.loadSound( "assets/sound/effects/dmonDie.wav" )
	flameDieSound = audio.loadSound( "assets/sound/effects/flameDie.wav" )
	landingSound = audio.loadSound( "assets/sound/effects/landingDmon.wav" )



	audio.setVolume( 0.5 ) 

	display.setDefault("isAnchorClamped",false)
end

local function setUpBackground()
	background1 = display.newImageRect( "assets/map/background/1.png", screenW, screenH )
	background1.x = halfW
	background1.y = halfH


	background2 = display.newImageRect( "assets/map/background/2.png", screenW, screenH )
	background2.x = halfW*2
	background2.y = halfH

	background3 = display.newImageRect( "assets/map/background/3.png", screenW, screenH )
	background3.x = halfW*3
	background3.y = halfH
	
	sceneGroup:insert( background1 )
	sceneGroup:insert( background2 )
	sceneGroup:insert( background3 )
end

function scene:create( event )
	sceneGroup = self.view

	initScene()
	setUpBackground()

	local worldGroup = display.newGroup()

	physics.start()
	physics.setGravity( 0, 0)
	physics.setDrawMode( "normal" )

	earth2 = display.newImageRect (worldGroup, "assets/map/earth.png", 300, 300 )
	earth2.x, earth2.y = halfW, halfH
	earth2.myName = "earth2"
	physics.addBody( earth2, "static", { radius = 150, isSensor = true})
	earth2.alpha = 0

	world = display.newSprite( earthDestructionSheet, earthDestructionSequence)
	world:setSequence( "stage1" )
	world:play()
	world.x = halfW
	world.y = halfH
	world.myName = "world"
	worldGroup:insert(world)
	physics.addBody( world, "static",{radius=178}  )


	moon = display.newImageRect( worldGroup, "assets/map/moon.png", 123, 123 )
	moon.x,moon.y = world.x,world.y
	moon.anchorX = 0.5
	moon.anchorY = -2.3

	fireWorld = display.newImageRect( worldGroup, "assets/map/earth_shadow.png", 357, 357 )
	fireWorld.x = halfW
	fireWorld.y = halfH
	fireWorld.alpha = 0
	fireWorld.hits = 0

	clouds = display.newSprite( cloudSheet, cloudSheetSequence)
	clouds:setSequence( "cloudMove" )
	clouds:play()
	clouds.timeScale = 0.5
	clouds.x = halfW
	clouds.y = halfH
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

	timer.performWithDelay( 800, function (...)
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
	        y = world.y+world.height/2 + 6,
	        halfWidth = 18,
	        halfHeight = 18,
	        outline = (graphics.newOutline( 100, "assets/triangle.png"))
	   	    }
	)
	particleSystem.myName = "Wasser"
								

	Runtime:addEventListener( "enterFrame", spawnDevil)

	Runtime:addEventListener( "enterFrame", onFrame )					
							end )





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

	scoreText = display.newText( worldGroup, "Score: " .. scorePoints, display.actualContentWidth - 200, 50, native.systemFontBold, 42 )
	scoreText:setFillColor( 1, 0.3137, 0.0196 )

	sceneGroup:insert(leftTouchArea)
	sceneGroup:insert(rightTouchArea)
	sceneGroup:insert(worldGroup)
end


function scene:show( event )
	local phase = event.phase
	
	if phase == "will" then

	elseif phase == "did" then

	end
end

function scene:hide( event )
	
	local phase = event.phase
	
	if event.phase == "will" then
		physics.stop()
		audio.dispose() 
	elseif phase == "did" then

	end	
	
end

function scene:destroy( event )
	sceneGroup:removeSelf( )
	sceneGroup = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene