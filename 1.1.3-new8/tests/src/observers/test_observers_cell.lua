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
-- Expected result: X teste, XX assertations, (X passed, X failed, X erros)
-- 
-- TEST FOR CELL OBSERVERS
--
-- Pendências: 
--  1) Não deve mandar warnings com o parametro "-quiet"
--	2) No arquivo CVS o ultimo ";" não deveria ser escrito
--  3) Somente no executavel gerado com CMAKE.  No executavel gerado com QMAKE ou MSVSC++ tudo funciona bem.
--     Teste dos CHAR estão abortando com a seguinte mensagem
--  		QWidget: Must construct a QApplication before a QPaintDevice
-- 		This application has requested the Runtime to terminate it in an unusual way.
-- 		Please contact the application's support team for more information.
--  4) QUANDO AS DUAS APIs são usadas simultaneamente. No teste UDP, um dos observers está registrando 20 mensagens e o outro 19. O correto seriam ambos registrarem 20.
--     QUANDO UMA SÖ API é usada, tudo funciona e são contadas 10 mensagens.

-- data for the tests

dofile (TME_PATH.."/tests/run/run_util.lua")

db = getDataBase()
DBMS = db["dbms"]
PWD = db["pwd"]
DB_VERSION = "4_2_0"
HEIGHT = "height_"

arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present

--require("XDebug")
--require "lunatest"
-- util function
function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end

if(DBMS == 0) then
	cs = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = PWD,
		theme = "cells90x90"
	}
else
	cs = CellularSpace{
		dbType = "ADO",
		database = "database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
		theme = "cells90x90"	
	}		
end
--cs:load();


-- Enables kill an observer
killObserver = false

-- ================================================================================#
-- OBSERVER TEXTSCREEN
function test_TextScreen(case) 
	if( not SKIP) then
		cell01 = cs.cells[1]

		switch( case ) : caseof {
		[1] = function(x) 
				-- OBSERVER TEXTSCREEN 01 
				print("TEXTSCREEN 01")
				--@DEPRECATED
				--cell01:createObserver( "textscreen" )
				observerTextScreen01 = Observer{ subject = cell01, type = "textscreen" }
			end,
		[2] = function(x) 
				-- OBSERVER TEXTSCREEN 02 
				print("TEXTSCREEN 02")
				--@DEPRECATED
				--cell01:createObserver( "textscreen", {} )
				observerTextScreen02 = Observer{ subject = cell01, type = "textscreen", attributes={}}
			end,
		[3] = function(x) 
				-- OBSERVER TEXTSCREEN 03 
				print("TEXTSCREEN 03")
				--@DEPRECATED
				--cell01:createObserver( "textscreen", {}, {} )
				observerTextScreen03 = Observer{ subject = cell01, type = "textscreen", attributes={}}
			end,
		[4] = function(x) 
				-- OBSERVER TEXTSCREEN 04
				print("TEXTSCREEN 04")
				--@DEPRECATED
				--cell01:createObserver( "textscreen", { "soilWater", HEIGHT, "counter" }, {} )
				-- criação de atributo dinâmico antes da especificação de observers	
				cell01.counter = 0
				observerTextScreen04 = Observer{ subject = cell01, type = "textscreen", attributes={ "soilWater", HEIGHT , "counter"}}
			end,
		[5] = function(x) 
				-- OBSERVER TEXTSCREEN 05
				print("TEXTSCREEN 05")
				--@DEPRECATED
				--cell01:createObserver( "textscreen", { "soilWater", HEIGHT, "counter" }, {} )
				-- criação de atributo dinâmico antes da especificação de observers	
				cell01.counter = 0
				observerTextScreen05 = Observer{ subject = cell01, type = "textscreen", attributes={ "soilWater", HEIGHT , "counter"}}

				killObserver =true
			end
		}

		for i = 1, 10, 1 do
			print("step", i)
			cell01.counter = i
			cell01:notify(i)

			if ((killObserver and observerTextScreen05) and (i == 8)) then
				print("", "observerTextScreen05:kill", observerTextScreen05:kill())
			end

			delay_s(1)
		end		
	end
