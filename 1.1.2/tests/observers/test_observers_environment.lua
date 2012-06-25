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

-- util function
function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do 
	for j = 1, 5, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
	end
end

state1 = State {
id = "walking",
Jump {
function( event, agent, cell )

	print(agent:getStateName());
	print(agent.energy)
	agent.energy= agent.energy - 1
	hungry = agent.energy == 0
	ag1.time = ag1.time + 1;
	ag1:notify(ag1.time);

	if (hungry) then
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
	ag1.time = ag1.time + 1;
	ag1:notify(ag1.time);

	if (not hungry)or( ag1.energy==5) then
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
time = 0,
state1,
state2
}


at1 = Automaton{
id = "At1",
it = Trajectory{
	target = cs
}
}

-- ev = Event{
-- time = 0,
-- action = function(event)
-- at1:execute(event) 
-- print("step", event:getTime()) io.flush()
-- return true 
-- end 
-- }

t = Timer{
Event{ time = 0, period = 1, action = function(event) 
	print("step:", event:getTime())  io.flush()

	at1:execute(event) 
	env:notify(event:getTime())

	env.counter = event:getTime() + 1
	env.temperature = event:getTime() * 2

	-- delay_s(1)

	if ((killObserver and observerKill) and (event:getTime() == 8)) then
		print("", "env:kill", env:kill(observerKill))
	end
	return true 
end 
}
}

-- --[[
-- t = Timer{
-- Pair {
-- Event{ time = 0, period = 1, priority=1},
-- Action {function(event) at1:execute(event) return true end }
-- }
-- }
-- ]]

env = Environment{ 
id = "MyEnvironment",
	c1 = cs,
-- verificar. funciona no linux. não funciona no windows.
-- erro: index out of bounds
--at1 = at1,
--ag1 = ag1,
	t = t,
counter = 0,
temperature = 0
}
--env:add(cs)
env:add(t)

-- Enables kill an observer
killObserver = false
observerKill = nil

-- ================================================================================#
-- OBSERVER TEXTSCREEN
function test_TextScreen( case) 
	if( not SKIP ) then	
		switch( case ) : caseof {

		[1] = function(x) 
			-- OBSERVER TEXTSCREEN 01 
			print("OBSERVER TEXTSCREEN 01") io.flush()
			--@DEPRECATED
			--env:createObserver("textscreen")
			observerTextScreen01 = Observer{ subject=env, type="textscreen" }
		end,

		[2] = function(x) 
			-- OBSERVER TEXTSCREEN 02
			print("OBSERVER TEXTSCREEN 02") io.flush()
			--@DEPRECATED
			--env:createObserver( "textscreen", {} )
			observerTextScreen02 = Observer{ subject=env, type="textscreen", attributes={} }
		end,

		[3] = function(x) 
			-- OBSERVER TEXTSCREEN 03
			print("OBSERVER TEXTSCREEN 03") io.flush() 
			--@DEPRECATED
			--env:createObserver( "textscreen", {}, {} )
			observerTextScreen03 = Observer{ subject=env, type="textscreen", attributes={} }
		end,

		[4] = function(x) 
			-- OBSERVER TEXTSCREEN 04
			print("OBSERVER TEXTSCREEN 04") io.flush()
			--@DEPRECATED
			--env:createObserver( "textscreen", {"c1"} )
			observerTextScreen04 = Observer{ subject=env, type="textscreen", attributes={"c1"} }
		end,

		[5] = function(x) 
			-- OBSERVER TEXTSCREEN 05
			print("OBSERVER TEXTSCREEN 05") io.flush()
			--@DEPRECATED
			--env:createObserver( "textscreen", {"c1"} )
			observerTextScreen05 = Observer{ subject=env, type="textscreen", attributes={"c1"} }

			killObserver = true
		end
		}
		if ((killObserver and observerTextScreen05) and (i == 8)) then
			print("", "observerTextScreen05:kill", observerTextScreen05:kill())
		end
		env:execute(10)
	end
end

-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03 

Deve apresentar na tela uma tabela textual contendo todos os atributos do ambiente "env" no cabeçalho: "at1", "cObj_", "cont", "id", "t", "ag1" e "c1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 04

Deve apresentar na tela uma tabela textual contendo o atributo "c1" do ambiente "env" no cabeçalho.
Deverão ser apresentadas também 10 linhas com o valor relativo ao atributo. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.

TEXTSCREEN 05
Este teste será idêntico ao teste TEXTSCREEN 04. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER LOGFILE
function test_LogFile( case) 
	if( not SKIP ) then
		switch( case ) : caseof {

		[1] = function(x) 
			-- OBSERVER LOGFILE 01
			print("OBSERVER LOGFILE 01") io.flush()
			--@DEPRECATED
			--env:createObserver("logfile")
			observerLogFile01 = Observer{subject=env, type="logfile"}
		end,

		[2] = function(x) 
			-- OBSERVER LOGFILE 02 
			print("OBSERVER LOGFILE 02") io.flush()
			--@DEPRECATED
			--env:createObserver( "logfile", {} )
			observerLogFile02 = Observer{subject=env, type="logfile", attributes={}}
		end,

		[3] = function(x) 
			-- OBSERVER LOGFILE 03
			print("OBSERVER LOGFILE 03") io.flush() 
			--@DEPRECATED
			--env:createObserver( "logfile", {}, {} )--nao roda
			observerLogFile03 = Observer{subject=env, type="logfile", attributes={}}
		end,

		[4] = function(x) 

			-- OBSERVER LOGFILE 04
			print("OBSERVER LOGFILE 04") io.flush()
			--@DEPRECATED
			--env:createObserver( "logfile", {"c1"} )
			observerLogFile04 = Observer{subject=env, type="logfile", attributes={"c1"}}
		end,

		[5] = function(x) 
			-- 0BSERVER LOGFILE 05
			print("OBSERVER LOGFILE 05") io.flush()
			--@DEPRECATED
			--env:createObserver( "logfile", {"t"},{"logfile.csv","."} )
			observerLogFile05 = Observer{subject=env, type="logfile", attributes={"t"}, outfile="logfile.csv", path="."}
		end,

		[6] = function(x) 
			-- 0BSERVER LOGFILE 06
			print("OBSERVER LOGFILE 06") io.flush()
			--@DEPRECATED
			--env:createObserver( "logfile", {"t"},{"logfile.csv","."} )
			observerLogFile06 = Observer{subject=env, type="logfile", attributes={"t"}, outfile="logfile.csv", path="."}

			killObserver = true
		end
		}

		if ((killObserver and observerLogFile06) and (i == 8)) then
			print("", "observerLogFile06:kill", observerLogFile06:kill())
		end
		env:execute(10)
	end
end

-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03 

Deverá ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos do ambiente "env" no cabeçalho: "at1", "cObj_", "cont", "id", "t", "ag1" e "c1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o diretório de saída, nome de arquivo ("result_.csv") e caractere de separação (";").

LOGFILE 04

Deverá ser gerado o arquivo "result_.csv" contendo uma tabela textual com o atributo "c1" do ambiente "env". Deverão ser apresentadas também 10 linhas com o valor relativo ao atributo. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o diretório de saída, nome de arquivo ("result_.csv") e caractere de separação (";"). 

LOGFILE 05

Deverá ser gerado o arquivo "logfile.csv" na localização "." (diretório corrente), contendo uma tabela textual com o atributo "t" do ambiente "env". Deverão ser apresentadas também 10 linhas com o valor relativo ao atributo. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverá ser mostrada mensagem de "Warning" informando o uso de valores padrão para o caractere de separação (";"). 

LOGFILE 06
Este teste será idêntico ao teste LOGFILE 05. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "logfile.csv" conterá apenas informações até o 8o. tempo de simulação


]]

