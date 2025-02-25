--gun
Gun = Object:new{
	--sprite = nil,
	spx = 0, spy = 0,	--sprite position
	w = 8, h = 4,	--size
	flipX = false,
	fireRate = 0.3,	--delay between two shots
	precision = 0.04,	--angle of precision loss
	bulletSpeed = 8,
	bulletDamage = 11,
	_fireTs = 0,	--last shot timestamp
	_firing = false,
	new = function(_ENV, body)
		local res = class.new(_ENV, body)

		res.sprite = {
			res.spx, res.spy,	--sprite position
			res.w, res.h,	--sprite size
			0, 0,	--display position
			res.w, res.h,	--display size
			false	--flipped x
		}

		return res
	end,
	update = function(_ENV)
		sprite[5] = x
		sprite[6] = y
		sprite[9] = flipX

		if (_firing) sprite[5] += flipX and 1 or -1

		_firing = false

		Object.update(_ENV)
	end,
	draw = function(_ENV)
		sspr(unpack(sprite))
	end,
	fire = function(_ENV, a)
		if (t() - _fireTs < fireRate and not _firing) return

		local precision = rnd(precision) - precision/2
		local bullet = Bullet:new{
			x = cx, y = cy,
			vx = cos(a + precision) * bulletSpeed, vy = sin(a + precision) * bulletSpeed,
			damage = bulletDamage
		}

		add(entities, bullet, 1)
		_firing = true
		_fireTs = t()
	end
}

Revolver = Gun:new{
	spx = 56,
	w = 6,
	precision = 0.01,	--angle of precision loss
	bulletDamage = 12
}

Pistol = Gun:new{	--Colt M 1911
	spx = 56, spy = 4,
	w = 6,
	fireRate = 0.25,	--delay between two shots
	precision = 0.005,	--angle of precision loss
	bulletSpeed = 9
}

Submachinegun = Gun:new{	--Thompson
	spx = 62, spy = 4,
	w = 9,
	fireRate = 0.08,	--delay between two shots
	precision = 0.028,	--angle of precision loss
	bulletDamage = 12
}

AssaultRiffle = Gun:new{	--Kalashnikov Ak 47
	spx = 62,
	w = 11,
	fireRate = 0.11,	--delay between two shots
	bulletSpeed = 11,
	bulletDamage = 30
}

Sniper = Gun:new{
	spx = 73,
	w = 14,
	fireRate = 0.75,	--delay between two shots
	precision = 0.001,	--angle of precision loss
	bulletSpeed = 16,
	bulletDamage = 120
}

Shotgun = Gun:new{
	spx = 71, spy = 4,
	w = 11,
	fireRate = 0.6,	--delay between two shots
	precision = 0.05,	--angle of precision loss
	bulletSpeed = 10,
	bulletDamage = 40,
	fire = function(_ENV, a)
		Gun.fire(_ENV, a)
		Gun.fire(_ENV, a)
		Gun.fire(_ENV, a)
	end
}

Bullpup = Gun:new{
	spx = 87,
	w = 10,  h = 5,
	fireRate = 0.09,	--delay between two shots
	burstRate = 0.4,	--delay between two bursts
	precision = 0.0075,	--angle of precision loss
	bulletSpeed = 11,
	bulletDamage = 34,
	fire = function(_ENV, a)
		if (t() - _fireTs < burstRate and not _firing) return

		Gun.fire(_ENV, a)
		delayed(function() Gun.fire(_ENV, a) end, 0.095)
		delayed(function() Gun.fire(_ENV, a) end, 0.19)
	end
}

Machinegun = Gun:new{
	spx = 97,
	w = 12, h = 5,
	fireRate = 0.12,	--delay between two shots
	precision = 0.028,	--angle of precision loss
	bulletDamage = 64
}



GunItem = Object:new{
	w = 14, h = 10,
	gun = Revolver,
	update = function(_ENV)
		Object.update(_ENV)

		gun.x = cx - gun.w/2 --position x
		gun.y = y + gun.h/2 --position y
		gun:update()

		if (Player.action and Player:collide(_ENV) and not Player.gun:is(gun)) then
			Player.gun = gun:new{x = Player.gun.x, y = Player.gun.y}
			Player.gun:update()
		end
	end,
	draw = function(_ENV)
		pal(15, 4)
		if (Player.gun:is(gun)) for i=1,15 do pal(i, 6) end
		gun:draw()
		pal(0)
	end
}