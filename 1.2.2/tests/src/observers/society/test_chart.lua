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
		sc1.curve=i+3
		cs:notify(i)
		sc1:notify(i)
		sc1.cont = 0
		sc1:execute(ev)
		if (sc1.cont%2==0) then
			sc1.currentState=sc1.currentState+2
			sc1.cont=sc1.cont+1
		else
			sc1.currentState=sc1.currentState-2
			sc1.cont=sc1.cont+1

		end
		forEachCell(cs, function(cell)
			sc1.acum = math.cos(i*3.14/2)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerGraphic06) and (i == 8)) then
			print("", "observerGraphic06:kill", observerGraphic06:kill())
		end

		delay_s(100000)
	end
	unitTest:assert_true(true) 
end

cs = CellularSpace {
	xdim = 10
}

ev = Event{ time = 1, period = 1, priority = 1 }
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		
		cs:add( c )
	end
end
t = Timer{
	Event{ time = 0, action = function(event) sc1:execute(event) return true end }
}

sleeping = State {
	id = "sleeping",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 0) then
				return true
			end
			return false
		end,
		target = "foraging"
	}
}

foraging = State {
	id = "foraging",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 1) then
				return true
			end
			return false
		end,
		target = "sleeping"
	}
}
boi = function(i)
	ag = {energy = 20, type = "boi", foraging, sleeping}
	ag.getIn = function(ag, cs)
		cell = cs:sample()
		ag:enter(cell)
	end
	ag.class = "Rebanho"
  	ag.testValue = 55
	ag_ = Agent(ag)
	coord = Coord {x=i-1, y=i-1}
	cc = cs:getCell(coord)
	ag_:enter(cc)

	return ag_
end

sc1 = Society {
	instance = boi(1),
	state = "x",
	acum = 0,
	currentState = 0,
	curve=0
}

boi1 = boi(1)
boi2 = boi(2)
boi3 = boi(3)
boi4 = boi(4)
boi5 = boi(5)
boi6 = boi(6)
boi7 = boi(7)
boi8 = boi(8)
boi9 = boi(9)
boi10 = boi(10)

bois = {boi1, boi2, boi3, boi4, boi5, boi6, boi7, boi8, boi9, boi10}

sc1:add(boi1)
sc1:add(boi2)
sc1:add(boi3)
sc1:add(boi4)
sc1:add(boi5)

updateFunc = nil

e = Environment{cs, sc1}
e:createPlacement{strategy = "random"}


