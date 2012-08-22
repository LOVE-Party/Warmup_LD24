	--[[
The fun math for figuring the screen size.

320x240

Menus occupy the bottom 1/3
So start at Y 160.
8 pixel border in each direction so really start at (8, 168)

Display:
	Pos: (8, 168)
	Size: (304, 64)

Options:
	Left:
		Pos: (8, 168)
		Size: (202, 64)
	Right:
		Pos: (210, 168)
		Size: (102, 64)

		Right Text Half:
			Pos: (270, 168)
			Size: (52, 32)
--]]

local Gamestate = require "lib.gamestate"
local state = Gamestate.new()
Gamestate.battle = state;

local function __empty__() end

local COLOR_BLACK = {0, 0, 0}
local COLOR_WHITE = {255, 255, 255}

-- Used for menu_display, menu_options
local proxy_mt = {__call = function(self, t) return setmetatable(t, {__index = self}) end}

local menu = {}
function menu:draw(...)
	return self.mode:draw(...)
end
function menu:update(...)
	return self.mode:update(...)
end
function menu:keypressed(...)
	return self.mode:keypressed(...)
end
function menu:change(mode, next)
	if mode then  -- start a new context
		local old_mode = self.mode
		self.mode = mode
		self.next = next or old_mode;
	else  -- leave current context
		self.mode = assert(mode or self.next, "No next mode")
	end
	self.mode:start();
end

--- menu_display()
-- Creates a new `menu_options` object.
--
--@param `base` the base table from which the functions will operate
-- this table should look like:
-- {
--  timer = 2; -- default time the display shows before changing
--  text = "The text to display"
-- }
local menu_display = setmetatable({
	start = function(self)
		self.__timer = self.timer;
	end,
	draw = function(self)
		local graphics = love.graphics

		graphics.setColor(COLOR_WHITE)
		graphics.rectangle("fill", 8, 168, 304, 64)

		graphics.setColor(COLOR_BLACK)
		graphics.rectangle("line", 8, 168, 304, 64)

		graphics.printf(self.text, 16, 176, 296)
	end,
	update = function(self, dt)
		self.__timer = self.__timer - dt
		if self.__timer <= 0 then
			menu:change()
		end
	end,
	keypressed = __empty__;
}, proxy_mt)


--- menu_options()
-- Creates a new `menu_options` object.
--
--@param `base` the base table from which the following functions will operate
-- this table should look like this:
-- {
--  pos = 1; -- 1-4, the position of the cursor, in the order below
--  text = "the text on the left side";
--  list = {
--   {"TOP_LEFT", callback}
--   {"TOP_RIGHT", callback}
--   {"BOTTOM_LEFT", callback}
--   {"BOTTOM_RIGHT", callback}
-- }
local menu_options = setmetatable({
	start = function(self)
		self.__pos = self.pos;
	end,
	draw = function(self)
		local graphics = love.graphics

		-- background
		graphics.setColor(COLOR_WHITE)
		graphics.rectangle("fill", 8, 168, 304, 64)

		graphics.setColor(COLOR_BLACK)
		-- left box (228x64)
		graphics.rectangle("line", 8, 168, 202, 64) -- 76
		-- right box (76x64)
		graphics.rectangle("line", 210, 168, 102, 64)

		graphics.printf(self.text, 16, 176, 196)

		local list = self.list;

		graphics.print(list[1][1], 218, 176)
		graphics.print(list[2][1], 270, 176)
		graphics.print(list[3][1], 218, 208)
		graphics.print(list[4][1], 270, 208)

		local pos = self.__pos;
		local x, y
		x = (pos == 1 or pos == 3) and 212 or 264
		y = (pos == 1 or pos == 2) and 178 or 210

		graphics.rectangle("fill", x, y, 4, 4)
	end,
	update = __empty__,
	keypressed = function(self, key)
		local pos = self.__pos;
		-- clean this up sometime
		if key == "return" then
			return self.list[pos][2](self)
		elseif key == "right" then
			if pos == 1 or pos == 3 then
				self.__pos = pos == 1 and 2 or 4;
			end
		elseif key == "left" then
			if pos == 2 or pos == 4 then
				self.__pos = pos == 2 and 1 or 3;
			end
		elseif key == "up" then
			if pos == 3 or pos == 4 then
				self.__pos = pos == 3 and 1 or 2;
			end
		elseif key == "down" then
			if pos == 1 or pos == 2 then
				self.__pos = pos == 1 and 3 or 4;
			end
		end
	end,
}, proxy_mt)

--function love.load()
io.stdout:setvbuf("line")

local menu_list
menu_list = {
	welcome = menu_display{timer = 2, text = "Welcome!"};

	attack = menu_display{timer = 2, text = "You cannot attack!"};
	bag    = menu_display{timer = 2, text = "You have no bag!"};
	team   = menu_display{timer = 2, text = "You are alone!"};
	run    = menu_display{timer = 2, text = "You cannot escape!"};

	main = menu_options{
		pos = 1;
		text = "ARE YOU READY FOR BATTLE?!";
		list = {
			{"ATTACK", function() menu:change(menu_list.attack) end},
			{"BAG", function() menu:change(menu_list.bag) end},
			{"TEAM", function() menu:change(menu_list.team) end},
			{"RUN", function() menu:change(menu_list.run) end},
		}
	};
}

menu:change(menu_list.welcome, menu_list.main);
--end

function state:enter()

end

function state:draw()
	local graphics = love.graphics
	graphics.push()
	graphics.scale(2)

	menu:draw()

	graphics.pop()
end

function state:update(dt)
	menu:update(dt)
end

function state:keypressed(key)
	menu:keypressed(key)
end
