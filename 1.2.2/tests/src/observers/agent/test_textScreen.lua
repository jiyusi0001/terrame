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
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do
	for j = 1, 5, 1 do
		c = Cell{ cover = "pasture", agents_ = {}}
		c.y = j - 1;
		c.x = i - 1;
		cs:add( c );
	end
end

state1 = State {
id = "walking",
Jump {
function( event, agent, cell )

	print(agent:getStateName());
	print(agent.energy)
	agent.energy= agent.energy - 1
	hungry = agent.energy == 0
	ag1.counter = ag1.counter + 10;

			if (hungry) then
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
			agent.energy = agent.energy + 1
			print(agent:getStateName());
			hungry = ag1.energy>0
			ag1.counter = ag1.counter + 10;

			if (not hungry)or( ag1.energy >=5) then
				return true
			end
			return false
		end,
		target = "walking"
	}
}

ag1 = Agent{
	id = "Ag1",
	energy  = 5,
	hungry = false,
	counter = 0,
	st1=state1,
	st2=state2
}

env = Environment{ id = "MyEnvironment", cs, ag1}
env:createPlacement{strategy = "void"}

ev = Event{ time = 1, period = 1, priority = 1 }

cs:notify()
cell = cs.cells[1]
ag1:enter(cell)

textScreenFor = function ( killObserver,unitTest )
	for i=1, 10, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify()
		ag1:notify(i)
		if ((killObserver and observerTextScreen05) and (i == 8)) then
			print("", "observerTextScreen05:kill", observerTextScreen05:kill())
		end
		delay_s(1)
	end
	unitTest:assert_true(true) 
end

local observersTextScreenTest = UnitTest {
	test_TextScreen01 = function( unitTest )
		print("OBSERVER TEXTSCREEN 01")
		observerTextScreen01=Observer{ subject=ag1, type = "textscreen" }
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen01.type)
	end,		
	test_TextScreen02 = function( unitTest )
		print("OBSERVER TEXTSCREEN 02")
		observerTextScreen02=Observer{subject=ag1, type = "textscreen", attributes={}}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen02.type)
	end,
	test_TextScreen03 = function(unitTest)
		print("OBSERVER TEXTSCREEN 03")
		observerTextScreen03=Observer{subject=ag1, type = "textscreen", attributes={}}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen03.type)
	end,
	test_TextScreen04 = function(unitTest)
		-- OBSERVER TEXTSCREEN 04
		print("OBSERVER TEXTSCREEN 04")
		observerTextScreen04=Observer{subject=ag1, type = "textscreen", attributes={"currentState", "energy", "hungry"}}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen04.type)
	end,
	test_TextScreen05 = function(unitTest)
		-- OBSERVER TEXTSCREEN 05
		print("OBSERVER TEXTSCREEN 05")
		observerTextScreen05=Observer{subject=ag1, type = "textscreen", attributes={"currentState", "energy", "hungry"}}
		textScreenFor(true,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen05.type)
	end
	
}
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03
Deve apresentar na tela uma tabela textual contendo todos os atributos do agente: "hungry", "id", "class", "cObj_", "weights_, "time", "relatives_", "cell", "energy", "currentState", "st1" e "st2". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.

TEXTSCREEN04
Deve apresentar na tela uma tabela textual contendo os atributos "currentState", "energy" e "hungry". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes três atributos.

TEXTSCREEN05
Este teste será idêntico ao teste 04. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.
]]

observersTextScreenTest:run()
os.exit(0)
