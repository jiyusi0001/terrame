-- (C) 2010 INPE AND UFOP
--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=
print("Testing Group...")
--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=

function NewPlayer() -- creates a new agent
	return {money    = 300,
		    strategy = math.random(),
		    balance  = 0}
end

s = Society(NewPlayer, 20)

print("SIZE: "..s:size())

forEachAgent(s, function(a)
	print(a.strategy)
end)

g1 = Group(s,
	function(c)
		if c.strategy > 0.4 then return true end
	end,
	function(a, b)
		return a.strategy > b.strategy
	end
)

g2 = Group(s,
	function(c)
		if c.strategy > 0.7 then return true end
	end
)

print("SIZE: "..g1:size())
print("SIZE: "..g2:size())

forEachAgent(s, function(a)
	a.strategy = math.random()
	print(a.strategy)
end)

g1:rebuild()
g2:rebuild()
print("SIZE: "..g1:size())
print("SIZE: "..g2:size())

print("G 1")
forEachAgent(g1, function(a)
	print(a.strategy)
end)

g1:randomize()
print("RANDOMIZED G 1")
forEachAgent(g1, function(a)
	print(a.strategy)
end)

print("G 2")
forEachAgent(g2, function(a)
	print(a.strategy)
end)


--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=
print("...End of Group")
--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=


print("Please, press <ENTER> to quit...")
io.read()
