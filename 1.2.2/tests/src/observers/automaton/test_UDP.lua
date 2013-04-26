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
-- 			Breno Almeida Pereira
-------------------------------------------------------------------------------------------

dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

udpFor = function (killObserver,unitTest)
	for i=1, 10 , 1 do
		print("STEP: ", i) 
		cs:notify(i)
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerUDP08) and (i == 8)) then 
			print("", "observerUDP08:kill", observerUDP08:kill())
		end
		delay_s(1)
	end  
	unitTest:assert_true(true) 
end

MAX_COUNT = 9
cs = CellularSpace{ xdim = 0}
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
	end
end

state1 = State{
	id = "seco",
	Jump{
		function( event, agent, cell )
			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end,
		target = "molhado"
	}
}

state2 = State{
	id = "molhado",
	Jump{
		function( event, agent, cell )

			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end, 
		target = "seco"
	}
}

at1 = Automaton{
	id = "MyAutomaton",
	it = Trajectory{
		target = cs, 
		select = function(cell)
			local x = cell.x - 5;
			local y = cell.y - 5;
			return (x*x) + (y*y)  - 16 < 0.1
		end
	},
	soilWater = 0,
	acum = 0,
	cont  = 0,
	curve = 0,-- uma curva para o observer chart
	st2 = state2,
	st1 = state1,
}

env = Environment{ 
	id = "MyEnvironment"
}

t = Timer{
	Event{ time = 0, action = function(event) at1:execute(event) return true end }
}
-- insert CellularSpaces before Automata, Agents and Timers
env:add( cs )
env:add( at1 )

ev = Event{ time = 1, period = 1, priority = 1 }

at1:setTrajectoryStatus( true )

-- Enables kill an observer
killObserver = false

middle = math.floor(#cs.cells/2)
cell = cs.cells[middle]

local observersUDPTest = UnitTest {
	test_udp01 = function(unitTest)
		--OBSERVER UDPSENDER 01
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 01") io.flush()
		observerUDP01 = Observer{ subject = at1, type = "udpsender", port="54544"}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP01.type)
	end,
	test_udp02 = function(unitTest)
		--OBSERVER UDPSENDER 02
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 02") io.flush()
		observerUDP02 = Observer{ subject = at1, type = "udpsender", attributes = {}, port="54544"}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP02.type)
	end,
	test_udp03 = function(unitTest)
		--OBSERVER UDPSENDER 03
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 03") io.flush()
		observerUDP03 = Observer{ subject = at1, type = "udpsender", hosts = {}, attributes = {}, port="54544"}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP03.type)
	end,
	test_udp04 = function(unitTest)
		--OBSERVER UDPSENDER 04
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 04") io.flush()
		observerUDP04 = Observer{ subject = at1, type = "udpsender", attributes = {"currentState"}, port="54544"}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP04.type)
	end,
	test_udp05 = function(unitTest)
		--OBSERVER UDPSENDER 05
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 05") io.flush()
		observerUDP05 = Observer{ subject = at1, type = "udpsender", attributes = {"currentState","soilWater"}, port="54544"}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP05.type)
	end,
	test_udp06 = function(unitTest)
		--OBSERVER UDPSENDER 06
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 06") io.flush()
		observerUDP06 = Observer{ subject = at1, type = "udpsender", attributes = {"currentState","soilWater"}, port="54544", hosts = {IP1}}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP06.type)
	end,
	test_udp07 = function(unitTest)
		--OBSERVER UDPSENDER 07
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 07") io.flush()
		observerUDP07 = Observer{ subject = at1, type = "udpsender", attributes = {"currentState","soilWater"}, port="54544", hosts = {IP1,IP2}}
		udpFor(false, unitTest)
		unitTest:assert_equal("udpsender",observerUDP07.type)
	end,
	test_udp08 = function(unitTest)
		--OBSERVER UDPSENDER 08
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 08") io.flush()
		observerUDP08 = Observer{ subject = at1, type = "udpsender", attributes = {"currentState","soilWater"}, port="54544", hosts = {IP1,IP2}}
		udpFor(true, unitTest)
		unitTest:assert_equal("udpsender",observerUDP08.type)
	end

}

observersUDPTest:run()
os.exit(0)
