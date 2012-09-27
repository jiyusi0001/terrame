-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--d
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
dofile (TME_PATH.."/tests/run/run_util.lua")

mim = 0
max = 9
start = 10

--require "XDebug"

-- define o espaco celular
cs = CellularSpace{ xdim = 0}

for i = 1, 10, 1 do 
	for j = 1, 10, 1 do 
		c = Cell{ cover = AGUA,agents_ = {}}
		c.height_ = i
		c.path = 0
		c.x = i - 1
		c.y = j - 1
		c.cont=i*j
		c.cover = 1
		cs:add( c )
	end
end

-- Define a trajetória tr1

down = 1
up = 2
left = 3
right = 4

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

-- Define a trajetória tr2

oldFilter = function(cell)
	if(cell.x == cell.y) then
		return true
	end
	return false
end

oldSort = function(a,b)
	return a.x<b.x
end


newFilter = function(cell)
	if(cell.x+cell.y == 9) then
		return true
	end
	return false
end

newSort = function(a,b)
	return a.x<b.x
end

tr2 = Trajectory{
	target = cs,
	select = oldFilter,
	sort = newSort
}

-- Define as legendas

coverLeg = Legend{
	type = "number",
	grouping = "uniquevalue",
	slices = 5,
	precision = 6,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{
			color = "red", 
			value = 1
		},
		{
			color = "black",
			value = 0
		}						
	}
}

tr1Leg = Legend {
	type = "number",
	grouping = "uniquevalue",
	stdDeviation = "none",
	maximum = 28,
	minimum = 0,
	slices = 28,
	precision = 2,
	colorBar = {
		{
			color = "green",
			value = 0
		},
		{	
			color = "blue", 
			value = 28
		}
	},
	style = "dots",
	width = 5,
	symbol = CROSS
}

tr2Leg = Legend {
	type = "number",
	grouping = "uniquevalue",
	stdDeviation = "none",
	maximum = 10,
	minimum = 0,
	slices = 10,
	precision = 2,
	colorBar = {
		{
			color = "red",
			value = 0
		},
		{	
			color = "yellow",
			value = 10
		}
	},
	symbol = UTRIANGLE
}

-- Enables kill an observer
killObserver = false


--=============================================================--]]

-- OBSERVER TEXTSCREEN

function test_textScreen(case)
    if (not SKIP) then
        switch(case) : caseof{
            [1] = function(x)
                -- OBSERVER TEXTSCREEN 01
                print("OBSERVER TEXTSCREEN 01") io.flush()
                observerTextScreen01 = Observer{subject = tr1, type = "textscreen"}
            end,
            [2] = function(x)
                -- OBSERVER TEXTSCREEN 02
                print("OBSERVER TEXTSCREEN 02") io.flush()
                observerTextScreen02 = Observer{subject = tr1, type = "textscreen", attributes={}}
            end,
            [3] = function(x)
                -- OBSERVER TEXTSCREEN 03
                print("OBSERVER TEXTSCREEN 03") io.flush()
                observerTextScreen03 = Observer{subject = tr1, type = "textscreen", attributes={"valor1","valor2"}}
            end,
            [4] = function(x)
				-- OBSERVER TEXTSCREEN 04
				print("OBSERVER TEXTSCREEN 04")io.flush()
				observerTextScreen04 = Observer{ subject = tr1, type = "textscreen", attributes={}}
				killObserver =true
			end
        }
        for i = 1, 10, 1 do
			print("STEP:",i)io.flush()
			tr1.valor1 = tr1.valor1*i
			tr1.valor2 = 1/tr1.valor2*i
			tr1.t = i*2
			tr1:notify(i)
			if ((killObserver and observerTextScreen04) and (i == 8)) then
				print("", "observerTextScreen04:kill", observerTextScreen04:kill())io.flush()
			end
			delay_s(1)
		end
    end
end

