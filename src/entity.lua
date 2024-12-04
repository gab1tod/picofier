--entity
entities={}
function entity(sp,x,y,w,h)
	local e={}
	e.type={"entity"}
	e.sp=sp	--sprite
	e.x=x
	e.y=y
	e.w=w	--width
	e.h=h	--height
	function e:update()
	end
	function e:draw()
		spr(e.sp,e.x,e.y)
	end
	function e:collide(o)
		--returns true if e collides with o
		local xcol=o.x+o.w>e.x and o.x<e.x+e.w
		local ycol=o.y+o.h>e.y and o.y<e.y+e.h
		return xcol and ycol
	end
	function e:is(tp)	--test type(tp)
		for t in all(e.type) do
			if (t==tp) return true
		end
		return false
	end
	add(entities,e)
	return e
end

--moving entity
function movent(sp,x,y,w,h)
	local me=entity(sp,x,y,w,h)
	add(me.type,"movent")
	me.vx=0	--velocity
	me.vy=0
	me.g=1.2	--gravity
	function me:update()
		me.x+=me.vx
		me.y+=me.vy
	end
	function me:draw()
		spr(me.sp,me.x,me.y,1,1,me.vx<0)
	end
	return me
end


--player
function player(x,y)
	local 웃=movent(1,x,y,5,6)
	add(웃.type,"player")
	웃.sx=x	--spawn x
	웃.sy=y	--spawn y
	웃.wf=1.1	--walk force
	웃.iwf=0.12	--walk force on ice
	웃.jf=7	--jump force
	웃.wjf=9	--wall jump force (x)
	웃.xf=0.7	--floor friction
	웃.ixf=0.96	--iced floor friction
	웃.yf=0.85	--air friction
	웃.wyf=0.55	--walled friction
	웃.jg=0.31	--jump gravity
	웃.d=1	--direction
	웃.jmp=false	--jumping
	웃.fln=true	--falling
	웃.flrts=0	--floored timestamp
	웃.flrt=0.15	--floored delay
	웃.wld=0	--walled (-1:left,1:right,0:none)
	웃.wjit=0.15	--wall jump inibition time
	웃.rit=0.25	--respawn inibition time
	웃.its=0	--inhibition timestamp (disable ⬅️➡️)
	웃.mvg=false	--moving
	웃.enab=true	--enable inputs
	웃.dts=nil --death timestamp
	웃.dit=1	--death inibition time
	웃.wp=nil	--weapon
	웃.flrsp=0	--floor sprite
	웃.wlsp=0	--wall sprite
	function 웃:update()
		local flrd=time()<웃.flrts	--floored
	
		local onice=flrd and 웃.flrsp!=nil and fget(웃.flrsp,2)
	
		--moves
		웃.mvg=false
		if (웃.dts!=nil) then
			웃.y+=0.2
			if (time()>웃.dts) then
				웃.dts=nil
				웃:respawn()
			end
			return
		end
		if (웃.enab) then
			if (time()>웃.its) then
				if (btn(⬅️)) then
					웃.d=-1
					웃.vx=onice and 웃.vx-웃.iwf or 웃.vx-웃.wf
					웃.mvg=true
				end
				if (btn(➡️)) then
					웃.d=1 
					웃.vx=onice and 웃.vx+웃.iwf or 웃.vx+웃.wf
					웃.mvg=true
				end
			end
			if (btn(🅾️) and not 웃.jmp) then
			 if (flrd) then
			 	웃.flrts=0; flrd=false
				 웃.jmp=true
				 웃.vy=-웃.jf
				 웃.wld=0
				 sfx(1,-1,0,8)
				 for i=0,4 do
				 	local x=rnd(4)
				 	local v=rnd(2)+1
				 	local a=rnd(0.2)+0.15
				 	local tol=rnd(0.2)+0.1
				 	local tx=(웃.flrsp%16)*8+rnd(8)
				 	local ty=flr(웃.flrsp/16)*8+rnd(8)
				 	local tc=sget(tx,ty)
				 	particle(tc,웃.x+x,웃.y+7,cos(a)*v,sin(a)*v,tol,0.9,0.5)
				 end
			 elseif (웃.wld!=0) then
			 	웃.jmp=true
			 	웃.vy=-웃.jf
			 	웃.vx=-sgn(웃.wld)*웃.wjf
			 	웃.d=-웃.wld
			 	웃.wld=0
			 	웃.its=time()+웃.wjit
			 	sfx(1,-1,16)
				 for i=0,4 do
				 	local v=rnd(2)+1
				 	local a=rnd(0.2)
				 	local tol=rnd(0.2)+0.1
				 	local tx=(웃.wlsp%16)*8+rnd(8)
				 	local ty=flr(웃.wlsp/16)*8+rnd(8)
				 	local tc=sget(tx,ty)
				 	particle(tc,웃.x+4-웃.d*4,웃.y+7,cos(a)*v*웃.d,sin(a)*v,tol,0.9,0.5)
				 end
			 end
			end
			if (not btn(🅾️)) 웃.jmp=false
			if (웃.wp!=nil) 웃.wp:update()
		end
		
		if (웃.jmp and not (웃.fln or flrd)) then 웃.vy+=웃.jg
		else 웃.vy+=웃.g end
		
		local wslide=not flrd and 웃.wld==웃.d and 웃.vy>0
		
		웃.vx=onice and 웃.vx*웃.ixf or 웃.vx*웃.xf
		if (wslide) then
		 웃.vy*=웃.wyf
		 sfx(3,-1,8)
		 for i=0,1 do
		 	local v=rnd(2)+1
		 	local a=rnd(0.2)+0.23
		 	local tol=rnd(0.2)+0.1
		 	local tx=(웃.wlsp%16)*8+rnd(8)
		 	local ty=flr(웃.wlsp/16)*8+rnd(8)
		 	local tc=sget(tx,ty)
		 	particle(tc,웃.x+4+4*웃.d,웃.y+7,-cos(a)*v*웃.d,sin(a)*v,tol,0.9,0.5)
		 end
		else
		 웃.vy*=웃.yf
		end
		
		웃.x+=웃.vx
		웃.y+=웃.vy
		
		--map collisions
		local fln=웃.fln
		if (웃.vy>0) then
			웃.fln=true
			flrts=0; flrd=false
			for i=2,4 do
				if (solid(웃.x+i,웃.y+7)) then
					웃.flrsp=mget((웃.x+i)/8,(웃.y+7)/8)
					if (fln and 웃.vy>5) then
						--hard landing
						sfx(8)
					 for i=0,8 do
					 	local x=rnd(4)
					 	local v=rnd(3)+1
					 	local a=rnd(0.3)+0.1
					 	local tol=rnd(0.3)+0.1
					 	local tx=(웃.flrsp%16)*8+rnd(8)
					 	local ty=flr(웃.flrsp/16)*8+rnd(8)
					 	local tc=sget(tx,ty)
					 	particle(tc,웃.x+x,웃.y+7,cos(a)*v,sin(a)*v,tol,0.9,0.5)
					 end
					end
					웃.vy=0
					웃.fln=false
					웃.flrts=time()+웃.flrt; flrd=true
					웃.y=flr(웃.y/8)*8
					break
				end
			end
		elseif (웃.vy<0) then
			웃.fln=false
			웃.flrts=0; flrd=false
			for i=2.5,4 do
				if (solid(웃.x+i,웃.y)) then
					웃.vy=0
					웃.y=flr(웃.y/8)*8+7
					break
				end
			end
		end
		
		웃.wld=0
		for i=2,6 do
			if (웃.d>0 and solid(웃.x+8,웃.y+i)) then
				웃.wld=1
				웃.wlsp=mget((웃.x+8)/8,(웃.y+i)/8)
			end
			if (웃.d<0 and solid(웃.x-1,웃.y+i)) then
				웃.wld=-1
				웃.wlsp=mget((웃.x-1)/8,(웃.y+i)/8)
			end
		end
		
		if (웃.vx>0) then
			for i=2,6 do
				if (solid(웃.x+7,웃.y+i)) then
					웃.vx=0
					웃.x=flr(웃.x/8)*8
					break
				end
			end
		elseif (웃.vx<0) then
			for i=2,6 do
				if (solid(웃.x,웃.y+i)) then
					웃.vx=0
					웃.x=flr(웃.x/8)*8+8
				end
			end
		end
		
		for i=2,6 do
			if (deadly(웃.x+i,웃.y+7) or deadly(웃.x+i,웃.y+1)) then
				웃:die()
				return
			end
		end
		
		--entity collisions
		for e in all(entities) do
			if (e!=웃 and 웃:collide(e)) then
				--collide
				if (e:is("checkpoint") and e!=웃.ckp) then
					if (웃.ckp!=nil) 웃.ckp.ck=false
					웃.ckp=e
					e.ck=true
					sfx(4)
				elseif (e:is("item")) then
					e:cb(웃)
				elseif (e:is("zombie") or e:is("cerber") or e:is("invoker")) then
					웃:die()
				end
			end
		end
		
		--sprites
		if (not flrd) then
			if (웃.fln) then
				if (웃.wld!=0) then 웃.sp=18
				else 웃.sp=4 end
			else 웃.sp=3 end
		elseif (웃.mvg) then
			if (웃.sp<2) then
				웃.sp=2
				sfx(3,-1,0,2)
			 for i=0,2 do
			 	local v=rnd(2)+1
			 	local a=rnd(0.2)
			 	local tol=rnd(0.2)+0.1
			 	local tx=(웃.flrsp%16)*8+rnd(8)
			 	local ty=flr(웃.flrsp/16)*8+rnd(8)
			 	local tc=sget(tx,ty)
			 	particle(tc,웃.x+4-4*웃.d,웃.y+7,-cos(a)*v*웃.d,sin(a)*v,tol,0.9,0.5)
			 end
			end
			웃.sp+=0.4
			if (웃.sp>5) then
				웃.sp=2
				sfx(3,-1,0,2)
			 for i=0,2 do
			 	local v=rnd(2)+1
			 	local a=rnd(0.2)
			 	local tol=rnd(0.2)+0.1
			 	local tx=(웃.flrsp%16)*8+rnd(8)
			 	local ty=flr(웃.flrsp/16)*8+rnd(8)
			 	local tc=sget(tx,ty)
			 	particle(tc,웃.x+4-4*웃.d,웃.y+7,-cos(a)*v*웃.d,sin(a)*v,tol,0.9,0.5)
			 end
			end
		else
			웃.sp=1
		end
		
		cam.offx=16*웃.d
	end
	function 웃:draw()
		if (웃.dts!=nil and 웃.dts>=time()) then --dead
			--dead
			if (웃.dts>time()+0.9) then
				for i=1,15 do pal(i,7) end
			end
			if (웃.dts<time()+0.4) then
				for i=1,15 do pal(i,2) end
			end
			if (웃.dts<time()+0.2) then
				fillp(░)
			elseif (웃.dts<time()+0.3) then
				fillp(▒)
			end
			pspr(15,웃.x+웃.d,웃.y+2,1,1,웃.d<0)
			pal()
			fillp()
		else
			spr(웃.sp,웃.x+웃.d,웃.y,1,1,웃.d<0)
			if (웃.wp!=nil) then 웃.wp:draw()
			elseif (웃.sp<6) then spr(웃.sp+63,웃.x+웃.d,웃.y,1,1,웃.d<0) end
		end
	end
	function 웃:die()
		bsplash(웃.x,웃.y,16)
		웃.dts=time()+웃.dit
		sfx(5)
		sfx(6)
	end
	function 웃:respawn()
		nb_death+=1
		웃.sp=1
		웃.vx=0
		웃.vy=0
		웃.its=time()+웃.rit
		if (웃.ckp!=nil) then
			웃.x=웃.ckp.x
			웃.y=웃.ckp.y
		else
			웃.x=웃.sx
			웃.y=웃.sy
		end
	end
	return 웃
