-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can TME_LEGEND_COLOR.REDistribute it and/or
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
-- TEST FOR CELLULARSPACE OBSERVERS
--
-- Pendências: 
-- IMAGE
-- 0) TerraME gerado com QMAKE fica visivelmente mais eficiente que o gerado com CMAKE.
-- 1) No testes com IMAGE: O teste não termina quando todas as interfaces gráficas (isto é, threads) são mortas. É preciso pressionar crtl+C. 
--    Porém, no teste IMAGE 04 ou IMAGE 06, a aplicação TerraME termina corretamente.
--    Parece que se a interface for escondida antes do termino da aplicação, os ponteiros da GUI permanecem ativos e a aplicação não termina.
--    É necessario automaticamente matar as GUIs que não estejam visiveis.
-- 2) No testes com IMAGE: As interfaces das imagens estão muito pesadas. O usuário tem dificuldade em interagir com elas. 
-- 3) Test IMAGE 02: Pq vermelho para o preto?
-- 4) Test IMAGE 03: Pq estão sendo geradas 20 imagens?
-- 5) O que é que o teste IMAGE 05 está testando? Só tá usando a API antiga!!!
-- 6) Nenhum dos teste mostra agua correndo morro abaixo ou algo que comprove que o observer desenha bem padrões espaciais calculados 
--    dinamicamente
-- MAP
-- 7) A aplicacao aborta com erro fatal no teste 1. Talvez um bloco "try...catch" deveria tratar essa excessão e terminar suavemente a aplicação.


--obs: O teste de image com mais de um atributo apresentou um erro:
-- ASSERT failure in QList<T>::at: "index out of range", file /usr/include/qt4/QtCore/qlist.h, line 439 Aborted

--require "XDebug"

-- util functions	
function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end	
end


function createMySQLTable()
	local parametrosMySQL = {
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = PWD,
		theme = "cells90x90"
	}
	return parametrosMySQL
end

function createAccessTable()
	local parametrosAccess = {
		dbType = "ADO",
		database = "database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
		theme = "cells90x90"	
	}	
	return parametrosAccess;
end

dofile (TME_PATH.."/tests/run/run_util.lua")
db = getDataBase()
dbms = db["dbms"]
PWD = db["pwd"]
DB_VERSION = "4_2_0"
HEIGHT = "height_"

cs1 = nil
if(dbms == 0) then
	cs1 = CellularSpace(createMySQLTable())
else
	cs1 = CellularSpace(createAccessTable())
end

heightLeg = Legend{
	-- Attribute name:  height
	type = "number",
	grouping = "equalsteps",
	slices = 50,
	precision = 5,
	stdDeviation = "none",
	maximum = 255,
	minimum = 0,
	colorBar = {
		{color = "black", value = 0},
		{color = "white", value = 255}
	},
	stdColorBar = {}
}

heightLeg_GROUP_MODE = Legend{
	-- Attribute name:  height
	type = "number",
	grouping = "equalsteps",
	slices = 50,
	stdDeviation = "none",
	colorBar = {
		{color = "red", value = 0},
		{color = "blue", value = 128},
		{color = "green", value = 255}
	},
	stdColorBar = {
		{color = "white", value = 0},
		{color = "yellow", value = 128},
		{color = "black", value = 255}
	}
}

soilWaterLeg = Legend{
	-- Attribute name:  soilWater
	type = "number",
	grouping = "equalsteps",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 10,
	minimum = 0,
	colorBar = {
		{color = "white", value = 0},
		{color = "blue", value = 10}
	},
	stdColorBar = {}
}

-- Enables kill an observer
killObserver = false

