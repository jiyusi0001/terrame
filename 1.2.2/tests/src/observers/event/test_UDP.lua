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


-- TEST FOR EVENT OBSERVERS
ev = Event{ time = 1, period = 1, priority = 1 }

udpFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i) io.flush()
		ev:notify(i)
		if ((killObserver and observerUdpSender07) and (i == 8)) then
			print("", "observerUdpSender07:kill", observerUdpSender07:kill())
		end
	end
	unitTest:assert_true(true) 
end

local observersUDPTest = UnitTest {
	test_UDP01 = function(unitTest) 
		-- OBSERVER UDPSENDER 01
		print("OBSERVER UDPSENDER 01") io.flush()
		observerUdpSender01 = Observer{ subject = ev, type = "udpsender" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender01.type)
	end,
	test_UDP02 = function(unitTest) 
		-- OBSERVER UDPSENDER 02
		print("OBSERVER UDPSENDER 02") io.flush()
		observerUdpSender02 = Observer{ subject = ev, type = "udpsender", attributes = {} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender02.type)
	end,
	test_UDP03 = function(unitTest) 
		-- OBSERVER UDPSENDER 03
		IP2 = TME_UDPHost[2]
		print("OBSERVER UDPSENDER 03") io.flush()
		observerUdpSender03 = Observer{ subject = ev, type = "udpsender",hosts ={IP2} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender03.type)
	end,
	test_UDP04 = function(unitTest) 
		-- OBSERVER UDPSENDER 04
		print("OBSERVER UDPSENDER 04") io.flush()
		observerUdpSender04 = Observer{ subject = ev, type = "udpsender", attributes = {},port=TME_UDPPort }
		udpFor(false,unitTest)	
		unitTest:assert_equal("udpsender",observerUdpSender04.type)
	end,
	test_UDP05 = function(unitTest) 
		-- OBSERVER UDPSENDER 05
		IP1 = TME_UDPHost[1]
		print("OBSERVER UDPSENDER 05") io.flush()
		observerUdpSender05 = Observer{ subject = ev, type = "udpsender", attributes = {},port=TME_UDPPort,hosts={IP1} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender05.type)
	end,
	test_UDP06 = function(unitTest) 
		-- OBSERVER UDPSENDER 06
		IP1 = TME_UDPHost[1]
		IP2 = TME_UDPHost[2]
		print("OBSERVER UDPSENDER 06") io.flush()
		observerUdpSender06 = Observer{ subject = ev, type = "udpsender", attributes = {}, port=TME_UDPPort, hosts={IP1,IP2} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender06.type)
	end,
	test_UDP07 = function(unitTest) 
		-- OBSERVER UDPSENDER 07
		IP1 = TME_UDPHost[1]
		IP2 = TME_UDPHost[2]
		print("OBSERVER UDPSENDER 07") io.flush()
		observerUdpSender07 = Observer{ subject = ev, type = "udpsender", attributes = {}, port=TME_UDPPort, hosts={IP1,IP2} }
		udpFor(true,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender07.type)
	end
}
-- OBSERVER UDP 01 / OBSERVER UDP 02/ OBSERVER UDP 03:
--É esperado que seja recebida 1 mensagem, para a porta padrão, e no host padrão.

--Deverá mostrar os seguintes warnings:
--Warning: The Parameters Table is empty.
--Warning: Port not defined.
--Warning: Observer will send to broadcast.

-- ================================================================================#
-- OBSERVER UDP 04:
--É esperado que seja recebida 1 mensagem, para a porta 
--666, e no host padrão.

--Deverá mostrar os seguintes warnings:
--Warning: Observer will send to broadcast.

-- ================================================================================#
-- OBSERVER UDP 05:
--É esperado que seja recebida 1 mensagem, para a 
--porta 54544, e no host "192.168.0.235".

-- ================================================================================#
-- OBSERVER UDP 06:
--É esperado que seja recebida 1 mensagem, para a 
--porta 54544, e nos hosts "192.168.0.235" e "192.168.0.224".

-- ================================================================================#
-- OBSERVER UDP 07:
-- Este teste será idêntico ao teste OBSERVER UDP 07. Porém, no tempo de simulação 8, o observador "observerUdpSender07" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

observersUDPTest.skips = {"test_UDP5, test_UDP7"}
observersUDPTest:run()
os.exit(0)
