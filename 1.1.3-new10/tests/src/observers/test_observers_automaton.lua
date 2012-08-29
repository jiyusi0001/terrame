-- Hoje só é possivel notificar o cellularSpace para que o observer do automaton seja redesenhado. O automaton nao guarda referencias para este observer


--[[
OBS.:

Comentar State Machine

MAP 03 / IMAGE 04
Legenda padrão para texto ainda não definida.

MAP 04 / IMAGE 04 / IMAGE 05
Não foi possivel determinar a saida deste teste porque não sabemos se as cores da legenda do cellular space
devem se misturar com as cores do automaton.
]]

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

--require "XDebug"

function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end


cs = CellularSpace{ xdim = 0}
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
	end
end

soilWaterLeg = Legend{
	type = "number",
	grouping = "equalsteps",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 100,
	minimum = 0,
	colorBar = {
		{color = "green", value = 0},
		{color = "blue", value = 100}
	}
}

currentStateLeg = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "brown", value = "seco"},
		{color = "yellow", value = "molhado"}
	}
}

state1 = State{
	id = "seco",
	Jump{
		function( event, agent, cell )
			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end,
		target = "molhado"
	}
}

state2 = State{
	id = "molhado",
	Jump{
		function( event, agent, cell )
			--print(agent.cont,"molhado")
			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end, 
		target = "seco"
	}
}

at1 = Automaton{
	id = "MyAutomaton",
	it = Trajectory{
		target = cs, 
		select = function(cell)
			local x = cell.x - 5;
			local y = cell.y - 5;
			return (x*x) + (y*y)  - 16 < 0.1
		end
	},
	acum = 0,
	cont  = 0,
	st2 = state2,
	st1 = state1,
}

env = Environment{ 
	id = "MyEnvironment"
}

t = Timer{
	Event{ time = 0, action = function(event) at1:execute(event) return true end }
}
-- insert CellularSpaces before Automata, Agents and Timers
env:add( cs )
env:add( at1 )

ev = Event{ time = 1, period = 1, priority = 1 }

at1:setTrajectoryStatus( true )

-- Enables kill an observer
killObserver = false


-- ================================================================================#
-- OBSERVER TEXTSCREEN
function test_TextScreen(case) 
	if( not SKIP ) then
		middle = math.floor(#cs.cells/2)
		cell = cs.cells[middle]
		switch( case ) : caseof {
			[1] = function(x) 
				--OBSERVER TEXTSCREEN 01 
				print("OBSERVER TEXTSCREEN 01") io.flush()
				--@DEPRECATED
				--at1:createObserver("textscreen")
				observerTextScreen01 = Observer{ subject=at1, type = "textscreen" }
			end,

			[2] = function(x) 
				--OBSERVER TEXTSCREEN 02 
				print("OBSERVER TEXTSCREEN 02") io.flush()
				--@DEPRECATED
				--at1:createObserver("textscreen")
				observerTextScreen02 = Observer{ subject=at1, type = "textscreen" }
			end,

			[3] = function(x) 
				--OBSERVER TEXTSCREEN 03 
				print("OBSERVER TEXTSCREEN 03") io.flush()
				--@DEPRECATED
				--at1:createObserver("textscreen")
				observerTextScreen03 = Observer{ subject=at1, type = "textscreen" }
			end,

			[4] = function(x)
				-- OBSERVER TEXTSCREEN 04 
				print("OBSERVER TEXTSCREEN 04") io.flush()
				--@DEPRECATED
				--at1:createObserver( "textscreen", {},{cell} )
				observerTextScreen04 = Observer{ subject = at1, type = "textscreen", attributes={}, location=cell }
			end,

			[5] = function(x)
				-- OBSERVER TEXTSCREEN 05 
				print("OBSERVER TEXTSCREEN 05") io.flush()
				--@DEPRECATED
				--at1:createObserver( "textscreen", {"currentState"}, {cell} )
				observerTextScreen05 = Observer{ subject = at1, type = "textscreen", attributes={"currentState","acum"}, location=cell}
			end,

			[6] = function(x)
				-- OBSERVER TEXTSCREEN 06 
				print("OBSERVER TEXTSCREEN 06") io.flush()
				--@DEPRECATED
				--at1:createObserver( "textscreen", {"currentState"}, {cell} )
				observerTextScreen06 = Observer{ subject = at1, type = "textscreen", attributes={"currentState","acum"}, location=cell}

				killObserver = true
			end
		}

		for i=1, 10 , 1 do	
			print("STEP: ", i) io.flush()
			at1:notify()
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)			

			if ((killObserver and observerTextScreen06) and (i == 8)) then
				print("", "observerTextScreen06:kill", observerTextScreen06:kill())
			end

			delay_s(1)
		end
	end
