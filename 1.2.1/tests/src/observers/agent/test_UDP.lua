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



udpFor = function( killObserver )
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
end

local observersUDPTest = UnitTest {
	test_udp1 = function(self)
		--OBSERVER UDPSENDER 01
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 01")
		--@DEPRECATED
		--ag1:createObserver("udpsender")
		observerUDP01 = Observer{ subject = ag1, type = "udpsender" }
		udpFor(false)
	end,
	test_udp2 = function(self)
		--OBSERVER UDPSENDER 02
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 02")
		--@DEPRECATED
		--ag1:createObserver("udpsender", {})
		observerUDP02 = Observer{ subject = ag1, type = "udpsender", attributes={} }
		udpFor(false)
	end,
	test_udp3 = function(self)
		--OBSERVER UDPSENDER 03
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 03")
		--@DEPRECATED
		--ag1:createObserver("udpsender", {}, {})	--??
		observerUDP03 = Observer{ subject = ag1, type = "udpsender",hosts ={}, attributtes={} }
		udpFor(false)
	end,
	test_udp4 = function(self)
		--OBSERVER UDPSENDER 04
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 04")
		--@DEPRECATED
		--ag1:createObserver("udpsender",{"currentState"})
		observerUDP04 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState"} }
		udpFor(false)
	end,
	test_udp5 = function(self)
		--OBSERVER UDPSENDER 05
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 05")
		--@DEPRECATED
		--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544"})
		observerUDP05 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"}, port="54544" }
		udpFor(false)
	end,
	test_udp6 = function(self)
		--OBSERVER UDPSENDER 06
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 06")
		--@DEPRECATED
		--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544", IP1})
		observerUDP06 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"}, port="54544", hosts = {IP1} }
		udpFor(false)
	end,
	test_udp7 = function(self)
		--OBSERVER UDPSENDER 07
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 07")
		--@DEPRECATED
		--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544", IP1, IP2})
		observerUDP07 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"},
		port="54544", hosts = {IP1,IP2} }
		udpFor(false)
	end,
	test_udp8 = function(self)
		--OBSERVER UDPSENDER 08
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 08")
		--@DEPRECATED
		--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544", IP1, IP2})
		observerUDP08 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"},
		port="54544", hosts = {IP1,IP2} }
		udpFor(true)
	end
}

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 25 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e seu atributo "currenState".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e seus atributos "currenState" e "energy".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto "666".
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
todo]]

observersUDPTest:run()
os.exit(0)
