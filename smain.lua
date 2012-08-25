-------------------------------------------------------------------------
-- [smain.lua]
-- Main menu
-------------------------------------------------------------------------
local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"
local Monster = require "mon"
local Ability = require "abilities"
local sprites = require "gfx"

local _M = Gamestate.new()
-------------------------------------------------------------------------
Gamestate.main = _M
_M.name = "Main"

_M.options = {
	{'Battle Test', function(s)
		local alist = Ability.list;
		local monsters = {
			Monster:new {name = "Circuloid"; scale = 2;
				image = sprites.monsters[1];
				scale = 2;
				abilities = {
					alist.bite,
					alist.leech,
					alist.crush,
					alist.heal,
				}
			},
			Monster:new {name = "Lafolie!"; scale = 2;
				image = sprites.monsters[2];
				abilities = {
					alist.bite,
					alist.heal,
					alist.thick_hide,
					alist.buffed,
				}
			},
		}
		
		return Gamestate.switch(Gamestate.battle, monsters)
	end };
	{'Map Test', function() Gamestate.switch(Gamestate.world) end};
	{'Credits', function() Gamestate.switch(Gamestate.credits) end};
	{'Exit', function(s) love.event.quit()  end};
}

local width, height = love.graphics.getMode( )
width, height = width / 2, height / 2 -- we scale up by x2

local COLOR_NORMAL   = {200, 200, 200}
local COLOR_SELECTED = {255, 255, 255}

_M.selected = 0


function _M:enter()
	self.time = 0
	local fontimg = love.graphics.newImage("gfx/font.png")
	fontimg:setFilter('nearest', 'nearest')
	local font = love.graphics.newImageFont(fontimg, [[ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz`1234567890[]/\:|?, .'";{}<>-=]])
	love.graphics.setFont(font)
	self.font = font

	self.logo = love.graphics.newImage('gfx/mon-circuloid.png')
	self.logo:setFilter('nearest', 'nearest')
end

function _M:update(dt)
	soundmanager:update(dt)
end

function _M:draw()
	local lg = love.graphics
	local lt = love.timer

	lg.scale(2)

	lg.setFont(self.font)
	
	local scale, rot = (math.sin(self.time)*.05)+.95, (self.time / (math.pi*2))
	lg.draw(self.logo, width/2, height/2, rot, scale, scale, self.logo:getWidth()/2, self.logo:getHeight()/2)
	
	if self.selected == 0 then
		if math.floor(self.time) % 2 == 0 then
--			lg.setFont(self.font_sm)
			local msg = "Press any button to continue."
			local center = (width - lg.getFont():getWidth(msg)) / 2
			lg.print(msg, center, height*.75)
		end
	else
		local offset = height * .1
		local indent = offset
		local font, fh = lg.getFont()
		fh = font:getHeight()

		for i =#self.options, 1, -1 do
			lg.setColor(self.selected == i and COLOR_SELECTED or COLOR_NORMAL)
			-- we have to subtract an extra line height, because fonts are=
			--  rendered from the topline, not the baseline.
			lg.print(self.options[i][1], indent, (height-fh)-offset) 
			offset = offset + fh
		end
	end
end

function _M:update(dt)
	self.time = self.time+dt
end

function _M:keypressed(key, unicode)
	print(string.format("Keypressed: '%s'", key))
	local selected = self.selected
	if selected == 0 then
		selected = 1
	else
		if key == 'down' then
			selected = selected + 1
			if selected > #self.options then selected = 1 end
		elseif key == 'up' then
			selected = selected - 1
			if selected < 1 then selected = #self.options end
		elseif key == 'enter' or key == 'return' or key == ' ' then
			local option = self.options[self.selected]
			print(string.format("doing option '%s' [%d] ", tostring(option[1]),selected))
			option[2](self)
		end
	end
	self.selected = selected
end

function _M:mousepressed(x, y, button)

end

function _M:leave()

end
-------------------------------------------------------------------------
return _M
