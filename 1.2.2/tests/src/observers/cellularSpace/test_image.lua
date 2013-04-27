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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")

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

imageFor = function( killObserver, unitTest,testNumber,prefix) 
    if prefix == nil then
        prefix = "result_"
    end
	for i = 1, 10, 1 do
		print("STEP: ", i); io.flush()
		cs1:notify()
		forEachCell(cs1, function(cell)
			cell.soilWater = i
		end)
		if ((killObserver and observerImage11) and (i == 8)) then
			print("", "observerImage11:kill", observerImage11:kill())
		else
		    if (not(killObserver and i>8)) then
		        if i<10 then
		            
		            unitTest:assert_image_match("./"..prefix.."00000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/cellularSpace/test_image/test_image"..testNumber.."/"..prefix.."00000"..i..".png")
	            else
	                unitTest:assert_image_match("./"..prefix.."0000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/cellularSpace/test_image/test_image"..testNumber.."/"..prefix.."0000"..i..".png")
	            end
	        end
        end
		delay_s(1)
	end
	unitTest:assert_true(true) 
end

local observersImageTest = UnitTest {
	test_image01 = function(unitTest) 
		-- OBSERVER IMAGE 01 
		local copyCommand = ""
		local removeCommand = ""	
		print("IMAGE 01") io.flush()
		observerImage01 = Observer{ subject = cs1, type = "image" }
		imageFor(false,unitTest,"01")
		unitTest:assert_equal("image",observerImage01.type) 
	end,
	test_image02 = function(unitTest) 
		-- OBSERVER IMAGE 02 
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 02") io.flush()
		observerImage02 = Observer{ subject = cs1, type = "image", attributes={"soilWater"}}
		imageFor(false,unitTest,"02")
		unitTest:assert_equal("image",observerImage02.type) 	
	end,
	test_image03 = function(unitTest)
		-- OBSERVER IMAGE 03
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 03") io.flush()
		observerImage03 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},legends={soilWaterLeg} }
		imageFor(false,unitTest,"03")
		unitTest:assert_equal("image",observerImage03.type) 
	end,
	test_image04 = function(unitTest)
		-- OBSERVER IMAGE 04
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 04") io.flush()
		observerImage04 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},legends={soilWaterLeg } }
		imageFor(false,unitTest,"04")
		unitTest:assert_equal("image",observerImage04.type) 
	end,
	test_image05 = function(unitTest)
		-- OBSERVER IMAGE 05
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 05") io.flush()
		observerImage05 = Observer{ subject = cs1, type = "image", attributes={"soilWater",HEIGHT},legends= {soilWaterLeg, heightLeg} }
		imageFor(false,unitTest,"05")
		unitTest:assert_equal("image",observerImage05.type) 
	end,
	test_image06 = function(unitTest)
		-- OBSERVER IMAGE 06
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 06") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["quantil"]
		observerImage06 = Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false,unitTest,"06")
		unitTest:assert_equal("image",observerImage06.type) 
	end,
	test_image07 = function(unitTest)
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
		observerImage07 = Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE_NEW} }
		imageFor(false,unitTest,"07")
		unitTest:assert_equal("image",observerImage07.type) 
	end,
	test_image08 = function(unitTest)
		-- OBSERVER IMAGE 08
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 08") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["full"]
		observerImage08= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false,unitTest,"08")
		unitTest:assert_equal("image",observerImage08.type) 
	end,
	test_image09 = function(unitTest)
		-- OBSERVER IMAGE 09
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 09") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["half"]
		observerImage09= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false,unitTest,"09")
		unitTest:assert_equal("image",observerImage09.type) 
	end,
	test_image10 = function(unitTest)
		-- OBSERVER IMAGE 10
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 10") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		observerImage10= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(false,unitTest,"10")
		unitTest:assert_equal("image",observerImage10.type) 
	end,
	test_image11 = function(unitTest)
		-- OBSERVER IMAGE 11
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 11") io.flush()
		heightLeg_GROUP_MODE.grouping = TME_LEGEND_GROUPING_USER["stddeviation"]
		heightLeg_GROUP_MODE.stdDeviation = TME_LEGEND_STDDEVIATION_USER["quarter"]
		observerImage11= Observer{ subject = cs1, type = "image", attributes={HEIGHT},legends= {heightLeg_GROUP_MODE} }
		imageFor(true, unitTest,"11")
		unitTest:assert_equal("image",observerImage11.type) 
	end,
	test_image12 = function(unitTest)
		-- OBSERVER IMAGE 12
		local copyCommand = ""
		local removeCommand = ""
		print("IMAGE 12") io.flush()
		observerImage12 = Observer{ subject = cs1, type = "image", attributes={"soilWater"},path = TME_ImagePath,prefix = "prefix_",legends={soilWaterLeg } }
	    for i = 1, 10, 1 do
		    print("STEP: ", i); io.flush()
		    cs1:notify()
		    forEachCell(cs1, function(cell)
			    cell.soilWater = i
		    end)
		    if i<10 then
                unitTest:assert_image_match(TME_ImagePath.."/".."prefix_00000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/cellularSpace/test_image/test_image12".."/".."prefix_00000"..i..".png")
            else
                unitTest:assert_image_match(TME_ImagePath.."/".."prefix_0000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/cellularSpace/test_image/test_image12".."/".."prefix_0000"..i..".png")
            end
	    end

        moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."cellularSpace"..TME_DIR_SEPARATOR.."test_image"..TME_DIR_SEPARATOR.."test_image12",".png")
        if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/prefix_*".. " > /dev/null 2>&1 ")
	    else
			--@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end	    
		unitTest:assert_equal("image",observerImage12.type) 
	end,
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
Idem IMAGE 06, porém a legenda é "heightLeg_GROUP_MODE", devrá ter 10 faixas. Uma janela é exibida mostrando a execução, com os "parâmetros", "filename prefix" = "result" e "path".

IMAGE 07
Programa executará e logo no início deverão ser emitidas algumas mensagens, a primeira em relação a versão da TerraLib está diferente da versão das bases de dados, em seguida mais dois "Warning"s, pois são encontrados mais valores no modelo, do que na legenda do atributo "height_". Em seguida são geradas 10 imagens exibindo o relevo obtido a partir do atributo "HEIGHT" e da legenda "heightLeg_GROUP_MODE_NEW".

IMAGE 08
Idem IMAGE 07, com exceção da legenda que muda para "heightLeg_GROUP_MODE".

IMAGE 09
Idem IMAGE 08.

IMAGE 10
Idem IMAGE 08.


IMAGE 11
Este teste será idêntico ao teste IMAGE 10. Porém, no tempo de simulação 8, o observador "observerImage11" será destruído. Assim, serão geradas apenas 8 arquivos com o prefixo "result_" que contendo imagens iguais. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

IMAGE 12
Idem IMAGE 02, mas os arquivos serão gerados no Desktop com o nome prefix_
]]

observersImageTest:run()
os.exit(0)