--[[
TEXTSCREEN 01 / TEXTSCREEN 02
Deve apresentar na tela uma tabela textual contendo todos os atributos do trajectory: "select", "t", "valor2", "sort", "cObj_, "cells", "parent", "valor1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.

TEXTSCREEN03
Deve apresentar na tela uma tabela textual contendo os atributos "valor1", "valor2". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes três atributos.

TEXTSCREEN04
Este teste será idêntico ao teste 01. Porém, no tempo de simulação 8, o observador "observerTextScreen04" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.


-- ================================================================================#]]



-- OBSERVER LOGFILE

function test_logFile(case)
    if (not SKIP) then
        switch(case) : caseof{
            [1] = function(x)
                -- OBSERVER LOGFILE 01
                print("OBSERVER LOGFILE 01") io.flush()
                observerLogFile01 = Observer{subject = tr1, type = "logfile"}
            end,
            [2] = function(x)
                -- OBSERVER LOGFILE 02
                print("OBSERVER LOGFILE 02") io.flush()
                observerLogFile02 = Observer{subject = tr1, type = "logfile", attributes={}}
            end,
            [3] = function(x)
                -- OBSERVER LOGFILE 03
                print("OBSERVER LOGFILE 03") io.flush()
                observerLogFile03 = Observer{subject = tr1, type = "logfile", attributes ={},outfile = "logfile.csv", separator=","}
            end,
            [4] = function(x)
                -- OBSERVER LOGFILE 04
                print("OBSERVER LOGFILE 04") io.flush()
                observerLogFile04 = Observer{subject = tr1, type = "logfile", attributes={"valor1","valor2"}}
            end,
            [5] = function(x)
				-- OBSERVER LOGFILE 05
				print("OBSERVER LOGFILE 05")io.flush()
				observerLogFile05 = Observer{ subject = tr1, type = "logfile", attributes={}}
				killObserver =true
			end
        }
        for i = 1, 10, 1 do
			print("STEP:",i)io.flush()
			tr1:notify(i)
			tr1.valor1 = tr1.valor1*i
			tr1.valor2 = 1/tr1.valor2*i
			tr1.t = i*2
			if ((killObserver and observerLogFile05) and (i == 8)) then
				print("", "observerLogFile05:kill", observerLogFile05:kill())io.flush()
			end
			delay_s(1)
		end
    end
end


-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01 / LOGFILE 02

Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser uma tabela textual contendo todos os atributos do trajectory "tr1" no cabeçalho: "select", "t", "valor2", "sort", "cObj_, "cells", "parent", "valor1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 02), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 03
Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE 01, 02) deverão ser apresentados.
Deverão ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.

LOGFILE 04
Deverá ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos "valor1" e "valor2" e "hungry". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes atributos.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

LOGFILE 05
Este teste será idêntico ao teste 01. Porém, no tempo de simulação 8, o observador "observerLogFile05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "result_.csv" conterá apenas informações até o 8o. tempo de simulação



-- ================================================================================#]]


-- OBSERVER TABLE
function test_table(case)
    if (not SKIP) then
        switch(case) : caseof{
            [1] = function(x)
                -- OBSERVER TABLE 01
                print("OBSERVER TABLE 01") io.flush()
                observerTable01 = Observer{subject = tr1, type = "table"}
            end,
            [2] = function(x)
                -- OBSERVER TABLE 02
                print("OBSERVER TABLE 02") io.flush()
                observerTable02 = Observer{subject = tr1, type = "table", attributes={}}
            end,
            [3] = function(x)
                -- OBSERVER TABLE 03
                print("OBSERVER TABLE 03") io.flush()
                observerTable03 = Observer{subject = tr1, type = "table", attributes={},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
            end,
            [4] = function(x)
                -- OBSERVER TABLE 04
                print("OBSERVER TABLE 04") io.flush()
                observerTable04 = Observer{subject = tr1, type = "table", attributes={"valor1", "valor2"},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
            end,
            [5] = function(x)
				-- OBSERVER TABLE 05
				print("OBSERVER TABLE 05")io.flush()
				observerTable05 = Observer{ subject = tr1, type = "table", attributes={}}
				killObserver =true
			end
        }
        for i = 1, 10, 1 do
			print("STEP:",i)io.flush()
			tr1.valor1 = tr1.valor1*i
			tr1.valor2 = 1/tr1.valor2*i
			tr1.t = i*2
			tr1:notify(i)
			if ((killObserver and observerTable05) and (i == 8)) then
				print("", "observerTable05:kill", observerTable05:kill())io.flush()
			end
			delay_s(1)
		end
    end
end

-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02
Deverá ser apresentada uma tabela contendo todos os atributos da trajetória "tr1" como linhas da tabela: "select", "t", "valor2", "sort", "cObj_, "cells", "parent", "valor1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 03
Resultados idênticos aos dos observers TABLE01, TABLE02, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 04
Deve apresentar na tela uma tabela contendo os atributos "valor1" e "valor2". Os atributos devem ser apresentados na ordem em que é feita a especificação. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 05
Este teste será idêntico ao teste 01. Porém, no tempo de simulação 8, o observador "observerTable05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observador será fechada.


]]
-- ================================================================================#

