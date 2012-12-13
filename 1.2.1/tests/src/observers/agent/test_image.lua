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


imageFor = function ( killObserver )
	for i=1, 25, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify()
		ag1:notify(i)
		if ((killObserver and observerImage06) and (i == 18)) then
			print("", "observerImage06:kill", observerImage06:kill())
		end
		delay_s(2)
	end
	--print(compareDirectory("agent","image",case,"."))io.flush()
end

local observersImageTest = UnitTest {
	test_Image1 = function(self)
		-- OBSERVER IMAGE 01 
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 01")
		--@DEPRECATED
		--ag1:createObserver( "image" )
		observerImage01=Observer{subject=ag1, type = "image" }
		imageFor(false)
	end,
	test_Image2 = function(self)
		-- OBSERVER IMAGE 02
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 02")
		--@DEPRECATED
		--ag1:createObserver("image", {"currentState"}, {cs})
		observerImage02=Observer{subject=ag1, type = "image", attributes={"currentState"}, cellspace = cs}
		imageFor(false)
	end,
	test_Image3 = function(self)
		-- OBSERVER IMAGE 03
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 03")
		--@DEPRECATED
		--ag1:createObserver("image", {"currentState"}, {obs})
		observerImage03=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		imageFor(false)
	end,
	test_Image4 = function(self)
		-- OBSERVER IMAGE 04
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 04")
		--@DEPRECATED
		--ag1:createObserver("image", {"currentState"}, {cs,obs})
		--observerImage04=Observer{subject=ag1, type = "image", attributes={"currentState"}, cellspace = cs, observer = obs}
		observerImage04=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		imageFor(false)
	end,
	test_Image5 = function(self)
		-- OBSERVER IMAGE 05
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 05")
		--@DEPRECATED
		--ag1:createObserver("image", {"currentState"}, {cs,obs,ag1Leg})
		observerImage05=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs, legends = {ag1Leg} }
		imageFor(false)
	end,
	test_Image6 = function(self)
		-- OBSERVER IMAGE 06
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 06")
		--@DEPRECATED
		--ag1:createObserver("image", {"currentState"}, {cs,obs,ag1Leg})
		observerImage06=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs, legends = {ag1Leg} }
		imageFor(true)
	end
}

--[[
IMAGE 01
O programa deverá ser abortado. Não é possível utilizar IMAGE observers sem a identificação de pelo menos um atributo.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 02
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de agentes sem a identificação observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 03
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de agentes sem a identificação de um espaço celular.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 04
Deverá gerar 25 imagens com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda padrão.
Como a legenda padrão (que é carregada neste teste) não conhece os valores do atributo "currentState", o agente não irá receber as cores definidas na legenda e sim a cor padrão "BLACK".
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão. 

IMAGE 05
Deverá gerar 25 imagens com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda "ag1Leg".
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão. 

IMAGE 06
Este teste será idêntico ao teste IMAGE 05. Porém, no tempo de simulação 18, o observador "observerImage06" será destruído. As imagens geradas até o 18o. tempo de simulação conterão o agente. As imagens geradas a partir do 19o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.
]]

observersImageTest:run()
os.exit(0)