-- ================================================================================#
-- OBSERVER TABLE
function test_Table( case) 
	if( not SKIP ) then
		switch( case ) : caseof {
		[1] = function(x) 
			-- OBSERVER TABLE 01 
			print("OBSERVER TABLE 01") io.flush()
			--@DEPRECATED
			--env:createObserver("table")
			observerTable01 = Observer{ subject=env, type="table" }
		end,

		[2] = function(x) 
			-- OBSERVER TABLE 02 
			print("OBSERVER TABLE 02") io.flush()
			--@DEPRECATED
			--env:createObserver( "table", {} )
			observerTable02 = Observer{ subject=env, type="table" }
		end,

		[3] = function(x) 
			-- OBSERVER TABLE 03
			print("OBSERVER TABLE 03") io.flush() 
			--@DEPRECATED
			--env:createObserver( "table", {}, {} )
			observerTable03 = Observer{subject=env, type="table", attributes={}}
		end,

		[4] = function(x) 
			-- OBSERVER TABLE 04
			print("OBSERVER TABLE 04") io.flush()
			--@DEPRECATED
			--env:createObserver( "table", {"c1"} )
			observerTable04 = Observer{subject=env, type="table",attributes={}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		end,

		[5] = function(x) 
			-- 0BSERVER TABLE 05
			print("OBSERVER TABLE 05") io.flush()
			--@DEPRECATED
			--env:createObserver( "table", {"t"},{"Atributos","Valores"} )
			-- criação de atributo dinâmico antes da especificação de observers
			env.counter = 0
			observerTable05 = Observer{subject=env, type="table", attributes={"t","c1","counter"}}
		end,

		[6] = function(x) 
			-- 0BSERVER TABLE 06
			print("OBSERVER TABLE 06") io.flush()
			--@DEPRECATED
			--env:createObserver( "table", {"t"},{"Atributos","Valores"} )
			-- criação de atributo dinâmico antes da especificação de observers
			env.counter = 0
			observerTable06 = Observer{subject=env, type="table", attributes={"t","c1","counter"}}
			killObserver = true

		end
		}
		if ((killObserver and observerLogFile06) and (i == 8)) then
			print("", "observerTable06:kill", observerTable06:kill())
		end
		env:execute(10)
	end
end

-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02 / TABLE 03 
Deve apresentar uma tabela contendo todos os atributos (e respectivos valores) do ambiente "env": "at1", "cObj_", "cont", "id", "t", "ag1", "c1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 04 
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "t", "c1_" e "counter". Os atributos devem ser apresentados na ordem em que é feita a especificação. O valor do atributo "counter" deverá variar de 1 a 10 durante o teste. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 06
Este teste será idêntico ao teste TABLE 05. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER DYNAMIC GRAPHIC E OBSERVER GRAPHIC
function test_Chart( case )
	if( not SKIP ) then
		switch( case ) : caseof {
		[1] = function(x) 
			-- OBSERVER DYNAMIC GRAPHIC 01
			print("OBSERVER DYNAMIC GRAPHIC 01") io.flush()
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"c1"})
			observerDynamicGraphic01=Observer{subject=env, type="chart"}
		end,

		[2] = function(x) 
			-- OBSERVER DYNAMIC GRAPHIC 02
			print("OBSERVER DYNAMIC GRAPHIC 02") io.flush()
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"counter"})
			observerDynamicGraphic02=Observer{subject=env, type="chart", attributes={"counter"}}
		end,

		[3] = function(x) 
			-- OBSERVER GRAPHIC 01
			print("OBSERVER GRAPHIC 01") io.flush()
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.GRAPHIC, {"temperature", "counter"}---)
			observerGraphic01 = Observer{subject=env, type="chart", attributes={"temperature"}, xAxis="counter"}
		end,

		[4] = function(x) 
			print("OBSERVER GRAPHIC 02") io.flush()
			-- OBSERVER GRAPHIC 02
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.GRAPHIC, {"temperature", "counter"}, {})	 					  
			observerGraphic02 = Observer{subject=env, type="chart", attributes={"temperature"},xAxis="counter", title="GraphicTitle"}
		end,

		[5] = function(x) 
			print("OBSERVER GRAPHIC 03") io.flush()
			-- OBSERVER GRAPHIC 03
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.GRAPHIC, {"temperature", "counter"}, {"GraphicTitle","CurveTitle"})
			observerGraphic03 = Observer{subject=env, type="chart", attributes={"temperature"}, xAxis="counter", title="GraphicTitle", curveLabel="CurveTitle"}
		end,

		[6] = function(x) 
			-- OBSERVER GRAPHIC 04
			print("OBSERVER GRAPHIC 04") io.flush()
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.GRAPHIC, {"temperature", "counter"}, {"GraphicTitle","CurveTitle","XLabel"})
			observerGraphic04 = Observer{subject=env, type="chart", attributes={"temperature"},xAxis="counter",title="GraphicTitle",curveLabel="CurveTitle",xLabel="XLabel"}
		end,

		[7] = function(x) 
			-- OBSERVER GRAPHIC 05
			print("OBSERVER GRAPHIC 05") io.flush()
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"temperature","counter"}, {"Dynamic cell x tempo", "cell-tempo", "c1", "t"})
			observerGraphic05 = Observer{subject=env, type="chart", attributes={"temperature"},xAxis="counter",title="Dynamic cell",curveLabel="temperature x counter",xLabel="t"}
		end,

		[8] = function(x) 
			-- OBSERVER GRAPHIC 06
			print("OBSERVER GRAPHIC 06") io.flush()
			--@DEPRECATED
			--env:createObserver(TME_OBSERVERS.DYNAMICGRAPHIC, {"temperature","counter"}, {"Dynamic cell x tempo", "cell-tempo", "c1", "t"})
			observerGraphic06 = Observer{subject=env, type="chart", attributes={"temperature"},xAxis="counter",title="Dynamic cell",curveLabel="temperature x counter",xLabel="t"}

			killObserver = true
		end
		}
		if ((killObserver and observerGraphic06) and (i == 8)) then
			print("", "observerGraphic06:kill", observerGraphic06:kill())
		end

		env:execute(10)
	end
