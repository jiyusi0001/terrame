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
--			Henrique Cota Cam�lo
--			Washington Sena Fran�a e Silva
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

cs1 = createCS(dbms,pwd,"cells90x90")
cs1.t = 0

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

chartFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("STEP: ", i)
		cs1.valor1 = (cs1.valor1*i)*2
		if(cs1.valor2) then cs1.valor2 = 1/(cs1.valor2*i-1) end
		cs1.t = i*2
		cs1:notify(i)
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
        print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
        observerDynamicGraphic01 = Observer{subject = cs1, type = "chart"}
        chartFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic01.type) 
    end,
    test_chart02 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 02
        print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0               
	    observerDynamicGraphic02 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {}}
	    chartFor(false,unitTest)
	    unitTest:assert_equal("chart",observerDynamicGraphic02.type) 
    end,
    test_chart03 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 03
        print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
        observerDynamicGraphic03 = Observer{subject = cs1, type = "chart", attributes={"valor2","valor1"}, legends = {heightLeg}}
        chartFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic03.type) 
    end,
	test_chart04 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 04
        print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
        observerDynamicGraphic04 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {heightLeg}}
        chartFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic04.type) 
    end,
    test_chart05 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 05
        print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
		cs1.valor1 = 0
        observerDynamicGraphic05 = Observer{subject = cs1, type = "chart", attributes={"valor1"}, legends = {}}
        chartFor(false,unitTest)
        unitTest:assert_equal("chart",observerDynamicGraphic05.type) 
   	end,
    test_chart06 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 06
        print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
		cs1.valor1 = 0
    	observerDynamicGraphic06 = Observer{subject = cs1, type = "chart", attributes={"valor1"}, legends = {heightLeg}}
    	chartFor(false,unitTest)
    	unitTest:assert_equal("chart",observerDynamicGraphic06.type) 
    end,
    test_chart07 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07")
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerDynamicGraphic07 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {heightLeg, soilWaterLeg}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic07.type) 
	end,
	test_chart08 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 08
		print("OBSERVER DYNAMIC GRAPHIC 08")
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerDynamicGraphic08 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {heightLeg, soilWaterLeg}, title = "Dynamics Graphics"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic08.type) 
	end,
	test_chart09 = function(unitTest) 
		-- OBSERVER GRAPHIC 01
		print("GRAPHIC 01") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic01 = Observer{ subject = cs1, type = "chart",attributes={"valor2"},xAxis="valor1" }
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic01.type) 
	end,
	test_chart10 = function(unitTest) 
		-- OBSERVER GRAPHIC 02
		print("GRAPHIC 02") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic02 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1", title=nil}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic02.type) 
	end,
	test_chart11 = function(unitTest) 
		-- OBSERVER GRAPHIC 03
		print("GRAPHIC 03") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic03 = Observer{ subject = cs1, type = "chart",attributes={"valor2"},xAxis="valor1",title="GraphicTitle"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic03.type) 
	end,
	test_chart12 = function(unitTest) 
		-- OBSERVER GRAPHIC 04
		print("GRAPHIC 04") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0	 	
		observerGraphic04 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1",title="GraphicTitle",curveLabels={"CurveTitle"} }
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic04.type) 
	end,
	test_chart13 = function(unitTest) 
		-- OBSERVER GRAPHIC 05
		print("GRAPHIC 05") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic05 = Observer{ subject = cs1, type = "chart",attributes={"valor2"},xAxis="valor1",title="GraphicTitle",curveLabels={"CurveTitle"}, yLabel="YLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic05.type) 
	end,
	test_chart14 = function(unitTest) 
		-- OBSERVER GRAPHIC 06
		print("GRAPHIC 06") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic06 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic06.type) 
	end,
	test_chart15 = function(unitTest) 
		-- OBSERVER GRAPHIC 07
		print("GRAPHIC 07") io.flush()
		-- cria��o de atributos din�micos antes da especifica��o de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic07 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1", title="GraphicTitle", curveLabels={"CurveTitle"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic07.type) 
	end,
	test_chart16 = function(unitTest) 
		-- OBSERVER GRAPHIC 08
		print("GRAPHIC 08") io.flush()
		cs1.valor1 = 0
		observerGraphic08 = Observer{ subject = cs1, type = "chart",attributes={"valor1"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic08.type) 
	end,
	test_chart17 = function(unitTest) 
		-- OBSERVER GRAPHIC 09
		print("GRAPHIC 09") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic09 = Observer{ subject = cs1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t"}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic09.type) 
	end,
	test_chart18 = function(unitTest) 
		-- OBSERVER GRAPHIC 10
		print("GRAPHIC 10") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic10 = Observer{ subject = cs1, type = "chart",attributes={"valor1","valor2"}, xAxis="t", legends={heightLeg, soilWaterLeg}, curveLabels={"Curve A", "CurveB"}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic10.type) 
	end,
	test_chart19 = function(unitTest) 
		-- OBSERVER GRAPHIC 11
		print("GRAPHIC 11") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic11 = Observer{ subject = cs1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t", legends={heightLeg}, curveLabels={"Curve A", "CurveB"}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic11.type) 
	end,
	test_chart20 = function(unitTest) 
		-- OBSERVER GRAPHIC 12
		print("GRAPHIC 12") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic12 = Observer{ subject = cs1, type = "chart",attributes={"valor2", "valor1"}, xAxis="t", legends={heightLeg}, curveLabels={"Curve A", "CurveB"}}
		chartFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic12.type) 
	end
}


-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
O programa dever� ser abortado. N�o � poss�vel utilizar os observers de aut�matos sem a identifica��o de um atributo para o eixo Y.
Dever� ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 02
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores roxo e azul respectivamente, onde o eixo X receber� os valores do tempo corrente do rel�gio de simula��o e os eixos Y receber�o os atributos "valor1" e "valor2" da trajet�ria "tr1". Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 03
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores vermelhor e azul respectivamente, onde o eixo X receber� os valores do tempo corrente do rel�gio de simula��o e os eixos Y receber�o os atributos "valor2" e "valor1" da trajet�ria "tr1". Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 04
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores verde (estilo dots) e azul respectivamente, onde o eixo X receber� os valores do tempo corrente do rel�gio de simula��o e os eixos Y receber�o os atributos "valor1" e "valor2" da trajet�ria "tr1". Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 05
Dever� apresentar um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores do tempo corrente do rel�gio de simula��o e do atributo "valor1" da trajet�ria "tr1", respectivamente. A curva de ter a cor roxa. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 06
Dever� apresentar um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores do tempo corrente do rel�gio de simula��o e do atributo "valor1" da trajet�ria "tr1", respectivamente. A curva de ter a cor verde no estilo dots. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 07
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores verde (estilo dots) e vermelha respectivamente, onde o eixo X receber� os valores do tempo corrente do rel�gio de simula��o e os eixos Y receber�o os atributos "valor1" e "valor2" da trajet�ria "tr1". Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

DYNAMIC GRAPHIC 08
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores verde (estilo dots) e vermelha respectivamente, onde o eixo X receber� os valores do tempo corrente do rel�gio de simula��o e os eixos Y receber�o os atributos "valor1" e "valor2" da trajet�ria "tr1". Com o t�tulo do gr�fico "GraphicTitle", Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo da curva ("$curveLabel"), t�tulo do eixo X ("time"), t�tulo do eixo y ("$yLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo das curvas", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 01 / GRAPHIC 02
Dever� ser apresentado um gr�fico de dispers�o XY, onde os eixos X e Y receber�o os valores dos atributos "t" e "valor1", respectivamente. Ser�o usados valores padr�o para os par�metros do gr�fico: t�tulo do gr�fico ("$graphTitle"), t�tulo da curva ("$curveLabel"), t�tulo do eixo Y ("$yLabel"), t�tulo do eixo X ("$xLabel").
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do gr�fico", "t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 03
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico "GraphicTitle".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo da curva", "t�tulo do eixo Y" e "t�tulo do eixo X").

GRAPHIC 04
Resultados id�nticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do t�tulo do gr�fico e t�tulo da curva: "GraphicTitle" e "CurveTitle".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para os par�metros ("t�tulo do eixo Y" e "t�tulo do eixo X").
Dever� apresentar um gr�fico de dispers�o XY, com uma reta na cor verde, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor2" da trajet�ria "sc1". Com o t�tulo do gr�fico "GraphicTitle", com o titulo dos labes Curve 1.

GRAPHIC 05
Dever� apresentar um gr�fico de dispers�o XY, com uma reta na cor verde, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor2" da trajet�ria "sc1". Com o t�tulo do gr�fico "GraphicTitle", com o titulo dos labes Curve 1.

GRAPHIC 06
Dever� apresentar um gr�fico de dispers�o XY, com uma reta na cor verde, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor2" da trajet�ria "sc1". Com o t�tulo do gr�fico "GraphicTitle", com o titulo dos labes Curve 1.


GRAPHIC 07
Dever� apresentar um gr�fico de dispers�o XY, com uma reta na cor verde, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor2" da trajet�ria "sc1". Com o t�tulo do gr�fico "GraphicTitle", com o titulo dos labes Curve1 e Curve2.


GRAPHIC 08
Dever� apresentar um gr�fico de dispers�o XY, com uma curva na cor verde, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor1" da trajet�ria "sc1". Com o t�tulo do gr�fico "GraphicTitle", com o titulo dos labes Curve1 e Curve2.


GRAPHIC 09
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores verde e vermelha respectivamente, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor1" e "valor2" da trajet�ria "sc1". Com o t�tulo do gr�fico "GraphicTitle", com o titulo dos labes "Curve1" e "Curve2".

GRAPHIC 10
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores Branco e preto(pontos) respectivamente, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor1" e "valor2" da trajet�ria "sr1". Com o t�tulo do gr�fico "graphTitle", com o titulo dos labes Curve1 e Curve2.

GRAPHIC 11
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores vermelho e preto(pontos) respectivamente, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor2" e "valor1" da trajet�ria "sc1". Com o t�tulo do gr�fico "graphTitle", com o titulo dos labes Curve1 e Curve2.

GRAPHIC 12
Dever� apresentar um gr�fico de dispers�o XY, com duas curvas nas cores vermelho e preto(pontos) respectivamente, onde o eixo X receber� o valor do atributo "t" os eixos Y receber�o os atributos "valor2" e "valor1" da trajet�ria "sc1". Com o t�tulo do gr�fico "graphTitle", com o titulo dos labes Curve1 e Curve2.

]]

observersChartTest:run()
os.exit(0)
