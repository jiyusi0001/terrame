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

graphicFor = function(killObserver,unitTest)
	for i=1, 10, 1 do
		print("STEP: ", i) io.flush()
		at1.curve=i%3
		cs:notify(i)
		at1:notify(i)
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerGraphic06) and (i == 8)) then
			print("", "observerGraphic06:kill", observerGraphic06:kill())
		end

		delay_s(1)
	end
	unitTest:assert_true(true) 
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
	test_dynamicGraph01 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 01
		print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
		observerDynamicGraphic01 = Observer{ subject = at1, type = "chart",attributes={}}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic01.type)
	end,

	test_dynamicGraph02 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
		observerDynamicGraphic02 = Observer{ subject = at1, type = "chart",attributes={"currentState"} }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic02.type)
	end,

	test_dynamicGraph03 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
		--@DEPRECATED
		--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{})
		observerDynamicGraphic03 = Observer{ subject = at1, type = "chart", location=cell, attributes={"currentState"} }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic03.type)
	end,

	test_dynamicGraph04 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
		observerDynamicGraphic04 = Observer{ subject = at1, type = "chart",attributes={"currentState"},location=cell, title = "titulo", curveLabels={"curva"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic04.type)
	end,
	test_dynamicGraph05 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
		observerDynamicGraphic05 = Observer{ subject = at1, type = "chart",attributes={"currentState","curve"},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic05.type)
	end,

	test_dynamicGraph06 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
		observerDynamicGraphic06 = Observer{ subject = at1, type = "chart",attributes={"currentState","curve"},legends={currentStateLeg,curveLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic06.type)
	end,
	test_dynamicGraph07 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07") io.flush()
		observerDynamicGraphic07 = Observer{ subject = at1, type = "chart",attributes={"currentState","curve"},legends={currentStateLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic07.type)
	end,
	test_dynamicGraph08 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 08
		print("OBSERVER DYNAMIC GRAPHIC 08") io.flush()
		observerDynamicGraphic08 = Observer{ subject = at1, type = "chart",attributes={"curve","currentState"},legends={curveLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic08.type)
	end,

	test_graph01 = function(unitTest)
		-- OBSERVER GRAPHIC 01
		print("OBSERVER GRAPHIC 01") io.flush()
		observerGraphic01 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum",location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic01.type)
	end,

	test_graph02 = function(unitTest)
		-- OBSERVER GRAPHIC 02
		print("OBSERVER GRAPHIC 02") io.flush()
		observerGraphic02 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic02.type)
	end,

	test_graph03 = function(unitTest)
		-- OBSERVER GRAPHIC 03
		print("OBSERVER GRAPHIC 03") io.flush()
		observerGraphic03 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle",curveLabels={"CurveTitle"}, location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic03.type)
	end,

	test_graph04 = function(unitTest)
		-- OBSERVER GRAPHIC 04
		print("OBSERVER GRAPHIC 04") io.flush()
		observerGraphic04 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic04.type)
	end,
	test_graph05 = function(unitTest)
		-- OBSERVER GRAPHIC 05
		print("OBSERVER GRAPHIC 05") io.flush()
		observerGraphic05 = Observer{ subject = at1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={" CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic05.type)
	end,
	test_graph06 = function(unitTest)
		-- OBSERVER GRAPHIC 06
		print("OBSERVER GRAPHIC 06") io.flush()
		observerGraphic06 = Observer{ subject = at1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={" CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(true,unitTest)
        unitTest:assert_equal("chart",observerGraphic06.type)
	end,
	test_graph07 = function(unitTest)
		-- OBSERVER GRAPHIC 07
		print("OBSERVER GRAPHIC 07") io.flush()
		observerGraphic07 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic07.type)
	end,
	test_graph08 = function(unitTest)
		-- OBSERVER GRAPHIC 08
		print("OBSERVER GRAPHIC 08") io.flush()
		observerGraphic08 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic08.type)
	end,
	test_graph09 = function(unitTest)
		-- OBSERVER GRAPHIC 09
		print("OBSERVER GRAPHIC 09") io.flush()
		observerGraphic09 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, legends={curveLeg,currentStateLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic09.type)
	end,
	test_graph10 = function(unitTest)
		-- OBSERVER GRAPHIC 10
		print("OBSERVER GRAPHIC 10") io.flush()
		observerGraphic10 = Observer{ subject = at1, type="chart", attributes={"currentState","curve"}, legends={currentStateLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic10.type)
	end,
	test_graph11 = function(unitTest)
		-- OBSERVER GRAPHIC 11
		print("OBSERVER GRAPHIC 11") io.flush()
		observerGraphic11 = Observer{ subject = at1, type="chart", attributes={"curve","currentState"}, legends={curveLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic11.type)
	end
}

-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
Programa não deverá ser executado, já que o gráfico de 'observers' deverá conter ao menos um atributo, então assim, ocorrerá um erro.

DYNAMIC GRAPHIC 02
Programa não será executado, pois para obsercar um autômato é requerido um parâmetro 'localização' para que seja uma célula, sendo assim ocorrerá um erro.

DYNAMIC GRAPHIC 03
Deverá ser criado um gráfico com título 'Graph Title', com a curva crescendo em relação a 'yLable' e 'time' de acordo com o 'currentState'.

DYNAMIC GRAPHIC 04
Programa cria um gráfico 'Title' cuja curva crescerá de acordo com 'time' no eixo x e 'currentState' no eixo y.

DYNAMIC GRAPHIC 05
Programa deverá apresentar um gráfico 'titutlo' com duas curvas um partindo de '0', de nome 'CurveTitle', e outra partindo de '1', de nome 'CurveTitle2', as duas crescendo em relação ao eixo x 'time' e ao eixo y 'currentState'.

DYNAMIC GRAPHIC 06
Programa deverá criar um gráfico 'titulo' com duas curvas, uma 'CurveTitle' que se apresenta na cor marrom e outra 'CurveTitle2' que se apresenta na cor verde, crescendo em relação ao 'tempo' e ao 'currentState'.

DYNAMIC GRAPHIC 07
Programa apresentará um gráfico 'título' com duas curvas, uma marrom 'CurveTitle' que parte de '0' e outra 'CurveTitle2' que parte de '1', as duas crescem de acordo com o eixo y 'currentState' e eixo y 'time'.


DYNAMIC GRAPHIC 08
Programa apresentará um gráfico 'titulo' com duas curvas de nomes 'CurveTitle' e 'CurveTitle2', sendo essas verde e marrom, respectivamente, a primeira partindo de '1', variando de '0-2' e a segunda partindo de '0', variando de '0-1' em altura.

GRAPHIC 01
Programa apresentará um gráfico 'GraphTitle', com uma curva roxa, partindo de '0', crescendo de acordo com os eixo1 x 'xLabel' e eixo y 'yLabe', variando de '0-1' em altura, e até 5.000 em largura.

GRAPHIC 02
Idem GRAPHIC 01.

GRAPHIC 03
Idem GRAPHIC 01.

GRAPHIC 04
Idem GRAPHIC 01.

GRAPHIC 05
Idem GRAPHIC 01.

GRAPHIC 06
Idem GRAPHIC 01, exceto que em largura varia apenas até 3.000.

GRAPHIC 07
Programa apresentará um gráfico 'GraphTitle' com duas curvas, uma azul partindo de '0' e variando de '0-2' e uma roxa patindo de '1' e variando de '0-1' em altura, até 5.000 em largura.

GRAPHIC 08
Idem GRAPHIC 07.

GRAPHIC 09
Idem GRAPHIC 07.

GRAPHIC 10
Idem GRAPHIC 07, exceto que a curva 2, é marrom.

GRAPHIC 11
Idem GRAPHIC 07, exceto que a curva 1 é verde e a curva 2 é azul.
]]

observersChartTest:run()
os.exit(0)
