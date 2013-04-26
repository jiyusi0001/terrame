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

function createCSShape(filename)
    local cs = CellularSpace{
        database = filename
    }
    return cs
end

cs1 = createCS(dbms,pwd,"cells90x90")

csS1 = createCSShape(TME_PATH.."/tests/dependencies/util/shapefile/EstadosBrasil.shp")
csS2 = createCSShape(TME_PATH.."/tests/dependencies/util/shapefile/UnidadeHabitacional_Integrado_pto_pt.shp")
csS3 = createCSShape(TME_PATH.."/tests/dependencies/util/shapefile/Tema_amarantina_arruamento_lin.shp")

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

populLeg = Legend{
	-- Attribute name:  height
	type = "number",
	grouping = "equalsteps",
	slices = 27,
	precision = 5,
	stdDeviation = "none",
	maximum = 100000,
	minimum = 40000000,
	colorBar = {
		{color = "cyan", value = 100000},
		{color = "blue", value = 40000000}
	},
	stdColorBar = {},
	style = "sticks",
	width = 6,
	symbol = DIAMOND
}

idLeg = Legend{
	-- Attribute name:  height
	type = "number",
	grouping = "equalsteps",
	slices = 30,
	precision = 5,
	stdDeviation = "none",
	maximum = 30,
	minimum = 0,
	colorBar = {
		{color = "red", value = 0},
		{color = "black", value = 30}
	},
	stdColorBar = {},
	style = "sticks",
	width = 6,
	symbol = DIAMOND
}

attrLeg = Legend{
	-- Attribute name:  height
	type = "number",
	grouping = "uniquevalue",
	slices = 1,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "yellow", value = 1},
		{color = "green", value = 0}
	},
	stdColorBar = {},
	style = "sticks",
	width = 6,
	symbol = DIAMOND
}


mapFor = function( killObserver,unitTest ) 
	for i = 1, 10, 1 do
		print("STEP: ", i); io.flush()
		cs1:notify(i)
		csS1:notify(i)
		csS2:notify(i)
		csS3:notify(i)
		forEachCell(cs1, function(cell)
			cell.soilWater = i
		end)
		if ((killObserver and observerMap10) and (i == 8)) then
			print("", "observerMap10:kill", observerMap10:kill())
		end
		delay_s(1)
	end
	unitTest:assert_true(true)
end


local observersMapTest = UnitTest {
	test_map01 = function(unitTest) 		
		-- OBSERVER MAP 01 
		print("MAP 01") io.flush()
		observerMap01 = Observer{ subject = cs1, type = "map" }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap01.type)
	end,
	test_map02 = function(unitTest)			
		-- OBSERVER MAP 02 
		print("MAP 02") io.flush()
		observerMap02 = Observer{ subject = cs1, type = "map", attributes={"soilWater"} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap02.type)
	end,
	test_map03 = function(unitTest)
		-- OBSERVER MAP 03
		print("MAP 03") io.flush()
		observerMap03 = Observer{ subject = cs1, type = "map", attributes={"soilWater"},legends= {soilWaterLeg} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap03.type)
	end,
	test_map04 = function(unitTest)
		-- OBSERVER MAP 04
		print("MAP 04") io.flush()
		observerMap04 = Observer{ subject = cs1, type = "map", attributes={"soilWater", HEIGHT},legends= {soilWaterLeg, heightLeg} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap04.type)
	end,
	test_map05 = function(unitTest)
		-- OBSERVER MAP 05
		print("MAP 05") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["quantil"]
		observerMap05 = Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap05.type)
	end,
	test_map06 = function(unitTest)
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
		observerMap06 = Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE_NEW} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap06.type)
	end,
	test_map07 = function(unitTest)
		-- OBSERVER MAP 07
		print("MAP 07") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["full"]
		observerMap07= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap07.type)
	end,
	test_map08 = function(unitTest)
		-- OBSERVER MAP 08
		print("MAP 08") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["half"]
		observerMap08= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap08.type)
	end,
	test_map09 = function(unitTest)
		-- OBSERVER MAP 09
		print("MAP 09") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		observerMap09= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(false,unitTest)
		unitTest:assert_equal("map",observerMap09.type)
	end,
	test_map10 = function(unitTest)
		-- OBSERVER MAP 10
		print("MAP 10") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		observerMap10= Observer{ subject = cs1, type = "map", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		mapFor(true, unitTest)
		unitTest:assert_equal("map",observerMap10.type)
	end,
	test_map11 = function(unitTest)
	  -- OBSERVER MAP 11
		print("MAP 11") io.flush()
        forEachCell(csS1, function(cell)
            cell.attr1 = tonumber(cell.objectId_) % 2
        end)
		Observer{ subject = csS1, type = "shapefile", attributes = {"POPUL","attr1"},legends = {populLeg,attrLeg}}
		mapFor(false, unitTest)
	end,
	test_map12 = function(unitTest)
	  -- OBSERVER MAP 12
		print("MAP 12") io.flush()
		observerMap12= Observer{ subject = csS2, type = "shapefile", attributes={"latitude"},legends= {} }
		mapFor(false, unitTest)
	end,
	test_map13 = function(unitTest)
	  -- OBSERVER MAP 13
		print("MAP 13") io.flush()
		forEachCell(csS3,function(cell)
		    cell.objet_id_8 = tonumber(cell.objet_id_8)
		end)
		observerMap13= Observer{ subject = csS3, type = "shapefile", attributes = {"objet_id_8"}, legends = {idLeg}}
		mapFor(false, unitTest)
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

MAP 10
Deverá ser executado do STEP 1 ao STEP 10, sendo que entre os STEPs 8 e 9, apresenta uma mensagem: "observerMap10:kill    true", utilizando a função test_map10.

MAP11

Deve iniciar apresentando uma imagem do mapa do brasil dividido em 27 poligonos pintados a partir do atributo POPUL e da legenda populLeg, A legenda do atributo POPUL deve ter 5 valores.

MAP12

Tenho que ver com Luiz o que exatamente os dados do shape significam

MAP13 (Não implementado)

Tenho que ver com Luiz o que exatamente os dados do shape significam

]]

observersMapTest:run()
os.exit(0)