-- OBSERVER DYNAMIC GRAPHIC E OBSERVER GRAPHIC
function test_chart(case)
    if (not SKIP) then
        switch(case) : caseof{
            [1] = function(x)
                -- OBSERVER DYNAMIC GRAPHIC 01
                print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
                observerDynamicGraphic01 = Observer{subject = tr1, type = "chart"}
            end,
            [2] = function(x)
                -- OBSERVER DYNAMIC GRAPHIC 02
                print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
                observerDynamicGraphic02 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {}}
            end,
            [3] = function(x)
                -- OBSERVER DYNAMIC GRAPHIC 03
                print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
                observerDynamicGraphic03 = Observer{subject = tr1, type = "chart", attributes={"valor2","valor1"}, legends = {tr2Leg}}
            end,
            [4] = function(x)
                -- OBSERVER DYNAMIC GRAPHIC 04
                print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
                observerDynamicGraphic04 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {tr1Leg}}
            end,
            [5] = function(x)
                -- OBSERVER DYNAMIC GRAPHIC 05
                print("OBSERVER DYNAMIC GRAPHIC 05") io.flush()
                observerDynamicGraphic05 = Observer{subject = tr1, type = "chart", attributes={"valor1"}, legends = {}}
            end,
            [6] = function(x)
                -- OBSERVER DYNAMIC GRAPHIC 06
                print("OBSERVER DYNAMIC GRAPHIC 06") io.flush()
                observerDynamicGraphic06 = Observer{subject = tr1, type = "chart", attributes={"valor1"}, legends = {tr1Leg}}
            end,
            [7] = function(x)
				-- OBSERVER DYNAMIC GRAPHIC 07
				print("OBSERVER DYNAMIC GRAPHIC 07")
				observerDynamicGraphic07 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {tr1Leg, tr2Leg}}
			end,
			[8] = function(x)
				-- OBSERVER DYNAMIC GRAPHIC 08
				print("OBSERVER DYNAMIC GRAPHIC 08")
				observerDynamicGraphic08 = Observer{subject = tr1, type = "chart", attributes={"valor1","valor2"}, legends = {tr1Leg, tr2Leg}, title = "Dynamics Graphics"}
			end,
            [9] = function(x)
				-- OBSERVER GRAPHIC 01
				print("GRAPHIC 01") io.flush()
				observerGraphic01 = Observer{ subject = tr1, type = "chart",attributes={"valor1"},xAxis="t" }
			end,
			[10] = function(x) 
				-- OBSERVER GRAPHIC 02
				print("GRAPHIC 02") io.flush()
				observerGraphic02 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t", title=nil}
			end,
			[11] = function(x) 
				-- OBSERVER GRAPHIC 03
				print("GRAPHIC 03") io.flush()
				observerGraphic03 = Observer{ subject = tr1, type = "chart",attributes={"valor1"},xAxis="t",title="GraphicTitle"}
			end,
			[12] = function(x)
				-- OBSERVER GRAPHIC 04
				print("GRAPHIC 04") io.flush()
				observerGraphic04 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t",title="GraphicTitle",curveLabels={"Curve A"} }
			end,
			[13] = function(x) 
				-- OBSERVER GRAPHIC 05
				print("GRAPHIC 05") io.flush()
				observerGraphic05 = Observer{ subject = tr1, type = "chart",attributes={"valor1"},xAxis="t",title="GraphicTitle",curveLabels={"Curve A"}, yLabel="valor1"}
			end,
			[14] = function(x) 
				-- OBSERVER GRAPHIC 06
				print("GRAPHIC 06") io.flush()
				observerGraphic06 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
			end,
			[15] = function(x) 
				-- OBSERVER GRAPHIC 07
				print("GRAPHIC 07") io.flush()
				observerGraphic07 = Observer{ subject = tr1, type = "chart",attributes={"valor1"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
				killObserver = true
			end,
			[16] = function(x) 
				-- OBSERVER GRAPHIC 08
				print("GRAPHIC 08") io.flush()
				observerGraphic08 = Observer{ subject = tr1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t"}
			end,
			[17] = function(x) 
				-- OBSERVER GRAPHIC 09
				print("GRAPHIC 09") io.flush()
				observerGraphic09 = Observer{ subject = tr1, type = "chart",attributes={"valor1","valor2"}, xAxis="t", legends={tr1Leg, tr2Leg}, curveLabels={"Curve A", "CurveB"}}

			end,
			[18] = function(x) 
				-- OBSERVER GRAPHIC 10
				print("GRAPHIC 10") io.flush()
				observerGraphic10 = Observer{ subject = tr1, type = "chart",attributes={"valor1", "valor2"}, xAxis="t", legends={tr1Leg}, curveLabels={"Curve A", "CurveB"}}
			end,
			[19] = function(x) 
				-- OBSERVER GRAPHIC 11
				print("GRAPHIC 11") io.flush()
				observerGraphic11 = Observer{ subject = tr1, type = "chart",attributes={"valor2", "valor1"}, xAxis="t", legends={tr2Leg}, curveLabels={"Curve A", "CurveB"}}
			end,
			[20] = function(x) 
				-- OBSERVER GRAPHIC 07
				print("GRAPHIC 12") io.flush()
				observerGraphic07 = Observer{ subject = tr1, type = "chart",attributes={"valor1","valor2"}, xAxis="t", title="GraphicTitle", curveLabels={"Curve A"}, yLabel="YLabel", xLabel="XLabel"}
				--killObserver = true
			end			
		}
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
    end
end

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

GRAPHIC 05
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico, título da curva e rótulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "XLabel".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetros "título do eixo X".

GRAPHIC 06
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso de valores específicos na lista de parâmetros.

GRAPHIC 07
Este teste será idêntico ao teste 06. Porém, no tempo de simulação 8, o observador "observerGraphic10" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observador será fechada.

GRAPHIC 08
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores roxa e azul respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Com o título do gráfico "GraphicTitle", com o titulo dos labes CurveA e CurveB.

GRAPHIC 09
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores verde (estilo dots) e vermelha respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Com o título do gráfico "GraphicTitle", com o titulo dos labes "CurveA" e "CurveB".

GRAPHIC 10
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores verde (estilo dots) e azul respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor1" e "valor2" da trajetória "tr1". Com o título do gráfico "GraphicTitle", com o titulo dos labes CurveA e CurveB.

GRAPHIC 11
Deverá apresentar um gráfico de dispersão XY, com duas curvas nas cores vermelho e azul respectivamente, onde o eixo X receberá o valor do atributo "t" os eixos Y receberão os atributos "valor2" e "valor1" da trajetória "tr1". Com o título do gráfico "GraphicTitle", com o titulo dos labes CurveA e CurveB.

]]

