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

soilWaterLeg = Legend{
	type = "number",
	grouping = "equalsteps",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 100,
	minimum = 0,
	colorBar = {
		{color = "green", value = 0},
		{color = "blue", value = 100}
	}
}

currentStateLeg = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "brown", value = "first"},
		{color = "yellow", value = "second"}
	}
}

function test_automaton_observer()
	print("Testing Automaton TME_OBSERVERS.* ")
	
	cs = CellularSpace{ xdim = 0}
	for i = 1, 2, 1 do 
		c = Cell{ soilType = i }
		c.x = i-1;
		c.y = i-1;
		cs:add( c );
	end
	obsMap = Observer{ subject = cs, type = "map", attributes = {"soilType"},legends = { soilWaterLeg} }
	
	state1 = State{
		id = "first",
		Jump{
			function( event, agent, cell )
				if (agent.cont < 10) then 
					agent.cont = agent.cont + 1;
					print("Ev: "..event:getTime(), "- Ag:"..agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."] - currentState: ", cell:getStateName(at1))
					print("currentState: ", cell:getStateName(at1))
					at1:notify(event:getTime());
					t:notify();
					return true
				end
				if( agent.cont == 10 ) then agent.cont = 0 end
				return false
			end,
			target = "second" 
		}
	}

	state2 = State{
		id = "second",
		Jump{
			function( event, agent, cell )
				if (agent.cont < 10) then 
					agent.cont = agent.cont + 1;
					print("Ev: "..event:getTime(), "- Ag:"..agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."] - currentState: ", cell:getStateName(at1))
					at1:notify(event:getTime());
					t:notify();
					return true
				end
				if( agent.cont == 10 ) then agent.cont = 0 end
				return false
			end, 
			target = "first"
		}
	}
	
	at1 = Automaton{
		id = "MyAutomaton",
		it = Trajectory{
			target = cs, 
			select = function( cell ) return true; end
		},
		cont  = 0,
		temperatura = 10,
		state1,
		state2
	}
	
	print("----------------------")
	print("at1", at1)
	print("state1", state1)
	print("state2", state2)
	print("----------------------")
	
	middle = math.floor(#cs.cells/2)
	cell = cs.cells[middle]

	print( "Automaton... ");
	env = Environment{
		id = "MyEnvironment"
	}
	
	t = Timer{
		Event{ time = 0, action = function(event) at1:execute(event); cs:notify() return true end }
	}
		
	-- insert CellularSpaces before Automata, Agents and Timers
	env:add( cs )
	env:add( at1 )
	env:add( t )
	at1:setTrajectoryStatus( true )

	--- Observers
	obsText = Observer{ subject = at1, type = "textscreen", location =cell }
	obsTable = Observer{ subject = at1, type = "table", location =cell }
	obsLog = Observer{ subject = at1, type = "logfile", location =cell }
	obsChart = Observer{ subject = at1, type = "chart",attributes={"currentState"}, title="GraphicTitle", curveLabel="CurveTitle", yLabel="YLabel", location=cell}
	obsState = Observer{subject=at1, type = "statemachine",legends={currentStateLeg}, location=cell}
	obsAutMap =  Observer{ subject = at1, type = "map", attributes={"currentState"},cellspace = cs, observer = obsMap,legends = {currentStateLeg} }

	at1:notify();
	
	obsTimer = Observer{ subject = t, type = "scheduler"} 	
	at1:notify()
	t:notify()
	
	env:execute( 10 )
end

test_automaton_observer()

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
