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
-- Author: Rodrigo Reis Pereira (rreisp@gmail.com)
-------------------------------------------------------------------------------------------
-- Expected result: 9 teste, 76 assertations, (9 passed, 0 failed, 0 erros)
-- 
--  In the DEBUG mode the tests result change. Maybe due to the different compiler optimization 
--  settings, the (/02) flag is incompatible with the DEBUG mode (/Zi). In the DEBUG mode, 
--  the optimization is disabled (/Od).  
--  Expected result: ? teste, ?? assertations, (3 passed, 2 failed, 3 erros)
-- 

arg=""
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/tests/run/run_util.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

-- ================================================================================#
-- DEFAULT PARAMETERS (REGULAR ASSIGNMENT FLOW (parameters table is empty))
--[[
defaultParameters = Legend {
type = "number",
minimum = 0,
maximum	= 10,
stdDeviation = "none",
grouping = "equalsteps",
slices = 4,
precision = 4,
colorBar = {{"white", ""},{"black",""}},
symbol = "�",
font = "Symbol",
fontSize = 12		
}
]]--

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do
	for j = 1, 5, 1 do
		mine = ""
		cv=""	
		if math.modf(i+j, 2) == 0 then 
			mine = false
			cv = "pasture"
		else
			mine= true
			cv = "forest"			 	
		end 	
		c = Cell{ cover = cv, height = i+j, isMine = mine , agents_ = {} }
		c.y = j - 1;
		c.x = i - 1;
		c.cont=i*j
		cs:add( c );
	end
end

-- ================================================================================#
-- DEFAULT PARAMETERS (REGULAR ASSIGNMENT FLOW (parameters table is empty))
defaultParameters = Legend {
	type = "number",
	minimum = 0,
	maximum	= 100,
	stdDeviation = "none",
	grouping = "equalsteps",
	slices = 2,
	precision = 4,
	colorBar = {{value = 0, color = "white"},{value = 100, color = "black"}},
	symbol = "®",
	font = "Symbol",
	fontSize = 12		
}

-- DEFAULT PARAMETERS (ALTERNATIVE ASSIGNMENT FLOW (parameters table is not empty))
terrameDefaultParameters = Legend {
	-- this attribute does not exist. It will force each default attribute to be defined individually in 'legend.lua' 	
	xxx = nil
}

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (NUMBER)
numberLegend = Legend { 
	type = "number", 
	grouping = "equalsteps", 
	slices = 2, 
	maximum = 100, 
	minimum = 0, 
	colorBar = {  
		{value = 0, color = "red"}, 
		{value = 100, color = "black"}
	}
}

terrameNumberLegend = Legend {
	type = "number"
}

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (BOOL)
boolLegend = Legend { 
	type = "bool", 
	grouping = "uniquevalue", 
	slices = 2, 
	maximum = 1, 
	minimum = 0, 
	colorBar = {  
		{value = false, color = "black"}, 
		{value = true, color = "white"}
	}
}

terrameBoolLegend = Legend {
	type = "bool"
}

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (TEXT)
textLegend = Legend { 
	type = "string", 
	grouping = "uniquevalue", 
	maximum = 100, 
	minimum = 0, 
	colorBar = {  
		{value = "BLACK", color = "black"}, 
		{value = "WHITE", color = "white"}
	}
}

terrameTextLegend = Legend {
	type = "string",
}

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (DATETIME)
dateTimeLegend = Legend { 
	type = "datetime",
	grouping = "equalsteps", 
	slices = 2, 
	maximum = 100, 
	minimum = 0, 
	colorBar = {  
		{value = "2012-01-01 00:00:00", color = "black"}, 
		{value = "2012-01-31 00:00:00", color = "white"}
	}
}

terrameDateTimeLegend = Legend {
	type = "datetime"
}

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (CellularSpace)
expectedLegends = Legend {
		type = "string", 
		grouping = "uniquevalue", 
		slices = 2, 
		maximum = 1, 
		minimum = 0, 
		colorBar = { {value = "YELLOW", color = "yellow"}, {value = "BLUE", color = "blue"} }	
}

expectedLegends2 = Legend {
		type = "bool", 
		grouping = "uniquevalue", 
		slices = 2, 
		maximum = 1, 
		minimum = 0, 
		colorBar = { {value = true, color = "green"}, {value = false, color = "red"} }
}

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Agent)
expectedLegend = Legend {
	type = "string",
	grouping = "uniquevalue",
	symbol = "qqwqqA",
	--symbol = 65,
	font = "Verdana",
	fontSize = 10,
	colorBar = {  
		{value = "GREEN", color = "green"}, 
		{value = "RED", color = "red"}
	}		
}