-- ================================================================================#

-- OBSERVER IMAGE
function test_Image( case)
	if( not SKIP ) then
		obsImage = Observer{ subject = cs, type = "image", attributes={"cover"}, legends = {coverLeg} }
		--obsImage = cs:createObserver("image", {"cover"}, {coverLeg})

		switch( case ) : caseof {

			[1] = function(x)
				-- OBSERVER IMAGE 01 
				print("OBSERVER IMAGE 01") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "image" )
				observerImage01 = Observer{ subject = tr1, type = "image" }
			end,
			[2] = function(x)
				-- OBSERVER IMAGE 02 
				print("OBSERVER IMAGE 02") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "image", {obsImage} )
				observerImage02 = Observer{ subject = tr1, type = "image", observer = obsImage}
			end,
			[3] = function(x)
				-- OBSERVER IMAGE 03
				print("OBSERVER IMAGE 03") io.flush()
				--@DEPRECATED
				--tr1:createObserver("image", {cs})
				observerImage03 = Observer{ subject = tr1, type = "image"}
			end,
			[4] = function(x)
				-- OBSERVER IMAGE 04
				print("OBSERVER IMAGE 04") io.flush()
				--@DEPRECATED
				--tr1:createObserver("image", {cs,obsImage})
				observerImage04 = Observer{ subject = tr1, type = "image", observer = obsImage}
			end,
			[5] = function(x) 
				-- OBSERVER IMAGE 05
				print("OBSERVER IMAGE 05") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
				observerImage05=Observer{subject=tr1, type = "image",legends={tr1Leg}, observer = obsImage }
			end,
			[6] = function(x)
				-- OBSERVER IMAGE 06
				print("OBSERVER IMAGE 06") io.flush()
				tr1.cont=0
				--@DEPRECATED
				--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
				observerImage06=Observer{subject=tr1, type = "image", attributes={"cont"},legends={tr1Leg}, observer = obsImage }
			end,
			[7] = function(x)
				-- OBSERVER IMAGE 07
				print("OBSERVER IMAGE 07") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
				observerImage07=Observer{subject=tr1, type = "image", attributes={"trajectory"},legends={tr1Leg}, observer = obsImage }
			end,
			[8] = function(x) --com trajetória dinamica
				-- OBSERVER IMAGE 08
				print("OBSERVER IMAGE 08") io.flush()
				--@DEPRECATED
				--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
				observerImage08=Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage} 
				-- , path="./Lua",prefix = "prefix_" }
				for i = 1, 10, 1 do
					print("STEP:",i)io.flush()
					if(i%2==0)then
						tr2:filter(newFilter)
					else
						tr2:filter(oldFilter)
					end
					cs:notify()
					delay_s(1)
				end
			end,
			[9] = function(x) --com trajetória dinamica
				-- OBSERVER IMAGE 09
				print("OBSERVER IMAGE 09") io.flush()
				--@DEPRECATED
				--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
				observerImage09 = Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage}
				-- path="./Lua",prefix = "prefix_" }

				killObserver = true

				for i = 1, 10, 1 do
					print("STEP:", i)io.flush()
					if(i%2==0)then
						tr2:filter(newFilter)
					else
						tr2:filter(oldFilter)
					end

					if ((killObserver and observerImage09) and (i == 8)) then
						print("", "observerImage09:kill", observerImage09:kill())io.flush()
					end

					cs:notify()
					delay_s(1)
				end
			end
		}

		if(case < 8) then cs:notify() end
		print(compareDirectory("trajectory","image",case,"."))io.flush()
	end
