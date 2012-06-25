-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--d
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

mim = 0
max = 9
start = 10

--require "XDebug"

-- define o espaco celular
cs = CellularSpace{ xdim = 0}

for i = 1, 10, 1 do 
	for j = 1, 10, 1 do 
		c = Cell{ cover = AGUA,agents_ = {}}
		c.height_ = i
		c.path = 0
		c.x = i - 1
		c.y = j - 1
		c.cont=i*j
		c.cover = 1
		cs:add( c )
	end
end

function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end

-- Define a trajetória tr1

down = 1
up = 2
left = 3
right = 4

tr1 = Trajectory{
	target = cs,
select = function(cell)
	if((cell.cont <= max+1 and cell.cont > mim+1) and cell.x==mim) then
		cell.path = up
		return true
	end
	if((cell.cont <= max and cell.cont > mim) and cell.y==mim) then
		cell.path = right
		return true
	end
	if((cell.cont >= max and cell.cont <= max*max+2*max+1) and cell.x == max) then
		cell.path = down
		return true
	end
	return false
end,
sort = function(a,b)
	if(a.path == right) then	
		return a.x<b.x 
	elseif(a.path == left) then	
		return a.x>b.x 
	elseif(a.path == down) then
		return a.y<b.y;	
	elseif(a.path == up) then
		return a.y>b.y
	end
end
}

-- Define a trajetória tr2

oldFilter = function(cell)
	if(cell.x == cell.y) then
		return true
	end
	return false
end

oldSort = function(a,b)
	return a.x<b.x
end


newFilter = function(cell)
	if(cell.x+cell.y == 9) then
		return true
	end
	return false
end

newSort = function(a,b)
	return a.x<b.x
end

tr2 = Trajectory{
target = cs,
select = oldFilter,
sort = newSort
}

-- Define as legendas

coverLeg = Legend{
type = "number",
groupingMode = "uniquevalue",
slices = 5,
precision = 6,
stdDeviation = "none",
maximum = 1,
minimum = 0,
colorBar = {
	{
		color = "red", 
		value = 1
	},
	{
		color = "black",
		value = 0
	}						
}
}

tr1Leg = Legend {
type = "number",
groupingMode = "uniquevalue",
stdDeviation = "none",
maximum = 28,
minimum = 0,
slices = 28,
precision = 2,
colorBar = {
	{
		color = "green",
		value = 0
	},
	{	
		color = "blue", 
		value = 28
	}
}
}

tr2Leg = Legend {
type = "number",
groupingMode = "uniquevalue",
stdDeviation = "none",
maximum = 10,
minimum = 0,
slices = 10,
precision = 2,
colorBar = {
	{
		color = "red",
		value = 0
	},
	{	
		color = "yellow",
		value = 10
	}
}
}

-- Enables kill an observer
killObserver = false


--=============================================================--]]

-- OBSERVER IMAGE
function test_Image( case)
	if( not SKIP ) then
		obsImage = Observer{ subject = cs, type = "image", attributes={"cover"}, legends = {coverLeg} }
		--obsImage = cs:createObserver("image", {"cover"}, {coverLeg})

		switch( case ) : caseof {

		[1] = function(x)
			-- OBSERVER IMAGE 01 
			print("OBSERVER IMAGE 01") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "image" )
			observerImage01 = Observer{ subject = tr1, type = "image" }
		end,
		[2] = function(x)
			-- OBSERVER IMAGE 02 
			print("OBSERVER IMAGE 02") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "image", {obsImage} )
			observerImage02 = Observer{ subject = tr1, type = "image", observer = obsImage}
		end,
		[3] = function(x)
			-- OBSERVER IMAGE 03
			print("OBSERVER IMAGE 03") io.flush()
			--@DEPRECATED
			--tr1:createObserver("image", {cs})
			observerImage03 = Observer{ subject = tr1, type = "image"}
		end,
		[4] = function(x)
			-- OBSERVER IMAGE 04
			print("OBSERVER IMAGE 04") io.flush()
			--@DEPRECATED
			--tr1:createObserver("image", {cs,obsImage})
			observerImage04 = Observer{ subject = tr1, type = "image", observer = obsImage}
		end,
		[5] = function(x) 
			-- OBSERVER IMAGE 05
			print("OBSERVER IMAGE 05") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
			observerImage05=Observer{subject=tr1, type = "image",legends={tr1Leg}, observer = obsImage }
		end,
		[6] = function(x)
			-- OBSERVER IMAGE 06
			print("OBSERVER IMAGE 06") io.flush()
			tr1.cont=0
			--@DEPRECATED
			--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
			observerImage06=Observer{subject=tr1, type = "image", attributes={"cont"},legends={tr1Leg}, observer = obsImage }
		end,
		[7] = function(x)
			-- OBSERVER IMAGE 07
			print("OBSERVER IMAGE 07") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
			observerImage07=Observer{subject=tr1, type = "image", attributes={"trajectory"},legends={tr1Leg}, observer = obsImage }
		end,
		[8] = function(x) --com trajetória dinamica
			-- OBSERVER IMAGE 08
			print("OBSERVER IMAGE 08") io.flush()
			--@DEPRECATED
			--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
			observerImage08=Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage} 
			-- , path="./Lua",prefix = "prefix_" }
			for i = 1, 10, 1 do
				print("STEP:",i)
				if(i%2==0)then
					tr2:filter(newFilter)
				else
					tr2:filter(oldFilter)
				end
				cs:notify()
				delay_s(1)
			end
		end,
		[9] = function(x) --com trajetória dinamica
			-- OBSERVER IMAGE 09
			print("OBSERVER IMAGE 09") io.flush()
			--@DEPRECATED
			--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
			observerImage09 = Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage}
			-- path="./Lua",prefix = "prefix_" }

			killObserver = true

			for i = 1, 10, 1 do
				print("STEP:", i)
				if(i%2==0)then
					tr2:filter(newFilter)
				else
					tr2:filter(oldFilter)
				end

				if ((killObserver and observerImage09) and (i == 8)) then
					print("", "observerImage09:kill", observerImage09:kill())
				end

				cs:notify()
				delay_s(1)
			end
		end
		}

		if(case < 8) then cs:notify() end
	end
