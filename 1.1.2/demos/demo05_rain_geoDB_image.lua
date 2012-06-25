-- RAIN AND WATER DRAINAGE MODEL
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
C = 200 -- a single shot rain 
MINIMUM_HEIGHT_TO_RAIN = 255
K = 0.04 -- absorbing coefficient
FINAL_TIME = 30

soilWaterLeg = Legend{
	-- Attribute: soilWater
	type = "number",
	groupingMode = "equalsteps",
	slices = 40,
	precision = 1,
	stdDeviation = "none",
	maximum = 300,
	minimum = 0, 
	colorBar = {
		{ 
			color = "white",
			value = 0
		},
		{
			color = "blue",
			value = 1
		}
	}
}

heightLeg = Legend{
	-- Attribute: soilWater
	type = "number",
	groupingMode = "equalsteps",
	slices = 40,
	precision = 1,
	stdDeviation = "none",
	maximum = 255,
	minimum = 0,
	colorBar = {
		{
			color = "black", 
			value = 0
		},
		{
			color = "white",
			value = 255
		}
	}
}


math.randomseed(os.time())

cs = nil
if(dbms == 0) then
	cs = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = pwd,
		theme = "cells90x90"
	}
else
	cs = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "cells90x90",
		select = { HEIGHT, "soilWater" }	
	}		
end
cs:load();

-- Create a Observer Map
obs = Observer{ subject = cs, type = "map", attributes={HEIGHT, "soilWater"},legends= { heightLeg, soilWaterLeg} }

function isNeighbor(cell1, cell2)
	return cell1 ~= cell2 and cell1[ HEIGHT ] >= cell2[ HEIGHT ]
end

create3x3Neighborhood(cs, isNeighbor)

-------------------------------------------------------------------------------
rain = function(cs)
	forEachCell(cs, function(cell)
		if(cell[ HEIGHT ] >= MINIMUM_HEIGHT_TO_RAIN) then
			cell.soilWater = cell.soilWater + C
		end
	end)
end

absorb = function(cell)
	cell.soilWater = cell.soilWater - K*cell.soilWater
end

superficial_flow = function(cell)
	countNeigh = cell:getNeighborhood():size()	

	if(countNeigh > 0 ) then
		local qflow = cell.past.soilWater/countNeigh

		total = 0
		forEachNeighbor(cell, function(cell, neigh)
			neigh.soilWater = neigh.soilWater + qflow
			total = total + qflow
		end)

		if total ~= cell.past.soilWater then
			local rn = cell:getNeighborhood():sample()
			rn.soilWater = rn.soilWater + cell.past.soilWater - total
		end

	else
		cell.soilWater = cell.soilWater + cell.past.soilWater
	end
end

totalWater = function(cs)
	total = 0
	forEachCell(cs, function(cell)
		total = total + cell.soilWater
	end)
	return total
end

t = Timer{
	Event{ priority = 0, action = function(event)
		rain(cs)
		return false
	end},
	Event{ priority = 2, action = function(event)
		forEachCell(cs, absorb)
		cs:synchronize()
		forEachCell(cs, function(cell) cell.soilWater = 0 end)
		forEachCell(cs, superficial_flow)
	end},
	Event{ priority = 1, period = 1, action = function(event)
		print(event:getTime())
		cs:notify()
	end}
}

print("Simulating until step ".. FINAL_TIME .. "...") 
t:execute(FINAL_TIME)
print("READY!")
io.flush()
