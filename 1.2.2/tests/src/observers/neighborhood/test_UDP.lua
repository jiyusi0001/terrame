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
--			Breno Almeida Pereira
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs1 = CellularSpace{xdim = 20, value = 0}

forEachCell(
	cs1,
	function(cell)
		cell.dist_roads = 10 * (cell.x * cell.y)/(cell.x + cell.y)
	end
)

cs1:createNeighborhood{ name = "Moore_test1", strategy = "moore", self = false }

local maxWeight = 0;
local minWeight = math.huge;
local maxDist = 0;
local minDist = math.huge;

forEachCell(
	  cs1,
	  function(cell)
		
		  if(cell.dist_roads > maxDist)then
			  maxDist = cell.dist_roads;
		  end	
		  if(cell.dist_roads < minDist)then
			  minDist = cell.dist_roads;
		  end
		
		  forEachNeighbor(
			  cell, 
			  "Moore_test1",
			  function(cell, neigh, weight)
				  if(weight > maxWeight)then
					  maxWeight = weight;
				  end
				  if(weight < minWeight)then
					  minWeight = weight;
				  end
			  end
		  )
	   end
)

cs1:notify()

obsNeigh = nil

udpFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i)
		cs1.counter = i
		cs1:notify(i)
		value = 1 + (i*15)
		if ((killObserver and observerUDP07) and (i == 8)) then
			print("", "observerUDP07:kill", observerUDP07:kill())
		end

		delay_s(1)
	end
	unitTest:assert_true(true) 

end

local observersUDPTest = UnitTest {
	test_udp01 = function(UnitTest)
		-- OBSERVER UDPSENDER 01
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 01")
            	observerUDP01 = Observer{ subject = cs1, type = "udpsender", port="54544" }
	       udpFor(false,unitTest)
               unitTest:assert_equal("udpsender",observerUDP01.type)
		
	end,
	test_udp02 = function(unitTest) 
		-- OBSERVER UDPSENDER 02
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 02")
   	observerUDP02 = Observer{ subject = cs1, type = "udpsender", attributes = {}, port="54544" }
	       udpFor(false,unitTest)
               unitTest:assert_equal("udpsender",observerUDP02.type)

	end,
	test_udp03 = function(unitTest) 
		-- OBSERVER UDPSENDER 03
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 03")
            	observerUDP03 = Observer{ subject = cs1, type = "udpsender", hosts = {}, attributes = {}, port="54544" }
	       udpFor(false,unitTest)
               unitTest:assert_equal("udpsender",observerUDP03.type)

	end,
	test_udp04 = function(unitTest) 
		-- OBSERVER UDPSENDER 04
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 04")
            	observerUDP04 = Observer{ subject = cs1, type = "udpsender", attributes = {"value"}, port="54544" }
	       udpFor(false,unitTest)
               unitTest:assert_equal("udpsender",observerUDP04.type)

	end,
	test_udp05 = function(unitTest) 
		-- OBSERVER UDPSENDER 05
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 05")
            	observerUDP05 = Observer{ subject = cs1, type = "udpsender", attributes = {"value"}, port="54544", hosts = {IP1} }
	       udpFor(false,unitTest)
               unitTest:assert_equal("udpsender",observerUDP05.type)

	end,
	test_udp06 = function(unitTest) 
		-- OBSERVER UDPSENDER 06
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 06")
            	observerUDP06 = Observer{ subject = cs1, type = "udpsender", attributes = {"value"}, port="54544", hosts = {IP1,IP2} }
	       udpFor(false,unitTest)
               unitTest:assert_equal("udpsender",observerUDP06.type)

	end,
	test_udp07 = function(unitTest) 
		-- OBSERVER UDPSENDER 07
		IP1 = "127.0.0.1" 
	       	IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 07")
            	observerUDP07 = Observer{ subject = cs1, type = "udpsender", attributes = {"value"}, port="54544", hosts = {IP1,IP2} }
	       udpFor(true,unitTest)
               unitTest:assert_equal("udpsender",observerUDP07.type)

	end
}

observersUDPTest:run()
os.exit(0)		
