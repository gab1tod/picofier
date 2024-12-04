--camera
function cam(targ,w,h,v,t)
	local cam={}
	--targ must have x and y
	cam.targ=targ
	cam.x=targ.x
	cam.y=targ.y
	cam.ww=w	--window width
	cam.wh=h	--window height
	cam.v=v	--velocity
	cam.t=t	--response time
	cam.hb={⬅️=0,➡️=896,⬇️=128}	--hard bounds
	cam.cx=62	--camera center point
	cam.cy=62
	
	function cam:update()
		local targ={
			x=cam.targ.x+cam.targ.vx*6+(cam.targ.d-cam.targ.vx/3)*24,
			y=cam.targ.y+cam.targ.vy*6
		}

		if (btn(⬇️)) targ.y+=56
		if (btn(⬆️)) targ.y-=56

		--thresholds
		local lt=targ.x-cam.ww/2
		local rt=targ.x+cam.ww/2
		local tt=targ.y-cam.wh/2
		local bt=targ.y+cam.wh/2
		
		if (cam.x<lt) then
			cam.xpts=nil
			if (cam.xnts==nil) cam.xnts=time()
			if (time()-cam.xnts>cam.t) cam.x+=(targ.x-cam.x)*cam.v
		elseif (cam.x>rt) then
			cam.xnts=nil
			if (cam.xpts==nil) cam.xpts=time()
			if (time()-cam.xpts>cam.t) cam.x+=(targ.x-cam.x)*cam.v
		else
			cam.xnts=nil
			cam.xpts=nil
		end

		if (cam.y<tt) then
			cam.ypts=nil
			if (cam.ynts==nil) cam.ynts=time()
			if (time()-cam.ynts>cam.t) cam.y+=(targ.y-cam.y)*cam.v
		elseif (cam.y>bt) then
			cam.ynts=nil
			if (cam.ypts==nil) cam.ypts=time()
			if (time()-cam.ypts>cam.t) cam.y+=(targ.y-cam.y)*cam.v
		else
			cam.ynts=nil
			cam.ypts=nil
		end
		
		--bounds
		local b=cam.hb
		cam.x-=cam.cx
		cam.y-=cam.cy
		if (b.⬅️!=nil and cam.x<b.⬅️) cam.x=b.⬅️
		if (b.➡️!=nil and cam.x>b.➡️) cam.x=b.➡️
		if (b.⬆️!=nil and cam.y<b.⬆️) cam.y=b.⬆️
		if (b.⬇️!=nil and cam.y>b.⬇️) cam.y=b.⬇️
		cam.x+=cam.cx
		cam.y+=cam.cy
		
	end
	function cam:draw()
		local x=cam.x-cam.cx
		local y=cam.y-cam.cy
		camera(x,y)
	end
	return cam
end