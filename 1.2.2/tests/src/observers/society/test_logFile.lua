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
		sc1:notify()
		sc1.cont = 0
		sc1:execute(ev)
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

cs = CellularSpace {
	xdim = 10
	-- -- xdim = 3,
	--cover = "pasture"
}

ev = Event{ time = 1, period = 1, priority = 1 }
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		
		cs:add( c )
	end
end
t = Timer{
	Event{ time = 0, action = function(event) sc1:execute(event) return true end }
}

sleeping = State {
	id = "sleeping",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 0) then
				return true
			end
			--print("T:", event:getTime())
			--print("-- sleeping")
			return false
		end,
		target = "foraging"
	}
}

foraging = State {
	id = "foraging",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 1) then
				return true
			end
			--print("T:", event:getTime())
			--print("-- foraging")
			return false
		end,
		target = "sleeping"
	}
}
boi = function(i)
	ag = {energy = 20, type = "boi", foraging, sleeping}
	ag.getIn = function(ag, cs)
		cell = cs:sample()
		ag:enter(cell)
	end
	ag.class = "Rebanho"
  	ag.testValue = 55
	ag_ = Agent(ag)
	coord = Coord {x=i-1, y=i-1}
	cc = cs:getCell(coord)
	ag_:enter(cc)

	return ag_
end

sc1 = Society {
	instance = boi(1),
	state = "x",
	--st2 = foraging,
	--st1 = sleeping,
	acum = 0,
	currentState = 0
}

boi1 = boi(1)
boi2 = boi(2)
boi3 = boi(3)
boi4 = boi(4)
boi5 = boi(5)
boi6 = boi(6)
boi7 = boi(7)
boi8 = boi(8)
boi9 = boi(9)
boi10 = boi(10)

bois = {boi1, boi2, boi3, boi4, boi5, boi6, boi7, boi8, boi9, boi10}

sc1:add(boi1)
sc1:add(boi2)
sc1:add(boi3)
sc1:add(boi4)
sc1:add(boi5)

updateFunc = nil

e = Environment{cs, sc1}
e:createPlacement{strategy = "random"}

local observersLogFileTest = UnitTest {
	test_logFile01 = function(unitTest)
		-- OBSERVER LOGFILE 01 
		print("OBSERVER LOGFILE 01") io.flush()
		observerLogFile01 = Observer{ subject = sc1, type = "logfile" }
		logFileFor(false,unitTest)  
		unitTest:assert_equal("logfile",observerLogFile01.type)  
	end,

	test_logFile02 = function(unitTest)
		-- OBSERVER LOGFILE 02 
		print("OBSERVER LOGFILE 02") io.flush()
		observerLogFile02 = Observer{ subject = sc1, type = "logfile", attributes={} }
		logFileFor(false,unitTest)  
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,

	test_logFile03 = function(unitTest)
		-- OBSERVER LOGFILE 03 
		print("OBSERVER LOGFILE 03") io.flush()
		observerLogFile03 = Observer{ subject = sc1, type = "logfile", attributes={} }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,

	test_logFile04 = function(unitTest)
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04") io.flush()
		observerLogFile04 = Observer{ subject = sc1, type = "logfile", attributes={},location=cell }
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,

	test_logFile05 = function(unitTest)
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05") io.flush()
		observerLogFile05 = Observer{ subject = sc1, type = "logfile", attributes={"currentState","acum"},location=cell}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_logFile06 = function(unitTest)
		-- OBSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06") io.flush()
		observerLogFile06 = Observer{subject = sc1, type="logfile", location=cell, outfile="logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end,
	
	test_logFile07 = function(unitTest)
		-- OBSERVER LOGFILE 07
		print("OBSERVER LOGFILE 07") io.flush()
		observerLogFile07 = Observer{subject = sc1, type="logfile", location=cell, outfile="logfile.csv", separator=","}
		logFileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile07.type)
	end,

    test_logFile08 = function(unitTest)
		-- OBSERVER LOGFILE 08
		print("OBSERVER LOGFILE 08") io.flush()
		observerLogFile08 = Observer{subject = sc1, type="logfile", location=cell, outfile = TME_ImagePath.."/result.csv"}
		logFileFor(false,unitTest)
		moveFilesToResults(TME_ImagePath,TME_PATH.."/bin/results/observers/society/test_logFile/test_logFile08",".csv")
        os.capture("rm "..TME_ImagePath.."/result.csv")
		unitTest:assert_equal("logfile",observerLogFile08.type)
	end
}

-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01
Programa criará um 'observerLogFile' que recebe 'Observer' do tipo 'logfile', sem atributos.

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