-- ================================================================================#
-- OBSERVER IMAGE
function test_image( case )

	if( not SKIP ) then

		switch( case ) : caseof {
			[1] = function(x) 
				-- OBSERVER IMAGE 01 
				print("IMAGE 01") io.flush()
				--@DEPRECATED
				--cs1:createObserver( "image" )
				observerImage01 = Observer{ subject = cs1, type = "image" }	
			end,
			[2] = function(x) 
				-- OBSERVER IMAGE 02 
				print("IMAGE 02") io.flush()
				--@DEPRECATED
				--cs1:createObserver( "image", {"soilWater"} )
				observerImage02 = Observer{ subject = cs1, type = "image", attributes={"soilWater"}}	
			end,
			[3] = function(x)
				-- OBSERVER IMAGE 03
				print("IMAGE 03") io.flush()
				--@DEPRECATED
				--cs1:createObserver( "image", {"soilWater"}, { soilWaterLeg } )
				observerImage03 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},legends={soilWaterLeg} }	
			end,
			[4] = function(x)
				-- OBSERVER IMAGE 04
				print("IMAGE 04") io.flush()
				--@DEPRECATED
				--cs1:createObserver( "image", {"soilWater"}, {".", "prefix_", soilWaterLeg } )
				observerImage04 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},path=".",prefix = "prefix_",legends={soilWaterLeg } }
			end,
			[5] = function(x)
				-- OBSERVER IMAGE 05
				print("IMAGE 05") io.flush()
				--@DEPRECATED				
				--cs1:createObserver("image", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerImage05 = Observer{ subject = cs1, type = "image", attributes={"soilWater",HEIGHT},legends= {soilWaterLeg, heightLeg} }
			end,

			[6] = function(x)
				-- OBSERVER IMAGE 06
				print("IMAGE 06") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["quantil"]
				--@DEPRECATED
				--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
				observerImage06 = Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[7] = function(x)
				-- OBSERVER IMAGE 07
				print("IMAGE 07") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["uniquevalue"]
				--@DEPRECATED
				--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
				observerImage07 = Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[8] = function(x)
				-- OBSERVER IMAGE 08
				print("IMAGE 08") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["full"]
				--@DEPRECATED
				--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
				observerImage08= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[9] = function(x)
				-- OBSERVER IMAGE 09
				print("IMAGE 09") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["half"]
				--@DEPRECATED
				--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
				observerImage09= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[10] = function(x)
				-- OBSERVER IMAGE 10
				print("IMAGE 10") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
				--@DEPRECATED
				--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
				observerImage10= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[11] = function(x)
				-- OBSERVER IMAGE 11
				print("IMAGE 11") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
				--@DEPRECATED
				--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
				observerImage11= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }

				killObserver= true

			end
		}

		for i = 1, 10, 1 do
			print("STEP: ", i); io.flush()
			cs1:notify()
			forEachCell(cs1, function(cell)
				cell.soilWater = i
			end)

			if ((killObserver and observerImage11) and (i == 8)) then
				print("", "observerImage11:kill", observerImage11:kill())
			end

			delay_s(1)
		end
	end
end

