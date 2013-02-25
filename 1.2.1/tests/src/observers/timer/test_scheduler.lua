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

schedulerFor = function(killObserver)
	if ((killObserver and observerScheduler07) and (i == 8)) then
		print("", "observerScheduler07:kill", observerScheduler07:kill())
	end
	clock1:execute(30)
end

local observersSchedulerTest = UnitTest {
	-- ================================================================================#
	-- OBSERVER SCHEDULER
	test_scheduler01 = function(x)
		-- OBSERVER SCHEDULER 01
		print("OBSERVER SCHEDULER 01")
		--clock1:createObserver("scheduler")
		createTimer(1)
		observerScheduler01 = Observer{ subject = clock1, type = "scheduler" }
		schedulerFor(false)
	end,
	test_scheduler02 = function(x)
		-- OBSERVER SCHEDULER 02
		print("OBSERVER SCHEDULER 02")
		--clock1:createObserver( "scheduler", {} )
		createTimer(1)
		observerScheduler02 = Observer{ subject = clock1, type = "scheduler", attributes={}}
		schedulerFor(false)
	end,
	test_scheduler03 = function(x)
		-- OBSERVER SCHEDULER 03
		print("OBSERVER SCHEDULER 03")
		--clock1:createObserver( "scheduler", {}, {} )
		createTimer(1)
		observerScheduler03 = Observer{ subject = clock1, type = "scheduler", attributes={}}
		schedulerFor(false)
	end,
	test_scheduler04 = function(x)
		-- OBSERVER SCHEDULER 04
		print("OBSERVER SCHEDULER 04")
		--clock1:createObserver("scheduler")
		createTimer(2)
		observerScheduler04 = Observer{ subject = clock1, type = "scheduler" }
		schedulerFor(false)
	end,
	test_scheduler05 = function(x)
		-- OBSERVER SCHEDULER 05
		print("OBSERVER SCHEDULER 05")
		--clock1:createObserver( "scheduler", {} )
		createTimer(2)
		observerScheduler05 = Observer{ subject = clock1, type = "scheduler", attributes={}}
		schedulerFor(false)
	end,
	test_scheduler06 = function(x)
		-- OBSERVER SCHEDULER 06
		print("OBSERVER SCHEDULER 06")
		--clock1:createObserver( "scheduler", {}, {} )
		createTimer(2)
		observerScheduler06 = Observer{ subject = clock1, type = "scheduler", attributes={}}
		schedulerFor(false)
	end,
	test_scheduler07 = function(x)
		-- OBSERVER SCHEDULER 07
		print("OBSERVER SCHEDULER 07")
		--clock1:createObserver( "scheduler", {}, {} )
		createTimer(2)
		observerScheduler07 = Observer{ subject = clock1, type = "scheduler", attributes={}}

		END_TIME = 20
		schedulerFor(true)
	end
} 
--[[
SCHEDULER 01 / SCHEDULER 02 / SCHEDULER 03
Deverá apresentar na tela um escalonador onde cada uma de suas linhas representa um evento (i.e., "ev1", "ev2", "ev3" e "ev4"). Os eventos deverão se alternar conforme a execução de cada um. A cada execução um novo evento deve ficar no topo da lista apresentada, seguindo a ordem de execução: "ev1", "ev2", "ev3" e "ev4". O mostrador do relógio de simulação deverá atingir o valor 30.

SCHEDULER 04 / SCHEDULER 05 / SCHEDULER 06
Deverá apresentar na tela um escalonador onde cada uma de suas linhas representa um evento (i.e., "ev1", "ev2", "ev3" e "ev4"). Os eventos deverão se alternar conforme a execução de cada um. A cada execução um novo evento deve ficar no topo da lista apresentada mas, quando "ev1" chegar ao topo, o mesmo deve executar durante 4 vezes ao invés de uma, como é o caso de "ev2", "ev3" e "ev4".

SCHEDULER 07
Este teste será idêntico ao teste SCHEDULER 06. Porém, no tempo de simulação 20, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

observersSchedulerTest:run()
os.exit(0)
