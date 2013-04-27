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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")
dofile (TME_PATH.."/tests/dependencies/TestConf.lua")

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
			ag1.counter = ag1.counter + 10

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


imageFor = function ( killObserver,unitTest,testNumber,prefix) 
    if prefix == nil then
        prefix = "result_"
    end
	for i=1, 25, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify()
		ag1:notify(i)

		if ((killObserver and observerImage06) and (i == 18)) then
			print("", "observerImage06:kill", observerImage06:kill())
		end

			if i<10 then
            unitTest:assert_image_match("./"..prefix.."00000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/agent/test_image/test_Image0"..testNumber.."/"..prefix.."00000"..i..".png")
        else
            unitTest:assert_image_match("./"..prefix.."0000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/agent/test_image/test_Image0"..testNumber.."/"..prefix.."0000"..i..".png")
        end
		delay_s(2)
	end
	unitTest:assert_true(true) 
end

local observersImageTest = UnitTest {
	test_Image01 = function(unitTest)
		-- OBSERVER IMAGE 01 
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 01")
		observerImage01=Observer{subject=ag1, type = "image"}
		imageFor(false,unitTest,1)
		unitTest:assert_equal("image",observerImage01.type)
		
	end,
	test_Image02 = function(unitTest)
		-- OBSERVER IMAGE 02
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 02")
		observerImage02=Observer{subject=ag1, type = "image", attributes={"currentState"}, cellspace = cs}
		imageFor(false,unitTest,2)
		unitTest:assert_equal("image",observerImage02.type)
	end,
	test_Image03 = function(unitTest)
		-- OBSERVER IMAGE 03
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 03")
		observerImage03=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		imageFor(false,unitTest,3)
		unitTest:assert_equal("image",observerImage03.type)
		
	end,
	test_Image04 = function(unitTest)
		-- OBSERVER IMAGE 04
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 04")
		observerImage04=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		imageFor(false,unitTest,4)
		unitTest:assert_equal("image",observerImage04.type)
		
	end,
	test_Image05 = function(unitTest)
		-- OBSERVER IMAGE 05
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 05")
		observerImage05=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs, legends = {ag1Leg} }
		imageFor(false,unitTest,5)
		unitTest:assert_equal("image",observerImage05.type)		
	end,
	test_Image06 = function(unitTest)
		-- OBSERVER IMAGE 06
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		print("OBSERVER IMAGE 06")
		observerImage06=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs, legends = {ag1Leg} }
		imageFor(true,unitTest,6)
		unitTest:assert_equal("image",observerImage06.type)
		
	end,
	test_Image07 = function(unitTest)
		-- OBSERVER IMAGE 07
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg},path =TME_ImagePath ,prefix = "prefix_"}
		print("OBSERVER IMAGE 07")
		observerImage07=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		
	    for i=1, 25, 1 do
		    print("step ",i)
		    ag1:execute(ev)
		    ag1:move(cs.cells[i])
		    cs:notify()
		    ag1:notify(i)

		    if i<10 then
                unitTest:assert_image_match(TME_ImagePath.."/".."prefix_00000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/agent/test_image/test_Image07".."/".."prefix_00000"..i..".png")
            else
                unitTest:assert_image_match(TME_ImagePath.."/".."prefix_0000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/agent/test_image/test_Image07".."/".."prefix_0000"..i..".png")
            end		    
	    end
        moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."agent"..TME_DIR_SEPARATOR.."test_image"..TME_DIR_SEPARATOR.."test_Image07",".png")

	    if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/prefix_*".. " > /dev/null 2>&1 ")
	    else
		    --@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end
        
        unitTest:assert_equal("image",observerImage07.type)
		
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

IMAGE 07
Idem IMAGE 04, mas os arquivos serão gerados no Desktop com o nome prefix_
]]

observersImageTest:run()
os.exit(0)
