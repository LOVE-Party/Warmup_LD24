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
local COLOR_BLUE  = {  0,   0, 255}

-- Used for menu_display, menu_options
local proxy_mt = {__call = function(self, t)
	setmetatable(t, {__index = self}):create()
	return t
end}

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
		self.mode = assert(self.next, "No next mode")
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
	create = function(self)
		self.exit = self.exit or __empty__
	end;
	start = function(self)
		self.__timer = self.timer;
		self.exit = self.exit or __empty__
	end,
	draw = function(self, pos_x, pos_y, size_x, size_y)
		local graphics = love.graphics

		graphics.setColor(COLOR_WHITE)
		graphics.rectangle("fill", pos_x, pos_y, size_x, size_y)

		graphics.setColor(COLOR_BLACK)
		graphics.rectangle("line", pos_x, pos_y, size_x, size_y)

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

local menu_main = setmetatable({
	create = function(self, ...)
	end;
	start = function(self)
		self.display:start()
	end;
	draw = function(self)
		return self.display:draw(8, 168, 304, 64)
	end;
	update = function(self, dt)
		return self.display:update(dt)
	end;
	keypressed = function(self, key)
		return self.display:keypressed(key)
	end;
}, proxy_mt)

local menu_options = setmetatable({
	create = __empty__;
	start = function(self)
		self.__pos = self.pos;
	end,
	draw = function(self, pos_x, pos_y, size_x, size_y)
		local graphics = love.graphics


		-- background
		graphics.setColor(COLOR_WHITE)
		graphics.rectangle("fill", pos_x, pos_y, size_x, size_y)

		graphics.setColor(COLOR_BLACK)
		graphics.rectangle("line", pos_x, pos_y, size_x, size_y)

		local list = self.list;

		graphics.print(list[1][1], pos_x + 8, pos_y + 8)
		graphics.print(list[2][1], pos_x + size_x/2 + 8, pos_y + 8)
		graphics.print(list[3][1], pos_x + 8, pos_y + 32)
		graphics.print(list[4][1], pos_x + size_x/2 + 8, pos_y + 32)

		local pos = self.__pos;
		local x, y
		x = pos_x + ((pos == 1 or pos == 3) and 2 or 2 + size_x/2)
		y = pos_y + ((pos == 1 or pos == 2) and 10 or 34)

		graphics.rectangle("fill", x, y, 4, 4)
	end,
	update = __empty__,
	keypressed = function(self, key)
		local pos = self.__pos;
		local new;
		-- clean this up sometime
		if key == "return" then
			if self.list.func then
				return self.list.func(self)
			else
				return self.list[pos][2](self, state)
			end
		elseif key == "right" then
			if pos == 1 or pos == 3 then
				new = pos == 1 and 2 or 4;
			end
		elseif key == "left" then
			if pos == 2 or pos == 4 then
				new = pos == 2 and 1 or 3;
			end
		elseif key == "up" then
			if pos == 3 or pos == 4 then
				new = pos == 3 and 1 or 2;
			end
		elseif key == "down" then
			if pos == 1 or pos == 2 then
				new = pos == 1 and 3 or 4;
			end
		end

		if new then
			if self.list[new][1] ~= "" then
				self.__pos = new;
			end
		end
	end,
}, proxy_mt)