state1 = State {
	id = "walking",
	Jump {
		function( event, agent, cell )
			print(agent:getStateName());
			hungry = agent.energy < 300
			ag1.time = ag1.time + 1;
			ag1:notify(ag1.time);

			if (hungry) then
				agent.energy = agent.energy + 30
				return true
			end
			return false
		end,
		target = "sleeping"
	}
}

state2 = State {
	id = "sleeping",
	Jump {
		function( event, agent, cell )
			print(agent:getStateName());
			hungry = true
			ag1.time = ag1.time + 1;
			ag1:notify(ag1.time);

			if (not hungry) then
				agent.energy = 0
				return true
			end
			return false
		end,
		target = "walking"
	}
}

ag1 = Agent{
	id = "Ag1",
	energy  = 0,
	hungry = false,
	time = 0,
	state1,
	state2
}
cs:notify()
cell = cs.cells[1]
ag1:enter(cell)

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Automaton)
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

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Trajectory)
mim = 0
max = 9
start = 10

down = 1
up = 2
left = 3
right = 4

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

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Neighborhood)
cs1 = CellularSpace{xdim = 20}

forEachCell(
	cs1,
	function(cell)
		cell.dist_roads = 10 * (cell.x * cell.y)/(cell.x + cell.y)
	end
)

cs1:createNeighborhood{ name = "Moore_test1", strategy = "moore", self = false }

local maxWeight = 0;
local minWeight = math.huge;
local maxDist = 0;
local minDist = math.huge;

forEachCell(
	  cs1,
	  function(cell)
		
		  if(cell.dist_roads > maxDist)then
			  maxDist = cell.dist_roads;
		  end	
		  if(cell.dist_roads < minDist)then
			  minDist = cell.dist_roads;
		  end
		
		  forEachNeighbor(
			  cell, 
			  "Moore_test1",
			  function(cell, neigh, weight)
				  if(weight > maxWeight)then
					  maxWeight = weight;
				  end
				  if(weight < minWeight)then
					  minWeight = weight;
				  end
			  end
		  )
	   end
)

cs1:notify()

obsNeigh = nil

-- ================================================================================#
-- DATABASE LEGEND RETRIEVAL

dbExpectedLegend = Legend {
	type="number",
	stdDeviation=-1,
	slices=10,
	maximum=3.4e-37,
	minimum=3.4e+37,
	symbol="@",
	fontSize=12,
	font="Symbol",
	--colorBar="0 255 240 @ 0.00 ! ;1 0 240 @ 1.00 ! ;",
	--colorBar= { {{0 255 240} 0.00}, {{1 0 240} 1.00} },
	--colorBar = { {"green" 0.00}, {"red" 1.00} },
	colorBar = { {color = "green"}, {color = "red"} },
	precision=6,
	grouping=0
}

databaseLegend = Legend {
	type = "string",
	grouping = "uniquevalue",
	symbol = "qqwqqA",
	--symbol = 65,
	font = "Verdana",
	fontSize = 10,
	colorBar = {  
		{color = "green"},
		{color = "red"}
	}		
}

-- ================================================================================#
-- LOAD LEGEND FROM DATABASE

local dbms = 0
local pwd = "terralab0705"

local HEIGHT = "height_"
local cs2 = nil

cs2 = CellularSpace{
	dbType = "mysql",
	host = "127.0.0.1",
	database = "cabeca",
	user = "root",
	password = pwd,
	theme = "cells90x90"
}

local leg = cs2.legend

-- ================================================================================#
-- COLOR BAR ELEMENT ORDERING

--verificar de variaveis n existem--
VERMELHO = 1
PRETO = 2
VAZIO = 3
dim = 20
cs3 = CellularSpace{xdim = dim, ydim = dim}
cs4 = CellularSpace{xdim = dim, ydim = dim}

function coloreCelula(cell)
	if cell.x == cell.y then
		cell.color = VERMELHO
	elseif cell.x + cell.y == dim - 1 then 
		cell.color = PRETO
	else
		cell.color = VAZIO
	end
end

forEachCell(cs3, coloreCelula)
forEachCell(cs4, coloreCelula)

leg = Legend{
	grouping = "uniquevalue",
	colorBar = {
		{value = 1, color = "red"},
		{value = 2, color = "black"},
		{value = 3, color = "white"}
	}
}

leg2 = Legend{
	grouping = "uniquevalue",
	colorBar = {
		{value = 3, color = "white"},
		{value = 1, color = "red"},
		{value = 2, color = "black"}	
	}
}

--Legendas com erros para serem testadas--
leg3 = Legend{
	grouping = "uniquevalue",
	colorBar = {
		{value = 3, color = "white"},
		{value = 1, color = "red"},
		{value = 2, color = "black"}	
	}
}

leg4 = Legend{
	grouping = "uniquevalue",
	colorBar = {
		{value = 3, color = "white"},
		{value = 1, color = "red"},
		{value = 2, color = "black"}	
	}
}