end


--checkpoint
function checkpoint(x,y,ck)
	local cp=entity(11,x,y,8,8)
	add(cp.type,"checkpoint")
	cp.ck=ck or false	--checked
	function cp:update()
		cp.sp+=0.17
		if (ceil(cp.sp)>15) cp.sp-=4
	end
	function cp:draw()
		if (not cp.ck) pal(8,7)
		spr(cp.sp,cp.x,cp.y)
		pal()
	end
	return cp
end


--item
function item(sp,x,y,cb)
	local i=entity(sp,x-0.5,y-0.5,9,9)
	i.cb=cb	--callback(item,player)
	i.colts=nil	--collected timestamp
	add(i.type,"item")
	function i:draw()
		if (i.colts!=nil) then
			spr(i.sp,i.x,i.y+sin((time()-i.colts)*2.1)*16)
		else
			spr(i.sp,i.x,i.y+cos(time()+i.x/2.05)*1.5)
		end
	end
	return i
end


--coin
function coin(x,y)
	local cp=item(6,x,y)
	add(cp.type,"coin")
	function cp:cb(웃)
		if (cp.colts!=nil) return
		cp.colts=time()
		nb_🅾️+=1
		sfx(0)
	end
	function cp:update()
		cp.sp+=0.27
		if (ceil(cp.sp)>11) cp.sp-=5
		if (cp.colts!=nil and time()-cp.colts>0.2) del(entities,cp)
	end
	return cp