end
--[[
IMAGE 01
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de trajetória sem a identificação do espaço celular e respectivo observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 02
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de trajetória sem a identificação do espaço celular para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 03
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de trajetória sem a identificação do observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 04
Deve gerar uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda padrão (valores únicos entre 0 e 27; cores entre verde e vermelho) de trajetórias.
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.

IMAGE 05
Deve gerar uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda "tr1Leg" (valores únicos entre 0 e 27; cores entre verde e azul).

IMAGE 06
Resultado idêntico ao do observers IMAGE 05, exceto pelo uso do atributo "cont".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

IMAGE 07
Resultado idêntico ao do observers IMAGE 05, exceto pelo uso do atributo "trajectory".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

IMAGE 08
Deve gerar 10 imagens com fundo em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida com cores de acordo com a legenda "tr2Leg" (valores únicos entre 0 e 10; cores entre vermelho e amarelo) e com forma alternando a cada instante sua orientação, da célula do canto superior esquerdo para a célula do canto inferior direito, e vice-versa.

IMAGE 09
Este teste será idêntico ao teste IMAGE 08. Porém, no tempo de simulação 8, o observador "observerImage06" será destruído. As imagens geradas até o 8o. tempo de simulação conterão o agente. As imagens geradas a partir do 9o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.

-- ================================================================================#]]


-- OBSERVER MAP
function test_Map( case)
	if( not SKIP ) then
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }
		--obsMap = cs:createObserver("map", {"cover"}, {coverLeg})

		switch( case ) : caseof {

		[1] = function(x)
			-- OBSERVER MAP 01 
			print("OBSERVER MAP 01") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "map" )
			observerMap01 = Observer{ subject = tr1, type = "map" }
		end,
		[2] = function(x)
			-- OBSERVER MAP 02 
			print("OBSERVER MAP 02") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "map", {obsMap} )
			observerMap02 = Observer{ subject = tr1, type = "map", observer = obsMap}
		end,
		[3] = function(x)
			-- OBSERVER MAP 03
			print("OBSERVER MAP 03") io.flush()
			--@DEPRECATED
			--tr1:createObserver("map", {cs})
			observerMap03 = Observer{ subject = tr1, type = "map"}
		end,
		[4] = function(x)
			-- OBSERVER MAP 04
			print("OBSERVER MAP 04") io.flush()
			--@DEPRECATED
			--tr1:createObserver("map", {cs,obsMap})
			observerMap04 = Observer{ subject = tr1, type = "map", observer = obsMap}
		end,
		[5] = function(x)
			-- OBSERVER MAP 05
			print("OBSERVER MAP 05") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
			observerMap05=Observer{subject=tr1, type = "map", legends={tr1Leg}, observer = obsMap }
		end,
		[6] = function(x)
			-- OBSERVER MAP 06
			print("OBSERVER MAP 06") io.flush()
			tr1.cont=0
			--@DEPRECATED
			--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
			observerMap06=Observer{subject=tr1, type = "map", attributes={"cont"},legends={tr1Leg}, observer = obsMap }
		end,
		[7] = function(x)
			-- OBSERVER MAP 07
			print("OBSERVER MAP 07") io.flush()
			--@DEPRECATED
			--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
			observerMap07=Observer{subject=tr1, type = "map", attributes={"trajectory"},legends={tr1Leg}, observer = obsMap }
		end,
		[8] = function(x) --com trajetória dinamica
			-- OBSERVER MAP 08
			print("OBSERVER MAP 08") io.flush()
			--@DEPRECATED
			--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
			observerMap08=Observer{subject=tr2, type = "map", legends={tr2Leg}, attributes={"trajectory"}, observer = obsMap }
			for i = 1, 10, 1 do
				print("STEP:",i)
				if(i%2==0)then
					tr2:filter(newFilter)
				else
					tr2:filter(oldFilter)
				end
				cs:notify()
				delay_s(1)
			end
		end,
		[9] = function(x) --com trajetória dinamica
			-- OBSERVER MAP 09
			print("OBSERVER MAP 09") io.flush()
			--@DEPRECATED
			--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
			observerMap09=Observer{subject=tr2, type = "map", legends={tr2Leg}, attributes={"trajectory"}, observer = obsMap }

			killObserver = true

			for i = 1, 10, 1 do
				print("STEP:",i)
				if(i%2==0)then
					tr2:filter(newFilter)
				else
					tr2:filter(oldFilter)
				end

				if ((killObserver and observerMap09) and (i == 8)) then
					print("", "observerMap09:kill", observerMap09:kill())
				end

				cs:notify()
				delay_s(1)
			end
		end
		}

		cs:notify()
		cs:notify()
	end
