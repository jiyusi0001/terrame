-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can TME_LEGEND_COLOR.REDistribute it and/or
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

-- util function
function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do
	for j = 1, 5, 1 do
		c = Cell{ cover = "pasture", agents_ = {}}
		c.y = j - 1;
		c.x = i - 1;
		cs:add( c );
	end
end

coverLeg = Legend {
type = "string",	--TME_LEGEND_TYPE.TEXT,
groupingMode = "uniquevalue",	--TME_LEGEND_GROUPING.UNIQUEVALUE,
slices = 2,
precision = 5,
stdDeviation = "none",	--TME_LEGEND_STDDEVIATION.NONE,
maximum = 1,
minimum = 0,
colorBar = {
{color = "green", value = "pasture"},
{color = "brown", value = "soil"}
}
}

state1 = State {
id = "walking",
Jump {
function( event, agent, cell )

	print(agent:getStateName());
	print(agent.energy)
	agent.energy= agent.energy - 1
	hungry = agent.energy == 0
	ag1.counter = ag1.counter + 10;
	--ag1:notify(ag1.time);

	if (hungry) then
		--agent.energy = agent.energy + 30
		return true
	end
	return false
end,
target = "sleeping"
}
}

state2 = State {
id = "sleeping",
Jump {
function( event, agent, cell )
	agent.energy = agent.energy + 1
	print(agent:getStateName());
	hungry = ag1.energy>0
	ag1.counter = ag1.counter + 10;
	--ag1:notify(ag1.time);

	if (not hungry)or( ag1.energy >=5) then
		return true
	end
	return false
end,
target = "walking"
}
}

ag1 = Agent{
id = "Ag1",
energy  = 5,
hungry = false,
counter = 0,
st1=state1,
st2=state2
}


ag1Leg = Legend{
type = "string",
groupingMode = "uniquevalue",
slices = 10,
precision = 5,
stdDeviation = "none",
maximum = 1,
minimum = 0,
colorBar = {
{color = "red", value = "walking"},
{color = "blue", value = "sleeping"}
}
}



ag1LegMinimumParameters = Legend{
maximum = 1,
minimum = 0,
colorBar = {
{color = "red", value = "walking"},
{color = "blue", value = "sleeping"}
},
}

energyLeg = Legend{
type = "number", -- NUMBER
groupingMode = "equalsteps",		-- ,		-- STDDEVIATION
slices = 10,
precision = 5,
stdDeviation = "none",		-- ,		-- FULL
maximum = 100,
minimum = 1,
colorBar = {
{color = "green", value = 0},
{color = "blue", value = 100}
}
}

env = Environment{ id = "MyEnvironment" }

env:add( cs )
env:add( ag1 )

ev = Event{ time = 1, period = 1, priority = 1 }

cs:notify()
cell = cs.cells[1]
ag1:enter(cell)

-- Enables kill an observer
killObserver = false


--vardump(energyLeg)

