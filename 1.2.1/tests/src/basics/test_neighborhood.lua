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
-- Expected result: 1 teste, 37 assertations, (1 passed, 0 failed, 0 erros)
-- 

dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

local neighborhoodTest = UnitTest {
	test_NeighborhoodType = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
		print("Testing Neighborhood...")io.flush()


		cs = CellularSpace{
			xdim=10
		}
		self:assert_not_nil(cs)

		n1=Neighborhood()
		self:assert_not_nil(n1)

		--print("\nADDCELL:") io.flush()
		--print(n1:size())
		self:assert_equal(0, n1:size() )

		-- --n1:addCell(cs.cells[1], cs) -- does not work
		n1:addCell(Coord{x=0, y=0}, cs, 0.5)
		--print(n1:size()) io.flush()
		self:assert_equal(1, n1:size() )

		-- --n1:addCell(cs.cells[2], cs) -- does not work
		n1:addCell(Coord{x=0, y=1}, cs, 0.5)
		--print(n1:size())  io.flush()
		self:assert_equal(2, n1:size() )

		--if not n1:isEmpty() then print("NOT EMPTY")  io.flush() end
		self:assert_false(n1:isEmpty())

		--print("CLEAR")  io.flush() 
		n1:clear()
		--if n1:isEmpty() then print("EMPTY")  io.flush()  end
		self:assert_true(n1:isEmpty())

		--print(n1:size())
		self:assert_equal(0, n1:size())

		n1:addCell(Coord{x=0, y=0}, cs, 1.5)
		--print(n1:size())
		-- --n1:addCell(cs.cells[2], cs) -- does not work
		n1:addCell(Coord{x=0, y=1}, cs, 0.5)
		--print(n1:size())
		self:assert_equal(2,n1:size())

		--print("\nERASING")
		n1:eraseCell(Coord{x=0, y=0})
		--print(n1:size())
		self:assert_equal(1, n1:size())

		-- --n1:addCell(cs.cells[2], cs) -- does not work
		n1:eraseCell(Coord{x=0, y=1})
		--print(n1:size())
		self:assert_equal(0, n1:size())

		n1:addCell(Coord{x=0, y=0}, cs, 1.5)
		n1:addCell(Coord{x=0, y=1}, cs, 0.5)
		self:assert_equal(2, n1:size())

		--print("GETID: "..n1:getID())
		self:assert_equal("", n1:getID()) -- melhorar: deveria ser "1" por default
		cs.cells[3]:addNeighborhood(n1, "test")
		--print("GETID: "..n1:getID())
		self:assert_equal("test", n1:getID())
		cs.cells[4]:addNeighborhood(n1, "myTest")
		--print("GETID: "..n1:getID())
		self:assert_equal("myTest", n1:getID())


		--if not n1:isFirst() then print "NOT IS FIRST" end
		self:assert_false(n1:isFirst())
		--if n1:isLast() then print "IS LAST" end
		self:assert_true(n1:isLast())

		--print("WEIGHT: "..n1:getWeight())
		self:assert_number(n1:getWeight())

		n1:first()
		--if n1:isFirst() then print "IS FIRST" end
		self:assert_true(n1:isFirst())

		--print("WEIGHT: "..n1:getWeight())
		self:assert_number(n1:getWeight())

		--if n1:getNeighbor() == cs.cells[1] then print "EQUAL CELL"   end
		self:assert_equal(n1:getNeighbor(), cs.cells[1])

		--if n1:getWeight()   == 1.5         then print "EQUAL WEIGHT" end
		self:assert_equal(1.5, n1:getWeight())

		n1:setWeight(0.7)
		--if n1:getWeight()   == 0.7         then print "EQUAL WEIGHT" end
		self:assert_equal(0.7, n1:getWeight())

		--print(n1:getCoord())
		x,y = n1:getCoord()
		self:assert_equal(0, x)
		self:assert_equal(0,y)

		n1:next()
		--print(n1:getCoord())
		x,y = n1:getCoord()
		self:assert_equal(1, x)
		self:assert_equal(0,y)


		--print("WEIGHT: "..n1:getWeight())
		self:assert_equal(0.5, n1:getWeight())

		--if not n1:isLast() then print "IS NOT LAST" end
		self:assert_false(n1:isLast())

		n1:next()
		--if n1:isLast() then print "IS LAST" end
		self:assert_true(n1:isLast())

		n1:first()
		--if not n1:isLast() then print "IS NOT LAST" end
		self:assert_false( n1:isLast())

		n1:last()
		--if n1:isLast() then print "IS LAST" end
		self:assert_true( n1:isLast())
		--print("WEIGHT: "..n1:getWeight())
		self:assert_number( n1:getWeight())

		--print(n1:getCellNeighbor(Coord{x=0, y=0}).x)
		self:assert_equal(0, n1:getCellNeighbor(Coord{x=0, y=0}).x)

		--print(n1:getCellWeight(Coord{x=0, y=0}))
		self:assert_equal(0.7, n1:getCellWeight(Coord{x=0, y=0}))

		n1:setCellWeight(Coord{x=0, y=0}, 0.2)
		--print(n1:getCellWeight(Coord{x=0, y=0}))
		self:assert_equal(0.2, n1:getCellWeight(Coord{x=0, y=0}))


		print("READY!!")
		self:assert_true(true)
	end,

	-- RAIAN: Tests for the Dynamic Neighborhoods structures
	test_DynamicNeighborhoods = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
		print("Testing Dynamic Neighborhoods...")io.flush()


		cs = CellularSpace{
			xdim=10
		}
		self:assert_not_nil(cs)

		cs:createNeighborhood{
			strategy = "moore",
			name = "moore",
			self = false
		}

		local cell = cs:getCell(Coord{x = 5, y = 5})
		local neighborhood = cell:getNeighborhood("moore")

		self:assert_equal(8, neighborhood:size())
		self:assert_false(neighborhood:isNeighbor(cell))

		local neighT = neighborhood:sample()
		self:assert_true(neighborhood:isNeighbor(neighT))

		local sumWeight = 0

		forEachNeighbor(
		cell, 
		"moore",
		function(c, neigh, weight)
			self:assert_true(neighborhood:isNeighbor(neigh))

			self:assert_equal(0.125, neighborhood:getNeighWeight(neigh))

			sumWeight = sumWeight + weight
		end
		)

		self:assert_equal(1, sumWeight)

		sumWeight = 0

		forEachNeighbor(
		cell, 
		"moore", 
		function(c, neigh, weight)
			neighborhood:setNeighWeight(neigh, 8)
			weight = neighborhood:getNeighWeight(neigh)

			self:assert_equal(8, weight)
			sumWeight = sumWeight + weight
		end
		)

		self:assert_equal(64, sumWeight)

		neighT = cs:getCell(Coord{x = 1, y = 1})
		neighborhood:addNeighbor(neighT, 10)
		sumWeight = sumWeight + neighborhood:getNeighWeight(neighT)

		self:assert_true(neighborhood:isNeighbor(neighT))
		self:assert_equal(9, neighborhood:size())
		self:assert_equal(74, sumWeight)

		neighborhood:eraseNeighbor(neighT)

		self:assert_false(neighborhood:isNeighbor(neighT))

		sumWeight = 0
		forEachNeighbor(
		cell,
		"moore",
		function(c, neigh, weight)
			sumWeight = sumWeight + weight
		end
		)

		self:assert_equal(64, sumWeight)

		filterFunc = function(n) return n.x == cell.x end
		weightFunc = function(n) return n.x + cell.x end
		neighborhood:reconfigure(cs, filterFunc, weightFunc)

		sumWeight = 0

		forEachNeighbor(
		cell, 
		"moore",
		function(c, neigh, weight)
			self:assert_equal(neigh.x, c.x)
			self:assert_equal(neigh.x + cell.x, weight)

			sumWeight = sumWeight + weight
		end
		)

		self:assert_equal(100, sumWeight)
		self:assert_equal(10, neighborhood:size())
	end
}
neighborhoodTest.skipped = {"test1"}
neighborhoodTest:run()

os.exit(0)
