local Gamestate = require "lib.gamestate"
local sprites = require "gfx"
local Player = require "player"

local module = Gamestate.new()
Gamestate.world = module

module.change = 16
local SIZE = 16;
local landscape = sprites.landscape

-- TODO: different levels/maps/locations
-- Yes, the map is 9x9, deal w/ it 4 now
-- Or better yet, let's get started on random generation
local map_data = {
	size = 81;
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 2, 2, 0, 2, 2, 1, 0},
	{0, 1, 2, 3, 3, 3, 2, 1, 0},
	{0, 1, 0, 3, 4, 3, 0, 1, 0},
	{0, 1, 2, 3, 3, 3, 2, 1, 0},
	{0, 1, 2, 2, 0, 2, 2, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
}

local batch = love.graphics.newSpriteBatch(landscape.image, map_data.size)
batch:bind()
local i = 0;
for y = 1, #map_data do
	for x = 1, #map_data[y] do
		batch:addq(landscape[map_data[y][x]][1], (x-1)*SIZE, (y-1)*SIZE)
	end
end
batch:unbind();

-- default starting stuff
-- Place selected map here
module.map = {
	image = landscape.image;
	raw   = landscape;
	batch = batch;
	data  = map_data;

	x = 0;
	y = 0;
}

module.player = Player {
	speed = 4;  -- walk 4 blocks per second
	steps = 8;  -- take 8 steps per block, more = smoother movement
}

module.player:random_position(module)

function module:enter()
	-- TODO: something about picking different portions of the world such as
	-- starting in different towns
end

function module:draw()
	local graphics = love.graphics
	graphics.push()
	graphics.scale(2)

	graphics.draw(self.map.batch, self.map.x, self.map.y)
	self.player:draw()

	graphics.pop()
end

function module:update(dt)
	self.player:update(self, dt)
end

--[[
function module:keypressed(key)
	if key == "left" then
		self.x = self.x - self.change
	elseif key == "right" then
		self.x = self.x + self.change
	elseif key == "up" then
		self.y = self.y - self.change
	elseif key == "down" then
		self.y = self.y + self.change
	end
end
]]