end


--zombie
function zombie(x,y,d)
	local zb=movent(90+rnd(4),x,y,5,6)
	zb.vx=(d or 1)*0.7
	zb.hp=8
	zb.hit=false
	add(zb.type,"zombie")
	local supd=zb.update
	function zb:update()
		supd(zb)
		zb.hit=false
		
		if (solid(zb.x+7,zb.y) or not solid(zb.x+7,zb.y+8)) then
			zb.x=flr(zb.x/8)*8
			zb.vx=-abs(zb.vx)
		end
		if (solid(zb.x,zb.y) or not solid(zb.x,zb.y+8)) then
			zb.x=flr(zb.x/8)*8+8
			zb.vx=abs(zb.vx)
		end
		
		zb.flrsp=mget(zb.x/8,zb.y/8+1)
		
		--entity collisions
		for e in all(entities) do
			if (e!=zb and zb:collide(e)) then
				--collide
				if (e:is("bullet")) then
				 zb.hit=true
					zb.hp-=e.dp
					del(entities,e)
					if (zb.hp<=0) then
						sfx(9,-1,16)
						bsplash(zb.x,zb.y,16)
						local chunk_colors={11,8,3,11}
						for i=1,4 do
							local a=rnd(0.25)+0.125
							local v=rnd(3)+1
							local p=particle(chunk_colors[i],zb.x+3,zb.y+3,cos(a)*v,sin(a)*v,1,0.9,0.5)
							function p:draw()
								rectfill(p.x,p.y,p.x+1,p.y+1,p.sp)
							end
						end
						del(entities,zb)
						--coin(zb.x,zb.y):cb(웃)
					else
						sfx(9,-1,0,8)
						bsplash(zb.x,zb.y,4)
					end
				end
			end
		end
		
		zb.sp+=0.2
		if (zb.sp>=94) then
			zb.sp-=4
			if (zb.x>cam.x-1.5*cam.cx and zb.x<cam.x+1.5*cam.cx) then
				sfx(3,-1,2,2)
			 for i=0,2 do
			 	local v=rnd(2)+1
			 	local a=rnd(0.2)
			 	local tol=rnd(0.2)+0.1
			 	local tx=(zb.flrsp%16)*8+rnd(8)
			 	local ty=flr(zb.flrsp/16)*8+rnd(8)
			 	local tc=sget(tx,ty)
			 	--particle(tc,zb.x+4-4*sgn(zb.vx),zb.y+7,-cos(a)*v*sgn(zb.vx),sin(a)*v,tol,0.9,0.5)
			 	particle(tc,zb.x+4-4*sgn(zb.vx),zb.y+7,-cos(a)*v*sgn(zb.vx),sin(a)*v,tol,0.9,0.5)
			 end
		 end
		end
	end
	function zb:draw()
		if (zb.hit) then
			for i=1,16 do
				pal(i,7)
			end
		end
		spr(zb.sp,zb.x+sgn(zb.vx)*2,zb.y,1,1,zb.vx<0)
		pal()
	end
	return zb