local menu_split = setmetatable({
	start = function(self)
		self.left:start()
		self.right:start()
	end;
	create = function(self)
		self.name = "MenuSplit"
		self:set_mode(self.mode)
		self.right = self.list.options1
	end;
	draw = function(self)
		self.left:draw(  8, 168, 202, 64)
		self.right:draw(210, 168, 102, 64)
	end;
	update = function(self, dt)
		if self.mode == 1 then
			self.right:update(dt)
		elseif self.mode == 2 then
			self.left:update(dt)
		end
	end,
	keypressed = function(self, key)
		if self.mode == 1 then
			self.right:keypressed(key)
		elseif self.mode == 2 then
			self.left:keypressed(key)
		end
	end;
	set_mode = function(self, n)
		self.mode = n
		if n == 1 then
			self.left = self.list.display
		elseif n == 2 then
			self.left = self.list.options2
		end
		self.left:start()
	end
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


--function love.load()
io.stdout:setvbuf("line")

local menu_list

local function AI_React(state)
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
	local ability = options[math.random(1,#options)]
	assert(ability, "Why don't I have a valid action?")

	menu_list.used_ability.display.text = ("%s used %s."):format(
		me.name,
		ability.name
	)
	menu_list.used_ability.display.ability = ability
	menu.next = menu_list.used_ability;
end

local function turn(self, state)
	if state.turn == 1 then
		state.turn = 2  -- It's now the opponent's turn
		return AI_React(state)
	else
		state.turn = 1; -- It's now the player's turn
		menu_list.main:set_mode(1)
		menu.next = menu_list.main
	end
end

menu_list = {
	welcome = menu_main{
		display = menu_display{timer = 2, text = "Welcome!" };
	};

	used_ability = menu_main{
		display = menu_display{
			timer = 1; text = "";   -- set in callback
			exit = function(self, state)
				local hit, attacker, defender
				if state.turn == 1 then
					attacker, defender = state.monsters[1], state.monsters[2]
				else
					attacker, defender = state.monsters[2], state.monsters[1]
				end

				local ability = self.ability
				assert(ability, "Why don't I have a valid action?")
				hit = attacker:useability(defender, ability)

				menu_list.ability_result.display.text = string.format("%s %s!", ability.name, hit and 'succeeded' or 'failed')
				menu.next = menu_list.ability_result
			end;
		};
	};
	ability_result  = menu_main{
		name = 'ability_result';
		display = menu_display{timer = 1; text = "Ability used!"; exit = turn};
	};

	bag    = menu_main{
		display = menu_display{timer = 2; text = "You have no bag!"};
	};
	team   = menu_main{
		display = menu_display{timer = 2; text = "You are alone!"};
	};
	run    = menu_main{
		display = menu_display{timer = 2; text = "You cannot escape!"};
	};

	main = menu_split{
		mode = 1;
		list = {
			display = menu_display{text = "ARE YOU READY FOR BATTLE?!"};
			options1 = menu_options{
				pos = 1;
				list = {
					{"ATTACK", function(self, state)
						menu_list.main:set_mode(2)
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
				};
			};
			options2 = menu_options{
				pos = 1;
				start = function(self)
					self.__pos = self.pos
					local monster = state.monsters[1]
					for i = 1, #monster.abilities do
						self.list[i][1] = monster.abilities[i].name
					end
				end;
				list = {
					func = function(self, n) -- general callback
						local ability = state.monsters[1].abilities[self.__pos]
						menu_list.used_ability.display.text = ("%s used %s."):format(
							state.monsters[1].name,
							ability.name
						)
						menu_list.used_ability.display.ability = ability;
						menu:change(menu_list.used_ability)
					end,
					{"", __empty__},  -- individual callbacks ignored
					{"", __empty__},
					{"", __empty__},
					{"", __empty__},
				};
			};
		};
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
	self.font = love.graphics.getFont()
	self.monsters = monsters;
	state.turn = 1;
end

function state:draw()
	local graphics = love.graphics
	graphics.setFont(self.font)
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
	draw_bar(240, 128+10, monster.energy / monster.energymax, COLOR_BLUE)


	-- Opponent
	monster = self.monsters[2]
	graphics.setColor(COLOR_WHITE)
	graphics.draw(monster.image, 240,  8, 0, monster.scale)
	graphics.print(monster.name, 16, 32)
	draw_bar( 16,  48, monster.health / monster.healthmax, COLOR_GREEN)
	draw_bar( 16,  48+10, monster.energy / monster.energymax, COLOR_BLUE)

	graphics.pop()
end

function state:update(dt)
	menu:update(dt)
end

function state:keypressed(key)
	menu:keypressed(key)
end