end
-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN01 / TEXTSCREEN02 / TEXTSCREEN03

Deve apresentar na tela uma tabela textual contendo todos os atributos da célula "cell01" no cabeçalho: "soilWater", "cObj_", "Lin", "y", "x", "object_id0", "Col", "height_", "past", "agents_" e "objectId_". Todos estes atributos deverão estar presentes mas, não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 04

Deve apresentar na tela uma tabela textual contendo os atributos "soilWater", "height_" e "counter". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes três atributos. Todas as linhas (com exceção do atributo dinâmico "counter") deverão ser iguais já que o teste em questão não altera valores dos atributos "soilWater" e "height".
Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 05
Este teste será idêntico ao teste TEXTSCREEN 04. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.


]]

-- ================================================================================#
-- OBSERVER LOGFILE	
function test_LogFile( case )
	if( not SKIP ) then
		cell01 = cs.cells[1]

		switch( case ) : caseof {
		[1] = function(x) 				
				--OBSERVER LOGFILE 01 
				print("LOGFILE 01") io.flush()
				--@DEPRECATED				
				--cell01:createObserver( "logfile" )
				observerLogFile01 = Observer{ subject = cell01, type = "logfile" }
			end,
		[2] = function(x) 
				-- OBSERVER LOGFILE 02
				print("LOGFILE 02") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "logfile", {} )
				observerLogFile02 = Observer{ subject = cell01, type = "logfile",attributes={} }
			end,
		[3] = function(x) 
				-- OBSERVER LOGFILE 03
				print("LOGFILE 03") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "logfile", {}, {} )
				observerLogFile03 = Observer{ subject = cell01, type = "logfile", attributes={} } 
			end,
		[4] = function(x) 
				-- OBSERVER LOGFILE 04
				print("LOGFILE 04") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "logfile", {}, {"logfile.csv", ","} )
				observerLogFile04 = Observer{ subject = cell01, type = "logfile",attributes={},outfile = "logfile.csv", separator=","}
			end,
		[5] = function(x) 
				-- OBSERVER LOGFILE 05
				print("LOGFILE 05") io.flush()
				--@DEPRECATED	
				--cell01:createObserver( "logfile", { "soilWater", HEIGHT, "counter" } )
				-- criação de atributo dinâmico antes da especificação de observers
				cell01.counter = 0
				observerLogFile05 = Observer{ subject = cell01, type = "logfile",attributes={"soilWater", HEIGHT,"counter"} }
			end,
		[6] = function(x) 
				-- OBSERVER LOGFILE 06
				print("LOGFILE 06") io.flush()
				--@DEPRECATED	
				--cell01:createObserver( "logfile", { "soilWater", HEIGHT, "counter" } )
				-- criação de atributo dinâmico antes da especificação de observers
				cell01.counter = 0
				observerLogFile06 = Observer{ subject = cell01, type = "logfile",attributes={"soilWater", HEIGHT,"counter"} }

				killObserver = true
			end
		}

		for i = 1, 10, 1 do
			print("step", i)
			cell01.counter = i
			cell01:notify(i)

			if ((killObserver and observerLogFile06) and (i == 8)) then
				print("", "observerLogFile06:kill", observerLogFile06:kill())
			end

			delay_s(1)
		end

	end
end
-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03
Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser uma tabela textual contendo todos os atributos da célula "cell01" no cabeçalho: "soilWater", "cObj_", "Lin", "y", "x", "object_id0", "Col", "height_", "past", "agents_" e "objectId_". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 04
Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE01, 02 e 03) deverão ser apresentados.
Deverão ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.

LOGFILE 05
Deverá ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos "soilWater", "height_" e "counter". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes atributos. Todas as linhas deverão ser semelhantes, com exceção do atributo "counter", já que o teste em questão não altera valores dos atributos "soilWater" e "height".
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

LOGFILE 06
Este teste será idêntico ao teste LOGFILE 05. Porém, no tempo de simulação 8, o observador "observerLogFile06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "result_.csv" conterá apenas informações até o 8o. tempo de simulação

]]

