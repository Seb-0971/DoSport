
local composer = require( "composer" )

local scene = composer.newScene()

local widget = require "widget"


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Initialize variables
local W = display.contentWidth; -- Get the width of the screen
local H = display.contentHeight; -- Get the height of the screen
local letterboxWidth = math.abs(display.screenOriginX)
local letterboxHeight = math.abs(display.screenOriginY)
local screenTop 
local screenBottom 
local screenLeft
local screenRight

local lives = 3
local score = 0
local died = false

local onGameOver ,  btn_returnToMenu

-- Array for balls to animate (parameters)
local params = --{
	--{ radius=18, xDir=1, yDir=1, xSpeed=2.5, ySpeed=6.0, r=1, g=0, b=0.1 },
	--{ radius=15, xDir=1, yDir=1, xSpeed=3.5, ySpeed=4.0, r=0.95, g=0.1, b=0.3 },
	{ radius=15, xDir=1, yDir=-1, xSpeed=5.5, ySpeed=5.0, r=0.9, g=0.2, b=0.5 }
--}

local ballCollection = {}
 
local car
local gameLoopTimer
local livesText
local livesImage = {}
local scoreText
local finalScoreText

-- Set up display groups
local backGroup   -- Display group for the background image
local mainGroup   -- Display group for the ship, asteroids, lasers, etc.
local worldGroup
local uiGroup     -- Display group for UI objects like the score

local function updateText()
    --livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end



local function restoreCar()
 
    car.isBodyActive = false
    car.x = display.contentCenterX
    car.y = letterboxHeight+H-28
 
    -- Fade in the car
    transition.to( car, { alpha=1, time=500,
        onComplete = function()
            car.isBodyActive = true
            died = false
        end
    } )
end


	
local function createBall()
	local itemParams = params --[item]
	local ball = display.newImageRect(mainGroup,"soccerBall.png",32,32)
	ball.x = math.random( 50,400 )
	ball.y = math.random( 20,40 )
	ball.alpha=0.8
	ball.xDir = itemParams.xDir
	ball.yDir = itemParams.yDir
	ball.xSpeed = itemParams.xSpeed
	ball.ySpeed = itemParams.ySpeed
	ball.radius = itemParams.radius
	ballCollection[#ballCollection+1] = ball
	ball.myName = "ball"
	physics.addBody( ball,{ isSensor=true } )
    ball:applyTorque( 1 )
    
end

local function gameLoop()
    -- Create new ball
    if(lives~=0) then 
    createBall() 
    end
end

--local function endGame()
   -- composer.setVariable( "finalScore", score )
    --composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
--end

--local function gotoMenu()
--composer.gotoScene( "menu", { time=800, effect="crossFade" } )
--end

local function onHighscoresTouch(event)
    if(event.phase == "ended") then 
      --audio.play(_CLICK)
        composer.gotoScene("highscores", "slideUp")
    end
end

local function goToMenu(event)
	if(event.phase == "ended") then 
		--audio.play(_CLICK)
	composer.gotoScene( "menu",{ time=600, effect="crossFade" }  )
end
end


function onGameOver()
    --audio.play(_GAMEOVER)
    composer.setVariable( "finalScore", score )
    
    Runtime:removeEventListener("enterFrame", sendEnemies)
    Runtime:removeEventListener("collision", onCollision)

    
    for i=1,#ballCollection do
        if(ballCollection[i] ~= nil) then 
            ballCollection[i].alpha=0
        end
    end 

    

    
    
    gameoverBackground = display.newRect(worldGroup, 0, 0, (letterboxWidth*2)+W , (letterboxHeight*2)+ H)
        gameoverBackground.x = _CX; gameoverBackground.y = _CY
        gameoverBackground:setFillColor(0)
        gameoverBackground.alpha = 0.6

    gameOverBox = display.newImageRect(worldGroup, "gameover.png", 200, 60)
        gameOverBox.x = _CX; gameOverBox.y = _CY - gameOverBox.height*1.5



        --local menuButton = display.newText( worldGroup, "Menu", display.contentCenterX, H-10, _FONT, 40 )
		--menuButton:setFillColor( 0.75, 0.78, 1 )
        --menuButton:addEventListener( "tap", gotoMenu )
        
        scoreText.alpha=0
        display.newText(uiGroup,"YOUR SCORE...",_CX,_CY-32,_FONT2,22)
        finalScoreText = display.newText( uiGroup, " " .. score, _CX, _CY, _FONT2, 22 )
        
        local btn_upgrades
	    btn_upgrades = widget.newButton {
        width = 150,
        height = 50,
        defaultFile = "images/menu/btn_highscores.png",
        onEvent = onHighscoresTouch
    }
    btn_upgrades.x = _CX
	btn_upgrades.y = _B-75
	btn_upgrades.alpha=0.9
    worldGroup:insert(btn_upgrades)

    local btn_menu
	btn_menu = widget.newButton {
        width = 150,
        height = 50,
        defaultFile = "images/menu/btn_menu.png",
        onEvent = goToMenu
    }
    btn_menu.x = _CX
	btn_menu.y = _B-25
	btn_menu.alpha=0.8
    worldGroup:insert(btn_menu)

    
end
 

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "car" and obj2.myName == "ball" ) or
                 ( obj1.myName == "ball" and obj2.myName == "car" ) )
        then
            if ( died == false ) then
                died = true
 
                -- Update lives
                
                if(lives>0) then
                    livesImage[lives].alpha=0
                end 

                lives = lives - 1

                --livesText.text = "Lives: " .. lives
                

                if ( lives == 0 ) then
					display.remove( car )
					timer.performWithDelay( 1000, onGameOver() )
                else
                    car.alpha = 0
                    timer.performWithDelay( 1000, restoreCar )
                end
            end
        end
    end