--------------------------------------------------------------
legFor = function (killObservers,unitTest) 
	for i = 1, 10, 1 do
		print("STEP: ", i);
		forEachCell(cs,function(cell)
			cell.defaultParameters = i
		end)

		if ((killObserver and observerDefault10) and (i == 8)) then
			print("", "observerDefault10:kill", observerDefault10:kill())
		end
		delay_s(1)
	end
	unitTest:assert_true(true)
end

local observerLeg = UnitTest {
	test_leg01 = function(unitTest)
		print("OBSERVER LEGEND 01")
		print("Testing Default Parameters (regular assignment flow)")
		observerLeg01 = Observer{subject = cs,type = "map", attributes = {"cover"}, legends = {defaultParameters}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg01.type)
	end,

	test_leg02 = function(unitTest)
		print("OBSERVER LEGEND 02")
		print("Testing Default Parameters (alternative assignment flow)") io.flush() 	
		observerLeg02 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {terrameDefaultParameters}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg02.type)
	end,

	test_leg03 = function(unitTest)
		print("OBSERVER LEGEND 03")
		print("Testing Automatic Number Legend 01") io.flush() 	
		observerLeg03 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {numberLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg03.type)
	end,	
	test_leg04 = function(unitTest)
		print("OBSERVER LEGEND 04")
		print("Testing Automatic Number Legend 02") io.flush() 	
		observerLeg04 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {terrameNumberLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg04.type)
	end,

	test_leg05 = function(unitTest)
		print("OBSERVER LEGEND 05")
		print("Testing Automatic Bool Legend 01") io.flush() 	
		observerLeg05 = Observer{subject = cs, type = "map", attributes = {"height"}, legends = {boolLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg05.type)
	end,
	test_leg06 = function(unitTest)
		print("OBSERVER LEGEND 06")
		print("Testing Automatic Bool Legend 02") io.flush() 	
		observerLeg06 = Observer{subject = cs, type = "map", attributes = {"height"}, legends = {terrameBoolLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg06.type)
	end,

	test_leg07 = function(unitTest)
		print("OBSERVER LEGEND 07")
		print("Testing Automatic Text Legend 01") io.flush() 	
		observerLeg07 = Observer{subject = cs, type = "map", attributes = {"height"}, legends = {textLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg07.type)
	end,
	test_leg08 = function(unitTest)
		print("OBSERVER LEGEND 08")
		print("Testing Automatic Text Legend 02") io.flush() 	
		observerLeg08 = Observer{subject = cs, type = "map", attributes = {"height"}, legends = {terrameTextLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg08.type)
	end,
	
	test_leg09 = function(unitTest)
		print("OBSERVER LEGEND 09")
		print("Testing Automatic DateTime Legend 01") io.flush()
		observerLeg09 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {dataTimeLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg09.type)
	end,
	test_leg10 = function(unitTest)
		print("OBSERVER LEGEND 10")
		print("Testing Automatic DateTime Legend 02") io.flush() 	
		observerLeg10 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {terrameDataTimeLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg10.type)
	end,

	test_leg11 = function(unitTest)
		print("OBSERVER LEGEND 11")
		print("Testing Automatic CellularSpace ColorBar 01") io.flush() 	
		observerLeg11 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {expectedLegends}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg11.type)
	end,
	test_leg12 = function(unitTest)
		print("OBSERVER LEGEND 12")
		print("Testing Automatic CellularSpace ColorBar 02") io.flush() 	
		observerLeg12 = Observer{subject = cs, type = "map", attributes = {"cover"}, legends = {expectedLegends2}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg12.type)
	end,

	test_leg13 = function(unitTest)
		print("OBSERVER LEGEND 13")
		print("Testing Automatic Agent ColorBar") io.flush() 
		observerLegCs = Observer{ subject = cs, type = "map", attributes={"cover","isMine"}, legends = {expectedLegend} , prefix = "csimage_"}
		observerLeg13 = Observer{ subject = ag1, type = "map", attributes={"currentState"}, legends={expectedLegend}, cellspace = cs, observer = observerLegCs}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg13.type)
	end,

	test_leg14 = function(unitTest)
		print("OBSERVER LEGEND 14")
		print("Testing Automatic Automaton ColorBar") io.flush() 	
		observerLegCs = Observer{ subject = cs, type = "map", attributes={"cover","isMine"}, legends = {defaultParameters} , prefix = "csimage_"}	
		observerLeg14 = Observer{ subject = at1, type = "map", attributes={"currentState"}, legends={defaultParameters}, cellspace = cs, observer = observerLegCs}
	
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg14.type)
	end,

	test_leg15 = function(unitTest)
		print("OBSERVER LEGEND 15")
		print("Testing Automatic Trajectory ColorBar") io.flush() 	
		observerLegCs = Observer{ subject = cs, type = "map", attributes={"cover","height"}, legends = {defaultParameters} , prefix = "csimage_"}
		observerLeg15 = Observer{ subject = tr1, type = "map", attributes={"currentState"}, legends={defaultParameters}, cellspace = cs, observer = observerLegCs}
	
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg15.type)
	end,

	test_leg16 = function(unitTest)
		print("OBSERVER LEGEND 16")
		print("Testing Automatic Neighborhood ColorBar") io.flush() 	
		observerLegCs = Observer{ subject = cs, type = "map", attributes={"isMine","height"}, legends = {defaultParameters} , prefix = "csimage_"}
		observerLeg16 = Observer{ subject = cs1, type = "map", attributes={"dist_roads"}, legends={defaultParameters}, cellspace = cs, observer = observerLegCs}
	
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg16.type)
	end,

	test_leg17 = function(unitTest)
		print("OBSERVER LEGEND 17")
		print("Testing Database Legend Retrieval 01") io.flush() 		
		observerLeg17 = Observer{subject = cs3, type = "map", attributes = {"color"}, legends = {dbExpectedLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg17.type)
	end,
	test_leg18 = function(unitTest)
		print("OBSERVER LEGEND 18")
		print("Testing Database Legend Retrieval 02") io.flush() 		
		observerLeg18 = Observer{subject = cs3, type = "map", attributes = {"color"}, legends = {databaseLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg18.type)
	end,

	test_leg19 = function(unitTest)
		print("OBSERVER LEGEND 19")
		print("Testing Load Legend From Database") io.flush() 		

		observerLeg19 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {databaseLegend}}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg19.type)
	end,

	test_leg20 = function(unitTest)
		print("OBSERVER LEGEND 20")
		print("Testing Color Bar Element Ordering 01") io.flush() 		
		observerLeg20 = Observer{subject = cs3, type = "map", attributes = {"color"}, legends = {leg}, prefix = "image1_"}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg20.type)
	end,
	test_leg21 = function(unitTest)
		print("OBSERVER LEGEND 21")
		print("Testing Color Bar Element Ordering 02") io.flush() 		
		observerLeg21 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {leg2}, prefix = "image2_"}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg21.type)
	end,