end
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03
O programa deverá ser abortado. Não é possível utilizar observers de autômatos sem a identificação do parâmetro "location".
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

TEXTSCREEN 04
Deve apresentar na tela uma tabela textual contendo todos os atributos do autômato "at1" no cabeçalho: "acum", "cont", "currentState", "id", "it", "cObj_", "st1" e "st2". Todos esses atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. 
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 05
Deve apresentar na tela uma tabela textual  contendo os atributos do automaton "at1" no cabeçalho: "currentState" e "acum". Os atributos devem ser apresentados na ordem em que é feita a especificação.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 06
Este teste será idêntico ao teste 05. Porém, no tempo de simulação 8, o observador "observerTextScreen06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

================================================================================#]]
-- OBSERVER LOGFILE
function test_LogFile( case) 
	if(not  SKIP ) then	
		middle = math.floor(#cs.cells/2)
		cell = cs.cells[middle]
		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER LOGFILE 01 
				print("OBSERVER LOGFILE 01") io.flush()
				--@DEPRECATED
				--at1:createObserver("logfile")
				observerLogFile01 = Observer{ subject = at1, type = "logfile" }
			end,

			[2] = function(x)
				-- OBSERVER LOGFILE 02 
				print("OBSERVER LOGFILE 02") io.flush()
				--@DEPRECATED
				--at1:createObserver("logfile",{})
				observerLogFile02 = Observer{ subject = at1, type = "logfile", attributes={} }
			end,

			[3] = function(x)
				-- OBSERVER LOGFILE 03 
				print("OBSERVER LOGFILE 03") io.flush()
				--@DEPRECATED
				--at1:createObserver("logfile",{},{})
				observerLogFile03 = Observer{ subject = at1, type = "logfile", attributes={} }
			end,

			[4] = function(x)
				-- OBSERVER LOGFILE 04
				print("OBSERVER LOGFILE 04") io.flush()
				--@DEPRECATED
				--at1:createObserver( "logfile", {},{cell} )
				observerLogFile04 = Observer{ subject = at1, type = "logfile", attributes={},location=cell }
			end,

			[5] = function(x)
				-- OBSERVER LOGFILE 05
				print("OBSERVER LOGFILE 05") io.flush()
				--@DEPRECATED
				--at1:createObserver( "logfile", {"currentState"}, {cell} )
				observerLogFile05 = Observer{ subject = at1, type = "logfile", attributes={"currentState","acum"},location=cell}
			end,
			[6] = function(x)
				-- OBSERVER LOGFILE 06
				print("OBSERVER LOGFILE 06") io.flush()
				--@DEPRECATED
				--at1:createObserver( "logfile", {"currentState"}, {cell, "logfile.csv", ","} )
				observerLogFile06 = Observer{subject = at1, type="logfile", location=cell, outfile="logfile.csv", separator=","}
			end,
			[7] = function(x)
				-- OBSERVER LOGFILE 07
				print("OBSERVER LOGFILE 07") io.flush()
				--@DEPRECATED
				--at1:createObserver( "logfile", {"currentState"}, {cell, "logfile.csv", ","} )
				observerLogFile07 = Observer{subject = at1, type="logfile", location=cell, outfile="logfile.csv", separator=","}

				killObserver = true
			end
		}
		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			at1:notify()
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)

			if ((killObserver and observerLogFile07) and (i == 8)) then
				print("", "observerLogFile07:kill", observerLogFile07:kill())
			end

			delay_s(1)
		end
	end
end
--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03
O programa deverá ser abortado. Não é possível utilizar observers de autômatos sem a identificação do parâmetro "location".
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

LOGFILE 04

Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser uma tabela textual contendo todos os atributos do autômato "at1" no cabeçalho: "acum", "cont", "currentState", "id", "it", "cObj_", "st1" e "st2". Todos esses atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. 
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 05

