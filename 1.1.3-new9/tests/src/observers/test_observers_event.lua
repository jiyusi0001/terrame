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


SKIP = true

-- TEST FOR EVENT OBSERVERS

-- util function
function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay	
	while os.time() < time_to do end
end

ev = Event{ time = 1, period = 1, priority = 1 }


-- Enables kill an observer
killObserver = false

-- ================================================================================#
-- OBSERVER TEXTSCREEN
function test_TextScreen(case) 
	if( not SKIP) then

		switch( case ) : caseof {
			[1] = function(x) 
				-- OBSERVER TEXTSCREEN 01 
				print("TEXTSCREEN 01")
				--@DEPRECATED
				--ev:createObserver( "textscreen" )
				observerTextScreen01 = Observer{ subject = ev, type = "textscreen" }
			end,
			[2] = function(x) 
				-- OBSERVER TEXTSCREEN 02 
				print("TEXTSCREEN 02")
				--@DEPRECATED
				--ev:createObserver( "textscreen", {} )
				observerTextScreen02 = Observer{ subject = ev, type = "textscreen", attributes={}}
			end,
			[3] = function(x) 
				-- OBSERVER TEXTSCREEN 03 
				print("TEXTSCREEN 03")
				--@DEPRECATED
				--ev:createObserver( "textscreen", {}, {} )
				observerTextScreen03 = Observer{ subject = ev, type = "textscreen", attributes={}}
			end,
			[4] = function(x) 
				-- OBSERVER TEXTSCREEN 04
				print("TEXTSCREEN 04")
				--@DEPRECATED
				--ev:createObserver( "textscreen", { "time", period, "priority" }, {} )
				observerTextScreen04 = Observer{ subject = ev, type = "textscreen", attributes={ "time", "period"}}
			end,
			[5] = function(x) 
				-- OBSERVER TEXTSCREEN 05
				print("TEXTSCREEN 05")
				--@DEPRECATED
				--ev:createObserver( "textscreen", { "time", period, "priority" }, {} )
				observerTextScreen05 = Observer{ subject = ev, type = "textscreen", attributes={ "time", "period"}}

				killObserver = true
			end
		}

		for i = 1, 10, 1 do
			print("step", i) io.flush()
			ev:notify(i)

			if ((killObserver and observerTextScreen05) and (i == 8)) then
				print("", "observerTextScreen05:kill", observerTextScreen05:kill())
			end

			-- delay_s(1)
		end	

	end
end

-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03

Deve apresentar na tela uma tabela textual contendo todos os atributos do evento "ev" no cabeçalho: "time", "period" e "priority". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 04

Deve apresentar na tela uma tabela textual contendo os atributos "time" e "period". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes dois atributos.
Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 05
Este teste será idêntico ao teste TEXTSCREEN 04. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER LOGFILE
function test_LogFile( case) 
	if(not SKIP ) then
		switch( case ) : caseof {
			[1] = function(x) 
				--OBSERVER LOGFILE 01 
				print("OBSERVER LOGFILE 01") io.flush()
				--@DEPRECATED
				--ev:createObserver( "logfile" )
				observerLogFile01 = Observer{ subject = ev, type = "logfile" }
			end,

			[2] = function(x) 
				-- OBSERVER LOGFILE 02
				print("OBSERVER LOGFILE 02") io.flush()
				--@DEPRECATED
				--ev:createObserver( "logfile", {} )
				observerLogFile02 = Observer{ subject = ev, type = "logfile",attributes={} }
			end,

			[3] = function(x) 
				-- OBSERVER LOGFILE 03
				print("OBSERVER LOGFILE 03") io.flush()
				--@DEPRECATED
				--ev:createObserver( "logfile", {}, {} )
				observerLogFile03 = Observer{ subject = ev, type = "logfile",attributes={} }	
			end,

			[4] = function(x) 
				-- OBSERVER LOGFILE 04
				print("OBSERVER LOGFILE 04") io.flush()
				--@DEPRECATED
				--ev:createObserver( "logfile", {}, {"rain.csv", ","} )
				observerLogFile04 = Observer{ subject=ev,type="logfile",attributes={}, outfile = "logfile.csv", separator="," }	
			end,

			[5] = function(x) 
				-- OBSERVER LOGFILE 05
				print("OBSERVER LOGFILE 05") io.flush()
				--@DEPRECATED
				--ev:createObserver( "logfile", {}, {"rain.csv", ","} )
				observerLogFile05 = Observer{ subject=ev,type="logfile",attributes={}, outfile = "logfile.csv", separator="," }	

				killObserver = true
			end
		}

		for i = 1, 10, 1 do
			print("step", i) io.flush()
			ev:notify(i)

			if ((killObserver and observerLogFile05) and (i == 8)) then
				print("", "observerLogFile05:kill", observerLogFile05:kill())
			end
			-- delay_s(1)
		end
	end
end

-- TESTES OBSERVER LOGFILE
--[[
LOGFILE01 / LOGFILE02 / LOGFILE03

Os arquivos gerados deverão ser idênticos, com nome ("result_.csv" usando ";" como separador). O conteúdo destes arquivos deverá ser uma tabela textual contendo todos os atributos do evento "ev" no cabeçalho: "time", "period" e "priority". Todos estes atributos deverão estar presentes mas, não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser idênticas, já que o teste em questão não altera valores dos atributos.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 04
Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE01, 02 e 03) deverão ser apresentados.
Deverão ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.

LOGFILE 05
Este teste será idêntico ao teste LOGFILE 04. Porém, no tempo de simulação 8, o observador "observerLogFile05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "logfile.csv" conterá apenas informações até o 8o. tempo de simulação


]]

