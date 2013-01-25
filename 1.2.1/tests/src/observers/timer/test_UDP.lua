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
-- Author:     Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--             Rodrigo Reis Pereira
--            Henrique Cota Camêlo
--            Washington Sena França e Silva
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

clock1 = nil
function createTimer(case)
	switch( case ) : caseof {   
		[1] = function(x)
			clock1 = Timer{
				id = "clock1",
				ev1 = Event{time = 1, period = 1, priority = 1,  action = function(event)
						clock1:notify();
						-- print("ev1,period = 1, priority = 1")   io.flush()

						print("step ev1", event:getTime())  io.flush()

						if ((killObserver and observerKill) and (event:getTime() == END_TIME)) then
							print("", "clock1:kill", clock1:kill(observerKill))
						end

						--delay_s(1)
					end},
				ev2 = Event{time = 1, period = 1, priority = 2, action = function(event)
						clock1:notify();
						-- print("ev2,period = 1, priority = 2") io.flush()
						print("step ev2", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev3 = Event{time = 1, period = 1, priority = 3,  action = function(event)
						clock1:notify();
						-- print("ev3,period = 1, priority = 3") io.flush()
						print("step ev3", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev4 = Event{time = 1,   period =1,  priority = 4,  action = function(event)
						clock1:notify();
						-- print("ev4,period = 1, priority = 4") io.flush()
						print("step ev4", event:getTime())  io.flush()
						--delay_s(1)
						--for i = 1,4000000 do end
						io.flush()
					end}
			}
		end,
		[2] = function(x)
			clock1 = Timer{
				id = "clock1",
				ev1 = Event{time = 1, period = 1, priority = 1,  action = function(event)
						clock1:notify();
						-- print("ev1,period = 1, priority = 1") io.flush()

						print("step ev1", event:getTime())  io.flush()

						if ((killObserver and observerKill) and (event:getTime() == END_TIME)) then
							print("", "clock1:kill", clock1:kill(observerKill))
						end
						--delay_s(1)
					end},
				ev2 = Event{time = 1, period = 4, priority = 10, action = function(event)
						clock1:notify();
						-- print("ev2,period = 4, priority = 10") io.flush()
						print("step ev2", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev3 = Event{time = 1, period = 4, priority = 10,  action = function(event)
						clock1:notify();
						-- print("ev3,period = 4, priority = 10") io.flush()
						print("step ev3", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev4 = Event{time = 1,   period = 4,  priority = 10,  action = function(event)
						clock1:notify();
						-- print("ev4,period = kpriority = 10") io.flush()
						print("step ev4", event:getTime())  io.flush()
						--delay_s(1)                                         
						--for i = 1,4000000 do end
						io.flush()
					end}
			}
		end
	}
end

-- Enables kill an observer
killObserver = false
observerKill = nil
END_TIME = 8

udpFor = function(killObserver)
	clock1:execute(10)
	if ((killObserver and observerUdpSender11) and (i == 8)) then
		print("", "observerUdpSender11:kill", observerUdpSender11:kill())
	end
end

local observersUdpTest = UnitTest {
	-- ================================================================================#
	-- OBSERVER UDP
	test_upd01 = function(x)
		-- OBSERVER UDPSENDER 01
		print("OBSERVER UDPSENDER 01")
		--clock1:createObserver("udpsender")
		createTimer(1)
		observerUdpSender01 = Observer{ subject = clock1, type = "udpsender" }
		udpFor(false)
	end,
	test_upd02 = function(x)
		-- OBSERVER UDPSENDER 02
		print("OBSERVER UDPSENDER 02")
		--clock1:createObserver("udpsender", {})
		createTimer(1)
		observerUdpSender02 = Observer{ subject = clock1, type = "udpsender", attributes = {} }
		udpFor(false)
	end,
	test_upd03 = function(x)
		-- OBSERVER UDPSENDER 03
		print("OBSERVER UDPSENDER 03")
		--clock1:createObserver("udpsender", {}, {""})
		createTimer(1)
		observerUdpSender03 = Observer{ subject = clock1, type = "udpsender",hosts ={}, attributes={} }
		udpFor(false)
	end,
	test_upd04 = function(x)
		-- OBSERVER UDPSENDER 04
		print("OBSERVER UDPSENDER 04")
		--clock1:createObserver("udpsender", { }, {"456456", IP2})
		createTimer(1)
		observerUdpSender04 = Observer{ subject = clock1, type = "udpsender", attributes = { },port= "456456",hosts={IP2} }
		udpFor(false)
	end,
	test_upd05 = function(x)
		-- OBSERVER UDPSENDER 05
		print("OBSERVER UDPSENDER 05")
		--clock1:createObserver("udpsender", { }, {"456456", IP1, IP2})
		createTimer(1)
		observerUdpSender05 = Observer{ subject = clock1, type = "udpsender", attributes = { },port = "456456",hosts={IP1,IP2} }
		udpFor(false)
	end,
	test_upd06 = function(x)
		-- OBSERVER UDPSENDER 06
		print("OBSERVER UDPSENDER 06")
		--clock1:createObserver("udpsender")
		createTimer(2)
		observerUdpSender06 = Observer{ subject = clock1, type = "udpsender" }
		udpFor(false)
	end,
	test_upd07 = function(x)
		-- OBSERVER UDPSENDER 07
		print("OBSERVER UDPSENDER 07")
		--clock1:createObserver("udpsender", {})
		createTimer(2)
		observerUdpSender07 = Observer{ subject = clock1, type = "udpsender", attributes = {} }
		udpFor(false)
	end,
	test_upd08 = function(x)
		-- OBSERVER UDPSENDER 08
		print("OBSERVER UDPSENDER 08")
		--clock1:createObserver("udpsender", {}, {""})
		createTimer(2)
		observerUdpSender08 = Observer{ subject = clock1, type = "udpsender",hosts ={}, attributes={} }
		udpFor(false)
	end,
	test_upd09 = function(x)
		-- OBSERVER UDPSENDER 09
		print("OBSERVER UDPSENDER 09")
		--clock1:createObserver("udpsender", { }, {"456456", IP2})
		createTimer(2)
		observerUdpSender09 = Observer{ subject = clock1, type = "udpsender", attributes = { },port= "456456",hosts={IP2} }
		udpFor(false)
	end,
	test_upd10 = function(x)
		-- OBSERVER UDPSENDER 10
		print("OBSERVER UDPSENDER 10")
		--clock1:createObserver("udpsender", { }, {"456456", IP1, IP2})
		createTimer(2)
		observerUdpSender10 = Observer{ subject = clock1, type = "udpsender", attributes = { },port = "456456",hosts={IP1,IP2} }
		udpFor(false)
	end,
	test_upd11 = function(x)
		-- OBSERVER UDPSENDER 11
		print("OBSERVER UDPSENDER 11")
		--clock1:createObserver("udpsender", { }, {"456456", IP1, IP2})
		createTimer(2)
		observerUdpSender11 = Observer{ subject = clock1, type = "udpsender", attributes = { },port = "456456",hosts={IP1,IP2} }
		udpFor(true)
	end
}
-- TESTES OBSERVER UDPSENDER
--[[
UDPSENDER 01/02/03/04/05/06/07/08/09/10/11
São apresentados vários Warnings, reportando uma falha no envio da mensagem. Erro no socket, pois também não consegue enviar a mensagem. Em seguida outro warning é apresentado reduzindo o tamanho do datagram.
Outros dois warnings são mostrados, reportando que a tabela de parâmetros está vazia e outro dizendo que o "Port" não foi definido.

]]

observersUdpTest.skips ={
    "test_upd03",
    "test_upd08"
}
observersUdpTest:run()
os.exit(0)