-- ================================================================================#
-- OBSERVER TEXTSCREEN
function test_TextScreen( case )
	if( not SKIP ) then

		switch( case ) : caseof {
		-- OBSERVER TEXTSCREEN 01
		[1] = function(x)
			print("OBSERVER TEXTSCREEN 01")
			--@DEPRECATED
			--ag1:createObserver( "textscreen" )
			observerTextScreen01=Observer{ subject=ag1, type = "textscreen" }
		end,
		-- OBSERVER TEXTSCREEN 02
		[2] = function(x)
			print("OBSERVER TEXTSCREEN 02")
			--@DEPRECATED				
			--ag1:createObserver( "textscreen", {} )
			observerTextScreen02=Observer{subject=ag1, type = "textscreen", atributes={}}
		end,
		-- OBSERVER TEXTSCREEN 03
		[3] = function(x)
			print("OBSERVER TEXTSCREEN 03")
			--@DEPRECATED				
			--ag1:createObserver( "textscreen", {}, {})
			observerTextScreen03=Observer{subject=ag1, type = "textscreen", attributes={}}
		end,
		[4] = function(x)
			-- OBSERVER TEXTSCREEN 04
			print("OBSERVER TEXTSCREEN 04")
			--@DEPRECATED
			--ag1:createObserver( "textscreen", {"energy", "hungry"} )
			observerTextScreen04=Observer{subject=ag1, type = "textscreen", attributes={"currentState", "energy", "hungry"}}
		end,
		[5] = function(x)
			-- OBSERVER TEXTSCREEN 05
			print("OBSERVER TEXTSCREEN 05")
			--@DEPRECATED
			--ag1:createObserver( "textscreen", {"energy", "hungry"} )
			observerTextScreen05=Observer{subject=ag1, type = "textscreen", attributes={"currentState", "energy", "hungry"}}
			killObserver = true
		end
		}

		for i=1, 10, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()
			ag1:notify(i)

			if ((killObserver and observerTextScreen05) and (i == 8)) then
				print("", "observerTextScreen05:kill", observerTextScreen05:kill())
			end
			delay_s(1)
		end

	end
end

-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03
Deve apresentar na tela uma tabela textual contendo todos os atributos do agente: "hungry", "id", "class", "cObj_", "weights_, "time", "relatives_", "cell", "energy", "currentState", "st1" e "st2". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.

TEXTSCREEN04
Deve apresentar na tela uma tabela textual contendo os atributos "currentState", "energy" e "hungry". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes três atributos.

TEXTSCREEN05
Este teste será idêntico ao teste 04. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.


-- ================================================================================#]]


-- OBSERVER LOGFILE
function test_LogFile( case )
	if( not SKIP ) then

		switch( case ) : caseof {
		[1] = function(x)
			-- OBSERVER LOGFILE 01
			print("OBSERVER LOGFILE 01")
			--@DEPRECATED
			--ag1:createObserver( "logfile" )
			observerLogFile01=Observer{subject=ag1, type = "logfile"}
		end,
		[2] = function(x)
			-- OBSERVER LOGFILE 02
			print("OBSERVER LOGFILE 02")
			--@DEPRECATED
			--ag1:createObserver( "logfile", {} )
			observerLogFile02=Observer{subject=ag1, type = "logfile", attributes ={}}
		end,
		[3] = function(x)
			-- OBSERVER LOGFILE 03
			print("OBSERVER LOGFILE 03")
			--@DEPRECATED
			--ag1:createObserver( "logfile", {}, {} )
			observerLogFile03=Observer{subject=ag1, type = "logfile", attributes ={}}
		end,
		[4] = function(x)
			-- OBSERVER LOGFILE 04
			print("OBSERVER LOGFILE 04")
			--@DEPRECATED
			--ag1:createObserver( "logfile", {},{"logfile.csv",","} )
			observerLogFile04=Observer{subject=ag1, type = "logfile", attributes ={},outfile = "logfile.csv", separator=","}
		end,
		[5] = function(x)
			-- OBSERVER LOGFILE 05
			print("OBSERVER LOGFILE 05")
			--@DEPRECATED
			--ag1:createObserver( "logfile", {"currentState", "energy", "hungry"}, {"logfile.csv"} )
			observerLogFile05=Observer{subject=ag1, type = "logfile", attributes ={"currentState", "energy", "hungry"}}
		end,
		[6] = function(x)
			-- OBSERVER LOGFILE 06
			print("OBSERVER LOGFILE 06")
			--@DEPRECATED
			--ag1:createObserver( "logfile", {"currentState", "energy", "hungry"}, {"logfile.csv"} )
			observerLogFile06=Observer{subject=ag1, type = "logfile", attributes ={"currentState", "energy", "hungry"}}
			killObserver = true
		end
		}

		for i=1, 10, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()
			ag1:notify(i)

			if ((killObserver and observerLogFile06) and (i == 8)) then
				print("", "observerLogFile06:kill", observerLogFile06:kill())
			end
		end

	end
