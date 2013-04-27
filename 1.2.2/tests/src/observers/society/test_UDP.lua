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
--      Breno Almeida Pereira
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs = CellularSpace {
	xdim = 10
}

forEachCell(cs, function(cell)
	cell.cover = "pasture"
end)

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
	instance = boi(1),
	quantity = 0,
	value = 0
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

udpFor = function( killObservers,unitTest )
	local funcForKill = function(ag)
			return 2==ag:getID()
	end
		
	for i = 1, 10, 1 do
		print("STEP: ", i); io.flush()
		updateFunc(i, sc1)
		if ((killObserver and observerUDP08) and (i == 8)) then
			print("", "observerUDP08:kill", observerUDP08:kill(funcForKill))
		end
		delay_s(2)
		print("Members in society 'sc1':", sc1:size())
		cs:notify()
		sc1:notify()
	end
	unitTest:assert_true(true)
end

local observersUDPTest = UnitTest {
	test_udp01 = function(unitTest)
		-- OBSERVER UDPSENDER 01
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 01") io.flush()
		observerUDP01 = Observer{ subject = sc1, type = "udpsender", port = "54544"}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP01.type)
	end,
	test_udp02 = function(unitTest)
		-- OBSERVER UDPSENDER 02
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 02") io.flush()
		observerUDP02 = Observer{ subject = sc1, type = "udpsender", attributes = {}, port = "54544"}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP02.type)
	end,
	test_udp03 = function(unitTest)
		-- OBSERVER UDPSENDER 03
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 03") io.flush()
		observerUDP03 = Observer{ subject = sc1, type = "udpsender", hosts = {}, attributes = {}, port = "54544"}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP03.type)
	end,
	test_udp04 = function(unitTest)
		-- OBSERVER UDPSENDER 04
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 04") io.flush()
		observerUDP04 = Observer{ subject = sc1, type = "udpsender", attributes = {"quantity"}, port = "54544"}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP04.type)
	end,
	test_udp05 = function(unitTest)
		-- OBSERVER UDPSENDER 05
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 05") io.flush()
		observerUDP05 = Observer{ subject = sc1, type = "udpsender", attributes = {"quantity","value"}, port = "54544"}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP05.type)
	end,
	test_udp06 = function(unitTest)
		-- OBSERVER UDPSENDER 06
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 06") io.flush()
		observerUDP06 = Observer{ subject = sc1, type = "udpsender", attributes = {"quantity","value"}, port = "54544", hosts = {IP1}}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP06.type)
	end,
	test_udp07 = function(unitTest)
		-- OBSERVER UDPSENDER 07
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 07") io.flush()
		observerUDP07 = Observer{ subject = sc1, type = "udpsender", attributes = {"quantity","value"}, port = "54544", hosts = {IP1, IP2}}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP07.type)
	end,
	test_udp08 = function(unitTest)
		-- OBSERVER UDPSENDER 08
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 08") io.flush()
		observerUDP08 = Observer{ subject = sc1, type = "udpsender", attributes = {"quantity","value"}, port = "54544", hosts = {IP1, IP2}}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		udpFor(true,unitTest)
		unitTest:assert_equal("udpsender",observerUDP08.type)
	end
}

observersUDPTest:run()
os.exit(0)
