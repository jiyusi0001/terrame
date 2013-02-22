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
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

clock1 = nil
function createTimer(case)
	switch( case ) : caseof {   
		[1] = function(x)
			clock1 = Timer{
				id = "clock1",
				ev1 = Event{time = 1, period = 1, priority = 1,  action = function(event)
						clock1:notify();
						-- print("ev1,period = 1, priority = 1")   io.flush()

						print("step ev1", event:getTime())  io.flush()

						if ((killObserver and observerKill) and (event:getTime() == END_TIME)) then
							print("", "clock1:kill", clock1:kill(observerKill))
						end

						--delay_s(1)
					end},
				ev2 = Event{time = 1, period = 1, priority = 2, action = function(event)
						clock1:notify();
						-- print("ev2,period = 1, priority = 2") io.flush()
						print("step ev2", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev3 = Event{time = 1, period = 1, priority = 3,  action = function(event)
						clock1:notify();
						-- print("ev3,period = 1, priority = 3") io.flush()
						print("step ev3", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev4 = Event{time = 1,   period =1,  priority = 4,  action = function(event)
						clock1:notify();
						-- print("ev4,period = 1, priority = 4") io.flush()
						print("step ev4", event:getTime())  io.flush()
						--delay_s(1)
						--for i = 1,4000000 do end
						io.flush()
					end}
			}
		end,
		[2] = function(x)
			clock1 = Timer{
				id = "clock1",
				ev1 = Event{time = 1, period = 1, priority = 1,  action = function(event)
						clock1:notify();
						-- print("ev1,period = 1, priority = 1") io.flush()

						print("step ev1", event:getTime())  io.flush()

						if ((killObserver and observerKill) and (event:getTime() == END_TIME)) then
							print("", "clock1:kill", clock1:kill(observerKill))
						end
						--delay_s(1)
					end},
				ev2 = Event{time = 1, period = 4, priority = 10, action = function(event)
						clock1:notify();
						-- print("ev2,period = 4, priority = 10") io.flush()
						print("step ev2", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev3 = Event{time = 1, period = 4, priority = 10,  action = function(event)
						clock1:notify();
						-- print("ev3,period = 4, priority = 10") io.flush()
						print("step ev3", event:getTime())  io.flush()
						--delay_s(1)
					end},
				ev4 = Event{time = 1,   period = 4,  priority = 10,  action = function(event)
						clock1:notify();
						-- print("ev4,period = kpriority = 10") io.flush()
						print("step ev4", event:getTime())  io.flush()
						--delay_s(1)                                         
						--for i = 1,4000000 do end
						io.flush()
					end}
			}
		end
	}
end


-- Enables kill an observer
killObserver = false
observerKill = nil
END_TIME = 8

logFileFor = function(killObserver)
	if ((killObserver and observerLogFile13) and (i == 8)) then
		print("", "observerLogFile13:kill", observerLogFile13:kill())
	end
	clock1:execute(10)
end

local observersLogFileTest = UnitTest {
	-- ================================================================================#
	-- OBSERVER LOGFILE
	test_logFile01 = function(x)
		--OBSERVER LOGFILE 01
		print("OBSERVER LOGFILE 01 ")
		--@DEPRECATED
		--clock1:createObserver( "logfile" )
		createTimer(1)
		observerLogFile01 = Observer{ subject = clock1, type = "logfile" }
		logFileFor(false)
	end,
	test_logFile02 = function(x)
		-- OBSERVER LOGFILE 02
		print("OBSERVER LOGFILE 02 ")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {} )
		createTimer(1)
		observerLogFile02 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false)
	end,
	test_logFile03 = function(x)
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03 ")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {""} )
		createTimer(1)
		observerLogFile03 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false)
	end,
	test_logFile04 = function(x)
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(1)
		observerLogFile04 = Observer{ subject = clock1, type = "logfile", attributes={"@time"}}
		logFileFor(false)
	end,
	test_logFile05 = function(x)
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(1)
		observerLogFile05 = Observer{ subject = clock1, type = "logfile", attributes={"@time","ev1","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false)
	end,
	test_logFile06 = function(x)
		-- OBSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(1)
		observerLogFile06 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false)
	end,
	test_logFile07 = function(x)
		--OBSERVER LOGFILE 07
		print("OBSERVER LOGFILE 7 ")
		--@DEPRECATED
		--clock1:createObserver( "logfile" )
		createTimer(2)
		observerLogFile07 = Observer{ subject = clock1, type = "logfile" }
		logFileFor(false)
	end,
	test_logFile08 = function(x)
		-- OBSERVER LOGFILE 08
		print("OBSERVER LOGFILE 08 ")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {} )
		createTimer(2)
		observerLogFile08 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false)
	end,
	test_logFile09 = function(x)
		-- OBSERVER LOGFILE 09
		print("OBSERVER LOGFILE 09 ")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {""} )
		createTimer(2)
		observerLogFile09 = Observer{ subject = clock1, type = "logfile",attributes={} }
		logFileFor(false)
	end,
	test_logFile10 = function(x)
		-- OBSERVER LOGFILE 10
		print("OBSERVER LOGFILE 10")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(2)
		observerLogFile10 = Observer{ subject = clock1, type = "logfile", attributes={"@time"}}
		logFileFor(false)
	end,
	test_logFile11 = function(x)
		-- OBSERVER LOGFILE 11
		print("OBSERVER LOGFILE 11")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(2)
		observerLogFile11 = Observer{ subject = clock1, type = "logfile", attributes={"@time","ev1","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false)
	end,
	test_logFile12 = function(x)
		-- OBSERVER LOGFILE 12
		print("OBSERVER LOGFILE 12")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(2)
		observerLogFile12 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(false)
	end,
	test_logFile13 = function(x)
		-- OBSERVER LOGFILE 13
		print("OBSERVER LOGFILE 13")
		--@DEPRECATED
		--clock1:createObserver( "logfile", {}, {} )
		createTimer(2)
		observerLogFile13 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
		logFileFor(true)
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
]]

observersLogFileTest:run()
os.exit(0)
