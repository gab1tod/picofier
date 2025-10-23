pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--picofier
--purify the land from evil
inbuf=''	--input buffer
version='1.1'

function _init()
	if (cartdata("gabintod_picofier_1")) then
		n_lvl=dget(0)	--number of unlocked level
	else
		init_cartdata()
	end
	
	add(page.stack,credit_screen:new())
	page:current():init()
	--page:push(screen_title:new())
	for i=1,6 do
		if (stat(6)=='level'..i) then
			add(page.stack,screen_title:new())
			page:current():init()
			add(page.stack,main_menu:new())
			page:current():init()
			add(page.stack,level_menu:new({lvl_i=i}))
			page:current():init()
		end
	end
end

function _update()
	--cheat codes
	if (btnp(⬅️)) inbuf..='⬅️'
	if (btnp(➡️)) inbuf..='➡️'
	if (btnp(⬆️)) inbuf..='⬆️'
	if (btnp(⬇️)) inbuf..='⬇️'
	if (btnp(🅾️)) inbuf..='🅾️'
	if (btnp(❎)) inbuf..='❎'
	if (#inbuf>10) inbuf=sub(inbuf,-10)
	if (n_lvl<6 and inbuf=='⬆️⬆️⬇️⬇️⬅️➡️⬅️➡️🅾️❎') then
		--unlock all levels
		n_lvl=6
		sfx(4)
		inbuf=''
	end

	page:update()
end

function _draw()
	page:draw()
end

function init_cartdata()
	n_lvl=1
	dset(0,n_lvl)
	for i=1,6 do
		dset(i*3-2,-1)
		dset(i*3-1,-1)
		dset(i*3,-1)
	end
end
-->8
--class
global=_ENV
class=setmetatable({
	new=function(_,t)
		return setmetatable(t or {},{
		__index=_})
	end
},{
__index=_ENV})

--widget
widget=class:new({
	x=0,
	y=0,
	w=128,
	h=128,
	init_ts=nil,
	init=function(_ENV)
		init_ts = time()
	end,
	update=function(_) end,
	draw=function(_) end,
})

--pages
page=widget:new({
	trans_co=nil,	--transition between pages coroutine
	stack={},	--stack of all pages
	prev=nil,	--previous page (for transitions)
	update=function(_ENV)
		stack[#stack]:update()
	end,
	draw=function(_ENV)
		if (trans_co!=nil and costatus(trans_co)!='dead') then
			coresume(trans_co)
		else
			trans_co=nil
			stack[#stack]:draw()
		end
	end,
	push=function(_ENV,page)
		if (trans_co!=nil) return
		prev=stack[#stack]
		add(stack,page)
		page:init()
		trans_co=cocreate(trans_in)
	end,
	pop=function(_ENV)
		if (#stack<=1 or trans_co!=nil) return
		prev=stack[#stack]
		trans_co=cocreate(trans_out)
		page:init()
		del(stack,stack[#stack])
	end,
	current=function(_ENV)
		return stack[#stack]
	end,
	trans_in=function()
		d=6	--duration
		sfx(0)
		--draw transition
		for i=0,d do
			cls()
			if (page.prev!=nil) page.prev:draw()
			rectfill(0,cos(i/(d*4))*128,128,128,1)
			yield()
		end
		for i=0,d do
			cls(1)
			page:current():draw()
			rectfill(0,0,128,cos(i/(d*4))*128,1)
			yield()
		end
		yield()
	end,
	trans_out=function()
		d=7	--duration
		sfx(1)
		--draw transition
		for i=0,d do
			cls()
			if (page.prev!=nil) page.prev:draw()
			rectfill(0,0,128,-sin(i/(d*4))*128,1)
			yield()
		end
		for i=0,d do
			cls(1)
			page:current():draw()
			rectfill(0,-sin(i/(d*4))*128,128,128,1)
			yield()
		end
		yield()
	end,
})

entity=class:new{
	x=0,y=0,
	w=0,h=0,
	vx=0,vy=0,
	update=function(_ENV)
		x+=vx
		y+=vy
	end,
	draw=function(_)end
}

memt=entity:new{	--map entity
	mx=0,my=0,
	mw=1,mh=1,
	draw=function(_ENV)
		map(mx,my,x,y,mw,mh)
	end
}

function cloud(x,y,vx,s)
	local mapings={
		[0]={32,0,2,1},
		[1]={32,1,5,2},
		[2]={32,3,5,2},
		[3]={32,5,6,3},
	}
	local mpg=mapings[s]
	return memt:new{
		x=x,y=y,vx=vx,
		mx=mpg[1],
		my=mpg[2],
		mw=mpg[3],
		mh=mpg[4],
		w=mpg[3]*8,
		h=mpg[4]*8,
	}
end
-->8
--screen title
screen_title=page:new({
	clouds={},
	init=function(_ENV)
		clouds={}
		for i=0,5 do
			local x=rnd(256)-64
			local y=rnd(32)
			local vx=-rnd(0.5)-0.2
			local s=flr(rnd(4))
			local cld=cloud(x,y,vx,s)
			add(clouds,cld)
		end
		
		page.init(_ENV)
	end,
	update=function(_ENV)
		if (flr((time()-init_ts)*50)==55) sfx(2)
	
		for c in all(clouds) do
			c:update()
			if (c.x<-c.w) then
				del(clouds,c)
				local x=rnd(128)+128
				local y=rnd(32)
				local vx=-rnd(0.5)-0.2
				local s=flr(rnd(4))
				local cld=cloud(x,y,vx,s)
				add(clouds,cld)
			end
		end
		
		if (btnp(🅾️)) page:push(main_menu:new{selec_i=n_lvl>1 and 2 or 1})
	end,
	draw=function(_ENV)
		cls(12)
		
		for c in all(clouds) do
			c:draw()
		end
		
		map(16,0,0,0,128,128)
		map(16,16,0,0,128,128)
		for i=0,21 do
			local y=cos(time()/2+i*0.01)*(21^2-i^2)*0.02
			local h=i*12/21+0.5
			line(20+i,84+y-h/2,20+i,84+y+h/2,8)
			if (i>1) then
				pset(20+i,84+y-h/2+1,7)
				pset(20+i,84+y+h/2-1,7)
			end
		end
		
		local y=(time()-init_ts)<1.75 and -48-cos((time()-init_ts-0.75)/2)*64 or 16+sin(time()/2)*5
		sspr(64,0,6*8,16,16,y+16,96,32)
		local txt="press 🅾️ to start"
		if (flr(time()*1.5)&1==1) print(txt,64-#txt*2,66,7)
	
		print('V'..version,1,122,3)
		txt='GABINTOD'
		print(txt,128-#txt*4,122,3)
	end
})

--credit screen
credit_screen=page:new{
	update = function(_ENV)
		if (time()>2) page:push(screen_title:new())
	end,
	draw = function(_ENV)
		cls(1)
		spr(80,29,56,9,2)
		local txt='presents'
		print(txt,64-#txt*2,71,6)
	end
}
-->8
--level menu
level=class:new({
	name='',
	file='',
	nb_🅾️=-1,
	total_🅾️=-1,
	deathcount=-1,
	perfect=false,	--all coins and no death at the same time
	load_data=function(_ENV,i)
		local d=dget(i*3-2)
		perfect=(d!=-1) and d&0x80!=0 or false
		nb_🅾️=(d!=-1) and d&0x7f or d
		total_🅾️=dget(i*3-1)
		deathcount=dget(i*3)
	end
})

level_menu=page:new({
	clouds={},
	lvl_i=1,
	view_i=1,
	view_v=0.25,
	levels={
		level:new({name='plains in ruin',file="level1"}),
		level:new({name='castle on high',file="level2"}),
		level:new({name='hostile cave',file="level3"}),
		level:new({name='snowy mountain',file="level4"}),
		level:new({name='forest of evil',file="level5"}),
	},
	init=function(_ENV)
		clouds={}
		for i=0,10 do
			local x=rnd(256)-64
			local y=rnd(120)
			local vx=-rnd(0.5)-0.2
			local s=flr(rnd(4))
			local cld=cloud(x,y,vx,s)
			add(clouds,cld)
		end
		for i,lvl in pairs(levels) do
			lvl:load_data(i)
		end
		view_i=lvl_i
	end,
	update=function(_ENV)
		for c in all(clouds) do
			c:update()
			if (c.x<-c.w) then
				del(clouds,c)
				local x=rnd(128)+128
				local y=rnd(120)
				local vx=-rnd(0.5)-0.2
				local s=flr(rnd(4))
				local cld=cloud(x,y,vx,s)
				add(clouds,cld)
			end
		end
		
		if (btnp(❎)) page:pop()
		if (btnp(🅾️) and n_lvl>=lvl_i) then
			load(selection(_ENV).file..'.p8','back to menu')
			load('picofier_'..selection(_ENV).file..'.p8.png','back to menu')
			load('#picofier_'..selection(_ENV).file,'back to menu')
		end
		if (btnp(⬅️) and lvl_i>1) lvl_i-=1 sfx(3,-1,16)
		if (btnp(➡️) and lvl_i<#levels) lvl_i+=1 sfx(3,-1,0,16)
		view_i+=(lvl_i-view_i)*view_v
	end,
	draw=function(_ENV)
		cls(12)
		for c in all(clouds) do
			c:draw()
		end
		
		local txt='\^wlevels'
		print(txt,64-#txt*3+1,16,1)
		print(txt,64-#txt*3+1,15,1)
		print(txt,64-#txt*3,16,1)
		print(txt,64-#txt*3-1,14,1)
		print(txt,64-#txt*3-1,15,1)
		print(txt,64-#txt*3,14,1)
		print(txt,64-#txt*3,15,7)
		
		local x=cos(time())*2.5
		if (lvl_i>1) spr(138,5+x,64)
		if (lvl_i<#levels) spr(138,116-x,64,1,1,true)
		
		local y=4+cos(time()/4)*4
		for i,lvl in pairs(levels) do
			draw_tab((i-1)*128-(view_i-1)*128,y,i,lvl)
		end
		
		txt='❎ BACK'
		print(txt,25,120,5)
		if (not btn(❎)) print(txt,24,120,7)
		
		txt='🅾️ PLAY'
		print(txt,75,120,5)
		if (not btn(🅾️) and lvl_i<=n_lvl) print(txt,74,120,7)
	end,
	selection=function(_ENV)
		return levels[lvl_i]
	end,
	draw_tab=function(x,y,i,lvl)
		map(0,0,x,y,16,16)
		local txt='-LEVEL '..i..'-'
		print(txt,x+64-#txt*2,y+32,1)
		txt=lvl.name
		print(txt,x+64-#txt*2,y+41,13)
		print(txt,x+64-#txt*2,y+40,0)
		
		if (n_lvl<i) then
			spr(172,x+56,y+60,2,2)
			txt='locked'
			print(txt,x+64-#txt*2,y+80,5)
			return
		end
		
		txt=lvl.nb_🅾️>=0 and lvl.nb_🅾️..'/' or '?/'
		txt..=lvl.total_🅾️>=0 and lvl.total_🅾️..'' or '?'
		spr(136,x+64-#txt*2-5,y+54)
		print(txt,x+64-#txt*2+4,y+55,0)
		
		txt=lvl.deathcount>=0 and 'X'..lvl.deathcount or 'X?'
		spr(137,x+64-#txt*2-5,y+63)
		print(txt,x+64-#txt*2+4,y+64,0)
	
		if (not lvl.perfect) then
			for i=1,15 do pal(i,13) end
		end
		spr(143,x+56,y+88,1,2)
		spr(143,x+64,y+88,1,2,true)
		spr(139,x+56,y+80,2,2)
		pal()
		
		if (lvl.nb_🅾️<0 or lvl.nb_🅾️!=lvl.total_🅾️) then
			for i=1,15 do pal(i,13) end
		end
		spr(143,x+36,y+88,1,2)
		spr(143,x+44,y+88,1,2,true)
		spr(141,x+36,y+80,2,2)
		pal()
		
		if (lvl.deathcount!=0) then
			for i=1,15 do pal(i,13) end			
		end
		spr(143,x+76,y+88,1,2)
		spr(143,x+84,y+88,1,2,true)
		spr(174,x+76,y+80,2,2)
		pal()
	end
})
-->8
--main menu
menu_item=class:new({
	name='',
	select=function(_)end,
	enable=function(_) return true end
})

main_menu=page:new({
	clouds={},
	selec_i=1,
	view_i=1,
	view_v=0.5,
	ngts=-10,	--new game confirm timestamp
	ngc=false,	--new game confirm popup
	ngct=2,	--new game confirm time
	items={},
	init=function(_ENV)
		clouds={}
		for i=0,10 do
			local x=rnd(256)-64
			local y=rnd(120)
			local vx=-rnd(0.5)-0.2
			local s=flr(rnd(4))
			local cld=cloud(x,y,vx,s)
			add(clouds,cld)
		end
		view_i=selec_i
		items={
			menu_item:new({
				name='new game',
				select=function(_)
					if (n_lvl>1) then
						_ENV.ngts=time()
						sfx(3,-1,0,16)
					else
						page:push(level_menu:new())
					end
				end,
				}),
			menu_item:new({
				name='continue',
				select=function(_) page:push(level_menu:new()) end,
				enable=function(_) return n_lvl>1 end
			}),
			--menu_item:new({
			--	name='survival',
			--	select=function(_) end,
			--	enable=function(_) return false end
			--}),
		}
	end,
	update=function(_ENV)
		for c in all(clouds) do
			c:update()
			if (c.x<-c.w) then
				del(clouds,c)
				local x=rnd(128)+128
				local y=rnd(120)
				local vx=-rnd(0.5)-0.2
				local s=flr(rnd(4))
				local cld=cloud(x,y,vx,s)
				add(clouds,cld)
			end
		end
		
		local dt=time()-ngts
		if (dt>ngct+0.25 and ngc) ngc=false sfx(3,-1,16)
		if (dt<ngct+0.25) then
			ngc=true
			if (btnp(❎)) ngts=time()-ngct-0.25
			if (btnp(🅾️)) ngts=time()-ngct-0.25 init_cartdata() page:push(level_menu:new())
			return
		end
		if (btnp(❎)) page:pop()
		if (btnp(🅾️) and selection(_ENV):enable()) selection(_ENV):select()
		if (btnp(⬆️)) then
			selec_i-=1
			sfx(3,-1,16)
			if (selec_i<1) selec_i=#items
			while (not items[selec_i]:enable()) do
				selec_i-=1
				if (selec_i<1) selec_i=#items
			end
		end
		if (btnp(⬇️)) then
			selec_i+=1
			sfx(3,-1,0,16)
			if (selec_i>#items) selec_i=1
			while (not items[selec_i]:enable()) do
				selec_i+=1
				if (selec_i>#items) selec_i=1
			end
		end
		view_i+=(selec_i-view_i)*view_v
	end,
	draw=function(_ENV)
		cls(12)
		for c in all(clouds) do
			c:draw()
		end
		
		local txt='\^wmain menu'
		print(txt,64-#txt*3+1,16,1)
		print(txt,64-#txt*3+1,15,1)
		print(txt,64-#txt*3,16,1)
		print(txt,64-#txt*3-1,14,1)
		print(txt,64-#txt*3-1,15,1)
		print(txt,64-#txt*3,14,1)
		print(txt,64-#txt*3,15,7)
		
		fillp(░)
		circfill(64,66,42,13)
		fillp(▒)
		circfill(64,66,36,13)
		fillp()
		circfill(64,66,30,13)
		
		local x=cos(time()/1.2)*2
		
		rectfill(32-x,56-#items*8+view_i*16-4-x,128-33+x,56-#items*8+view_i*16+8+x,1)
		rectfill(32-x+1,56-#items*8+view_i*16-3-x,128-32+x,56-#items*8+view_i*16+9+x,1)
		
		for i,item in pairs(items) do
			txt=item.name
			print(txt,64-#txt*2,56-#items*8+i*16+1,1)
			if (item:enable()) print(txt,64-#txt*2,56-#items*8+i*16,7)
		end
		
		txt='❎ BACK'
		print(txt,25,120,5)
		if (not btn(❎)) print(txt,24,120,7)
		
		txt='🅾️ SELECT'
		print(txt,75,120,5)
		if (not btn(🅾️) and selection(_ENV):enable()) print(txt,74,120,7)
	
		local dt=time()-ngts
		if (dt<ngct+0.5) then
			local y=(dt<0.25 or dt>ngct+0.25) and 128+sin(dt)*25 or 103
			spr(170,56,y*1.5-70,2,2)
			rectfill(10,y+1,117,y+20,2)
			rectfill(11,y+2,118,y+21,2)
			rectfill(10,y,117,y+19,8)
			rectfill(11,y+1,118,y+20,8)
			txt='erase data ?'
			print(txt,64-#txt*2,y+4,7)
			txt='❎ CANCEL'
			print(txt,20,y+12,2)
			if (not btn(❎)) print(txt,20,y+12,7)
			txt='🅾️ CONFIRM'
			print(txt,72,y+12,2)
			if (not btn(🅾️)) print(txt,72,y+12,7)
		end	
	end,
	selection=function(_ENV)
		return items[selec_i]
	end,
})


confirm_delete=page:new{
	ts=nil,	--timestamp
	dts=nil,	--delete timestamp
	cit=3,	--confirm inhibition time
	init=function(_ENV)
		ts=time()
		dts=nil
	end,
	update=function(_ENV)
		if (btnp(❎) and dts==nil) page:pop()
		if (btnp(🅾️) and dts==nil and time()-ts>cit) init_cartdata() dts=time() sfx(2)
		if (dts!=nil and time()-dts>2) page:pop()
	end,
	draw=function(_ENV)
		cls(8)
		local txt='\^w\^treset data'
		print(txt,64-#txt*3,17,2)
		print(txt,64-#txt*3,16,7)
	
		local x=cos(time()/2)*10
		local y=sin(time())*4
		spr(170,56+x,38+y,2,2)
		
		print('\^rrwarning! reseting your cart data will wipe out\nthe persistant memory. any progress will be \nlost forever',16,68,7)
		
		txt='❎ BACK'
		print(txt,25,120,2)
		if (not btn(❎) and dts==nil) print(txt,24,120,7)
		txt='🅾️ CONFIRM'
		local dt=time()-ts
		if (not btn(🅾️) and dt>cit and dts==nil) print(txt,75,120,2) print(txt,74,120,7)
		if (dt<=cit) print((cit+1)-ceil(dt),95,120,7)
	
		if (dts!=nil) then
			rectfill(0,56,128,76,0)
			txt='\^wdeleted'
			print(txt,64-#txt*3,65,5)
			print(txt,64-#txt*3,64,7)
		end
	end,
}
__gfx__
0000000000000666ddd000006666666666666ddd6666666666666ddd666666660000000000000000000000000000000000000000000000000000000000000000
000000000006666666ddd0006666666666666ddd666666d666666ddd666666660000000000000000000000000000000000000000000000000000000000000000
0070070000666666666ddd006666666666666ddd66666d6666666ddd66666d660000000000000000000000000000000000000000000000000000000000000000
00077000066666666666ddd06666666666666ddd66ddd666d6666ddd666dd66600011111000000000000000000000000000000000000000000b3bbbbbbbbbbbb
00077000066666666666ddd06666666666666ddddd66d6666dd66ddd66d666660001777710000000000000000000000000000000000000003b3bbbbbbbbbbbbb
007007006666666666666ddd6666666666666ddd66666d66666ddddd6666666600017667611111001110011111111111111111111110000033b3bbbbbbbbbbbb
000000006666666666666ddd6666666666666ddd6666666666d66ddd666666660001761761777711776117761777617776177761777100003b3bbbbbbbbbbbbb
000000006666666666666ddd6666666666666ddd6666666666666ddd6666666600017617617766176661776617666177661766617666100033b3bbbbbbbbbbbb
bbbbbbbb3bbbbbbbbbbbbbb33bbbbbb3ddddddddddddd6d6d6d6d6d6d6d6d6d60001777761176117611176161761111761176111761610000000000000000000
3b3bbb3b633bbb3b3b3bbb36633bbb36dddddddddddddd6d6d6d6d6d6d6d6d6d0001766611176117611171761766111761176611777610000000000000000000
633b3363663b3363633b3366663b3366ddddddddddddddd6d6d6d6d6d6d6d6dd0001761111777617776177761761117776176111766110000000000000000000
66636666666366666663666666636666dddddddddddddd6d6d6d6d6d6d6d6ddd0001661111666611666166611661116666166661661610000000000000000000
66666666666666666666666666666666ddddddddddddddd6d6d6d6d6d6d6dddd0000111100111111111111111111111111111111111110000000000000000003
66666666666666666666666666666666dddddddddddddddd6d6d6d6d6d6ddddd0000011100011110111111111110111111111111111000000000000000003333
66666666666666666666666666666666ddddddddddddddddd6d6d6d6d6dddddd0000000000000000000000000000000000000000000000000000000003333333
66666666666666666666666666666666dddddddddddddddd6d6d6d6d6ddddddd0000000000000000000000000000000000000000000000000000003333333333
ddddd6d6d6d6d6d6d6d6d6d600000000d0000000d0000000bbbbbbbb3bbbbbbb23333bbb33333bbb222233332222222222222233222222220003333333333333
dddddd6ddd6d6d6ddd6d6d6d0000000ddd0000006d000000bbbbbbbbb3bbbbbb2333b3bb3333b3bb222233332222222222222223b22222220333333333333333
ddddddddddd6d6ddddd6d6d6000000ddddd00000d6d00000bbbbbbbb3b3bbbbb22333b3b33333b3b222233332222222222222223bb2222223333333333333333
dddddddddddd6ddddddd6d6d00000ddddd6d00006d6d0000bbbbbbbb33b3bbbb223333b3333333b3222223332222222222222223bbb222223333333333333333
ddddddddddd6ddddddd6d6d60000ddddddd6d000d6d6d000bbbbbbbb333bbbbb2233333b3333333b222223332222222222222222bbbb22223333333333332222
dddddddddddddddddddd6d6d000ddddddddd6d006d6d6d00bbbbbbbb33b3bbbb222333b3333333b3222223332222222222222222bbbbb2223333332222222222
ddddddddddddddddddddd6d600ddddddddddd6d0d6d6d6d0bbbbbbbb333b3bbb2223333b3333333b222222332222222222222222bbbbbb222222222222222222
dddddddddddddddddddd6d6d0ddddddddddd6d6d6d6d6d6dbbbbbbbb3333b3bb2223333333333333222222332222222222222222bbbbbbb22222222222222222
0000000000000000b3b33333bbbbbbbbbbbbbbbbbbbbbbbb424222224242222222222222222222224444444424244444bbbbbbbb444444443b3bbbbb24244444
0000000000000000bb3b3222bbbbbbbbbbbbbbbbbbb3333344242222442422bb22222222222222bb44444444b2424444bbbbbbbb4444444433b3bbbb22424444
0000000000000000b3b22222bbbbbbbbbbbbbb3333333333424222224242bbbb222222222222bbbb44444444bbb44444bbbbbbbb444444443b3bbbbb24244444
000000000000000044242222bbbbbbbbb3333333333333334424222244bbbbbb2222222222bbbbbbbbbbbbbbbbbbbbbb44444444444444443342444422424444
000000000000000042422222b3b33333333333333333322242422222bbbbbbbb22222222bbbbbbbbbbbbbbbbbbbbbbbb44444444444444442424444424244444
bb0000000000000044242222bb3b3333333333333322222244242222bbbbbbbb222222bbbbbbbbbbbbbbbbbbbbbbbbbb44444444444444442242444422424444
bbbbbbbb0000000042422222b3b33333333333322222222242422222bbbbbbbb2222bbbbbbbbbbbbbbbbbbbbbbbbbbbb44444444444444442424444424244444
bbbbbbbbbbbbbbb044242222bb3b3333333322222222222244242222bbbbbbbb22bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb44444444444444442242444422424444
00000000000000777770000000000777777700007777777777777777bb2244bbbb2244bb002244000000000033333bbbbbbbbbbb000000000000000000000000
00000000000077777777700000077777777777007777777777777777bb2244bbbb2244bb00224400000000003333bbbbbbbbbbb3000000000000000000000000
00000000000777777777770007777777777777707777777777777777bb2244bbbb2244bb00224400000000003333bbbbbbbbbbb3000000000000000000000000
00000000007777777777770077777777777777707777777777777777bb2244bbbb2244bb0022440000000000333bbbbbbbbbbb33000000000000000000000000
bbbb0000007777777777777077777777777777777777777777777777bb2244bbbb2244bb00224400000ff000333bbbbbbbbbbb33000000000000000000000000
bbbbbbbb077777777777777067777777777777767777777777777777b33243bbbb2244bb0022440000ffff0033bbbbbbbbbbb333000000000000000000000000
bbbbbbbb077777777777777766676767676767667777777767676767b33333bbbb2244bb00224400002ff40033bbbbbbbbbbb333000000000000000000000000
bbbbbbbb77777777777777770666666666666660777777776666666633333bbbbb2244bb00224400002244003bbbbbbbbbbb3333000000000000000000000000
00777777777777777077777777777777077777770077777777777777777777770000000000000000000000000000000000000000000000000000000000000000
07000000000000000700000000000000700000007700000000000000000000007000000000000000000000000000000000000000000000000000000000000000
70777777007777770007777700777770007777700007777700777777007777700700000000000000000000000000000000000000000000000000000000000000
70777777b0773333b0773333b07733770077337b00773377b0777777b077337b0070000000000000000000000000000000000000000000000000000000000000
70773377b07777333077b77730777777b07777770077b377b0773377b07777770070300000000000000000000000000000000000000000000000000000000000
7077b377b07733b00077b377b0773377b0773377b077bb77b077b377b0773377b070300000000000000000000000000000000000000000000000000000000000
7077b077b037777700777777b077b377b0777777b0777773b077b077b0777777b070300000000000000000000000000000000000000000000000000000000000
7033b033b0033333b0333333b033b033b0333333b03333333033b033b0333333b070300000000000000000000000000000000000000000000000000000000000
70033003300033333003333330033003300333333003333300033003300333333070300000000000000000000000000000000000000000000000000000000000
07000000007000000000000000000000000000000000000007000000000000000700300000000000000000000000000000000000000000000000000000000000
00777777770777777777777777777777777777777777777770777777777777777003000000000000000000000000000000000000000000000000000000000000
00000000000300000000000000000000000000000000000000300000000000000030000000000000000000000000000000000000000000000000000000000000
00033333333033333333333333333333333333333333333333033333333333333300000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000bbbbbb0000000000aaaaaa0000000087888
000000000000000000000000000000000000000000000000000000000000000000aaa90000ddd50000011710000bbbb7777bb000000aaaa7777aa00000087888
00000000000000000000000000000000000000000000000000000000000000000aa77a900dd7dd5000177710003bbbbbbb777b00009aaaa99a777a0000087888
00000000000000000000000000000000000000000000000000000000000000000aaa7a900d777d500177771003bbbbbbbbbb77b009aaa999999a77a000087888
00000000000000000000000000000000000000000000000000000000000000000aaaaa900dd7dd500117771003bbbbbbbbbbb7b009aa99999999a7a000087888
00000000000000000000000000000000000000000000000000000000000000000aaaaa900dd7dd50001117103bbbbbbbbbb3377b9aaa99a99a99a77a00087888
000000000000000000000000000000000000000000000000000000000000000000aaa9000ddddd50000111103bbbbbbbbb333b7b9aaa99a99aaaaa7a00087888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001103bb33bbbb333bb7b9aaa9999999aaa7a00087888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bb333bb333bbb7b9aaaa9999999aa7a00087888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbb333333bbbb7b9aaaaaa99a99aa7a00087887
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbb3333bbbbbbb9aaa99a99a99aaaa00087878
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbb33bbbbbbb009aa99999999aaa000087788
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbbbbbbb009aaa999999aaaa000087880
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbbbb300009aaaa99aaaa90000088800
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033bbbbbb3300000099aaaaaa9900000088000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333300000000009999990000000080000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555ddd0000000000dddddd00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000000005511115d0000000dddd7777dd000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888000000000555000015d000001ddddddd777d00
000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888800000000550000001d00001dddddddddd77d0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000088228800000000150000001500001ddd111111dd7d0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000088277288000000015000000150001ddd11111111d77d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000888777788800000015000000150001dd1111111111d7d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000888777788800000011000000150001dd11dd11dd11d7d
000000000000000000000000000000000000000000000000000000000000000000000000000000000088887777888800005555555ddddd001dd11dd11dd11d7d
0000000000000000000000000000000000000000000000000000000000000000000000000000000008888887788888800055555d1555dd001dd1111dd1111d7d
000000000000000000000000000000000000000000000000000000000000000000000000000000000888888778888880001555d11155dd001ddd11111111dddd
000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888005155d11155550001ddd111111dddd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000088888882288888880015155d1555550001ddd1d11d1dddd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000088888887788888880011515dd5555500001dddddddddd100
000000000000000000000000000000000000000000000000000000000000000000000000000000002888888888888882001115151555550000011dddddd11000
00000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222000001111111100000000011111100000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777cccccccccccccccccccccccccccccccccccccccccc
777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777cccccccccccccccccccccccccccccccccccccccc
7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777777ccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777777777777ccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777777777777cccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777776cccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6667676767676766cccccccccccccccccccccccccccccccccccccc
7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666ccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77777777ccccccccccccccccccccccccdccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7777777777cccccccccccccccccccccdddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77777777777cccccccccccccccccccdddddccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77777777777ccccccccccccccccccddddd6dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
777777777777ccccccccccccccccddddddd6dccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
777777777776cccccccccccccccddddddddd6dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
676767676766ccccccccccccccddddddddddd6dcccccccccccccccccccccccccccccccccccccccc7777777777777cccccccccccccccccccccccccccccccccccc
66666666666ccccccccccccccddddddddddd6d6dccccccccccccccccccccccccccccccccccccc77777777777777777cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccddddddddddddd6d6dcccccccccccccccdccccccccccccccccccc7777777777777777777ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccddddddddddddddd6d6dcccccccccccccdddccccccccccccccccc77777777777777777777ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccddddddddddddddddd6d6dcccccccccccdddddcccccccccccccccc777777777777777777777cccccccccccccccccccccccccccccccc
cccccccccccccccccccccddddddddddddddddd6d6d6dcccccccccddddd6dcccccccccccccc7777777777777777777777cccccccccccccccccccccccccc777777
ccccccccccccccccccccddddddddddddddddddd6d6d6dcccccccddddddd6dccccccccccccc77777777777777777777777ccccccccccccccccccccccc77777777
cccccccccccccccccccddddddddddddddddddddd6d6d6dcccccddddddddd6dccccccccccc777777777777777777777777ccccccccccccccccccccc7777777777
ccccccccccccccccccddddddddddddddddddddddd6d6d6dcccddddddddddd6dccccccc7777777777777777777777777777777cccccccccccccccc77777777777
cccccccccccccccccddddddddddddddddddddddd6d6d6d6dcddddddddddd6d6dcccc77777777777777777777777777777777777cccccccccccccc77777777777
ccccccccccccccccddddddddddddddddddddddddd6d6d6d6ddddddddddddd6d6dc77777777777777777777777777777777777777ccccccccdcccc67777777777
cccccccccccccccddddddddddddddddddddddddddd6d6d6ddddddddddddddd6d6d77777777777777777777777777777777777777cccccccdddccc66676767676
ccccccccccccccdddddddd1111111111ddddddddddd6d6ddddddddddddddddd6d6d77777777777777777777777777777777777777cccccdddddccc6666666666
cccccccccccccddddddddd1111111111dddddddddddd6ddddddddddddddddd6d6d6d7777777777777777777777777777777777776ccccddddd6dcccccccccccc
ccccccccccccdddddddddd117777777711ddddddddd6ddddddddddddddddddd6d6d6d676767676767676767676767676767676766cccddddddd6dccccccccccc
cccccccccccddddddddddd117777777711dddddddddddddddddddddddddddddd6d6d6d6666666666666666666666666666666666cccddddddddd6dcccccccccc
ccccccccccdddddddddddd1177666677661111111111dddd111111dddd11111111111111111111111111111111111111111111ccccddddddddddd6dccccccccc
cccccccccddddddddddddd1177666677661111111111dddd111111dddd11111111111111111111111111111111111111111111cccddddddddddd6d6dcccccccc
ccccccccdddddddddddddd1177661177661177777777111177776611117777661177777766117777776611777777661177777711ddddddddddddd6d6dccccccc
cccccccddddddddddddddd1177661177661177777777111177776611117777661177777766117777776611777777661177777711dddddddddddddd6d6dcccccc
ccccccdddddddddddddddd117766117766117777666611776666661177776666117766666611777766661177666666117766666611ddddddddddddd6d6dccccc
cccccddddddddddddddddd117766117766117777666611776666661177776666117766666611777766661177666666117766666611dddddddddddd6d6d6dcccc
ccccdddddddddddddddddd117777777766111177661111776611111177661166117766111111117766111177661111117766116611ddddddddddddd6d6d6dccc
cccddddddddddddddddddd117777777766111177661111776611111177661166117766111111117766111177661111117766116611dddddddddddddd6d6d6dcc
ccdddddddddddddddddddd117766666611111177661111776611111177117766117766661111117766111177666611117777776611ddddddddddddddd6d6d6dc
cddddddddddddddddddddd117766666611111177661111776611111177117766117766661111117766111177666611117777776611dddddddddddddd6d6d6d6d
dddddddddddddddddddddd117766111111117777776611777777661177777766117766111111777777661177661111117766661111ddddddddddddddd6d6d6d6
dddddddddddddddddddddd117766111111117777776611777777661177777766117766111111777777661177661111117766661111dddddddddddddddd6d6d6d
dddddddddddddddddddddd116666111111116666666611116666661166666611116666111111666666661166666666116666116611ddddddddddddddddd6d6dd
dddddddddddddddddddddd116666111111116666666611116666661166666611116666111111666666661166666666116666116611dddddddddddddddddd6ddd
dddddddddddddddddddddddd11111111dddd1111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddddd6dddd
dddddddddddddddddddddddd11111111dddd1111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddddddd
dddddddddddddddddddddddddd111111dddddd11111111dd1111111111111111111111dd111111111111111111111111111111dddddddddddddddddddddddddd
dddddddddddddddddddddddddd111111dddddd11111111dd1111111111111111111111dd111111111111111111111111111111dddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd777d777d777dd77dd77dddddd77777dddddd777dd77dddddd77d777d777d777d777ddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd7d7d7d7d7ddd7ddd7ddddddd77ddd77dddddd7dd7d7ddddd7dddd7dd7d7d7d7dd7dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd777d77dd77dd777d777ddddd77d7d77dddddd7dd7d7ddddd777dd7dd777d77ddd7dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd7ddd7d7d7ddddd7ddd7ddddd77ddd77dddddd7dd7d7ddddddd7dd7dd7d7d7d7dd7dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd7ddd7d7d777d77dd77ddddddd77777ddddddd7dd77dddddd77ddd7dd7d7d7d7dd7dddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddb3bbbbbbbbbbbb
dddddddddddddddddddddddddddddddddddddddddddffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd33b3bbbbbbbbbbbbb
ddddddddddddddddddddddddddddddddddddddddd8ffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd333333b3bbbbbbbbbbbb
dddddddddddddddddddddddddddddddddddddddd872ff4ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd33333333b3bbbbbbbbbbbbb
ddddddddddddddddddddddddddddddddddddddd8782244dddddddddddddddddddddddddddddddddddddddddddddddddddddddd333333333333b3bbbbbbbbbbbb
dddddddddddddddddddddddddddddddddddddd87882244ddddddddddddddddddddddddddddddddddddddddddddddddddddd33333333333333b3bbbbbbbbbbbbb
dddddddddddddddddddd8ddddddddddddddd8878882244ddddddddddddddddddddddddddddddddddddddddddddddddddd33333333333333333b3bbbbbbbbbbbb
dddddddddddddddddddd88888ddddddddd887788882244dddddddddddddddddddddddddddddddddddddddddddddddddd33333333333333333b3bbbbbbbbbbbbb
ddddddddddddddddddddd8777888888888778888882244dddddddddddddddddddddddddddddddddddddddddddddddddd33333333333333333342444444444444
bbbbdddddddddddddddddd887777777777888888882244dddddddddddddddddddddddddddddddddddddddddddddddddd33333333333322222424444444444444
bbbbbbbbbbdddddddddddddd8788888888888888882244dddddddddddddddddddddddddddddddddddddddddddddddddd33333322222222222242444444444444
bbbbbbbbbbbbbbbbddddddddd878888888888888882244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222424444444444444
bbbbbbbbbbbbbbbbbbbbbbbddd87788888888888882244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222242444444444444
bbbbbbbbbbbbbbbbbbbbbbbbddd8877888888888882244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222424444444444444
bbbbbbbbbbbbbbbbbbb33333ddddd88778888888772244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222242444444444444
bbbbbbbbbbbbbb3333333333ddddddd887777777882244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222424444444444444
bbbbbbbbb333333333333333ddddddddd8888888dd2244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222242444444444444
b3b333333333333333333222dddddddddddddddddd2244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222424444444444444
bb3b33333333333333222222dddddddddddddddddd2244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222242444444444444
b3b333333333333222222222dddddddddddddddddd2244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222424444444444444
bb3b33333333222222222222dddddddddddddddddd2244dddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222242444444444444
b3b333332222222222222222dddddddddddddddddd2244dddddddddddddddddd3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222222424444444444444
bb3b32222222222222222222dddddddddddddddddd2244ddddddddddddddddddb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2222222222222222242444444444444
b3b222222222222222222222dddddddddddddddddd2244dddddddddddddddddd3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222222222222222424444444444444
442422222222222222222222dddddddddddddddddd2244dddddddddddddddddd33b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222242444444444444
424222222222222222222222dddddddddddddddddd2244dddddddddddddddddd333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2222222222222424444444444444
442422222222222222222222dddddddddddddddddd2244dddddddddddddddddd33b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222222222222242444444444444
424222222222222222222222dddddddddddddddddd2244dddddddddddddddddd333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222424444444444444
442422222222222222222222dddddddddddddddddd2244dddddddddddddddddd3333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2222222222242444444444444
424222222222222222222222bbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb23333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222222222424444444444444
4424222222222222222222bbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb2333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222242444444444444
42422222222222222222bbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb22333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2222222424444444444444
442422222222222222bbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb223333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222222242444444444444
4242222222222222bbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb2233333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222424444444444444
44242222222222bbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb222333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2222242444444444444
424222222222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb2223333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222424444444444444
4424222222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb22233333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22242444444444444
42422222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb222233333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2424444444444444
442422bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb22223333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb242444444444444
4242bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb222233333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4444444444444
44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb2222233333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2244bbbbbbbbbbbbbbbbbb22222333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33243bbbbbbbbbbbbbbbbbb2222233333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbb22222233333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbb222222333333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbb2222223333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbb222222233333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbb2222222333333b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbb22222223333333b3bbbbbbbbbbbbbbbbb33bb33b33bb333b33bb333bb33b33bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbb222222223333333bbbbbbbbbbbbbbbbb3bbb3b3b33bbb3bb3b3bb3bb3b3b3b3b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbb22222222333333b3bbbbbbbbbbbbbbbb3b3b333b3b3bb3bb3b3bb3bb3b3b3b3b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbb222222223333333bbbbbbbbbbbbbbbbb333b3b3b333b333b3b3bb3bb33bb33bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbb2222222233333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

__map__
0000000000000000000000000000000000000000000000000000000000000000434400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000041420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000434646464400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000011112031303031110120302000000000023240000000000000000000000004145420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000000002314152523240000000000000000434646464400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030306000000231414142114152500000000232400000000414200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050303030303030303030304000023141414141414142225232423141525004145454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000014141414141414141517142014141421434646464644000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303070303030304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050303030303030303070304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030304000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030303030303030303030306000014141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000004a0000000000001e1f0e0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000004030310000490000000000002e2f3e3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000003334350000490000000000002b2b3f3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000322b2b0000490000272626262d2b3f3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000363839262648262628262626262d3f3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037262626264726262a27262626263b3a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000262626264c4b26262c29262626262626000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
4b02000018050110500b0500a0500a0500a0500b0500c0500c0500d0500e0500e05010050110501105013050140501605017050180501a0501b0501e0501f0502005023050240502605027050290502b0502e050
4a0200002d0502e0502f05030050300502f0502e0502d0502b0502a0502805026050250502405022050200501f0501d0501c0501b05019050180501705015050140501305012050100500f0500d0500b05009050
a0030000321503215031150301502f1502e1502e1502c1502b1502a1502815027150241502315022150201501e1501c1501b150191501615015150131501115025200252002e2002e2002e2002e2002e2002e200
01023522277501e7501a7501b7501d7501f7502075001700237002770025700217001b7001a70018700187001f7502475028750257501f7501b75019750217001f7001d5001f7001f7001d7001c7001870018700
00100000180501c0501f05023050000001f0502305223052230522305200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 03434344

