-- SPATIAL GAMES
-- (C) 2010 INPE AND UFOP

-- PARAMETERS
N = 69 -- cellular space size (NxN)
TURNS = 300

COOPERATE          = 0
JUST_COOPERATE     = 1
NOT_COOPERATE      = 2
JUST_NOT_COOPERATE = 3

function Game(p1, p2)
	if p1 == COOPERATE     and p2 == COOPERATE     then return {1, 1} end
	if p1 == COOPERATE     and p2 == NOT_COOPERATE then return {0, 1.4} end
	if p1 == NOT_COOPERATE and p2 == COOPERATE     then return {1.4, 0} end
	if p1 == NOT_COOPERATE and p2 == NOT_COOPERATE then return {0, 0} end
end

fillCells = function(cs)
	forEachCell(cs, function(cell)
		cell.strategy = COOPERATE

		if cell.x == 35 and cell.y == 35 then
			cell.strategy = NOT_COOPERATE
		end
	end)
end

function initTurn(cell)
	if cell.strategy == JUST_COOPERATE     then cell.strategy = COOPERATE     end
	if cell.strategy == JUST_NOT_COOPERATE then cell.strategy = NOT_COOPERATE end
	cell.payoff = 0
end

function turn(cell)
	forEachNeighbor(cell, function(cell, neigh)
		g = Game(cell.strategy, neigh.strategy)
		cell.payoff  = cell.payoff  + g[1]
		neigh.payoff = neigh.payoff + g[2]
	end)
end

function chooseBest(cell)
	cell.max_payoff = cell.payoff
	cell.strat_max_payoff = cell.strategy

	forEachNeighbor(cell, function(cell, neigh)
		if neigh.payoff > cell.max_payoff then
			cell.max_payoff = neigh.payoff
			cell.strat_max_payoff = neigh.strategy
		elseif neigh.payoff == cell.max_payoff then
			if neigh.strategy ~= cell.strategy then
				cell.max_payoff = neigh.payoff
				cell.strat_max_payoff = neigh.strategy
			end
		end
	end)
end

function update(cell)
	if cell.max_payoff >= cell.payoff then
		if cell.strat_max_payoff == COOPERATE and cell.strategy ~= COOPERATE then
			cell.strategy = JUST_COOPERATE
		end
		if cell.strat_max_payoff == NOT_COOPERATE and cell.strategy ~= NOT_COOPERATE then
			cell.strategy = JUST_NOT_COOPERATE
		end
	end
end

csn = CellularSpace{
	xdim = N
}

csn:createNeighborhood{strategy = "vonneumann"}

fillCells(csn)

leg = Legend{
	colorBar = {
		{color = "blue", value = COOPERATE},
		{color = "red", value = NOT_COOPERATE},
		{color = "green", value = JUST_COOPERATE},
		{color = "yellow", value = JUST_NOT_COOPERATE}
	}
}

obs = Observer{
	subject = csn,
	attributes = {"strategy"},
	legends = {leg}
}

csn:notify()

t = Timer{
	Event{action = function(event)
		forEachCell(csn, initTurn)
		forEachCell(csn, turn)
		forEachCell(csn, chooseBest)
		forEachCell(csn, update)
		local time = event:getTime()
		print(time)
		io.flush()
		csn:notify()
	end}
}

t:execute(TURNS)

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
