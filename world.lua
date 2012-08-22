local sprites = require "gfx"
local Gamestate = require "lib.gamestate"
local module = Gamestate.new()
Gamestate.world = module

module.change = 16

local landscape = sprites.landscape

-- TODO: different levels/maps/locations
-- Yes, the map is 7x7, deal w/ it 4 now
local map_data = {
	1, 1, 1, 1, 1, 1, 1,
	1, 2, 2, 2, 2, 2, 1,
	1, 2, 3, 3, 3, 2, 1,
	1, 2, 3, 4, 3, 2, 1,
	1, 2, 3, 3, 3, 2, 1,
	1, 2, 2, 2, 2, 2, 1,
	1, 1, 1, 1, 1, 1, 1,
}

local batch = love.graphics.newSpriteBatch(landscape.image, #map_data)
batch:bind()
local i = 0;
for y = 0, 6 do
	for x = 0, 6 do
		i = i + 1;
		batch:addq(landscape[map_data[i]], x*16, y*16)
	end
end
batch:unbind();

function module:enter()
	-- TODO: something about picking different portions of the world such as
	-- starting in different towns

	self.x = 0
	self.y = 0
end

function module:draw()
	local graphics = love.graphics
	graphics.push()
	graphics.scale(2, 2)

	graphics.print(("(%d, %d)"):format(self.x, self.y), 0, 0)
	graphics.draw(batch, self.x, self.y)

	graphics.pop()
end

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