-- TESTES OBSERVER IMAGE
--[[
IMAGE 01
O programa deverá ser abortado. Não é possível utilizar observers IMAGE sem a identificação dos parâmetros a serem plotados.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 02
Deve gerar 10 imagens, totalmente preenchidas com cores da legenda padrão, sendo que para cada uma das faixas da legenda serão produzidas 2 imagens. 
A legenda do atributo "soilWater" deve ter 5 faixas variando (passos iguais) com cores entre vermelho e preto e valores numéricos entre 0 e 10. 
Todas as variações de cores presentes na legenda devem ser apresentadas pelas imagens.
Deverão ser emitidas mensagens de "Warning" informando o uso do diretório corrente para saída, o uso de prefixo e de legenda padrões.

IMAGE 03
Deve gerar 10 imagens, totalmente preenchidas com cores da legenda "soilWaterLeg". As cores das imagens deverão variar de branco a azul escuro.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão. 

IMAGE 04
Deve gerar 10 imagens, totalmente preenchidas com cores da legenda "soilWaterLeg". As cores das imagens deverão variar de branco a azul escuro.
As imagens serão geradas no diretório corrente com prefixo "prefix_".

IMAGE 05
Deve gerar 10 imagens exibindo o relevo obtido a partir do atributo HEIGHT e da legenda "heightLeg". A legenda do atributo "soilWater" deve ter 10 faixas variando (passos iguais) com cores entre branco e azul escuro e valores numéricos entre 0 e 10. A cada notificação as células do espaço em questão deverão possuir uma das cores da legenda sobreposta sobre o relevo.
Deverão ser emitidas mensagens de "Warning" informando o uso do diretório corrente para saída e prefixo padrões.

IMAGE 06

IMAGE 07

IMAGE 08

IMAGE 09

IMAGE 10


IMAGE 11
Este teste será idêntico ao teste IMAGE 10. Porém, no tempo de simulação 8, o observador "observerImage11" será destruído. Assim, serão geradas apenas 8 arquivos com o prefixo "result_" que contendo imagens iguais. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER MAP
function test_map( case )
	if( not SKIP ) then

		switch( case ) : caseof {
			[1] = function(x) 		
				-- OBSERVER MAP 01 
				print("MAP 01") io.flush()
				--@DEPRECATED	
				--cs1:createObserver( "map" )
				observerMap01 = Observer{ subject = cs1, type = "map" }
			end,
			[2] = function(x)			
				-- OBSERVER MAP 02 
				print("MAP 02") io.flush()
				--@DEPRECATED	
				--cs1:createObserver( "map", {"soilWater"} )
				observerMap02 = Observer{ subject = cs1, type = "map", attributes={"soilWater"} }
			end,
			[3] = function(x)
				-- OBSERVER MAP 03
				print("MAP 03") io.flush()
				--@DEPRECATED
				--cs1:createObserver( "map", {"soilWater"}, {soilWaterLeg} )
				observerMap03 = Observer{ subject = cs1, type = "map", attributes={"soilWater"},legends= {soilWaterLeg} }
			end,
			[4] = function(x)
				-- OBSERVER MAP 04
				print("MAP 04") io.flush()
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap04 = Observer{ subject = cs1, type = "map", attributes={"soilWater", HEIGHT},legends= {soilWaterLeg, heightLeg} }
			end,
			[5] = function(x)
				-- OBSERVER MAP 05
				print("MAP 05") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["quantil"]
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap05 = Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[6] = function(x)
				-- OBSERVER MAP 06
				print("MAP 06") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["uniquevalue"]
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap06 = Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[7] = function(x)
				-- OBSERVER MAP 07
				print("MAP 07") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["full"]
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap07= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[8] = function(x)
				-- OBSERVER MAP 08
				print("MAP 08") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["half"]
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap08= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[9] = function(x)
				-- OBSERVER MAP 09
				print("MAP 09") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap09= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
			end,
			[10] = function(x)
				-- OBSERVER MAP 10
				print("MAP 10") io.flush()
				heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
				heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
				--@DEPRECATED
				--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
				observerMap10= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }

				killObserver = true

			end
		}

		for i = 1, 10, 1 do
			print("STEP: ", i); io.flush()
			cs1:notify(i)

			forEachCell(cs1, function(cell)
				cell.soilWater = i
			end)

			if ((killObserver and observerMap10) and (i == 8)) then
				print("", "observerMap10:kill", observerMap10:kill())
			end

			delay_s(1)
		end
	end
end

-- TESTES OBSERVER MAP
--[[
MAP01
O programa deverá ser abortado. Não é possível utilizar observers MAP sem a identificação dos parâmetros a serem plotados.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP02
Deve iniciar apresentando uma imagem vermelha. A legenda do atributo "soilWater" deve ter 5 faixas variando (passos iguais) com cores entre vermelho e preto e valores numéricos entre 0 e 100. Todas as variações de cores presentes na legenda devem ser apresentadas na área de desenho.
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.

MAP03
Deve iniciar apresentando uma imagem em branco. A legenda do atributo "soilWater" deve ter 10 faixas variando (passos iguais) com cores entre branco e azul escuro e valores numéricos entre 0 e 10. A cada notificação as células do espaço em questão deverão possuir uma das cores da legenda.

MAP04
Deve iniciar apresentando uma imagem exibindo o relevo obtido a partir do atributo HEIGHT e da legenda "heightLeg". A legenda do atributo "soilWater" deve ter 10 faixas variando (passos iguais) com cores entre branco e azul escuro e valores numéricos entre 0 e 10. A cada notificação as células do espaço em questão deverão possuir uma das cores da legenda sobreposta sobre o relevo.

MAP05
Deve iniciar apresentando uma imagem exibindo o relevo a partir do atributo HEIGHT e da legenda heightLeg_GROUP_MODE. As imagens apresentaram o agrupamento 'Quantil'. As imagens geradas variam entre Verde, para áreas altas, Azul, para áreas com altimetria intermediária e Vermelho, para áreas baixas. A legenda do atributo HEIGHT deve conter 50 faixas. As notificações não alteram a imagem apresentada.

MAP06
Deve iniciar apresentando uma imagem exibindo o relevo a partir do atributo HEIGHT e da legenda heightLeg_GROUP_MODE. As imagens apresentaram o agrupamento 'Unique Value'. As imagens geradas são brancas e possuem diversos pontos em tons de verde, azul e vermelho e também haverá uma mancha maior em verde e bordas vermelhas à squerda e em cima.
A legenda do atributo HEIGHT deve conter 50 faixas. As notificações não alteram a imagem apresentada.

MAP07
Deve iniciar apresentando uma imagem exibindo o relevo a partir do atributo HEIGHT e da legenda heightLeg_GROUP_MODE. As imagens apresentaram o agrupamento 'Desvio Padrão' e o tipo de desvio 'FULL'. As imagens geradas variam em 4 faixas: Preta, valores altos, Branca, valores intermediários altos, Verde, intermediários baixos e Vermelhos, para valores baixos.  
A legenda do atributo HEIGHT deve conter 50 faixas. As notificações não alteram a imagem apresentada.

MAP08
Deve iniciar apresentando uma imagem exibindo o relevo a partir do atributo HEIGHT e da legenda heightLeg_GROUP_MODE. As imagens apresentaram o agrupamento 'Desvio Padrão' e o tipo de desvio 'HALF'. As imagens geradas variam em 4 faixas: Preta, valores altos, Branca, valores intermediários altos, Verde, intermediários baixos e Vermelhos, para valores baixos.  
A legenda do atributo HEIGHT deve conter 50 faixas. As notificações não alteram a imagem apresentada.

MAP 09
Este teste será idêntico ao teste IMAGE 08. Porém, no tempo de simulação 8, o observador "observerMap10" será destruído. Assim, serão geradas apenas 8 imagens iguais. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]


-- ================================================================================#

-- ================================================================================#
-- OBSERVER UDP
function test_udp( case )
	if( not SKIP ) then
		IP1 = "192.168.0.12"
		IP2 = "192.168.0.255"

		switch( case ) : caseof {
			[1] = function(x) 						
				-- OBSERVER UDPSENDER 01
				print("UDPSENDER 01") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender")
				observerUdpSender01 = Observer{ subject = cs1, type = "udpsender" }
			end,
			[2] = function(x) 		
				-- OBSERVER UDPSENDER 02
				print("UDPSENDER 02") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", {})
				observerUdpSender02 = Observer{ subject = cs1, type = "udpsender", attributes = {} }
			end,
			[3] = function(x)
				-- OBSERVER UDPSENDER 03
				print("UDPSENDER 03") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", {}, {})
				observerUdpSender03 = Observer{ subject = cs1, type = "udpsender",hosts ={}, attributes={} }
			end,
			[4] = function(x)
				-- OBSERVER UDPSENDER 04
				print("UDPSENDER 04") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", { "soilWater", HEIGHT})
				observerUdpSender04 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT} }
			end,
			[5] = function(x)
				-- OBSERVER UDPSENDER 05
				print("UDPSENDER 05") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", { "soilWater", HEIGHT }, {"456456"})
				observerUdpSender05 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT},port="666" }	
			end,
			[6] = function(x)
				-- OBSERVER UDPSENDER 06
				print("UDPSENDER 06") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", { "soilWater", HEIGHT }, {"456456", IP2})
				observerUdpSender06 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT},port= "666",hosts={IP2} }--??
			end,
			[7] = function(x)
				-- OBSERVER UDPSENDER 07
				print("UDPSENDER 07") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", { "soilWater", HEIGHT }, {"456456", IP1, IP2})
				observerUdpSender07 = Observer{ subject = cs1, type = "udpsender", attributes = { "soilWater", HEIGHT},port = "666",hosts={IP1,IP2} }
			end,
			[8] = function(x)
				-- OBSERVER UDPSENDER 08
				print("UDPSENDER 08") io.flush()
				--@DEPRECATED
				--cs1:createObserver("udpsender", { "soilWater", HEIGHT }, {"456456", IP1, IP2})
				observerUdpSender08 = Observer{ subject = cs1, type = "udpsender", attributes = {},port = "666",hosts={IP1,IP2} }

				killObserver = true
			end
		}
		for i = 1, 10, 1 do
			print("STEP: ", i); io.flush()
			cs1:notify(i)

			if ((killObserver and observerUdpSender08) and (i == 8)) then
				print("", "observerUdpSender08:kill", observerUdpSender08:kill())
			end
		end	
	end
end

-- TESTES OBSERVER UDPSENDER
--[[
UDPSENDER01 / UDPSENDER02 / UDPSENDER03
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do espaço celular "cs1" e os dados referente aos atributos de todas suas células.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:


UDPSENDER04
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação (endereço "IP2"). O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". Os clientes deverão receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

]]

-- SKIP = false

-- test_image( TEST ) -- cases of [1..11]
--test_map( TEST ) -- cases of [1..10]
--test_udp( TEST ) -- cases of [1..8]

--[[
testsSourceCodes = {
["image"] = test_image,
["map"] = test_map,
["udp"] = test_udp
}
--]]
testsSourceCodes = {
	test_image,
	test_map,
	test_udp
}

print("**     TESTS FOR AUTOMATON OBSERVERS      **\n")
print("** Choose observer type and test case **")
print("(1) Image 	    ","[ Cases 1..11 ]")
print("(2) Map          ","[ Cases 1..10 ]")
print("(3) UDP          ","[ Cases 1..8  ]")

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