-- ================================================================================#
-- OBSERVER TABLE
function test_Table( case )
	if( not SKIP ) then
		cell01 = cs.cells[1]

		switch( case ) : caseof {
		[1] = function(x) 
				-- OBSERVER TABLE 01 
				print("TABLE 01") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "table" )
				observerTable01 = Observer{ subject = cell01, type = "table" }
			end,                
		[2] = function(x) 
				--OBSERVER TABLE 02 
				print("TABLE 02") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "table", {} )
				observerTable02 = Observer{ subject = cell01, type = "table",attributes={} }
			end,        
		[3] = function(x)
				-- OBSERVER TABLE 03
				print("TABLE 03") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "table", {}, {} )
				observerTable03 = Observer{ subject = cell01, type = "table",attributes={} }
			end,        
		[4] = function(x)
				-- OBSERVER TABLE 04
				print("TABLE 04") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "table", {}, {"attr","vvv"} )
				observerTable04 = Observer{ subject = cell01, type = "table",attributes={},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
			end,
		[5] = function(x)
				-- OBSERVER TABLE 05
				print("TABLE 05") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "table", {"soilWater", HEIGHT, "counter"})
				-- criação de atributo dinâmico antes da especificação de observers
				cell01.counter = 0
				observerTable05 = Observer{ subject = cell01, type = "table",attributes={"soilWater", HEIGHT, "counter"} }
			end,
		[6] = function(x)
				-- OBSERVER TABLE 06
				print("TABLE 06") io.flush()
				--@DEPRECATED
				--cell01:createObserver( "table", {"soilWater", HEIGHT, "counter"})
				-- criação de atributo dinâmico antes da especificação de observers
				cell01.counter = 0
				observerTable06 = Observer{ subject = cell01, type = "table",attributes={"soilWater", HEIGHT, "counter"} }

				killObserver = true
			end

		}

		for i = 1, 10, 1 do
			print("step", i)
			cell01.counter = i
			cell01:notify(i)

			if ((killObserver and observerTable06) and (i == 8)) then
				print("", "observerTable06:kill", observerTable06:kill())
			end

			delay_s(1)
		end
	end
end