end

-- Function to update balls on every frame
local function moveBalls( event )

	for i = 1,#ballCollection do

		local ball = ballCollection[i]
		-- Calculate next delta position
		local dx = ( ball.xSpeed * ball.xDir )
		local dy = ( ball.ySpeed * ball.yDir )

		-- If ball has touched any screen edge, reverse direction
		local xNew, yNew = ball.x + dx, ball.y + dy
		local radius = ball.radius
		if ( xNew > screenRight - radius or xNew < screenLeft + radius ) then
            ball.xDir = -ball.xDir 
             -- Increase score
             if ( lives > 0 ) then
             score = score + 1
             scoreText.text = " " .. score
             end
		end
		if ( yNew > screenBottom - radius or yNew < screenTop + radius ) then
            ball.yDir = -ball.yDir 
             -- Increase score
             if ( lives > 0 ) then
                score = score + 1
                scoreText.text = "" .. score
                end
		end

		-- Move ball to next delta position
		ball:translate( dx, dy )
	end
end



    



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	
	physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
    backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
	
	worldGroup = display.newGroup() 
	sceneGroup:insert( worldGroup ) 
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

	-- Load the background
local background = display.newImageRect( backGroup, "soccerBG.jpg", (letterboxWidth*2)+W , (letterboxHeight*2)+ H )
background.x = display.contentCenterX
background.y = display.contentCenterY
background.alpha = 0.8

---Lives
for i=1, lives do
    livesImage[i]= display.newImageRect(uiGroup, "images/heart.png",25 , 25)
    livesImage[i].x = _L + (i*26) 
    livesImage[i].y = _T +15
end 

-- Create "walls" around screen
local wallL = display.newRect( worldGroup, 0-letterboxWidth, display.contentCenterY, 20, display.actualContentHeight )
wallL.anchorX = 1
physics.addBody( wallL, "static", { bounce=1, friction=0.1 } )

local wallR = display.newRect( worldGroup, 480+letterboxWidth, display.contentCenterY, 20, display.actualContentHeight )
wallR.anchorX = 0
physics.addBody( wallR, "static", { bounce=1, friction=0.1 } )

