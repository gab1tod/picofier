--Picfier main class

function _init()
	poke(0x5F2D, 1)	--enable mouse inputs

	--make color changes
	pal(14, -10, 1)

	GunItem.x = 10
	GunItem.y = 20
	add(entities, GunItem)
	add(entities, GunItem:new{x = 30, gun = Pistol})
	add(entities, GunItem:new{x = 50, gun = Machinegun})
	add(entities, GunItem:new{x = 70, gun = AssaultRiffle})
	add(entities, GunItem:new{x = 90, gun = Sniper})
	add(entities, GunItem:new{x = 110, gun = Shotgun})

	Player.x = 60
	Player.y = 60
	add(entities, Player)
end

function _update60()
	mouseX, mouseY, mouseBtn = stat(32), stat(33), stat(34)	--mouse info

	if (btnp(🅾️)) then
		local a = rnd(1)
		add(entities, Zombie:new{x = 64 - cos(a) * 64, y = 64 - sin(a) * 64})
	end

	--input direction
	local dx, dy = 0, 0
	if (btn(⬅️, 1)) dx -= 1
	if (btn(➡️, 1)) dx += 1
	if (btn(⬆️, 1)) dy -= 1
	if (btn(⬇️, 1)) dy += 1

	if (dx != 0 and dy != 0) then	--normalize input vector
		dx *= 0.7071
		dy *= 0.7071
	end

	Player.running = btn(🅾️, 1)
	Player.firing = (mouseBtn & 1) > 0
	Player.action = (mouseBtn & 2) > 0

	Player.dx = dx
	Player.dy = dy

	Player.aimAngle = atan2(mouseX - Player.cx, mouseY - Player.cy)

	update_entities()
end

function _draw()
	cls(14)
	if (t() - Player.gun._fireTs < 0.001) then
		camera(flr(cos(Player.aimAngle) + 0.5), flr(sin(Player.aimAngle) + 0.5))
	else
		camera()
	end

	draw_entities()

	spr(6, mouseX - 3, mouseY - 3)	--mousr cursor
end