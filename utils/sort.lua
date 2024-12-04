--Sort table
function sort(t,comp)
	comp=comp or function(a,b) return a<b end
	for i=1,#t do
		local j=i
		while j>1 and comp(t[j],t[j-1]) do
			t[j],t[j-1]=t[j-1],t[j]
			j-=1
		end
	end
end