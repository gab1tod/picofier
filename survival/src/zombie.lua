--zombie

Zombie = Entity:new{
	w = 4, h = 6, r = 5,	--size (width, height, ray)
	a = 0,	--angle
	sprite = 16,
	hp = 100,	--health points
	_hitTs = 0,	--hit timestamp
	pfMode = false,	--pathfinding mode
	targetPFNode = nil,	--target pathfinding node
	new = function(_ENV, body)
		local res = class.new(_ENV, body)
			res.speed = 0.25 + rnd(0.15)
		return res
	end,
	update = function(_ENV)
		if (hp <= 0) then
			del(entities, _ENV)
			return
		end

		pfMode = not _ENV:inView(Player.cx, Player.cy)

		local dx, dy
		if (pfMode) then
			if (closestPFNode and Player.closestPFNode) then
				printh('find path from '..closestPFNode.name..' to '..Player.closestPFNode.name)
				local journey = closestPFNode:findPath(Player.pclosestPFNode)
				targetPFNode = journey[1]
				for targ in all(journey) do
					local obstructed = not _ENV:inView(targ.x * 8, targ.y * 8)

					printh(targ.name..(obstructed and ' obstructed' or ' visible'))

					if (obstructed) break
					targetPFNode = targ
				end
				printh('')
			end
			if (targetPFNode) then
				dx, dy = targetPFNode.x - tx, targetPFNode.y - ty
			else
				dx, dy = 0, 0
			end
		else
			targetPFNode = nil
			dx, dy = Player.x - x, Player.y - y
		end
		local d = sqrt(dx^2 + dy^2)
		if (d > 0) then
			dx /= d
			dy /= d

			if (dx != 0) flipped = dx < 0
		end
		a = atan2(dx, dy)
		vx = dx * speed
		vy = dy * speed
			

		Entity.update(_ENV)

		for e in all(entities) do
			if (e:is(Zombie) and e!=_ENV) then
				local dx, dy, d = e.cx - cx, e.cy - cy
				d = dist(dx, dy)

				if (d < r and d != 0) then	--too close to another zombie
					dx *= r/d
					dy *= r/d
					x = e.x - dx
					y = e.y - dy
					Object.update(_ENV)
				end
			end
		end

		sprite += 0.125
		if (sprite >= 20) sprite -= 4
	end,
	draw = function(_ENV)
		if (t() - _hitTs < 0.04) for i=1,15 do pal(i, 7) end
		spr(sprite, x - 1, y - 1, 0.75, 1, flipped)
		pal(0)
	end
}


--Spawner
spawners = {}

Spawner = Object:new{
	spawnX = 0, spawnY = 0,	--spawning direction
	new = function(_ENV, body)
		local res = class.new(_ENV, body)

		res.x *= 8
		res.y *= 8
		res.spawnX *= 8
		res.spawnY *= 8

		Object.update(res)

		return res
	end,
}


--Pathfinding node
pfNodes = {}

PFNode = class:new{
	room = '[PFNode room]', index = 0,
	x = 0, y = 0,	--position
	--links = {},
	new = function(_ENV, body)
		local res = class.new(_ENV, body)

		res.name = res.room..'-'..res.index
		res.links = res.links or {}
		add(pfNodes, res)

		return res
	end,
	findPath = function(_ENV, target)
		local Q = {_ENV}
		local explored = {_ENV}
		local parents = {}
		local found = false

		while #Q > 0 do
			local node = deli(Q, 1)

			found = node == target
			if (found) break

			for link in all(node.links) do
				if not isIn(explored, link) then
					add(explored, link)
					parents[link] = node
					add(Q, link)
				end
			end
		end

		--build path
		if (not found) return nil

		local path = {}
		local prec = target
		while prec != _ENV do
			add(path, prec, 1)
			prec = parents[prec]
		end
		add(path, _ENV, 1)

		return path
	end
}