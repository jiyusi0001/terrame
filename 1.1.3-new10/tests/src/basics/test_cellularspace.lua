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
-- Expected result: 3 teste, 40025 assertations, (3 passed, 0 failed, 0 erros)
-- 
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_VolatileCellularSpaceCoordinatesSystem()

	--skip("")

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end
	print("\nTesting VolatileCellularSpaceCoordinatesSystem...")
	--print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")

	-- defines a volatile CellularSpace
	cs = CellularSpace{
		xdim = 100
	}

	-- resets the volatile cellular space
	cs:load()

	-- VOLATILE: Tests coordinates conversion functions
	x, y = index2coord(1, cs.maxCol)
	idx = coord2index( x, y, cs.maxCol)
	--print(x, y, idx)
	assert_equal(0,x)
	assert_equal(0,y)
	assert_equal(1,idx)

	x, y = index2coord(2, cs.maxCol)
	idx = coord2index( x, y, cs.maxCol)
	--print(x, y, idx)
	assert_equal(0,x)
	assert_equal(1,y)
	assert_equal(2,idx)

	x, y = index2coord(99, cs.maxCol)
	idx = coord2index( x, y, cs.maxCol)
	--print(x, y, idx)
	assert_equal(0,x)
	assert_equal(98,y)
	assert_equal(99,idx)

	x, y = index2coord(100, cs.maxCol)
	idx = coord2index( x, y, cs.maxCol)
	--print(x, y, idx)
	assert_equal(0,x)
	assert_equal(99,y)
	assert_equal(100,idx)


	-- test CellularSpace::getCell()
	c = Coord{x=0,y=99}
	--print( cs.cells[idx].x, cs.cells[idx].y) io.flush()
	cIdx1 = coord2index(cs.cells[idx].x, cs.cells[idx].y, cs.maxCol ) 
	cIdx2 = coord2index(cs:getCell(c).x, cs:getCell(c).y, cs.maxCol ) 
	--print( cIdx1, cIdx2) io.flush()
	--print(cIdx1 == cIdx2) io.flush()
	assert_equal( cIdx1, cIdx2 )
	--if cs:getCell(c) == cs.cells[100] then print "EQUAL" io.flush() end
	assert_equal(cs:getCell(c), cs.cells[idx])

	-- Test cell new attributes
	cs:getCell(c).newAttribute = 3
	--print(cs.cells[100].newAttribute) -- 3
	assert_equal(3, cs.cells[100].newAttribute)

	print("READY")
	assert_true(true)	
end


function test_CellularSpacesPast()


	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[2]) then
		skip("No testing...") io.flush()
	end
	print("\nTesting CellularSpacesPast...")
	--print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")

	-- defines a volatile CellularSpace
	cs = CellularSpace{
		xdim = 100
	}

	forEachCell(cs, function( cell) assert_not_nil(cell) end )
	forEachCell(cs, function( cell) assert_not_nil(cell.past) end )
	forEachCell(cs, function( cell) cell.cover="forest" end )

	print("SYNCHRONIZE") io.flush()
	cs:synchronize()
	forEachCell(cs, function( cell) assert_not_nil(cell.past.cover) end )
	forEachCell(cs, function( cell) assert_equal("forest",cell.past.cover) end )

	--print("PRESENT:")
	forEachElement(cs.cells[1], assert_not_nil)
	--print("\nPAST:")
	forEachElement(cs.cells[1].past, assert_not_nil)

	print("READY!!!")
	assert_true(true)

end


function test_SaveImageFromVolatileCellularSpace()

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[3]) then
		skip("No testing...") io.flush()
	end
	print("-- test_SaveImageFromVolatileCellularSpace");

	-- defines and loads the celular space from a TerraView theme
	cs = CellularSpace{
		xdim = 100
	}

	for t = 1,2 do

		forEachCell( cs,
		function( cell )
			cell.height = t
		end	)


		-- NOTE: It should return a Boolean value indicating the sucess or the fail.
		-- save2PNGc(cs, t, "..\\Results\\Rain\\", "height", {0, 2}, {WHITE, BLUE}, 60)

	end
	print("READY!!! -- Look into the ..\\Results\\Rain\\ filesystem directory!!!")
	assert_true(true)

end

functionList = {
	[1] = "test_SaveImageFromVolatileCellularSpace",
	[2] = "test_CellularSpacesPast",
	[3] = "test_SaveImageFromVolatileCellularSpace"
}

SKIPS = executeBasics("cellular space", functionList, skips)

lunatest.run()

os.exit(0)