end
-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03

Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser uma tabela textual contendo todos os atributos do agente "ag1" no cabeçalho: "hungry", "id", "class", "cObj_", "weights_, "time", "relatives_", "cell", "energy", "currentState", "st1" e "st2". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 04
Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE 01, 02 e 03) deverão ser apresentados.
Deverão ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.

LOGFILE 05
Deverá ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos "currentState", "energy" e "hungry". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes atributos.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

LOGFILE 06
Este teste será idêntico ao teste 05. Porém, no tempo de simulação 8, o observador "observerLogFile06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "result_.csv" conterá apenas informações até o 8o. tempo de simulação



-- ================================================================================#]]
-- OBSERVER TABLE

function test_Table( case )
	if( not SKIP ) then
		switch( case ) : caseof {
		[1] = function(x)
			-- OBSERVER TABLE 01
			print("OBSERVER TABLE 01")
			--@DEPRECATED
			--ag1:createObserver( "table" )
			observerTable01=Observer{subject=ag1, type = "table"}
		end,
		[2] = function(x)
			--OBSERVER TABLE 02 
			print("OBSERVER TABLE 02")
			--@DEPRECATED
			--ag1:createObserver( "table", {} )
			observerTable02=Observer{subject=ag1, type = "table",attributes={}}
		end,
		[3] = function(x)
			-- OBSERVER TABLE 03
			print("OBSERVER TABLE 03")
			--@DEPRECATED
			--ag1:createObserver( "table", {}, {} )
			observerTable03=Observer{subject=ag1, type = "table",attributes={}}
		end,
		[4] = function(x)
			-- OBSERVER TABLE 04
			print("OBSERVER TABLE 04")
			--@DEPRECATED
			--ag1:createObserver( "table", {},{"-- ATTRS --", "-- VALUES --"})
			observerTable04=Observer{subject=ag1, type = "table",attributes={},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		end,
		[5] = function(x)
			-- OBSERVER TABLE 05
			print("OBSERVER TABLE 05")
			--@DEPRECATED
			--ag1:createObserver( "table", {"currentState", "energy", "hungry"})
			observerTable05=Observer{subject=ag1, type = "table",attributes = {"currentState", "energy", "hungry"}}
		end,
		[6] = function(x)
			-- OBSERVER TABLE 06
			print("OBSERVER TABLE 06")
			--@DEPRECATED
			--ag1:createObserver( "table", {"currentState", "energy", "hungry"})
			observerTable06=Observer{subject=ag1, type = "table",attributes = {"currentState", "energy", "hungry"}}

			killObserver = true
		end
		}
		for i=1, 10, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()            
			ag1:notify(i)

			if ((killObserver and observerTable06) and (i == 8)) then
				print("", "observerTable06:kill", observerTable06:kill())
			end
			delay_s(1)
		end
	end
end
-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02 / TABLE 03
Deverá ser apresentada uma tabela contendo todos os atributos do agente "ag1" como linhas da tabela: "hungry", "id", "class", "cObj_", "weights_, "time", "relatives_", "cell", "energy", "currentState", "st1" e "st2". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 04
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "currentState", "energy" e "hungry". Os atributos devem ser apresentados na ordem em que é feita a especificação. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 06
Este teste será idêntico ao teste 05. Porém, no tempo de simulação 8, o observador "observerTable06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observador será fechada.


]]
-- ================================================================================#
-- OBSERVER DYNAMIC GRAPHIC E OBSERVER GRAPHIC
function test_chart( case )
	if( not SKIP ) then
		switch( case ) : caseof {
		-- OBSERVER DYNAMIC GRAPHIC 01
		[1] = function(x)
			print("OBSERVER DYNAMIC GRAPHIC 01")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
			observerDynamicGraphic01=Observer{subject=ag1, type="chart", attributes={"energy"} }             
		end,
		[2] = function(x)
			-- OBSERVER DYNAMIC GRAPHIC 02
			print("OBSERVER DYNAMIC GRAPHIC 02")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{"GraphicTitle","CurveTitle", "YLabel","XLabel"})
			observerDynamicGraphic02=Observer{subject=ag1, type = "chart", attributes={"energy"}, title="GraphicTitle", curveLabel="CurveTitle",  yLabel="YLabel", xLabel="XLabel"}	
		end,
		[3] = function(x)
			print("OBSERVER DYNAMIC GRAPHIC 03")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"},{})
			observerDynamicGraphic03=Observer{subject=ag1, type="chart", attributes={"currentState"} }             
		end,
		[4] = function(x)
			-- OBSERVER GRAPHIC 01
			print("OBSERVER GRAPHIC 01")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"energy","counter"})
			observerGraphic01=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter"}
		end,
		[5] = function(x)
			-- OBSERVER GRAPHIC 02
			print("OBSERVER GRAPHIC 02")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"},{})
			observerGraphic01=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title=nil}
		end,
		[6] = function(x)
			-- OBSERVER GRAPHIC 03
			print("OBSERVER GRAPHIC 03")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"}, {"GraphicTitle"})
			observerGraphic03=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle"}
		end,
		[7] = function(x)
			-- OBSERVER GRAPHIC 04
			print("OBSERVER GRAPHIC 04")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"}, {"GraphicTitle","CurveTitle"})	 	
			observerGraphic04=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle", curveLabel="CurveTitle"}
		end,
		[8] = function(x)
			-- OBSERVER GRAPHIC 05
			print("OBSERVER GRAPHIC 05")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.GRAPHIC, {"currentState", "energy"}, {"GraphicTitle","CurveTitle","YLabel"})	 
			observerGraphic04=Observer{subject=ag1, type = "chart", attributes={"currentState"}, xAxis="counter", title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel"}
		end,
		[9] = function(x)
			-- OBSERVER GRAPHIC 06
			print("OBSERVER GRAPHIC 06")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
			observerGraphic09=Observer{subject=ag1, type = "chart",attributes={"currentState"}, xAxis="counter",title="GraphicTitle",curveLabel="CurveTitle", yLabel="YLabel",xLabel="XLabel"}
		end,
		[10] = function(x)
			-- OBSERVER GRAPHIC 07
			print("OBSERVER GRAPHIC 07")
			--@DEPRECATED
			--ag1:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"energy"}, {"Dynamic energy", "energy", "energy x time", "time"})
			observerGraphic10=Observer{subject=ag1, type = "chart",attributes={"currentState"}, xAxis="counter",title="GraphicTitle",curveLabel="CurveTitle", yLabel="YLabel",xLabel="XLabel"}

			killObserver = true
		end
		}
		for i=1, 10, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify(i)
			ag1:notify(i)

			if ((killObserver and observerGraphic10) and (i == 8)) then
				print("", "observerGraphic10:kill", observerGraphic10:kill())
			end

			delay_s(1)
		end
	end
