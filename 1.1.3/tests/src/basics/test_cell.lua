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
-- Expected result: 2 teste, 25 assertations, (2 passed, 0 failed, 0 erros)
-- 
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_CellsAttributesAndPast()

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--="); io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end
	print("\nTesting CellsAttributesAndPast...")

	cell = Cell{
		cover = "forest",
		soilWater = 0
	}

	assert_not_nil(cell.past)
	assert_nil( cell.past.cover )

	cell:synchronize()

	--print("CELL:")
	--forEachElement(cell, print)io.flush()
	--print("PAST:")
	--forEachElement(cell:getPast(), print) io.flush()
	assert_not_nil(cell.past)
	assert_equal(cell.past,cell:getPast())
	assert_equal(cell.cover,"forest")
	assert_equal(cell.cover, cell.past.cover)
	assert_nil(cell.past.past)


	print("READY!!!")
	assert_true(true)

end

function test_CellsNeighborhoodAndIterator()

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--="); io.flush()
	if (SKIPS[2]) then
		skip("No testing...") io.flush()
	end
	print("\nTesting test_CellsNeighborhoodAndIterator...")

	-- defines a volatile CellularSpace
	cs = CellularSpace{
		xdim = 100
	}

	n1=Neighborhood()
	n1:addCell(Coord{x=1, y=1}, cs, 0.5)
	n1:addCell(Coord{x=1, y=2}, cs, 0.5)

	n2=Neighborhood()
	--print("TYPE: "..type(n2)) io.flush() -- TYPE: table
	n2:addCell(Coord{x=2, y=3}, cs, 0.34)
	n2:addCell(Coord{x=2, y=2}, cs, 0.33)
	n2:addCell(Coord{x=2, y=1}, cs, 0.33)

	cell = Cell{
		cover = "forest",
		soilWater = 0
	}
	assert_equal(0, cell:size())
	--print("Size:"..cell:size()) io.flush()
	cell:addNeighborhood(n1, "1")
	--print("Size:"..cell:size()) io.flush()
	assert_equal(1, cell:size())
	cell:addNeighborhood(n2, 2)
	--print("Size:"..cell:size()) io.flush()
	assert_equal(2, cell:size())

	--print("Neighborhood:") io.flush()
	n = cell:getNeighborhood("1") io.flush()
	--print(n:size()) io.flush()
	--print(n:getID()) io.flush()
	--print(type(n:getID())) io.flush()
	--print("End Neighborhood") io.flush()
	assert_equal(2, n:size())
	assert_equal("1", n:getID())
	assert_string(n:getID())

	--print("Neighborhood:") io.flush()
	n = cell:getNeighborhood(2) 
	--print(n:size()) io.flush()
	--print(n:getID()) io.flush()
	--print(type(n:getID())) io.flush()
	--print("End Neighborhood") io.flush()
	assert_equal(3, n:size())
	assert_equal("2", n:getID())
	assert_string(n:getID())

	-- Test iterator
	cell:first()
	--if cell:isFirst() then print "IS FIRST"  io.flush() end
	assert_equal(true, cell:isFirst())

	--print("ID: "..cell:getCurrentNeighborhood():getID())
	--if cell:getCurrentNeighborhood() == n1 then print "EQUAL TO N1"  io.flush() end
	--print("TYPE: "..type(cell:getCurrentNeighborhood())) io.flush()
	assert_equal(n1, cell:getCurrentNeighborhood())
	assert_equal("1", cell:getCurrentNeighborhood():getID())

	cell:next()

	--print("ID: "..cell:getCurrentNeighborhood():getID())
	--if cell:getCurrentNeighborhood() == n2 then print "EQUAL TO N2"   io.flush() end
	assert_equal(n2, cell:getCurrentNeighborhood())
	assert_equal("2", cell:getCurrentNeighborhood():getID())


	cell:next()
	--if cell:isLast() then print "IS LAST" io.flush() end
	assert_equal(true, cell:isLast())

	cell:first()
	cell:last()
	--if cell:isLast() then print "IS LAST" io.flush() end
	--print("TYPE: "..type(cell:getCurrentNeighborhood())) io.flush()
	assert_equal(true, cell:isLast())


	print("READY!!!")
	assert_true(true)

end

function test_CellGetAgent()
    print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--="); io.flush()
	if (SKIPS[3]) then
		skip("No testing...") io.flush()
	end
	state1 = State {
	    id = "walking",
		Jump {
			function( event, agent, cell )

				print(agent:getStateName());
				print(agent.energy)
				agent.energy= agent.energy - 1
				hungry = agent.energy == 0
				ag1.counter = ag1.counter + 10;
				--ag1:notify(ag1.time);

				if (hungry) then
					--agent.energy = agent.energy + 30
					return true
				end
				return false
			end,
			target = "sleeping"
		}
	}

	state2 = State {
		id = "sleeping",
		Jump {
			function( event, agent, cell )
				agent.energy = agent.energy + 1
				print(agent:getStateName());
				hungry = ag1.energy>0
				ag1.counter = ag1.counter + 10;
				--ag1:notify(ag1.time);

				if (not hungry)or( ag1.energy >=5) then
					return true
				end
				return false
			end,
			target = "walking"
		}
	}

	ag1 = Agent{
		id = "Ag1",
		energy  = 5,
		hungry = false,
		counter = 0,
		st1=state1,
		st2=state2
	}
    ag2 = Agent{
		id = "Ag2",
		energy  = 5,
		hungry = false,
		counter = 0,
		st1=state1,
		st2=state2
	}

    cs = CellularSpace{ xdim = 3}

	local myEnv = Environment {
		id = "MyEnvironment",
		cs,
		ag1
	}
	myEnv:createPlacement{strategy = "void"}

    c = cs.cells[1]
    ag1:enter(c)
    ag2:enter(c)
    assert_equal(type(c:getAgent()),"Agent")
    assert_equal(type(c:getAgents()),"table")
    
end

skips = {

}

functionList = {
	[1] = "test_CellsAttributesAndPast",
	[2] = "test_CellsNeighborhoodAndIterator",
    [3] = "test_CellGetAgent"
}

SKIPS = executeBasics("cell", functionList, skips)

lunatest.run()

os.exit(0)
