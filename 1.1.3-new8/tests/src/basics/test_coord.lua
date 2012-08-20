-- (C) 2010 INPE AND UFOP
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
-- Expected result: 1 teste, 13 assertations, (1 passed, 0 failed, 0 erros)
-- 
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_CoordType()

    print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end

	--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=
	print("\nTesting CoordType...")
	--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=
	
	coord1 = Coord()
	--table.foreach(coord1:get(), print)
	--print("")
	assert_equal(0,coord1:get().x)	
	assert_equal(0,coord1:get().y)
	assert_nil(coord1.x)-- to read Coord attributes, use Coord::get()
	assert_nil(coord1.y) -- to write Coord attributes, use Coord::set({x = 0, y = 0})
	
	-- test the Coord type
	c = Coord{x=0, y=99}
	cOut = c:get()
	--print("COORD:",cOut.x, cOut.y) io.flush()
	--print("COORD:",c.x, c.y) io.flush() -- to read Coord attributes, use Coord::get()
	assert_equal(0, cOut.x)
	assert_equal(99,cOut.y)
	assert_equal(nil, c.x)
	assert_equal(nil, c.y)
	c.x = 10; c.y = 10;
	cOut = c:get()
	--print("COORD:",cOut.x, cOut.y) io.flush() -- to write Coord attributes, use Coord::set({x = 0, y = 0})
	assert_equal( cOut.x, 0)
	assert_equal( cOut.y, 99) 
	c:set({ x=10, y=10 })
	cOut = c:get()
	--print("COORD:",cOut.x, cOut.y) io.flush() -- to write Coord attributes, use Coord::set({x = 0, y = 0})
	assert_equal( 10, cOut.x)
	assert_equal( 10, cOut.y) 

	print("READY")
	assert_true(true)	

end

functionList = {
    [1] = "test_CoordType"
}

SKIPS = executeBasics("coord", functionList, skips)

lunatest.run()

os.exit(0)
