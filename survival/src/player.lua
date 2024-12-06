--player

Player = Entity:new{
	dx = 0, dy = 0,	--directional input
	running = false,	--run input
	firing = false,	--fire weapon input
	action = false,	--action input
	aimAngle = 0,	--aim input
	w = 4, h = 6,
	sprite = 1,
	runSpeed = 0.95,
	gun = Revolver:new(),
	update = function(_ENV)
		local spd = running and runSpeed or speed
		vx = dx * spd
		vy = dy * spd

		Entity.update(_ENV)

		-- TODO: hit test with map
		if (v > 0) then
			if (vx > 0) then
				if (vy > 0) then	--right down

				elseif (vy < 0) then	--right up

				else 	--right

				end
			else
				if (vy > 0) then	--left down

				elseif (vy < 0) then	--left up

				else 	--left

				end
			end

			Object.update(_ENV)
		end

		if (moving) then
			if (sprite < 2) sprite = 2
			sprite += running and 0.225 or 0.15
			if (sprite >= 6) sprite -= 4
		else
			sprite = 1
		end

		if (not (running and moving)) then
			gun.x = cx + cos(aimAngle) * 4 - gun.w/2 --position x
			gun.y = cy + sin(aimAngle) * 3 - gun.h/2	--position y
			gun.flipX = aimAngle > 0.25 and aimAngle < 0.75	--gun flipped
		else
			gun.x = cx + (flipped and -4 or 4) - gun.w/2 --position x
			gun.y = cy + sin(t() * 3) - gun.h/2 --position y
			gun.flipX = flipped	--gun flipped
		end

		gun:update()

		if (not (running and moving) and firing) gun:fire(aimAngle)	--fire gun
	end,
	draw = function(_ENV)
		spr(sprite, x - 1, y - 1, 0.75, 1, flipped)

		gun:draw()
	end
}