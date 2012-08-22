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
	m = {}
	setmetatable(m, _MT)
	
	m.name      = t.name or "Circuloid"
	m.level     = t.level or 1
	m.image     = t.image or "mon-circuloid"
	m.abilities =  {}
	if t.abilities then
		for i=1,#t.abilities do
			m.abilities[i] = t.abilities[i]
		end
	else
		m.abilities[1] = abilities.list.bite
	end
	
	-- Provisional stats, purely for the sake of testing.
	m.speed    = t.speed or m.level -- dodge, initative
	m.strength = t.power or m.level -- damage
	m.tough    = t.tough or m.level -- Toughness, defence
	m.healthmax = t.healthmax or t.health or (m.level * 7) + m.tough
	m.health    = t.health or m.healthmax
	m.energymax = t.energymax or t.energy or (m.level * 3) + m.speed
	m.energy    = t.energy or m.energymax
	
	
	return m
end

function _M:attack(target, ability)
	ability = ability or self.abilities[1]
	local r = function(n) return math.random(n-1, n) end
	local a, b = r(self.speed+ability.initative), r(target.speed)
	local dam = 0
	if a > b then
		dam = ability:use(self, target)
	end
	return a>b, a, b, dam
end


function _M:dobasicattack(target)
	local r = function(n) return math.random(n-1, n) end
	local a, b = r(self.speed), r(target.speed)
	if a > b then
		local dam  = self.strength - target.tough
		dam = dam > 0 or 1
		target:damage(dam)
		return true, a, b, dam
	end
	return false, a, b, 0
end

function _M:damage(n)
	assert(type(n) == 'number', "Damage must be a number")
	assert(n >=0, "Damage must be a positive number")
	n = n-self.tough
	n = n > 0 and n or 1
	self.health = self.health - n
	self.health = self.health >=0 and self.health or 0
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

