-----------------------------------------------------------------------------------------
--
-- end.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local score = require("score")

-- include Corona's "widget" library
local widget = require "widget"

local background1
local background2
local background3
local highestScore
local retryButton
local sceneGroup

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease(event)
	
	if event.phase == "began" then
		composer.gotoScene( "level1", "fade", 500 )
		composer.removeHidden( )
		composer.removeScene("end")
	end
	return true	-- indicates successful touch
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

end

function scene:create( event )
	sceneGroup = self.view

	background1 = display.newImageRect( "assets/map/background/1.png", display.contentWidth, display.contentHeight )
	background1.x = display.contentCenterX
	background1.y = display.contentCenterY


	background2 = display.newImageRect( "assets/map/background/2.png", display.contentWidth, display.contentHeight )
	background2.x = display.contentCenterX*2
	background2.y = display.contentCenterY

	background3 = display.newImageRect( "assets/map/background/3.png", display.contentWidth, display.contentHeight )
	background3.x = display.contentCenterX*3
	background3.y = display.contentCenterY

	highestScore = display.newImageRect( "assets/highestScore.png", display.contentWidth, display.contentHeight )
	highestScore.x, highestScore.y  = display.contentCenterX, display.contentCenterY
	score:load()
	local scoreTable = score:get()
	table.sort(scoreTable)
	local scoreGroup = display.newGroup( )
	for i = 1, 3 do
		if i <= #scoreTable then
			local scoreText = display.newText(i .. ".     " .. scoreTable[#scoreTable - (i-1)], display.contentCenterX, 220 + (i-1) * 75, native.systemFontBold, 72 )
			scoreText:setFillColor( 1, 0.3137, 0.0196 )
			scoreGroup:insert(scoreText)
		end
	end
	retryButton = display.newImageRect( "assets/play.png", 100, 100 )
	retryButton.x, retryButton.y = display.contentCenterX, display.contentHeight - 200
	retryButton:addEventListener( "touch", onPlayBtnRelease )
	
	sceneGroup:insert( background1 )
	sceneGroup:insert( background2 )
	sceneGroup:insert( background3 )
	sceneGroup:insert( highestScore )
	sceneGroup:insert(scoreGroup)
	sceneGroup:insert(retryButton)

	Runtime:addEventListener( "enterFrame", onFrame )
end

function scene:show( event )
	
	local phase = event.phase
	if phase == "will" then

	elseif phase == "did" then
		score.get()
	end	
end

function scene:hide( event )	
	if event.phase == "will" then
		Runtime:removeEventListener( "enterFrame", onFrame )
	elseif phase == "did" then
		-- Called when the scene is now off screen
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