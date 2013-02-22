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

function test_timer_observer()

	local tbAttribTb = {} 
	local tbParamTb = {"Attributes", "Values"}
	
	event1 = Event{time = 0,   period = 1,  priority = 1, action = function(event)
			clock1:notify();
			event1:notify();
			print("clock1: ", clock1:getTime());
			for i = 1,4000000 do end
			print("Message1: "..event:getTime())
	end}
		

	clock1 = Timer{
		id = "clock1",
		event2 = Event{time = 20, period = 25, priority = 10, action = function() end},
		event3 = Event{time = 20, period = 75, priority = 5,  action = function() end},
		event4 = Event{time = 20, period = 50, priority = 2,  action = function() end},
		event1
	}

	obsText = Observer{ subject = clock1, type = "textscreen"}
	obsLog = Observer{ subject = clock1, type = "logfile"}
	obsTable = Observer{ subject = clock1, type = "table"}
	obsSch = Observer{ subject = clock1, type = "scheduler"}

	obsEventText = Observer{ subject = event1, type = "textscreen"}
	obsEventLog = Observer{ subject = event1, type = "logfile"}
	obsEventTable = Observer{ subject = event1, type = "table"}
	
	clock1:execute(100)
	clock1:notify()
end

test_timer_observer()

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)

