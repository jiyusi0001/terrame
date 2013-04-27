-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2007 INPE and TerraLAB/UFOP.
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

function test_agent_observer()
	print("Test Agent TME_OBSERVERS...")

	state1 = State{
		id = "first",
		Jump{function(event, agent, cell)
			if (agent.cont < 10) then
			-- if (agent.cont % 2 == 0) and (agent.cont < 10)then 
				print("Ev: "..event:getTime(), "- Ag:fst: "..agent.id..": "..agent.cont, agent.temperatura)
				-- ag1:notify(event:getTime())
				t:notify(event:getTime())
				agent.cont = agent.cont + 1
				agent.temperatura = agent.temperatura + 2
				return true
			end
			return false
		end, target = "second"}
	}
	
	state2 = State{
		id = "second",
		Jump{function(event, agent, cell)
			if (agent.cont < 10) then
				print("Ev: "..event:getTime(), "- Ag:scd: "..agent.id..": "..agent.cont, agent.temperatura)
				t:notify(event:getTime())
				ag1:notify(event:getTime())
				agent.cont = agent.cont + 1
				agent.temperatura = agent.temperatura
				return true
			end
			return false
		end,
		target = "first"
		}
	}

	print("----------------------")
	print("ag1", ag1)
	print("state1", state1)
	print("state2", state2)
	print("----------------------")

	ag1 = Agent{
		id = "MyAgent",
		cont = 0,
		temperatura = 10,
		state1,
		state2
	}	
	
	env = Environment{ 
		id = "MyEnvironment"
	}
	
	t = Timer{
		Event{ time = 0, action = function(event) ag1.cont = 0; ag1:execute(event) return true end }
	}
	
	-- insert CellularSpaces before Automata, Agents and Timers
	env:add(ag1)
	env:add(t)

	--- Observers

	obsTable = Observer{ subject = ag1, type = "table", attributes={"cont","temperatura"}}
	obsGraph = Observer{ subject = ag1, type = "chart",attributes={"temperatura"}, xAxis="cont", title="cont x temperatura"}
	obsDGraph1 = Observer{ subject = ag1, type = "chart",attributes={"cont"},title="cont x tempo", curveTitle="?",xLabel="?",yLabel="?"}
	obsDGraph2 = Observer{ subject = ag1, type = "chart",attributes={"temperatura"},title="temperatura", curveTitle="temperatura x tempo",xLabel="tempo",yLabel="temperatura"}

	obsDGraph3 = Observer{ subject = ag1, type = "chart",attributes={"cont"},title="cont", curveTitle="cont x tempo",xLabel="tempo",yLabel="cont"}
	obsDGraph4 = Observer{ subject = ag1, type = "textscreen",attributes={"cont", "temperatura", "currentState"}}
	obsLog = Observer{ subject = ag1, type = "logfile", attributes={}, outfile = "agent.csv"}

	ag1:notify()

	obsSchd = Observer{ subject = t, type = "scheduler"}	
	t:notify()

	env:execute( 10 )
end

test_agent_observer()

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
