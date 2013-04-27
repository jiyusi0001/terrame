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
-- Author:     Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--             Rodrigo Reis Pereira
--            Henrique Cota Camêlo
--            Washington Sena França e Silva
-------------------------------------------------------------------------------------------
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

clock1 = nil
function createTimer(case)
	switch( case ) : caseof {   
		[1] = function()
			clock1 = Timer{
				id = "clock1",
				ev1 = Event{time = 1, period = 1, priority = 1,  action = function(event)
						clock1:notify();

						print("step ev1", event:getTime())  io.flush()

						if ((killObserver and observerKill) and (event:getTime() == END_TIME)) then
							print("", "clock1:kill", clock1:kill(observerKill))
						end
					end},
				ev2 = Event{time = 1, period = 1, priority = 2, action = function(event)
						clock1:notify();
						print("step ev2", event:getTime())  io.flush()
					end},
				ev3 = Event{time = 1, period = 1, priority = 3,  action = function(event)
						clock1:notify();
						print("step ev3", event:getTime())  io.flush()
					end},
				ev4 = Event{time = 1,   period =1,  priority = 4,  action = function(event)
						clock1:notify();
						print("step ev4", event:getTime())  io.flush()
						io.flush()
					end}
			}
		end,
		[2] = function(x)
			clock1 = Timer{
				id = "clock1",
				ev1 = Event{time = 1, period = 1, priority = 1,  action = function(event)
						clock1:notify();
						print("step ev1", event:getTime())  io.flush()

						if ((killObserver and observerKill) and (event:getTime() == END_TIME)) then
							print("", "clock1:kill", clock1:kill(observerKill))
						end
					end},
				ev2 = Event{time = 1, period = 4, priority = 10, action = function(event)
						clock1:notify();
						print("step ev2", event:getTime())  io.flush()
					end},
				ev3 = Event{time = 1, period = 4, priority = 10,  action = function(event)
						clock1:notify();
						print("step ev3", event:getTime())  io.flush()
					end},
				ev4 = Event{time = 1,   period = 4,  priority = 10,  action = function(event)
						clock1:notify();
						print("step ev4", event:getTime())  io.flush()
						io.flush()
					end}
			}
		end
	}
end

killObserver = false
observerKill = nil
END_TIME = 8

logFileFor = function(killObserver,unitTest)
	if ((killObserver and observerLogFile13) and (i == 8)) then
		print("", "observerLogFile13:kill", observerLogFile13:kill())
	end
	clock1:execute(10)
	unitTest:assert_true(true) 
end

local observersLogFileTest = UnitTest {
	test_logFile01 = function(unitTest)
		--OBSERVER LOGFILE 01
		print("OBSERVER LOGFILE 01 ")
		createTimer(1)
		observerLogFile01 = Observer{ subject = clock1, type = "logfile" }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile01.type)
	end,
	test_logFile02 = function(unitTest)
		-- OBSERVER LOGFILE 02
		print("OBSERVER LOGFILE 02 ")
		createTimer(1)
		observerLogFile02 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,
	test_logFile03 = function(unitTest)
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03 ")
		createTimer(1)
		observerLogFile03 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,
	test_logFile04 = function(unitTest)
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04")
		createTimer(1)
		observerLogFile04 = Observer{ subject = clock1, type = "logfile", attributes={"@time"}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,
	test_logFile05 = function(unitTest)
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05")
		createTimer(1)
		observerLogFile05 = Observer{ subject = clock1, type = "logfile", attributes={"@time","ev1","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_logFile06 = function(unitTest)
		-- OBSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06")
		createTimer(1)
		observerLogFile06 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end,
	test_logFile07 = function(unitTest)
		--OBSERVER LOGFILE 07
		print("OBSERVER LOGFILE 7 ")
		createTimer(2)
		observerLogFile07 = Observer{ subject = clock1, type = "logfile" }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile07.type)
	end,
	test_logFile08 = function(unitTest)
		-- OBSERVER LOGFILE 08
		print("OBSERVER LOGFILE 08 ")
		createTimer(2)
		observerLogFile08 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile08.type)
	end,
	test_logFile09 = function(unitTest)
		-- OBSERVER LOGFILE 09
		print("OBSERVER LOGFILE 09 ")
		createTimer(2)
		observerLogFile09 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile09.type)
	end,
	test_logFile10 = function(unitTest)
		-- OBSERVER LOGFILE 10
		print("OBSERVER LOGFILE 10")
		createTimer(2)
		observerLogFile10 = Observer{ subject = clock1, type = "logfile", attributes={"@time"}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile10.type)
	end,
	test_logFile11 = function(unitTest)
		-- OBSERVER LOGFILE 11
		print("OBSERVER LOGFILE 11")
		createTimer(2)
		observerLogFile11 = Observer{ subject = clock1, type = "logfile", attributes={"@time","ev1","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile11.type)
	end,
	test_logFile12 = function(unitTest)
		-- OBSERVER LOGFILE 12
		print("OBSERVER LOGFILE 12")
		createTimer(2)
		observerLogFile12 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile12.type)
	end,
	test_logFile13 = function(unitTest)
		-- OBSERVER LOGFILE 13
		print("OBSERVER LOGFILE 13")
		createTimer(2)
		observerLogFile13 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile13.type)
	end,
	test_logFile14 = function(unitTest)
		-- OBSERVER LOGFILE 14
		print("OBSERVER LOGFILE 14")
		createTimer(2)
		observerLogFile14 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"},outfile = TME_ImagePath.."/result.csv"}
		logFileFor(false,unitTest)
		
	    moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."timer"..TME_DIR_SEPARATOR.."test_logFile"..TME_DIR_SEPARATOR.."test_logFile14",".csv")
	    
	    
	    if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/result.csv".. " > /dev/null 2>&1 ")
	    else
		    --@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end
        
		unitTest:assert_equal("logfile",observerLogFile14.type)
	end
}

--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03 / LOGFILE 07 / LOGFILE 08 / LOGFILE 09
Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser uma tabela textual contendo todos os atributos do relógio "clock1" no cabeçalho: : "id", "@time", "ev1", "ev2", "ev3", "ev4" e "cObj_". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 40 linhas (19 para LOGFILE 07 / LOGFILE 08 / LOGFILE 09) com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 a 03 e de 07 a 09), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 04 / LOGFILE 10
Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser  uma tabela textual contendo o atributo "@time". Deverão ser apresentadas também 40 linhas (19 para LOGFILE 10) com os valores relativos ao atributo. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

LOGFILE 05 / LOGFILE 11
Deverá ser gerado um arquivo com nome "logfile.csv" que utiliza "," como separador. O conteúdo do arquivo deverá ser  uma tabela textual contendo os atributos "@time", "ev1","id" e "cObj_". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 40 linhas (19 para LOGFILE 11) contendo os valores relativos a estes três atributos. Todas as linhas deverão ser iguais já que o teste em questão não altera os valores dos atributos.

LOGFILE06 / LOGFILE 12
Deverá ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conteúdo do arquivo deverá ser  uma tabela textual contendo os atributos "@time","id","cObj_". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 40 linhas (19 para LOGFILE 12) linhas contendo os valores relativos a estes três atributos. Todas as linhas deverão ser iguais já que o teste em questão não altera valores dos atributos.

LOGFILE 13
Este teste será idêntico ao teste LOGFILE 12. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "result_.csv" conterá apenas informações até o 8o. tempo de simulação

LOGFILE 14
ToDo.
]]

observersLogFileTest:run()
os.exit(0)
