-- SCHELLING'S SEGREGATION MODEL
-- (C) 2010 INPE AND UFOP

-- PARAMETERS
N = 100  -- cellular space size (NxN)
T = 4    -- agent contentedness index: 3 to 5
V = 0.05 -- vacancy ratio: 0.05 to 0.35 (5% to 35%)

MAX_TURNS = 3000     -- maximum number of simulation steps
OBSERVE_PERIOD = 10  -- save the spatial configuration each OBSERVE_PERIOD steps
TME_PATH_1_1_2 = os.getenv("TME_PATH_1_1_2")
-- MODEL
math.randomseed(os.time())

mWHITE = 0
mRED   = 1
mBLACK = 2

fillCells = function(cs)
	forEachCell(cs, function(cell)
		rvalue = math.random()

		if     rvalue < V         then cell.colour = mWHITE
		elseif rvalue < (1 + V)/2 then cell.colour = mRED 
		else                           cell.colour = mBLACK end
	end)
end

function getRandomCell(cs, colour, condition)
	pos = math.random(cs:size())
	for i = pos, cs:size() do
		cell = cs.cells[i]
		if condition(colour, cell) then return cell end
	end

	for i = 1, pos do
		cell = cs.cells[i]
		if condition(colour, cell) then return cell end	
	end
	return false
end

function isUnhappy(colour, cell)
	if cell.colour ~= colour then return false end

	quantity = 0
	forEachNeighbor(cell, function(cell, neigh)
		if neigh ~= cell and neigh.colour == colour then
			quantity = quantity + 1
		end
	end)
	return quantity < T
end

function isAvailable(colour, cell)
	if cell.colour ~= mWHITE then return false end

	quantity = 0
	forEachNeighbor(cell, function(cell, neigh)
		if neigh.colour == colour then
			quantity = quantity + 1
		end
	end)
	return quantity >= T
end

function schellingTurn(cs, colour)
	oldcell = getRandomCell(cs, colour, isUnhappy);   if not oldcell then return false end
	newcell = getRandomCell(cs, colour, isAvailable); if not newcell then return false end

	t              = oldcell.colour
	oldcell.colour = newcell.colour
	newcell.colour = t
	return true
end

csn = CellularSpace{xdim = N}

createMooreNeighborhood(csn)
fillCells(csn)

leg = Legend{
		-- Attribute: strategy
		type = "number",
		groupingMode = "uniquevalue",
		slices = 3,
		precision = 0,
		stdDeviation = "none",
		maximum = mBLACK,
		minimum = mWHITE,
		colorBar = {
			{color = "white", value = mWHITE},
			{color = "red", value = mRED},
			{color = "black", value = mBLACK}
		}
}

obs = Observer{ subject = csn, type = "map", attributes = {"colour"},legends = { leg} }

t = Timer{
	Event{ action = function(event)
		cr = schellingTurn(csn, mRED) 
		cb = schellingTurn(csn, mBLACK)
		if event:getTime() % OBSERVE_PERIOD == 0 or (not (cr or cb)) then 
			csn:notify() 
		end
		print(event:getTime()) io.flush()
		return cr or cb
	end}
}

t:execute(MAX_TURNS)

print("READY!")
