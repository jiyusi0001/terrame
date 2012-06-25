-- (C) 2010 INPE AND UFOP
math.randomseed(os.time())

-- SILENT = true

predator = function()
	ag = {energy = 20, type = "wolf"}
	ag.execute = function(ag)
		ag.energy = ag.energy - 1
		if ag.energy <= 0 then
			ag:leave()
			return 
		end
		local tmpcell = ag:getLocation():getNeighborhood():sample()
		local countsheep = 0
		forEachNeighbor(ag:getLocation(), function(cell, neigh)
			local localcount = 0
			forEachAgent(neigh, function(ag)
				if ag.type == "sheep" then
					localcount = localcount + 1
				end
			end)

			if localcount > countsheep then
				tmpcell = neigh
				countsheep = localcount
			end
		end)

		ag:move(tmpcell)

		forEachAgent(ag:getLocation(), function(other)
			if other.type == "sheep" then
				ag.energy = ag.energy + other:eaten()
				return false
			end
		end)

	end
	ag.duplicate = function(ag, soc, space)
		if ag.energy > 50 then
			newagent = Agent(predator())
			soc:add(newagent)
			ag.energy = math.floor(ag.energy/2 - 10)
			newagent.energy = ag.energy
			newagent:enter(space:sample())
		end
	end
	ag.getIn = function(ag, cs)
		cell = cs:sample()
		ag:enter(cell)
	end
	ag.state = State{ id = "Wolf" }
	return Agent(ag)
end

prey = function()
	ag = {energy = 20, type = "sheep"}
	ag.execute = function(ag)
		ag.energy = ag.energy - 1
		if ag.energy <= 0 then
			ag:leave()
			return
		end

		local neigh = ag:getLocation():getNeighborhood():sample()

		ag:move(neigh)
		if neigh.cover == "pasture" then
			neigh.cover = "soil"
			ag.energy = ag.energy + 20
		end
	end
	ag.getIn = function(ag, cs)
		cell = cs:sample()
		ag:enter(cell)
	end
	ag.duplicate = function(ag, soc, space)
		if ag.energy > 40 then
			newagent = Agent(prey())
			soc:add(newagent)
			ag.energy = math.floor(ag.energy/2)
			newagent.energy = ag.energy
			newagent:enter(space:sample())
		end
	end
	ag.eaten = function(ag)
		if ag.energy > 20 then
			ag.energy = ag.energy - 20
			return 20
		else
			value = ag.energy
			ag.energy = 0
			ag:leave()
			return value
		end
	end
	ag.state = State{ id = "Sheep" }
	return Agent(ag)
end

predators = Society(predator, 3)
preys = Society(prey, 2)

cs = CellularSpace{
	xdim = 100,
	-- xdim = 3,
	cover = "pasture"
}
createMooreNeighborhood(cs, "1", false)

dopasture = function(cell)
	cell.cover = "pasture"
	cell.count = 0
end

forEachCell(cs, dopasture)

function regrowth(cell)
	if cell.cover == "soil" then
		cell.count = cell.count + 1
		if cell.count >= 4 then
			cell.cover = "pasture"
			cell.count = 0
		end
	end
end

forEachAgent(predators, function(ag) ag:getIn(cs) end)
forEachAgent(preys,     function(ag) ag:getIn(cs) end)

function countAgents(cs)
	count = 0
	forEachCell(cs, function(cell)
		forEachAgent(cell, function(ag)
			count = count + 1
		end)
	end)
	return count
end
 
coverLeg = Legend{
		-- Attribute name:  cover
		type = "string", -- NUMBER
		groupingMode = "uniquevalue",		-- ,		-- STDDEVIATION
		slices = 2,
		precision = 5,
		stdDeviation = "none",		-- ,		-- FULL
		maximum = 1,
		minimum = 0,
		colorBar = {
			{color = "green", value = "pasture"},
			{color = "white", value = "soil"}
		}
}

agentsLeg = Legend{
		type = "string",
		groupingMode = "uniquevalue",
		slices = 3,
		precision = 5,
		stdDeviation = "none",
		maximum = 1,
		minimum = 0,
		colorBar = {
			{color = "blue", value = "Sheep"},
			{color = "red", value = "Wolf"}
		}
}

obsCover = Observer{ subject = cs, type = "map", attributes = {"cover"},legends = { coverLeg} }


forEachAgent(predators, function(ag) 
    Observer{subject=ag, type = "map", attributes={"currentState"}, cellspace = cs, observer = obsCover, legends = {agentsLeg}}  
end)
forEachAgent(preys, function(ag) 
    Observer{subject=ag, type = "map", attributes={"currentState"}, cellspace = cs, observer = obsCover, legends = {agentsLeg}}  
end)

function devagar(max)
	d = 0
	while (d <= max) do
		d = d +1
	end
end

t = Timer{
	Event{action = function(event)
		preys:execute()
		predators:execute()
		forEachCell(cs, regrowth)

		forEachAgent(predators,
                    function(ag)
                        --print("============================================================  1  ==")
                        ag:duplicate(predators, cs)
                        -- -- -- print("ag:getLocation()", ag:getLocation())
                        -- -- print("pred - ag:getLocation().x", ag:getLocation().x, "ag:getLocation().y", ag:getLocation().y)
                        -- -- print("pred - ag:getLocation()", ag:getLocation())
                        --print("============================================================  2  ==")
                        ag:notify()
                    end)
		forEachAgent(preys,
                    function(ag)
                        ag:duplicate(preys, cs)
                        -- -- print("preys - ag:getLocation().x", ag:getLocation().x, "ag:getLocation().y", ag:getLocation().y)
                        ag:notify()
                    end)
		print("Time: "..event:getTime(),"-", "#predators:", predators:size(), "#preys:", preys:size())--.." <<===  "..countAgents(cs))
		io.flush()

		forEachCell(cs, function(cell)
			cell.value = "nothing"
			forEachAgent(cell, function(other)
				if other.type == "sheep" and cell.value == "nothing" then
					cell.value = "sheep"
				end
				if other.type == "wolf" then
					cell.value = "wolf"
				end
			end)
		end)

		cs:notify()
		predators = Group(predators, function(ag) return ag.energy > 0 end)
		preys     = Group(preys,     function(ag) return ag.energy > 0 end)
		
		
		print("\n\n---------------")
	end}
}

 cs:notify()
 t:execute(30)
 cs:notify()

 
print("READY")
