local img = love.graphics.newImage
local quad = love.graphics.newQuad;

local landscape_img = img("gfx/landscape.png")
local landscape_x = landscape_img:getWidth()
local landscape_y = landscape_img:getHeight()

return {
	landscape = {
		image = landscape_img;
		quad( 0,  0, 16, 16, landscape_x, landscape_y), -- grass
		quad(17,  0, 16, 16, landscape_x, landscape_y), -- dirt
		quad( 0, 17, 16, 16, landscape_x, landscape_y), -- rock
		quad(17, 17, 16, 16, landscape_x, landscape_y), -- sand
	};
}
