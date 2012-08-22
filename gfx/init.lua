local img = love.graphics.newImage
local quad = love.graphics.newQuad;

local landscape_img = img("gfx/landscape.png")
local landscape_x = landscape_img:getWidth()
local landscape_y = landscape_img:getHeight()

return {
	landscape = {
		image = landscape_img;
		-- Format:
		-- {Quad, IsWalkable}
		[0] =
		{quad(32,  0, 16, 16, landscape_x, landscape_y), false},    -- nothing
		{quad( 0,  0, 16, 16, landscape_x, landscape_y),  true},    -- grass
		{quad(16,  0, 16, 16, landscape_x, landscape_y),  true},    -- dirt
		{quad( 0, 16, 16, 16, landscape_x, landscape_y),  true},    -- rock
		{quad(16, 16, 16, 16, landscape_x, landscape_y),  true},    -- sand
	};
}