Deverá ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos "currentState" e "acum". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes atributos.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

LOGFILE 06

Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE04) deverão ser apresentados.
Deverão ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.

Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",", que contém uma tabela textual com o atributo "currentState". Deverão ser apresentadas também o número de linhas correspondente ao valor da variável "10" com os valores relativos ao atributo do cabeçalho.

LOGFILE 07
Este teste será idêntico ao teste 05. Porém, no tempo de simulação 8, o observador "observerLogFile07" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "logfile.csv" conterá apenas informações até o 8o. tempo de simulação


-- ================================================================================#]]
-- OBSERVER TABLE
function test_Table( case) 
	if( not SKIP ) then
		middle = math.floor(#cs.cells/2)
		cell = cs.cells[middle]
		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER TABLE 01 
				print("OBSERVER TABLE 01") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table" )
				observerTable01 = Observer{ subject = at1, type = "table" }
			end,

			[2] = function(x)
				-- OBSERVER TABLE 02
				print("OBSERVER TABLE 02") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table", {} )
				observerTable02 = Observer{ subject = at1, type = "table", attributes={} }
			end,

			[3] = function(x)
				-- OBSERVER TABLE 03 
				print("OBSERVER TABLE 03") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table", {}, {} )
				observerTable03 = Observer{ subject = at1, type = "table", attributes={} }
			end,

			[4] = function(x)
				--OBSERVER TABLE 04
				print("OBSERVER TABLE 04") io.flush()
				--at1:createObserver( "table", {},{cell} )
				observerTable04 = Observer{ subject = at1, type = "table",attributes={}, location=cell }
			end,

			[5] = function(x)
				-- OBSERVER TABLE 05
				print("OBSERVER TABLE 05") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table", {"currentState"}, {cell,"","valores"} )
				observerTable05 = Observer{ subject = at1, type = "table",attributes={"currentState"},location=cell,xLabel ="Valores" }
			end,

			[6] = function(x)
				-- OBSERVER TABLE 06
				print("OBSERVER TABLE 06") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table", {"currentState"}, {cell,"atributos",""} )
				observerTable06 = Observer{ subject = at1, type = "table",attributes={"acum"},yLabel = "Atributos",location=cell}
			end,

			[7] = function(x)
				-- OBSERVER TABLE 07
				print("OBSERVER TABLE 07") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table", {"currentState","acum"}, {cell,"atributos","valores"})
				observerTable07 = Observer{ subject = at1, type = "table",attributes={"currentState","acum"} ,yLabel = "Atributos", xLabel ="Valores",location=cell }
			end,

			[8] = function(x)
				-- OBSERVER TABLE 08
				print("OBSERVER TABLE 08") io.flush()
				--@DEPRECATED
				--at1:createObserver( "table", {"currentState","acum"}, {cell,"atributos","valores"})
				observerTable08 = Observer{ subject = at1, type = "table",attributes={"currentState","acum"} ,yLabel = "Atributos", xLabel ="Valores",location=cell }

				killObserver = true
			end
		}
		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			cs:notify(i)
			at1:notify(i)
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)			

			if ((killObserver and observerTable08) and (i == 8)) then
				print("", "observerTable08:kill", observerTable08:kill())
			end

			delay_s(1)
		end
	end
