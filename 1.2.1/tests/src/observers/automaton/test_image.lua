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

imageFor = function (killObserver)
	for i=1, 10 , 1 do
		print("STEP: ", i) io.flush()
		cs:notify()
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerImage05) and (i == 8)) then 
			print("", "observerImage05:kill", observerImage05:kill())
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

local observersImageTest = UnitTest {
	test_image01 = function(x)
		-- OBSERVER IMAGE 01 
		print("OBSERVER IMAGE 01 ") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map")
		observerImage01 = Observer{ subject = at1, type = "image" }
    imageFor(false)
	end,

	test_image02 = function(x)
		-- OBSERVER IMAGE 02 
		print("OBSERVER IMAGE 02 ") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map",{"currentState"})
		observerImage02 = Observer{ subject = at1, type = "image", attributes={"currentState"}}
    imageFor(false)
	end,

	test_image03 = function(x)
		-- OBSERVER IMAGE 03 
		print("OBSERVER IMAGE 03 ") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map",{"currentState"},{cs,obs})
		obs = Observer { subject = cs, type = "image", attributes = {"soilWater"}, legends = {soilWaterLeg}}
		observerImage03 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs}
    imageFor(false)
	end,

	test_image04 = function(x)
		-- OBSERVER IMAGE 04 
		print("OBSERVER IMAGE 04") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map", {"currentState"}, {cs, obs, currentStateLeg} )
		obs = Observer { subject = cs, type = "image", attributes = {"soilWater"}, legends = {soilWaterLeg}}
		observerImage04 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs,legends = {currentStateLeg} }
    imageFor(false)
	end,

	test_image05 = function(x)
		-- OBSERVER IMAGE 05 
		print("OBSERVER IMAGE 05") io.flush()
		--@DEPRECATED
		--at1:createObserver( "map", {"currentState"}, {cs, obs, currentStateLeg} )
		obs = Observer { subject = cs, type = "image", attributes = {"soilWater"}, legends = {soilWaterLeg}}		
		observerImage05 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs,legends = {currentStateLeg} }
    imageFor(true)             
	end
}

-- TESTES OBSERVER IMAGE
--[[
IMAGE 01
Programa apresentará um erro, pois o 'observers' deve ter exatamente um ou dois atributos, no caso não tem nenhum atributo.

IMAGE 02
Prorgama apresentará um erro, porque no parâmetro 'observer' não foi achado.

IMAGE 03
Idem IMAGE 02.

IMAGE 04
Idem IMAGE 02.

IMAGE 05
Idem IMAGE 02.
]]

observersImageTest:run()
os.exit(0)
