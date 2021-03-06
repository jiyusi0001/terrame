-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright � 2001-2007 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library.
--
--The authors reassure the license terms regarding the warranties.
--They specifically disclaim any warranties, including, but not limited to,
--the implied warranties of merchantability and fitness for a particular purpose.
--The framework provided hereunder is on an "as is" basis, and the authors have no
--obligation to provide maintenance, support, updates, enhancements, or modifications.
--In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
--indirect, special, incidental, or consequential damages arising out of the use
--of this library and its documentation.
--
-- Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
-------------------------------------------------------------------------------------------
-- Expected result: 1 teste, 1230 assertations, (1 passed, 0 failed, 0 erros)
--

arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")
DB_VERSION = "4_2_0"

function test_NeighborhoodCreationMethods()

	print("-------------------------------------");
	print("-- test_NeighborhoodCreationMethods");

	local cs = CellularSpace{
		xdim=10
	}
	assert_not_nil(cs)
	assert_equal(100, cs:size())

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("Not testing...") io.flush()
	end
	print("Testing Neighborhood creation...") io.flush()

	------------------------------------------------------- Moore -----------------------------------------------------------------
	print("\t-> MOORE")
	cs:createNeighborhood {
		strategy = "moore",
		name = "moore"
	}	

	local x={}

	forEachCell(cs, function(c)
		local n = c:getNeighborhood("moore")		
		assert_not_nil(n)

		if(x[n:size()] == nil)then
			x[n:size()] = 0
		end

		x[n:size()] = x[n:size()] + 1

		forEachNeighbor(
		c,
		"moore",
		function(cell, neigh, weight)
			assert_equal(0.11111111111111, weight, 0.00001)
		end
		)
	end)

	assert_equal(32, x[6])
	assert_equal(4,  x[4])
	assert_equal(64, x[9])

	------------------------------------------------------- 3x3 -------------------------------------------------------------------
	print("\t-> 3x3")
	filterF = function(c,c) return true end
	weightF = function(c,c) return 1 end

	cs:createNeighborhood {
		strategy = "3x3",
		filter = filterF,
		weight = weightF,
		name = "3x3"
	}

	x={}

	forEachCell(cs, function(c)
		n = c:getNeighborhood("3x3")
		assert_not_nil(n)

		if(x[n:size()] == nil)then
			x[n:size()] = 0
		end

		x[n:size()] = x[n:size()] + 1

		forEachNeighbor(
		c,
		"3x3",
		function(cell, neigh, weight)
			assert_equal(1, weight)
		end
		)
	end)

	assert_equal(32, x[6])
	assert_equal(4,  x[4])
	assert_equal(64, x[9])

	------------------------------------------------------- mxn -------------------------------------------------------------------	
	print("\t-> MxN")
	cs:createNeighborhood {
		strategy = "mxn",
		m = 3, -- ratio
		n = 5, -- ratio
		filter = filterF,
		weight = weightF,
		name = "mxn",
	}

	x = {}

	forEachCell(cs, function(c)
		local n = c:getNeighborhood("mxn")
		assert_not_nil(n)
		assert_gte(6,n:size())

		if(x[n:size()] == nil)then
			x[n:size()] = 0
		end

		x[n:size()] = x[n:size()] + 1

		forEachNeighbor(
		c,
		"mxn",
		function(cell, neigh, weight)
			assert_equal(1, weight)
		end
		)
	end)

	assert_equal(4,  x[6])
	assert_equal(4,  x[8])
	assert_equal(16, x[9])
	assert_equal(12, x[10])
	assert_equal(16, x[12])
	assert_equal(48, x[15])

	-- RAIAN: Another Strategies to create neighborhoods
	------------------------------------------------------- Function --------------------------------------------------------------
	print("\t-> FUNCTION")
	filterFunc = function(c1, c2) 
		return (((c2.x <= c1.x + 2) and (c2.x >= c1.x - 2)) and ((c2.y <= c1.y + 2) and (c2.y >= c1.y - 2))) and (c1 ~= c2)
	end

	weightFunc = function(c1, c2)
		return (c1.x + c1.y) / ((c2.x + c2.y) + 1)
	end

	cs:createNeighborhood{
		strategy = "function",
		name = "function",
		filter = filterFunc,
		weight = weightFunc
	}

	x = {}
	local sumWeight = 0;
	local minWeight = math.huge
	local maxWeight = -math.huge

	forEachCell(
	cs, 
	function(cell)
		local neighborhood = cell:getNeighborhood("function")
		assert_not_nil(neighborhood)
		assert_gte(8, neighborhood:size())

		if(x[neighborhood:size()] == nil)then
			x[neighborhood:size()] = 0
		end

		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"function",
		function(c, neigh, weight)
			assert_gte(0, weight)
			assert_lte(4, weight)
			maxWeight = math.max(maxWeight, weight)
			minWeight = math.min(minWeight, weight)
			sumWeight = sumWeight + weight
		end
		)
	end
	)

	assert_equal(4, x[8])
	assert_equal(8, x[11])
	assert_equal(24, x[14])
	assert_equal(4, x[15])
	assert_equal(24, x[19])
	assert_equal(36, x[24])

	assert_equal(1679.7929714764, sumWeight, 0.00001)
	assert_equal(4, maxWeight)
	assert_equal(0, minWeight)

	------------------------------------------------------- Von Neumann -----------------------------------------------------------

	print("\t-> VONNEUMANN")

	cs:createNeighborhood{strategy = "vonneumann", name = "vonneumann"}

	x = {}

	forEachCell(
	cs,
	function(cell)
		local neighborhood = cell:getNeighborhood("vonneumann")
		assert_not_nil(neighborhood)
		assert_gte(2, neighborhood:size())

		if(x[neighborhood:size()] == nil)then
			x[neighborhood:size()] = 0
		end

		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"vonneumann",
		function(c, neigh, weight)
			assert_equal(0.25, weight)
		end
		)
	end
	)

	assert_equal(4, x[2])
	assert_equal(32, x[3])
	assert_equal(64, x[4])

	--###################################################### Coupling ###########################################################--
	print("Testing Coupling functions...")

	local cs2 = CellularSpace{
		xdim = 10
	}
	assert_not_nil(cs2)
	assert_equal(100, cs2:size())
	------------------------------------------------------- Coord -----------------------------------------------------------------
	print("\t-> COORD")

	cs:createNeighborhood{strategy = "coord", target = cs2, name = "coupling_coord"}

	x = {}

	forEachCell(
	cs,
	function(cell)
		local neighborhood = cell:getNeighborhood("coupling_coord")
		assert_not_nil(neighborhood)
		assert_equal(1, neighborhood:size())

		if(x[neighborhood:size()] == nil)then
			x[neighborhood:size()] = 0
		end

		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"coupling_coord", 
		function(c, neigh, weight)
			assert_equal(1, weight)
		end
		)
	end
	)

	assert_equal(100, x[1])

	------------------------------------------------------- mxn -------------------------------------------------------------------
	print("\t-> MxN")

	filterFunction = function(c1, c2)
		return true;
	end

	weightFunction = function(c1, c2)
		return ((c1.x + c2.x) * (c1.y + c2.y))/5
	end

	cs:createNeighborhood{
		strategy = "mxn", 
		target = cs2, 
		name = "coupling_mxn", 
		m = 3, 
		n = 3, 
		filter = filterFunction,
		weight = weightFunction
	}

	x = {}
	minWeight = math.huge
	maxWeight = -math.huge
	sumWeight = 0

	forEachCell(
	cs,
	function(cell)
		local neighborhood = cell:getNeighborhood("coupling_mxn")
		assert_not_nil(neighborhood)
		assert_gte(4, neighborhood:size())

		if(x[neighborhood:size()] == nil)then
			x[neighborhood:size()] = 0
		end

		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"coupling_mxn",
		function(c, neigh, weight)
			assert_gte(0, weight)
			assert_lte(64.8, weight)
			minWeight = math.min(minWeight, weight)
			maxWeight = math.max(maxWeight, weight)
			sumWeight = sumWeight + weight
		end
		)			
	end
	)

	assert_equal(32, x[6])
	assert_equal(4, x[4])
	assert_equal(64, x[9])

	assert_equal(64.8, maxWeight)
	assert_equal(0, minWeight)
	assert_equal(12700.8, sumWeight, 0.00001)

	-- RAIAN: Fim

	print("READY!!")
	assert_true(true)