end
--[[
TABLE 01 / TABLE 02 / TABLE 03
O programa deverá ser abortado. Não é possível utilizar observers de autômatos sem a identificação do parâmetro "location".
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

TABLE 04
Deverá ser apresentada uma tabela contendo todos os atributos do autômato "at1" como linhas da tabela: "acum", "cont", "currentState", "id", "it", "cObj_", "st1" e "st2". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values". Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 05
Deve apresentar na tela uma tabela contendo o atributo "currentState". A primeira coluna deverá ter o valor padrão "Attributes" enquanto a segunda coluna deverá ter o valor "Valores".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 06
Deve apresentar na tela uma tabela contendo o atributo "acum". A primeira coluna deverá ter o valor "Atributos" enquanto a segunda coluna deverá ter o valor padrão "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 07
Deve apresentar na tela uma tabela contendo os atributos "currentState" e "acum". Os atributos devem ser apresentados na ordem em que é feita a especificação. As colunas deverão ter os valores "Atributos" e "Valores".

TABLE 08
Este teste será idêntico ao teste 07. Porém, no tempo de simulação 8, o observador "observerTable08" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.


-- ================================================================================#]]
-- OBSERVER DYNAMIC GRAPHIC E OBSERVER GRAPHIC
function test_Chart( case )
	if( not SKIP ) then
		middle = math.floor(#cs.cells/2)
		cell = cs.cells[middle]
		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER DYNAMIC GRAPHIC 01
				print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {},{})
				observerDynamicGraphic01 = Observer{ subject = at1, type = "chart",attributes={}}
			end,

			[2] = function(x)
				-- OBSERVER DYNAMIC GRAPHIC 02
				print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{})
				observerDynamicGraphic02 = Observer{ subject = at1, type = "chart",attributes={"currentState"} }
			end,

			[3] = function(x)
				-- OBSERVER DYNAMIC GRAPHIC 03
				print("OBSERVER DYNAMIC GRAPHIC 03") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{})
				observerDynamicGraphic03 = Observer{ subject = at1, type = "chart", location=cell, attributes={"currentState"} }
			end,

			[4] = function(x)
				-- OBSERVER DYNAMIC GRAPHIC 04
				print("OBSERVER DYNAMIC GRAPHIC 04") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"currentState"},{cell, "titulo","curva","x eixo","y eixo"} )
				observerDynamicGraphic04 = Observer{ subject = at1, type = "chart",attributes={"currentState"},location=cell, title = "titulo", curveLabel="curva", yLabel = "- currentState -" }
			end,

			[5] = function(x)
				-- OBSERVER GRAPHIC 01
				print("OBSERVER GRAPHIC 01") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState","acum"},{cell})
				observerGraphic01 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum",location=cell}
			end,

			[6] = function(x)
				-- OBSERVER GRAPHIC 02
				print("OBSERVER GRAPHIC 02") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState","acum"}, {cell,"GraphicTitle"})	 	
				observerGraphic02 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", location=cell}
			end,

			[7] = function(x)
				-- OBSERVER GRAPHIC 03
				print("OBSERVER GRAPHIC 03") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle"}) 	
				observerGraphic03 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle",curveLabel="CurveTitle", location=cell}
			end,

			[8] = function(x)
				-- OBSERVER GRAPHIC 04
				print("OBSERVER GRAPHIC 04") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel"})
				observerGraphic04 = Observer{ subject = at1, type = "chart",attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", location=cell}
			end,
			[9] = function(x)
				-- OBSERVER GRAPHIC 05
				print("OBSERVER GRAPHIC 05") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
				observerGraphic05 = Observer{ subject = at1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabel=" CurveTitle", yLabel="yLabel", xLabel="XLabel", location=cell }
			end,
			[10] = function(x)
				-- OBSERVER GRAPHIC 06
				print("OBSERVER GRAPHIC 06") io.flush()
				--@DEPRECATED
				--at1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "acum"}, {cell,"GraphicTitle","CurveTitle","YLabel","XLabel"})
				observerGraphic06 = Observer{ subject = at1, type="chart", attributes={"currentState"}, xAxis="acum", title="GraphicTitle", curveLabel=" CurveTitle", yLabel="yLabel", xLabel="XLabel", location=cell }

				killObserver = true
			end
		}
		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			cs:notify(i)
			at1:notify(i)
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				--at1.acum = math.cos(i*3.14/2)
				cell.soilWater=i*10
			end)

			if ((killObserver and observerGraphic06) and (i == 8)) then
				print("", "observerGraphic06:kill", observerGraphic06:kill())
			end

			delay_s(1)
		end
	end
