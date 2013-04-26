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

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do 
	for j = 1, 5, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
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
			ag1.time = ag1.time + 1;
			ag1:notify(ag1.time);

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
			ag1.time = ag1.time + 1;
			ag1:notify(ag1.time);

			if (not hungry)or( ag1.energy==5) then
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
	time = 0,
	state1,
	state2
}


at1 = Automaton{
	id = "At1",
	it = Trajectory{
		target = cs
	}
}

t = Timer{
	Event{ time = 0, period = 1, action = function(event) 
			at1:execute(event) 
			env:notify(event:getTime())

			env.counter = event:getTime() + 1
			env.temperature = event:getTime() * 2
      env.energy = env.energy - event:getTime() * 2

			if ((killObserver and observerKill) and (event:getTime() == 8)) then
				print("", "env:kill", env:kill(observerKill))
			end
			return true 
		end 
	}
}

--chart legends
temperatureLegGraph = Legend{
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

counterLegGraph = Legend{
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

energyLegGraph = Legend{
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
	style = "sticks",  -- estilo da curva 
	symbol = 3 -- tipo do simbolo 
}

env = Environment{ 
	id = "MyEnvironment",
	c1 = cs,
	-- verificar. funciona no linux. não funciona no windows.
	-- erro: index out of bounds
	--at1 = at1,
	--ag1 = ag1,
	t = t,
	counter = 0,
	temperature = 0,
	energy = 100000
}
env:add(t)

chartFor = function( killObserver,unitTest )
	if ((killObserver and observerLogFile06) and (i == 8)) then
		print("", "observerLogFile06:kill", observerLogFile06:kill())
	end
	env:execute(100)
	unitTest:assert_true(true)
end

local observersLogFileTest = UnitTest {
    test_chart01 = function(unitTest) 
		-- OBSERVER DYNAMIC GRAPHIC 01
		print("OBSERVER DYNAMIC GRAPHIC 01")
		observerDynamicGraphic01 = Observer{subject=env, type="chart", attributes={"counter"}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic01.type)
	end,
	test_chart02 = function(unitTest) 
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02")
		observerDynamicGraphic02 = Observer{subject=env, type="chart", attributes={"counter"},title="GraphicTitle", curveLabels={"CurveTitle"},  yLabel="YLabel", xLabel="XLabel"}	
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic02.type)
	end,
	test_chart03 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03")
		observerDynamicGraphic03=Observer{subject=env, type="chart", attributes={"temperature"} }             
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic03.type)
	end,
	test_chart04 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04")
		observerDynamicGraphic04=Observer{subject=env, type="chart", attributes={"temperature","counter"}, title="Environment", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}             
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic04.type)
	end,
	test_chart05 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05")
		observerDynamicGraphic05=Observer{subject=env, type="chart", attributes={"temperature","counter"},legends={counterLegGraph,temperatureLegGraph},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic05.type)
	end,
	test_chart06 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06")
		observerDynamicGraphic06=Observer{subject=env, type="chart", attributes={"counter","temperature"},legends={counterLegGraph},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic06.type)
	end,
	test_chart07 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07")
		observerDynamicGraphic07=Observer{subject=env, type="chart", attributes={"temperature","counter"},legends={temperatureLegGraph},title="GraphicTitle", curveLabels={"CurveTitle","CurveTitle2"},  yLabel="YLabel", xLabel="XLabel"}  
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic07.type)
	end,
	test_chart08 = function(unitTest)
		-- OBSERVER GRAPHIC 01
		print("OBSERVER GRAPHIC 01")
		observerGraphic01=Observer{subject=env, type = "chart", attributes={"temperature"}, xAxis="counter"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic01.type)
	end,
	test_chart09 = function(unitTest)
		-- OBSERVER GRAPHIC 02
		print("OBSERVER GRAPHIC 02")
		observerGraphic02=Observer{subject=env, type = "chart", attributes={"temperature"}, xAxis="counter", title=nil}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic02.type)
	end,
	test_chart10 = function(unitTest)
		-- OBSERVER GRAPHIC 03
		print("OBSERVER GRAPHIC 03")
		observerGraphic03=Observer{subject=env, type = "chart", attributes={"temperature"}, xAxis="counter", title="GraphicTitle"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic03.type)
	end,
	test_chart11 = function(unitTest)
		-- OBSERVER GRAPHIC 04
		print("OBSERVER GRAPHIC 04")
		observerGraphic04=Observer{subject=env, type = "chart", attributes={"temperature"}, xAxis="counter", title="GraphicTitle", curveLabels={"CurveTitle"}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic04.type)
	end,
	test_chart12 = function(unitTest)
		-- OBSERVER GRAPHIC 05
		print("OBSERVER GRAPHIC 05")
		observerGraphic05=Observer{subject=env, type = "chart", attributes={"temperature"}, xAxis="counter", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic05.type)
	end,
	test_chart13 = function(unitTest)
		-- OBSERVER GRAPHIC 06
		print("OBSERVER GRAPHIC 06")
		observerGraphic06=Observer{subject=env, type = "chart",attributes={"temperature"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic06.type)
	end,
	test_chart14 = function(unitTest)
		-- OBSERVER GRAPHIC 07
		print("OBSERVER GRAPHIC 07")
		observerGraphic07=Observer{subject=env, type = "chart",attributes={"temperature"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic07.type)
	end,
	test_chart15 = function(unitTest)
		-- OBSERVER GRAPHIC 08
		print("OBSERVER GRAPHIC 08")
		observerGraphic08=Observer{subject=env, type = "chart",attributes={"temperature","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic08.type)
	end,
	test_chart16 = function(unitTest)
		-- OBSERVER GRAPHIC 09
		print("OBSERVER GRAPHIC 09")
		observerGraphic09=Observer{subject=env, type = "chart",attributes={"temperature","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel",xLabel="XLabel", legends={temperatureLegGraph}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic09.type)
	end,
	test_chart17 = function(unitTest)
		-- OBSERVER GRAPHIC 10
		print("OBSERVER GRAPHIC 10")
		observerGraphic10=Observer{subject=env, type = "chart",attributes={"temperature","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={temperatureLegGraph,energyLegGraph}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic10.type)
	end,
	test_chart18 = function(unitTest)
		-- OBSERVER GRAPHIC 11
		print("OBSERVER GRAPHIC 11")
		observerGraphic11=Observer{subject=env, type = "chart",attributes={"temperature","energy"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={temperatureLegGraph}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic11.type)
	end,
	test_chart19 = function(unitTest)
		-- OBSERVER GRAPHIC 12
		print("OBSERVER GRAPHIC 12")
		observerGraphic12=Observer{subject=env, type = "chart",attributes={"energy","temperature"}, xAxis="counter",title="GraphicTitle",curveLabels={"CurveTitle","Curvetitle2"}, yLabel="YLabel",xLabel="XLabel", legends={energyLegGraph}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic12.type)
	end
}
-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "counter" do environment "env", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 02
Resultados idênticos aos dos observers DYNAMIC GRAPHIC01, exceto pelo uso do título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , "CurveTitle", "YLabel" e "XLabel".

DYNAMIC GRAPHIC 03
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "temperature" do environment "env", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
O gráfico plotado é linear.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 04
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas com cores aleatórias, onde os eixos X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "temperature" e "counter" do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 05
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas , sendo uma curva continua e outra pontilhada nas cores verde e vermelha respectivamente, onde o eixo X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "temperature" e "counter" do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 06
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas , sendo uma curva continua de cor automática e outra pontilhada na cor vermelha , onde o eixo X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "temperature" e "counter"  do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

DYNAMIC GRAPHIC 07
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas , sendo uma curva continua de cor vermelha e outra continua de cor automática , onde o eixo X recebera os valores do tempo corrente do relógio de simulação e o Y recebera um valor automático de acordo com os atributos "temperature" e "counter"  do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel" e "XLabel".

GRAPHIC 01 / GRAPHIC 02
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "temperature" e "counter", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
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
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas continuas e de cores aleatórias, onde os eixos X e Yreceberão valores de acordo com os atributos "temperature" e "energy" do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 09
Deverá apresentar um gráfico de dispersão XY, contendo duas curvas continuas de cores aleatórias, onde os eixos X e Y receberão valores de acordo com os atributos "temperature" e "energy" do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle"}, "YLabel", "XLabel" e "counter".

GRAPHIC 10
Deverá apresentar um gráfico de dispersão XY, contendo uma curva em "sticks" de cor verde e uma curva pontilhada de cor vermelha, onde os eixos X e Y receberão valores de acordo com os atributos "temperature" e "energy" do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 11
Deverá apresentar um gráfico de dispersão XY, contendo uma curva continua de cor aleatória e uma curva pontilhada de cor vermelha, onde os eixos X e Y receberão valores de acordo com os atributos "temperature" e "energy" do environment "env". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".

GRAPHIC 12
Deverá apresentar um gráfico de dispersão XY, contendo uma curva continua de cor verde e uma curva continua de cor aleatória, onde os eixos X e Y receberão valores de acordo com os atributos "energy" e "currentState" do agente "ag1". Serão usados o título do gráfico, título da curva, rótulo para o eixo Y, rótulo para o eixo X e o xAxis : "GraphicTitle" , {"CurveTitle","CurveTitle2"}, "YLabel", "XLabel" e "counter".
]]


observersLogFileTest:run()
os.exit(0)
