--Picfier main class
--version 0.1

function _init()
	poke(0x5F2D, 1)	--enable mouse inputs

	--make color changes
	pal(14, -10, 1)

	Player.x = 252
	Player.y = 348
	add(entities, Player)

	Camera.x = Player.x - 60
	Camera.y = Player.y - 60
	mouseX, mouseY, mouseBtn = stat(32) + Camera.x, stat(33) + Camera.y, stat(34)	--mouse info

	--Gun items
	add(entities, GunItem:new{x = 190, y = 295})
	add(entities, GunItem:new{x = 334, y = 355, gun = Pistol})

	--Pathfinding nodes
	local r1n1 = PFNode:new{room = 'r1', index = 1, x = 32, y = 44}
	local r1n2 = PFNode:new{room = 'r1', index = 2, x = 35, y = 46}
	local r1n3 = PFNode:new{room = 'r1', index = 3, x = 39, y = 44}
	local r1n4 = PFNode:new{room = 'r1', index = 4, x = 38, y = 38}
	local r1n5 = PFNode:new{room = 'r1', index = 5, x = 32, y = 38}
	local r1n6 = PFNode:new{room = 'r1', index = 6, x = 32, y = 32.5}
	local r1n7 = PFNode:new{room = 'r1', index = 7, x = 25, y = 38}
	local r1n8 = PFNode:new{room = 'r1', index = 8, x = 24, y = 44}
	local r1n9 = PFNode:new{room = 'r1', index = 9, x = 27, y = 46}
	add(r1n1.links, r1n2) add(r1n2.links, r1n1)	--Room1 Node1
	add(r1n1.links, r1n3) add(r1n3.links, r1n1)
	add(r1n1.links, r1n5) add(r1n5.links, r1n1)
	add(r1n1.links, r1n8) add(r1n8.links, r1n1)
	add(r1n1.links, r1n9) add(r1n9.links, r1n1)
	add(r1n2.links, r1n3) add(r1n3.links, r1n2)	--Room1 Node2
	add(r1n3.links, r1n4) add(r1n4.links, r1n3)	--Room1 Node3
	add(r1n4.links, r1n5) add(r1n5.links, r1n4)	--Room1 Node4
	add(r1n5.links, r1n6) add(r1n6.links, r1n5)	--Room1 Node5
	add(r1n5.links, r1n7) add(r1n7.links, r1n5)
	add(r1n7.links, r1n8) add(r1n8.links, r1n7)	--Room1 Node7
	add(r1n8.links, r1n9) add(r1n9.links, r1n8)	--Room1 Node8

	--List spawners
	unlockedRooms = {1}
	spawners[1] = {}
	add(spawners[1], Spawner:new{x = 20, y = 43, spawnX = 1})
	add(spawners[1], Spawner:new{x = 20, y = 44, spawnX = 1})
	add(spawners[1], Spawner:new{x = 26, y = 49, spawnY = -1})
	add(spawners[1], Spawner:new{x = 27, y = 49, spawnY = -1})
	add(spawners[1], Spawner:new{x = 34, y = 49, spawnY = -1})
	add(spawners[1], Spawner:new{x = 35, y = 49, spawnY = -1})

	--Log
	printh('\n\n\n')
end

function _update60()
	resumePromises()

	if (btnp(🅾️)) then
		local spawn = spawners[1][flr(rnd(#spawners[1])) + 1]
		add(entities, Zombie:new{x = spawn.x + spawn.spawnX, y = spawn.y + spawn.spawnY})
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

	Camera.x = Player.x - 60
	Camera.y = Player.y - 60
	mouseX, mouseY, mouseBtn = stat(32) + Camera.x, stat(33) + Camera.y, stat(34)	--mouse info
	if (t() - Player.gun._fireTs < 0.017) then
		Camera.x += flr(cos(Player.aimAngle) + 0.5)
		Camera.y += flr(sin(Player.aimAngle) + 0.5)
	end
	Camera:update()
end

function _draw()
	cls(0)

	Camera:draw()

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