-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02 / TABLE 03
Deverá ser apresentada uma tabela contendo todos os atributos da célula "cell01" como linhas da tabela: "soilWater", "cObj_", "Lin", "y", "x", "object_id0", "Col", "height_", "past", "agents_" e "objectId_". Todos estes atributos deverão estar presentes mas, não necessariamente serão apresentados nesta ordem. O atributo dinâmico "counter" deverá ser exibido e seu valor deve variar entre 1 e 10 durante o teste. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 04
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "soilWater", "height_" e "counter". Os atributos devem ser apresentados na ordem em que é feita a especificação. O valor do atributo "counter" deverá variar de 1 a 10 durante o teste. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 05
Este teste será idêntico ao teste TABLE 05. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER DYNAMIC GRAPHIC E OBSERVER GRAPHIC
function test_chart( case )
	if( not SKIP ) then
		cell01 = cs.cells[1]

		switch( case ) : caseof {
		[1] = function(x) 		
				-- OBSERVER DYNAMIC GRAPHIC 01
				print("DYNAMIC GRAPHIC 01") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {})
				-- criação de atributo dinâmico antes da especificação de observers
				cell01.eixoY = 0
				observerDynamicGraphic01 = Observer{ subject = cell01, type = "chart",attributes={} }
			end,

		[2] = function(x) 		
				-- OBSERVER DYNAMIC GRAPHIC 02
				print("DYNAMIC GRAPHIC 02") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"eixoY"})
				-- criação de atributo dinâmico antes da especificação de observers
				cell01.eixoY = 0
				observerDynamicGraphic02 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"} }
			end,
		[3] = function(x) 
				-- OBSERVER DYNAMIC GRAPHIC 03
				print("DYNAMIC GRAPHIC 03") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"eixoY"},{})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoY = 0
				observerDynamicGraphic03 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},title=nil}
			end,
		[4] = function(x) 
				-- OBSERVER GRAPHIC 01
				print("GRAPHIC 01") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0
				observerGraphic01 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX" }
			end,
		[5] = function(x) 
				-- OBSERVER GRAPHIC 02
				print("GRAPHIC 02") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0
				observerGraphic02 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title=nil}
			end,
		[6] = function(x) 
				-- OBSERVER GRAPHIC 03
				print("GRAPHIC 03") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0
				observerGraphic03 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX",title="GraphicTitle"}
			end,
		[7] = function(x) 
				-- OBSERVER GRAPHIC 04
				print("GRAPHIC 04") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0	 	
				observerGraphic04 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX",title="GraphicTitle",curveLabel="CurveTitle" }
			end,
		[8] = function(x) 
				-- OBSERVER GRAPHIC 05
				print("GRAPHIC 05") io.flush()
				--@DEPRECATED
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0
				observerGraphic05 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX",title="GraphicTitle",curveLabel="CurveTitle", yLabel="YLabel"}
			end,
		[9] = function(x) 
				-- OBSERVER GRAPHIC 06
				print("GRAPHIC 06") io.flush()
				--@DEPRECATED	
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0
				observerGraphic06 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", xLabel="XLabel"}
			end,
		[10] = function(x) 
				-- OBSERVER GRAPHIC 07
				print("GRAPHIC 07") io.flush()
				--@DEPRECATED	
				--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.eixoX = 0
				cell01.eixoY = 0
				observerGraphic07 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", xLabel="XLabel"}

				killObserver = true

			end
		}

		for i = 1, 10, 1 do
			print("step", i)
			cell01.eixoX = i + i
			cell01.eixoY = i * i
			--cell01.valor = math.sin(i*3.14/2)	
			cell01:notify(i)

			if ((killObserver and observerGraphic08) and (i == 8)) then
				print("", "observerGraphic08:kill", observerGraphic08:kill())
			end

			delay_s(1)
		end
	end
end

-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
O programa deverá ser abortado. Não é possível utilizar observers GRAPHIC sem a especificação de ao menos um atributo.
Deverá ser emitida uma mensagem de "Warning" informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 02 / DYNAMIC GRAPHIC 03
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "eixoY", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 01 / GRAPHIC 02
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "eixoX" e "eixoY", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 03
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico "GraphicTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 04
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico e título da curva: "GraphicTitle" e "CurveTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do eixo Y" e "título do eixo X").

GRAPHIC 05
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico, título da curva e rótulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "XLabel".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetros "título do eixo X".

GRAPHIC 06
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso de valores específicos na lista de parâmetros.

