-- RAIN DRAINAGE MODELS
-- (C) 2010 INPE AND UFOP

initialTime = os.time()

-- DBMS Type
-- 0 : mysql
-- 1 : msaccess
print(">> Database type: ")io.flush()
print("\t0 : MySQL")io.flush()
print("\t1 : MSAccess")io.flush()
dbms = tonumber(io.read())

if (dbms == 0) then 
	print(">> MySQL password: ")io.flush()
	pwd=io.read()
end

-- attributes name can differ in differents DBMS's
HEIGHT= "height_"

-- access database properties
                                                           
DB_HOME = TME_PATH .. "\\database"
DB_ACCESS = DB_HOME .."\\cabecaDeBoi_" .. TME_DB_VERSION .. ".mdb"

----------------------------------------------------------------
-- Input and output data paths
OUTPUT_PATH = TME_PATH.."\\results\\rain\\"

----------------------------------------------------------------
-- Model parameters
-- C = rain/t
-- K = infiltration coefficient

--cellSpaceSize = 100; MAX_MIN = {12.5, 0}; C = 2; K = 0.4; FINAL_TIME = 25; ALT_CHUVA = 200; 		-- original
cellSpaceSize = 100; MAX_MIN = {105 , 0}; C = 2  ; K = 0; FINAL_TIME = 60 ; ALT_CHUVA = 200;  		-- original - no infiltration
-- cellSpaceSize = 100; MAX_MIN = {1040, 0}; C = 2 * 2 ; K = 0; FINAL_TIME = 2* 24; ALT_CHUVA = 0; 	-- rains everywhere
ANYWHERE = false
FINAL_TIME = 30


----------------------------------------------------------------
-- PART 1 - Retrieve the cell space from the database
csQ = nil
if(dbms == 0) then
	csQ = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = pwd,
		theme = "cells90x90",
		select = {HEIGHT, "soilWater"}
	}
else
	csQ = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "cells90x90",
		select = {HEIGHT, "soilWater"}
	}
end

csQ:createNeighborhood()
csQ:synchronize()

----------------------------------------------------------------
-- Creates legends and observers

heightLeg = Legend{
	-- Attribute name:  height
	type = "number",
	grouping = "equalsteps",
	slices = 50,
	precision = 5,
	maximum = 255,
	minimum = 0,
	colorBar = {
		{color = "black", value = 0},
		{color = "white", value = 1}
	}
}


soilWaterLeg = Legend{
	type = "number",
	grouping = "equalsteps",
	slices = 100,
	precision = 5,
	maximum = 105,
	minimum = 0,
	colorBar = {
		{color = "white", value = 0},
		{color = {170, 255, 255}, value = 0.242991},
		{color = {0, 170, 255}, value = 0.598131},
		{color = {0, 85, 255}, value = 3.02804},
		{color = "blue", value = 5.45794},
		{color = {0, 0, 127}, value = 10}
	}
}

forEachCell(csQ, function(cell)
	if ((cell.x == 19) and (cell.y == 64) ) then

		textScreenObserver = Observer{ subject = cell, type = "textscreen", attributes={ "soilWater", HEIGHT }}
		logFileObserver = Observer{ subject = cell, type = "logfile",attributes={"soilWater", HEIGHT} }
		tableObserver = Observer{ subject = cell, type = "table",attributes={},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		--udpSenderObserver = Observer{ subject = cell, type = "udpsender", attributes = { "soilWater", HEIGHT} }		
		cell:notify()
	end
end)


obs1 = Observer{
	subject = csQ,
	type = "map",
	attributes = {HEIGHT, "soilWater"},
	legends= {heightLeg, soilWaterLeg}
}

obs2 = Observer{
	subject = csQ,
	type = "image",
	attributes = {HEIGHT, "soilWater"},
	legends= {heightLeg, soilWaterLeg}
}

csQ:notify()

----------------------------------------------------------------
-- Model initializaion
forEachCell(csQ, function(cell)
		cell.soilWater = 0
		cell:notify()
end)

----------------------------------------------------------------
-- Model run	
ini = os.time()
for t = 1, FINAL_TIME do
	-- PART 2: It's raining in the high areas
	forEachCell(csQ,function(cell)
			if ANYWHERE or (cell[HEIGHT] > ALT_CHUVA) then
				cell.soilWater = cell.past.soilWater + C
			end
			cell:notify(t)
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
				if (cell ~= neigh) and (cell[HEIGHT] > neigh[HEIGHT]) then
					neigh.flow = neigh.flow + flow
				end
			end)
		end
	end)
	
	forEachCell(csQ,function(cell)
		cell.soilWater = cell.flow
		cell:notify(t)		
	end)
		
	csQ:synchronize()
	csQ:notify(t)
	
	print("t: ", t ,"\n")	 io.flush()
end
endTime = os.time()

print("Elapsed time:", endTime - initialTime)

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
