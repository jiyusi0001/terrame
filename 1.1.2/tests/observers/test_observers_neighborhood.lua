SKIP = true

-- TEST FOR NEIGHBORHOOD OBSERVERS
-- util function
function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end


-- database loading
-- dbms = 1 (Access), 0 (MySQL)
dbms = 0
DB_VERSION = "4_0_0"
HEIGHT = "height_"

cs = nil
if(dbms == 0) then
	cs = CellularSpace{
	dbType = "mysql",
	host = "127.0.0.1",
	database = "cabeca",
	user = "root",
	password = "1d9e9s7h",
	theme = "cells90x90"
	}
else
	cs = CellularSpace{
	dbType = "ADO",
	database = "database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
	theme = "cells90x90"	
	}		
end
cs:load()
createMooreNeighborhood(cs)
cs:synchronize()

heightLeg = Legend{
-- Attribute name:  height
type = "number",
groupingMode = "equalsteps",
slices = 50,
precision = 5,
stdDeviation = "none",
maximum = 255,
minimum = 0,
colorBar = {
{"black", 0},
{"white", 1}
},
stdColorBar = {}
}

soilWaterLeg = Legend{
-- Attribute name:  soilWater
type = "number",
groupingMode = "equalsteps",
slices = 100,
precision = 5,
stdDeviation = "none",
maximum = 105,
minimum = 0,
colorBar = {
{color = "white", value = 0},
{color = {170, 255, 255}, value = 0.242991},
{color = {0, 170, 255}, value = 0.598131},
{color = {0, 85, 255}, value = 3.02804},
{color = "blue", value = 5.45794},
{color = {0, 0, 127}, value = 10}
},
stdColorBar = {}
}


-- ================================================================================#
-- OBSERVER IMAGE
if( not SKIP ) then
	cs:createObserver("textscreen",{"database"},{"Attributes", "Value"})
	cs:notify()	
end

-- TESTE01
-- Resultados esperados:
--[[

]]

-- ================================================================================#
-- OBSERVER MAP
if(not SKIP ) then
	cs:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg}) -- cabeca de boi
	--cs:createObserver("map", {"soilWater", "height_"}, {soilWaterLeg, heightLeg}) -- cabeca de boi
	--cs:createObserver("map", {"soilWater"}, {soilWaterLeg})  -- just soilwater map
	--cs:createObserver("map", {"height"}, {heightLeg})  -- just height map
	cs:notify()
end
-- TESTE02
-- Resultados esperados:
--[[

]]

-- ================================================================================#
-- OBSERVER UDP
if( SKIP ) then
	cs:createObserver("udpsender", {"valor", "explosao"}, {"45454", "127.0.0.1"});
end

-- TESTE03
-- Resultados esperados:
--[[

]]

-- ================================================================================#
-- TEST MODEL EXECUTION
-- ================================================================================#
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
-- Model initializaion
forEachCell(cs, function(cell)
	cell.soilWater = 0
	cell:notify()
end)

-- Model run	
for t = 1, FINAL_TIME, 1 do
	-- PART 2: It's raining in the high areas
	forEachCell(cs,function(cell)
		if ANYWHERE or (cell[HEIGHT] > ALT_CHUVA) then
			cell.soilWater = cell.past.soilWater + C
		end
		cell:notify(t)
	end)
	cs:synchronize()	

	-- PART 3: create a temporary variable to store the flow
	forEachCell(cs, function(cell)
		cell.flow = 0
	end)

	-- Calculate the drainage and the flow
	forEachCell(cs, function(cell)
		-- PART 4: calculate the drainage
		cell.soilWater = cell.past.soilWater - K*cell.past.soilWater
		-- count the lower neighbors
		countNeigh = 0
		forEachNeighbor(cell,
		function(cell, neigh)
			if (cell ~= neigh) and (cell[HEIGHT] >= neigh[HEIGHT]) then
				countNeigh = countNeigh + 1
			end
		end);

		-- PART 5: calculates the flow to neighbors
		if (countNeigh > 0) then
			flow = cell.soilWater / countNeigh
			-- send the water to neighbors
			forEachNeighbor(cell,
			function(cell, neigh)
				if (cell ~= neigh) 
				and (cell[HEIGHT] > neigh[HEIGHT]) then
					neigh.flow = neigh.flow + flow
				end
			end)
		end
	end)

	forEachCell(cs,function(cell)
		cell.soilWater = cell.flow
		cell:notify(t)		
	end)

	cs:synchronize()
	delay_s(2)
	cs:notify(t)
end
