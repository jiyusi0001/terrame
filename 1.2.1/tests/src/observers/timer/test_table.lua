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

tableFor = function(killObserver)
	if ((killObserver and observerTable13) and (i == 8)) then
		print("", "observerTable13:kill", observerTable13:kill())
	end
	clock1:execute(10)
end

local observersTableTest = UnitTest {
	-- ================================================================================#
	-- OBSERVER TABLE
	test_table01 = function(x)
		--OBSERVER TABLE 01
		print("OBSERVER TABLE 01")
		--clock1:createObserver( "table" )
		createTimer(1)
		observerTable01 = Observer{ subject = clock1, type = "table" }
		tableFor(false)
	end,
	test_table02 = function(x)
		--OBSERVER TABLE 02
		print("OBSERVER TABLE 02")
		--clock1:createObserver( "table", {} )
		createTimer(1)
		observerTable02 = Observer{ subject = clock1, type = "table",attributes={} }
		tableFor(false)
	end,
	test_table03 = function(x)
		-- OBSERVER TABLE 03
		print("OBSERVER TABLE 03")
		--clock1:createObserver( "table", {}, {} )
		createTimer(1)
		observerTable03 = Observer{ subject = clock1, type = "table",attributes={} }
		tableFor(false)
	end,
	test_table04 = function(x)
		-- OBSERVER TABLE 04
		print("OBSERVER TABLE 04")
		--@DEPRECATED
		--clock1:createObserver( "table", {"@time"}, {} )
		createTimer(1)
		observerTable04 = Observer{ subject = clock1, type = "table", attributes={"@time"}}
		tableFor(false)
	end,
	test_table05 = function(x)
		-- OBSERVER TABLE 05
		print("OBSERVER TABLE 05")
		--@DEPRECATED
		--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
		createTimer(1)
		observerTable05 = Observer{ subject = clock1, type = "table", attributes={"@time","ev1","id","cObj_"}}
		tableFor(false)
	end,
	test_table06 = function(x)
		-- OBSERVER TABLE 06
		print("OBSERVER TABLE 06")
		--@DEPRECATED
		--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
		createTimer(1)
		observerTable06 = Observer{ subject = clock1, type = "table", attributes={"@time","id","cObj_"}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		tableFor(false)
	end,
	test_table07 = function(x)
		--OBSERVER TABLE 07
		print("OBSERVER TABLE 07")
		--clock1:createObserver( "table" )
		createTimer(2)
		observerTable07 = Observer{ subject = clock1, type = "table" }
		tableFor(false)
	end,
	test_table08 = function(x)
		--OBSERVER TABLE 08
		print("OBSERVER TABLE 08")
		--clock1:createObserver( "table", {} )
		createTimer(2)
		observerTable08 = Observer{ subject = clock1, type = "table",attributes={} }
		tableFor(false)
	end,
	test_table09 = function(x)
		-- OBSERVER TABLE 09
		print("OBSERVER TABLE 09")
		--clock1:createObserver( "table", {}, {} )
		createTimer(2)
		observerTable09 = Observer{ subject = clock1, type = "table",attributes={} }
		tableFor(false)
	end,
	test_table10 = function(x)
		-- OBSERVER TABLE 10
		print("OBSERVER TABLE 10")
		--@DEPRECATED
		--clock1:createObserver( "table", {"@time"}, {} )
		createTimer(2)
		observerTable10 = Observer{ subject = clock1, type = "table", attributes={"@time"}}
		tableFor(false)
	end,
	test_table11 = function(x)
		-- OBSERVER TABLE 11
		print("OBSERVER TABLE 11")
		--@DEPRECATED
		--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
		createTimer(2)
		observerTable11 = Observer{ subject = clock1, type = "table", attributes={"@time","ev1","id","cObj_"}}
		tableFor(false)
	end,
	test_table12 = function(x)
		-- OBSERVER TABLE 12
		print("OBSERVER TABLE 12")
		--@DEPRECATED
		--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
		createTimer(2)
		observerTable12 = Observer{ subject = clock1, type = "table", attributes={"@time","id","cObj_"}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		tableFor(false)
	end,
	test_table13 = function(x)
		-- OBSERVER TABLE 13
		print("OBSERVER TABLE 13")
		--@DEPRECATED
		--clock1:createObserver( "table", {"ev1","id","cObj_"}, {} )
		createTimer(2)
		observerTable13 = Observer{ subject = clock1, type = "table", attributes={"@time","id","cObj_"}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		tableFor(true)
	end
}
-- TESTES OBSERVER TEXTSCREEN
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

observersTableTest:run()
os.exit(0)
