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
dofile (TME_PATH.."/tests/run/run_util.lua")

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

-- ================================================================================#
-- OBSERVER TEXTSCREEN
function test_TextScreen( case)
	if( not SKIP ) then
		switch( case ) : caseof {
			[1] = function(x) 
				-- OBSERVER TEXTSCREEN 01
				print("OBSERVER TEXTSCREEN 01")
				--@DEPRECATED
				--clock1:createObserver("textscreen")
				createTimer(1)
				observerTextScreen01 = Observer{ subject = clock1, type = "textscreen" }
			end,
			[2] = function(x) 
				-- OBSERVER TEXTSCREEN 02
				print("OBSERVER TEXTSCREEN 02")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {} )
				createTimer(1)
				observerTextScreen02 = Observer{ subject = clock1, type = "textscreen", attributes={}}
			end,
			[3] = function(x)
				-- OBSERVER TEXTSCREEN 03 
				print("OBSERVER TEXTSCREEN 03")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(1)
				observerTextScreen03 = Observer{ subject = clock1, type = "textscreen", attributes={}}
			end,
			[4] = function(x)
				-- OBSERVER TEXTSCREEN 04 
				print("OBSERVER TEXTSCREEN 04")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(1)
				observerTextScreen04 = Observer{ subject = clock1, type = "textscreen", attributes={"@time"}}
			end,
			[5] = function(x)
				-- OBSERVER TEXTSCREEN 05
				print("OBSERVER TEXTSCREEN 05")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(1)
				observerTextScreen05 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","ev1","id","cObj_"}}
			end,
			[6] = function(x)
				-- OBSERVER TEXTSCREEN 06
				print("OBSERVER TEXTSCREEN 06")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(1)
				observerTextScreen06 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","id","cObj_"}}
			end,
			[7] = function(x) 
				-- OBSERVER TEXTSCREEN 07
				print("OBSERVER TEXTSCREEN 07")
				--@DEPRECATED
				--clock1:createObserver("textscreen")
				createTimer(2)
				observerTextScreen07 = Observer{ subject = clock1, type = "textscreen" }
			end,
			[8] = function(x) 
				-- OBSERVER TEXTSCREEN 08
				print("OBSERVER TEXTSCREEN 08")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {} )
				createTimer(2)
				observerTextScreen08 = Observer{ subject = clock1, type = "textscreen", attributes={}}
			end,
			[9] = function(x)
				-- OBSERVER TEXTSCREEN 09
				print("OBSERVER TEXTSCREEN 09")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(2)
				observerTextScreen09 = Observer{ subject = clock1, type = "textscreen", attributes={}}
			end,
			[10] = function(x)
				-- OBSERVER TEXTSCREEN 10 
				print("OBSERVER TEXTSCREEN 10")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(2)
				observerTextScreen10 = Observer{ subject = clock1, type = "textscreen", attributes={"@time"}}
			end,
			[11] = function(x)
				-- OBSERVER TEXTSCREEN 11
				print("OBSERVER TEXTSCREEN 11")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(2)
				observerTextScreen11 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","ev1","id","cObj_"}}
			end,
			[12] = function(x)
				-- OBSERVER TEXTSCREEN 12
				print("OBSERVER TEXTSCREEN 12")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(2)
				observerTextScreen12 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","id","cObj_"}}
			end,
			[13] = function(x)
				-- OBSERVER TEXTSCREEN 13
				print("OBSERVER TEXTSCREEN 13")
				--@DEPRECATED
				--clock1:createObserver( "textscreen", {}, {} )
				createTimer(2)
				observerTextScreen13 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","id","cObj_"}}

				killObserver = true
			end
		}
		if ((killObserver and observerTextScreen13) and (i == 8)) then
			print("", "observerTextScreen13:kill", observerTextScreen13:kill())
		end
		clock1:execute(10)

	end