end
--[[
DYNAMIC GRAPHIC 01
O programa deverá ser abortado. Não é possível utilizar os observers de autômatos sem a identificação de um atributo para o eixo Y.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 02
O programa deverá ser abortado. Não é possível utilizar os observers de autômatos sem a identificação do parâmetro "location".
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 03
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "currentState", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 04
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "currentState", respectivamente. Serão usados como valores para os parâmetros do gráfico: título do gráfico ("titulo"), título da curva ("curva"), título do eixo X ("time"), título do eixo y ("- currentState -").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros "xLabel".

GRAPHIC 01
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "acum" e "currenState", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
Valores em "x" variam linearmente. Valores em "y" variam entre 0 e 1.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 02
Resultado idêntico ao do observers GRAPHIC01, exceto pelo uso do título do gráfico "GraphicTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 03
Resultado idêntico ao do observers GRAPHIC02, exceto pelo uso do título do gráfico e título da curva: "GraphicTitle" e "CurveTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do eixo Y" e "título do eixo X").

GRAPHIC 04
Resultado idêntico ao do observers GRAPHIC02, exceto pelo uso do título do gráfico, título da curva e rótulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "YLabel".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetros "título do eixo X".

GRAPHIC 05
Resultado idêntico ao do observers GRAPHIC02, exceto pelo uso da lista de parâmetros.

GRAPHIC 06
Este teste será idêntico ao teste GRAPHIC 05. Porém, no tempo de simulação 8, o observador "observerGraphic06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.


-- ================================================================================#]]

-- OBSERVER UDP
function test_UDP( case )
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		middle = math.floor(#cs.cells/2)
		cell = cs.cells[middle]
		switch( case ) : caseof {

			[1] = function(x)
				-- OBSERVER UDPSENDER 01
				print("OBSERVER UDPSENDER 01") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender")
				observerUdpSender01 = Observer{ subject = at1, type = "udpsender" }
			end,

			[2] = function(x)
				-- OBSERVER UDPSENDER 02
				print("OBSERVER UDPSENDER 02") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", {})
				observerUdpSender02 = Observer{ subject = at1, type = "udpsender", attributes = {} }
			end,

			[3] = function(x)
				-- OBSERVER UDPSENDER 03
				print("OBSERVER UDPSENDER 03") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", {}, {})
				observerUdpSender03 = Observer{ subject = at1, type = "udpsender", attributes = {} }
			end,

			[4] = function(x)
				-- OBSERVER UDPSENDER 04
				print("OBSERVER UDPSENDER 04") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", { "currentState", "cont"},{cell})
				observerUdpSender04 = Observer{ subject = at1, type = "udpsender", attributes = { "currentState"},location=cell }
			end,

			[5] = function(x)
				-- OBSERVER UDPSENDER 05
				print("OBSERVER UDPSENDER 05") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", { "currentState", "cont" }, {cell,"666"})
				observerUdpSender05 = Observer{ subject = at1, type = "udpsender", attributes = { "currentState", "acum"},port="666",location=cell }	
			end,

			[6] = function(x)
				-- OBSERVER UDPSENDER 06
				print("OBSERVER UDPSENDER 06") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", { "currentState", "cont" }, {cell,"666", "127.0.0.1"})
				observerUdpSender06 = Observer{ subject = at1, type = "udpsender", attributes = { "currentState", "acum" },port="666",hosts={IP1},location=cell }
			end,

			[7] = function(x)
				-- OBSERVER UDPSENDER 07
				print("OBSERVER UDPSENDER 07") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", { "currentState", "cont" }, {cell,"666", IP1, IP2})
				observerUdpSender07 = Observer{ subject = at1, type = "udpsender", attributes = { "currentState", "acum"},port="666",hosts={IP1,IP2},location=cell }
			end,

			[8] = function(x)
				-- OBSERVER UDPSENDER 08
				print("OBSERVER UDPSENDER 08") io.flush()
				--@DEPRECATED
				--at1:createObserver("udpsender", { "currentState", "cont" }, {cell,"666", IP1, IP2})
				observerUdpSender08 = Observer{ subject = at1, type = "udpsender", attributes = { "currentState", "acum"},port="666",hosts={IP1,IP2},location=cell }

				killObserver = true
			end
		}
		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			cs:notify()
			at1:notify()
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)

			if ((killObserver and observerUdpSender08) and (i == 8)) then
				print("", "observerUdpSender08:kill", observerUdpSender08:kill())
			end

			delay_s(1)
		end	
	end
end

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do automaton "at1" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do automaton "at1" e seu atributo "currenState".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do automaton "at1" e seus atributos "currenState" e "acum".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações do automaton "at1" e seus atributos "currentState" e "acum".
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações do automaton "at1" e seus atributos "currentState" e "acum".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes. 

UDPSENDER 08
Este teste será idêntico ao teste UDPSENDER 07. Porém, no tempo de simulação 8, o observador "observerUdpSender08" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

-- ================================================================================#]]

-- OBSERVER STATEMACHINE
function test_StateMachine( case )
	if( not SKIP ) then
		middle = math.floor(#cs.cells/2)
		cell = cs.cells[middle]
		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER STATEMACHINE 01
				print("OBSERVER STATEMACHINE 01") io.flush()
				--@DEPRECATED
				--at1:createObserver( "statemachine")
				observerStateMachine01=Observer{subject=at1, type = "statemachine"}
			end,
			[2] = function(x)
				-- OBSERVER STATEMACHINE 02
				print("OBSERVER STATEMACHINE 02") io.flush()
				--@DEPRECATED
				--at1:createObserver( "statemachine",{} )
				observerStateMachine02=Observer{subject=at1, type = "statemachine", atributes={}}
			end,

			[3] = function(x)
				-- OBSERVER STATEMACHINE 03
				print("OBSERVER STATEMACHINE 03") io.flush()
				--@DEPRECATED
				--at1:createObserver( "statemachine", {},{})
				observerStateMachine03=Observer{subject=at1, type = "statemachine", attributes={}}
			end,

			[4] = function(x)
				--OBSERVER STATEMACHINE 04
				print("OBSERVER STATEMACHINE 04") io.flush()
				--@DEPRECATED
				--at1:createObserver( "statemachine" , {"currentState"}, {cell} )
				observerStateMachine04=Observer{subject=at1, type = "statemachine", attributes={"currentState"},legends={}, location=cell}
			end,

			[5] = function(x)
				--OBSERVER STATEMACHINE 05
				print("OBSERVER STATEMACHINE 05") io.flush()
				--@DEPRECATED
				--at1:createObserver( "statemachine" , {"currentState"}, {cell, currentStateLeg} )
				observerStateMachine05=Observer{subject=at1, type = "statemachine",legends={currentStateLeg}, location=cell}
			end,

			[6] = function(x)
				--OBSERVER STATEMACHINE 06
				print("OBSERVER STATEMACHINE 06") io.flush()
				--@DEPRECATED
				--at1:createObserver( "statemachine" , {"currentState"}, {cell, currentStateLeg} )
				observerStateMachine06=Observer{subject=at1, type = "statemachine",legends={currentStateLeg}, location=cell}

				killObserver = true
			end

		}

		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			cs:notify()
			at1:notify()
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)

			if ((killObserver and observerStateMachine06) and (i == 8)) then
				print("", "observerStateMachine06:kill", observerStateMachine06:kill())
			end

			delay_s(1)
		end
	end