end

--[[
MAP 01
O programa deverá ser abortado. Não é possível utilizar MAP observers de trajectory sem a identificação do espaço celular e respectivo observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 02
O programa deverá ser abortado. Não é possível utilizar MAP observers de trajectory sem a identificação do espaço celular para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 03
O programa deverá ser abortado. Não é possível utilizar MAP observers de trajectory sem a identificação do observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 04
Deve iniciar apresentando uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda padrão (?????) de trajetórias.
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.

MAP 05
Deve iniciar apresentando uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda "tr1Leg" (valores únicos entre 0 e 27; cores entre verde e azul).

MAP 06
Resultado idêntico ao do observers MAP 05, exceto pelo uso do atributo "cont".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

MAP 07
Resultado idêntico ao do observers MAP 05, exceto pelo uso do atributo "trajectory".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

MAP 08
Deve iniciar apresentando uma imagem com fundo em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida com cores de acordo com a legenda "tr2Leg" (valores únicos entre 0 e 10; cores entre vermelho e amarelo) e com forma alternando a cada instante sua orientação, da célula do canto superior esquerdo para a célula do canto inferior direito, e vice-versa.

================================================================================#]]

-- OBSERVER UDP
function test_udp( case)
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		switch( case ) : caseof {
		[1] = function(x)
			-- OBSERVER UDPSENDER 01
			print("OBSERVER UDPSENDER 01") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender")
			observerUdpSender01 = Observer{ subject = cs, type = "udpsender" }
		end,
		[2] = function(x)
			-- OBSERVER UDPSENDER 02
			print("OBSERVER UDPSENDER 02") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender", {})
			observerUdpSender02 = Observer{ subject = cs, type = "udpsender",attributes={} }
		end,
		[3] = function(x)
			-- OBSERVER UDPSENDER 03
			print("OBSERVER UDPSENDER 03") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender", {}, {})
			observerUdpSender03 = Observer{ subject = cs, type = "udpsender",hosts ={}, attributes={} }
		end,
		[4] = function(x)
			-- OBSERVER UDPSENDER 04
			print("OBSERVER UDPSENDER 04") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender", { "path"})
			observerUdpSender04 = Observer{ subject = cs, type = "udpsender", attributes = {"path"} }
		end,
		[5] = function(x)
			-- OBSERVER UDPSENDER 05
			print("OBSERVER UDPSENDER 05") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender", { "cont", "path"}, {"54544"})
			observerUdpSender05 = Observer{ subject = cs, type = "udpsender", attributes = { "cont", "path"},port="54544" }
		end,
		[6] = function(x)
			-- OBSERVER UDPSENDER 06
			print("OBSERVER UDPSENDER 05") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender", { "cont", "path" }, {"54544", IP2})
			observerUdpSender06 = Observer{ subject = cs, type = "udpsender", attributes = { "cont", "path"},port= "54544",hosts={IP2} }
		end,
		[7] = function(x)
			-- OBSERVER UDPSENDER 07
			print("OBSERVER UDPSENDER 07") io.flush()
			--@DEPRECATED
			--cs:createObserver("udpsender", { "cont", "path" }, {"54544", IP1, IP2})
			observerUdpSender07 = Observer{ subject = cs, type = "udpsender", attributes = { "cont", "path"},port = "54544",hosts={IP1,IP2} }
		end
		}

		cs:notify()

	end
end

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do cellular space "cs" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas uma mensagem "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do cellular space "cs" e seu atributo "path".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas uma mensagem "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do cellular space "cs" e seus atributos "cont" e "path".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas uma mensagem "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber uma mensagens idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações do cellular space "cs" e seus atributos "cont" e "path".
Serão disparadas uma mensagem "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações do cellular space "cs" e seus atributos "cont" e "path".
Serão disparadas uma mensagem "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

-- ================================================================================#]]

-- SKIP = false

-- test_Image(TEST)  -- cases of [1..9]
-- test_Map(TEST)  -- cases of [1..9]
-- test_udp(TEST) -- cases of [1..7]

-- Os testes do método "kill" usando o Map e Image devem ser feitos separadamente

testsSourceCodes = {
["Image"] = test_Image,
["Map"] = test_Map,
["UDP"] = test_udp
}

file = io.open("input.txt","r")
obsType = file:read()
testNumber = tonumber(file:read())
file:close()

testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)

