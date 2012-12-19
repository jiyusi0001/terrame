-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can TME_LEGEND_COLOR.REDistribute it and/or
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

cs = CellularSpace{
	xdim = 10
	-- -- xdim = 3,
	--cover = "pasture"
}

forEachCell(cs, function(cell)
	cell.cover = "pasture"
end)

coverLeg = Legend{
	-- Attribute name:  cover
	type = "string", -- NUMBER
	grouping = "uniquevalue",		-- ,		-- STDDEVIATION
	slices = 2,
	precision = 5,
	stdDeviation = "none",		-- ,		-- FULL
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "green", value = "pasture"},
		{color = "brown", value = "soil"}
	}
}

rebanhoLeg = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 3,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "black", value = "foraging"}, -- estado 1
		{color = "red", value = "sleeping"}   -- estado 2
	},
	font = "Times",
	fontSize = 14,
	symbol = "u"
}

sleeping = State {
	id = "sleeping",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 0) then
				return true
			end
			print("T:", event:getTime())
			print("-- sleeping")
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
			print("T:", event:getTime())
			print("-- foraging")
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
	instance = boi(1)
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
--For's

imageFor = function( killObservers )
	for i = 1, 10, 1 do
			print("STEP: ", i); io.flush()
			updateFunc(i, sc1)
			if ((killObserver and observerImage09) and (i == 8)) then
				print("", "observerImage09:kill", observerImage09:kill(updateFunc))
			end
			delay_s(2)
			print("Members in society 'sc1':", sc1:size())
			cs:notify()
			sc1:notify()
	end
	--print(compareDirectory("society","image",case,"."))io.flush()
end

-- ================================================================================#
local observersImageTest = UnitTest {
-- OBSERVER IMAGE
		
	test_image1 = function(unitTest)
		-- OBSERVER IMAGE01
		--obs1 = cs:createObserver("image", {"cover"}, {coverLeg})
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 01") io.flush()
		observerImage01 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then soc:remove(boi1) end
		end
		imageFor(false)
	end,
	test_image2 = function(unitTest)
		-- OBSERVER IMAGE02
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 02") io.flush()
		observerImage02 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then soc:remove(soc:sample()) end
		end
		imageFor(false)
	end,
	test_image3 = function(unitTest)
		-- OBSERVER IMAGE03
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 03") io.flush()
		observerImage03 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then
				soc:remove(boi1)
				soc:remove(boi3)
				soc:remove(boi5)
			end
		end
		imageFor(false)
	end,
	test_image4 = function(unitTest)
		-- OBSERVER IMAGE04
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 04") io.flush()
		observerImage04 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			size = soc:size()
			if(step == 5) then
				for i=1,size,1 do
					soc:remove(soc:getAgent(1))
				end
			end
		end
		imageFor(false)
	end,
	test_image5 = function(unitTest)
		-- OBSERVER IMAGE05
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 05") io.flush()
		observerImage05 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then
				--soc:killAll()
				observerImage05:killAll()
				soc:clear()
			end
		end
		imageFor(false)
	end,
	test_image6 = function(unitTest)
		-- OBSERVER IMAGE06
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 06") io.flush()
		observerImage06 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			event = Event { time = step }
			if(step == 5) then
				forEachAgent(soc, function(ag)
					coord = Coord {x=0, y=0}
					ag:move(cs:getCell(coord))
				end)
			end
		end
		imageFor(false)
	end,
	test_image7 = function(unitTest)
		-- OBSERVER IMAGE07
		print("IMAGE 07") io.flush()
		observerImage07 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step > 5) then
				coord = Coord {x=step-1, y=step-1}
				cell = cs:getCell(coord)
				bois[step]:enter(cell)
				ob = Observer{ subject = bois[step], type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				sc1:add(bois[step])
			end
		end
		imageFor(false)
	end,
	test_image8 = function(unitTest)
		-- OBSERVER IMAGE08
		print("IMAGE 08") io.flush()
		--sc1:createObserver("image", {"currentState"}, {cs, obs1, rebanhoLeg})
		observerImage08 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		--obs = nil
		updateFunc = function(step, soc)
			event = Event { time = step }
			bois[10]:execute(event)
			if(step % 2 == 1) then
				bois[10]:enter( cs:getCell(Coord{x=9,y=9}) )
				--obs = bois[10]:createObserver("image", {"currentState"}, {cs, obs1, rebanhoLeg})
				ob = Observer{ subject = bois[10], type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				--table.insert(sc1.observers_, obs)
				sc1:add(bois[10])
				print("boi[10] - visible", bois[10]:getStateName())
			else
				sc1:remove(bois[10])
				print("boi[10] - hidden", bois[10]:getStateName())
			end
		end
		imageFor(false)
	end,
	test_image9 = function(unitTest)
		-- OBSERVER IMAGE9
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 09") io.flush()
		observerImage09 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
		local c1 = cs:sample()
		forEachAgent(sc1, function(ag)
			ag:move(c1)
		end)
		killObserver = true
		updateFunc = function(step, soc)
		-- do nothing
		end
		imageFor(true)
	end,
	test_image10 = function(unitTest)
		-- OBSERVER IMAGE 10
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}
		print("IMAGE 10") io.flush()
		observerMap10 = Observer{ subject = sc1, type = "image", attributes= {"testValue"}, observer = obs1 }
		local c1 = cs:sample()
		forEachAgent(sc1, function(ag)
			ag:move(c1)
		end)
			
		updateFunc = function(step, soc)
		    local ags = soc:getAgents()
	        for i=1,getn(ags),1 do
            	if i%2 == 1 then ags[i].testValue = 10
             	else
                	ags[i].testValue = 55
              	end
            end
		end      
		imageFor(false)
	end
}
-- TESTES OBSERVER IMAGE
--[[
IMAGE 01
Deverá gerar ma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação o agente posicionado na primeira das células será removido. O restante do teste deve apresentar apenas 4 agentes, que devem permanecer na posição em que se encontravam.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 02
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação um agente será selecionado aleatoriamente e removido. O restante do teste deve apresentar apenas 4 agentes, que devem permanecer na posição em que se encontravam.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 03
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação os agentes contidos nas células das posições 1,3 e 5 serão removidos. O restante do teste deve apresentar apenas 2 agentes, que devem permanecer na posição em que se encontravam.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 04 / IMAGE 05
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação todos agentes serão removidos.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 06
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação todos agentes serão movidos para a célula(1,1), onde deverão permanecer até o fim da execução do teste.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 07
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). A partir do instante 5 da simulação serão inseridos outros 5 agentes na sociedade em questão. Estes agentes serão posicionados nas células restantes da diagonal.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 08
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão apresentados 6 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito) e o último na última célula da diagonal. A cada passo da simulação o agente posicionado na célula(9,9) deverá mudar do estado "foraging" para o estado "sleeping", sendo exibido com cor de acordo com a legenda "rebanhoLeg".
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 09
Deverá gerar uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão apresentados 5 agentes, posicionados numa única célula, escolhida aleatoriammente.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 10
É apresentado um "Warning: Attribute 'colorBar' should be a table, got a nil." Using default color bar. Executando do STEP 1 ao STEP 10, utilizando a função test_image10, sendo que em todos os passos "Members in society 'sc1':   5"
.
--]]

observersImageTest.skips = {"test_NotDeclaredStates"}
observersImageTest:run()
os.exit(0)