end

--cerber
function cerber(x,y)
	local zb=movent(218,x,y,5,7)
	zb.runf=0.5	--run force
	--zb.jf=7	--jump force
	zb.friction=0.8
	zb.d=1
	zb.hp=12
	zb.hit=false
	zb.chasing=false
	zb.d_chase=76	--chasing distance
	zb.flrd=false
	add(zb.type,"cerber")
	local supd=zb.update
	function zb:update()
		local dx=웃.x-zb.x
		local dy=웃.y-zb.y
		local pchase=zb.chasing
		zb.chasing=abs(dx)<zb.d_chase and abs(dy)<zb.d_chase -- and sgn(dx)==zb.d
		if (zb.chasing and not pchase) sfx(10)
		
		if (zb.chasing) then
			zb.d=sgn(dx)
			zb.vx+=zb.d*zb.runf
		else
			zb.vx=0
		end
		
		zb.vy+=zb.g
		
		zb.vx*=zb.friction
		zb.vy*=zb.friction
		
		supd(zb)
		zb.hit=false
		
		if (zb.vy<0) then
			for i=1,6 do
				if (solid(zb.x+i,zb.y+3)) then
					--move outside block
					zb.y=flr(zb.y/8)*8+8
					zb.vy=0
					break
				end
			end
		end
		if (zb.vy>0) then
			zb.flrd=false
			for i=0,7 do
				if (solid(zb.x+i,zb.y+8)) then
					--move outside block
					zb.y=flr(zb.y/8)*8
					zb.vy=0
					zb.flrd=true
					break
				end
			end
		end
		if (zb.vx<0) then
			for i=0,4 do
				if (solid(zb.x,zb.y+i+3)) then
					--move outside block
					zb.x=flr(zb.x/8)*8+8
					--zb.vx=0
				break
				end
			end
		end
		if (zb.vx>0) then
			for i=0,4 do
				if (solid(zb.x+7,zb.y+i+3)) then
					--move outside block
					zb.x=flr(zb.x/8)*8
					--zb.vx=0
					break
				end
			end
		end
		
		--entity collisions
		for e in all(entities) do
			if (e!=zb and zb:collide(e)) then
				--collide
				if (e:is("bullet")) then
				 zb.hit=true
					zb.hp-=e.dp
					del(entities,e)
					if (zb.hp<=0) then
						sfx(9,-1,16)
					 	bsplash(zb.x,zb.y,16)
						local chunk_colors={0,6,8,0}
						for i=1,4 do
							local a=rnd(0.25)+0.125
							local v=rnd(3)+1
							local p=particle(chunk_colors[i],zb.x+3,zb.y+3,cos(a)*v,sin(a)*v,1,0.9,0.5)
							function p:draw()
								rectfill(p.x,p.y,p.x+1,p.y+1,p.sp)
							end
						end
						del(entities,zb)
						--coin(zb.x,zb.y):cb(웃)
					else
						sfx(9,-1,0,8)
					 	bsplash(zb.x,zb.y,4)
					end
				end
			end
		end
		
		zb.flrsp=mget(zb.x/8,zb.y/8+1)
		
		if (not zb.flrd) then
			zb.sp=zb.vy<0 and 220 or 221
		elseif (zb.vx!=0) then
			zb.sp+=0.4
			if (zb.sp>=222) then
				zb.sp-=4
				if (zb.x>cam.x-1.5*cam.cx and zb.x<cam.x+1.5*cam.cx) then
				sfx(3,-1,4,2)
			 for i=0,2 do
			 	local v=rnd(2)+1
			 	local a=rnd(0.2)
			 	local tol=rnd(0.2)+0.1
			 	local tx=(zb.flrsp%16)*8+rnd(8)
			 	local ty=flr(zb.flrsp/16)*8+rnd(8)
			 	local tc=sget(tx,ty)
			 	--particle(tc,zb.x+4-4*sgn(zb.vx),zb.y+7,-cos(a)*v*sgn(zb.vx),sin(a)*v,tol,0.9,0.5)
			 	particle(tc,zb.x+4,zb.y+7,0,sin(a)*v,tol,0.9,0.5)
			 end
		 end
			end
		else
			zb.sp=218
		end
		
		if (zb.y>130) del(entities,zb)
	end
	function zb:draw()
		pal(5,0)
		if (zb.hit) then
			for i=1,16 do
				pal(i,7)
			end
		end
		if (zb.chasing) pal(9,8)
		spr(zb.sp,zb.x,zb.y,1,1,zb.d<0)
		pal()
	end
	return zb