GRAPHIC 07
Este teste será idêntico ao teste GRAPHIC 06. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER UDP
function test_udp( case )
	if( not SKIP ) then
		cell01 = cs.cells[1]
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"

		switch( case ) : caseof {
		[1] = function(x) 		
				-- OBSERVER UDPSENDER 01
				print("UDPSENDER 01") io.flush()
				--@DEPRECATED				
				--cell01:createObserver("udpsender")
				observerUdpSender01 = Observer{ subject = cell01, type = "udpsender" }
			end,
		[2] = function(x) 		
				-- OBSERVER UDPSENDER 02
				print("UDPSENDER 02") io.flush()
				--@DEPRECATED
				--cell01:createObserver("udpsender", {})
				observerUdpSender02 = Observer{ subject = cell01, type = "udpsender", attributes = {} }
			end,
		[3] = function(x) 
				-- OBSERVER UDPSENDER 03
				print("UDPSENDER 03") io.flush()
				--@DEPRECATED
				--cell01:createObserver("udpsender", {}, {})
				observerUdpSender03 = Observer{ subject = cell01, type = "udpsender",hosts ={}, attributes={} }
			end,
		[4] = function(x) 
				-- OBSERVER UDPSENDER 04
				print("UDPSENDER 04") io.flush()
				--cell01:createObserver("udpsender", { "soilWater", HEIGHT, "counter"})
				observerUdpSender04 = Observer{ subject = cell01, type = "udpsender", attributes = { "soilWater", HEIGHT} }
			end,
		[5] = function(x) 
				-- OBSERVER UDPSENDER 05
				print("UDPSENDER 05") io.flush()
				--@DEPRECATED
				--cell01:createObserver("udpsender", { "soilWater", HEIGHT, "counter" }, {"45454"})
				-- criação de atributos dinâmicos antes da especificação de observers
				cell01.counter = 0
				observerUdpSender05 = Observer{ subject = cell01, type = "udpsender", attributes = { "soilWater", HEIGHT, "counter"},port="456456" }	
			end,
		[6] = function(x) 
				-- OBSERVER UDPSENDER 06
				print("UDPSENDER 06") io.flush()
				--@DEPRECATED
				--cell01:createObserver("udpsender", { "soilWater", HEIGHT, "counter" }, {"45454", IP2})
				observerUdpSender06 = Observer{ subject = cell01, type = "udpsender", attributes = { "soilWater", HEIGHT, "counter"},port= "666",hosts={IP2} }--??
			end,
		[7] = function(x) 
				-- OBSERVER UDPSENDER 07
				--@DEPRECATED
				print("UDPSENDER 07") io.flush()
				--cell01:createObserver("udpsender", { "soilWater", HEIGHT, "counter" }, {"45454", IP2, IP1})
				observerUdpSender07 = Observer{ subject = cell01, type = "udpsender", attributes = { "soilWater", HEIGHT, "counter"},port = "666",hosts={IP1,IP2} }
			end,
		[8] = function(x) 
				-- OBSERVER UDPSENDER 08
				print("UDPSENDER 08") io.flush()
				--@DEPRECATED
				--cell01:createObserver("udpsender", { "soilWater", HEIGHT, "counter" }, {"45454", IP2, IP1})
				observerUdpSender08 = Observer{ subject = cell01, type = "udpsender", attributes = { "soilWater", HEIGHT, "counter"},port = "666",hosts={IP1,IP2} }

				killObserver = true

			end
		}

		for i = 1, 10, 1 do
			print("step", i)
			cell01.counter = i
			cell01:notify(i)

			if ((killObserver and observerUdpSender08) and (i == 8)) then
				print("", "observerUdpSender08:kill", observerUdpSender08:kill())
			end

			delay_s(1)
		end	
	end
end
-- TESTES OBSERVER UDPSENDER
--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell21110soilWater10cObj_3Lua-Address(UD):0x861fe4cLin10y10x10object_id03C00L00Col10height_10past3Lua-Address(TB):0x8622478agents_3Lua-Address(TB):0x8606658objectId_3C00L00	

UDPSENDER 04

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER 05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater", "height_" e "counter".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER 06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater", "height_" e counter
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER 07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

]]

-- SKIP = false
-- TEST = 10

-- test_TextScreen(TEST)  -- cases of [1..5]
-- test_LogFile(TEST)  -- cases of [1..6]
-- test_Table(TEST) -- cases of [1..6]
--test_chart(TEST) -- cases of [1..10]
-- test_udp(TEST) -- cases of [1..8]
--[[
testsSourceCodes = {
["textscreen"] = test_TextScreen, 
["logfile"] = test_LogFile,
["table"] = test_Table,
["chart"] = test_chart,
["udp"] = test_udp
}
--]]
testsSourceCodes = {
test_TextScreen, 
test_LogFile,
test_Table,
test_chart,
test_udp
}

print("**      TESTS FOR CELL OBSERVERS      **\n")io.flush()
print("** Choose observer type and test case **")io.flush()
print("(1) TextScreen   ","[ Cases 1..5  ]")io.flush()
print("(2) LogFile      ","[ Cases 1..6  ]")io.flush()
print("(3) Table	    ","[ Cases 1..6  ]")io.flush()
print("(4) Chart        ","[ Cases 1..10 ]")io.flush()
print("(5) UDP          ","[ Cases 1..8  ]")io.flush()

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
