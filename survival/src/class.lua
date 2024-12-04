--class

global = _ENV

class = setmetatable({
	new = function(self, body)
		body = body or {}
		return setmetatable(body, {__index = self})
	end,
	is = function(self, t)
		if (self == nil) return false
		if (self == t) return true
		local mt = getmetatable(self)
		if (mt != nil) return self.is(mt.__index, t)
		return false
	end
}, {
	__index = _ENV
})