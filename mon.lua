-------------------------------------------------------------------------
-- [mon.lua]
-- Lovely mon module
-------------------------------------------------------------------------
local _M = {_NAME = "mon", _TYPE = 'module'}

--local set     = require "lib.set"
local abilities = require "abilities"
-------------------------------------------------------------------------

local _MT = {__index=_M, __tostring = function(s) return s:tostring() end}

function _M:new(t)
	t = t or {}
	local m = {}
	setmetatable(m, _MT)
	
	m.name      = t.name or "Circuloid"
	m.level     = t.level or 1
	m.image     = t.image -- or "mon-circuloid", use values from `gfx/init.lua`
	m.scale     = t.scale or 1
	m.abilities =  {}
	if t.abilities then
		for i=1,#t.abilities do
			m.abilities[i] = t.abilities[i]
		end
	else
		m.abilities[1] = abilities.list.bite
	end
	
	-- Provisional stats, purely for the sake of testing.
	m.speed     = t.speed     or m.level+2 -- dodge, initative
	m.strength  = t.strength  or m.level+2 -- damage
	m.tough     = t.tough     or m.level   -- Toughness, defence
	m.healthmax = t.healthmax or t.health or (m.level * 7) + m.tough
	m.health    = t.health    or m.healthmax
	m.energymax = t.energymax or t.energy or (m.level * 3) + m.speed
	m.energy    = t.energy    or m.energymax
	
	return m
end

function _M:useability(target, ability)
	if not ability then print "using default attack" end
	ability = ability or self.abilities[1]
	if type(ability) == 'number' then ability = self.abilities[ability] end
	assert(ability, "Could not find a valid ability!")
	if self:canuse(target, ability) then
		self.energy = self.energy - ability.cost
		self.energy = self.energy >= 0 and self.energy or 0
		local r = function(n) return math.random(10)+n end
		local a, b = r(self.speed+ability.initative), target.speed+5
		local dam = 0
		if a > b or target == self then
			dam = ability:use(self, target)
		end
		return a>b, a, b, dam
	else
		return false, 0, 0, 0
	end
end

_M.attack = _M.usability

function _M:canuse(target, ability)
	ability = ability or self.abilities[1]
	if self.energy < ability.cost then
		return false, 'expensive'
	end
	
	return true, 'okay'
end

function _M:hasability(ability)
	for k, v in pairs(self.abilities) do
		if v == ability then return k end
	end
	return false
end

function _M:addability(ability)
	assert(ability, "Cannot add nil abilities")
	assert(not self:hasability(ability), "Cannot add an ability twice")
	self.abilities[#self.abilities+1] = ability
	ability:aquire(self)
end

function _M:delability(ability)
	for k, v in pairs(self.abilities) do
		if v == ability then
			table.remove(self.abilities, k)
			ability:lose(self)
			return v
		end
	end
end

function _M:damage(n)
	assert(type(n) == 'number', "Damage must be a number")
	assert(n >=0, "Damage must be a positive number")
	n = n-math.random(math.ceil(self.tough/2), self.tough)
	n = n > 0 and n or 1
	self.health = self.health - n
	self.health = self.health >=0 and self.health or 0
	return n
end

function _M:drain(n)
	assert(type(n) == 'number', "Damage must be a number")
	assert(n >=0, "Damage must be a positive number")
	n = n-math.random(math.ceil(self.tough/2), self.tough)
	n = n > 0 and n or 1
	self.energy = self.energy - n
	self.energy = self.energy >=0 and self.energy or 0
	return n
end

function _M:heal(n)
	assert(type(n) == 'number', "Damage must be a number")
	assert(n >=0, "Damage must be a positive number")
	n = self.healthmax - self.health
	self.health = self.health + n
	return n
end

function _M:restore(n)
	assert(type(n) == 'number', "Damage must be a number")
	assert(n >=0, "Damage must be a positive number")
	n = self.energymax - self.energy
	self.energy = self.energy + n
	return n
end

function _M:tostring()
	local s = string.format("Name: %s, [%d/%d]-{%d/%d}, No.traits: %d\nSpd: %d, Str:%d, Con:%d",
		self.name, self.health, self.healthmax, self.energy, self.energymax, 
		#self.abilities, self.speed, self.strength, self.tough)
	return s
end
-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

