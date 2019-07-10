
local composer = require( "composer" )

local scene = composer.newScene()

local widget = require "widget"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local W = display.contentWidth; -- Get the width of the screen
local H = display.contentHeight; -- Get the height of the screen
local letterboxWidth = math.abs(display.screenOriginX)
local letterboxHeight = math.abs(display.screenOriginY)
local centerX = W * .5
local centerY = H * .5

local function onPlayTouch(event)
    if(event.phase == "ended") then 
	  --audio.play(_CLICK)
        composer.gotoScene("game","zoomInOutFade")
    end
end



local function gotoGame()
	local options = {
		effect = "fade",
		time = 1000,
		params = { 
			
		}
	}
	composer.gotoScene( "game" ,options)
end

local function gotoHighScores(event)
	if(event.phase == "ended") then 
		--audio.play(_CLICK)
	composer.gotoScene( "highscores" ,"slideUp")
end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Load the background
    local background = display.newImageRect( sceneGroup, "images/menu/bg2.jpg", (letterboxWidth*2)+W , (letterboxHeight*2)+ H )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.alpha = 0.8
	
	-- Load the car for the animation 
	local carS = display.newImageRect(sceneGroup, "images/menu/car.png",60,52)
	local carR = display.newImageRect(sceneGroup, "images/menu/car.png",60,52)
	carS.x = _L -carS.width ; carS.y = _CH * 0.7
	carR.x = _R +carR.width ; carR.y = _CH * 0.7
	carS.alpha=0.8
	carR.alpha=0.8


	-- Transitions
	local moveCarR = transition.to(carR, {x=_CX+150, delay=350})
	local moveCarS = transition.to(carS, {x=_CX-150, delay=350})
	
	--Logo
	local highScoresHeader = display.newText( sceneGroup, "THE NICE SOCCER FACE", display.contentCenterX, _T+40, _FONT2, 40 )


	-- Create some buttons
	local btn_play
	btn_play = widget.newButton {
        width = 150,
        height = 50,
		defaultFile = "images/menu/btn_play.png",
		
        onEvent = onPlayTouch
    }
    btn_play.x = _CX
	btn_play.y = _CY-10
	btn_play.alpha=0.9
	sceneGroup:insert(btn_play)

	local btn_upgrades
	btn_upgrades = widget.newButton {
        width = 150,
        height = 50,
        defaultFile = "images/menu/btn_highscores.png",
        onEvent = gotoHighScores
    }
    btn_upgrades.x = _CX
	btn_upgrades.y = btn_play.y + (btn_upgrades.height * 1.25)
	btn_upgrades.alpha=0.9
    sceneGroup:insert(btn_upgrades)
--
--	local playButton = display.newText( sceneGroup, "Play", centerX, centerY-30, native.systemFont, 30 )
--	playButton:setFillColor(1, 0.4, 0.4)

--	local highScoresButton = display.newText( sceneGroup, "High Scores", centerX, centerY+15, native.systemFont, 30 )
--	highScoresButton:setFillColor( 1, 0.5, 0.5)

--	playButton:addEventListener( "tap", gotoGame )
--	highScoresButton:addEventListener( "tap", gotoHighScores )
--

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