end
--[[
IMAGE 01
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de trajetória sem a identificação do espaço celular e respectivo observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 02
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de trajetória sem a identificação do espaço celular para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 03
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de trajetória sem a identificação do observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 04
Deve gerar uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda padrão (valores únicos entre 0 e 27; cores entre verde e vermelho) de trajetórias.
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.

IMAGE 05
Deve gerar uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda "tr1Leg" (valores únicos entre 0 e 27; cores entre verde e azul).

IMAGE 06
Resultado idêntico ao do observers IMAGE 05, exceto pelo uso do atributo "cont".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

IMAGE 07
Resultado idêntico ao do observers IMAGE 05, exceto pelo uso do atributo "trajectory".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

IMAGE 08
Deve gerar 10 imagens com fundo em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida com cores de acordo com a legenda "tr2Leg" (valores únicos entre 0 e 10; cores entre vermelho e amarelo) e com forma alternando a cada instante sua orientação, da célula do canto superior esquerdo para a célula do canto inferior direito, e vice-versa.

IMAGE 09
Este teste será idêntico ao teste IMAGE 08. Porém, no tempo de simulação 8, o observador "observerImage06" será destruído. As imagens geradas até o 8o. tempo de simulação conterão o agente. As imagens geradas a partir do 9o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.

-- ================================================================================#]]


-- OBSERVER MAP
function test_Map( case)
	if( not SKIP ) then
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }
		--obsMap = cs:createObserver("map", {"cover"}, {coverLeg})

		switch( case ) : caseof {

			[1] = function(x)
				-- OBSERVER MAP 01 
				print("OBSERVER MAP 01") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "map" )
				observerMap01 = Observer{ subject = tr1, type = "map" }
			end,
			[2] = function(x)
				-- OBSERVER MAP 02 
				print("OBSERVER MAP 02") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "map", {obsMap} )
				observerMap02 = Observer{ subject = tr1, type = "map", observer = obsMap}
			end,
			[3] = function(x)
				-- OBSERVER MAP 03
				print("OBSERVER MAP 03") io.flush()
				--@DEPRECATED
				--tr1:createObserver("map", {cs})
				observerMap03 = Observer{ subject = tr1, type = "map"}
			end,
			[4] = function(x)
				-- OBSERVER MAP 04
				print("OBSERVER MAP 04") io.flush()
				--@DEPRECATED
				--tr1:createObserver("map", {cs,obsMap})
				observerMap04 = Observer{ subject = tr1, type = "map", observer = obsMap}
			end,
			[5] = function(x)
				-- OBSERVER MAP 05
				print("OBSERVER MAP 05") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
				observerMap05=Observer{subject=tr1, type = "map", legends={tr1Leg}, observer = obsMap }
			end,
			[6] = function(x)
				-- OBSERVER MAP 06
				print("OBSERVER MAP 06") io.flush()
				tr1.cont=0
				--@DEPRECATED
				--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
				observerMap06=Observer{subject=tr1, type = "map", attributes={"cont"},legends={tr1Leg}, observer = obsMap }
			end,
			[7] = function(x)
				-- OBSERVER MAP 07
				print("OBSERVER MAP 07") io.flush()
				--@DEPRECATED
				--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
				observerMap07=Observer{subject=tr1, type = "map", attributes={"trajectory"},legends={tr1Leg}, observer = obsMap }
			end,
			[8] = function(x) --com trajetória dinamica
				-- OBSERVER MAP 08
				print("OBSERVER MAP 08") io.flush()
				--@DEPRECATED
				--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
				observerMap08=Observer{subject=tr2, type = "map", legends={tr2Leg}, attributes={"trajectory"}, observer = obsMap }
				for i = 1, 10, 1 do
					print("STEP:",i)
					if(i%2==0)then
						tr2:filter(newFilter)
					else
						tr2:filter(oldFilter)
					end
					cs:notify()
					delay_s(1)
				end
			end,
			[9] = function(x) --com trajetória dinamica
				-- OBSERVER MAP 09
				print("OBSERVER MAP 09") io.flush()
				--@DEPRECATED
				--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
				observerMap09=Observer{subject=tr2, type = "map", legends={tr2Leg}, attributes={"trajectory"}, observer = obsMap }

				killObserver = true

				for i = 1, 10, 1 do
					print("STEP:",i)io.flush()
					if(i%2==0)then
						tr2:filter(newFilter)
					else
						tr2:filter(oldFilter)
					end

					if ((killObserver and observerMap09) and (i == 8)) then
						print("", "observerMap09:kill", observerMap09:kill())io.flush()
					end

					cs:notify()
					delay_s(1)
				end
			end
		}

		cs:notify()
	end