end

-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "energy" do agente "ag1", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

DYNAMIC GRAPHIC 02
Resultados idênticos aos dos observers DYNAMIC GRAPHIC01, exceto pelo uso do título do gráfico, título da curva, rótulo para o eixo Y e rótulo para o eixo X: "GraphicTitle" , "CurveTitle", "YLabel" e "XLabel".

DYNAMIC GRAPHIC 03
Deverá apresentar um gráfico de dispersão XY, onde os eixos X e Y receberão os valores do tempo corrente do relógio de simulação e do atributo "currentState" do agente "ag1", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo X ("time"), título do eixo y ("$yLabel").
O formato da curva neste teste é o de uma onda quadrada. 
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 01 / GRAPHIC 02
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "currentState" e "counter", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
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

]]

-- ================================================================================#

-- OBSERVER IMAGE
function test_Image( case )
	if( not SKIP ) then
		--obs = cs:createObserver("image", {"cover"},{coverLeg})
		obs = Observer{subject = cs, type = "image", attributes={"cover"}, legends={coverLeg}}
		switch( case ) : caseof {
		[1] = function(x)
			-- OBSERVER IMAGE 01 
			print("OBSERVER IMAGE 01")
			--@DEPRECATED
			--ag1:createObserver( "image" )
			observerImage01=Observer{subject=ag1, type = "image" }
		end,
		[2] = function(x)
			-- OBSERVER IMAGE 02
			print("OBSERVER IMAGE 02")
			--@DEPRECATED
			--ag1:createObserver("image", {"currentState"}, {cs})
			observerImage02=Observer{subject=ag1, type = "image", attributes={"currentState"}, cellspace = cs}
		end,
		[3] = function(x)
			-- OBSERVER IMAGE 03
			print("OBSERVER IMAGE 03")
			--@DEPRECATED
			--ag1:createObserver("image", {"currentState"}, {obs})
			observerImage03=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		end,
		[4] = function(x)
			-- OBSERVER IMAGE 04
			print("OBSERVER IMAGE 04")
			--@DEPRECATED
			--ag1:createObserver("image", {"currentState"}, {cs,obs})
			--observerImage04=Observer{subject=ag1, type = "image", attributes={"currentState"}, cellspace = cs, observer = obs}
			observerImage04=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs}
		end,
		[5] = function(x)
			-- OBSERVER IMAGE 05
			print("OBSERVER IMAGE 05")
			--@DEPRECATED
			--ag1:createObserver("image", {"currentState"}, {cs,obs,ag1Leg})
			observerImage05=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs, legends = {ag1Leg} }
		end,
		[6] = function(x)
			-- OBSERVER IMAGE 06
			print("OBSERVER IMAGE 06")
			--@DEPRECATED
			--ag1:createObserver("image", {"currentState"}, {cs,obs,ag1Leg})
			observerImage06=Observer{subject=ag1, type = "image", attributes={"currentState"}, observer = obs, legends = {ag1Leg} }

			killObserver = true
		end
		}
		for i=1, 25, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()
			ag1:notify(i)

			if ((killObserver and observerImage06) and (i == 18)) then
				print("", "observerImage06:kill", observerImage06:kill())
			end

			delay_s(2)
		end
	end