local observersChartTest = UnitTest {
	test_dynamicGraph01 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 01
		print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
		observerDynamicGraphic01 = Observer{ subject = sc1, type = "chart",attributes={}}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic01.type)
	end,

	test_dynamicGraph02 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
  	observerDynamicGraphic02 = Observer{ subject = sc1, type = "chart",attributes={"currentState"} }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic02.type)
	end,

	test_dynamicGraph03 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
		observerDynamicGraphic03 = Observer{ subject = sc1, type = "chart", location=cell, attributes={"currentState"} }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic03.type)
	end,

	test_dynamicGraph04 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
		observerDynamicGraphic04 = Observer{ subject = sc1, type = "chart",attributes={"currentState"},location=cell, title = "titulo", curveLabels={"curva"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic04.type)
	end,
	test_dynamicGraph05 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
		observerDynamicGraphic05 = Observer{ subject = sc1, type = "chart",attributes={"currentState","curve"},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic05.type)
	end,

	test_dynamicGraph06 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
		observerDynamicGraphic06 = Observer{ subject = sc1, type = "chart",attributes={"currentState","curve"},legends={currentStateLeg,curveLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic06.type)
	end,

	test_dynamicGraph07 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07") io.flush()
		observerDynamicGraphic07 = Observer{ subject = sc1, type = "chart",attributes={"currentState","curve"},legends={currentStateLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic07.type)
	end,

	test_dynamicGraph08 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 08
		print("OBSERVER DYNAMIC GRAPHIC 08") io.flush()
		observerDynamicGraphic08 = Observer{ subject = sc1, type = "chart",attributes={"curve","currentState"},legends={curveLeg},location=cell, title = "titulo", curveLabels={"CurveTitle","CurveTitle2"}, yLabel = "- currentState -" }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic08.type)
	end,

	test_graph01 = function(unitTest)
		-- OBSERVER GRAPHIC 01
		print("OBSERVER GRAPHIC 01") io.flush()
		observerGraphic01 = Observer{ subject = sc1, type = "chart",attributes={"currentState"}, xAxis="acum",location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic01.type)
	end,

	test_graph02 = function(unitTest)
		-- OBSERVER GRAPHIC 02
		print("OBSERVER GRAPHIC 02") io.flush()
		observerGraphic02 = Observer{ subject = sc1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic02.type)
	end,

	test_graph03 = function(unitTest)
		-- OBSERVER GRAPHIC 03
		print("OBSERVER GRAPHIC 03") io.flush()
		observerGraphic03 = Observer{ subject = sc1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle",curveLabels={"CurveTitle"}, location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic03.type)
	end,

	test_graph04 = function(unitTest)
		-- OBSERVER GRAPHIC 04
		print("OBSERVER GRAPHIC 04") io.flush()
		observerGraphic04 = Observer{ subject = sc1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", location=cell}
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic04.type)
	end,
	test_graph05 = function(unitTest)
		-- OBSERVER GRAPHIC 05
		print("OBSERVER GRAPHIC 05") io.flush()
		observerGraphic05 = Observer{ subject = sc1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={" CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic05.type)
	end,
	test_graph06 = function(unitTest)
		-- OBSERVER GRAPHIC 06
		print("OBSERVER GRAPHIC 06") io.flush()
		observerGraphic06 = Observer{ subject = sc1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={" CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(true,unitTest)
        unitTest:assert_equal("chart",observerGraphic06.type)
	end,
	test_graph07 = function(unitTest)
		-- OBSERVER GRAPHIC 07
		print("OBSERVER GRAPHIC 07") io.flush()
		observerGraphic07 = Observer{ subject = sc1, type="chart", attributes={"curve","currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic07.type)
	end,
	test_graph08 = function(unitTest)
		-- OBSERVER GRAPHIC 08
		print("OBSERVER GRAPHIC 08") io.flush()
		observerGraphic08 = Observer{ subject = sc1, type="chart", attributes={"curve","currentState"}, xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic08.type)
	end,
	test_graph09 = function(unitTest)
		-- OBSERVER GRAPHIC 09
		print("OBSERVER GRAPHIC 09") io.flush()
		observerGraphic09 = Observer{ subject = sc1, type="chart", attributes={"curve","currentState"}, legends={curveLeg,currentStateLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic09.type)
	end,
	test_graph10 = function(unitTest)
		-- OBSERVER GRAPHIC 10
		print("OBSERVER GRAPHIC 10") io.flush()
		observerGraphic10 = Observer{ subject = sc1, type="chart", attributes={"currentState","curve"}, legends={currentStateLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic10.type)
	end,
	test_graph11 = function(unitTest)
		-- OBSERVER GRAPHIC 11
		print("OBSERVER GRAPHIC 11") io.flush()
		observerGraphic11 = Observer{ subject = sc1, type="chart", attributes={"curve","currentState"}, legends={curveLeg},xAxis="acum", title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"}, yLabel="yLabel", xLabel="XLabel", location=cell }
        graphicFor(false,unitTest)
        unitTest:assert_equal("chart",observerGraphic11.type)
	end
}

-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
Programa não deverá ser executado, já que o gráfico de 'observers' deverá conter ao menos um atributo, então assim, ocorrerá um erro.

DYNAMIC GRAPHIC 02
Deverá ser criado um gráfico com título 'Graph Title', com a curva crescendo em relação a 'yLable' e 'time' de acordo com o 'currentState'.

DYNAMIC GRAPHIC 03
Deverá ser criado um gráfico com título 'Graph Title', com a curva crescendo em relação a 'yLable' e 'time' de acordo com o 'currentState'.

DYNAMIC GRAPHIC 04
Programa cria um gráfico 'Title' cuja curva crescerá de acordo com 'time' no eixo x e 'currentState' no eixo y.

DYNAMIC GRAPHIC 05
Programa deverá apresentar um gráfico 'titutlo' com duas curvas um partindo de '0', de nome 'CurveTitle', e outra partindo de '1', de nome 'CurveTitle2', as duas crescendo em relação ao eixo x 'time' e ao eixo y 'currentState'.

DYNAMIC GRAPHIC 06
Programa deverá criar um gráfico 'titulo' com duas curvas, uma 'CurveTitle' que se apresenta na cor roxa e outra 'CurveTitle2' que se apresenta na cor azul, crescendo em relação ao 'tempo' e ao 'currentState'.

DYNAMIC GRAPHIC 07
Programa apresentará um gráfico 'título' com duas curvas, uma roxa 'CurveTitle' que parte de '0' e outra 'CurveTitle2' na cor azul que parte de '1', as duas crescem de acordo com o eixo y 'currentState' e eixo y 'time'.


DYNAMIC GRAPHIC 08
Programa apresentará um gráfico 'titulo' com duas curvas de nomes 'CurveTitle' e 'CurveTitle2', sendo essas verde e marrom, respectivamente, a primeira partindo de '1'.

GRAPHIC 01
Programa apresentará um gráfico 'GraphTitle', com uma curva roxa, partindo de '0', crescendo de acordo com os eixo1 x 'xLabel' e eixo y 'yLabe', variando de '-1' a '1' em largura.

GRAPHIC 02
Idem GRAPHIC 01.

GRAPHIC 03
Idem GRAPHIC 01.

GRAPHIC 04
Idem GRAPHIC 01.

GRAPHIC 05
Idem GRAPHIC 01.

GRAPHIC 06
Idem GRAPHIC 01, porem varia de '0' a '-1'.

GRAPHIC 07
Programa apresentará um gráfico 'GraphTitle' com duas curvas, uma azul partindo de '0' e variando de '0-2' e uma roxa patindo de '1' e variando de '0-1' em largura.

GRAPHIC 08
Idem GRAPHIC 07.

GRAPHIC 09
Idem GRAPHIC 07.

GRAPHIC 10
Idem GRAPHIC 07, exceto que a curva 2, é roxa.

GRAPHIC 11
Idem GRAPHIC 07, exceto que a curva 1 é azul e a curva 2 é roxa.
]]

observersChartTest:run()
os.exit(0)
