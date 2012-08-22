-------------------------------------------------------------------------
-- [smain.lua]
-- Main menu
-------------------------------------------------------------------------
local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"
local Monster = require "mon"
local sprites = require "gfx"

local _M = Gamestate.new()
-------------------------------------------------------------------------
Gamestate.main = _M
_M.name = "Main"

function _M:enter()
	local fontimg = love.graphics.newImage("gfx/font.png")
	local font = love.graphics.newImageFont(fontimg, [[ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz`1234567890[]/\:|?, ]])
	love.graphics.setFont(font)

	local monsters = {
		Monster:new {
			name = "Circuloid";
			image = sprites.monsters[1];
			scale = 2;
		},
		Monster:new {
			name = "Lafolie!";
			image = sprites.monsters[2];
			scale = 2;
		},
	}
	return Gamestate.switch(Gamestate.battle, monsters)
end

function _M:update(dt)
	soundmanager:update(dt)
end

function _M:draw()
	love.graphics.print("Hello, World!", 24, 53)
end

function _M:keypressed(key, unicode)

end

function _M:mousepressed(x, y, button)

end

function _M:leave()

end
-------------------------------------------------------------------------
return _M
