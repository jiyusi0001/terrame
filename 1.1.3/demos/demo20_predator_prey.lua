-- (C) 2010 INPE AND UFOP

PASTURE = 0
SOIL = 1

commonActions = function(ag)
	ag.energy = ag.energy - 1
	local cell = ag:getCell()
	ag:move(ag:getCell():getNeighborhood():sample())
	if ag.energy >= 50 then
		ag.energy = ag.energy/2
		ag:reproduce()
	elseif ag.energy <= 0 then
		ag:die()
	end
end

predator = Agent{
	energy = 40,
	name = "predator",
	execute = function(self)
		forEachAgent(self:getCell(), function(other)
			if other.name == "prey" then
				self.energy = self.energy + other.energy / 2
				other:die()
				return false -- found a prey, stop forEachAgent
-- ULTIMO ERRO: REMOVER OS PROBLEMAS PARA FAZER O IF A SEGUIR FUNCIONAR CORRETAMENTE
			elseif other.name == "predator" and other ~= self and math.random() < 0.1 then
				self.energy = self.energy + other.energy / 2
				other:die()
				return false -- found a prey, stop forEachAgent
			end
		end)
		commonActions(self)
	end
}

prey = Agent{
	energy = 40,
	name = "prey",
	execute = function(self)
		if self:getCell().cover == "pasture" then
			self:getCell().cover = "soil"
			self.energy = self.energy + 5
		end
		commonActions(self)
	end
}

predators = Society{
	instance = predator,
	quantity = 2
}

preys = Society{
	instance = prey,
	quantity = 2
}

cs = CellularSpace{
	xdim = 2
}
cs:createNeighborhood()

env = Environment{
	cs,
	predators,
	preys
}

env:createPlacement{strategy = "random", max = 1}

dopasture = function(cell)
	cell.cover = 0
end

forEachCell(cs, dopasture)

function regrowth(cell)
	if cell.cover == SOIL then
		cell.count = cell.count + 1
		if cell.count >= 4 then
			cell.cover = PASTURE
			cell.count = 0
		end
	end
end

function countAgents(cs)
	count = 0
	forEachCell(cs, function(cell)
		forEachAgent(cell, function(ag)
			count = count + 1
		end)
	end)
	return count
end

timer = Timer{
	Event{action = function(event)
		print("================================")
		print(event:getTime())
		io.flush()
		preys:execute()
		predators:execute()
		forEachCell(cs, regrowth)
	end}
}

timer:execute(40)

print("READY")

