-- RAIN DRAINAGE MODELS
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

-- attributes name can differ in differents DBMS's
HEIGHT= "height_"

-- access database properties
DB_VERSION = "4_2_0"
DB_HOME = TME_PATH_1_1_2 .. "\\database"
DB_ACCESS = DB_HOME .."\\cabecaDeBoi_" .. DB_VERSION .. ".mdb"

-- model parameters
C = 2 -- rain/t
K = 0.4 -- flow coefficient
FINAL_TIME = 24

-- PART 1 - Retrieve the cell space from the database
if(dbms == 0) then
	csQ = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = pwd,
		theme = "cells90x90"
	}
else
	csQ = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "cells90x90",
		select = { HEIGHT, "soilWater" }	
	}		
end
csQ:load();

-- RULES
createMooreNeighborhood(csQ)
csQ:synchronize()

forEachCell(csQ, function(cell)
	cell.soilWater = 0
end)

for t = 1, FINAL_TIME, 1 do

	-- PART 2: It's raining in the high areas
	forEachCell(csQ,function(cell)
		if(cell[HEIGHT] > 200) then
			cell.soilWater = cell.past.soilWater + C
		end
	end)
	csQ:synchronize()
	
	-- PART 3: create a temporary variable to store the flow
	forEachCell(csQ, function(cell)
		cell.flow = 0
	end)

	-- Calculate the drainage and the flow
	forEachCell(csQ, function(cell)
		-- PART 4: calculate the drainage
		cell.soilWater = cell.past.soilWater - K*cell.past.soilWater
		-- count the lower neighbors
		countNeigh = 0
		forEachNeighbor(cell, function(cell, neigh)
			if (cell ~= neigh) and (cell[HEIGHT] >= neigh[HEIGHT]) then 
		    	countNeigh = countNeigh + 1
			end
		end)
			
		-- PART 5: calculates the flow to neighbors
		if (countNeigh > 0) then
			flow = cell.soilWater / countNeigh
			-- send the water to neighbors
			forEachNeighbor(cell, function(cell, neigh)
				if (cell ~= neigh) 	and (cell[HEIGHT] > neigh[HEIGHT]) then
					neigh.flow = neigh.flow + flow
				end
			end)
		end
	end) --forEachCell
		
	forEachCell(csQ, function(cell)
		cell.soilWater = cell.flow
	end)
		
	csQ:synchronize()
	
	-- report: soil water
	print("t: "..t ); io.flush();
	if (t == FINAL_TIME) then
		csQ:save( t, "water", {"soilWater"} );
	end
end
print("READY!")
print("Please, press <ENTER> to quit.")
io.flush()
io.read()