end

-- TESTES OBSERVER IMAGE
--[[
IMAGE 01
O programa deverá ser abortado. Não é possível utilizar IMAGE observers sem a identificação de pelo menos um atributo.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 02
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de agentes sem a identificação observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 03
O programa deverá ser abortado. Não é possível utilizar IMAGE observers de agentes sem a identificação de um espaço celular.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

IMAGE 04
Deverá gerar 25 imagens com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda padrão.
Como a legenda padrão (que é carregada neste teste) não conhece os valores do atributo "currentState", o agente não irá receber as cores definidas na legenda e sim a cor padrão "BLACK".
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão. 

IMAGE 05
Deverá gerar 25 imagens com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda "ag1Leg".
Deverá ser emitida mensagem de "Warning" informando o uso do diretório corrente para saída e o uso de prefixo padrão. 

IMAGE 06
Este teste será idêntico ao teste IMAGE 05. Porém, no tempo de simulação 18, o observador "observerImage06" será destruído. As imagens geradas até o 18o. tempo de simulação conterão o agente. As imagens geradas a partir do 19o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.

-- ================================================================================#]]
-- OBSERVER MAP
function test_Map( case )
	if( not SKIP ) then
		obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }

		switch( case ) : caseof {
		[1] = function(x)
			-- OBSERVER MAP 01 
			print("OBSERVER MAP 01")
			--@DEPRECATED
			--ag1:createObserver( "map" )
			observerMap01=Observer{subject=ag1, type = "map" }
		end,
		[2] = function(x)
			-- OBSERVER MAP 02
			print("OBSERVER MAP 02")
			--@DEPRECATED
			--ag1:createObserver("map", {"currentState"}, {cs})
			observerMap02=Observer{subject=ag1, type = "map", attributes={"currentState"}}
		end,
		[3] = function(x)
			-- OBSERVER MAP 03
			print("OBSERVER MAP 03")
			--@DEPRECATED
			--ag1:createObserver("map", {"currentState"}, {obs})
			observerMap03=Observer{subject=ag1, type = "map", attributes={"currentState"},observer = obsMap}
		end,
		[4] = function(x)
			-- OBSERVER MAP 04
			print("OBSERVER MAP 04")
			--@DEPRECATED
			--ag1:createObserver("map", {"currentState"}, {cs,obs})
			observerMap04=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap}
		end,
		[5] = function(x)
			-- OBSERVER MAP 05
			print("OBSERVER MAP 05")
			--@DEPRECATED
			--ag1:createObserver("map", {"currentState","energy"}, {cs,obs})                
			observerMap05=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap, legends = {ag1Leg} }

		end,
		[6] = function(x)
			-- OBSERVER MAP 06
			print("OBSERVER MAP 06")
			--@DEPRECATED
			--ag1:createObserver("map", {"currentState","energy"}, {cs,obs,ag1Leg,energyLeg})
			observerMap06=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap, legends = {ag1Leg}}
		end,
		[7] = function(x)
			-- OBSERVER MAP 07
			print("OBSERVER MAP 07")
			--@DEPRECATED
			--ag1:createObserver("map", {"currentState","energy"}, {cs,obs,ag1Leg,energyLeg})
			observerMap07=Observer{subject=ag1, type = "map", attributes={"currentState"}, observer = obsMap, legends = {ag1Leg}}                
			killObserver = true
		end
		}

		for i=1, 25, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()
			ag1:notify(i)

			if ((killObserver and observerMap07) and (i == 18)) then
				print("", "observerMap07:kill", observerMap07:kill())
			end

			delay_s(2)
		end
	end
