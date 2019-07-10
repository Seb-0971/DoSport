-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )



-- Initialize variables
W = display.contentWidth; -- Get the width of the screen
H = display.contentHeight; -- Get the height of the screen

local lives = 3
local score = 0
local died = false
 
local ballsTable = {}
 
local car
local gameLoopTimer
local livesText
local scoreText



-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local worldGroup= display.newGroup()
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load the background
local background = display.newImageRect( backGroup, "soccerBG.jpg", (letterboxWidth*2)+W , (letterboxHeight*2)+ H )
background.x = display.contentCenterX
background.y = display.contentCenterY
background.alpha = 0.8


-- Declare initial variables
local letterboxWidth = math.abs(display.screenOriginX)
local letterboxHeight = math.abs(display.screenOriginY)


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
livesText = display.newText( uiGroup, "Lives: " .. lives, -letterboxWidth+50, -letterboxHeight+8, native.systemFont, 16 )
scoreText = display.newText( uiGroup, "Score: " .. score, letterboxWidth+W-55, -letterboxHeight+8, native.systemFont, 16 )

local function updateText()
    livesText.text = "Lives: " .. lives
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
                lives = lives - 1
                livesText.text = "Lives: " .. lives
                if ( lives == 0 ) then
                    display.remove( car )
                else
                    car.alpha = 0
                    timer.performWithDelay( 1000, restoreCar )
                end
            end
        end
    end
end

Runtime:addEventListener( "collision", onCollision )

----------------------------------


-- Local variables and forward references
local screenTop 
local screenBottom 
local screenLeft
local screenRight

-- Array for balls to animate (parameters)
local params = --{
	--{ radius=18, xDir=1, yDir=1, xSpeed=2.5, ySpeed=6.0, r=1, g=0, b=0.1 },
	--{ radius=15, xDir=1, yDir=1, xSpeed=3.5, ySpeed=4.0, r=0.95, g=0.1, b=0.3 },
	{ radius=15, xDir=1, yDir=-1, xSpeed=5.5, ySpeed=5.0, r=0.9, g=0.2, b=0.5 }
--}

local ballCollection = {}

local itemParams = params --[item]
	--local ball = display.newCircle( mainGroup, display.contentCenterX, display.contentCenterY, itemParams.radius )
    local ball = display.newImageRect(mainGroup,"soccerBall.png",32,32)
    ball.x = math.random( 100,300 )
    ball.y = math.random( 20,40 )
    ball.alpha=0.8
    --ball:setFillColor( itemParams.r, itemParams.g, itemParams.b )
	ball.xDir = itemParams.xDir
	ball.yDir = itemParams.yDir
	ball.xSpeed = itemParams.xSpeed
	ball.ySpeed = itemParams.ySpeed
	ball.radius = itemParams.radius
    ballCollection[#ballCollection+1] = ball
    ball.myName = "ball"
    physics.addBody( ball,{ isSensor=true } )
    ball:applyTorque( 1 )

-- Iterate through params array and add new balls into "ballCollection" array
local function createBall()
--for item = 1,#params do
	local itemParams = params --[item]
	--local ball = display.newCircle( mainGroup, display.contentCenterX, display.contentCenterY, itemParams.radius )
    local ball = display.newImageRect(mainGroup,"soccerBall.png",32,32)
    ball.x = math.random( 50,400 )
    ball.y = math.random( 20,40 )
    ball.alpha=0.8
    --ball:setFillColor( itemParams.r, itemParams.g, itemParams.b )
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
--end

local function gameLoop()
    -- Create new ball
    createBall()
end

gameLoopTimer = timer.performWithDelay( 5000, gameLoop, 0 )

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
             score = score + 1
             scoreText.text = "Score: " .. score
		end
		if ( yNew > screenBottom - radius or yNew < screenTop + radius ) then
            ball.yDir = -ball.yDir 
             -- Increase score
             score = score + 1
             scoreText.text = "Score: " .. score
		end

		-- Move ball to next delta position
		ball:translate( dx, dy )
	end
end


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
Runtime:addEventListener( "enterFrame", moveBalls )



--------------------------------------------------------
-- Set Variables

motionx = 0; -- Variable used to move character along x axis
speed = 6; -- Set Walking Speed

-- Add player

-- physics.addBody( player, "dynamic", { friction=0.5, bounce=0 } )

-- Add right joystick button
-- local right = display.newRect(0,0,50,50)
local right = display.newImageRect( uiGroup, "right.png",  64, 64 )
right.alpha=0.2
right.x = letterboxWidth+W-32; right.y = letterboxHeight+H-32;

-- Add left joystick button
--local left = display.newRect(0,0,50,50)
local left = display.newImageRect( uiGroup, "left.png",  64, 64 )
left.alpha=0.2
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
