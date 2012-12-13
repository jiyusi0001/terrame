-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
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
-- Author: 	Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
-- 			Rodrigo Reis Pereira
--			Henrique Cota Camêllo
--			Washington Sena França e Silva
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

mapFor = function (killObserver)
	for i=1, 10 , 1 do
		print("STEP: ", i) io.flush()
		cs:notify()
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerMap05) and (i == 8)) then 
			print("", "observerMap05:kill", observerMap05:kill())
		end

		delay_s(1)
	end  
end

MAX_COUNT = 9
cs = CellularSpace{ xdim = 0}
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
	end
end

soilWaterLeg = Legend{
	type = "number",
	grouping = "equalsteps",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 100,
	minimum = 0,
	colorBar = {
		{color = "green", value = 0},
		{color = "blue", value = 100}
	}
}

curveLeg = Legend{
	colorBar = {
		{color = "green", value = 0},
		{color = "blue", value = 100}
	},
	width = 2, -- largura da linha

	--works only with charts observers
	style = "lines",  -- estilo da curva 
	symbol = "rect" -- tipo do simbolo 
}

currentStateLeg = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "brown", value = "seco"},
		{color = "yellow", value = "molhado"}
	},
	width = 2, -- largura da linha

	--works only with charts observers
	style = "lines",  -- estilo da curva 
	symbol = "rect" -- tipo do simbolo 
}

state1 = State{
	id = "seco",
	Jump{
		function( event, agent, cell )
			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end,
		target = "molhado"
	}
}

state2 = State{
	id = "molhado",
	Jump{
		function( event, agent, cell )

			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end, 
		target = "seco"
	}
}

at1 = Automaton{
	id = "MyAutomaton",
	it = Trajectory{
		target = cs, 
		select = function(cell)
			local x = cell.x - 5;
			local y = cell.y - 5;
			return (x*x) + (y*y)  - 16 < 0.1
		end
	},
	acum = 0,
	cont  = 0,
	curve = 0,-- uma curva para o observer chart
	st2 = state2,
	st1 = state1,
}

env = Environment{ 
	id = "MyEnvironment"
}

t = Timer{
	Event{ time = 0, action = function(event) at1:execute(event) return true end }
}
-- insert CellularSpaces before Automata, Agents and Timers
env:add( cs )
env:add( at1 )

ev = Event{ time = 1, period = 1, priority = 1 }

at1:setTrajectoryStatus( true )

-- Enables kill an observer
killObserver = false

middle = math.floor(#cs.cells/2)
cell = cs.cells[middle]

local observersMapTest = UnitTest {
	test_map01 = function(x)
		-- OBSERVER MAP 01 
		print("OBSERVER MAP 01 ") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map")
		observerMap01 = Observer{ subject = at1, type = "map" }
    mapFor(false)
	end,

	test_map02 = function(x)
		-- OBSERVER MAP 02 
		print("OBSERVER MAP 02 ") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map",{"currentState"})
		observerMap02 = Observer{ subject = at1, type = "map", attributes={"currentState"}}
    mapFor(false)
	end,

	test_map03 = function(x)
		-- OBSERVER MAP 03 
		print("OBSERVER MAP 03 ") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map",{"currentState"},{cs,obs})
		observerMap03 = Observer{ subject = at1, type = "map", attributes={"currentState"}, observer = obs}
    mapFor(false)
	end,

	test_map04 = function(x)
		-- OBSERVER MAP 04 
		print("OBSERVER MAP 04") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map", {"currentState"}, {cs, obs, currentStateLeg} )
		observerMap04 = Observer{ subject = at1, type = "map", attributes={"currentState"}, observer = obs,legends = {currentStateLeg} }
    mapFor(false)
	end,

	test_map05 = function(x)
		-- OBSERVER MAP 05 
		print("OBSERVER MAP 05") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map", {"currentState"}, {cs, obs, currentStateLeg} )
		observerMap05 = Observer{ subject = at1, type = "map", attributes={"currentState"}, observer = obs,legends = {currentStateLeg} }
    mapFor(true)             
	end
}

observersMapTest:run()
os.exit(0)
