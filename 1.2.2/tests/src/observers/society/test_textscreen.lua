-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can TME_LEGEND_COLOR.REDistribute it and/or
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
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs = CellularSpace {
	xdim = 10
}

forEachCell(cs, function(cell)
	cell.cover = "pasture"
end)

coverLeg = Legend{
	-- Attribute name:  cover
	type = "string", -- NUMBER
	grouping = "uniquevalue",		-- ,		-- STDDEVIATION
	slices = 2,
	precision = 5,
	stdDeviation = "none",		-- ,		-- FULL
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "green", value = "pasture"},
		{color = "brown", value = "soil"}
	}
}

rebanhoLeg = Legend {
	type = "string",
	grouping = "uniquevalue",
	slices = 3,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{color = "black", value = "foraging"}, -- estado 1
		{color = "red", value = "sleeping"}   -- estado 2
	},
	font = "Times",
	fontSize = 14,
	symbol = "u"
}

sleeping = State {
	id = "sleeping",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 0) then
				return true
			end
			print("T:", event:getTime())
			print("-- sleeping")
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
			print("T:", event:getTime())
			print("-- foraging")
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
	instance = boi(1)
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

textscreenFor = function( killObservers,unitTest )
	local funcForKill = function(ag)
			return 2==ag:getID()
	end
		
	for i = 1, 10, 1 do
		print("STEP: ", i); io.flush()
		updateFunc(i, sc1)
		if ((killObserver and observerTextScreen04) and (i == 3)) then
			print("", "observerTextScreen04:kill", observerTextScreen04:kill(funcForKill))
		end
		delay_s(1000)
		print("Members in society 'sc1':", sc1:size())
		cs:notify()
		sc1:notify()
	end
	unitTest:assert_true(true)
end

-- ================================================================================#
local observersTextScreenTest = UnitTest {
	test_textscreen01 = function(unitTest)
		-- OBSERVER TEXTSCREEN 01
		print("TEXTSCREEN 01") io.flush()
		observerTextScreen01 = Observer{ subject = sc1, type = "textscreen"}
		updateFunc = function(step,soc)
			if(step == 5) then soc:remove(boi1) end
		end
		textscreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen01.type)
	end,
	test_textscreen02 = function(unitTest)
		-- OBSERVER TEXTSCREEN 02
		print("TEXTSCREEN 02 ") io.flush()	
		observerTextScreen02 = Observer{ subject = sc1, type = "textscreen", attributes= {}, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then soc:remove(soc:sample()) end
		end
		textscreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen02.type)		
	end,
	test_textscreen03 = function(unitTest)
		-- OBSERVER TEXTSCREEN 03
		print("TEXTSCREEN  03") io.flush() 
		observerTextScreen03 = Observer{ subject = sc1, type = "textscreen", attributes= {"quantity"}, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then
				soc:remove(boi1)
				soc:remove(boi3)
				soc:remove(boi5)
			end
		end
		textscreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen03.type)
	end,
	test_textscreen04 = function(unitTest)
		-- OBSERVER TEXTSCREEN 04
		print("TEXTSCREEN  04") io.flush()
		observerTextScreen04 = Observer{ subject = sc1, type = "textscreen", attributes= {"quantity"}, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			size = soc:size()
			if(step == 5) then
				for i=1,size,1 do
					soc:remove(soc:getAgent(1))
				end
			end
		end
		textscreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen04.type)
	end,
	test_textscreen05 = function(unitTest)
		-- OBSERVER TEXTSCREEN 05
		print("TEXTSCREEN  05") io.flush()
		observerTextScreen05 = Observer{ subject = sc1, type = "textscreen", attributes= {"quantity"}, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			if(step == 5) then
				observerTextSreen05:killAll()
				soc:clear()
			end
		end
		textscreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen05.type)
	end,
	test_textscreen06 = function(unitTest)
		-- OBSERVER TEXTSCREEN 06
		print("TEXTSCREEN  06") io.flush()
		observerTextScreen06 = Observer{ subject = sc1, type = "textscreen", attributes= {"quantity"}, observer = obs1, legends = {rebanhoLeg} }
		updateFunc = function(step, soc)
			event = Event { time = step }
			if(step == 5) then
				forEachAgent(soc, function(ag)
					coord = Coord {x=0, y=0}
					ag:move(cs:getCell(coord))
				end)
			end
		end
		textscreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen06.type)
	end
}
-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03
Deve aparecer na tela uma tablea textual com os atributos "observerId",	"messages", "instance",	"cObj_", "placements", "quantity", "parent", "agents",	"autoincrement".

TEXTSCREEN 04
Deve apresentar na tela uma tabela textual contendo o atributo quantity.

TEXTSCREEN 05
Idem ao 04. Poren, no tempo de simulação 8, o observador "observerTextScreen06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]


observersTextScreenTest.skips = {"test_NotDeclaredStates"}
observersTextScreenTest:run()
os.exit(0)
