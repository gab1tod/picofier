--layer object
function layo(x,y,m)
	local lo={}
	lo.x=x
	lo.y=y
	lo.m=m or 0	--position multiplier
	function lo:pos()
		local x=lo.x
		local y=lo.y
		
		if (cam!=nil) then
			x+=((cam.x+cam.cx)-lo.x)*lo.m
			y+=((cam.y+cam.cy)-lo.y)*lo.m
		end
		
		return x,y
	end
	function lo:update() end
	function lo:draw()
		--todo
	end
	return lo
end


--map object
function mapo(x,y,mx,my,mw,mh,m)
	local mo=layo(x,y,m)
	mo.mx=mx
	mo.my=my
	mo.mw=mw
	mo.mh=mh
	function mo:draw()
		local ofx,ofy=mo:pos(cam)
		map(mo.mx,mo.my,ofx,ofy,mo.mw,mo.mh)
	end
	return mo
end

function cloud(x,y,tp,v,m)
	local cd=mapo(x,y,0,48,5,3,m)
	cd.v=v
	if (tp==1) then
		cd.my=51
		cd.mh=2
	elseif (tp==2) then
		cd.my=53
		cd.mw=2
		cd.mh=1
	end
	function cd:update()
		cd.x+=cd.v
		if (cd.x<-256) cd.x=128*8
	end
	return cd
end

--mountains
function mountains(x,y,m)
	local mt=mapo(x,y,0,54,16,10,m)
	function mt:draw()
		local ofx,ofy=mt:pos(cam)
		map(mt.mx,mt.my,ofx,ofy,mt.mw,mt.mh)
		map(mt.mx,mt.my,ofx+mt.mw*8,ofy,mt.mw,mt.mh)
	end
	return mt
end

--tree
function tree(x,y,h,c,m)
	local tr=mapo(x,y,5,48,3,5,m)
	tr.c=c or 3	--color
	tr.h=h or 1	--height >0
	function tr:draw()
		--todo:change color
		if (c==2) then
			pal(11,3)
			pal(3,1)
			pal(4,2)
			pal(2,1)
		elseif (c==1) then
			pal(11,1)
			pal(3,1)
			pal(4,1)
			pal(2,1)
		end
		local ofx,ofy=tr:pos(cam)
		ofy=tr.y
		map(tr.mx,tr.my,ofx,ofy,tr.mw,1) --tree top
		for i=1,tr.h do
			map(tr.mx,tr.my+1,ofx,ofy+i*8,tr.mw,1) --tree center
		end
		map(tr.mx,tr.my+2,ofx,ofy+(tr.h+1)*8,tr.mw,4) --tree top
		pal()
	end
	return tr
end


--layer text
function latxt(txt,x,y,c,m,sdws)
	local lt=layo(x,y,m)
	lt.txt=txt	--text
	lt.c=c or 7	--color
	lt.sdws=sdws or {}	--shadows
	function lt:draw()
		local x,y=lt:pos()
		for s in all(sdws) do
			print(lt.txt,x+s.x,y+s.y,s.c or lt.c)
		end
		print(lt.txt,x,y,lt.c)
	end
	function lt:shadow(x,y,c)
		add(sdws,{x=x,y=y,c=c})
	end
	return lt
end