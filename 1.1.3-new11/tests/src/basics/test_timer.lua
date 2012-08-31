-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright � 2001-2007 INPE and TerraLAB/UFOP.
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
-- Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
-------------------------------------------------------------------------------------------
-- Expected result: 3 teste, 60 assertations, (3 passed, 0 failed, 0 erros)
--

arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_Timer()

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end
	print("Testing Timer, Pair, Evend, and Message...") io.flush()

	qt1=0
	qt2=0
	qt3=0

	timer = Timer{
		Pair{ Event{ time = 1, period = 1}, Action {function()
					--print "first event"
					qt1 = qt1 + 1
				end}},
		Pair{Event{ time = 2, period = 1}, Action {function()
					--print "second event"
					qt2 = qt2 + 1
				end}},
		Pair{Event{ time = 3, period = 1}, Action {function()
					--print "third event"
					qt3 = qt3 + 1
				end}}
	}

	timer:execute(4)

	--print("\n\n")
	--print("1st event:"..qt1.." times")
	--print("2nd event:"..qt2.." times")
	--print("3rd event:"..qt3.." times")
	--print("\nANOTHER TIMER")

	assert_equal(4, qt1)
	assert_equal(3, qt2)
	assert_equal(2, qt3)

	timer2 = Timer{
		Event{ time = 1, period = 1, action = function(event)
				cont = cont + 1
				assert_not_nil(event)
				--print ("first event - time: "..event:getTime())
				--print ("first event - priority: "..event:getPriority())
				--print ("first event - period: "..event:getPeriod())

				-- -- configuring the current event does not affects the TerraMEscheduler
				evTime = event:getTime() + 2
				event:config(evTime , 2, 0) 
				--print ("modified event - time: "..event:getTime()) io.flush()
				assert_equal(evTime, event:getTime())
				--print ("modified event - period: "..event:getPeriod()) io.flush()
				assert_equal(2, event:getPeriod())
				--print(event)
			end},

		Pair{ Event{ time = 1, period = 1}, Action {function(event)
					cont = cont + 1
					--print ("second event "..timer2:getTime())
					return false
				end}}
	}

	cont = 0
	--print("GET TIME: "..timer2:getTime()) io.flush()
	assert_equal(1, timer2:getTime())
	timer2:execute(6)
	assert_equal(7, timer2:getTime())
	--print("Count: ", cont)
	assert_equal(7, cont)

	cont = 0
	--print("AGAIN") io.flush()
	timer2:execute(4)
	assert_equal(7, timer2:getTime())
	assert_equal(0, cont)

	cont = 0
	--print("GET TIME: "..timer2:getTime())
	timer2:reset()
	--print("\nRESETED")
	--print("GET TIME: "..timer2:getTime()) io.flush()
	assert_equal(7, timer2:getTime()) -- The event.time == 7 is still inside the scheduler
	timer2:execute(4)
	assert_equal(7, timer2:getTime()) -- The event.time == 7 is still inside the scheduler

	print("ADDING EVENT")
	timer2:add(Event{ time = 1, period = 1}, Action {function(event)
			cont = cont + 1
			print ("third event "..timer2:getTime())
		end})

	cont = 0
	timer2:execute(12)
	--print("Count: ", cont) io.flush()
	assert_equal(13, timer2:getTime())
	assert_equal(6, cont)

	print("READY!!")
	assert_true(true)

end

-- One Timer, one Event and one Message 
function test_OneTimerOneEventAndOneMessage( )

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[2]) then
		skip("No testing...") io.flush()
	end

	print("-------------------------------------");
	print("-- test_OneTimerOneEventAndOneMessage");
	print("-------------------------------------");

	countEvent = 0 -- Event test counter
	clock1 = Timer{
		Pair{
			--## PRATICE: Exchange the two following lines. Try different "period" values.
			Event{ time = 0, period = 1 },
			--Event{ time = 0, period = 0.5 },

			--## PRATICE: Exchange the two following lines. The DEFAULT MESSAGE RETURN VALUE is TRUE.
			Action { function(event) 
					--print("Message1: ", event:getTime(), event:getPeriod(), event:getPriority() ) 
					countEvent = countEvent + 1
				end }
			--Action { function(event)  
			--	--print("Message1: ", event:getTime(), event:getPeriod(), event:getPriority() ); 
			--	countEvent = countEvent + 1
			--	return false; 
			--end }
		}
	}

	clock1:execute(10);

	t = Event{ time = 7, period = 3, priority = 4}
	print("Atributo do evento:", t:getTime(), t:getPeriod(), t:getPriority())

	print( "Events: ", countEvent ); 
	assert_equal( countEvent, 11 )

	print("Ready!!!")
	assert_true(true)

end 

-- One Timer, TWO Event and TWO Messages with different PRIORITIES
function  test_DifferentEventPriorities()

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[3]) then
		skip("No testing...") io.flush()
	end


	print("-------------------------------------");
	print("-- DifferentEventPriorities");
	print("-------------------------------------");

	-- lower numbers higher priorities
	orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
	local timeMemory = 0   -- memory of time test variable 
	assert_equal(orderToken, 0)
	clock1 = Timer{
		Pair{
			Event{ time = 0, period = 1 },
			Action { function(event) 		     
					--print("Message1: "..event:getTime(), orderToken, timeMemory ) io.flush()
					timeMemory = event:getTime()
					assert_lte(1,orderToken )
					orderToken = 1
					return true; 
				end }
		},
		Pair{
			--## PRATICE: Try change the priority between 0 and 1
			Event{ time = 1, period = 1, priority = 1 }, -- lower priority (default = 0)
			Action { function(event) 
					--print("Message2: "..event:getTime(), orderToken, timeMemory)  io.flush() 		
					if ( event:getTime() == timeMemory) then 
						assert_equal(1, orderToken )
					else
						-- -- Message2 can never execute before Message1 during the same time interval 
						print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
						assert_equal(2, orderToken )
					end
					timeMemory = event:getTime()
					orderToken = 0
					return true; 
				end }
		}
	}
	clock1:execute(3);

	print("Ready!!!")
	assert_true(true)
end

functionList = {
	[1] = "test_Timer",
	[2] = "test_OneTimerOneEventAndOneMessage",
	[3] = "test_DifferentEventPriorities"
}

SKIPS = executeBasics("timer", functionList, skips)

lunatest.run()

os.exit(0)
