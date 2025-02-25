--Picfier main class
--version 0.1

function _init()
	poke(0x5F2D, 1)	--enable mouse inputs

	--make color changes
	pal(14, -10, 1)

	--set spawners black
	for i=32,63 do
		for j=8,15 do
			sset(i, j, 0)
		end
	end

	spawnDelay = 3
	spawnCount = 10
	spawnTs = t() + spawnDelay
	Player.x = 252
	Player.y = 348
	add(entities, Player)

	Camera.x = Player.x - 60
	Camera.y = Player.y - 60
	mouseX, mouseY, mouseBtn = stat(32) + Camera.x, stat(33) + Camera.y, stat(34)	--mouse info

	--Gun items
	add(entities, GunItem:new{x = 190, y = 295})
	add(entities, GunItem:new{x = 334, y = 355, gun = Pistol})
	add(entities, GunItem:new{x = 31*8, y = 40*8, gun = Machinegun})

	--Pathfinding nodes
	--Room 1
	local r1n1 = PFNode:new{room = 'r1', index = 1, x = 32, y = 44}
	local r1n2 = PFNode:new{room = 'r1', index = 2, x = 35, y = 46}
	local r1n3 = PFNode:new{room = 'r1', index = 3, x = 39, y = 44}
	local r1n4 = PFNode:new{room = 'r1', index = 4, x = 38, y = 38}
	local r1n5 = PFNode:new{room = 'r1', index = 5, x = 32, y = 38}
	local r1n6 = PFNode:new{room = 'r1', index = 6, x = 32, y = 32.5}
	local r1n7 = PFNode:new{room = 'r1', index = 7, x = 25, y = 38}
	local r1n8 = PFNode:new{room = 'r1', index = 8, x = 24, y = 44}
	local r1n9 = PFNode:new{room = 'r1', index = 9, x = 27, y = 46}
	add(r1n1.links, r1n2) add(r1n2.links, r1n1)	--Node1
	add(r1n1.links, r1n3) add(r1n3.links, r1n1)
	add(r1n1.links, r1n5) add(r1n5.links, r1n1)
	add(r1n1.links, r1n8) add(r1n8.links, r1n1)
	add(r1n1.links, r1n9) add(r1n9.links, r1n1)
	add(r1n2.links, r1n3) add(r1n3.links, r1n2)	--Node2
	add(r1n3.links, r1n4) add(r1n4.links, r1n3)	--Node3
	add(r1n4.links, r1n5) add(r1n5.links, r1n4)	--Node4
	add(r1n5.links, r1n6) add(r1n6.links, r1n5)	--Node5
	add(r1n5.links, r1n7) add(r1n7.links, r1n5)
	add(r1n7.links, r1n8) add(r1n8.links, r1n7)	--Node7
	add(r1n8.links, r1n9) add(r1n9.links, r1n8)	--Node8

	--Room 2
	local r2n1 = PFNode:new{room = 'r2', index = 1, x = 38, y = 32}
	local r2n2 = PFNode:new{room = 'r2', index = 2, x = 43, y = 31}
	local r2n3 = PFNode:new{room = 'r2', index = 3, x = 47, y = 30}
	local r2n4 = PFNode:new{room = 'r2', index = 4, x = 50, y = 31.7}
	local r2n5 = PFNode:new{room = 'r2', index = 5, x = 45, y = 35}
	local r2n6 = PFNode:new{room = 'r2', index = 6, x = 47, y = 25.5}
	local r2n7 = PFNode:new{room = 'r2', index = 7, x = 42, y = 25}
	add(r2n1.links, r2n2) add(r2n2.links, r2n1)	--Node1
	add(r2n2.links, r2n3) add(r2n3.links, r2n2)	--Node2
	add(r2n2.links, r2n4) add(r2n4.links, r2n2)
	add(r2n2.links, r2n5) add(r2n5.links, r2n2)
	add(r2n3.links, r2n4) add(r2n4.links, r2n3)	--Node3
	add(r2n3.links, r2n5) add(r2n5.links, r2n3)
	add(r2n3.links, r2n6) add(r2n6.links, r2n3)
	add(r2n4.links, r2n5) add(r2n5.links, r2n4)	--Node4
	add(r2n6.links, r2n7) add(r2n7.links, r2n6)	--Node6

	--Room 3
	local r3n1 = PFNode:new{room = 'r3', index = 1, x = 54, y = 31.7}
	local r3n2 = PFNode:new{room = 'r3', index = 2, x = 54.5, y = 35.5}
	local r3n3 = PFNode:new{room = 'r3', index = 3, x = 58.5, y = 34.5}
	local r3n4 = PFNode:new{room = 'r3', index = 4, x = 62.5, y = 35.5}
	local r3n5 = PFNode:new{room = 'r3', index = 5, x = 63, y = 31.7}
	local r3n6 = PFNode:new{room = 'r3', index = 6, x = 62.5, y = 27.5}
	local r3n7 = PFNode:new{room = 'r3', index = 7, x = 54.5, y = 27.5}
	add(r3n1.links, r3n2) add(r3n2.links, r3n1)	--Node1
	add(r3n1.links, r3n7) add(r3n7.links, r3n1)
	add(r3n2.links, r3n3) add(r3n3.links, r3n2)	--Node2
	add(r3n2.links, r3n4) add(r3n4.links, r3n2)
	add(r3n3.links, r3n4) add(r3n4.links, r3n3)	--Node3
	add(r3n4.links, r3n5) add(r3n5.links, r3n4)	--Node4
	add(r3n5.links, r3n6) add(r3n6.links, r3n5)	--Node5
	add(r3n6.links, r3n7) add(r3n7.links, r3n6)	--Node6

	--Across rooms
	add(r1n4.links, r2n1) add(r2n1.links, r1n4)	--Room 1-2
	add(r2n4.links, r3n1) add(r3n1.links, r2n4)	--Room 2-3

	--List spawners
	unlockedRooms = {1, 2, 3}
	spawners[1] = {
		Spawner:new{x = 20, y = 43, spawnX = 1},
		Spawner:new{x = 20, y = 44, spawnX = 1},
		Spawner:new{x = 26, y = 49, spawnY = -1},
		Spawner:new{x = 27, y = 49, spawnY = -1},
		Spawner:new{x = 34, y = 49, spawnY = -1},
		Spawner:new{x = 35, y = 49, spawnY = -1}
	}
	spawners[2] = {
		Spawner:new{x = 44, y = 38, spawnY = -1},
		Spawner:new{x = 45, y = 38, spawnY = -1},
		Spawner:new{x = 41, y = 21, spawnY = 1},
		Spawner:new{x = 42, y = 21, spawnY = 1}
	}
	spawners[3] = {
		Spawner:new{x = 58, y = 31, spawnY = 1},
	}


	--Log
	printh('\n\n\n')