end
-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03 / TEXTSCREEN 07 / TEXTSCREEN 08 / TEXTSCREEN 09
Deve apresentar na tela uma tabela textual contendo todos os atributos do relógio "clock1" no cabeçalho: "id", "@time", "ev1", "ev2", "ev3", "ev4" e "cObj_". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 40 linhas (19 linhas para TEXTSCREEN 07 / TEXTSCREEN 08 / TEXTSCREEN 09) com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 04 / TEXTSCREEN 10
Deve apresentar na tela uma tabela textual contendo o atributo "@time". Deverão ser apresentadas também 10 linhas com os valores relativos ao atributo. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverão ser apresentadas também 40 linhas (19 para TEXTSCREEN 10) com os valores relativos a cada um dos atributos do cabeçalho. 
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 05 / TEXTSCREEN 11
Deve apresentar na tela uma tabela textual contendo os atributos "@time","ev1","id","cObj_". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 40 linhas (19 para TEXTSCREEN 11) contendo os valores relativos a estes três atributos. Todas as linhas deverão ser iguais já que o teste em questão não altera valores dos atributos.

TEXTSCREEN 06 / TEXTSCREEN 12
Deve apresentar na tela uma tabela textual contendo os atributos "@time","id","cObj_". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 40(19 para TEXTSCREEN 12) linhas contendo os valores relativos a estes três atributos. Todas as linhas deverão ser iguais já que o teste em questão não altera valores dos atributos.

--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 13
Este teste será idêntico ao teste TEXTSCREEN 12. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]
-- ================================================================================#
-- OBSERVER LOGFILE
function test_LogFile( case)
	if( not SKIP ) then
		switch( case ) : caseof {
			[1] = function(x)
				--OBSERVER LOGFILE 01 
				print("OBSERVER LOGFILE 01 ")
				--@DEPRECATED
				--clock1:createObserver( "logfile" )
				createTimer(1)
				observerLogFile01 = Observer{ subject = clock1, type = "logfile" }
			end,
			[2] = function(x)
				-- OBSERVER LOGFILE 02
				print("OBSERVER LOGFILE 02 ")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {} )
				createTimer(1)
				observerLogFile02 = Observer{ subject = clock1, type = "logfile",attributes={} }
			end,
			[3] = function(x)
				-- OBSERVER LOGFILE 03
				print("OBSERVER LOGFILE 03 ")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {""} )
				createTimer(1)
				observerLogFile03 = Observer{ subject = clock1, type = "logfile",attributes={} }
			end,
			[4] = function(x)
				-- OBSERVER LOGFILE 04 
				print("OBSERVER LOGFILE 04")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(1)
				observerLogFile04 = Observer{ subject = clock1, type = "logfile", attributes={"@time"}}
			end,
			[5] = function(x)
				-- OBSERVER LOGFILE 05
				print("OBSERVER LOGFILE 05")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(1)
				observerLogFile05 = Observer{ subject = clock1, type = "logfile", attributes={"@time","ev1","id","cObj_"}, outfile = "logfile.csv", separator=","}
			end,
			[6] = function(x)
				-- OBSERVER LOGFILE 06
				print("OBSERVER LOGFILE 06")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(1)
				observerLogFile06 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
			end,
			[7] = function(x)
				--OBSERVER LOGFILE 07 
				print("OBSERVER LOGFILE 7 ")
				--@DEPRECATED
				--clock1:createObserver( "logfile" )
				createTimer(2)
				observerLogFile07 = Observer{ subject = clock1, type = "logfile" }
			end,
			[8] = function(x)
				-- OBSERVER LOGFILE 08
				print("OBSERVER LOGFILE 08 ")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {} )
				createTimer(2)
				observerLogFile08 = Observer{ subject = clock1, type = "logfile",attributes={} }
			end,
			[9] = function(x)
				-- OBSERVER LOGFILE 09
				print("OBSERVER LOGFILE 09 ")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {""} )
				createTimer(2)
				observerLogFile09 = Observer{ subject = clock1, type = "logfile",attributes={} }
			end,
			[10] = function(x)
				-- OBSERVER LOGFILE 10
				print("OBSERVER LOGFILE 10")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(2)
				observerLogFile10 = Observer{ subject = clock1, type = "logfile", attributes={"@time"}}
			end,
			[11] = function(x)
				-- OBSERVER LOGFILE 11
				print("OBSERVER LOGFILE 11")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(2)
				observerLogFile11 = Observer{ subject = clock1, type = "logfile", attributes={"@time","ev1","id","cObj_"}, outfile = "logfile.csv", separator=","}
			end,
			[12] = function(x)
				-- OBSERVER LOGFILE 12
				print("OBSERVER LOGFILE 12")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(2)
				observerLogFile12 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}
			end,
			[13] = function(x)
				-- OBSERVER LOGFILE 13
				print("OBSERVER LOGFILE 13")
				--@DEPRECATED
				--clock1:createObserver( "logfile", {}, {} )
				createTimer(2)
				observerLogFile13 = Observer{ subject = clock1, type = "logfile", attributes={"@time","id","cObj_"}, outfile = "logfile.csv", separator=","}

				killObserver = true
			end
		}
		--clock1:notify()
		if ((killObserver and observerLogFile13) and (i == 8)) then
			print("", "observerLogFile13:kill", observerLogFile13:kill())
		end
		clock1:execute(10)
	end
