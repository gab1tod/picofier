--Picfier main class
--version 0.1

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
	add(entities, GunItem:new{y = 90, gun = Bullpup})

	local n1, n2, n3, n4, n5	--pathfinding nodes
	n1 = PFNode:new{name = 'n1', x = 14, y = 2.5}
	n2 = PFNode:new{name = 'n2', x = 14, y = 13.5}
	n3 = PFNode:new{name = 'n3', x = 13.5, y = 6.5}
	n4 = PFNode:new{name = 'n4', x = 6, y = 7}
	n5 = PFNode:new{name = 'n5', x = 6, y = 3}
	add(n1.links, n3) add(n3.links, n1)
	add(n2.links, n3) add(n3.links, n2)
	add(n3.links, n4) add(n4.links, n3)
	add(n4.links, n5) add(n5.links, n4)

	Player.x = 60
	Player.y = 60
	add(entities, Player)

	--Log
	printh('\n\n\n')
end

function _update60()
	resumePromises()

	mouseX, mouseY, mouseBtn = stat(32), stat(33), stat(34)	--mouse info

	if (btnp(🅾️)) then
		local zy = rnd(1) > 0.5 and 104 or 16
		add(entities, Zombie:new{x = 120, y = zy})
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
	cls(0)
	if (t() - Player.gun._fireTs < 0.001) then
		camera(flr(cos(Player.aimAngle) + 0.5), flr(sin(Player.aimAngle) + 0.5))
	else
		camera()
	end

	map()

	draw_entities()

	for node in all(pfNodes) do
		for link in all(node.links) do
			line(node.x, node.y, link.x, link.y, 7)
		end
		circ(node.x, node.y, 2, node == Player.closestPFNode and 10 or 7)
		print(node.name, node.x + 3, node.y + 3, node == Player.closestPFNode and 10 or 7)
	end

	spr(6, mouseX - 3, mouseY - 3)	--mousr cursor
end