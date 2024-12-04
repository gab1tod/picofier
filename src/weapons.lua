--weapons
function weapon(isp,sp,fr,bb)
	local w={}
	w.type={"weapon"}
	w.isp=isp	--icon sprite
	w.sp=sp	--sprite
	w.fr=fr	--fire rate	time
	w.bb=bb	--bullet builder function
	w.ats=0	--action timestamp
	w.ow=nil	--owner(player)
	function w:update()
		if (w.ow==nil) return
		local o=w.ow
		if (btn(❎) and time()-w.ats>w.fr) then
			--shoot
			for i=0,4 do
				local a=rnd(0.2)-0.1
				local v=rnd(2)+0.1
				local tol=rnd(0.1)+0.1
				particle(9,웃.x+3+4*웃.d,웃.y+3,cos(a)*v*웃.d+웃.vx,sin(a)*v+웃.vy,tol,0.99,0)
			end
			w:bb()
			w.ats=time()
			sfx(7,-1,0,6)
		end
	end
	function w:draw()
		local o=w.ow
		if (o==nil or o.sp==18) return
		if (time()-w.ats<w.fr/2) then
			spr(w.sp+4,o.x+o.d,o.y,1,1,o.d<0)
		else
			if (not o.mvg and btn(⬆️)) then
				spr(w.sp+3,o.x+o.d,o.y,1,1,o.d<0)
			else
				spr(o.sp+w.sp-1,o.x+o.d,o.y,1,1,o.d<0)
			end
		end
	end
	function w:is(tp)	--test type(tp)
		for t in all(w.type) do
			if (t==tp) return true
		end
		return false
	end
	return w
end

--bullet
function bullet(sp,x,y,w,h,vx,vy,dp)
	local b=movent(sp,x,y,w,h)
	b.vx=vx
	b.vy=vy
	b.ts=time()	--timestamp
	b.tol=2	--time of life
	b.dp=dp
	b.upd=b.update
	add(b.type,'bullet')
	function b:update()
		b.upd(b)
		if (time()-b.ts>b.tol) del(entities,b)
		if (b.x>cam.x+cam.cx+8 or b.x<cam.x-cam.cx-8) del(entities,b)
		--map collisions
		for i=0,b.w-1 do
			for j=0,b.h-1 do
				if (solid(b.x+i,b.y+j)) then
					del(entities,b)
					if (b.x>cam.x-70 and b.x<cam.x+70) then	--in screen
						for i=0,4 do
							local a=rnd(0.5)-0.25
							local v=rnd(2)+0.1
							local tol=rnd(0.1)+0.1
							local tile=mget((b.x+i)/8,(b.y+j)/8)
							local tx=(tile%16)*8+rnd(8)
					 	local ty=flr(tile/16)*8+rnd(8)
					 	local tc=sget(tx,ty)
					 	if (tc<1 or tc>15) tc=7
					 	particle(tc,b.x+i,b.y+j,-cos(a)*v*sgn(b.vx),sin(a)*v,tol,0.99,0)
						end
						sfx(7,-1,12)
					end
					break
					break
				end
			end
		end
	end
	function b:draw()
		for y=0,7 do
			for x=0,7 do
				local c=sget(b.sp%16*8+(b.vx<0 and 7-x or x),flr(b.sp/16)*8+y)
				if (c!=0) then
					pset(b.x+x,b.y+0+(b.vy<0 and (b.vx<0 and x-4 or 4-x) or 0),c)
				end
			end
		end
	end
end

function small_bb(w)	--small bullet builder
	if (btn(⬆️)) then
		bullet(101,w.ow.x+w.ow.d*5,w.ow.y+2,4,1,w.ow.d*3,-3,1.1)
	else
		bullet(101,w.ow.x+w.ow.d*5,w.ow.y+4,4,1,w.ow.d*6,0,1.1)
	end
end

--function large_bb(w)	--large bullet builder
--	if (btn(⬆️)) then
--		bullet(85,w.ow.x+w.ow.d*5,w.ow.y+1,8,3,w.ow.d*2,-2,4)
--	else
--		bullet(85,w.ow.x+w.ow.d*5,w.ow.y+3,8,3,w.ow.d*4,0,4)
--	end
--end

--handgun
function handgun(x,y)
	local hi=item(69,x,y)
	add(hi.type,"handgun")
	function hi:cb(웃)
		if (hi.colts!=nil) return
		local hg=weapon(69,96,0.04,nil)
		local hgu=hg.update
		function hg:update()
			hgu(hg)
			if (btn(❎)) hg.ats=time()
		end
		local hgd=hg.draw
		hg.bb=small_bb
		웃.wp=hg
		hg.ow=웃
		hi.colts=time()
		sfx(0)
	end
	function hi:update()
		if (hi.colts!=nil and time()-hi.colts>0.2) del(entities,hi)
	end
	return hi
end

--rifle
function rifle(x,y)
	local hi=item(70,x,y)
	add(hi.type,"rifle")
	function hi:cb(웃)
		if (hi.colts!=nil) return
		local hg=weapon(70,80,0.09,nil)
		local hgu=hg.update
		local hgd=hg.draw
		hg.bb=small_bb
		웃.wp=hg
		hg.ow=웃
		hi.colts=time()
		sfx(0)
	end
	function hi:update()
		if (hi.colts!=nil and time()-hi.colts>0.2) del(entities,hi)
	end
	return hi
end