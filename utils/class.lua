--class
global=_ENV

class=setmetatable({
	new=function(frame,body)
		return setmetatable(body,{
			__index=frame,
			__tostring=function(self)
				local res='{'
				for k,v in pairs(self) do
					if (#res>1) res..=';'
					res..=tostring(k)..'='..tostring(v)
				end
				return res..'}'
			end
		})
	end,
	is=function(self,type)
		local t=getmetatable(self)
		if (t!=nil) t=t.__index
		if (t==nil) return false
		if (t==type) return true
		return self.is(t,type)
	end
},{
	__index=_ENV
})