end

-- TESTES OBSERVER LOGFILE
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

-- ================================================================================#
-- OBSERVER TABLE
function test_Table( case)
	if( not SKIP ) then
		switch( case ) : caseof {
			[1] = function(x)
				--OBSERVER TABLE 01
				print("OBSERVER TABLE 01")
				--clock1:createObserver( "table" )
				createTimer(1)
				observerTable01 = Observer{ subject = clock1, type = "table" }
			end,
			[2] = function(x)
				--OBSERVER TABLE 02
				print("OBSERVER TABLE 02")
				--clock1:createObserver( "table", {} )
				createTimer(1)
				observerTable02 = Observer{ subject = clock1, type = "table",attributes={} }
			end,
			[3] = function(x)
				-- OBSERVER TABLE 03
				print("OBSERVER TABLE 03")
				--clock1:createObserver( "table", {}, {} )
				createTimer(1)
				observerTable03 = Observer{ subject = clock1, type = "table",attributes={} }
			end,
			[4] = function(x)
				-- OBSERVER TABLE 04 
				print("OBSERVER TABLE 04")
				--@DEPRECATED
				--clock1:createObserver( "table", {"@time"}, {} )
				createTimer(1)
				observerTable04 = Observer{ subject = clock1, type = "table", attributes={"@time"}}
			end,
			[5] = function(x)
				-- OBSERVER TABLE 05
				print("OBSERVER TABLE 05")
				--@DEPRECATED
				--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
				createTimer(1)
				observerTable05 = Observer{ subject = clock1, type = "table", attributes={"@time","ev1","id","cObj_"}}
			end,
			[6] = function(x)
				-- OBSERVER TABLE 06
				print("OBSERVER TABLE 06")
				--@DEPRECATED
				--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
				createTimer(1)
				observerTable06 = Observer{ subject = clock1, type = "table", attributes={"@time","id","cObj_"}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
			end,
			[7] = function(x)
				--OBSERVER TABLE 07
				print("OBSERVER TABLE 07")
				--clock1:createObserver( "table" )
				createTimer(2)
				observerTable07 = Observer{ subject = clock1, type = "table" }
			end,
			[8] = function(x)
				--OBSERVER TABLE 08
				print("OBSERVER TABLE 08")
				--clock1:createObserver( "table", {} )
				createTimer(2)
				observerTable08 = Observer{ subject = clock1, type = "table",attributes={} }
			end,
			[9] = function(x)
				-- OBSERVER TABLE 09
				print("OBSERVER TABLE 09")
				--clock1:createObserver( "table", {}, {} )
				createTimer(2)
				observerTable09 = Observer{ subject = clock1, type = "table",attributes={} }
			end,
			[10] = function(x)
				-- OBSERVER TABLE 10 
				print("OBSERVER TABLE 10")
				--@DEPRECATED
				--clock1:createObserver( "table", {"@time"}, {} )
				createTimer(2)
				observerTable10 = Observer{ subject = clock1, type = "table", attributes={"@time"}}
			end,
			[11] = function(x)
				-- OBSERVER TABLE 11
				print("OBSERVER TABLE 11")
				--@DEPRECATED
				--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
				createTimer(2)
				observerTable11 = Observer{ subject = clock1, type = "table", attributes={"@time","ev1","id","cObj_"}}
			end,
			[12] = function(x)
				-- OBSERVER TABLE 12
				print("OBSERVER TABLE 12")
				--@DEPRECATED
				--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
				createTimer(2)
				observerTable12 = Observer{ subject = clock1, type = "table", attributes={"@time","id","cObj_"}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
			end,
			[13] = function(x)
				-- OBSERVER TABLE 13
				print("OBSERVER TABLE 13")
				--@DEPRECATED
				--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
				createTimer(2)
				observerTable13 = Observer{ subject = clock1, type = "table", attributes={"@time","id","cObj_"}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}

				killObserver = true
			end

		}
		if ((killObserver and observerTable13) and (i == 8)) then
			print("", "observerTable13:kill", observerTable13:kill())
		end
		clock1:execute(10)
	end
end

-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02 / TABLE 03 / TABLE 07 / TABLE 08 / TABLE 09
Deverá apresentar na tela uma tabela contendo todos os atributos do relógio "clock1" no cabeçalho: "id", "@time", "ev1", "ev2", "ev3", "ev4" e "cObj_". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 04 / TABLE 10
Deverá apresentar na tela uma tabela contendo o atributo "@time". O atributo dinâmico "@time" deverá ser exibido e seu valor deve variar entre 1 e 10 durante o teste.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 05 / TABLE 11
Deverá apresentar na tela uma tabela contendo os atributos "@time","ev1","id","cObj_". Os atributos devem ser apresentados na ordem em que é feita a especificação. O valor do atributo "@time" deve variar entre 1 e 10 durante o teste.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 06 / TABLE 12
Deverá apresentar na tela uma tabela contendo os atributos "@time","id","cObj_". O titulo da coluna de atributos será "-- ATTRS --" e o da coluna de valores "-- VALUES --". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes três atributos. Todas as linhas deverão ser iguais já que o teste em questão não altera valores dos atributos.

TABLE 13
Este teste será idêntico ao teste TABLE 12. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]
-- ================================================================================#
-- OBSERVER SCHEDULER
function test_Scheduler(case)
	if( not SKIP ) then
		switch( case ) : caseof {
			[1] = function(x)
				-- OBSERVER SCHEDULER 01 
				print("OBSERVER SCHEDULER 01")
				--clock1:createObserver("scheduler")
				createTimer(1)
				observerScheduler01 = Observer{ subject = clock1, type = "scheduler" }
			end,
			[2] = function(x)
				-- OBSERVER SCHEDULER 02 
				print("OBSERVER SCHEDULER 02")
				--clock1:createObserver( "scheduler", {} )
				createTimer(1)
				observerScheduler02 = Observer{ subject = clock1, type = "scheduler", attributes={}}
			end,
			[3] = function(x)
				-- OBSERVER SCHEDULER 03 
				print("OBSERVER SCHEDULER 03")
				--clock1:createObserver( "scheduler", {}, {} )
				createTimer(1)
				observerScheduler03 = Observer{ subject = clock1, type = "scheduler", attributes={}}
			end,
			[4] = function(x)
				-- OBSERVER SCHEDULER 04 
				print("OBSERVER SCHEDULER 04")
				--clock1:createObserver("scheduler")
				createTimer(2)
				observerScheduler04 = Observer{ subject = clock1, type = "scheduler" }
			end,
			[5] = function(x)
				-- OBSERVER SCHEDULER 05
				print("OBSERVER SCHEDULER 05")
				--clock1:createObserver( "scheduler", {} )
				createTimer(2)
				observerScheduler05 = Observer{ subject = clock1, type = "scheduler", attributes={}}
			end,
			[6] = function(x)
				-- OBSERVER SCHEDULER 06 
				print("OBSERVER SCHEDULER 06")
				--clock1:createObserver( "scheduler", {}, {} )
				createTimer(2)
				observerScheduler06 = Observer{ subject = clock1, type = "scheduler", attributes={}}
			end,
			[7] = function(x)
				-- OBSERVER SCHEDULER 07 
				print("OBSERVER SCHEDULER 07")
				--clock1:createObserver( "scheduler", {}, {} )
				createTimer(2)
				observerScheduler07 = Observer{ subject = clock1, type = "scheduler", attributes={}}

				END_TIME = 20
				killObserver = true
			end
		}
		if ((killObserver and observerScheduler07) and (i == 8)) then
			print("", "observerScheduler07:kill", observerScheduler07:kill())
		end
		clock1:execute(30)

	end
end
-- TESTES OBSERVER SCHEDULER
--[[
SCHEDULER 01 / SCHEDULER 02 / SCHEDULER 03
Deverá apresentar na tela um escalonador onde cada uma de suas linhas representa um evento (i.e., "ev1", "ev2", "ev3" e "ev4"). Os eventos deverão se alternar conforme a execução de cada um. A cada execução um novo evento deve ficar no topo da lista apresentada, seguindo a ordem de execução: "ev1", "ev2", "ev3" e "ev4". O mostrador do relógio de simulação deverá atingir o valor 30.

SCHEDULER 04 / SCHEDULER 05 / SCHEDULER 06
Deverá apresentar na tela um escalonador onde cada uma de suas linhas representa um evento (i.e., "ev1", "ev2", "ev3" e "ev4"). Os eventos deverão se alternar conforme a execução de cada um. A cada execução um novo evento deve ficar no topo da lista apresentada mas, quando "ev1" chegar ao topo, o mesmo deve executar durante 4 vezes ao invés de uma, como é o caso de "ev2", "ev3" e "ev4".

SCHEDULER 07
Este teste será idêntico ao teste SCHEDULER 06. Porém, no tempo de simulação 20, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

-- ================================================================================#
-- OBSERVER UDP
function test_udp( case)
	if( not SKIP ) then
		IP1 = "192.168.0.235"
		IP2 = "192.168.0.224"
		switch( case ) : caseof {

			[1] = function(x)
				-- OBSERVER UDPSENDER 01
				print("OBSERVER UDPSENDER 01")
				--clock1:createObserver("udpsender")
				createTimer(1)
				observerUdpSender01 = Observer{ subject = clock1, type = "udpsender" }
			end,
			[2] = function(x)
				-- OBSERVER UDPSENDER 02
				print("OBSERVER UDPSENDER 02")
				--clock1:createObserver("udpsender", {})
				createTimer(1)
				observerUdpSender02 = Observer{ subject = clock1, type = "udpsender", attributes = {} }
			end,
			[3] = function(x)
				-- OBSERVER UDPSENDER 03
				print("OBSERVER UDPSENDER 03")
				--clock1:createObserver("udpsender", {}, {""})
				createTimer(1)
				observerUdpSender03 = Observer{ subject = clock1, type = "udpsender",hosts ={}, attributes={} }
			end,
			[4] = function(x)
				-- OBSERVER UDPSENDER 04
				print("OBSERVER UDPSENDER 04")
				--clock1:createObserver("udpsender", { }, {"456456", IP2})
				createTimer(1)
				observerUdpSender04 = Observer{ subject = clock1, type = "udpsender", attributes = { },port= "456456",hosts={IP2} }
			end,
			[5] = function(x)
				-- OBSERVER UDPSENDER 05
				print("OBSERVER UDPSENDER 05")
				--clock1:createObserver("udpsender", { }, {"456456", IP1, IP2})
				createTimer(1)
				observerUdpSender05 = Observer{ subject = clock1, type = "udpsender", attributes = { },port = "456456",hosts={IP1,IP2} }
			end,
			[6] = function(x)
				-- OBSERVER UDPSENDER 06
				print("OBSERVER UDPSENDER 06")
				--clock1:createObserver("udpsender")
				createTimer(2)
				observerUdpSender06 = Observer{ subject = clock1, type = "udpsender" }
			end,
			[7] = function(x)
				-- OBSERVER UDPSENDER 07
				print("OBSERVER UDPSENDER 07")
				--clock1:createObserver("udpsender", {})
				createTimer(2)
				observerUdpSender07 = Observer{ subject = clock1, type = "udpsender", attributes = {} }
			end,
			[8] = function(x)
				-- OBSERVER UDPSENDER 08
				print("OBSERVER UDPSENDER 08")
				--clock1:createObserver("udpsender", {}, {""})
				createTimer(2)
				observerUdpSender08 = Observer{ subject = clock1, type = "udpsender",hosts ={}, attributes={} }
			end,
			[9] = function(x)
				-- OBSERVER UDPSENDER 09
				print("OBSERVER UDPSENDER 09")
				--clock1:createObserver("udpsender", { }, {"456456", IP2})
				createTimer(2)
				observerUdpSender09 = Observer{ subject = clock1, type = "udpsender", attributes = { },port= "456456",hosts={IP2} }
			end,
			[10] = function(x)
				-- OBSERVER UDPSENDER 10
				print("OBSERVER UDPSENDER 10")
				--clock1:createObserver("udpsender", { }, {"456456", IP1, IP2})
				createTimer(2)
				observerUdpSender10 = Observer{ subject = clock1, type = "udpsender", attributes = { },port = "456456",hosts={IP1,IP2} }
			end,
			[11] = function(x)
				-- OBSERVER UDPSENDER 11
				print("OBSERVER UDPSENDER 11")
				--clock1:createObserver("udpsender", { }, {"456456", IP1, IP2})
				createTimer(2)
				observerUdpSender11 = Observer{ subject = clock1, type = "udpsender", attributes = { },port = "456456",hosts={IP1,IP2} }

				killObserver = true
			end
		}
		--clock1:notify()
		clock1:execute(10)
		if ((killObserver and observerUdpSender11) and (i == 8)) then
			print("", "observerUdpSender11:kill", observerUdpSender11:kill())
		end
	end
end

testsSourceCodes = {
	test_TextScreen, 
	test_LogFile,
	test_Table,
	test_Scheduler,
	test_udp
}

print("**     TESTS FOR TIMER OBSERVERS      **\n")
print("** Choose observer type and test case **")
print("(1) TextScreen        ","[ Cases 1..13 ]")
print("(2) LogFile           ","[ Cases 1..13 ]")
print("(3) Table             ","[ Cases 1..13 ]")
print("(4) Scheduler         ","[ Cases 1..7  ]")
print("(5) UDP               ","[ Cases 1..11 ]")

print("\nObserver Type:")io.flush()
obsType = tonumber(io.read())
print("\nTest Case:    ")io.flush()
testNumber = tonumber(io.read())
print("")io.flush()
testsSourceCodes[obsType](testNumber)

print("Press <ENTER> to quit...")io.flush()	
io.read()

os.exit(0)
