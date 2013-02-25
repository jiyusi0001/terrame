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

textScreenFor = function(killObserver)
  if((killObserver and observerTextScreen13) and (i==8)) then
    print("", "observerTextScreen13:kill",observerTextScreen13:kill())
  end
  clock1:execute(10)
end

local observersTextScreenTest = UnitTest {
	--=============================================================#
	-- OBSERVER TEXTSCREEN
	test_textScreen01 = function(x)
		-- OBSERVER TEXTSCREEN 01
		print("OBSERVER TEXTSCREEN 01")
		--@DEPRECATED
		--clock1:createObserver("textscreen")
		createTimer(1)
		observerTextScreen01 = Observer{ subject = clock1, type = "textscreen" }
		textScreenFor(false)
	end,
	test_textScreen02 = function(x)
		-- OBSERVER TEXTSCREEN 02
		print("OBSERVER TEXTSCREEN 02")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {} )
		createTimer(1)
		observerTextScreen02 = Observer{ subject = clock1, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_textScreen03 = function(x)
		-- OBSERVER TEXTSCREEN 03
		print("OBSERVER TEXTSCREEN 03")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(1)
		observerTextScreen03 = Observer{ subject = clock1, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_textScreen04 = function(x)
		-- OBSERVER TEXTSCREEN 04
		print("OBSERVER TEXTSCREEN 04")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(1)
		observerTextScreen04 = Observer{ subject = clock1, type = "textscreen", attributes={"@time"}}
		textScreenFor(false)
	end,
	test_textScreen05 = function(x)
		-- OBSERVER TEXTSCREEN 05
		print("OBSERVER TEXTSCREEN 05")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(1)
		observerTextScreen05 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","ev1","id","cObj_"}}
		textScreenFor(false)
	end,
	test_textScreen06 = function(x)
		-- OBSERVER TEXTSCREEN 06
		print("OBSERVER TEXTSCREEN 06")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(1)
		observerTextScreen06 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","id","cObj_"}}
		textScreenFor(false)
	end,
	test_textScreen07 = function(x)
		-- OBSERVER TEXTSCREEN 07
		print("OBSERVER TEXTSCREEN 07")
		--@DEPRECATED
		--clock1:createObserver("textscreen")
		createTimer(2)
		observerTextScreen07 = Observer{ subject = clock1, type = "textscreen" }
		textScreenFor(false)
	end,
	test_textScreen08 = function(x)
		-- OBSERVER TEXTSCREEN 08
		print("OBSERVER TEXTSCREEN 08")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {} )
		createTimer(2)
		observerTextScreen08 = Observer{ subject = clock1, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_textScreen09 = function(x)
		-- OBSERVER TEXTSCREEN 09
		print("OBSERVER TEXTSCREEN 09")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(2)
		observerTextScreen09 = Observer{ subject = clock1, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_textScreen10 = function(x)
		-- OBSERVER TEXTSCREEN 10
		print("OBSERVER TEXTSCREEN 10")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(2)
		observerTextScreen10 = Observer{ subject = clock1, type = "textscreen", attributes={"@time"}}
	end,
	test_textScreen11 = function(x)
		-- OBSERVER TEXTSCREEN 11
		print("OBSERVER TEXTSCREEN 11")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(2)
		observerTextScreen11 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","ev1","id","cObj_"}}
		textScreenFor(false)
	end,
	test_textScreen12 = function(x)
		-- OBSERVER TEXTSCREEN 12
		print("OBSERVER TEXTSCREEN 12")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(2)
		observerTextScreen12 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","id","cObj_"}}
		textScreenFor(false)
	end,
	test_textScreen13 = function(x)
		-- OBSERVER TEXTSCREEN 13
		print("OBSERVER TEXTSCREEN 13")
		--@DEPRECATED
		--clock1:createObserver( "textscreen", {}, {} )
		createTimer(2)
		observerTextScreen13 = Observer{ subject = clock1, type = "textscreen", attributes={"@time","id","cObj_"}}
		textScreenFor(true)
	end
}
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

observersTextScreenTest:run()
os.exit(0)