end

--[[
MAP 01
O programa deverá ser abortado. Não é possível utilizar MAP observers de trajectory sem a identificação do espaço celular e respectivo observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 02
O programa deverá ser abortado. Não é possível utilizar MAP observers de trajectory sem a identificação do espaço celular para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 03
O programa deverá ser abortado. Não é possível utilizar MAP observers de trajectory sem a identificação do observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 04
Deve iniciar apresentando uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda padrão (?????) de trajetórias.
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.

MAP 05
Deve iniciar apresentando uma imagem em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida sob as células das bordas laterais e borda superior com cores definidas pela legenda "tr1Leg" (valores únicos entre 0 e 27; cores entre verde e azul).

MAP 06
Resultado idêntico ao do observers MAP 05, exceto pelo uso do atributo "cont".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

MAP 07
Resultado idêntico ao do observers MAP 05, exceto pelo uso do atributo "trajectory".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

MAP 08
Deve iniciar apresentando uma imagem com fundo em preto, de acordo com a legenda do atributo "cover" ( do espaço celular "cs") que pode assumir os valores numéricos 0 e 1 (cores preto ou vermelho). A trajetória será exibida com cores de acordo com a legenda "tr2Leg" (valores únicos entre 0 e 10; cores entre vermelho e amarelo) e com forma alternando a cada instante sua orientação, da célula do canto superior esquerdo para a célula do canto inferior direito, e vice-versa.

================================================================================#]]

-- OBSERVER UDP
function test_udp( case)
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER UDPSENDER 01
				print("OBSERVER UDPSENDER 01") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender")
				observerUdpSender01 = Observer{ subject = tr1, type = "udpsender" }
			end,
			[2] = function(x)
				-- OBSERVER UDPSENDER 02
				print("OBSERVER UDPSENDER 02") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender", {})
				observerUdpSender02 = Observer{ subject = tr1, type = "udpsender",attributes={} }
			end,
			[3] = function(x)
				-- OBSERVER UDPSENDER 03
				print("OBSERVER UDPSENDER 03") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender", {}, {})
				observerUdpSender03 = Observer{ subject = tr1, type = "udpsender",hosts ={}, attributes={} }
			end,
			[4] = function(x)
				-- OBSERVER UDPSENDER 04
				print("OBSERVER UDPSENDER 04") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender", { "path"})
				observerUdpSender04 = Observer{ subject = tr1, type = "udpsender", attributes = {"valor1"} }
			end,
			[5] = function(x)
				-- OBSERVER UDPSENDER 05
				print("OBSERVER UDPSENDER 05") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender", { "cont", "path"}, {"54544"})
				observerUdpSender05 = Observer{ subject = tr1, type = "udpsender", attributes = { "valor1", "valor2"},port="54544" }
			end,
			[6] = function(x)
				-- OBSERVER UDPSENDER 06
				print("OBSERVER UDPSENDER 05") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender", { "cont", "path" }, {"54544", IP2})
				observerUdpSender06 = Observer{ subject = tr1, type = "udpsender", attributes = { "valor1", "valor2"},port= "54544",hosts={IP2} }
			end,
			[7] = function(x)
				-- OBSERVER UDPSENDER 07
				print("OBSERVER UDPSENDER 07") io.flush()
				--@DEPRECATED
				--cs:createObserver("udpsender", { "cont", "path" }, {"54544", IP1, IP2})
				observerUdpSender07 = Observer{ subject = tr1, type = "udpsender", attributes = { "valor1", "valor2"},port = "54544",hosts={IP1,IP2} }
			end
		}

		cs:notify()

	end
end

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do cellular space "cs" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas uma mensagem "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do cellular space "cs" e seu atributo "path".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas uma mensagem "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do cellular space "cs" e seus atributos "cont" e "path".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas uma mensagem "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber uma mensagens idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações do cellular space "cs" e seus atributos "cont" e "path".
Serão disparadas uma mensagem "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações do cellular space "cs" e seus atributos "cont" e "path".
Serão disparadas uma mensagem "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas uma mensagem idênticas. Esta mensagem serão transformadas em arquivos pelo cliente de testes.

-- ================================================================================#]]

-- SKIP = false

-- test_Image(TEST)  -- cases of [1..9]
-- test_Map(TEST)  -- cases of [1..9]
-- test_udp(TEST) -- cases of [1..7]

-- Os testes do método "kill" usando o Map e Image devem ser feitos separadamente

testsSourceCodes = {
    test_textScreen,
    test_logFile,
    test_table,
    test_chart,
	test_Image,
	test_Map,
	test_udp
}

print("**     TESTS FOR TRAJECTORY OBSERVERS      **\n")io.flush()
print("** Choose observer type and test case **")io.flush()
print("(1) TextScreen             ","[ Cases 1..4  ]")io.flush()
print("(2) LogFile             ","[ Cases 1..5  ]")io.flush()
print("(3) Table             ","[ Cases 1..5  ]")io.flush()
print("(4) Chart             ","[ Cases 1..19  ]")io.flush()
print("(5) Image             ","[ Cases 1..9  ]")io.flush()
print("(6) Map               ","[ Cases 1..9  ]")io.flush()
print("(7) UDP               ","[ Cases 1..7  ]")io.flush()

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
