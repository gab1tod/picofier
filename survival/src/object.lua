--object and entity

Object = class:new{
	x = 0, y = 0,	--position
	z = 0,	--display index
	w = 8, h = 8,	--size
	cx = 4, cy = 4,	--center position
	ex = 8, ey = 8,	--end position
	update = function(_ENV)
		--update end position
		ex = x + w
		ey = y + h

		--update center position
		cx = x + w/2
		cy = y + h/2
	end,
	draw = function(_ENV) end,
	collide = function(_ENV, other)	--collision test
		return ex >= other.x and x <= other.ex and ey >= other.y and y <= other.ey
	end
}


Entity = Object:new{
	vx = 0, vy = 0,	--velocity
	v = 0,	--linear velocity
	speed = 0.45,
	moving = false, flipped = false,
	update = function(_ENV)
		x += vx
		y += vy

		v = dist(vx, vy)
		moving = v > 0.001
		if (abs(vx) > 0.001) flipped = vx < 0

		Object.update(_ENV)	--update end position

		if (moving and _ENV:collideWithWall()) then
			y -= vy
			Object.update(_ENV)
			if (_ENV:collideWithWall()) then
				x -= vx
				Object.update(_ENV)
			end
			y += vy
			Object.update(_ENV)
			if (_ENV:collideWithWall()) then
				y -= vy
				Object.update(_ENV)
			end
		end
	end,
	collideWithWall = function(_ENV)
		return solid(x, y) or solid(ex, y) or solid(x, ey) or solid(ex, ey)
	end
}


entities = {}

function update_entities()
	for e in all(entities) do
		e:update()
	end
	sort(entities, function(a, b)
		if (a.z != b.z) return a.z < b.z
		return a.ey < b.ey
	end)
end

function draw_entities()
	--TODO: optimize

	for e in all(entities) do
		e:draw()
	end
end