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
-- Expected result: 1 teste, 259 assertations, (1 passed, 0 failed, 0 erros)
-- 

dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

local trajectoryTest = UnitTest {
	test_TrajectoryType = function(unitTest) 

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
		cs = CellularSpace{
			xdim = 10
		}

		cs:load()

		--print("Size: ", cs:size())
		unitTest:assert_equal( 100, cs:size())

		local cont = 0
		forEachCell(cs, function(cell)
			cont = cont + 1
			unitTest:assert_equal("Cell",type(cell))
		end)
		--print("Count:", cont) io.flush()
		unitTest:assert_equal(100, cont)

		it = Trajectory{
			target = cs
		}

		cont = 0
		unitTest:assert_equal(100, it:size())
		forEachCell(it, function(cell)
			cont = cont + 1
			unitTest:assert_equal("Cell",type(cell))
		end)
		unitTest:assert_equal(100, cont)


		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
		print("Testing Trajectory...") io.flush()

		t = Trajectory{
			target = cs,
			select = function(c)
				--print(c) io.flush()
				if c.x > 7 and c.y > 5 then return true end
			end,
			greater = function(a, b)
				return a.y > b.y
			end
		}

		cont = 0
		orderMemory = 10

		print("------------------------------------")
		forEachCell(t, function(cell)
			cont = cont + 1
			--print("fec", cell.x.." "..cell.y)
			assert("Cell",type(cell))--******************************
			unitTest:assert_gt(cell.x, 7)
			unitTest:assert_gt(cell.y, 5)
			--print(cell.y <= orderMemory)
			unitTest:assert_true(cell.y <= orderMemory)
			orderMemory = cell.y 
		end)
		--print("Count:", cont) io.flush()
		unitTest:assert_equal(8, cont)

		t:randomize()
		print("RANDOMISE")

		forEachCell(t, function(cell)
		--print(cell.x.." "..cell.y)
		end)
		print("not tested :-(")


		--print("SIZE: "..t:size())
		unitTest:assert_equal(8, t:size())

		t:filter(function(c)
			if c.x < 9 and c.x > 7 and c.y > 5 then return true end
		end)

		forEachCell(t, function(cell)
			--print(cell.x) io.flush()
			unitTest:assert_lt( cell.x, 9 )
			unitTest:assert_gt( cell.x ,7 )
			unitTest:assert_gt( cell.y, 5 )
		end)
		--print("SIZE: "..t:size()) io.flush()
		unitTest:assert_equal(4, t:size())

		print("SORT:")
		t:sort(function(a, b)
			return a.y > b.y
		end)
		orderMemory = 10
		forEachCell(t, function(cell)
			--print(cell.y)
			--print(cell.y < orderMemory)
			unitTest:assert_true(cell.y < orderMemory)
			orderMemory = cell.y
		end)

		xMemory = 10
		yMemory = 10
		cont = 0
		print("SORT COORD:")
		t:sort(greaterByCoord("<"))
		forEachCell(t, function(cell)
			--print("x: ", cell.x, xMemory) io.flush()
			unitTest:assert_lte(cell.x, xMemory)
			--print("y: ", cell.y, yMemory) io.flush()
			if( cell.x == xMemory) then
				unitTest:assert_gte(cell.y,yMemory)
			end
			xMemory = cell.x
			yMemory = cell.y
			cont = cont + 1
		end)
		unitTest:assert_equal(4, cont)

		--[[
		--@RODRIGO
		xMemory = 10
		yMemory = 10
		cont = 0	
		print("SORT ATTRIB:")
		t:sort(greaterByAttribute("x","<"))
		forEachCell(t, function(cell)
		--print("x: ", cell.x, xMemory) io.flush()
		assert_lte(xMemory, cell.x)
		xMemory = cell.x
		cont = cont + 1		
		end)
		assert_equal(4, cont)
		--]]

		cont = 0
		print("REFRESH:")
		t:rebuild()
		forEachCell(t, function(cell)
			--print(cell.x.."  "..cell.y)
			cont = cont + 1
		end)
		unitTest:assert_equal(4, cont)


		print("GET CELL:")
		c = Coord{x=8, y=9}
		--print(t:getCell(c).x)
		unitTest:assert_equal(8, t:getCell(c).x)


		c = Coord{x=8, y=6}
		--print(t:getCell(c).y)
		unitTest:assert_equal(6, t:getCell(c).y)

		print("READY!!!")
		unitTest:assert_true(true)

	end,

	test_TrajectoryInAnotherTrajectory = function(unitTest)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()

		cellSpace = CellularSpace{
			xdim = 5
		}

		cont = 0

		forEachCell(cellSpace, function(cell)
			cell.value = cont
			cont = cont + 1
		end)

		trajectoryMain = Trajectory{
			target = cellSpace,
			select = function(cell)
				return cell.value % 5 == 0
			end,
			greater = function(a,b)
				return a.value <= b.value
			end
		}

		cellSpaceInner = CellularSpace{
			xdim = 0
		}

		for i=1, #trajectoryMain.cells, 1 do
			cellSpaceInner:add(trajectoryMain.cells[i])
		end

		trajectoryMain.trajectoryInner = Trajectory{
			target = cellSpaceInner,
			select = function(cell)
				return cell.value % 2 == 0
			end,
			greater = function(a,b)
				return a.value > b.value
			end
		}
		print("Trajectory in another Trajectory:")

		forEachCell(trajectoryMain.trajectoryInner,function(cell)
			print(cell.value)
		end)

		resultMain = {0,5,10,15,20}
		resultInner = {20,10,0}

		cont=1
		forEachCell(trajectoryMain.trajectoryInner,function(cell)
			unitTest:assert_equal(cell.value,resultInner[cont])
			cont = cont+1
		end)

	end,

	test_readOnlyFunctions = function(unitTest) 

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()

		cs = CellularSpace{
			xdim = 5,
		}

		cont = 0

		forEachCell(cs, function(cell)
			cell.value = cont
			cont = cont + 1
		end)

		g = function(a, b)
			return a.value > b.value
		end

		s = function(cell)
			return cell.value > 5
		end

		tr = Trajectory{
			target = cs,
			greater = g,
			select = s
		}

		tr:rebuild()

		unitTest:assert_equal(tr.parent,cs)
		unitTest:assert_equal(tr.select,s)
		unitTest:assert_equal(tr.greater,g)

	end
}

trajectoryTest:run()
