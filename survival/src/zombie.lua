--zombie

Zombie = Entity:new{
	w = 4, h = 6, r = 5,	--size (width, height, ray)
	a = 0,	--angle
	sprite = 16,
	hp = 100,	--health points
	_hitTs = 0,	--hit timestamp
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

		local dx, dy = Player.x - x, Player.y - y
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