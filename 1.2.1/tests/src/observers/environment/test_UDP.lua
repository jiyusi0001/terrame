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

-- ev = Event{
-- time = 0,
-- action = function(event)
-- at1:execute(event) 
-- print("step", event:getTime()) io.flush()
-- return true 
-- end 
-- }

t = Timer{
	Event{ time = 0, period = 1, action = function(event) 
			--print("step:", event:getTime())  io.flush()

			at1:execute(event) 
			env:notify(event:getTime())

			env.counter = event:getTime() + 1
			env.temperature = event:getTime() * 2

			-- delay_s(1)

			if ((killObserver and observerKill) and (event:getTime() == 8)) then
				print("", "env:kill", env:kill(observerKill))
			end
			return true 
		end 
	}
}

-- --[[
-- t = Timer{
-- Pair {
-- Event{ time = 0, period = 1, priority=1},
-- Action {function(event) at1:execute(event) return true end }
-- }
-- }
-- ]]

env = Environment{ 
	id = "MyEnvironment",
	c1 = cs,
	-- verificar. funciona no linux. não funciona no windows.
	-- erro: index out of bounds
	--at1 = at1,
	--ag1 = ag1,
	t = t,
	counter = 0,
	temperature = 0
}
--env:add(cs)
env:add(t)

udpFor = function( killObserver )
	if ((killObserver and observerUDP06) and (i == 8)) then
		print("", "observerUDP06:kill", observerUDP06:kill())
	end
	env:execute(10)
end

local observersUDPTest = UnitTest {
	test_udp01 = function(unitTest) 
		--OBSERVER UDPSENDER 01
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 01") io.flush()
		--@DEPRECATED
		--env:createObserver("udpsender")
		observerUDP01=Observer{subject=env, type="udpsender"}
		udpFor(false)
	end,
	test_udp02 = function(unitTest) 
		--OBSERVER UDPSENDER 02
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 02") io.flush()
		--@DEPRECATED
		--env:createObserver("udpsender", {})
		observerUDP02=Observer{subject=env, type="udpsender",attributes={}}
		udpFor(false)
	end,
	test_udp03 = function(unitTest) 
		--OBSERVER UDPSENDER 03
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 03") io.flush()
		--@DEPRECATED
		--env:createObserver("udpsender", {}, {})
		observerUDP03=Observer{subject=env, type="udpsender", attributes={}}
		udpFor(false)
	end,
	test_udp04 = function(unitTest) 
		--OBSERVER UDPSENDER 04
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 04") io.flush()
		--@DEPRECATED
		--env:createObserver("udpsender",{"t"},{"54544"})
		observerUDP04=Observer{subject=env, type="udpsender",attributes={"t"},port="54544"}
		udpFor(false)
	end,
	test_udp05 = function(unitTest) 
		--OBSERVER UDPSENDER 05
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 05") io.flush()
		--@DEPRECATED
		--env:createObserver("udpsender",{"t"},{"54544", IP1})
		observerUDP05=Observer{subject=env, type="udpsender",attributes={"t"},port="54544",host={IP1}}
		udpFor(false)
	end,
	test_udp06 = function(unitTest) 
		--OBSERVER UDPSENDER 06
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		print("OBSERVER UDPSENDER 06") io.flush()
		--@DEPRECATED
		--env:createObserver("udpsender",{"t"},{"54544", IP1, IP2})
		observerUDP06=Observer{subject=env, type="udpsender",attributes={"t"},port="54544",host={IP1,IP2}}
		udpFor(true)
	end
}
-- TESTES OBSERVER UDPSENDER
--[[
UDPSENDER01 / UDPSENDER02 / UDPSENDER03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?11?0?soilWater?1?0?cObj_?3?Lua-Address(UD):0x861fe4c?Lin?1?0?y?1?0?x?1?0?object_id0?3?C00L00?Col?1?0?height_?1?0?past?3?Lua-Address(TB):0x8622478?agents_?3?Lua-Address(TB):0x8606658?objectId_?3?C00L00??	

UDPSENDER04

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater", "height_" e "counter".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater", "height_" e counter
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??
]]

observersUDPTest:run()
os.exit(0)