end

function _update60()
	resumePromises()

	if (btnp(🅾️) or (t() >= spawnTs and spawnCount > 0)) then
		local spawn = rnd(spawners[rnd(unlockedRooms)])
		add(entities, Zombie:new{x = spawn.x + spawn.spawnX, y = spawn.y + spawn.spawnY})
		spawnTs += spawnDelay
		spawnCount -= 1
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

	--draw spawners shades
	pal(1, 0, 0)
	for room in all(spawners) do
		for spawn in all(room) do
			if (spawn.spawnX != 0) then
				spr(27, spawn.x + (spawn.spawnX > 0 and -4 or -12), spawn.y, 3, 1, spawn.spawnX < 0)
				spr(27, spawn.x + (spawn.spawnX > 0 and -4 or -12), spawn.y - 6, 3, 1, spawn.spawnX < 0)
			else
				spr(43, spawn.x, spawn.y + (spawn.spawnY > 0 and 0 or -20), 1, 3, false, spawn.spawnY < 0)
			end
		end
	end
	pal(0)

	--draw pathfinding nodes
	--[[for node in all(pfNodes) do
		for link in all(node.links) do
			line(node.x * 8, node.y * 8, link.x * 8, link.y * 8, 7)
		end
		circ(node.x * 8, node.y * 8, 2, node == Player.closestPFNode and 10 or 7)
		print(node.name, node.x * 8 + 3, node.y * 8 + 3, node == Player.closestPFNode and 10 or 7)
	end]]
	
	spr(6, mouseX - 3, mouseY - 3)	--mousr cursor
end