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
			--print("step:", event:getTime())  io.flush()

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

logFileFor = function( killObserver )
	if ((killObserver and observerLogFile06) and (i == 8)) then
		print("", "observerLogFile06:kill", observerLogFile06:kill())
	end
	env:execute(10)
end

local observersLogFileTest = UnitTest {
	test_LogFile1 = function(unitTest) 
		-- OBSERVER LOGFILE 01
		print("OBSERVER LOGFILE 01") io.flush()
		--@DEPRECATED
		--env:createObserver("logfile")
		observerLogFile01 = Observer{subject=env, type="logfile"}
		logFileFor(false)
	end,
	test_LogFile2 = function(unitTest) 
		-- OBSERVER LOGFILE 02 
		print("OBSERVER LOGFILE 02") io.flush()
		--@DEPRECATED
		--env:createObserver( "logfile", {} )
		observerLogFile02 = Observer{subject=env, type="logfile", attributes={}}
		logFileFor(false)
	end,
	test_LogFile3 = function(unitTest) 
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03") io.flush() 
		--@DEPRECATED
		--env:createObserver( "logfile", {}, {} )--nao roda
		observerLogFile03 = Observer{subject=env, type="logfile", attributes={}}
		logFileFor(false)
	end,
	test_LogFile4 = function(unitTest) 
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04") io.flush()
		--@DEPRECATED
		--env:createObserver( "logfile", {"c1"} )
		observerLogFile04 = Observer{subject=env, type="logfile", attributes={"c1"}}
		logFileFor(false)
	end,
	test_LogFile5 = function(unitTest) 
		-- 0BSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05") io.flush()
		--@DEPRECATED
		--env:createObserver( "logfile", {"t"},{"logfile.csv","."} )
		observerLogFile05 = Observer{subject=env, type="logfile", attributes={"t"}, outfile="logfile.csv", path="."}
		logFileFor(false)
	end,
	test_LogFile6 = function(unitTest) 
		-- 0BSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06") io.flush()
		--@DEPRECATED
		--env:createObserver( "logfile", {"t"},{"logfile.csv","."} )
		observerLogFile06 = Observer{subject=env, type="logfile", attributes={"t"}, outfile="logfile.csv", path="."}
		logFileFor(true)
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
]]

observersLogFileTest:run()
os.exit(0)