end



--torch
function torch(x,y)
	local cp=entity(74,x,y,8,8)
	add(cp.type,"torch")
	function cp:update()
		cp.sp+=0.2
		if (ceil(cp.sp)>78) cp.sp-=4
	end
	function cp:draw()
		local ci=(cos(cp.x/2.05+time()/1.5)+cos(cp.y/2.05+time()/5))/2
		circfill(cp.x+3.5,cp.y+3.5,9+ci*3,13)
		circfill(cp.x+3.5,cp.y+3.5,7+ci*4,6)
		for i=0,2 do
			for j=0,2 do
				spr(94,cp.x-8+i*8,cp.y-8+j*8)
			end
		end
		spr(cp.sp,cp.x,cp.y)
	end
	return cp
end


--particle
function particle(c,x,y,vx,vy,ld,ff,g)
	local p=movent(c,x,y,1,1)
		p.vx=vx
		p.vy=vy
		p.sts=time()	--spawn timestamp
		p.ld=ld	--life duration
		p.ff=ff	--friction
		p.g=g or p.g
		function p:update()
			p.vy+=p.g
			p.vx*=p.ff
			p.vy*=p.ff
			p.x+=p.vx
			p.y+=p.vy
			
			if (time()-p.sts>p.ld) del(entities,p)
		end
		function p:draw()
			pset(p.x,p.y,p.sp)
		end
	return p
