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
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

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

defaultParameters = Legend {
	type = "number",
	minimum = 0,
	maximum	= 100,
	stdDeviation = "none",
	grouping = "equalsteps",
	slices = 2,
	precision = 4,
	colorBar = {{color = "white", value = 0},{color = "black", value = 100}},
	symbol = "®",
	font = "Symbol",
	fontSize = 12		
}

function test_DefaultParameters()
	if (SKIPS[1]) then
		skip("No testing...") io.flush() --  121312 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	print("Testing Default Parameters (regular assignment flow)") io.flush() 	

	for key,value in pairs(defaultParameters) do
		assert_equal(terrameDefaultParameters[key],value)
	end

end


-- ================================================================================#
-- DEFAULT PARAMETERS (ALTERNATIVE ASSIGNMENT FLOW (parameters table is not empty))
terrameDefaultParameters = Legend {
	-- this attribute does not exist. It will force each default attribute to be defined individually in 'legend.lua' 	
	xxx = nil
}

function test_AlternativeDefaultParameters()
	if (SKIPS[2]) then
		skip("No testing...") io.flush() --  121312 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	print("Testing Default Parameters (alternative assignment flow)") io.flush() 	

	for key,value in pairs(defaultParameters) do
		assert_equal(terrameDefaultParameters[key],value)
	end

end

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (NUMBER)
numberLegend = Legend { 
	type = "number", 
	grouping = "equalsteps", 
	slices = 2, 
	maximum = 100, 
	minimum = 0, 
	colorBar = {  
		{color = "red", value = 0}, 
		{color = "black", value = 100}
	}
}

terrameNumberLegend = Legend {
	type = "number"
}

