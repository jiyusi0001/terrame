-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2007 INPE and TerraLAB/UFOP.
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
-- Expected result: 14 teste, 532444 assertations, (13 passed, 0 failed, 0 erros, 1 skipped)
--

-- \file test_space.lua
-- Unit Tests for TerraME spatial models: Cell, Cellular, Neighborhood
-- Unit Tests for integration with the TerraLib 3.2.0 library 

dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

-- attributes name can differ in differents DBMS's
DB_VERSION = "4_2_0"
HEIGHT = "height_"

db = getDataBase()
dbms = db["dbms"]
pwd = db["pwd"]

local gisTest = UnitTest {
	test_LoadTerraLibCellularSpacesMinimalParameters = function(unitTest)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
		print("\nTesting LoadTerraLibCellularSpacesMinimalParameters...")

		-- defines and loads the celular space from a TerraLib theme
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
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"	
			}		
		end
		--cs:load();

		cont = 0
		forEachCell( cs, function( cell) 
			cont = cont + 1
			unitTest:assert_string(cell.object_id0)
			unitTest:assert_number(cell.x )
			unitTest:assert_number(cell.y )
			unitTest:assert_not_nil(cell[ HEIGHT ])
			unitTest:assert_not_nil(cell.soilWater)
		end)
		unitTest:assert_equal(10201, cont)

		print("READY")
		unitTest:assert_true(true)	
	end,

	test_LoadTerraLibCellularSpacesSelectedAttributes = function(unitTest)

		--[[if(SKIPS[2]) then
		skip("No testing...") -- 50002 assertions
		end]]--

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
		print("\nTesting LoadTerraLibCellularSpacesSelectedAttributes...")

		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0) then
			cs = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }	
			}
		else
			cs = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }

			}
		end
		print("Loading...")
		--cs:load();

		print("testing loaded cells...")
		cont = 0
		forEachCell( cs, function( cell) 
			cont = cont + 1
			unitTest:assert_string(cell.objectId_)
			unitTest:assert_number(cell.x )
			unitTest:assert_number(cell.y )
			unitTest:assert_not_nil(cell[HEIGHT])
			unitTest:assert_not_nil(cell.soilWater)
		end)
		print("Count:", cont) io.flush()
		unitTest:assert_equal(10201, cont)

		print("READY")
		unitTest:assert_true(true)	
	end,

	-- Loads the CellularSpace using the WHERE clause
	test_LoadTerraLibWhereClause = function(unitTest)

		--[[if(SKIPS[3]) then
		skip("Not testing...") -- 27721 assertation
		end--]]

		print("------------------------------------------------");
		print("-- LoadTerraLibWhereClause ");

		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0) then
			cs = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }	,
				where = HEIGHT .. " > 100"
			}
		else
			cs = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" },
				where = HEIGHT .. " > 100"	
			}
		end
		--cs:load();


		print("wait...") io.flush()
		--cs:load();

		cont = 0
		forEachCell( cs, function( cell) 
			cont = cont + 1
			unitTest:assert_string(cell.objectId_)
			unitTest:assert_number(cell.x )
			unitTest:assert_number(cell.y )
			unitTest:assert_gt(cell[ HEIGHT ],99)		
			--assert_gt(100, cell[ HEIGHT ])
			unitTest:assert_not_nil(cell.soilWater)
		end)
		print(cont) io.flush()
		unitTest:assert_equal(5673, cont)

	end,

	test_TerraLibCellularSpaceCoordinatesSystem = function(unitTest)

		print("------------------------------------------------");
		print("\nTesting TerraLibCellularSpaceCoordinatesSystem...")

		-- defines and loads the celular space from a TerraLib theme
		csDB = nil
		if(dbms == 0) then
			csDB = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }
			}
		else
			csDB = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }
			}
		end
		--csDB:load();

		-- GEO_DATABASE: Tests coordinates conversion functions
		-- print( csDB.cells[0].x, csDB.cells[0].y) io.flush() -- ERROR: There is no index: 0 (zero)

		--print( csDB.cells[1].x, csDB.cells[1].y) io.flush()
		--print( csDB.cells[2].x, csDB.cells[2].y) io.flush()
		--print( csDB.cells[3].x, csDB.cells[3].y) io.flush()

		print("geo_wait...") io.flush()
		x, y = index2coord(1, csDB.maxCol)
		idx = coord2index( x, y, csDB.maxCol)
		--print(x, y, idx)
		unitTest:assert_equal(0,x)
		unitTest:assert_equal(0,y)
		unitTest:assert_equal(1,idx)

		x, y = index2coord(2, csDB.maxCol)
		idx = coord2index( x, y, csDB.maxCol)
		--print(x, y, idx)
		unitTest:assert_equal(0,x)
		unitTest:assert_equal(1,y)
		unitTest:assert_equal(2,idx)

		--x, y = index2coord(99, csDB.maxCol)
		x, y = index2coord(100, csDB.maxCol)
		idx = coord2index( x, y, csDB.maxCol)
		--print(x, y, idx, csDB.maxCol)
		unitTest:assert_equal(0,x)
		unitTest:assert_equal(99,y)
		unitTest:assert_equal(100,idx)

		x, y = index2coord(101, csDB.maxCol)
		idx = coord2index( x, y, csDB.maxCol)
		--print(x, y, idx)
		unitTest:assert_equal(0,x)
		unitTest:assert_equal(100,y)
		unitTest:assert_equal(101,idx)

		-- test CellularSpace::getCell()
		c = Coord{x=0,y=100}
		--print( csDB.cells[i].x, csDB.cells[i].y) io.flush()
		--print( csDB:getCell(c).x, csDB:getCell(c).y) io.flush()
		cIdx1 = coord2index(csDB.cells[idx].x, csDB.cells[idx].y, csDB.maxCol ) 
		cIdx2 = coord2index(csDB:getCell(c).x, csDB:getCell(c).y, csDB.maxCol ) 
		--print( cIdx1, cIdx2) io.flush()
		--print(cIdx1 == cIdx2) io.flush()
		unitTest:assert_equal( cIdx1, cIdx2 )
		--if csDB:getCell(c) == csDB.cells[100] then print "EQUAL" io.flush() end
		unitTest:assert_equal(csDB:getCell(c), csDB.cells[idx])

		-- Test cell new attributes
		csDB:getCell(c).newAttribute = 3
		--print(cs.cells[100].newAttribute) -- 3
		unitTest:assert_equal(3, csDB.cells[101].newAttribute)

		print("READY")
		unitTest:assert_true(true)	
	end,

	-- Loads a CellularSpace from the TerraLib (ADO). 
	-- Loads "cells" CellularSpace from the "aguasolo"  database. 
	-- Loads the CellularSpace "neighName" neighborhood
	-- Traverses the CellularSpace printing all cell's neighborhood, twice.
	-- Once using the Neighborhood iterator, and
	-- Another using the ForEachNeighbor function.
	-- Proximity matrix generated in the 3.2.0 TerraView version
	-- Parameters: (contiguity, calculate neighbor distance, 
	--              squared inverse distance, neighbor number normalization)
	test_LoadTerraLibGPM = function(unitTest)


		-- RAIAN: The function that loads a GPM from a TerraLib database is not working yet! 
		-- 7 assertation

		neighName = "1";


		print("\n-------------------------------------------------");
		print("-- test_LoadTerraLibGPM");



		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0)then
			cs = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }
			}
		else
			cs = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" }	
			}		
		end
		print("wait...") io.flush()
		--cs:load();
		print("wait...") io.flush()

		--cs:loadTerraLibGPM(neighName);
		--cs:loadNeighborhood();
		--	cs:loadNeighborhood{name = neighName, source = "filepath ou dbname"}	
		cs:loadNeighborhood{ source = "GPM_NAME", name = neighName};

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		print( "TRAVERSES CELLULAR SPACE - FIRST TIME"); io.flush();
		for i,cell in ipairs( cs.cells) do 
			countCell = countCell + 1
			local nh = cell:getNeighborhood(neighName);
			--print("Neighborhood: ", nh); io.flush();
			--print("Size: ", nh:size()); io.flush();
			nh:first();
			while( not nh:isLast()) do
				neigh = nh:getNeighbor();
				weight = nh:getWeight();
				unitTest:assert_not_nil( neigh )
				unitTest:assert_not_nil( weight )
				--print("C"..neigh.x.."L"..neigh.y..", "..weight); io.flush();
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
				nh:next();
			end
		end
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(10201,countCell)
		unitTest:assert_equal(80400,countNeigh)
		unitTest:assert_equal(10201.00000602,sumWeight,0.00001)

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		print( "TRAVERSES CELLULAR SPACE - SECOND TIME"); io.flush();
		forEachCell( 
		cs,
		function( cell,i)
			countCell = countCell + 1
			--print("C"..cell.x.."L"..cell.y.."..............................................");
			forEachNeighbor(
			cell,
			function(cell, neigh, weight)
				unitTest:assert_not_nil( cell ) 
				unitTest:assert_not_nil( neigh )
				unitTest:assert_not_nil( weight )
				--			print("C"..neigh.x.."L"..neigh.y..", "..weight); io.flush();
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end,
			neighName
			)
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(10201,countCell)
		unitTest:assert_equal(80400,countNeigh)
		unitTest:assert_equal(10201.00000602,sumWeight,0.00001)

		print("READY!!!");
		unitTest:assert_true(true)
	end,

	-- RAIAN: Comentei este teste porque vou realiza-lo no test_neighborhood.lua
	-- VERIFICAR
	-- Loads the CellularSpace Neighborhood from a file (*.GAL).
	-- Traverses the CellularSpace counting all cell's neighborhoods.
	--function test_LoadNeighborhoodFromGALFile()
	--	
	--	if(SKIPS[6]) then
	--		skip("Not working yet (GAL neighborhood file)... ")
	--	end
	--	
	--	print("-------------------------------------");
	--	print("test_LoadNeighborhoodFromGALFile     ");
	--	
	--	neighName = "1"
	--	
	--	-- defines and loads the celular space from a TerraLib theme
	--	cs = nil
	--	if(dbms == 0)then
	--		cs = CellularSpace{
	--			dbType = "mysql",
	--			--host = "127.0.0.1",
	--			host = "localhost",
	--			database = "cabeca",
	--			user = "root",
	--			password = pwd,
	--			theme = "cells90x90",
	--			select = { HEIGHT, "soilWater" }
	--		}
	--	else
	--		cs = CellularSpace{
	--			dbType = "ADO",
	--			database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
	--			theme = "cells90x90",
	--			select = { HEIGHT, "soilWater" }	
	--		}		
	--	end
	--	print("wait...") io.flush()
	--	--cs:load();
	--	
	--	--------------------------------------------------------------------------------------------------------------------------------------------
	--	cs:loadNeighborhood{ source = "database\\neighCabecaDeBoi90x90.GAL", name = neighName};
	--	--------------------------------------------------------------------------------------------------------------------------------------------
	--	local countCell = 0   -- cell test counter
	--	local countNeigh = 0	-- neighbor test counter
	--	local sumWeight =0	-- weight test accumulator	
	--	forEachCell( 
	--		cs,
	--		function( cell )
	--			countCell = countCell + 1
	--			--print("C"..cell.x.."L"..cell.y.."..............................................");
	--			forEachNeighbor(
	--				cell,
	--				function(cell, neigh, weight)
	--					--print("C"..neigh.x.."L"..neigh.y..", "..weight);
	--					countNeigh = countNeigh + 1
	--					sumWeight = sumWeight + weight
	--				end,
	--				neighName
	--			)
	--		end
	--	);
	--	print("Cells: ", countCell )
	--	print("Neighbors: ", countNeigh )
	--	print("Weight: ", sumWeight)
	--	assert_equal(10201,countCell)
	--	assert_equal(80400,countNeigh)
	--	assert_equal(10201,sumWeight,0.00001)
	--	
	--	
	--	print("READY!!!");
	--	assert_true(true)
	--
	--end


	-- Loads the CellularSpace using the WHERE clause
	-- Dynamically, creates a Moore neighborhood
	test_LoadTerraLibWhereClauseAndCreateNeighborhood = function(unitTest)

		print("------------------------------------------------");
		print("-- LoadTerraLibWhereClauseAndCreateNeighborhood ");

		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0)then
			cs = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" },
				where = HEIGHT .. " > 100"
			}
		else
			cs = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90",
				select = { HEIGHT, "soilWater" },
				where = HEIGHT .. " > 100"	
			}		
		end

		print("wait...") io.flush()
		--cs:load();

		cs:createNeighborhood{ strategy = "moore", name = "first" }

		filter3x3 = function(cell,neigh)		
			return neigh[HEIGHT] < cell[HEIGHT];
		end

		weight3x3 = function(cell, neigh)
			return (cell[HEIGHT] - neigh[HEIGHT] )/ (cell[HEIGHT] + neigh[HEIGHT]);
		end

		cs:createNeighborhood{ strategy = "3x3", filter = filter3x3, weight = weight3x3, name = "second" }

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		forEachCell( 
		cs,
		function( cell )
			--print("C"..cell.x.."L"..cell.y.."..............................................");
			countCell = countCell + 1
			forEachNeighbor(
			cell,
			"first",				
			function(cell, neigh, weight)
				--print("C"..neigh.x.."L"..neigh.y..", "..weight);
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end
			)
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(5673, countCell)
		unitTest:assert_equal(49385, countNeigh)
		unitTest:assert_equal(5487.2222222281,sumWeight,0.00001)

		print("................"); io.flush();

		countCell = 0   -- cell test counter
		countNeigh = 0	-- neighbor test counter
		sumWeight =0	-- weight test accumulator	
		forEachCell( 
		cs,
		function(cell )
			--print("C"..cell.x.."L"..cell.y.."..............................................");
			countCell = countCell + 1
			forEachNeighbor(
			cell,
			"second",
			function(cell, neigh, weight)
				--print("C"..neigh.x.."L"..neigh.y..", "..cell.altimetria-neigh.altimetria..", "..weight);
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end
			)
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(5673,countCell)
		--assert_equal(18045,countNeigh)
		unitTest:assert_equal(18582,countNeigh)
		--assert_equal(453.59519215437,sumWeight,0.00001)
		unitTest:assert_equal(451.98359156683,sumWeight,0.00001)


		print("READY!!!"); io.flush();
		unitTest:assert_true(true)
	end,

	-- Loads the CellularSpace using the mininal set of parameters. 
	-- The default values are: dbType ="MySQL", host="localhost", layer=theme, select=*, where="".
	-- On TerraME Neighborhood functions, the parameter neighborhood name (or ID) is optional.
	-- The default value is "1".
	-- Creates a Moore neighboorhood under the default ID and traverses it.
	-- This neighborhood is overwritten by another loadded from the database, which is also traversed.
	test_NeighborhoodOverwriting = function(unitTest)

		print("-------------------------------------");
		print("-- test_NeighborhoodOverwriting");


		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0)then
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
		print("wait...") io.flush()
		--cs:load();

		cs:createNeighborhood()

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		forEachCell( 
		cs,
		function( cell )
			--print("C"..cell.x.."L"..cell.y.."..............................................");
			countCell = countCell + 1
			forEachNeighbor(
			cell,
			function(cell, neigh, weight)
				--print("C"..neigh.x.."L"..neigh.y..", "..weight);
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end
			)
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(121,countCell)
		unitTest:assert_equal(961,countNeigh)
		unitTest:assert_equal(106.77777777778,sumWeight,0.00001)

		print("......................................")
		print("wait..."); io.flush();

		--	cs:loadTerraLibGPM();
		-- RAIAN: This function is not working with GPM stored in database!
		-- Suggestion: Use a .gpm file instead of a database. 
		--	cs:loadNeighborhood{ source = "NAME_GPM" }
		cs:loadNeighborhood{source = TME_PATH .."/database/neighCabecaDeBoi900x900.gpm"}

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		forEachCell( 
		cs,
		function( cell )
			--print("C"..cell.x.."L"..cell.y.."..............................................");
			countCell = countCell + 1
			forEachNeighbor(
			cell,
			function(cell, neigh, weight)
				--print("C"..neigh.x.."L"..neigh.y..", "..weight);
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end
			)
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(121,countCell)
		unitTest:assert_equal(1236,countNeigh)
		--assert_equal(2420928,sumWeight,0.00001)
		--assert_equal(2152870,sumWeight,0.00001)
		unitTest:assert_equal(1617916.8,sumWeight,0.00001)

		print("READY!!!");
		unitTest:assert_true(true)
	end,

	-- Loads the CellularSpace using the mininal set of parameters. 
	-- Creates TWO Moore neighboorhoodS  and traverses THEM using the CELL NEIGHBORHOODS ITERATOR.
	test_NeighborhoodIterators = function(unitTest)

		-- 4 assertation

		print("-------------------------------------");
		print("-- test_NeighborhoodsIterators");

		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0)then
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
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"
			}		
		end
		print("wait...") io.flush()

		cs:createNeighborhood{ strategy = "moore", name = "moore1" }
		cs:createNeighborhood{ strategy = "moore", name = "moore2" }

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		forEachCell( 
		cs,
		function( cell )
			print("C"..cell.x.."L"..cell.y.."..............................................");
			countCell = countCell + 1
			cell:first();
			while( not cell:isLast() ) do
				local nh = cell:getCurrentNeighborhood();
				forEachNeighbor(
				cell,
				nh:getID(),
				function(cell, neigh, weight)
					print("C"..neigh.x.."L"..neigh.y..", "..weight);
					countNeigh = countNeigh + 1
					sumWeight = sumWeight + weight
				end
				)
				cell:next();
			end
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)

		unitTest:assert_equal(10201, countCell)
		unitTest:assert_equal(181202, countNeigh)
		unitTest:assert_equal(20133.555555527, sumWeight,0.00001)

		print("READY!!!");
		unitTest:assert_true(true)
	end,

	-- Loads the CellularSpace using the mininal set of parameters.
	-- Creates TWO Moore neighboorhoodS  and traverses THEM using the 
	-- "forEachNeighborhood( cell, f( neighborhood) )".
	test_forEachNeighbor = function(unitTest)

		-- 4 assertation


		print("-------------------------------------");
		print("-- test_forEachNeighbor");

		-- defines and loads the celular space from a TerraLib theme
		cs = nil
		if(dbms == 0)then
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
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"
			}		
		end
		--cs:load();

		--createMooreNeighborhood( cs, "moore1" );
		cs:createNeighborhood {
			name = "moore1"
		}	
		--createMooreNeighborhood( cs, "moore2" );
		cs:createNeighborhood {
			name = "moore2"
		}

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	

		forEachCell( 
		cs,
		function( cell )
			-- print("C"..cell.x.."L"..cell.y.."..............................................");
			countCell = countCell + 1
			forEachNeighborhood(
			cell, 
			function( neighborhood  )
				-- print("-- "..neighborhood:getID());
				forEachNeighbor(
				cell,
				neighborhood:getID(),
				function(cell, neigh, weight)
					-- print("C"..neigh.x.."L"..neigh.y..", "..weight);
					countNeigh = countNeigh + 1
					sumWeight = sumWeight + weight
				end
				)						
			end
			);
		end
		);

		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(10201,countCell)
		unitTest:assert_equal(181202,countNeigh)
		unitTest:assert_equal(20133.555555527,sumWeight,0.00001)

		print("READY!!!");
		unitTest:assert_true(true)

	end,

	-- Loads the CellularSpace using the mininal set of parameters. 
	-- Creates TWO  neighboorhoods  and traverses them.
	-- The former neighborhood is Moore, the later is a MxN stationary neighborhood
	test_createMxNNeighborhood = function(unitTest)

		print("-------------------------------------");
		print("-- test_createMxNNeighborhood ");

		-- defines and loads the celular space from a TerraView theme
		cs1 = nil
		if(dbms == 0)then
			cs1 = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90"
			}
		else
			cs1 = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"
			}		
		end

		cs1:createNeighborhood{	strategy = "moore", name = "moore" }

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		-- Creates a neighborhood relationship which strengh is proportional to the number of neighbor
		-- This weight strategy is usefull for reduce boder effects
		forEachCell( cs1, function(cell)	cell.neighCont = 0; end  );
		cs1:createNeighborhood {
			strategy = "mxn",
			m = 3,
			n = 2,		
			--## PRATICE: change the neighborhood, dimension, 2x2, 3x2, etc
			filter = function(cell,neigh) 
				if( cell.x == neigh.x) and (cell.y == neigh.y) then 
					--## PRATICE: comment and uncomment the following line
					return false;
				end
				cell.neighCont = cell.neighCont + 1;
				countNeigh = countNeigh + 1;
				return true; 
			end,
			weight = function(cell, neigh)
				local weight = 1/cell.neighCont; sumWeight = sumWeight + weight; countCell = countCell +  1; return weight;
			end,
			name = "MxNStationary"
		}

		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(80400, countCell)
		unitTest:assert_equal(80400, countNeigh)
		unitTest:assert_equal(sumWeight, 27549.251190486,0.00001)


		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		forEachCell( cs1, 
		function(cell)
			countCell = countCell + 1
			neighborhood = cell:getNeighborhood("MxNStationary");
			forEachNeighbor(
			cell,
			"MxNStationary",
			function(cell, neigh, weight)
				neighborhood:setWeight( 1 / cell.neighCont );
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end
			);
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(10201,countCell)
		unitTest:assert_equal(80400, countNeigh)
		unitTest:assert_equal(27549.251190486,sumWeight,0.00001)

		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	
		forEachCell( 
		cs1,
		function(cell )
			--print("C"..cell.x.."L"..cell.y..", "..cell.neighCont.."..............................................");
			countCell = countCell + 1
			forEachNeighborhood(
			cell, 
			function( neighborhood  )
				--print("-- "..neighborhood:getID()..", "..neighborhood:size());
				forEachNeighbor(
				cell,
				neighborhood:getID(),
				function(cell, neigh, weight)
					--print("C"..neigh.x.."L"..neigh.y..", "..weight);
					countNeigh = countNeigh + 1
					sumWeight = sumWeight + weight
				end
				)						
			end
			);
		end
		);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(10201,countCell)
		unitTest:assert_equal(171001,countNeigh)
		--assert_equal(sumWeight,19867.11111,0,.00001)
		unitTest:assert_equal(20267.777777763,sumWeight,0.00001)

		print("READY!!!");
		unitTest:assert_true(true)

	end,

	-- Loads TWO different CellularSpaces from the database and SPATIALLY COUPLEs them.
	-- So, it traverses the SPATIAL COUPLING RESULTING NEIGHBORHOODS.
	-- Test rules based on the cell position inside the CellularSpace
	test_spatialCoupling = function(unitTest)

		print("-------------------------------------");
		print("-- test_spatialCoupling");

		-- defines and loads the celular space from a TerraView theme
		cs1 = nil
		if(dbms == 0)then
			cs1 = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells900x900"
			}
		else
			cs1 = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells900x900"
			}		
		end
		--cs1:load();

		cs2 = nil
		if(dbms == 0)then
			cs2 = CellularSpace{
				dbType = "mysql",
				host = "127.0.0.1",
				database = "cabeca",
				user = "root",
				password = pwd,
				theme = "cells90x90"
			}
		else
			cs2 = CellularSpace{
				dbType = "ADO",
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"
			}		
		end
		--cs2:load();

		print("wait...")
		cs1:createNeighborhood {
			strategy = "mxn",
			target = cs2,
			m = 3,
			n = 2,		
			--## PRATICE: change the neighborhood, dimension, 2x2, 3x2, etc
			filter = function(cell,neigh) 
				if( cell.x == neigh.x) and (cell.y == neigh.y) then 
					--## PRATICE: comment and uncomment the following line
					return false;
				end
				return true; 
			end,
			weight = function(cell, neigh) return 1/9; end,
			name = "spatialCoupling"
		}
		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	

		-- Traverses the "cs1" neighborhood
		print("-- Traverses the cs1 neighborhood. "); io.flush()
		OUTPUT = "";
		forEachCell( 
		cs1,
		function( cell, i )
			countCell = countCell + 1 -- test counter

			neighborhood = cell:getNeighborhood("spatialCoupling");

			OUTPUT = OUTPUT ..neighborhood:size()..", ";
			if( i % 11 == 0 ) then 
				--print(OUTPUT);
				OUTPUT = "";
			end

			forEachNeighborhood(
			cell, 
			function( neighborhood  )
				forEachNeighbor(
				cell,
				neighborhood:getID(),
				function(cell, neigh, weight)
					--print("C"..neigh.x.."L"..neigh.y..", "..weight);
					countNeigh = countNeigh + 1
					sumWeight = sumWeight + weight
				end
				)						
			end
			);
		end
		);
		--print(OUTPUT);
		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(121,countCell)
		unitTest:assert_equal(903,countNeigh)
		unitTest:assert_equal(100.33333,sumWeight,0.00001)


		local countCell = 0   -- cell test counter
		local countNeigh = 0	-- neighbor test counter
		local sumWeight =0	-- weight test accumulator	

		-- Traverses the "cs2" neighborhood
		print("-- Traverses the cs2 neighborhood."); io.flush();
		OUTPUT = "";
		forEachCell( 
		cs2,
		function( cell,i )

			neighborhood = cell:getNeighborhood("spatialCoupling");

			--OUTPUT = OUTPUT ..neighborhood:size()..", ";
			if( i % 100 == 0 ) then 
				--print(OUTPUT);
				OUTPUT = "";
			end

			forEachNeighborhood(
			cell, 
			function( neighborhood  )
				countCell = countCell + 1
				forEachNeighbor(
				cell,
				neighborhood:getID(),
				function(cell, neigh, weight)
					--print("C"..neigh.x.."L"..neigh.y..", "..weight);
					countNeigh = countNeigh + 1
					sumWeight = sumWeight + weight
				end
				)						
			end
			);
		end
		);
		--print(OUTPUT);

		print("Cells: ", countCell )
		print("Neighbors: ", countNeigh )
		print("Weight: ", sumWeight)
		unitTest:assert_equal(10201,countCell)
		unitTest:assert_equal(903,countNeigh)
		unitTest:assert_equal(100.33333, sumWeight,0.00001)

		print("READY!!!");
		unitTest:assert_true(true)


	end,

	test_SaveImageFromTerraLibCellularSpace = function(unitTest)

		print("-------------------------------------");
		print("-- test_SaveImageFromTerraLibCellularSpace");

		-- defines and loads the celular space from a TerraView theme
		cs = nil
		if(dbms == 0)then
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
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"
			}		
		end
		--cs:load();

		for t = 1,2 do

			forEachCell( cs,
			function( cell )
				cell[HEIGHT] = t
			end	)


			-- NOTE: It should return a Boolean value indicating the sucess or the fail.
			-- save2PNGc(cs, t, "test/results/rain/", HEIGHT, {0, 2}, {WHITE, BLUE}, 60)

		end
		print("READY!!! -- Look into the 'test/result/rain/' filesystem directory!!!")
		unitTest:assert_true(true)

	end,

	test_SaveTerraLibCellularSpace = function(unitTest)

		print("---------------------------------------");
		print("-- test_SaveTerraLibCellularSpace");

		-- defines and loads the celular space from a TerraView theme
		cs = nil
		if(dbms == 0)then
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
				database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
				theme = "cells90x90"
			}		
		end
		--cs:load()

		for t = 1,2 do

			forEachCell( cs,
			function( cell )
				cell[HEIGHT] = t
			end	)

			-- NOTE: It should returns the number o sucessfully saved cells
			cs:save(t,"themeName",HEIGHT ) -- all attributes
		end
		print("READY!!! -- Look at the TerraLib database!!!")
		unitTest:assert_true(true)

	end,

  test_save_load_shapefile = function(unitTest)
    function createShapeTable()
	    local cellspaceParameters = {
		    dbType = "",
		    host = "",
		    database = TME_PATH.."/tests/dependencies/shapefile/EstadosBrasil.shp",
		    user = "",
		    password = "",
		    theme = ""
	    }
	    return cellspaceParameters
    end

    cs = CellularSpace(createShapeTable())

    unitTest:assert_equal(cs:size(),27)
    unitTest:assert_equal(cs.minRow, 0)
    unitTest:assert_equal(cs.maxRow, 5256116)

    unitTest:assert_equal(cs.minCol, 0)
    unitTest:assert_equal(cs.maxCol, 5380443)
    --for i = 1, cs:size(), 1 do print(cs.cells[i].NOME_UF) end

    forEachCell(cs,function(cell)
        print("estado: "..cell.NOME_UF.."("..cell.SIGLA..")")
        print("pos: "..cell.x..", "..cell.y)
        print("\n")
    end)
    
    local POPUL_before = {}
    
    local valuesDefault = {
        500000,
        2300000,
        1300000,
        300000,
        2300000,
        1900000,
        9600000,
        300000,
        4800000,
        8700000,
        1000000,
        1700000,
        4300000,
        5400000,
        33700000,
        16500000,
        13300000,
        2700000,
        5200000,
        2800000,
        6700000,
        12600000,
        7400000,
        1600000,
        3300000,
        2700000,
        2600000
    }
    
    print("population values loaded:")

    for i = 1, 27, 1 do
        print(cs.cells[i].POPUL)
        POPUL_before[i] = cs.cells[i].POPUL
    end

    for i = 1, 27, 1 do
        cs.cells[i].POPUL = 10
    end

    cs:save()

    print("population values saved:")

    for i = 1, 27, 1 do
        print(cs.cells[i].POPUL)
    end

    for i = 1, 27, 1 do
        cs.cells[i].POPUL = POPUL_before[i]
    end

    print("population values restored:")

    for i = 1, 27, 1 do
        unitTest:assert_equal(cs.cells[i].POPUL, valuesDefault[i])
        print(t.cells[i].POPUL)
    end

    cs:save()
    
  end
}

gisTest.skips = {"test_LoadTerraLibGPM","test_LoadNeighborhoodFromGALFile"}
gisTest:run()