end

-- TESTES OBSERVER MAP
--[[
MAP 01
O programa deverá ser abortado. Não é possível utilizar MAP observers sem a identificação de pelo menos um atributo.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 02
O programa deverá ser abortado. Não é possível utilizar MAP observers de agentes sem a identificação observer para acoplamento.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 03
O programa deverá ser abortado. Não é possível utilizar MAP observers de agentes sem a identificação de um espaço celular.
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

MAP 04
Deverá exibir uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço, iniciando na "célula (1,1)" até a "célula (5,5)". 
Como a legenda padrão (que é carregada neste teste) não conhece os valores do atributo "currentState", o agente não irá receber as cores definidas na legenda e sim a cor padrão "BLACK".

MAP 05
Deverá exibir uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço, iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda "ag1LegMinimumParameters".

MAP 06
Deverá exibir uma imagem com plano de fundo preenchido (em verde) de acordo com a legenda "coverLeg". Deverá também exibir no plano superior um caractere representando o agente. Durante o teste o agente deve percorrer verticalmente todo o espaço, iniciando na "célula (1,1)" até a "célula (5,5)". O agente deverá possuir cores de acordo com o atributo "currentState" e a legenda "ag1Leg".

MAP 07
Este teste será idêntico ao teste MAP 06. Porém, no tempo de simulação 18, o observador "observerMap07" será destruído. As imagens exibidas até o 18o. tempo de simulação conterão o agente. As imagens exibidas a partir do 19o tempo de simulação conterão apenas o plano de fundo. O método "kill" irá retornar um valor booleano confirmando o sucesso da chamada e o agente não estrará presente na imagem.

-- ================================================================================#]]

-- OBSERVER STATEMACHINE
function test_StateMachine( case )
	if( not SKIP ) then
		cell = cs.cells[1]
		ag1:enter(cell)

		switch( case ) : caseof {
		[1] = function(x)
			-- OBSERVER STATEMACHINE 01
			print("OBSERVER STATEMACHINE 01")
			--@DEPRECATED
			--ag1:createObserver( "statemachine" )
			observerStateMachine01=Observer{subject=ag1, type = "statemachine"}
		end,
		[2] = function(x)
			-- OBSERVER STATEMACHINE 02
			print("OBSERVER STATEMACHINE 02")
			--@DEPRECATED
			--ag1:createObserver( "statemachine",{} )
			observerStateMachine02=Observer{subject=ag1, type = "statemachine", atributes={}}
		end,
		[3] = function(x)
			-- OBSERVER STATEMACHINE 03
			print("OBSERVER STATEMACHINE 03")
			--@DEPRECATED
			--ag1:createObserver( "statemachine", {},{})
			observerStateMachine03=Observer{subject=ag1, type = "statemachine", attributes={"energy"},legends={}}
		end,
		[4] = function(x)
			-- OBSERVER STATEMACHINE 04
			print("OBSERVER STATEMACHINE 04")
			--@DEPRECATED
			--ag1:createObserver( "statemachine" , {"currentState"} )
			observerStateMachine04=Observer{subject=ag1, type = "statemachine", attributes={"currentState"}}
		end,
		[5] = function(x)
			-- OBSERVER STATEMACHINE 05
			print("OBSERVER STATEMACHINE 05")
			--@DEPRECATED
			--ag1:createObserver( "statemachine" , {"currentState"},{ag1Leg} )
			observerStateMachine05=Observer{subject=ag1, type = "statemachine",legends={ag1Leg}}
		end,
		[6] = function(x)
			-- OBSERVER STATEMACHINE 06
			print("OBSERVER STATEMACHINE 06")
			--@DEPRECATED
			--ag1:createObserver( "statemachine" , {"currentState"},{ag1Leg} )
			observerStateMachine06=Observer{subject=ag1, type = "statemachine",legends={ag1Leg}}
			killObserver = true
		end
		}
		for i=1, 25, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()
			ag1:notify(i)

			if ((killObserver and observerStateMachine06) and (i == 18)) then
				print("", "observerStateMachine06:kill", observerStateMachine06:kill())
			end

			delay_s(1)
		end
	end
end

-- TESTES STATEMACHINE
--[[
STATEMACHINE 01
O programa deverá apresentar uma janela com a mensagem informando que o atributo selecionado não é um valor númerico.
Deve apresentar uma máquina de estados contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro deve ser cinza (legenda padrão).
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "legends".

STATEMACHINE 02 / STATEMACHINE 03
O programa deverá apresentar uma janela com a mensagem informando que o atributo selecionado não é um valor númerico.
Deve apresentar uma máquina de estados contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro deve ser cinza (legenda padrão).
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "subtitle".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

STATEMACHINE 04
O programa deverá apresentar uma janela com mensagem informando que o atributo selecionado não é um valor numérico.
Deve apresentar uma máquina de estados para o atributo "currentState" do agent "ag1" contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro estado deve ser cinza.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "subtitle".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

STATEMACHINE 05
Deve apresentar uma máquina de estados para o atributo "currentState" do agente "ag1" contendo dois estados, preenchidos de acordo com a legenda "currentStateLeg" ("walking" em verde e "sleeping" em marrom). A cada iteração o estado atual deve estar destacado com bordas em negrito.

-- ================================================================================#]]

-- OBSERVER UDP
function test_udp( case )
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		switch( case ) : caseof {
		[1] = function(x)
			--OBSERVER UDPSENDER 01
			print("OBSERVER UDPSENDER 01")
			--@DEPRECATED
			--ag1:createObserver("udpsender")
			observerUDP01 = Observer{ subject = ag1, type = "udpsender" }
		end,
		[2] = function(x)
			--OBSERVER UDPSENDER 02
			print("OBSERVER UDPSENDER 02")
			--@DEPRECATED
			--ag1:createObserver("udpsender", {})
			observerUDP02 = Observer{ subject = ag1, type = "udpsender", attributes={} }
		end,
		[3] = function(x)
			--OBSERVER UDPSENDER 03
			print("OBSERVER UDPSENDER 03")
			--@DEPRECATED
			--ag1:createObserver("udpsender", {}, {})	--??
			observerUDP03 = Observer{ subject = ag1, type = "udpsender",hosts ={}, attributtes={} }
		end,
		[4] = function(x)
			--OBSERVER UDPSENDER 04
			print("OBSERVER UDPSENDER 04")
			--@DEPRECATED
			--ag1:createObserver("udpsender",{"currentState"})
			observerUDP04 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState"} }
		end,
		[5] = function(x)
			--OBSERVER UDPSENDER 05
			print("OBSERVER UDPSENDER 05")
			--@DEPRECATED
			--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544"})
			observerUDP05 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"}, port="54544" }
		end,
		[6] = function(x)
			--OBSERVER UDPSENDER 06
			print("OBSERVER UDPSENDER 06")
			--@DEPRECATED
			--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544", IP1})
			observerUDP06 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"}, port="54544", hosts = {IP1} }
		end,
		[7] = function(x)
			--OBSERVER UDPSENDER 07
			print("OBSERVER UDPSENDER 07")
			--@DEPRECATED
			--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544", IP1, IP2})
			observerUDP07 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"},
			port="54544", hosts = {IP1,IP2} }
		end,
		[8] = function(x)
			--OBSERVER UDPSENDER 08
			print("OBSERVER UDPSENDER 08")
			--@DEPRECATED
			--ag1:createObserver("udpsender",{"currentState", "energy"},{"54544", IP1, IP2})
			observerUDP08 = Observer{ subject = ag1, type = "udpsender", attributes={"currentState", "energy"},
			port="54544", hosts = {IP1,IP2} }

			killObserver = true
		end
		}
		for i=1, 25, 1 do
			print("step ",i)
			ag1:execute(ev)
			ag1:move(cs.cells[i])
			cs:notify()
			ag1:notify(i)

			if ((killObserver and observerUDP08) and (i == 18)) then
				print("", "observerUDP08:kill", observerUDP08:kill())
			end

			delay_s(2)
		end
	end
end

--[[
UDPSENDER 01 / UDPSENDER 02 / UDPSENDER 03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 25 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 04
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e seu atributo "currenState".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto padrão "45454".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 05
A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações do agente "ag1" e seus atributos "currenState" e "energy".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma TME_LEGEND_COLOR.REDe) direcionadas ao porto "666".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 06
A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações do agente "ag1" e seus atributos "currentState" e "energy".
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

UDPSENDER 07
A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações do agente "ag1" e seus atributos "currentState" e "energy".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes.

-- ================================================================================#]]

-- SKIP = false
-- test_TextScreen(TEST)  -- cases of [1..5]
-- test_LogFile(TEST)  -- cases of [1..6]
-- test_Table(TEST) -- cases of [1..6]
-- test_chart(TEST) -- cases of [1..10]
-- test_Image(TEST) -- cases of [1..6]
-- test_Map(TEST) -- cases of [1..7]
-- test_StateMachine(TEST) -- cases of [1..6]
-- test_udp(TEST) -- cases of [1..7]

-- Os testes do método "kill" usando o Map e Image devem ser feitos separadamente

testsSourceCodes = {
["TextScreen"] = test_TextScreen, 
["LogFile"] = test_LogFile,
["Table"] = test_Table,
["Chart"] = test_chart,
["Image"] = test_Image,
["Map"] = test_Map,
["StateMachine"] = test_StateMachine,
["UDP"] = test_udp
}

file = io.open("input.txt","r")
obsType = file:read()
testNumber = tonumber(file:read())
file:close()

testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
