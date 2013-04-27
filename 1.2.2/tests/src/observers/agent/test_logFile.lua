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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do
	for j = 1, 5, 1 do
		c = Cell{ cover = "pasture", agents_ = {}}
		c.y = j - 1;
		c.x = i - 1;
		cs:add( c );
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
	ag1.counter = ag1.counter + 10;

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
			ag1.counter = ag1.counter + 10;

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

env = Environment{ id = "MyEnvironment", cs, ag1}
env:createPlacement{strategy = "void"}

ev = Event{ time = 1, period = 1, priority = 1 }

cs:notify()
cell = cs.cells[1]
ag1:enter(cell)

logfileFor = function( killObserver, unitTest)
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
	unitTest:assert_true(true) 
end

local observersLogFileTest = UnitTest {
	test_LogFile01 = function(unitTest)
		-- OBSERVER LOGFILE 01
		print("OBSERVER LOGFILE 01")
		observerLogFile01=Observer{subject=ag1, type = "logfile"}
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile01.type)
	end,
	test_LogFile02 = function(unitTest)
		-- OBSERVER LOGFILE 02
		print("OBSERVER LOGFILE 02")
		observerLogFile02=Observer{subject=ag1, type = "logfile", attributes ={}}
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,
	test_LogFile03 = function(unitTest)
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03")
		observerLogFile03=Observer{subject=ag1, type = "logfile", attributes ={}}
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,
	test_LogFile04 = function(unitTest)
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04")
		observerLogFile04=Observer{subject=ag1, type = "logfile", attributes ={},outfile = "logfile.csv", separator=","}
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,
	test_LogFile05 = function(unitTest)
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05")
		observerLogFile05=Observer{subject=ag1, type = "logfile", attributes ={"currentState", "energy", "hungry"}}
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_LogFile06 = function(unitTest)
		-- OBSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06")
		observerLogFile06=Observer{subject=ag1, type = "logfile", attributes ={"currentState", "energy", "hungry"}}
		logfileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end,
	test_LogFile07 = function(unitTest)
		-- OBSERVER LOGFILE 07
		print("OBSERVER LOGFILE 07")
		observerLogFile07=Observer{subject=ag1, type = "logfile", attributes ={"currentState", "energy", "hungry"} ,outfile = TME_ImagePath.."/result.csv"}
		logfileFor(false,unitTest)
	    moveFilesToResults(TME_ImagePath,TME_PATH.."/bin/results/observers/agent/test_logFile/test_LogFile07",".csv")
        os.capture("rm "..TME_ImagePath.."/result.csv")
		unitTest:assert_equal("logfile",observerLogFile07.type)
	end
}

--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03

Dever� ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conte�do do arquivo dever� ser uma tabela textual contendo todos os atributos do agente "ag1" no cabe�alho: "hungry", "id", "class", "cObj_", "weights_, "time", "relatives_", "cell", "energy", "currentState", "st1" e "st2". Todos estes atributos dever�o estar presentes mas n�o necessariamente ser�o apresentados nesta ordem.
Dever�o ser apresentadas tamb�m 10 linhas com os valores relativos a cada um dos atributos do cabe�alho.
Dever�o ser mostradas mensagens de "Warning" informando o uso de valores padr�o para o nome de arquivo ("result_.csv") e caractere de separa��o (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o par�metro relacionado ao arquivo de sa�da, o nome gerado para ambos os observers ser� o mesmo.

LOGFILE 04
Dever� ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE 01, 02 e 03) dever�o ser apresentados.
Dever�o ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabe�alho. Todas as linhas dever�o ser iguais j� que o teste em quest�o n�o altera valores.

LOGFILE 05
Dever� ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos "currentState", "energy" e "hungry". Os atributos devem ser apresentados na ordem em que � feita a especifica��o. Dever�o ser apresentadas tamb�m 10 linhas contendo os valores relativos a estes atributos.
Dever�o ser mostradas mensagens de "Warning" informando o uso de valores padr�o para o nome de arquivo ("result_.csv") e caractere de separa��o (";").

LOGFILE 06
Este teste ser� id�ntico ao teste 05. Por�m, no tempo de simula��o 8, o observador "observerLogFile06" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e o arquivo "result_.csv" conter� apenas informa��es at� o 8o. tempo de simula��o

LOGFILE 07
Descri��o por fazer.

]]

observersLogFileTest:run()
os.exit(0)
