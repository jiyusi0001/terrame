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

ag1Leg = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,

	style = 3,  -- estilo da curva
	symbol = "+", -- tipo do simbolo 
	width = 2, -- largura da linha

	colorBar = {
		{color = "red", value = "walking"},
		{color = "blue", value = "sleeping"}
	}
}

coverLeg = Legend {
	type = "string",	--TME_LEGEND_TYPE.TEXT,
	grouping = "uniquevalue",	--TME_LEGEND_GROUPING.UNIQUEVALUE,
	slices = 2,
	precision = 5,
	stdDeviation = "none",	--TME_LEGEND_STDDEVIATION.NONE,
	maximum = 1,
	minimum = 0,

	style = 1,  -- estilo da curva
	symbol = 13, -- tipo do simbolo 
	width = 2, -- largura da linha

	colorBar = {
		{color = "green", value = "pasture"},
		{color = "brown", value = "soil"}
	}
}

mapFor = function( killObserver,unitTest )
	for i=1, 25, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify(i)
		ag1:notify(i)
		if ((killObserver and observerMap07) and (i == 18)) then
			print("", "observerMap07:kill", observerMap07:kill())
		end
		delay_s(2)
	end
	unitTest:assert_true(true) 
end

local observersMapTest = UnitTest {
	test_Map01 = function(unitTest)
		-- OBSERVER MAP 01
		print("OBSERVER MAP 01")
		observerMap01=Observer{subject=ag1, type = "map" }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap01.type)
	end,
	test_Map02 = function(unitTest)
		-- OBSERVER MAP 02
		print("OBSERVER MAP 02")
		observerMap02=Observer{subject=ag1, type = "map", attributes={"currentState"}}
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap02.type)
	end,
	test_Map03 = function(unitTest)
		-- OBSERVER MAP 03
		print("OBSERVER MAP 03")
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }	
		observerMap03=Observer{subject=ag1, type = "map", attributes={"currentState"},observer = obsMap}
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap03.type)
	end,
	test_Map04 = function(unitTest)
		-- OBSERVER MAP 04
		print("OBSERVER MAP 04")
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }	
		observerMap04=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap}
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap04.type)
	end,
	test_Map05 = function(unitTest)
		-- OBSERVER MAP 05
		print("OBSERVER MAP 05")
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }	      
		observerMap05=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap, legends = {ag1Leg} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap05.type)
	end,
	test_Map06 = function(unitTest)
		-- OBSERVER MAP 06
		print("OBSERVER MAP 06")
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }	
		observerMap06=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap, legends = {ag1Leg}}
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap06.type)
	end,
	test_Map07 = function(unitTest)
		-- OBSERVER MAP 07
		print("OBSERVER MAP 07")
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }	
		observerMap07=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap, legends = {ag1Leg}}                
		mapFor(true,unitTest)
		unitTest:assert_equal("map",observerMap07.type)
	end
}

-- TESTES OBSERVER MAP
--[[
MAP 01
O programa deverá ser abortado. Não é possível utilizar MAP observers sem a identificação de pelo menos um atributo.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 02
O programa deverá ser abortado. Não é possível utilizar MAP observers de agentes sem a identificação observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 03
O programa deverá ser abortado. Não é possível utilizar MAP observers de agentes sem a identificação de um espaço celular.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 04
Deverá exibir uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço, iniciando na "célula (1,1)" até a "célula (5,5)". 
Como a legenda padrão (que é carregada neste teste) não conhece os valores do atributo "currentState", o agente não irá receber as cores definidas na legenda e sim a cor padrão "BLACK".

MAP 05
Deverá exibir uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço, iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda "ag1LegMinimumParameters".

MAP 06
Deverá exibir uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço, iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda "ag1Leg".

MAP 07
Este teste será idêntico ao teste MAP 06. Porém, no tempo de simulação 18, o observador "observerMap07" será destruído. As imagens exibidas até o 18o. tempo de simulação conterão o agente. As imagens exibidas a partir do 19o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.
]]

observersMapTest:run()
os.exit(0)