end
-- TESTES STATEMACHINE
--[[
STATEMACHINE 01 / STATEMACHINE 02 / STATEMACHINE 03
O programa deverá ser abortado. Não é possível utilizar os observers de autômatos sem a identificação do parâmetro "location".
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

STATEMACHINE 04
O programa deverá apresentar uma janela com mensagem informando que o atributo selecionado não é um valor numérico.
Deve apresentar uma máquina de estados contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro deve ser cinza.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "subtitle".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

STATEMACHINE 05
Deve ser apresentada uma máquina de estados contendo dois estados, preenchidos de acordo com a legenda "currentStateLeg" ("molhado" em verde e "seco" em marrom). A cada iteração o estado atual deve estar destacado com bordas em negrito.

STATEMACHINE 06
Este teste será idêntico ao teste STATEMACHINE 05. Porém, no tempo de simulação 8, o observador "observerStateMachine05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

-- ================================================================================#]]

-- OBSERVER MAP
function test_Map( case )
	if(not  SKIP ) then
		obs = Observer{ subject = cs, type = "map", attributes={"soilWater"}, legends= {soilWaterLeg} }
		switch( case ) : caseof {

			[1] = function(x)
				-- OBSERVER MAP 01 
				print("OBSERVER MAP 01 ") io.flush()
				--@DEPRECATED
				--at1:createObserver( "map")
				observerMap01 = Observer{ subject = at1, type = "map" }
			end,

			[2] = function(x)
				-- OBSERVER MAP 02 
				print("OBSERVER MAP 02 ") io.flush()
				--@DEPRECATED
				--at1:createObserver( "map",{"currentState"})
				observerMap02 = Observer{ subject = at1, type = "map", attributes={"currentState"}}
			end,

			[3] = function(x)
				-- OBSERVER MAP 03 
				print("OBSERVER MAP 03 ") io.flush()
				--@DEPRECATED
				--at1:createObserver( "map",{"currentState"},{cs,obs})
				observerMap03 = Observer{ subject = at1, type = "map", attributes={"currentState"}, observer = obs}
			end,

			[4] = function(x)
				-- OBSERVER MAP 04 
				print("OBSERVER MAP 04") io.flush()
				--@DEPRECATED
				--at1:createObserver( "map", {"currentState"}, {cs, obs, currentStateLeg} )
				observerMap04 = Observer{ subject = at1, type = "map", attributes={"currentState"}, observer = obs,legends = {currentStateLeg} }
			end,

			[5] = function(x)
				-- OBSERVER MAP 05 
				print("OBSERVER MAP 05") io.flush()
				--@DEPRECATED
				--at1:createObserver( "map", {"currentState"}, {cs, obs, currentStateLeg} )
				observerMap05 = Observer{ subject = at1, type = "map", attributes={"currentState"}, observer = obs,legends = {currentStateLeg} }

				killObserver = true               
			end
		}

		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			cs:notify()
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)

			if ((killObserver and observerMap05) and (i == 8)) then 
				print("", "observerMap05:kill", observerMap05:kill())
			end

			delay_s(1)
		end
	end
end
-- TESTES MAP
--[[
MAP 01
O programa deverá ser abortado. Não é possível utilizar MAP observers sem a identificação de pelo menos um atributo.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 02
O programa deverá ser abortado. Não é possível utilizar MAP observers de autômatos sem a identificação do espaço celular e respectivo observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 03
O programa deverá apresentar uma janela com mensagem informando que o atributo selecionado não é um valor numérico. Deve também deve ser apresentada uma imagem em amarelo com um círculo verde no meio. As cores do círculo devem variar entre verde e amarelo. A legenda para o atributo "currentState" (automaton: "at1") deve ser a legenda padrão. A legenda do atributo "soilWater" (celullar space: "cs") deve ter 10 faixas variando (passos iguais) com cores entre verde e azul e valores numéricos entre 0 e 100.
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.

MAP04
Deve iniciar apresentando uma imagem em amarelo com um círculo marrom ao centro. A cor do círculo deve oscilar entre marrom e amarelo, de acordo com a legenda do atributo "currentState" (do autômato "at1"): 2 faixas (valor único) sendo marrom para "seco" e amarelo para "molhado". A legenda do atributo "soilWater" (celullar space "cs") deve ter 10 faixas variando (em passos iguais) com cores entre verde e azul e valores numéricos entre 0 e 100.


MAP05
Este teste será idêntico ao teste MAP 04. Porém, no tempo de simulação 8, o observador "observerMap07" será destruído. As imagens exibidas até o 8o. tempo de simulação conterão o agente. As imagens exibidas a partir do 9o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o automâto não estrará presente na imagem.

================================================================================#]]

-- OBSERVER IMAGE
function test_Image( case )
	if( not SKIP ) then
		--obs = cs:createObserver("image", {"soilWater"}, {soilWaterLeg})
		obs = Observer{ subject = cs, type = "image", attributes={"soilWater"},legends= {soilWaterLeg} }
		switch( case ) : caseof {

			[1] = function(x)
				-- OBSERVER IMAGE 01 
				print("OBSERVER IMAGE 01 ") io.flush()
				--@DEPRECATED
				--at1:createObserver( "image")
				observerImage01 = Observer{ subject = at1, type = "image"}
			end,

			[2] = function(x)
				-- OBSERVER IMAGE 02 
				print("OBSERVER IMAGE 02 ") io.flush()
				--@DEPRECATED
				--at1:createObserver( "image", {"currentState"} )
				observerImage02 = Observer{ subject = at1, type = "image", attributes={"currentState"}}
			end,

			[3] = function(x)
				-- OBSERVER IMAGE 03
				print("OBSERVER IMAGE 03") io.flush()
				--@DEPRECATED
				--at1:createObserver("image", {"currentState"}, {cs, obs})
				observerImage03 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs}
			end,

			[4] = function(x)
				-- OBSERVER IMAGE 04
				print("OBSERVER IMAGE 04 ") io.flush()
				--@DEPRECATED
				--at1:createObserver("image", {"currentState"}, {cs, obs, currentStateLeg})
				observerImage04 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs,legends= {currentStateLeg} }          
			end,			
			[5] = function(x)
				-- OBSERVER IMAGE 05
				print("OBSERVER IMAGE 05 ") io.flush()
				--@DEPRECATED
				--at1:createObserver("image", {"currentState"}, {cs, obs,".", "prefix_", currentStateLeg})
				observerImage05 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs,legends= {currentStateLeg},path=".",prefix="prefix_" }
			end,			
			[6] = function(x)
				-- OBSERVER IMAGE 06
				print("OBSERVER IMAGE 06 ") io.flush()
				--@DEPRECATED
				--at1:createObserver("image", {"currentState"}, {cs, obs,".", "prefix_", currentStateLeg})
				observerImage06 = Observer{ subject = at1, type = "image", attributes={"currentState"}, observer = obs,legends= {currentStateLeg},path=".",prefix="prefix_" }

				killObserver = true
			end	
		}

		for i=1, 10 , 1 do
			print("STEP: ", i) io.flush()
			cs:notify()
			--at1:notify()
			at1.cont = 0
			at1:execute(ev)
			forEachCell(cs, function(cell)
				cell.soilWater=i*10
			end)

			if ((killObserver and observerImage06) and (i == 8)) then
				print("", "observerImage06:kill", observerImage06:kill())
			end

			delay_s(1)
		end
	end
