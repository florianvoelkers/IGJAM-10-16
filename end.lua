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

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	print ("scene create end")
	local sceneGruppe = self.view

	local background = display.newImageRect( "assets/concept_size.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	print ("scene create back")
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "game_over_logo.png", 346, 55 )
	titleLogo.x = display.contentCenterX + 18
	titleLogo.y = display.contentCenterY
	print ("scene create title")
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Retry",
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX + 18
	playBtn.y = display.contentHeight - 125
	print ("scene create button")
	-- all display objects must be inserted into group
	sceneGruppe:insert( background )
	sceneGruppe:insert( titleLogo )
	sceneGruppe:insert( playBtn )
	print ("scene create insert")
end

function scene:show( event )
	print ("show")
	local sceneGruppe = self.view
	local phase = event.phase
	print ("scene show")
	if phase == "will" then
			print ("will show")

		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		score.get()
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGruppe = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGruppe = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGruppe)
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