end

function bsplash(x,y,nb)	--blood splash
	for i=0,nb do
		local v=rnd(3)+1
		local a=rnd(0.5)
		local tol=rnd(0.2)+0.1
		particle(8,x+4,y+7,0,sin(a)*v,tol,0.9,0.5)
	end
end

--snow area
function snow_area(x,y,w,h,nb,follow)
	local sa={}
	sa.x=x
	sa.y=y
	sa.w=w
	sa.h=h
	sa.flks={}	--flakes
	sa.vx=-0.4
	sa.vy=1
	sa.follow=follow
	add(sa.type,'snow_area')
	
	for i=1,nb do
		local fx=x+rnd(w)
		local fy=y+rnd(h)
		add(sa.flks,{x=fx,y=fy})
	end
	function sa:update()
		if (sa.follow) sa.x=cam.x-cam.cx
	
		for flk in all(sa.flks) do
			flk.x+=sa.vx
			flk.y+=sa.vy
			if (flk.x<sa.x) flk.x+=sa.w
			if (flk.x>sa.x+sa.w) flk.x-=sa.w
			if (flk.y<sa.y) flk.y+=sa.h
			if (flk.y>sa.y+sa.h) flk.y-=sa.h
		end
	end
	function sa:draw()
		for f in all(sa.flks) do
			pset(f.x+cos(time()+f.y)*2,f.y,7)
		end
	end
	return sa
end

--sign post
function postsign(x,y,msg)
	local ps=entity(0,x,y,16,16)
	ps.msg=msg	--lines of message: {'line 1', 'line 2'...}
	ps.show=false
	add(ps.type,'postsign')
	function ps:update()
		ps.show=false
		for e in all(entities) do
			if (e:is('player') and e:collide(ps)) then
				ps.show=true
				break
			end
		end
	end
	function ps:draw()
		if (not ps.show) return
		local margin=3
		local h=#ps.msg*6+flr(margin*1.5)
		local w=0
		for line in all(ps.msg) do
			w=max(w,print(line,0,128))
		end
		w+=flr(1.5*margin)
		local x=ps.x+8-w/2
		local y=ps.y-h
		rectfill(x,y,x+w-1,y+h-1,1)
		rectfill(x+1,y+1,x+w,y+h,1)
		for i,line in pairs(ps.msg) do
			print(line,x+margin,y+margin+(i-1)*6,7)
		end
	end
	return ps
end