end
-- TESTES IMAGE
--[[
IMAGE01
O programa deverá ser abortado. Não é possível utilizar IMAGE observers sem a identificação de pelo menos um atributo.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE02
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de autômatos sem a identificação do espaço celular e respectivo observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE03
Deve gerar 10 imagens preenchidas no plano de fundo com as cores da legenda do atributo "soilWater" (do espaço celular "cs"): 10 faixas (passos iguais) com cores variando entre verde e azul e valores numéricos entre 0 e 100. Deve ser formado um círculo no centro da imagem com as cores da legenda padrão para
o atributo "currentState" (do autômato "at1").
Deverá ser emitida mensagem de "Warning" informando o uso de legenda padrão.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE04
Deve gerar 10 imagens preenchidas no plano de fundo com as cores da legenda do atributo "soilWater" (do espaço celular "cs"): 10 faixas (passos iguais) com cores variando entre verd3 e azul e valores numéricos entre 0 e 100. Deve ser formado um círculo no centro da imagem com as cores da legenda do atributo "currentState" (do autômato "at1"): 2 faixas de valores (valor único), sendo marrom para "seco" e amarelo para "molhado", respectivamente.
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão.

IMAGE 05
Resultados idênticos aos do observer IMAGE04, exceto pelo uso de valores específicos para o diretório de saída e o prefixo dos arquivos.

IMAGE 06
Este teste será idêntico ao teste IMAGE 05. Porém, no tempo de simulação 8, o observador "observerImage06" será destruído. As imagens geradas até o 8o. tempo de simulação conterão o agente. As imagens geradas a partir do 9o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.

================================================================================#]]

-- SKIP = false
MAX_COUNT = 9

testsSourceCodes = {
	test_TextScreen, 
	test_LogFile,
	test_Table,
	test_Chart,
	test_Image,
	test_Map,
	test_StateMachine,
	test_UDP
}


print("**     TESTS FOR AUTOMATON OBSERVERS      **\n")
print("** Choose observer type and test case **")
print("(1) TextScreen   ","[ Cases 1..6  ]")
print("(2) LogFile      ","[ Cases 1..7  ]")
print("(3) Table	    ","[ Cases 1..8  ]")
print("(4) Chart        ","[ Cases 1..10 ]")
print("(5) Image 	    ","[ Cases 1..6  ]")
print("(6) Map          ","[ Cases 1..5  ]")
print("(7) StateMachine ","[ Cases 1..6  ]")
print("(8) UDP          ","[ Cases 1..8  ]")

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
