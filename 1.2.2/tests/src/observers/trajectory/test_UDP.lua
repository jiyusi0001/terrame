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

mim = 0
max = 9
start = 10

cs = CellularSpace{ xdim = 0 }
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
	end,
	valor1 = 1,
	valor2 = 1,
	t = 0
}

udpFor = function(killObserver,unitTest)
	for i = 1, 10, 1 do
		print("STEP:",i)io.flush()
		tr1.valor1 = tr1.valor1*i
		tr1.valor2 = 1/tr1.valor2*i
		tr1.t = i*2
		tr1:notify(i)
		if ((killObserver and observerUDP08) and (i == 8)) then
			print("", "observerUDP08:kill", observerUDP08:kill())io.flush()
		end
		delay_s(10)
	end
	unitTest:assert_true(true)
end

local observersUDPTest = UnitTest {
	test_udp01 = function(unitTest)
		--OBSERVER UDPSENDER 01
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 01")
		observerUDP01 = Observer{ subject = tr1, type = "udpsender", port="54544" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP01.type)
	end,
	test_udp02 = function(unitTest)
		--OBSERVER UDPSENDER 02
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 02")
		observerUDP02 = Observer{ subject = tr1, type = "udpsender", attributes={}, port="54544" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP02.type)
	end,
	test_udp03 = function(unitTest)
		--OBSERVER UDPSENDER 03
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 03")

		observerUDP03 = Observer{ subject = tr1, type = "udpsender",hosts ={}, attributes={}, port="54544" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP03.type)
	end,
	test_udp04 = function(unitTest)
		--OBSERVER UDPSENDER 04
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 04")
		observerUDP04 = Observer{ subject = tr1, type = "udpsender", attributes={"valor1"}, port="54544" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP04.type)
	end,
	test_udp05 = function(unitTest)
		--OBSERVER UD0PSENDER 05
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 05")
		observerUDP05 = Observer{ subject = tr1, type = "udpsender", attributes={"valor1", "valor2"}, port="54544" }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP05.type)
	end,
	test_udp06 = function(unitTest)
		--OBSERVER UDPSENDER 06
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 06")
		observerUDP06 = Observer{ subject = tr1, type = "udpsender", attributes={"valor1", "valor2"}, port="54544", hosts = {IP1} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP06.type)
	end,
	test_udp07 = function(unitTest)
		--OBSERVER UDPSENDER 07
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 07")
		observerUDP07 = Observer{ subject = tr1, type = "udpsender", attributes={"valor1", "valor2"},
		port="54544", hosts = {IP1,IP2} }
		udpFor(false,unitTest)
		unitTest:assert_equal("udpsender",observerUDP07.type)
	end,
	test_udp08 = function(unitTest)
		--OBSERVER UDPSENDER 08
		IP1 = "127.0.0.1" 
		IP2 = "192.168.0.216"
		print("OBSERVER UDPSENDER 08")
		observerUDP08 = Observer{ subject = tr1, type = "udpsender", attributes={"valor1", "valor2"},
		port="54544", hosts = {IP1,IP2} }
		udpFor(true,unitTest)
		unitTest:assert_equal("udpsender",observerUDP08.type)
	end
}

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "tr1" e todos seus atributos. Serão disparadas 10 mensagens "broadcast" direcionadas ao porto padrão "54544". Cada uma das máquinas cliente deve receber 25 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "tr1" e seu atributo "valor1". Serão disparadas 10 mensagens "broadcast" direcionadas ao porto padrão "54544".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "tr1" e seus atributos "valor1" e "valor2". Serão disparadas 10 mensagens "broadcast" direcionadas ao porto "54544". Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 06
A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações do agente "tr1" e seus atributos "valor1" e "valor2". Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 07
A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações do agente "ag1" e seus atributos "valor1" e "valor2". Serão disparadas 10 mensagens "multicast" direcionadas ao porto "54544" das máquinas em questão. Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 08
Este teste será idêntico ao teste 07. Porém, no tempo de simulação 8, o observador "observerUDP08" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

todo]]

observersUDPTest:run()
os.exit(0)
