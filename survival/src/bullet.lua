--bullet

Bullet = Entity:new{
	w = 1, h = 1,
	z = -1,
	--_ts = 0,	--timestamp
	damage = 10,
	speed = 8,
	px = nil, py = nil,	--previous position
	new = function(_ENV, body)
		local res = Entity.new(_ENV, body)
		res._ts = t()
		return res
	end,
	update = function(_ENV)
		px = x
		py = y

		--Entity.update(_ENV)
		x += vx
		y += vy
		v = dist(vx, vy)

		local hits = {}
		for e in all(entities) do
			if (e:is(Zombie)) then
				local dx, dy = e.cx - px, e.cy - py
				local ix, iy = proj(dx, dy, vx, vy)
				local k = abs(vx) > abs(vy) and (ix / vx) or (iy / vy)
				if (k >= 0 and k <= 1 and dist(px + ix, py + iy, e.cx, e.cy) < e.r) add(hits, e)
			end
		end

		sort(hits, function(a, b) return dist(a.cx, a.cy, Player.cx, Player.cy) < dist(b.cx, b.cy, Player.cx, Player.cy) end)
		if (#hits > 0) then
			--TODO: hit zombie
			for e in all(hits) do
				e.hp -= damage
				e._hitTs = t()
			end
		end

		Object.update(_ENV)	--update end position

		if (t() - _ts >= 1) del(entities, _ENV)	--destroy bullet after 1 seconds
	end,
	draw = function(_ENV)
		if (t() > _ts) line(px, py, x, y, 10)
	end
}