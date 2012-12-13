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

graphicFor = function(killObserver)
	for i=1, 10, 1 do
		print("STEP: ", i) io.flush()
		at1.curve=i%3
		cs:notify(i)
		at1:notify(i)
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			--at1.acum = math.cos(i*3.14/2)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerGraphic06) and (i == 8)) then
			print("", "observerGraphic06:kill", observerGraphic06:kill())
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

local observersChartTest = UnitTest {
	test_dynamicGraph01 = function(x)
		-- OBSERVER DYNAMIC GRAPHIC 01
		print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {},{})
		observerDynamicGraphic01 = Observer{ subject = at1, type = "chart",attributes={}}
    graphicFor(false)
	end,

	test_dynamicGraph02 = function(x)
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{})
		observerDynamicGraphic02 = Observer{ subject = at1, type = "chart",attributes={"currentState"} }
    graphicFor(false)
	end,

	test_dynamicGraph03 = function(x)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{})
		observerDynamicGraphic03 = Observer{ subject = at1, type = "chart", location=cell, attributes={"currentState"} }
    graphicFor(false)
	end,

	test_dynamicGraph04 = function(x)
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{cell, "titulo","curva","x eixo","y eixo"} )
		observerDynamicGraphic04 = Observer{ subject = at1, type = "chart",attributes={"currentState"},location=cell, title = "titulo", curveLabels={"curva"}, yLabel = "- currentState -" }
    graphicFor(false)
	end,
	test_dynamicGraph05 = function(x)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{cell, "titulo","curva","x eixo","y eixo"} )
		observerDynamicGraphic05 = Observer{ subject = at1, type = "chart",attributes={"currentState","curve"},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
    graphicFor(false)
	end,

	test_dynamicGraph06 = function(x)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
		--@DEPRECATED
		observerDynamicGraphic06 = Observer{ subject = at1, type = "chart",attributes={"currentState","curve"},legends={currentStateLeg,curveLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
    graphicFor(false)
	end,
	test_dynamicGraph07 = function(x)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{cell, "titulo","curva","x eixo","y eixo"} )
		observerDynamicGraphic07 = Observer{ subject = at1, type = "chart",attributes={"currentState","curve"},legends={currentStateLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
    graphicFor(false)
	end,
	test_dynamicGraph08 = function(x)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 08
		print("OBSERVER DYNAMIC GRAPHIC 08") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{cell, "titulo","curva","x eixo","y eixo"} )
		observerDynamicGraphic08 = Observer{ subject = at1, type = "chart",attributes={"curve","currentState"},legends={curveLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
    graphicFor(false)
	end,

	test_graph01 = function(x)
		-- OBSERVER GRAPHIC 01
		print("OBSERVER GRAPHIC 01") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState","acum"},{cell})
		observerGraphic01 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum",location=cell}
    graphicFor(false)
	end,

	test_graph02 = function(x)
		-- OBSERVER GRAPHIC 02
		print("OBSERVER GRAPHIC 02") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState","acum"}, {cell,"GraphicTitle"})	 	
		observerGraphic02 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", location=cell}
    graphicFor(false)
	end,

	test_graph03 = function(x)
		-- OBSERVER GRAPHIC 03
		print("OBSERVER GRAPHIC 03") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle"}) 	
		observerGraphic03 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle",curveLabels={"CurveTitle"}, location=cell}
    graphicFor(false)
	end,

	test_graph04 = function(x)
		-- OBSERVER GRAPHIC 04
		print("OBSERVER GRAPHIC 04") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel"})
		observerGraphic04 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", location=cell}
    graphicFor(false)
	end,
	test_graph05 = function(x)
		-- OBSERVER GRAPHIC 05
		print("OBSERVER GRAPHIC 05") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic05 = Observer{ subject = at1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={" CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(false)
	end,
	test_graph06 = function(x)
		-- OBSERVER GRAPHIC 06
		print("OBSERVER GRAPHIC 06") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic06 = Observer{ subject = at1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={" CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(true)
	end,
	test_graph07 = function(x)--28/08
		-- OBSERVER GRAPHIC 07
		print("OBSERVER GRAPHIC 07") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic07 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(false)
	end,
	test_graph08 = function(x)--28/08
		-- OBSERVER GRAPHIC 08
		print("OBSERVER GRAPHIC 08") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic08 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(false)
	end,
	test_graph09 = function(x)--28/08
		-- OBSERVER GRAPHIC 09
		print("OBSERVER GRAPHIC 09") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic09 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, legends={curveLeg,currentStateLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(false)
	end,
	test_graph10 = function(x)--28/08
		-- OBSERVER GRAPHIC 10
		print("OBSERVER GRAPHIC 10") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic10 = Observer{ subject = at1, type="chart", attributes={"currentState","curve"}, legends={currentStateLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(false)
	end,
	test_graph11 = function(x)--28/08
		-- OBSERVER GRAPHIC 11
		print("OBSERVER GRAPHIC 11") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
		observerGraphic11 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, legends={curveLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
    graphicFor(false)
	end
}

observersChartTest:run()
os.exit(0)
