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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

mim = 0
max = 9
start = 10

cs = CellularSpace{ xdim = 0}

for i = 1, 10, 1 do 
	for j = 1, 10, 1 do 
		c = Cell{ cover = AGUA,agents_ = {}}
		c.height_ = i
		c.path = 0
		c.x = i - 1
		c.y = j - 1
		c.cont=i*j
		c.cover = 1
		cs:add( c )
	end
end

tr1 = Trajectory{
	target = cs,
	select = function(cell)
		if((cell.cont <= max+1 and cell.cont > mim+1) and cell.x==mim) then
			cell.path = up
			return true
		end
		if((cell.cont <= max and cell.cont > mim) and cell.y==mim) then
			cell.path = right
			return true
		end
		if((cell.cont >= max and cell.cont <= max*max+2*max+1) and cell.x == max) then
			cell.path = down
			return true
		end
		return false
	end,
	sort = function(a,b)
		if(a.path == right) then	
			return a.x<b.x 
		elseif(a.path == left) then	
			return a.x>b.x 
		elseif(a.path == down) then
			return a.y<b.y;	
		elseif(a.path == up) then
			return a.y>b.y
		end
	end,
	valor1 = 1,
	valor2 = 1,
	t = 0
}

logFileFor = function(killObserver,unitTest)
	for i = 1, 10, 1 do
		print("STEP:",i)io.flush()
		tr1:notify(i)
		tr1.valor1 = tr1.valor1*i
		tr1.valor2 = 1/tr1.valor2*i
		tr1.t = i*2
		if ((killObserver and observerLogFile05) and (i == 8)) then
			print("", "observerLogFile05:kill", observerLogFile05:kill())io.flush()
		end
		delay_s(1)
	end
	unitTest:assert_true(true)
end

local observersLogFileTest = UnitTest {
	test_logFile01 = function(unitTest)
		-- OBSERVER LOGFILE 01
		print("OBSERVER LOGFILE 01") io.flush()
		observerLogFile01 = Observer{subject = tr1, type = "logfile"}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile01.type)
	end,
	test_logFile02 = function(unitTest)
		-- OBSERVER LOGFILE 02
		print("OBSERVER LOGFILE 02") io.flush()
		observerLogFile02 = Observer{subject = tr1, type = "logfile", attributes={}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,
	test_logFile03 = function(unitTest)
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03") io.flush()
		observerLogFile03 = Observer{subject = tr1, type = "logfile", attributes ={},outfile = "logfile.csv", separator=","}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,
	test_logFile04 = function(unitTest)
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04") io.flush()
		observerLogFile04 = Observer{subject = tr1, type = "logfile", attributes={"valor1","valor2"}}
		logFileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,
	test_logFile05 = function(unitTest)
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05")io.flush()
		observerLogFile05 = Observer{ subject = tr1, type = "logfile", attributes={}}
		logFileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_logFile06 = function(unitTest)
		-- OBSERVER LOGFILE 06
		print("OBSERVER LOGFILE 06")io.flush()
		observerLogFile06 = Observer{ subject = tr1, type = "logfile", attributes={},outfile = TME_ImagePath.."/result.csv"}
		logFileFor(false,unitTest)
		
	    moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."trajectory"..TME_DIR_SEPARATOR.."test_logFile"..TME_DIR_SEPARATOR.."test_logFile06",".csv")
	    
	    
	    if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/result.csv".. " > /dev/null 2>&1 ")
	    else
		    --@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end
        
        os.capture("rm "..TME_ImagePath.."/result.csv")
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end
}

-- TESTES OBSERVER LOGFILE
--[[

LOGFILE 01 / LOGFILE 02 / LOGFILE 05 
Programa deverá criar um 'observer' do tipo 'logfile'.

LOGFILE 03
Idem LOGFILE 01, mas com o 'logfile.csv' do tipo 'outfile'.

LOGFILE 04
Idem LOGFILE 01, mas com dois atributos, 'valor1' e 'valor2'.

LOGFILE 05
ToDo.

LOGFILE 06
ToDo.

]]

observersLogFileTest:run()
os.exit(0)
