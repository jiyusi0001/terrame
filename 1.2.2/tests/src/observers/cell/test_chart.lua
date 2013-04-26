-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright � 2001-2012 INPE and TerraLAB/UFOP.
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
--			Henrique Cota Cam�llo
--			Washington Sena Fran�a e Silva
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

chartFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i)
		cell01.eixoX = i + i
		cell01.eixoY = i * i
		cell01.valor1 = (i * i)*2
		cell01:notify(i)
		if ((killObserver and observerGraphic08) and (i == 8)) then
			print("", "observerGraphic08:kill", observerGraphic08:kill())
		end
		delay_s(1)
	end
	unitTest:assert_true(true) 
end

local observersChartTest = UnitTest {
	test_chart01 = function(unitTest) 		
		-- OBSERVER DYNAMIC GRAPHIC 01
		cell01 = cs.cells[1]
		print("DYNAMIC GRAPHIC 01") io.flush()
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cell01.eixoY = 0
		observerDynamicGraphic01 = Observer{ subject = cell01, type = "chart", attributes={} }
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic01.type)
	end,
	test_chart02 = function(unitTest) 		
		-- OBSERVER DYNAMIC GRAPHIC 02
		cell01 = cs.cells[1]
		print("DYNAMIC GRAPHIC 02") io.flush()
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cell01.eixoY = 0
		observerDynamicGraphic02 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"} }
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic02.type)
	end,
	test_chart03 = function(unitTest) 
		-- OBSERVER DYNAMIC GRAPHIC 03
		cell01 = cs.cells[1]
		print("DYNAMIC GRAPHIC 03") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoY = 0
		observerDynamicGraphic03 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},title=nil}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic03.type)
	end,
	test_chart04 = function(unitTest) 
		-- OBSERVER GRAPHIC 01
		cell01 = cs.cells[1]
		print("GRAPHIC 01") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic01 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX" }
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic01.type)
	end,
	test_chart05 = function(unitTest) 
		-- OBSERVER GRAPHIC 02
		cell01 = cs.cells[1]
		print("GRAPHIC 02") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic02 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title=nil}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic02.type)
	end,
	test_chart06 = function(unitTest) 
		-- OBSERVER GRAPHIC 03
		cell01 = cs.cells[1]
		print("GRAPHIC 03") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic03 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX",title="GraphicTitle"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic03.type)
	end,
	test_chart07 = function(unitTest) 
		-- OBSERVER GRAPHIC 04
		cell01 = cs.cells[1]
		print("GRAPHIC 04") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0	 	
		observerGraphic04 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX",title="GraphicTitle",curveLabels={"CurveTitle"} }
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic04.type)
	end,
	test_chart08 = function(unitTest) 
		-- OBSERVER GRAPHIC 05
		cell01 = cs.cells[1]
		print("GRAPHIC 05") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic05 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"},xAxis="eixoX",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic05.type)
	end,
	test_chart09 = function(unitTest) 
		-- OBSERVER GRAPHIC 06
		cell01 = cs.cells[1]
		print("GRAPHIC 06") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic06 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic06.type)
	end,
	test_chart10 = function(unitTest) 
		-- OBSERVER GRAPHIC 07
		cell01 = cs.cells[1]
		print("GRAPHIC 07") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		observerGraphic07 = Observer{ subject = cell01, type = "chart",attributes={"eixoY"}, xAxis="eixoX", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic07.type)
	end,
	test_chart11 = function(unitTest) 
		-- OBSERVER GRAPHIC 08
		cell01 = cs.cells[1]
		print("GRAPHIC 08") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cell01.eixoX = 0
		cell01.eixoY = 0
		cell01.valor1 = 0
		observerGraphic08 = Observer{ subject = cell01, type = "chart",attributes={"eixoY","valor1"}, xAxis="eixoX", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic08.type)
	end
	
}
-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
O programa dever� ser abortado. N�o � poss�vel utilizar observers GRAPHIC sem a especifica��o de ao menos um atributo.
Dever� ser emitida uma mensagem de "Warning" informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 02 / DYNAMIC GRAPHIC 03
Dever� apresentar um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores do tempo corrente do rel�gio de simula��o e do atributo "eixoY", respectivamente. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 01 / GRAPHIC 02
Dever� ser apresentado um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores dos atributos "eixoX" e "eixoY", respectivamente. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo Y ("$yLabel"), t�tulo do eixo X ("$xLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 03
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico "GraphicTitle".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 04
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico e t�tulo da curva: "GraphicTitle" e "CurveTitle".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 05
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico, t�tulo da curva e r�tulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "XLabel".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para o par�metros "t�tulo do eixo X".

GRAPHIC 06
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso de valores espec�ficos na lista de par�metros.

GRAPHIC 07
Este teste ser� id�ntico ao teste GRAPHIC 06. Por�m, no tempo de simula��o 8, o observador "observerTextScreen05" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e a janela referente a este observer ser� fechada.

GRAPHIC 08
Este teste ser� id�ntico ao teste GRAPHIC 06. Por�m, no tempo de simula��o 8, o observador "observerTextScreen05" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e a janela referente a este observer ser� fechada. Tamb�m existe a presen�a de um segundo atrivuto("valor1").

]]

observersChartTest:run()
os.exit(0)
