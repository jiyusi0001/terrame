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
dofile (TME_PATH.."/tests/run/run_util.lua")

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

-- ================================================================================#
-- OBSERVER MAP
function test_map( case )
	if( not SKIP ) then
		--obs1 = cs:createObserver("map", {"cover"}, {coverLeg})
		obs1 = Observer { subject = cs, type = "map", attributes = {"cover"}, legends = {coverLeg}}

		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER MAP 01
				print("MAP 01") io.flush()
				observerMap01 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step,soc)
					if(step == 5) then soc:remove(boi1) end
				end
			end,
			[2] = function(x)
				-- OBSERVER MAP 02
				print("MAP 02") io.flush()
				observerMap02 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then soc:remove(soc:sample()) end
				end
			end,
			[3] = function(x)
				-- OBSERVER MAP 03
				print("MAP 03") io.flush()
				observerMap03 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then
						soc:remove(boi1)
						soc:remove(boi3)
						soc:remove(boi5)
					end
				end
			end,
			[4] = function(x)
				-- OBSERVER MAP 04
				print("MAP 04") io.flush()
				observerMap04 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					size = soc:size()
					if(step == 5) then
						for i=1,size,1 do
							soc:remove(soc:getAgent(1))
						end
					end
				end
			end,
			[5] = function(x)
				-- OBSERVER MAP 05
				print("MAP 05") io.flush()
				observerMap05 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then
						--soc:killAll()
						observerMap05:killAll()
						soc:clear()
					end
				end
			end,
			[6] = function(x)
				-- OBSERVER MAP 06
				print("MAP 06") io.flush()
				observerMap06 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					event = Event { time = step }
					if(step == 5) then
						forEachAgent(soc, function(ag)
							coord = Coord {x=0, y=0}
							ag:move(cs:getCell(coord))
						end)
					end
				end
			end,
			[7] = function(x)
				-- OBSERVER MAP 07
				print("MAP 07") io.flush()
				observerMap07 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step > 5) then
						coord = Coord {x=step-1, y=step-1}
						cell = cs:getCell(coord)
						bois[step]:enter(cell)
						ob = Observer{ subject = bois[step], type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
						sc1:add(bois[step])
					end
				end
			end,
			[8] = function(x)
				-- OBSERVER MAP 08
				print("MAP 08") io.flush()
				--sc1:createObserver("map", {"currentState"}, {cs, obs1, rebanhoLeg})
				observerMap08 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				--obs = nil
				updateFunc = function(step, soc)
					event = Event { time = step }
					bois[10]:execute(event)
					if(step % 2 == 1) then
						bois[10]:enter( cs:getCell(Coord{x=9,y=9}) )
						--obs = bois[10]:createObserver("image", {"currentState"}, {cs, obs1, rebanhoLeg})
						ob = Observer{ subject = bois[10], type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
						--table.insert(sc1.observers_, obs)
						sc1:add(bois[10])
						print("boi[10] - visible", bois[10]:getStateName())
					else
						sc1:remove(bois[10])
						print("boi[10] - hidden", bois[10]:getStateName())
					end
				end
			end,
			[9] = function(x)
				-- OBSERVER MAP 9
				print("MAP 09") io.flush()
				observerMap09 = Observer{ subject = sc1, type = "map", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				local c1 = cs:sample()
				forEachAgent(sc1, function(ag)
					ag:move(c1)
				end)
				
				local randomAgent = sc1:sample()
				
				updateFunc = function(step, soc)
				    killObserver=true
				-- do nothing
				end
			end
		}
		
		local funcForKill = function(ag)
			return 2==ag:getID()
		end
		
		for i = 1, 10, 1 do
			print("STEP: ", i); io.flush()
			updateFunc(i, sc1)
			if ((killObserver and observerMap09) and (i == 8)) then
				print("", "observerMap09:kill", observerMap09:kill(funcForKill))
			end
			delay_s(2)
			print("Members in society 'sc1':", sc1:size())
			cs:notify()
			sc1:notify()
		end
	end
end

-- TESTES OBSERVER MAP
--[[
MAP 01
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação o agente posicionado na primeira das células será removido. O restante do teste deve apresentar apenas 4 agentes, que devem permanecer na posição em que se encontravam.

MAP 02
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação um agente será selecionado aleatoriamente e removido. O restante do teste deve apresentar apenas 4 agentes, que devem permanecer na posição em que se encontravam.

MAP 03
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação os agentes contidos nas células das posições 1,3 e 5 serão removidos. O restante do teste deve apresentar apenas 2 agentes, que devem permanecer na posição em que se encontravam.

MAP 04 / MAP 05
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação todos agentes serão removidos.

MAP 06
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). No instante 5 da simulação todos agentes serão movidos para a célula(1,1), onde deverão permanecer até o fim da execução do teste.

MAP 07
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão inicialmente apresentados 5 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito). A partir do instante 5 da simulação serão inseridos outros 5 agentes na sociedade em questão. Estes agentes serão posicionados nas células restantes da diagonal.

MAP 08
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão apresentados 6 agentes, posicionados nas 5 primeiras células da diagonal (no sentido do canto superior esquerdo para o canto inferior direito) e o último na última célula da diagonal. A cada passo da simulação o agente posicionado na célula(9,9) deverá mudar do estado "foraging" para o estado "sleeping", sendo exibido com cor de acordo com a legenda "rebanhoLeg".

MAP 09
Deverá iniciar apresentando uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um conjunto de caracteres representando agentes. Serão apresentados 5 agentes, posicionados numa única célula, escolhida aleatoriammente.

]]

-- ================================================================================#
-- OBSERVER IMAGE
function test_image( case )
	if( not SKIP ) then
		--obs1 = cs:createObserver("image", {"cover"}, {coverLeg})
		obs1 = Observer { subject = cs, type = "image", attributes = {"cover"}, legends = {coverLeg}}

		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER IMAGE01
				print("IMAGE 01") io.flush()
				observerImage01 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then soc:remove(boi1) end
				end
			end,
			[2] = function(x)
				-- OBSERVER IMAGE02
				print("IMAGE 02") io.flush()
				observerImage02 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then soc:remove(soc:sample()) end
				end
			end,
			[3] = function(x)
				-- OBSERVER IMAGE03
				print("IMAGE 03") io.flush()
				observerImage03 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then
						soc:remove(boi1)
						soc:remove(boi3)
						soc:remove(boi5)
					end
				end
			end,
			[4] = function(x)
				-- OBSERVER IMAGE04
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
			end,
			[5] = function(x)
				-- OBSERVER IMAGE05
				print("IMAGE 05") io.flush()
				observerImage05 = Observer{ subject = sc1, type = "image", attributes= {"currentState"}, observer = obs1, legends = {rebanhoLeg} }
				updateFunc = function(step, soc)
					if(step == 5) then
						--soc:killAll()
						observerImage05:killAll()
						soc:clear()
					end
				end
			end,
			[6] = function(x)
				-- OBSERVER IMAGE06
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
			end,
			[7] = function(x)
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
			end,
			[8] = function(x)
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
			end,
			[9] = function(x)
				-- OBSERVER IMAGE9
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
			end
		}

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
		print(compareDirectory("society","image",case,"."))io.flush()
	end
end

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
--]]

testsSourceCodes = {
	test_image,
	test_map
}

print("**     TESTS FOR SOCIETY OBSERVERS      **\n")
print("** Choose observer type and test case **")
print("(1) Image        ","[ Cases 1..9 ]")
print("(2) Map          ","[ Cases 1..9 ]")

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
