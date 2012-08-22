--package.path = package.path .. ";./?/init.lua"
require "lib.gamestate"
--require("utils")
require "lib.soundmanager"

--states requires
require "intro"
require "smain"

function love.load()
	love.graphics.setBackgroundColor(50, 50, 50)

	--Set Random Seed
	math.randomseed(os.time());
	for i=1,3 do math.random() end

	Gamestate.registerEvents()
	Gamestate.switch(Gamestate[(arg[2] and arg[2]:match("--state=(.+)") or "intro")])
end

