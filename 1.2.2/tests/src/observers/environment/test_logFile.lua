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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

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

t = Timer{
	Event{ time = 0, period = 1, action = function(event) 
			at1:execute(event) 
			env:notify(event:getTime())

			env.counter = event:getTime() + 1
			env.temperature = event:getTime() * 2

			if ((killObserver and observerKill) and (event:getTime() == 8)) then
				print("", "env:kill", env:kill(observerKill))
			end
			return true 
		end 
	}
}

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
env:add(t)

logFileFor = function( killObserver,unitTest )
	if ((killObserver and observerLogFile06) and (i == 8)) then
		print("", "observerLogFile06:kill", observerLogFile06:kill())
	end
	env:execute(10)
	unitTest:assert_true(true)
end

local observersLogFileTest = UnitTest {
	test_LogFile01 = function(unitTest) 
		-- OBSERVER LOGFILE 01
		print("OBSERVER LOGFILE 01") io.flush()
		observerLogFile01 = Observer{subject=env, type="logfile"}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile01.type)
	end,
	test_LogFile02 = function(unitTest) 
		-- OBSERVER LOGFILE 02 
		print("OBSERVER LOGFILE 02") io.flush()
		observerLogFile02 = Observer{subject=env, type="logfile", attributes={}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,
	test_LogFile03 = function(unitTest) 
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03") io.flush() 
		observerLogFile03 = Observer{subject=env, type="logfile", attributes={}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,
	test_LogFile04 = function(unitTest) 
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04") io.flush()
		observerLogFile04 = Observer{subject=env, type="logfile", attributes={"c1"}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,
	test_LogFile05 = function(unitTest) 
		-- 0BSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05") io.flush()
		observerLogFile05 = Observer{subject=env, type="logfile", attributes={"t"}, outfile="logfile.csv", path="."}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_LogFile06 = function(unitTest) 
		-- 0BSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06") io.flush()
		observerLogFile06 = Observer{subject=env, type="logfile", attributes={"t"}, outfile="logfile.csv", path="."}
		logFileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end,
	test_LogFile07 = function(unitTest) 
		-- 0BSERVER LOGFILE 07
		print("OBSERVER LOGFILE 07") io.flush()
		observerLogFile07 = Observer{subject=env, type="logfile", attributes={"t"}, outfile = TME_ImagePath.."/result.csv"}
		logFileFor(true,unitTest)
		
	    moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."environment"..TME_DIR_SEPARATOR.."test_logFile"..TME_DIR_SEPARATOR.."test_LogFile07",".csv")
	    
	    
	    if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/result.csv".. " > /dev/null 2>&1 ")
	    else
		    --@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end
        
		unitTest:assert_equal("logfile",observerLogFile07.type)
	end
}
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

LOGFILE 07
]]

observersLogFileTest:run()
os.exit(0)
