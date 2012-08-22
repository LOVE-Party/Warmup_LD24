local SIZE = 16 -- size of tiles

--- Player
-- Attempting to manually walk the player will prove prolbematic at the moment
-- it will be easier after adding callbacks to when a destination is reached
-- but this is not needed yet.
local player = {
	speed = 4;  -- blocks per second
	steps = 8;  -- number of steps to take when moving between blocks
--	destination = {
--		x = 0; y = 0;   -- direction to travel in
--		steps = -1;
--	};

	-- Internals
	move_timer = 0;
--	next_destination = {
--		x = 0; y = 0;
--		steps = 0;
--	};
}
function player:draw()
	-- sprites go here
	love.graphics.circle("fill", self.pos_x*SIZE+8, self.pos_y*SIZE+8, 8)
end
function player:update(world, dt)
	local dst = self.destination
	self:keypress(world)

	self.move_timer = self.move_timer - dt;
	if self.move_timer <= 0 then
		self.move_timer = 1 / (self.speed * self.steps)

		if dst.steps > 0 then
			self.pos_x = self.pos_x + dst.x * (1 / self.steps)
			self.pos_y = self.pos_y + dst.y * (1 / self.steps)
			dst.steps = dst.steps - 1;
		end
		if dst.steps == 0 then
			local ndst = self.next_destination
			dst.x = ndst.x
			dst.y = ndst.y
			dst.steps = ndst.steps

			ndst.x = 0
			ndst.y = 0
			ndst.steps = 0
		end
	end
end
function player:can_move(world, x, y)
	local map = world.map
	local data = map.data
	return data[y] and data[y][x] and map.raw[data[x][y]][2] -- "'dem tables"
end
function player:random_position(world)
	local map = world.map.data
	local x, y

	repeat
		y = math.random(1, #map)
		x = math.random(1, #map[y])
		until map[y] and map[y][x] and self:can_move(world, x, y)

	self.pos_x = x - 1
	self.pos_y = y - 1
end
function player:keypress(world) -- not the event, just checks all this
	local key = love.keyboard.isDown
	local x, y

	if key "left" then x = -1 end
	if key "right" then x = x and 0 or 1 end -- holding both does nothing

	if key "up" then y = -1 end
	if key "down" then y = y and 0 or 1 end

	if x or y then
		x = x or 0
		y = y or 0

		-- basic: "is destination a place I can stand?"
		if not self:can_move(world, self.pos_x+x+1, self.pos_y+y+1) then return end

		-- advanced: "will going diagonally hit something?"
		local sum = x + y;
		if sum == 0 or math.abs(sum) == 2 then
			if not self:can_move(world, self.pos_x+x+1, self.pos_y+1  ) then return end
			if not self:can_move(world, self.pos_x+1,   self.pos_y+y+1) then return end
		end

		local dst = self.destination
		local ndst = self.next_destination

		if dst.steps <= 0 then  -- not moving
			dst.steps = self.steps
			dst.x = x
			dst.y = y
		elseif dst.steps <= self.steps/4 then
			ndst.steps = self.steps
			ndst.x = x
			ndst.y = y
		end
	end
end

local mt = {__index = player};

return setmetatable(player, {
	__call = function(self, t)
		t = t or {};
		t.destination = t.destination or {
			x = 0; y = 0;   -- direction to travel in
			steps = -1;
		}
		t.next_destination = t.next_destination or {
			x = 0; y = 0;
			steps = 0;
		};
		t.move_timer = 0;
		return setmetatable(t, mt);
	end,
})