end

-- TESTES OBSERVER GRAPHIC
--[[
DYNAMIC GRAPHIC 01
O programa deverá ser abortado. Não é possível utilizar observers GRAPHIC sem a especificação de ao menos um atributo.
Deverá ser emitida uma mensagem de "Warning" informando a forma correta de se utilizar este tipo de observer.

DYNAMIC GRAPHIC 02
Deverá apresentar uma reta vertical com início na coordenada (0,0) e com fim na coordenada (0,9), resultante da plotagem do atributo "counter" (eixo Y) em relação ao tempo do relógio de simulação (constante em 0).
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 01
Deverá ser apresentado um gráfico de dispersão XY, onde os eixos X e Y receberão os valores dos atributos "counter" e "temperature", respectivamente. Serão usados valores padrão para os parâmetros do gráfico: título do gráfico ("$graphTitle"), título da curva ("$curveLabel"), título do eixo Y ("$yLabel"), título do eixo X ("$xLabel").
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do gráfico", "título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 02
Resultados idênticos aos dos observers GRAPHIC 01, exceto pelo uso do título do gráfico "GraphicTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título da curva", "título do eixo Y" e "título do eixo X").

GRAPHIC 03
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico e título da curva: "GraphicTitle" e "CurveTitle".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para os parâmetros ("título do eixo Y" e "título do eixo X").

GRAPHIC 04
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso do título do gráfico, título da curva e rótulo para o eixo Y: "GraphicTitle" , "CurveTitle" e "XLabel".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetros "título do eixo X".

GRAPHIC 05
Resultados idênticos aos dos observers GRAPHIC01 e GRAPHIC02, exceto pelo uso de valores específicos na lista de parâmetros.

]]

