--bullet

Bullet = Entity:new{
	w = 1, h = 1,
	z = -1,
	_travelDist = 0,
	--_maxDist = 0,
	damage = 10,
	speed = 8,
	px = nil, py = nil,	--previous position
	new = function(_ENV, body)
		local res = Entity.new(_ENV, body)

		local hit, x, y, d = raycast(res.x, res.y, res.vx, res.vy, 256)
		res._maxDist = hit and d or 256

		return res
	end,
	update = function(_ENV)
		if (_travelDist >= _maxDist) return del(entities, _ENV)

		px = x
		py = y

		--Entity.update(_ENV)
		v = dist(vx, vy)
		if (_travelDist + v > _maxDist) then
			local deltaV = _maxDist - _travelDist
			vx, vy = vx / v * deltaV, vy / v * deltaV
			v = deltaV
		end
		x += vx
		y += vy
		_travelDist += v

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
			for e in all(hits) do
				e.hp -= damage
				e._hitTs = t()
			end
		end

		Object.update(_ENV)	--update end position
	end,
	draw = function(_ENV)
		if (_travelDist > 0) line(px, py, x, y, 10)
	end
}