-- ================================================================================#
-- OBSERVER TABLE
function test_Table( case) 
	if(not SKIP ) then
		switch( case ) : caseof {
			[1] = function(x) 
				-- OBSERVER TABLE 01 
				print("OBSERVER TABLE 01") io.flush()
				--@DEPRECATED
				--ev:createObserver("table")
				observerTextScreen01 = Observer{ subject = ev, type = "table" }
			end,

			[2] = function(x) 
				-- OBSERVER TABLE 02 
				print("OBSERVER TABLE 02") io.flush()
				--@DEPRECATED
				--ev:createObserver("table",{})
				observerTextScreen02 = Observer{ subject = ev, type = "table", attributes={} }
			end,
			[3] = function(x)
				-- OBSERVER TABLE 03
				print("TABLE 03") io.flush()
				--@DEPRECATED
				--ev:createObserver( "table", {}, {} )
				observerTable03 = Observer{ subject = ev, type = "table", attributes={} }
			end,        
			[4] = function(x)
				-- OBSERVER TABLE 04
				print("TABLE 04") io.flush()
				--@DEPRECATED
				--ev:createObserver( "table", {}, {"-- ATTRS --","-- VALUES --"} )
				observerTable04 = Observer{ subject = ev, type = "table",attributes={}, xLabel = "-- ATTRS --", yLabel ="-- VALUES --"}
			end,
			[5] = function(x)
				-- OBSERVER TABLE 05
				print("TABLE 05") io.flush()
				--@DEPRECATED
				--ev:createObserver( "table", {"time", "priority"})
				observerTable05 = Observer{ subject = ev, type = "table", attributes={"time", "priority"} }
			end,
			[6] = function(x)
				-- OBSERVER TABLE 06
				print("TABLE 06") io.flush()
				--@DEPRECATED
				--ev:createObserver( "table", {"time", "priority"})
				observerTable06 = Observer{ subject = ev, type = "table", attributes={"time", "priority"} }
				killObserver = true

			end
		}

		for i = 1, 10, 1 do
			print("step", i) io.flush()
			ev:notify(i)

			if ((killObserver and observerTable06) and (i == 8)) then
				print("", "observerTable06:kill", observerTable06:kill())
			end

			-- delay_s(1)
		end
	end
end

-- TESTES OBSERVER TABLE
--[[
TABLE01 / TABLE02 / TABLE03

Deverá ser apresentada uma tabela contendo todos os atributos do evento "ev" como linhas da tabela: "time", "period" e "priority". Todos estes atributos deverão estar presentes mas, não necessariamente serão apresentados nesta ordem. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 04
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "time" e "priority". Os atributos devem ser apresentados na ordem em que é feita a especificação. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 06
Este teste será idêntico ao teste TABLE 04. Porém, no tempo de simulação 8, o observador "observerTable06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.


]]

-- ================================================================================#
-- OBSERVER UDP
function test_UDP( case )
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		switch( case ) : caseof {		
			[1] = function(x) 
				-- OBSERVER UDPSENDER 01
				print("OBSERVER UDPSENDER 01") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender")
				observerUdpSender01 = Observer{ subject = ev, type = "udpsender" }
			end,

			[2] = function(x) 
				-- OBSERVER UDPSENDER 02
				print("OBSERVER UDPSENDER 02") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender", {})
				observerUdpSender02 = Observer{ subject = ev, type = "udpsender", attributes = {} }
			end,

			[3] = function(x) 
				-- OBSERVER UDPSENDER 03
				print("OBSERVER UDPSENDER 03") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender", {}, {})
				observerUdpSender03 = Observer{ subject = ev, type = "udpsender",hosts ={IP2} }
			end,

			[4] = function(x) 
				-- OBSERVER UDPSENDER 04
				print("OBSERVER UDPSENDER 04") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender", {}, {"666"})
				observerUdpSender04 = Observer{ subject = ev, type = "udpsender", attributes = {},port{666} }	
			end,

			[5] = function(x) 
				-- OBSERVER UDPSENDER 05
				print("OBSERVER UDPSENDER 05") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender", {}, {"666", "127.0.0.1"})
				observerUdpSender05 = Observer{ subject = ev, type = "udpsender", attributes = {},port{666},hosts={IP1} }--??
			end,

			[6] = function(x) 
				-- OBSERVER UDPSENDER 06
				print("OBSERVER UDPSENDER 06") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender", {}, {"666", IP1, IP2})
				observerUdpSender06 = Observer{ subject = ev, type = "udpsender", attributes = {}, port{666}, hosts={IP1,IP2} }
			end,

			[7] = function(x) 
				-- OBSERVER UDPSENDER 07
				print("OBSERVER UDPSENDER 07") io.flush()
				--@DEPRECATED
				--ev:createObserver("udpsender", {}, {"666", IP1, IP2})
				observerUdpSender07 = Observer{ subject = ev, type = "udpsender", attributes = {}, port{666}, hosts={IP1,IP2} }

				killObserver = true
			end
		}

		for i = 1, 10, 1 do
			print("step", i) io.flush()
			ev:notify(i)

			if ((killObserver and observerUdpSender07) and (i == 8)) then
				print("", "observerUdpSender07:kill", observerUdpSender07:kill())
			end

			-- delay_s(1)
		end

	end
end

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

SKIP = false

testsSourceCodes = {
	test_TextScreen, 
	test_LogFile,
	test_Table,
	test_UDP
}

print("**     TESTS FOR EVENT OBSERVERS      **\n")
print("** Choose observer type and test case **")
print("(1) TextScreen   ","[ Cases 1..5  ]")
print("(2) LogFile      ","[ Cases 1..5  ]")
print("(3) Table        ","[ Cases 1..6  ]")
print("(4) UDP          ","[ Cases 1..7  ]")

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)