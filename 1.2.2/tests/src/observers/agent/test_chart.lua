-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright � 2001-2012 INPE and TerraLAB/UFOP.
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
--			Henrique Cota Cam�lo
--			Washington Sena Fran�a e Silva
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do
	for j = 1, 5, 1 do
		c = Cell{ cover = "pasture", agents_ = {}}
		c.y = j - 1;
		c.x = i - 1;
		cs:add( c );
	end
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

			if (hungry) then
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

env = Environment{ id = "MyEnvironment", cs, ag1}
env:createPlacement{strategy = "void"}

ev = Event{ time = 1, period = 1, priority = 1 }

cs:notify()
cell = cs.cells[1]
ag1:enter(cell)

ag1LegGraph = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,

	style = 3,  -- estilo da curva
	symbol = 14, -- tipo do simbolo 
	width = 2, -- largura da linha

	colorBar = {
		{color = "red", value = "walking"},
		{color = "blue", value = "sleeping"}
	}
}

energyLeg = Legend{
	type = "number", -- NUMBER
	grouping = "equalsteps",		-- ,		-- STDDEVIATION
	slices = 10,
	precision = 5,
	stdDeviation = "none",		-- ,		-- FULL
	maximum = 100,
	minimum = 1,
	colorBar = {
		{color = "green", value = 0},
		{color = "blue", value = 100}
	},

	width = 2, -- largura da linha

	--works only with charts observers
	style = 1,  -- estilo da curva 
	symbol = 3 -- tipo do simbolo 
}

chartFor = function( killObserver,unitTest) 
	for i=1, 10, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify(i)
		ag1:notify(i)
		if ((killObserver and observerGraphic10) and (i == 8)) then
			print("", "observerGraphic10:kill", observerGraphic10:kill())
		end
		delay_s(1)
	end
	unitTest:assert_true(true) 
end

local observersChartTest = UnitTest {
  -- OBSERVER DYNAMIC GRAPHIC 01
	test_chart01 = function(unitTest)
		print("OBSERVER DYNAMIC GRAPHIC 01")
		observerDynamicGraphic01=Observer{subject=ag1, type="chart", attributes={"energy"} }     
		chartFor(false, unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic01.type) 
		
	end,
	test_chart02 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02")
		observerDynamicGraphic02=Observer{subject=ag1, type = "chart", attributes={"energy"}, title="GraphicTitle", curveLabels={"CurveTitle"},  yLabel="YLabel", xLabel="XLabel"}	
		chartFor(false, unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic02.type)
	end,
	test_chart03 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03")
		observerDynamicGraphic03=Observer{subject=ag1, type="chart", attributes={"currentState"} }             
		chartFor(false, unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic03.type)
	end,
	test_chart04 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04")
		observerDynamicGraphic04=Observer{subject=ag1, type="chart", attributes={"currentState","energy"}, title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}             
		chartFor(false, unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic04.type)
	end,
	test_chart05 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05")
		observerDynamicGraphic05=Observer{subject=ag1, type="chart", attributes={"currentState","energy"},legends={ag1LegGraph,energyLeg},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false, unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic05.type)
	end,
	test_chart06 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06")
		observerDynamicGraphic06=Observer{subject=ag1, type="chart", attributes={"currentState","energy"},legends={ag1LegGraph},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false, unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic06.type)
	end,
	test_chart07 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07")
		observerDynamicGraphic07=Observer{subject=ag1, type="chart", attributes={"energy","currentState"},legends={energyLeg},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic07.type)
	end,
	test_chart08 = function(unitTest)
		-- OBSERVER GRAPHIC 01
		print("OBSERVER GRAPHIC 01")
		observerGraphic01=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic01.type)
	end,
	test_chart09 = function(unitTest)
		-- OBSERVER GRAPHIC 02
		print("OBSERVER GRAPHIC 02")
		observerGraphic02=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title=nil}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic02.type)
	end,
	test_chart10 = function(unitTest)
		-- OBSERVER GRAPHIC 03
		print("OBSERVER GRAPHIC 03")
		observerGraphic03=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic03.type)
	end,
	test_chart11 = function(unitTest)
		-- OBSERVER GRAPHIC 04
		print("OBSERVER GRAPHIC 04")
		observerGraphic04=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle", curveLabels={"CurveTitle"}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic04.type)
	end,
	test_chart12 = function(unitTest)
		-- OBSERVER GRAPHIC 05
		print("OBSERVER GRAPHIC 05")
		observerGraphic05=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic05.type)
	end,
	test_chart13 = function(unitTest)
		-- OBSERVER GRAPHIC 06
		print("OBSERVER GRAPHIC 06")
		observerGraphic06=Observer{subject=ag1, type = "chart",attributes={"currentState"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic06.type)
	end,
	test_chart14 = function(unitTest)
		-- OBSERVER GRAPHIC 07
		print("OBSERVER GRAPHIC 07")
		observerGraphic07=Observer{subject=ag1, type = "chart",attributes={"currentState"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic07.type)
	end,
	test_chart15 = function(unitTest)
		-- OBSERVER GRAPHIC 08
		print("OBSERVER GRAPHIC 08")
		observerGraphic08=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic08.type)
	end,
	test_chart16 = function(unitTest)
		-- OBSERVER GRAPHIC 09
		print("OBSERVER GRAPHIC 09")
		observerGraphic09=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel", legends={ag1LegGraph}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic09.type)
	end,
	test_chart17 = function(unitTest)
		-- OBSERVER GRAPHIC 10
		print("OBSERVER GRAPHIC 10")
		observerGraphic10=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={ag1LegGraph,energyLeg}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic10.type)
	end,
	test_chart18 = function(unitTest)
		-- OBSERVER GRAPHIC 11
		print("OBSERVER GRAPHIC 11")
		observerGraphic11=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={ag1LegGraph}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic11.type)
	end,
	test_chart19 = function(unitTest)
		-- OBSERVER GRAPHIC 12
		print("OBSERVER GRAPHIC 12")
		observerGraphic12=Observer{subject=ag1, type = "chart",attributes={"energy","currentState"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={energyLeg}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic12.type)
	end
}
	
