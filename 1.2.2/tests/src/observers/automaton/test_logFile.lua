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
--			Henrique Cota Camêllo
--			Washington Sena França e Silva
-------------------------------------------------------------------------------------------
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

logFileFor = function(killObserver,unitTest)
	for i=1, 10 , 1 do
		print("STEP: ", i) io.flush()
		at1:notify()
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)

		if ((killObserver and observerLogFile07) and (i == 8)) then
			print("", "observerLogFile07:kill", observerLogFile07:kill())
		end

		delay_s(1)
	end
	unitTest:assert_true(true) 
end

MAX_COUNT = 9

cs = CellularSpace{ xdim = 0}
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
	end
end

state1 = State{
	id = "seco",
	Jump{
		function( event, agent, cell )
			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end,
		target = "molhado"
	}
}

state2 = State{
	id = "molhado",
	Jump{
		function( event, agent, cell )

			agent.acum = agent.acum+1
			if (agent.cont < MAX_COUNT) then 
				agent.cont = agent.cont + 1
				return true
			end
			if( agent.cont == MAX_COUNT ) then agent.cont = 0 end
			return false
		end, 
		target = "seco"
	}
}

at1 = Automaton{
	id = "MyAutomaton",
	it = Trajectory{
		target = cs, 
		select = function(cell)
			local x = cell.x - 5;
			local y = cell.y - 5;
			return (x*x) + (y*y)  - 16 < 0.1
		end
	},
	acum = 0,
	cont  = 0,
	curve = 0,-- uma curva para o observer chart
	st2 = state2,
	st1 = state1,
}

env = Environment{ 
	id = "MyEnvironment"
}

t = Timer{
	Event{ time = 0, action = function(event) at1:execute(event) return true end }
}
-- insert CellularSpaces before Automata, Agents and Timers
env:add( cs )
env:add( at1 )

ev = Event{ time = 1, period = 1, priority = 1 }

at1:setTrajectoryStatus( true )

-- Enables kill an observer
killObserver = false

middle = math.floor(#cs.cells/2)
cell = cs.cells[middle]


local observersLogFileTest = UnitTest {
	test_logFile01 = function(unitTest)
		-- OBSERVER LOGFILE 01 
		print("OBSERVER LOGFILE 01") io.flush()
		observerLogFile01 = Observer{ subject = at1, type = "logfile" }
		logFileFor(false,unitTest)  
		unitTest:assert_equal("logfile",observerLogFile01.type)  
	end,

	test_logFile02 = function(unitTest)
		-- OBSERVER LOGFILE 02 
		print("OBSERVER LOGFILE 02") io.flush()
		observerLogFile02 = Observer{ subject = at1, type = "logfile", attributes={} }
		logFileFor(false,unitTest)  
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,

	test_logFile03 = function(unitTest)
		-- OBSERVER LOGFILE 03 
		print("OBSERVER LOGFILE 03") io.flush()
		observerLogFile03 = Observer{ subject = at1, type = "logfile", attributes={} }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,

	test_logFile04 = function(unitTest)
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04") io.flush()
		--@DEPRECATED
		--at1:createObserver( "logfile", {},{cell} )
		observerLogFile04 = Observer{ subject = at1, type = "logfile", attributes={},location=cell }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,

	test_logFile05 = function(unitTest)
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05") io.flush()
		observerLogFile05 = Observer{ subject = at1, type = "logfile", attributes={"currentState","acum"},location=cell}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_logFile06 = function(unitTest)
		-- OBSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06") io.flush()
		observerLogFile06 = Observer{subject = at1, type="logfile", location=cell, outfile="logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end,
	
	test_logFile07 = function(unitTest)
		-- OBSERVER LOGFILE 07
		print("OBSERVER LOGFILE 07") io.flush()
		observerLogFile07 = Observer{subject = at1, type="logfile", location=cell, outfile="logfile.csv", separator=","}
		logFileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile07.type)
	end,
	
	test_logFile08 = function(unitTest)
		-- OBSERVER LOGFILE 08
		print("OBSERVER LOGFILE 08") io.flush()
		observerLogFile08 = Observer{subject = at1, type="logfile", location=cell, outfile = TME_ImagePath.."/result.csv"}
		logFileFor(false,unitTest)
		
		moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."automaton"..TME_DIR_SEPARATOR.."test_logFile"..TME_DIR_SEPARATOR.."test_logFile08",".csv")
	    
	    
	    if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/result.csv".. " > /dev/null 2>&1 ")
	    else
		    --@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end
        
        
		unitTest:assert_equal("logfile",observerLogFile08.type)
	end
}

-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01
Programa não será executado, pois para obsercar um autômato é requerido um parâmetro 'localização' para que seja uma célula, sendo assim ocorrerá um erro.

LOGFILE 02
Idem LOGFILE 01.

LOGFILE 03
Idem LOGFILE 01.

LOGFILE 04
Programa criará um 'observerLogFile' que recebe 'Observer' do tipo 'logfile', sem atributos e com localização de cada célula.

LOGFILE 05
Idem LOGFILE 04.

LOGFILE 06
Idem LOGFILE 04.

LOGFILE 07
Idem LOGFILE 04, mas com a mudança de que o objeto será apagado antes do fim da execução.
]]

observersLogFileTest:run()
os.exit(0)
