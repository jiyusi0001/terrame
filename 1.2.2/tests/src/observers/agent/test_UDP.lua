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

udpFor = function( killObserver,unitTest)
	for i=1, 25, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify()
		ag1:notify(i)
		if ((killObserver and observerUDP08) and (i == 18)) then
			print("", "observerUDP08:kill", observerUDP08:kill())
		end
		delay_s(2)
	end
	unitTest:assert_true(true) 
end

local observersUDPTest = UnitTest {
	test_udp01 = function(unitTest)
		--OBSERVER UDPSENDER 01
		print("OBSERVER UDPSENDER 01")
		observerUDP01 = Observer{ subject = ag1, type = "udpsender" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP01.type)
	end,
	test_udp02 = function(unitTest)
		--OBSERVER UDPSENDER 02
		print("OBSERVER UDPSENDER 02")
		observerUDP02 = Observer{ subject = ag1, type = "udpsender", attributes={} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP02.type)
	end,
	test_udp03 = function(unitTest)
		--OBSERVER UDPSENDER 03
		print("OBSERVER UDPSENDER 03")
		observerUDP03 = Observer{ subject = ag1, type = "udpsender",hosts ={}, attributes={} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP03.type)
	end,
	test_udp04 = function(unitTest)
		--OBSERVER UDPSENDER 04
		print("OBSERVER UDPSENDER 04")
		observerUDP04 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState"} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP04.type)
	end,
	test_udp05 = function(unitTest)
		--OBSERVER UDPSENDER 05
		print("OBSERVER UDPSENDER 05")
		observerUDP05 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"}, port=TME_UDPPort}
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP05.type)
	end,
	test_udp06 = function(unitTest)
		--OBSERVER UDPSENDER 06
		IP1 = TME_UDPHost[1]
		print("OBSERVER UDPSENDER 06")
		observerUDP06 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"}, port=TME_UDPPort, hosts = {IP1} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP06.type)
	end,
	test_udp07 = function(unitTest)
		--OBSERVER UDPSENDER 07
		IP1 = TME_UDPHost[1]
		IP2 = TME_UDPHost[2]
		print("OBSERVER UDPSENDER 07")
		observerUDP07 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"},
		port=TME_UDPPort, hosts = {IP1,IP2} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP07.type)
	end,
	test_udp08 = function(unitTest)
		--OBSERVER UDPSENDER 08
		IP1 = TME_UDPHost[1]
		IP2 = TME_UDPHost[2]
		print("OBSERVER UDPSENDER 08")
		observerUDP08 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"},
		port=TME_UDPPort, hosts = {IP1,IP2} }
		udpFor(true,unitTest)
		unitTest:assert_equal("udpsender",observerUDP08.type)
	end
}

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 25 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e seu atributo "currenState".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e seus atributos "currenState" e "energy".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 06
A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações do agente "ag1" e seus atributos "currentState" e "energy".
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 07
A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações do agente "ag1" e seus atributos "currentState" e "energy".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 08
Idem UDPSENDER 07.

todo]]

observersUDPTest:run()
os.exit(0)