end

-- RAIAN: Tests for loadNeighborhood Methods
function test_LoadNeighborhoodMethod()

	print("-------------------------------------");
	print("-- test_LoadNeighborhoodMethod");

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if(SKIPS[2])then
		skip("Not testing...")
	end

	cs = nil
	if(dbms == 0) then
		cs = CellularSpace{
			dbType = "mysql",
			host = "127.0.0.1",
			database = "cabeca",
			user = "root",
			password = pwd,
			theme = "cells900x900"
		}
	else
		cs = CellularSpace{
			dbType = "ADO",
			database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
			theme = "cells900x900"	
		}		
	end

	assert_not_nil(cs)
	assert_equal(121, cs:size())

	print("Testing load Neighborhood method from CellularSpace...") io.flush()	

	-------------------------------------------------------- .gpm Reg CS ----------------------------------------------------------

	print("\t-> Load Neighborhood from a .gpm file for a Regular Cellular Space!")

	cs:loadNeighborhood{
		source = TME_PATH .."/database/neighCabecaDeBoi900x900.gpm",
		name = "gpmReg"
	}

	local x = {}

	local minSize = math.huge
	local maxSize = -math.huge
	local minWeight = math.huge
	local maxWeight = -math.huge
	local sumWeight = 0

	forEachCell(
	cs, 
	function(cell)
		local neighborhood = cell:getNeighborhood("gpmReg")
		assert_not_nil(neighborhood)

		assert_gte(5, neighborhood:size())
		assert_lte(12, neighborhood:size())

		minSize = math.min(neighborhood:size(), minSize)
		maxSize = math.max(neighborhood:size(), maxSize)

		if(x[neighborhood:size()] == nil)then x[neighborhood:size()] = 0 end
		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"gpmReg",
		function(c, neigh, weight)
			assert_gte(900, weight)
			assert_lte(1800, weight)

			minWeight = math.min(weight, minWeight)
			maxWeight = math.max(weight, maxWeight)
			sumWeight = sumWeight + weight
		end
		)
	end
	)

	assert_equal(5, minSize)
	assert_equal(12, maxSize)
	assert_equal(900, minWeight)
	assert_equal(1800, maxWeight)
	assert_equal(1617916.8, sumWeight, 0.00001)

	assert_equal(28, x[11])
	assert_equal(8, x[7])
	assert_equal(28, x[8])
	assert_equal(4, x[10])
	assert_equal(49, x[12])
	assert_equal(4, x[5])

	-------------------------------------------------------- .gpm Irreg CS --------------------------------------------------------
	-- Arranjar um BD com estruturas irregulares para testar
	-------------------------------------------------------- .GAL Reg CS ----------------------------------------------------------
	print("\t-> Load Neighborhood from a .GAL file for a Regular Cellular Space!")

	cs:loadNeighborhood{
		source = TME_PATH .."/database/neighCabecaDeBoi900x900.GAL",
		name = "galReg"
	}

	x = {}

	minSize = math.huge
	maxSize = -math.huge
	sumWeight = 0

	forEachCell(
	cs, 
	function(cell)
		local neighborhood = cell:getNeighborhood("galReg")
		assert_not_nil(neighborhood)

		assert_gte(5, neighborhood:size())
		assert_lte(12, neighborhood:size())

		minSize = math.min(neighborhood:size(), minSize)
		maxSize = math.max(neighborhood:size(), maxSize)

		if(x[neighborhood:size()] == nil)then x[neighborhood:size()] = 0 end
		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"galReg",
		function(c, neigh, weight)
			assert_equal(1, weight)
			sumWeight = sumWeight + weight
		end
		)
	end
	)

	assert_equal(1236, sumWeight)
	assert_equal(5, minSize)
	assert_equal(12, maxSize)

	assert_equal(28, x[11])
	assert_equal(8, x[7])
	assert_equal(28, x[8])
	assert_equal(4, x[10])
	assert_equal(49, x[12])
	assert_equal(4, x[5])

	-------------------------------------------------------- .GAL Irreg CS --------------------------------------------------------
	-- Arranjar um BD com estruturas irregulares para testar
	-------------------------------------------------------- .GWT Reg CS ----------------------------------------------------------
	print("\t-> Load Neighborhood from a .GWT file for a Regular Cellular Space!")	

	cs:loadNeighborhood{
		source = TME_PATH .."/database/neighCabecaDeBoi900x900.GWT",
		name = "gwtReg"
	}

	x = {}

	minSize = math.huge
	maxSize = -math.huge
	minWeight = math.huge
	maxWeight = -math.huge
	sumWeight = 0

	forEachCell(
	cs, 
	function(cell)
		local neighborhood = cell:getNeighborhood("gwtReg")
		assert_not_nil(neighborhood)

		assert_gte(5, neighborhood:size())
		assert_lte(12, neighborhood:size())

		minSize = math.min(neighborhood:size(), minSize)
		maxSize = math.max(neighborhood:size(), maxSize)

		if(x[neighborhood:size()] == nil)then x[neighborhood:size()] = 0 end
		x[neighborhood:size()] = x[neighborhood:size()] + 1

		forEachNeighbor(
		cell, 
		"gwtReg",
		function(c, neigh, weight)
			assert_gte(900, weight)
			assert_lte(1800, weight)

			minWeight = math.min(weight, minWeight)
			maxWeight = math.max(weight, maxWeight)
			sumWeight = sumWeight + weight
		end
		)
	end
	)

	assert_equal(1800, maxWeight)
	assert_equal(900, minWeight)
	assert_equal(1617916.8, sumWeight, 0.00001)

	assert_equal(28, x[11])
	assert_equal(8, x[7])
	assert_equal(28, x[8])
	assert_equal(4, x[10])
	assert_equal(49, x[12])
	assert_equal(4, x[5])

	-------------------------------------------------------- .GWT Irreg CS --------------------------------------------------------
	-- Arranjar um BD com estruturas irregulares para testar

	--	print("------------------------------------------------")
	--	print("MAX: "..maxWeight)
	--	print("MIN: "..minWeight)
	--	print("SUM: "..sumWeight)
	--	print("------------------------------------------------")

	--	print("------------- x: ------------------")
	--	table.foreach(x, print)
	--	print("-----------------------------------")

	--	print("-------------------------------------------------");	
	--	forEachCell(
	--		cs, 
	--		function(cell)
	--			neighborhood = cell:getNeighborhood("galReg")
	--			print("neighborhood \""..neighborhood:getID().."\" from the cell["..cell:getID().."] - size: "..neighborhood:size())
	--			forEachNeighbor(
	--				cell,
	--				"galReg",
	--				function(cell, neigh, weight)
	--					print("\tneigh["..neigh:getID().."] - weight: "..weight)
	--				end
	--			)
	--		end
	--	)
	--	print("-------------------------------------------------");	

	print("READY!")
	assert_true(true)
end

skips = {

}

db = getDataBase()
dbms = db["dbms"]
pwd = db["pwd"]

functionList = {
	[1] = "test_NeighborhoodCreationMethods",
	[2] = "test_LoadNeighborhoodMethod"
}

SKIPS = executeBasics("neighborhood creation", functionList, skips)

lunatest.run()

os.exit(0)
