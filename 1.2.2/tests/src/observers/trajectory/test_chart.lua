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

mim = 0
max = 9
start = 10

cs = CellularSpace{ xdim = 0 }

tr1 = Trajectory{
	target = cs,
	select = function(cell)
		if((cell.cont <= max+1 and cell.cont > mim+1) and cell.x==mim) then
			cell.path = up
			return true
		end
		if((cell.cont <= max and cell.cont > mim) and cell.y==mim) then
			cell.path = right
			return true
		end
		if((cell.cont >= max and cell.cont <= max*max+2*max+1) and cell.x == max) then
			cell.path = down
			return true
		end
		return false
	end,
	sort = function(a,b)
		if(a.path == right) then	
			return a.x<b.x 
		elseif(a.path == left) then	
			return a.x>b.x 
		elseif(a.path == down) then
			return a.y<b.y;	
		elseif(a.path == up) then
			return a.y>b.y
		end
	end,
	valor1 = 1,
	valor2 = 1,
	t = 0
}

graphicFor = function(killObserver,unitTest)
	for i = 1, 10, 1 do
		print("STEP:",i)io.flush()
		tr1.valor1 = tr1.valor1*i
		tr1.valor2 = 1/tr1.valor2*i
		tr1.t = i*2
		tr1:notify(i)
		if((killObserver and observerGraphic07) and (i == 8)) then
			print("", "observerGraphic07:kill", observerGraphic07:kill())io.flush()
		end
		delay_s(1)
	end
	unitTest:assert_true(true)
end

