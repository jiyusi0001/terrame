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
dofile (TME_PATH.."/tests/dependencies/TestConf.lua")

--db = getDataBase()
--dbms = db["dbms"]
--PWD = db["pwd"]
DB_VERSION = "4_2_0"
HEIGHT = "height_"

db = getDataBase()
dbms = db["dbms"]
pwd = db["pwd"]

function createCS(dbms, pwd, t)
        -- defines and loads the celular space from a TerraLib theme 
        local cs = nil 
        if(dbms == 0) then 
            cs = CellularSpace{ 
                dbType = "mysql", 
                host = "127.0.0.1", 
                database = "cabeca", 
                user = "root", 
                password = pwd, 
                theme = t 
            } 
        else 
            cs = CellularSpace{ 
                dbType = "ADO", 
                database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb", 
                theme = t     
            }         
        end
    return cs
end

cs1 = createCS(dbms,pwd,"cells90x90")
cs1.soilWater = 0
--cs1[HEIGHT] = 0
cs1.height_=  0

udpFor = function( killObserver,unitTest ) 
	for i = 1, 10, 1 do
		print("STEP: ", i); io.flush()
		cs1:notify(i)
		if ((killObserver and observerUdpSender08) and (i == 8)) then
			print("", "observerUdpSender08:kill", observerUdpSender08:kill())
		end
	end	
	unitTest:assert_true(true) 
end


local observersUDPTest = UnitTest {
	test_udp01 = function(unitTest) 						
		-- OBSERVER UDPSENDER 01
		print("UDPSENDER 01") io.flush()
		observerUdpSender01 = Observer{ subject = cs1, type = "udpsender" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender01.type)
	end,
	test_udp02 = function(unitTest) 		
		-- OBSERVER UDPSENDER 02
		print("UDPSENDER 02") io.flush()
		observerUdpSender02 = Observer{ subject = cs1, type = "udpsender", attributes = {} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender02.type)
	end,
	test_udp03 = function(unitTest)
		-- OBSERVER UDPSENDER 03
		print("UDPSENDER 03") io.flush()
		observerUdpSender03 = Observer{ subject = cs1, type = "udpsender",hosts ={}, attributes={} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender03.type)
	end,
	test_udp04 = function(unitTest)
		-- OBSERVER UDPSENDER 04
		IP1 = "192.168.0.12"
		IP2 = "192.168.0.255"
		print("UDPSENDER 04") io.flush()
		observerUdpSender04 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender04.type)
	end,
	test_udp05 = function(unitTest)
		-- OBSERVER UDPSENDER 05
		print("UDPSENDER 05") io.flush()
		observerUdpSender05 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT},port=TME_UDPPort }
		udpFor(false,unitTest)	
		unitTest:assert_equal("udpsender",observerUdpSender05.type)
	end,
	test_udp06 = function(unitTest)
		-- OBSERVER UDPSENDER 06
		IP2 = TME_UDPHost[2]
		print("UDPSENDER 06") io.flush()
		observerUdpSender06 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT},port=TME_UDPPort,hosts={IP2} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender06.type)
	end,
	test_udp07 = function(unitTest)
		-- OBSERVER UDPSENDER 07
		IP1 = TME_UDPHost[1]
		IP2 = TME_UDPHost[2]
		print("UDPSENDER 07") io.flush()
		observerUdpSender07 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT},port = TME_UDPPort,hosts={IP1,IP2} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender07.type)
	end,
	test_udp08 = function(unitTest)
		-- OBSERVER UDPSENDER 08
		IP1 = TME_UDPHost[1]
		IP2 = TME_UDPHost[2]
		print("UDPSENDER 08") io.flush()
		observerUdpSender08 = Observer{ subject = cs1, type = "udpsender", attributes = {},port = TME_UDPPort,hosts={IP1,IP2} }
		udpFor(true,unitTest)
		unitTest:assert_equal("udpsender",observerUdpSender08.type)
	end
}

-- TESTES OBSERVER UDPSENDER
--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do espaço celular "cs1" e os dados referente aos atributos de todas suas células.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:


UDPSENDER 04
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cs1" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER 05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cs1" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER 06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação (endereço "IP2"). O cliente deverá receber a cada notificação as informações da célula "cs1" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER 07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". Os clientes deverão receber a cada notificação as informações da célula "cs1" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2?1?2?0?soilWater?1?0?height_?1?0??

UDPSENDER 08
Executando do STEP 1 ao STEP 10, sendo que entre os STEPs 8 e 9, o observerUdpSender08 recebe kill(true). É apresentada uma janela com as udp messages.

]]


observersUDPTest:run()
os.exit(0)
