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

chartFor = function( killObserver )
	for i = 1, 10, 1 do
		print("STEP: ", i)
		cs1.valor1 = (cs1.valor1*i)*2
		if(cs1.valor2) then cs1.valor2 = 1/(cs1.valor2*i-1) end
		cs1.t = i*2
		cs1:notify(i)
		--cs1.valor = math.sin(i*3.14/2)	
		cs1:notify(i)
		if ((killObserver and observerGraphic08) and (i == 8)) then
			print("", "observerGraphic08:kill", observerGraphic08:kill())
		end
		delay_s(1)
	end
end

local observersChartTest = UnitTest { 
	test_chart1 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 01
		--cs1 = cs.cells[1]
        print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
        observerDynamicGraphic01 = Observer{subject = cs1, type = "chart"}
        chartFor(false)
    end,
    test_chart2 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 02
        print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0               
	    observerDynamicGraphic02 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {}}
	    chartFor(false)
    end,
    test_chart3 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 03
        print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
        observerDynamicGraphic03 = Observer{subject = cs1, type = "chart", attributes={"valor2","valor1"}, legends = {heightLeg}}
        chartFor(false)
    end,
	test_chart4 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 04
        print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
        observerDynamicGraphic04 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {heightLeg}}
        chartFor(false)
    end,
    test_chart5 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 05
        print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
		cs1.valor1 = 0
        observerDynamicGraphic05 = Observer{subject = cs1, type = "chart", attributes={"valor1"}, legends = {}}
        chartFor(false)
   	end,
    test_chart6 = function(unitTest)
        -- OBSERVER DYNAMIC GRAPHIC 06
        print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
		cs1.valor1 = 0
    	observerDynamicGraphic06 = Observer{subject = cs1, type = "chart", attributes={"valor1"}, legends = {heightLeg}}
    	chartFor(false)
    end,
    test_chart7 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07")
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerDynamicGraphic07 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {heightLeg, soilWaterLeg}}
		chartFor(false)
	end,
	test_chart8 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 08
		print("OBSERVER DYNAMIC GRAPHIC 08")
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerDynamicGraphic08 = Observer{subject = cs1, type = "chart", attributes={"valor1","valor2"}, legends = {heightLeg, soilWaterLeg}, title = "Dynamics Graphics"}
		chartFor(false)
	end,
	test_chart9 = function(unitTest) 
		-- OBSERVER GRAPHIC 01
		print("GRAPHIC 01") io.flush()
		--@DEPRECATED
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic01 = Observer{ subject = cs1, type = "chart",attributes={"valor2"},xAxis="valor1" }
		chartFor(false)
	end,
	test_chart10 = function(unitTest) 
		-- OBSERVER GRAPHIC 02
		print("GRAPHIC 02") io.flush()
		--@DEPRECATED
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic02 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1", title=nil}
		chartFor(false)
	end,
	test_chart11 = function(unitTest) 
		-- OBSERVER GRAPHIC 03
		print("GRAPHIC 03") io.flush()
		--@DEPRECATED
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic03 = Observer{ subject = cs1, type = "chart",attributes={"valor2"},xAxis="valor1",title="GraphicTitle"}
		chartFor(false)
	end,
	test_chart12 = function(unitTest) 
		-- OBSERVER GRAPHIC 04
		print("GRAPHIC 04") io.flush()
		--@DEPRECATED
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0	 	
		observerGraphic04 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1",title="GraphicTitle",curveLabel="CurveTitle" }
		chartFor(false)
	end,
	test_chart13 = function(unitTest) 
		-- OBSERVER GRAPHIC 05
		print("GRAPHIC 05") io.flush()
		--@DEPRECATED
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic05 = Observer{ subject = cs1, type = "chart",attributes={"valor2"},xAxis="valor1",title="GraphicTitle",curveLabel="CurveTitle", yLabel="YLabel"}
		chartFor(false)
	end,
	test_chart14 = function(unitTest) 
		-- OBSERVER GRAPHIC 06
		print("GRAPHIC 06") io.flush()
		--@DEPRECATED	
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic06 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", xLabel="XLabel"}
		chartFor(false)
	end,
	test_chart15 = function(unitTest) 
		-- OBSERVER GRAPHIC 07
		print("GRAPHIC 07") io.flush()
		--@DEPRECATED	
		--cs1:createObserver(TME_OBSERVERS.GRAPHIC, {"eixoY", "eixoX"}, {"GraphicTitle","CurveTitle","YLabel","XLabel"})
		-- criação de atributos dinâmicos antes da especificação de observers
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic07 = Observer{ subject = cs1, type = "chart",attributes={"valor2"}, xAxis="valor1", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", xLabel="XLabel"}
		chartFor(true)
	end,
	test_chart16 = function(unitTest) 
		-- OBSERVER GRAPHIC 08
		print("GRAPHIC 08") io.flush()
		cs1.valor1 = 0
		observerGraphic08 = Observer{ subject = cs1, type = "chart",attributes={"valor1"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
		chartFor(false)
	end,
	test_chart17 = function(unitTest) 
		-- OBSERVER GRAPHIC 09
		print("GRAPHIC 09") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic09 = Observer{ subject = cs1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t"}
		chartFor(false)
	end,
	test_chart18 = function(unitTest) 
		-- OBSERVER GRAPHIC 10
		print("GRAPHIC 10") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic10 = Observer{ subject = cs1, type = "chart",attributes={"valor1","valor2"}, xAxis="t", legends={heightLeg, soilWaterLeg}, curveLabels={"Curve A", "CurveB"}}
		chartFor(false)
	end,
	test_chart19 = function(unitTest) 
		-- OBSERVER GRAPHIC 11
		print("GRAPHIC 11") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic11 = Observer{ subject = cs1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t", legends={heightLeg}, curveLabels={"Curve A", "CurveB"}}
		chartFor(false)
	end,
	test_chart20 = function(unitTest) 
		-- OBSERVER GRAPHIC 12
		print("GRAPHIC 12") io.flush()
		cs1.valor1 = 0
		cs1.valor2 = 0
		observerGraphic12 = Observer{ subject = cs1, type = "chart",attributes={"valor2", "valor1"}, xAxis="t", legends={heightLeg}, curveLabels={"Curve A", "CurveB"}}
		chartFor(false)
	end
}


-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
O programa deverá ser abortado. Não é possível utilizar os observers de autômatos sem a identificação de um atributo para o eixo Y.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 02
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores roxo e azul respectivamente, onde o eixo X receberá os valores do tempo corrente do relógio de simulação e os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 03
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores vermelhor e azul respectivamente, onde o eixo X receberá os valores do tempo corrente do relógio de simulação e os eixos Y receberão os atributos "valor2" e "valor1" da trajetória "tr1". Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 04
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores verde (estilo dots) e azul respectivamente, onde o eixo X receberá os valores do tempo corrente do relógio de simulação e os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 05
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "valor1" da trajetória "tr1", respectivamente. A curva de ter a cor roxa. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 06
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "valor1" da trajetória "tr1", respectivamente. A curva de ter a cor verde no estilo dots. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 07
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores verde (estilo dots) e vermelha respectivamente, onde o eixo X receberá os valores do tempo corrente do relógio de simulação e os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 08
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores verde (estilo dots) e vermelha respectivamente, onde o eixo X receberá os valores do tempo corrente do relógio de simulação e os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Com o título do gráfico "GraphicTitle", Serão usados valores padrão para os parâmetros do gráfico: título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título das curvas", "título do eixo Y" e "título do eixo X").

GRAPHIC 01 / GRAPHIC 02
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "t" e "valor1", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 03
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico "GraphicTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 04
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico e título da curva: "GraphicTitle" e "CurveTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do eixo Y" e "título do eixo X").
Deverá apresentar um gráfico de dispersão XY, com uma reta na cor verde, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" da trajetória "sc1". Com o título do gráfico "GraphicTitle", com o titulo dos labes Curve 1.

GRAPHIC 05
Deverá apresentar um gráfico de dispersão XY, com uma reta na cor verde, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" da trajetória "sc1". Com o título do gráfico "GraphicTitle", com o titulo dos labes Curve 1.

GRAPHIC 06
Deverá apresentar um gráfico de dispersão XY, com uma reta na cor verde, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" da trajetória "sc1". Com o título do gráfico "GraphicTitle", com o titulo dos labes Curve 1.


GRAPHIC 07
Deverá apresentar um gráfico de dispersão XY, com uma reta na cor verde, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" da trajetória "sc1". Com o título do gráfico "GraphicTitle", com o titulo dos labes Curve1 e Curve2.


GRAPHIC 08
Deverá apresentar um gráfico de dispersão XY, com uma curva na cor verde, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor1" da trajetória "sc1". Com o título do gráfico "GraphicTitle", com o titulo dos labes Curve1 e Curve2.


GRAPHIC 09
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores verde e vermelha respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "sc1". Com o título do gráfico "GraphicTitle", com o titulo dos labes "Curve1" e "Curve2".

GRAPHIC 10
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores Branco e preto(pontos) respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "sr1". Com o título do gráfico "graphTitle", com o titulo dos labes Curve1 e Curve2.

GRAPHIC 11
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores vermelho e preto(pontos) respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" e "valor1" da trajetória "sc1". Com o título do gráfico "graphTitle", com o titulo dos labes Curve1 e Curve2.

GRAPHIC 12
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores vermelho e preto(pontos) respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" e "valor1" da trajetória "sc1". Com o título do gráfico "graphTitle", com o titulo dos labes Curve1 e Curve2.

]]

observersChartTest:run()
os.exit(0)