--testam o tipo de legenda se for declarado errado
	test_leg22 = function(unitTest)
 
		print("OBSERVER LEGEND 22")
		print("Testing Color Bar Element Ordering if error") io.flush() 		
		observerLeg22 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {leg3}, prefix = "image2_"}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg22.type)
	end,

	test_leg23 = function(unitTest)
 
		print("OBSERVER LEGEND 23")
		print("Testing Color Bar Element Ordering if error") io.flush() 		
		observerLeg23 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {leg4}, prefix = "image2_"}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg23.type)
	end,

	test_leg24 = function(unitTest) 
		print("OBSERVER LEGEND 24")
		print("Testing Color Bar Element Ordering if error") io.flush() 		
    leg5 = Legend {
	    type = "strings",
	    grouping = "uniquevalue",
	    symbol = "qqwqqA",
	    --symbol = 65,
	    font = "Verdanas",
	    fontSize = 10,
	    colorBar = {  
		    {value = "GREEN", color = "green"}, 
		    {value = "RED", color = "red"}
	    }		
    }
		observerLeg24 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {leg5}, prefix = "image2_"}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg24.type)
	end,

	test_leg25 = function(unitTest) 
		print("OBSERVER LEGEND 25")
		print("Testing Color Bar Element Ordering if error") io.flush()
    local leg6 = Legend {
	    type = "string",
	    grouping = "uniquevalue",
	    symbol = "qqwqqA",
	    --symbol = 65,
	    font = "Verdana",
	    fontSize = 10,
	    colorBar = {  
		    {color = "green", value = "GREEN"}, 
		    {color = "red", value = "RED"}
	    }		
    } 		
		observerLeg25 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {leg6}, prefix = "image2_"}
		legFor(false,unitTest)
		unitTest:assert_equal("map",observerLeg25.type)
	end,

  test_leg26 = function(unitTest)
		print("OBSERVER LEGEND 26")
		print("Testing Attribute Suggestion Due Syntax Errors") io.flush()
    local legErr = Legend {
	    atype = "number",
	    aminimum = 0,
	    amaximum	= 100,
	    astdDeviation = "none",
	    agrouping = "equalsteps",
	    aslices = 2,
	    aprecision = 4,
	    acolorBar = {{value = 0, color = "white"},{value = 100, color = "black"}},
	    asymbol = "®",
	    afont = "Symbol",
	    afontSize = 12		
  }
		observerLeg26 = Observer{subject = cs4, type = "map", attributes = {"color"}, legends = {legErr}, prefix = "image2_"}
		unitTest:assert_true(true)
  end
}

observerLeg:run()
os.exit(0)