-- ================================================================================#
-- OBSERVER UDP
function test_UDP( case )
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		switch( case ) : caseof {	
		[1] = function(x) 
			--OBSERVER UDPSENDER 01
			print("OBSERVER UDPSENDER 01") io.flush()
			--@DEPRECATED
			--env:createObserver("udpsender")
			observerUDP01=Observer{subject=env, type="udpsender"}
		end,

		[2] = function(x) 
			--OBSERVER UDPSENDER 02
			print("OBSERVER UDPSENDER 02") io.flush()
			--@DEPRECATED
			--env:createObserver("udpsender", {})
			observerUDP02=Observer{subject=env, type="udpsender",attributes={}}
		end,

		[3] = function(x) 
			--OBSERVER UDPSENDER 03
			print("OBSERVER UDPSENDER 03") io.flush()
			--@DEPRECATED
			--env:createObserver("udpsender", {}, {})
			observerUDP03=Observer{subject=env, type="udpsender", attributes={}}
		end,

		[4] = function(x) 
			--OBSERVER UDPSENDER 04
			print("OBSERVER UDPSENDER 04") io.flush()
			--@DEPRECATED
			--env:createObserver("udpsender",{"t"},{"54544"})
			observerUDP04=Observer{subject=env, type="udpsender",attributes={"t"},port="54544"}
		end,

		[5] = function(x) 
			--OBSERVER UDPSENDER 05
			print("OBSERVER UDPSENDER 05") io.flush()
			--@DEPRECATED
			--env:createObserver("udpsender",{"t"},{"54544", IP1})
			observerUDP05=Observer{subject=env, type="udpsender",attributes={"t"},port="54544",host={IP1}}
		end,

		[6] = function(x) 
			--OBSERVER UDPSENDER 06
			print("OBSERVER UDPSENDER 06") io.flush()
			--@DEPRECATED
			--env:createObserver("udpsender",{"t"},{"54544", IP1, IP2})
			observerUDP06=Observer{subject=env, type="udpsender",attributes={"t"},port="54544",host={IP1,IP2}}
			killObserver = true
		end
		}
		if ((killObserver and observerUDP06) and (i == 8)) then
			print("", "observerUDP06:kill", observerUDP06:kill())
		end
		env:execute(10)
	end
