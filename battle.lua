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

local COLOR_BLACK = {  0,   0,   0}
local COLOR_WHITE = {255, 255, 255}
local COLOR_RED   = {255,   0,   0}
local COLOR_GREEN = {  0, 255,   0}

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
	local old_mode = self.mode
	if mode then  -- start a new context
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
		self.exit = self.exit or __empty__
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
			self:exit(state)
			return menu:change()
		end
	end,
	keypressed = function(self, key)
		if key == "return" then
			self:exit(state)
			return menu:change()
			-- TODO long text that needs scrolling
		end
	end;
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
			return self.list[pos][2](self, state)
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

local function opponent_AI(state)
	state.turn = 2
	local me  = state.monsters[2]
	local target = state.monsters[1]
	local options = {}
	for k, v in pairs(me.abilities) do
		if v.type == 'self' and me:canuse(me, v) then
			options[#options+1] = v
		elseif v.type == 'target' and me:canuse(target, v) then
			options[#options+1] = v
		end
	end
	local action = options[math.random(1,#options)]
	assert(action, "Why don't I have a valid action?")
	
	menu_list.used_ability.text = ("%s used %s."):format(
		me.name,
		action.name
	)
	menu_list.used_ability.action = action
	state.action = action
	menu.next = menu_list.used_ability;
end

local function turn(self, state)
	if state.turn == 1 then
		state.turn = 2  -- It's now the opponent's turn
		return opponent_AI(state)
	else
		state.turn = 1; -- It's now the player's turn
		menu.next = menu_list.main
	end
end

menu_list = {
	welcome = menu_display{timer = 2, text = "Welcome!"};

	used_ability = menu_display{
		name = 'used_ability';
		timer = 1; text = "";   -- set in callback
		exit = function(self, state)
			print(self.name)
			local hit, attacker, defender
			local action = self.action
			assert(action, "Why don't I have a valid action?")

			if state.turn == 1 then
				attacker, defender = state.monsters[1], state.monsters[2]
			else
				attacker, defender = state.monsters[2], state.monsters[1]
			end
				hit = attacker:useability(defender, action)
				
				menu_list.ability_result.text = string.format("%s %s!", action.name, hit and 'hit' or 'missed')
				menu.next = menu_list.ability_result
		end;
	};
	
	ability_result  = menu_display{
		name = 'ability_result';
		timer = 1; text = "It was used!";
		exit = function(self, ...)
			self.text="BADSTRREF"
			turn(self, ...)
		end
	};
	
	bag    = menu_display{timer = 2;
		name = 'bag'; text = "You have no bag!"};
	team   = menu_display{timer = 2;
		name = 'team';  text = "You are alone!"};
	run    = menu_display{timer = 2;
		name = 'run';  text = "You cannot escape!"};

	main = menu_options{
		name = 'menu_options'; 
		pos = 1;
		text = "ARE YOU READY FOR BATTLE?!";
		list = {
			{"ATTACK", function(self, state)
				menu:change(menu_list.used_ability)
				menu_list.used_ability.text = ("%s used %s."):format(
					state.monsters[1].name,
					"attack" -- TODO select abilities, eventually
				)
			end},
			{"BAG", function(self, state)
				menu:change(menu_list.bag)
			end},
			{"TEAM", function(self, state)
				menu:change(menu_list.team)
			end},
			{"RUN", function(self, state)
				menu:change(menu_list.run)
			end},
		}
	};
}

local function draw_bar(pos_x, pos_y, value, foreground_color)
	local graphics = love.graphics

	graphics.setColor(COLOR_BLACK)
	graphics.rectangle("fill", pos_x, pos_y, 64, 8)
	graphics.setColor(foreground_color)
	graphics.rectangle("fill", pos_x+2, pos_y+2, value*60, 4)
end

menu:change(menu_list.welcome, menu_list.main);
--end

function state:enter(old_state, monsters)
	self.monsters = monsters;
	state.turn = 1;
end

function state:draw()
	local graphics = love.graphics
	graphics.push()
	graphics.scale(2)

	menu:draw()


	local monster

	-- Player
	-- (0, 160) 16
	monster = self.monsters[1]
	graphics.setColor(COLOR_WHITE)
	graphics.draw(monster.image,  16, 88, 0, monster.scale)
	graphics.print(monster.name, 240, 112)
	draw_bar(240, 128, monster.health / monster.healthmax, COLOR_GREEN)


	-- Opponent
	monster = self.monsters[2]
	graphics.setColor(COLOR_WHITE)
	graphics.draw(monster.image, 240,  8, 0, monster.scale)
	graphics.print(monster.name, 16, 32)
	draw_bar( 16,  48, monster.health / monster.healthmax, COLOR_GREEN)

	graphics.pop()
end

function state:update(dt)
	menu:update(dt)
end

function state:keypressed(key)
	menu:keypressed(key)
end