-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
Dever� apresentar um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores do tempo corrente do rel�gio de simula��o e do atributo "energy" do agente "ag1", respectivamente. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 02
Resultados id�nticos aos dos observers DYNAMIC GRAPHIC01, exceto pelo uso do t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y e r�tulo para o eixo X: "GraphicTitle" , "CurveTitle", "YLabel" e "XLabel".

DYNAMIC GRAPHIC 03
Dever� apresentar um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores do tempo corrente do rel�gio de simula��o e do atributo "currentState" do agente "ag1", respectivamente. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
O formato da curva neste teste � o de uma onda quadrada. 
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 04
Dever� apresentar um gr�fico de dispers�o XY, contendo duas curvas com cores aleat�rias, onde os eixos X recebera os valores do tempo corrente do rel�gio de simula��o e o Y recebera um valor autom�tico de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y e r�tulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 05
Dever� apresentar um gr�fico de dispers�o XY, contendo duas curvas , sendo uma curva continua e outra pontilhada nas cores verde e vermelha respectivamente, onde o eixo X recebera os valores do tempo corrente do rel�gio de simula��o e o Y recebera um valor autom�tico de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y e r�tulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 06
Dever� apresentar um gr�fico de dispers�o XY, contendo duas curvas , sendo uma curva continua de cor autom�tica e outra pontilhada na cor vermelha , onde o eixo X recebera os valores do tempo corrente do rel�gio de simula��o e o Y recebera um valor autom�tico de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y e r�tulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 07
Dever� apresentar um gr�fico de dispers�o XY, contendo duas curvas , sendo uma curva continua de cor verde e outra continua de cor autom�tica , onde o eixo X recebera os valores do tempo corrente do rel�gio de simula��o e o Y recebera um valor autom�tico de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y e r�tulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

GRAPHIC 01 / GRAPHIC 02
Dever� ser apresentado um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores dos atributos "currentState" e "counter", respectivamente. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo Y ("$yLabel"), t�tulo do eixo X ("$xLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 03
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico "GraphicTitle".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 04
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico e t�tulo da curva: "GraphicTitle" e "CurveTitle".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 05
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico, t�tulo da curva e r�tulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "XLabel".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para o par�metros "t�tulo do eixo X".

GRAPHIC 06
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso de valores espec�ficos na lista de par�metros.

GRAPHIC 07
Este teste ser� id�ntico ao teste 06. Por�m, no tempo de simula��o 8, o observador "observerGraphic10" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e a janela referente a este observador ser� fechada.

GRAPHIC 08
Dever� apresentar um gr�fico de dispers�o XY, contendo duas curvas continuas e de cores aleat�rias, onde os eixos X e Yreceber�o valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y, r�tulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 09
Dever� apresentar um gr�fico de dispers�o XY, contendo duas curvas continuas de cores aleat�rias, onde os eixos X e Y receber�o valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y, r�tulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle"}, "YLabel", "XLabel" e "counter".

GRAPHIC 10
Dever� apresentar um gr�fico de dispers�o XY, contendo uma curva continua de cor verde e uma curva pontilhada de cor vermelha, onde os eixos X e Y receber�o valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y, r�tulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 11
Dever� apresentar um gr�fico de dispers�o XY, contendo uma curva continua de cor aleat�ria e uma curva pontilhada de cor vermelha, onde os eixos X e Y receber�o valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y, r�tulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 12
Dever� apresentar um gr�fico de dispers�o XY, contendo uma curva continua de cor verde e uma curva continua de cor aleat�ria, onde os eixos X e Y receber�o valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Ser�o usados o t�tulo do gr�fico, t�tulo da curva, r�tulo para o eixo Y, r�tulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".
]]

observersChartTest:run()
os.exit(0)
