-- FIRE SPREAD MODELS
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
DB_ACCESS = DB_HOME .."\\db_teoria_".. DB_VERSION .. ".mdb"


-- Automaton states
INACTIVE 	= 0
BURNING 	= 1
BURNED  	= 2

-- Model parameters
STEPS 		= 30 			-- number of simulation timesteps
I		    = 0.35  			-- fire propagation probability (0.1; 0.2; 0.25; 0.3; 0.4; 0.5)

-- Create a legend for Observer Map
stateLeg = Legend(
	{
		type = "number",
		groupingMode = "uniquevalue",
		slices = 3,
		precision = 5,
		stdDeviation = "none",
		maximum = BURNED,
		minimum = INACTIVE,
		colorBar = {
			{
				color = "green", 
				value = 0
			},
			{
				color = "red",
				value = 1
			},
			{
				color = "black",
				value = 2
			}
		},
		stdColorBar = {}
	}
);	


-- Define and load a TerraLib geographical database
if(dbms == 0) then
	cs = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "db_teoria",
		user = "root",
		password = pwd,
		theme = "cells",
		select = { "Col", "lin", "state" }
	}
else
	cs = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "cells",
		select = { "Col", "lin", "state" }
			
	}		
end
cs:load()

-- Create a Observer Map
obs = Observer{ subject = cs, type = "map", attributes={"state"}, legends= {stateLeg} }
cs:notify()

-- Create a Moore Neighborhood
createMooreNeighborhood(cs)

-------------------------------------------------------------------------------------------
-- Model execution
burned_total = 0
--cs:save(0,"state",{"state"})
for t = 1, STEPS do

	itF = Trajectory{ target = cs, select = function(cell) return cell.state == BURNING end}
	forEachCell(itF, function(cell)
		forEachNeighbor(cell, function(cell,neigh)
			if (neigh ~= cell and neigh.state == INACTIVE) then
				p = math.random()
				if p < I then
					neigh.state = BURNING
				end
			end
		end)
		cell.state = BURNED
		burned_total = burned_total + 1
	end)

	cs:notify()
end
--cs:save(STEPS,"themeName",{"state"})

print("<> The end - burned cells:",burned_total," <>")

print("READY!")
io.flush()