-- Create character
car = display.newImageRect( mainGroup, "car.png" , 60, 52)
car.x = display.contentCenterX
car.y = letterboxHeight+H-28
car.alpha=0.9

physics.addBody( car,"dynamic", { radius=20, bounce=0.3, friction=0.7 } )
car.myName = "car"

-- Display lives and score
--livesText = display.newText( uiGroup, "Lives: " .. lives, -letterboxWidth+50, -letterboxHeight+8, native.systemFont, 16 )
scoreText = display.newText( uiGroup, " " .. score, letterboxWidth+W-55, -letterboxHeight+8, _FONT2, 16 )

    local itemParams = params --[item]
    local ball = display.newImageRect(mainGroup,"soccerBall.png",32,32)
    ball.x = math.random( 100,300 )
    ball.y = math.random( 20,40 )
	ball.alpha=0.8
	ball.xDir = itemParams.xDir
	ball.yDir = itemParams.yDir
	ball.xSpeed = itemParams.xSpeed
	ball.ySpeed = itemParams.ySpeed
	ball.radius = itemParams.radius
    ballCollection[#ballCollection+1] = ball
    ball.myName = "ball"
    physics.addBody( ball,{ isSensor=true } )
	ball:applyTorque( 1 )
	
	-- Set Variables

motionx = 0; -- Variable used to move character along x axis
speed = 6; -- Set Walking Speed

-- Add player

-- physics.addBody( player, "dynamic", { friction=0.5, bounce=0 } )

-- Add right joystick button
-- local right = display.newRect(0,0,50,50)
local right = display.newImageRect( uiGroup, "right.png",  64, 64 )
right.alpha=0.3
right.x = letterboxWidth+W-32; right.y = letterboxHeight+H-32;

-- Add left joystick button
--local left = display.newRect(0,0,50,50)
local left = display.newImageRect( uiGroup, "left.png",  64, 64 )
left.alpha=0.3
left.x = -letterboxWidth+32 ; left.y = letterboxHeight+H-32;


-- When left arrow is touched, move character left
function left:touch()
    motionx = -speed;
    left.alpha=0.5
    end
    left:addEventListener("touch",left)
   
   -- When right arrow is touched, move character right
    function right:touch()
    motionx = speed;
    right.alpha=0.5
    end
    right:addEventListener("touch",right)
   

   -- Move character
    local function movePlayer (event)
        if lives>0 then
    car.x = car.x + motionx;
        end
    end
    Runtime:addEventListener("enterFrame", movePlayer)

    -- Stop character movement when no arrow is pushed
local function stop (event)
    if event.phase =="ended"   then
     motionx = 0;
     left.alpha=0.2
     right.alpha=0.2
    end
   end
   Runtime:addEventListener("touch", stop )

   

-- Resize event handler
local function onResizeEvent( event )

	-- Get current edges of visible screen, accounting for letterbox areas
	screenTop = display.screenOriginY
	screenBottom = display.contentHeight - display.screenOriginY
	screenLeft = display.screenOriginX
	screenRight = display.contentWidth - display.screenOriginX

	-- Iterate through the ball array and reset the location to center of the screen
	for i = 1,#ballCollection  do
		ballCollection[i].x = display.contentCenterX
		ballCollection[i].y = display.contentCenterY
	end
end



   -- Set up orientation initially after the app starts
onResizeEvent()
Runtime:addEventListener( "resize", onResizeEvent )



	

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
		Runtime:addEventListener( "enterFrame", moveBalls )
		gameLoopTimer = timer.performWithDelay( 5000, gameLoop, 0 )
		

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel( gameLoopTimer )
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
		physics.pause()
		Runtime:removeEventListener( "collision", onCollision )
		Runtime:removeEventListener( "enterFrame", moveBalls  )
		composer.removeScene( "game" )
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
