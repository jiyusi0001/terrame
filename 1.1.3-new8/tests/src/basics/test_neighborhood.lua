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
-- Expected result: 1 teste, 37 assertations, (1 passed, 0 failed, 0 erros)
-- 
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_NeighborhoodType()
	
	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end
	print("Testing Neighborhood...")io.flush()

	
	cs = CellularSpace{
		xdim=10
	}
	assert_not_nil(cs)
	
	n1=Neighborhood()
	assert_not_nil(n1)
	
	--print("\nADDCELL:") io.flush()
	--print(n1:size())
	assert_equal(0, n1:size() )
	
	-- --n1:addCell(cs.cells[1], cs) -- does not work
	n1:addCell(Coord{x=0, y=0}, cs, 0.5)
	--print(n1:size()) io.flush()
	assert_equal(1, n1:size() )
	
	-- --n1:addCell(cs.cells[2], cs) -- does not work
	n1:addCell(Coord{x=0, y=1}, cs, 0.5)
	--print(n1:size())  io.flush()
	assert_equal(2, n1:size() )
	
	--if not n1:isEmpty() then print("NOT EMPTY")  io.flush() end
	assert_false(n1:isEmpty())
	
	--print("CLEAR")  io.flush() 
	n1:clear()
	--if n1:isEmpty() then print("EMPTY")  io.flush()  end
	assert_true(n1:isEmpty())
	
	--print(n1:size())
	assert_equal(0, n1:size())
	
	n1:addCell(Coord{x=0, y=0}, cs, 1.5)
	--print(n1:size())
	-- --n1:addCell(cs.cells[2], cs) -- does not work
	n1:addCell(Coord{x=0, y=1}, cs, 0.5)
	--print(n1:size())
	assert_equal(2,n1:size())
	
	--print("\nERASING")
	n1:eraseCell(Coord{x=0, y=0})
	--print(n1:size())
	assert_equal(1, n1:size())
	
	-- --n1:addCell(cs.cells[2], cs) -- does not work
	n1:eraseCell(Coord{x=0, y=1})
	--print(n1:size())
	assert_equal(0, n1:size())
	
	n1:addCell(Coord{x=0, y=0}, cs, 1.5)
	n1:addCell(Coord{x=0, y=1}, cs, 0.5)
	assert_equal(2, n1:size())
	
	--print("GETID: "..n1:getID())
	assert_equal("", n1:getID()) -- melhorar: deveria ser "1" por default
	cs.cells[3]:addNeighborhood(n1, "test")
	--print("GETID: "..n1:getID())
	assert_equal("test", n1:getID())
	cs.cells[4]:addNeighborhood(n1, "myTest")
	--print("GETID: "..n1:getID())
	assert_equal("myTest", n1:getID())
	
	
	--if not n1:isFirst() then print "NOT IS FIRST" end
	assert_false(n1:isFirst())
	--if n1:isLast() then print "IS LAST" end
	assert_true(n1:isLast())
	
	--print("WEIGHT: "..n1:getWeight())
	assert_number(n1:getWeight())
	
	n1:first()
	--if n1:isFirst() then print "IS FIRST" end
	assert_true(n1:isFirst())
	
	--print("WEIGHT: "..n1:getWeight())
	assert_number(n1:getWeight())
	
	--if n1:getNeighbor() == cs.cells[1] then print "EQUAL CELL"   end
	assert_equal(n1:getNeighbor(), cs.cells[1])
	
	--if n1:getWeight()   == 1.5         then print "EQUAL WEIGHT" end
	assert_equal(1.5, n1:getWeight())
	
	n1:setWeight(0.7)
	--if n1:getWeight()   == 0.7         then print "EQUAL WEIGHT" end
	assert_equal(0.7, n1:getWeight())
	
	--print(n1:getCoord())
	x,y = n1:getCoord()
	assert_equal(0, x)
	assert_equal(0,y)
	
	n1:next()
	--print(n1:getCoord())
	x,y = n1:getCoord()
	assert_equal(1, x)
	assert_equal(0,y)
	
	
	--print("WEIGHT: "..n1:getWeight())
	assert_equal(0.5, n1:getWeight())
	
	--if not n1:isLast() then print "IS NOT LAST" end
	assert_false(n1:isLast())
	
	n1:next()
	--if n1:isLast() then print "IS LAST" end
	assert_true(n1:isLast())
	
	n1:first()
	--if not n1:isLast() then print "IS NOT LAST" end
	assert_false( n1:isLast())
	
	n1:last()
	--if n1:isLast() then print "IS LAST" end
	assert_true( n1:isLast())
	--print("WEIGHT: "..n1:getWeight())
	assert_number( n1:getWeight())
	
	--print(n1:getCellNeighbor(Coord{x=0, y=0}).x)
	assert_equal(0, n1:getCellNeighbor(Coord{x=0, y=0}).x)
	
	--print(n1:getCellWeight(Coord{x=0, y=0}))
	assert_equal(0.7, n1:getCellWeight(Coord{x=0, y=0}))
	
	n1:setCellWeight(Coord{x=0, y=0}, 0.2)
	--print(n1:getCellWeight(Coord{x=0, y=0}))
	assert_equal(0.2, n1:getCellWeight(Coord{x=0, y=0}))
	

	print("READY!!")
	assert_true(true)
end

functionList = {
    [1] = "test_NeighborhoodType"
}

SKIPS = executeBasics("neighborhood", functionList, skips)

lunatest.run()

os.exit(0)
