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

--db = getDataBase()
--dbms = db["dbms"]
--PWD = db["pwd"]
dbms = 0
DB_VERSION = "4_2_0"
HEIGHT = "height_"
PWD= "terralab0705"


cs1 = nil
if(dbms == 0) then
	cs1 = CellularSpace(createMySQLTable())
else
	cs1 = CellularSpace(createAccessTable())
end

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
	stdColorBar = {},
	style = "sticks",
	width = 6,
	symbol = DIAMOND
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

mapFor = function( killObserver ) 
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


local observersMapTest = UnitTest {
	test_map1 = function(unitTest) 		
		-- OBSERVER MAP 01 
		print("MAP 01") io.flush()
		--@DEPRECATED	
		--cs1:createObserver( "map" )
		observerMap01 = Observer{ subject = cs1, type = "map" }
		mapFor(false)
	end,
	test_map2 = function(unitTest)			
		-- OBSERVER MAP 02 
		print("MAP 02") io.flush()
		--@DEPRECATED	
		--cs1:createObserver( "map", {"soilWater"} )
		observerMap02 = Observer{ subject = cs1, type = "map", attributes={"soilWater"} }
		mapFor(false)
	end,
	test_map3 = function(unitTest)
		-- OBSERVER MAP 03
		print("MAP 03") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "map", {"soilWater"}, {soilWaterLeg} )
		observerMap03 = Observer{ subject = cs1, type = "map", attributes={"soilWater"},legends= {soilWaterLeg} }
		mapFor(false)
	end,
	test_map4 = function(unitTest)
		-- OBSERVER MAP 04
		print("MAP 04") io.flush()
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap04 = Observer{ subject = cs1, type = "map", attributes={"soilWater", HEIGHT},legends= {soilWaterLeg, heightLeg} }
		mapFor(false)
	end,
	test_map5 = function(unitTest)
		-- OBSERVER MAP 05
		print("MAP 05") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["quantil"]
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap05 = Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false)
	end,
	test_map6 = function(unitTest)
		-- OBSERVER MAP 06
		print("MAP 06") io.flush()
	    local colorBar_ = {}
       	local tempValues ={}        
        local tempCells =    
        forEachCell(cs1,
        function(cell)
          if(not tempValues[cell[HEIGHT]]) then
            local colorR = cell.x % 255
            local colorG = cell.y % 255
            local colorB = math.floor((cell.x + cell.y)/2) % 255
            local clr = {colorR, colorG, colorB}
            table.insert(colorBar_,{ color = clr, value = cell[HEIGHT] })
          end
          tempValues[cell[HEIGHT]] = cell[HEIGHT]
        end)   
          
        local heightLeg_GROUP_MODE_NEW = Legend {
         	type = "number",
          	grouping = TME_LEGEND_GROUPING_USER["uniquevalue"],
          	colorBar = colorBar_      
        }
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap06 = Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE_NEW} }
		mapFor(false)
	end,
	test_map7 = function(unitTest)
		-- OBSERVER MAP 07
		print("MAP 07") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["full"]
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap07= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false)
	end,
	test_map8 = function(unitTest)
		-- OBSERVER MAP 08
		print("MAP 08") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["half"]
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap08= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false)
	end,
	test_map9 = function(unitTest)
		-- OBSERVER MAP 09
		print("MAP 09") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap09= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false)
	end,
	test_map10 = function(unitTest)
		-- OBSERVER MAP 10
		print("MAP 10") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		--@DEPRECATED
		--cs1:createObserver("map", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerMap10= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(true)
	end
}

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

observersMapTest:run()
os.exit(0)