function test_AutomaticNumberLegend()
	if (SKIPS[3]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Number Legend")
	for key,value in pairs(numberLegend) do
		assert_equal(terrameNumberLegend[key],value)
	end

end

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (BOOL)
boolLegend = Legend { 
	type = "bool", 
	grouping = "uniquevalue", 
	slices = 2, 
	maximum = 1, 
	minimum = 0, 
	colorBar = {  
		{color = "black", value = false}, 
		{color = "white", value = true}
	}
}

terrameBoolLegend = Legend {
	type = "bool"
}

function test_AutomaticBoolLegend()
	if (SKIPS[4]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Bool Legend")
	for key,value in pairs(boolLegend) do
		assert_equal(terrameBoolLegend[key],value)
	end

end

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (TEXT)
textLegend = Legend { 
	type = "string", 
	grouping = "uniquevalue", 
	maximum = 100, 
	minimum = 0, 
	colorBar = {  
		{color = "black", value = "BLACK"}, 
		{color = "white", value = "WHITE"}
	}
}

terrameTextLegend = Legend {
	type = "string",
}

function test_AutomaticTextLegend()
	if (SKIPS[5]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Text Legend")
	for key,value in pairs(textLegend) do
		assert_equal(terrameTextLegend[key],value)
	end

end

-- ================================================================================#
-- AUTOMATIC PARAMETER INFERENCES (DATETIME)
dateTimeLegend = Legend { 
	type = "datetime",
	grouping = "equalsteps", 
	slices = 2, 
	maximum = 100, 
	minimum = 0, 
	colorBar = {  
		{color = "black", value = "2012-01-01 00:00:00"}, 
		{color = "white", value = "2012-01-31 00:00:00"}
	}
}

terrameDateTimeLegend = Legend {
	type = "datetime"
}

function test_AutomaticDateTimeLegend()
	if (SKIPS[6]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic DateTime Legend")
	for key,value in pairs(dateTimeLegend) do
		assert_equal(terrameDateTimeLegend[key],value)
	end

end

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (CellularSpace)
cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do
	for j = 1, 5, 1 do
		mine = ""
		cv=""	
		if math.mod(i+j, 2) == 0 then 
			mine = false
			cv = "pasture"
		else
			mine= true
			cv = "forest"			 	
		end 	
		c = Cell{ cover = cv, height = i+j, isMine = mine , agents_ = {} }
		c.y = j - 1;
		c.x = i - 1;
		cs:add( c );
	end
end

--csObserverMap = Observer{ subject = cs, type = "map", attributes={"cover","height","isMine"}, legends = {} }
--csObserverMap = Observer{ subject = cs, type = "map", attributes={"height","isMine"}, legends = {} }
--csObserverMap = Observer{ subject = cs, type = "map", attributes={"cover","isMine"}, legends = {} }

expectedLegends = {
	Legend {
		type = "string", 
		grouping = "uniquevalue", 
		slices = 2, 
		maximum = 1, 
		minimum = 0, 
		colorBar = { {color = "yellow", value = "YELLOW"}, {color = "blue", value = "BLUE"} }
	},
	Legend {
		type = "bool", 
		grouping = "uniquevalue", 
		slices = 2, 
		maximum = 1, 
		minimum = 0, 
		colorBar = { {color = "green", value = true}, {color = "red", value = false} }
	}	
}

function test_AutomaticCellularSpaceColorBar()
	if (SKIPS[7]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic CellularSpace ColorBar")

	csObserverMap = Observer{ subject = cs, type = "map", attributes={"cover","isMine"}, legends = {} }

	for i=1,#csObserverMap.attributes,1 do
		for key,value in pairs(expectedLegends[i]) do
			--print(i,key,value,csObserverMap.legends[i][key])			
			assert_equal(value,csObserverMap.legends[i][key])
		end
	end

end

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
		{color = "green", value = "GREEN"}, 
		{color = "red", value = "RED"}
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


function test_AutomaticAgentColorBar()
	if (SKIPS[8]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Agent ColorBar")

	csObserverMap = Observer{ subject = cs, type = "map", attributes={"cover","isMine"}, legends = {} }
	agObserverMap = Observer{ subject=ag1, type = "map", attributes={"currentState"}, legends={}, cellspace = cs, observer = csObserverMap }


	for key,value in pairs(expectedLegend) do
	--assert_equal(value, agObserverMap.legends[1][key])
	end
	cs:notify()
end

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Automaton)
function test_AutomaticAutomatonColorBar()
	if (SKIPS[9]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Automaton ColorBar")


end

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Trajectory)
function test_AutomaticTrajectoryColorBar()
	if (SKIPS[10]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Trajectory ColorBar")


end

-- ================================================================================#
-- AUTOMATIC COLOR BAR BASED ON SUBJECT (Neighborhood)
function test_AutomaticNeighborhoodColorBar()
	if (SKIPS[11]) then
		skip("No testing...") -- 50002 assertions
	end

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("\nTesting Automatic Neighborhood ColorBar")


end



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


function test_DatabaseLegendRetrieval()
	if (SKIPS[12]) then
		skip("No testing...") -- 50002 assertions
	end
	pwd = "terralab0705"
	csQ = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = pwd,
		theme = "cells90x90"
	}
	csQ:load()
	print(csQ.legend)
end

function test_loadLegendFromDataBase()
	if (SKIPS[13]) then
		skip("No testing...") -- 50002 assertions
	end
	local dbms = 0
	local pwd = "terralab0705"

	local HEIGHT = "height_"
	local cs1 = nil


		cs1 = CellularSpace{
			dbType = "mysql",
			host = "127.0.0.1",
			database = "cabecatestes",
			user = "root",
			password = pwd,
			theme = "cells90x90"
		}

	local leg = cs1.legend

	local obs = Observer{
		subject = cs1,
		type = "map",
		attributes={HEIGHT},
		-- , legends = {leg}
		legends = {leg}
	}

	cs1:notify()

	io.read()
	--cs2:notify()
end


--[[
== IMAGE & MAP (1 ou 2 atributos de celulas; N agentes, M automatos)
1) CellularSpace (branco-preto; amarelo-azul; "*" - verde-vermelho; "*" -  verde-vermelho; ... )
2) Agent ( verde-vermelho, font = "????", fontSize = 12, symbol = "*" )
3) Automaton ( amarelo-azul )
4) Trajectory ( verde-vermelho )
5) Neighborhood (verde-vermelho )
--]]
--[[
testsSourceCodes = {
[1] = test_DefaultParameters,
[2] = test_AlternativeDefaultParameters,
[3] = test_AutomaticNumberLegend,
[4] = test_AutomaticBoolLegend,
[5] = test_AutomaticTextLegend,
[6] = test_AutomaticDateTimeLegend,
[7] = test_AutomaticCellularSpaceColorBar,
[8] = test_AutomaticAgentColorBar,
[9] = test_AutomaticAutomatonColorBar,
[10] = test_AutomaticTrajectoryColorBar,
[11] = test_AutomaticNeighborhoodColorBar,
[12] = test_DatabaseLegendRetrieval
}

--escolha qual teste será executado
for i=1, 12, 1 do
testsSourceCodes[i]()
end
]]--

print("TESTS FINISHED...") io.flush()

functionList = {
	[1] = "test_DefaultParameters",
	[2] = "test_AlternativeDefaultParameters",
	[3] = "test_AutomaticNumberLegend",
	[4] = "test_AutomaticBoolLegend",
	[5] = "test_AutomaticTextLegend",
	[6] = "test_AutomaticDateTimeLegend",
	[7] = "test_AutomaticCellularSpaceColorBar",
	[8] = "test_AutomaticAgentColorBar",
	[9] = "test_AutomaticAutomatonColorBar",
	[10] = "test_AutomaticTrajectoryColorBar",
	[11] = "test_AutomaticNeighborhoodColorBar",
	[12] = "test_DatabaseLegendRetrieval",
	[13] = "test_loadLegendFromDataBase"

}

SKIPS = executeBasics("legends", functionList, skips)

lunatest.run()

os.exit(0)
