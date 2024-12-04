--state machine
--REQUIRES (class.lua)

state=class:new{
	init=function()end,	--called when state is mounted
	update=function()end,
	draw=function()end,
	close=function()end	--called when state is unmounted
}

statemachine=state:new{
	stack={},
	state=nil,
	push=function(_ENV,s)
		if (state!=nil) then
			add(stack,state)
			state:close()
		end
		state=s
		state:init()
	end,
	replace=function(_ENV,s)
		if (state!=nil) state:close()
		state=s
		state:init()
	end,
	pop=function(_ENV)
		local rm=state
		rm:close()
		if (#stack>0) then
			state=deli(stack,#stack)
			state:init()
		else
			state=nil
		end
		return rm
	end,
	init=function(_ENV)
		if (state!=nil) state:init()
	end,
	update=function(_ENV)
		if (state!=nil) state:update()
	end,
	draw=function(_ENV)
		if (state!=nil) state:draw()
	end
}