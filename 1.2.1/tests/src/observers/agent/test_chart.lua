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
--			Henrique Cota Camêlo
--			Washington Sena França e Silva
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

chartFor = function( killObserver) 
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
end

local observersChartTest = UnitTest {
	test_chart1 = function(self)
		print("OBSERVER DYNAMIC GRAPHIC 01")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
		observerDynamicGraphic01=Observer{subject=ag1, type="chart", attributes={"energy"} }       
		chartFor(false)
	end,
	test_chart2 = function(self)
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{"GraphicTitle","CurveTitle", "YLabel","XLabel"})
		observerDynamicGraphic02=Observer{subject=ag1, type = "chart", attributes={"energy"}, title="GraphicTitle", curveLabels={"CurveTitle"},  yLabel="YLabel", xLabel="XLabel"}	
		chartFor(false)
	end,
	test_chart3 = function(self)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
		observerDynamicGraphic03=Observer{subject=ag1, type="chart", attributes={"currentState"} }             
		chartFor(false)
	end,
	test_chart4 = function(self)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
		observerDynamicGraphic04=Observer{subject=ag1, type="chart", attributes={"currentState","energy"}, title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}             
		chartFor(false)
	end,
	test_chart5 = function(self)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
		observerDynamicGraphic05=Observer{subject=ag1, type="chart", attributes={"currentState","energy"},legends={ag1LegGraph,energyLeg},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false)
	end,
	test_chart6 = function(self)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
		observerDynamicGraphic06=Observer{subject=ag1, type="chart", attributes={"currentState","energy"},legends={ag1LegGraph},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false)
	end,
	test_chart7 = function(self)--28/08
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
		observerDynamicGraphic07=Observer{subject=ag1, type="chart", attributes={"energy","currentState"},legends={energyLeg},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false)
	end,
	test_chart8 = function(self)
		-- OBSERVER GRAPHIC 01
		print("OBSERVER GRAPHIC 01")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"energy","counter"})
		observerGraphic01=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter"}
		chartFor(false)
	end,
	test_chart9 = function(self)
		-- OBSERVER GRAPHIC 02
		print("OBSERVER GRAPHIC 02")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"},{})
		observerGraphic02=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title=nil}
		chartFor(false)
	end,
	test_chart10 = function(self)
		-- OBSERVER GRAPHIC 03
		print("OBSERVER GRAPHIC 03")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"}, {"GraphicTitle"})
		observerGraphic03=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle"}
		chartFor(false)
	end,
	test_chart11 = function(self)
		-- OBSERVER GRAPHIC 04
		print("OBSERVER GRAPHIC 04")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"}, {"GraphicTitle","CurveTitle"})	 	
		observerGraphic04=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle", curveLabels={"CurveTitle"}}
		chartFor(false)
	end,
	test_chart12 = function(self)
		-- OBSERVER GRAPHIC 05
		print("OBSERVER GRAPHIC 05")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"}, {"GraphicTitle","CurveTitle","YLabel"})	 
		observerGraphic05=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel"}
		chartFor(false)
	end,
	test_chart13 = function(self)
		-- OBSERVER GRAPHIC 06
		print("OBSERVER GRAPHIC 06")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic06=Observer{subject=ag1, type = "chart",attributes={"currentState"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(false)
	end,
	test_chart14 = function(self)
		-- OBSERVER GRAPHIC 07
		print("OBSERVER GRAPHIC 07")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic07=Observer{subject=ag1, type = "chart",attributes={"currentState"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(true)
	end,
	test_chart15 = function(self)--28/08
		-- OBSERVER GRAPHIC 08
		print("OBSERVER GRAPHIC 08")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic08=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(false)
	end,
	test_chart16 = function(self)--28/08
		-- OBSERVER GRAPHIC 09
		print("OBSERVER GRAPHIC 09")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic09=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel", legends={ag1LegGraph}}
		chartFor(false)
	end,
	test_chart17 = function(self)--28/08
		-- OBSERVER GRAPHIC 10
		print("OBSERVER GRAPHIC 10")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic10=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={ag1LegGraph,energyLeg}}
		chartFor(false)
	end,
	test_chart18 = function(self)--28/08
		-- OBSERVER GRAPHIC 11
		print("OBSERVER GRAPHIC 11")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic11=Observer{subject=ag1, type = "chart",attributes={"currentState","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={ag1LegGraph}}
		chartFor(false)
	end,
	test_chart19 = function(self)--28/08
		-- OBSERVER GRAPHIC 12
		print("OBSERVER GRAPHIC 12")
		--@DEPRECATED
		--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
		observerGraphic12=Observer{subject=ag1, type = "chart",attributes={"energy","currentState"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={energyLeg}}
		chartFor(false)
	end
}

	
-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "energy" do agente "ag1", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 02
Resultados idênticos aos dos observers DYNAMIC GRAPHIC01, exceto pelo uso do título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , "CurveTitle", "YLabel" e "XLabel".

DYNAMIC GRAPHIC 03
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "currentState" do agente "ag1", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
O formato da curva neste teste é o de uma onda quadrada. 
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 04
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas com cores aleatórias, onde os eixos X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 05
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas , sendo uma curva continua e outra pontilhada nas cores verde e vermelha respectivamente, onde o eixo X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 06
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas , sendo uma curva continua de cor automática e outra pontilhada na cor vermelha , onde o eixo X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 07
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas , sendo uma curva continua de cor verde e outra continua de cor automática , onde o eixo X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

GRAPHIC 01 / GRAPHIC 02
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "currentState" e "counter", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 03
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico "GraphicTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 04
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico e título da curva: "GraphicTitle" e "CurveTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do eixo Y" e "título do eixo X").

GRAPHIC 05
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico, título da curva e rótulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "XLabel".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetros "título do eixo X".

GRAPHIC 06
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso de valores específicos na lista de parâmetros.

GRAPHIC 07
Este teste será idêntico ao teste 06. Porém, no tempo de simulação 8, o observador "observerGraphic10" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observador será fechada.

GRAPHIC 08
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas continuas e de cores aleatórias, onde os eixos X e Yreceberão valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 09
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas continuas de cores aleatórias, onde os eixos X e Y receberão valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle"}, "YLabel", "XLabel" e "counter".

GRAPHIC 10
Deverá apresentar um gráfico de dispersão XY, contendo uma curva continua de cor verde e uma curva pontilhada de cor vermelha, onde os eixos X e Y receberão valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 11
Deverá apresentar um gráfico de dispersão XY, contendo uma curva continua de cor aleatória e uma curva pontilhada de cor vermelha, onde os eixos X e Y receberão valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 12
Deverá apresentar um gráfico de dispersão XY, contendo uma curva continua de cor verde e uma curva continua de cor aleatória, onde os eixos X e Y receberão valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".
]]

observersChartTest:run()
os.exit(0)
