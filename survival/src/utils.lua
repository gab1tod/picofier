--utils

--distance between two points
function dist(x1, y1, x2, y2)
	x2 = x2 or 0
	y2 = y2 or 0

	return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

--sorting table
function sort(t, comp)
	comp = comp or function(a, b) return a < b end
	for i = 1, #t do
		local j = i
		while j > 1 and comp(t[j], t[j-1]) do
			t[j], t[j-1] = t[j-1], t[j]
			j -= 1
		end
	end
end


--vectorial dot product
function dot(ax, ay, bx, by)
	return ax * bx + ay * by
end

--vectorial projection
function proj(ax, ay, bx, by)
	local k = dot(ax, ay, bx, by) / dot(bx, by, bx, by)
	return k * bx, k * by
end


--is solid
function solid(x, y)
	return fget(mget(x/8, y/8), 0)
end


--delayed actions (promises)
_promises = {}
function resumePromises()
	for p in all(_promises) do
		coresume(p)
		if (costatus(p) == 'dead') del(_promises, p)
	end
end

function promise(callback)
	local p = cocreate(callback)
	add(_promises, p)
	return p
end

function delayed(callback, delay)
	local ts = t()
		
	return promise(function()
		while (t() < ts + delay) do
			yield()
		end

		callback()
	end)
end