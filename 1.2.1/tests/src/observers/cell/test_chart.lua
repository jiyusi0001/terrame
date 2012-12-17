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

DB_VERSION = "4_2_0"
HEIGHT = "height_"

db = getDataBase()
dbms = db["dbms"]
pwd = db["pwd"]
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present

--require("XDebug")

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

cs = createCS(dbms,pwd,"cells90x90")

chartFor = function( killObserver )
	for i = 1, 10, 1 do
		print("step", i)
		cell01.eixoX = i + i
		cell01.eixoY = i * i
		cell01.valor1 = (i * i)*2
		--cell01.valor = math.sin(i*3.14/2)	
		cell01:notify(i)
		if ((killObserver and observerGraphic08) and (i == 8)) then
			print("", "observerGraphic08:kill", observerGraphic08:kill())
		end
		delay_s(1)
	end
end

local observersChartTest = UnitTest {
	test_chart1 = function(unitTest) 		
		-- OBSERVER DYNAMIC GRAPHIC 01
		cell01 = cs.cells[1]
		print("DYNAMIC GRAPHIC 01") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {})
		-- criação de atributo dinâmico antes da especificação de observers
		cell01.eixoY = 0
		observerDynamicGraphic01 = Observer{ subject = cell01, type = "chart", attributes={} }
		chartFor(false)
	end,
	test_chart2 = function(unitTest) 		
		-- OBSERVER DYNAMIC GRAPHIC 02
		cell01 = cs.cells[1]
		print("DYNAMIC GRAPHIC 02") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"eixoY"})
		-- criação de atributo dinâmico antes da especificação de observers
		cell01.eixoY = 0
		observerDynamicGraphic02 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"} }
		chartFor(false)
	end,
	test_chart3 = function(unitTest) 
		-- OBSERVER DYNAMIC GRAPHIC 03
		cell01 = cs.cells[1]
		print("DYNAMIC GRAPHIC 03") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"eixoY"},{})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoY = 0
		observerDynamicGraphic03 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},title=nil}
		chartFor(false)
	end,
	test_chart4 = function(unitTest) 
		-- OBSERVER GRAPHIC 01
		cell01 = cs.cells[1]
		print("GRAPHIC 01") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic01 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX" }
		chartFor(false)
	end,
	test_chart5 = function(unitTest) 
		-- OBSERVER GRAPHIC 02
		cell01 = cs.cells[1]
		print("GRAPHIC 02") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic02 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title=nil}
		chartFor(false)
	end,
	test_chart6 = function(unitTest) 
		-- OBSERVER GRAPHIC 03
		cell01 = cs.cells[1]
		print("GRAPHIC 03") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic03 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX",title="GraphicTitle"}
		chartFor(false)
	end,
	test_chart7 = function(unitTest) 
		-- OBSERVER GRAPHIC 04
		cell01 = cs.cells[1]
		print("GRAPHIC 04") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0	 	
		observerGraphic04 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX",title="GraphicTitle",curveLabel="CurveTitle" }
		chartFor(false)
	end,
	test_chart8 = function(unitTest) 
		-- OBSERVER GRAPHIC 05
		cell01 = cs.cells[1]
		print("GRAPHIC 05") io.flush()
		--@DEPRECATED
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic05 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX",title="GraphicTitle",curveLabel="CurveTitle", yLabel="YLabel"}
		chartFor(false)
	end,
	test_chart9 = function(unitTest) 
		-- OBSERVER GRAPHIC 06
		cell01 = cs.cells[1]
		print("GRAPHIC 06") io.flush()
		--@DEPRECATED	
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic06 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", xLabel="XLabel"}
		chartFor(false)
	end,
	test_chart10 = function(unitTest) 
		-- OBSERVER GRAPHIC 07
		cell01 = cs.cells[1]
		print("GRAPHIC 07") io.flush()
		--@DEPRECATED	
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic07 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", xLabel="XLabel"}
		chartFor(true)
	end,
	test_chart11 = function(unitTest) 
		-- OBSERVER GRAPHIC 08
		cell01 = cs.cells[1]
		print("GRAPHIC 08") io.flush()
		--@DEPRECATED	
		--cell01:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		cell01.valor1 = 0
		observerGraphic07 = Observer{ subject = cell01, type = "chart",attributes={"eixoY","valor1"}, xAxis="eixoX", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(true)
	end
}
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

GRAPHIC 08
Este teste será idêntico ao teste GRAPHIC 06. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada. Também existe a presença de um segundo atrivuto("valor1").

]]

observersChartTest:run()
os.exit(0)