local observersGraphicTest = UnitTest {
	test_dynamicGraph01 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 01
		print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
		observerDynamicGraphic01 = Observer{subject = tr1, type = "chart"}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic01.type)
	end,
	test_dynamicGraph02 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 02
		print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
		observerDynamicGraphic02 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic02.type)
	end,
	test_dynamicGraph03 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 03
		print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
		observerDynamicGraphic03 = Observer{subject = tr1, type = "chart", attributes={"valor2","valor1"}, legends = {tr2Leg}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic03.type)
	end,
	test_dynamicGraph04 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 04
		print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
		observerDynamicGraphic04 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {tr1Leg}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic04.type)
	end,
	test_dynamicGraph05 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 05
		print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
		observerDynamicGraphic05 = Observer{subject = tr1, type = "chart", attributes={"valor1"}, legends = {}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic05.type)
	end,
	test_dynamicGraph06 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 06
		print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
		observerDynamicGraphic06 = Observer{subject = tr1, type = "chart", attributes={"valor1"}, legends = {tr1Leg}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic06.type)
	end,
	test_dynamicGraph07 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 07
		print("OBSERVER DYNAMIC GRAPHIC 07")
		observerDynamicGraphic07 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {tr1Leg, tr2Leg}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic07.type)
	end,
	test_dynamicGraph08 = function(unitTest)
		-- OBSERVER DYNAMIC GRAPHIC 08
		print("OBSERVER DYNAMIC GRAPHIC 08")
		observerDynamicGraphic08 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {tr1Leg, tr2Leg}, title = "Dynamics Graphics"}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerDynamicGraphic08.type)
	end,
	test_graph01 = function(unitTest)
		-- OBSERVER GRAPHIC 01
		print("GRAPHIC 01") io.flush()
		observerGraphic01 = Observer{ subject = tr1, type = "chart",attributes={"valor1"},xAxis="t" }
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic01.type)
	end,
	test_graph02 = function(unitTest) 
		-- OBSERVER GRAPHIC 02
		print("GRAPHIC 02") io.flush()
		observerGraphic02 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t", title=nil}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic02.type)
	end,
	test_graph03 = function(unitTest) 
		-- OBSERVER GRAPHIC 03
		print("GRAPHIC 03") io.flush()
		observerGraphic03 = Observer{ subject = tr1, type = "chart",attributes={"valor1"},xAxis="t",title="GraphicTitle"}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic03.type)
	end,
	test_graph04 = function(unitTest)
		-- OBSERVER GRAPHIC 04
		print("GRAPHIC 04") io.flush()
		observerGraphic04 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t",title="GraphicTitle",curveLabels={"Curve A"} }
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic04.type)
	end,
	test_graph05 = function(unitTest) 
		-- OBSERVER GRAPHIC 05
		print("GRAPHIC 05") io.flush()
		observerGraphic05 = Observer{ subject = tr1, type = "chart",attributes={"valor1"},xAxis="t",title="GraphicTitle",curveLabels={"Curve A"}, yLabel="valor1"}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic05.type)
	end,
	test_graph06 = function(unitTest) 
		-- OBSERVER GRAPHIC 06
		print("GRAPHIC 06") io.flush()
		observerGraphic06 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic06.type)
	end,
	test_graph07 = function(unitTest) 
		-- OBSERVER GRAPHIC 07
		print("GRAPHIC 07") io.flush()
		observerGraphic07 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
		graphicFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic07.type)
	end,
	test_graph08 = function(unitTest) 
		-- OBSERVER GRAPHIC 08
		print("GRAPHIC 08") io.flush()
		observerGraphic08 = Observer{ subject = tr1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t"}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic08.type)
	end,
	test_graph09 = function(unitTest) 
		-- OBSERVER GRAPHIC 09
		print("GRAPHIC 09") io.flush()
		observerGraphic09 = Observer{ subject = tr1, type = "chart",attributes={"valor1","valor2"}, xAxis="t", legends={tr1Leg, tr2Leg}, curveLabels={"Curve A", "CurveB"}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic09.type)

	end,
	test_graph10 = function(unitTest) 
		-- OBSERVER GRAPHIC 10
		print("GRAPHIC 10") io.flush()
		observerGraphic10 = Observer{ subject = tr1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t", legends={tr1Leg}, curveLabels={"Curve A", "CurveB"}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic10.type)
	end,
	test_graph11 = function(unitTest) 
		-- OBSERVER GRAPHIC 11
		print("GRAPHIC 11") io.flush()
		observerGraphic11 = Observer{ subject = tr1, type = "chart",attributes={"valor2", "valor1"}, xAxis="t", legends={tr2Leg}, curveLabels={"Curve A", "CurveB"}}
		graphicFor(false,unitTest)
		unitTest:assert_equal("chart",observerGraphic11.type)
	end,
	test_graph12 = function(unitTest) 
		-- OBSERVER GRAPHIC 12
		print("GRAPHIC 12") io.flush()
		observerGraphic12 = Observer{ subject = tr1, type = "chart",attributes={"valor1","valor2"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
		graphicFor(true,unitTest)
		unitTest:assert_equal("chart",observerGraphic12.type)
	end
}

-- TESTES OBSERVER GRAPHIC
--[[

DYNAMIC GRAPHIC 01
O programa deverá apresentar uma mensagem de ERRO, reportando que o gráfico de Observers deve ter no mínimo um atributo, se for ao contrário disso, não será executado.

DYNAMIC GRAPHIC 02
O programa deverá apresentar um gráfico do tipo “chart”, com os atributos “valor1” e “valor2”, o gráfico deverá crescer durante a execução.

DYNAMIC GRAPHIC 03
Idem DYNAMIC GRAPHIC 02, exceto que a legenda deverá mudar para "tr2Leg".

DYNAMIC GRAPHIC 04
Idem DYNAMIC GRAPHIC 02, exceto que a legenda deverá mudar para "tr1Leg".

DYNAMIC GRAPHIC 05
O programa deverá apresentar um gráfico do tipo “chart”, com o atributo “valor1”, o gráfico deverá crescer durante a execução, neste caso não tem legenda para ser carregada.

DYNAMIC GRAPHIC 06
Idem Idem DYNAMIC GRAPHIC 02, exceto que ao invés do gráfico ter dois atributos, ele terá apenas um: "valor1".

DYNAMIC GRAPHIC 07
O programa deverá apresentar um gráfico do tipo “chart”, com o atributo “valor1” e "valor2" e duas legendas "tr1Leg" e "tr2Leg", o gráfico deverá crescer durante a execução.

DYNAMIC GRAPHIC 08
Idem DYNAMIC GRAPHIC 07, mas com o título diferente: "Dynamics Graphics".

GRAPHIC 01
O programa deverá apresentar um gráfico do tipo “chart”, com um atributo “valor1” e o eixo x deverá ser chamado de “t”.

GRAPHIC 02
Idem GRAPHIC 1, exceto que no lugar do título, está “nil”, vazio.

GRAPHIC 03
Idem GRAPHIC 1, mas com o nome do gráfico: “GraphicTitle”.

GRAPHIC 04
O programa deverá exibir um gráfico do tipo “chart”, com um atributo “valor1”, o eixo x “t”, título do gráfico deverá ser “GraphicTitle” e uma curva “Curve A”

GRAPHIC 05
Idem GRAPHIC 4, exceto que o eixo y, será o “valor1”.

GRAPHIC 06
O programa deverá apresentar um gráfico com um atributo “valor1”, o eixo x “Xlabel”, o eixo y “Ylabel”, uma curvo “Curve A”

GRAPHIC 07
Idem GRAPHIC 6.

GRAPHIC 08
O programa deverá apresentar um gráfico com dois atributos “valor1” e “valor2”.

GRAPHIC 09
Programa deverá apresentar um gráfico com dois atributos “valor1” e ”valor2”, duas legendas “tr1Leg” e “tr2Leg”, duas curvas “Curve A” e “Curve B”.

GRAPHIC 10
Idem 9, exceto que carrega apenas uma legenda “tr1Leg”.

GRAPHIC 11
Idem 10, mas carregando a legenda “tr2Leg”.

GRAPHIC 12
Programa deverá apresentar um gráfico com dois atributos “valor1” e “valor2”, eixo x “XLabel” e eixo y “Ylabel”, de título “GraphicTitle”, uma curva “Curve A”.

]]

observersGraphicTest:run()
os.exit(0)
