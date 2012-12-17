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

imageFor = function( killObserver, unitTest) 
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
	--print(compareDirectory("cellularspace","image",case,"."))io.flush()
  --unitTest:assert_equal_directory_structure("cellularspace","image",case,".")
end

local observersImageTest = UnitTest {
	test_image1 = function(unitTest) 
		-- OBSERVER IMAGE 01 
		local copyCommand = ""
		local removeCommand = ""	
		print("IMAGE 01") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "image" )
		observerImage01 = Observer{ subject = cs1, type = "image" }
		imageFor(false)
	end,
	test_image2 = function(unitTest) 
		-- OBSERVER IMAGE 02 
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 02") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "image", {"soilWater"} )
		observerImage02 = Observer{ subject = cs1, type = "image", attributes={"soilWater"}}
		imageFor(false)	
	end,
	test_image3 = function(unitTest)
		-- OBSERVER IMAGE 03
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 03") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "image", {"soilWater"}, { soilWaterLeg } )
		observerImage03 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},legends={soilWaterLeg} }
		imageFor(false)
	end,
	test_image4 = function(unitTest)
		-- OBSERVER IMAGE 04
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 04") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "image", {"soilWater"}, {".", "prefix_", soilWaterLeg } )
		observerImage04 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},path=".",prefix = "prefix_",legends={soilWaterLeg } }
		imageFor(false)
	end,
	test_image5 = function(unitTest)
		-- OBSERVER IMAGE 05
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 05") io.flush()
		--@DEPRECATED				
		--cs1:createObserver("image", {"soilWater", HEIGHT}, {soilWaterLeg, heightLeg})
		observerImage05 = Observer{ subject = cs1, type = "image", attributes={"soilWater",HEIGHT},legends= {soilWaterLeg, heightLeg} }
		imageFor(false)
	end,
	test_image6 = function(unitTest)
		-- OBSERVER IMAGE 06
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 06") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["quantil"]
		--@DEPRECATED
		--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
		observerImage06 = Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false)
	end,
	test_image7 = function(unitTest)
		-- OBSERVER IMAGE 07
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 07") io.flush()
		local colorBar_ = {}
		local tempValues ={}        
        local tempCells =    
        forEachCell(cs1, function(cell)
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
		--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
		observerImage07 = Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE_NEW} }
		imageFor(false)
	end,
	test_image8 = function(unitTest)
		-- OBSERVER IMAGE 08
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 08") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["full"]
		--@DEPRECATED
		--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
		observerImage08= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false)
	end,
	test_image9 = function(unitTest)
		-- OBSERVER IMAGE 09
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 09") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["half"]
		--@DEPRECATED
		--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
		observerImage09= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false)
	end,
	test_image10 = function(unitTest)
		-- OBSERVER IMAGE 10
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 10") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		--@DEPRECATED
		--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
		observerImage10= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false)
	end,
	test_image11 = function(unitTest)
		-- OBSERVER IMAGE 11
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 11") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		--@DEPRECATED
		--cs1:createObserver("image", {HEIGHT}, {heightLeg_GROUP_MODE})
		observerImage11= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(true, unitTest)
	end
}


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

observersImageTest:run()
os.exit(0)
