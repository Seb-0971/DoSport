-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- APP OPTIONS
_APPNAME = "DoSportCopia"
_FONT = "MadeinChina"
_FONT2 = "PermanentMarker.ttf"


-- CONSTANT VALUES
_CX = display.contentWidth*0.5
_CY = display.contentHeight*0.5
_CW = display.contentWidth
_CH = display.contentHeight
_T = display.screenOriginY -- Top
_L = display.screenOriginX -- Left
_R = display.viewableContentWidth - _L -- Right
_B = display.viewableContentHeight - _T-- Bottom
W = display.contentWidth; -- Get the width of the screen
H = display.contentHeight; -- Get the height of the screen
letterboxWidth = math.abs(display.screenOriginX)
letterboxHeight = math.abs(display.screenOriginY)
centerX = W * .5
centerY = H * .5

local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )
 


composer.gotoScene( "menu" , options )