
require("lib.Helper")

local function main()
	display.setStatusBar( display.HiddenStatusBar )
	math.randomseed( os.time() )

	local composer = require "composer"
	composer.gotoScene( "scene_game" )
end

main()