end
-- TESTES OBSERVER UDPSENDER
--[[
UDPSENDER01 / UDPSENDER02 / UDPSENDER03

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e todos seus atributos.
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell21110soilWater10cObj_3Lua-Address(UD):0x861fe4cLin10y10x10object_id03C00L00Col10height_10past3Lua-Address(TB):0x8622478agents_3Lua-Address(TB):0x8606658objectId_3C00L00	

UDPSENDER04

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Deverá ser emitida mensagem informando o uso de valores padrão para os parâmetros "port" e "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto padrão "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER05

A realização deste teste depende da execução do cliente UDP em diferentes computadores. Cada um deles deve receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater", "height_" e "counter".
Deverá ser emitida mensagem informando o uso de valor padrão para o parâmetro "address".
Serão disparadas 10 mensagens "broadcast" (para todas maquinas na mesma rede) direcionadas ao porto "456456".
Cada uma das máquinas cliente deve receber 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER06

A realização deste teste depende da execução do cliente UDP na mesma máquina onde ocorre a simulação. O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater", "height_" e counter
Serão disparadas 10 mensagens "unicast" direcionadas ao porto "666" do servidor local.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10

UDPSENDER07

A realização deste teste depende da execução do cliente UDP na máquinas com ips "IP1" e "IP2". O cliente deverá receber a cada notificação as informações da célula "cell01" e seus atributos "soilWater" e "height_".
Serão disparadas 10 mensagens "multicast" direcionadas ao porto "666" das máquinas em questão.
Deverão ser recebidas 10 mensagens idênticas. Estas mensagens serão transformadas em arquivos pelo cliente de testes, sendo que o conteúdo de cada um destes arquivos deve ser como o que segue:

cell2120soilWater10height_10
]]


--#####################################################################################################################################################


-- OBSERVER UDP 01 / OBSERVER UDP 02/ OBSERVER UDP 03:
--É esperado que seja recebida 1 mensagem, para a porta padrão, e no host padrão.

--Deverá mostrar os seguintes warnings:
--Warning: Port not defined.
--Warning: Observer will send to broadcast.

-- ================================================================================#
-- OBSERVER UDP 04:
--É esperado que seja recebida 1 mensagem,para o atributo t, para a porta 
--padrão, e no host padrão.

--Deverá mostrar os seguintes warnings:
--Warning: Port not defined.
--Warning: Observer will send to broadcast.

-- ================================================================================#
-- OBSERVER UDP 05:
--É esperado que seja recebida 1 mensagem,para o atributo t, para a 
--porta 54544, e no host "192.168.0.235".

-- ================================================================================#
-- OBSERVER UDP 06:
--É esperado que seja recebida 1 mensagem,para o atributo t, para a 
--porta 54544, e nos hosts "192.168.0.235" e "192.168.0.224".

-- ================================================================================#


SKIP = false

-- test_TextScreen(TEST)  -- cases of [1..5]
-- test_LogFile(TEST)  -- cases of [1..6]
-- test_Table(TEST) -- cases of [1..6]
-- test_Chart(TEST) -- cases of [1..8]
--test_UDP(TEST) -- cases of [1..7]

testsSourceCodes = {
["TextScreen"] = test_TextScreen, 
["LogFile"] = test_LogFile,
["Table"] = test_Table,
["Chart"] = test_Chart,
["UDP"] = test_UDP
}

file = io.open("input.txt","r")
obsType = file:read()
testNumber = tonumber(file:read())
file:close()

testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
