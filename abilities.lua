-------------------------------------------------------------------------
-- [abilities.lua]
-- abilities
-------------------------------------------------------------------------
local _M = {_NAME = "abilities", _TYPE = 'module'}
-------------------------------------------------------------------------
local _MT = {__index=_M}

_M.list = {}

function _M:new(t)
	t = t or {}
	local a = {}
	setmetatable(a, _MT)
	
	a.name      = t.name or "Ability"
	a.id        = t.id   or a.name:lower():gsub("%W", "_") -- the internal name of the trait
	a.desc      = t.desc or "Does something"
	a.type      = t.type or 'passive' -- 'passive', 'self', 'target'
	a.tier      = t.tier or 1
	a.cost      = t.cost or 0
	a.initative = 0;
	a.aquire    = t.aquire or function(ability, owner) end
	a.lose      = t.lose or function(ability, owner) end
	a.use       = t.use or function(ability, owner, target) end
	
	return a
end

local function ability(t)
	local a = _M:new(t)
	assert(not _M.list[a.name], string.format("Ability '%s' already exists", a.name))
	_M.list[a.id] = a
	_M.list[#_M.list+1] = a
	return a
end
-------------------------------------------------------------------------
ability {name="Bite", desc="Put pointy teeth in opponent!", type='target';
	use=function(self, owner, target)
		return target:damage(math.random(owner.strength + self.tier))
	end;
}

ability {name="Thick Hide", desc="Other 'mon break teeth on me, ha ha!", type='passive';
	aquire=function(self, owner, target)
		owner.tough = owner.tough+1
	end;
	lose=function(self, owner, target)
		owner.tough = owner.tough-1
	end;
}


-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

