-- AMAZONIA DEFORESTATION MODELS
-- (C) 2010 INPE AND UFOP

TME_PATH_1_1_2 = os.getenv("TME_PATH_1_1_2");

-- DBMS Type
-- 0 : mysql
-- 1 : msaccess
if(not dbms) then
	print("-- DBMS Type")
	print("-- 0 : mysql")
	print("-- 1 : msaccess")
	print("Please, enter database type: ")
  	dbms = tonumber(io.read())
end

if (not pwd) then 
  print("Please, enter database password: ")
  pwd=io.read()
end

-- access database properties
DB_VERSION = "4_2_0"
DB_HOME = TME_PATH_1_1_2 .. "\\database"
DB_ACCESS = DB_HOME .."\\amazonia_".. DB_VERSION .. ".mdb"

-- CONSTANTS (MODEL PARAMETERS)
CELL_AREA = 10000
FINAL_TIME = 10
ALLOCATION = 30000 -- yearly demand
LIMIT = 30 -- max deforestation not allocated in each year

TERRAME_PATH = TME_PATH_1_1_2
INPUT_PATH = TERRAME_PATH.."\\database\\"

deforLeg = Legend(
	{
		type = "number",
		groupingMode = "equalsteps",
		slices = 50,
		precision = 5,
		stdDeviation = "none",
		maximum = 1,
		minimum = 0,
		colorBar = {
			{color = "green", value = 0},
			{color = "red", value = 1},
		},
		stdColorBar = {}
	}
);	

-- GLOBAL VARIABLES
csQ = nil
if(dbms == 0) then
	csQ = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "amazonia",
		user = "root",
		password = pwd,
		theme = "dinamica",
		select= {"defor", "dist_urban_areas", "conn_markets_inv_p", "prot_all2"}
	}
else
	csQ = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "dinamica",
		select= {"defor", "dist_urban_areas", "conn_markets_inv_p", "prot_all2"}			
	}		
end
-- RULES
csQ:load()
createMooreNeighborhood(csQ)

-- Create a Observer Map
obs = Observer{ subject = csQ, type = "map", attributes={"defor"},legends= {deforLeg} }
csQ:notify()

calculatePotNeighborhood = function(cs)
	local total_pot = 0

	forEachCell(cs, function(cell)
		cell.pot = 0
		local countNeigh = 0

		if cell.defor < 1.0 then
			forEachNeighbor(cell, function(cell, neigh)
				-- The potential of change for each cell is
				-- the average of neighbors� deforestation.
				-- fully deforested cells have zero potential
				cell.pot = cell.pot + neigh.defor
				countNeigh = countNeigh + 1
			end)
			if cell.pot > 0 then
				-- increment the total potential
				cell.pot = cell.pot / countNeigh
				total_pot = total_pot + cell.pot
			end
		end
	end)
	return total_pot
end

calculatePotRegression = function(cs)
	local total_pot = 0

	-- The potential for change is the residue of a
	-- linear regression between the cell�s
	-- current and expected deforestation
	-- according to the following model:
	forEachCell(cs, function(cell)
		cell.pot = 0

		if cell.defor < 1.0 then
			expected =  - 0.450 * math.log10 (cell.dist_urban_areas)
						+ 0.260 * cell.conn_markets_inv_p
						- 0.140 * cell.prot_all2
						+ 2.313

			if expected > cell.defor then
				cell.pot = expected - cell.defor
				total_pot = total_pot + cell.pot
			end
		end
	end)
	return total_pot
end

calculatePotMixed = function(cs)
	local total_pot = 0

	forEachCell(cs, function(cell)
		cell.pot = 0
		cell.ave_neigh = 0

		-- Calculate the average deforestation
		countNeigh = 0
		forEachNeighbor(cell, function(cell, neigh)
			-- The potential of change for each cell is
			-- the average of neighbors� deforestation.
			if cell.defor < 1.0 then
				cell.ave_neigh = cell.ave_neigh + neigh.defor
				countNeigh = countNeigh + 1
			end
		end)
	
		-- find the average deforestation
		if cell.defor < 1.0 then
			cell.ave_neigh = cell.ave_neigh / countNeigh
		end

		-- Potential for change
		if cell.defor < 1.0 then
			expected =    0.7300 * cell.ave_neigh
						- 0.1500 * math.log10(cell.dist_urban_areas)
						+ 0.0500 * cell.conn_markets_inv_p
						- 0.0700 * cell.prot_all2
						+ 0.7734

			if expected > cell.defor then
				cell.pot = expected - cell.defor
				total_pot = total_pot + cell.pot
			end
		end
	end)
	return total_pot
end

deforest = function(cs, total_pot)
	-- ajust the demand for each cell so that
	-- the maximum demand for change is 100%
	-- adjust the demand so that excess demand is
	-- allocated to the remaining cells
	-- there is an error limit (30 km2 or 0.1%)
	local total_demand = ALLOCATION
	while (total_demand > LIMIT ) do
		forEachCell(cs, function(cell)
			newarea = (cell.pot / total_pot)* total_demand
			cell.defor = cell.defor + newarea/CELL_AREA
			if cell.defor >= 1 then
				total_pot = total_pot - cell.pot
				cell.pot = 0
				excess = (cell.defor - 1) * CELL_AREA
				cell.defor = 1
			else
				excess = 0
			end
			-- adjust the total demand
			total_demand = total_demand - (newarea - excess)
		end)
	end
end

calculatePot = {calculatePotNeighborhood, calculatePotRegression, calculatePotMixed}
currentPot = calculatePot[1]

hasPotential = function(cell1)
	return cell1.pot > 0
end

greaterPotential = function(cell1, cell2)
	return cell1.pot > cell2.pot
end

t = Timer{
	Event{ action = function(event)
		print("1 Time:", event:getTime()) io.flush()
		local total_pot = currentPot(csQ)
		print("2 Time:", event:getTime()) io.flush()

		csQ:notify()
		
		print("3 Time:", event:getTime()) io.flush()
		t = Trajectory{ target = csQ, select = hasPotential, sort = greaterPotential}
		print("4 Time:", event:getTime()) io.flush()
		deforest(t, total_pot)
		print("5 Time:", event:getTime()) io.flush()
	end}
}

t:execute(FINAL_TIME -1)

print("READY")
io.flush()
