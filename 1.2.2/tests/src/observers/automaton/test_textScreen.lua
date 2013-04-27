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

textScreenFor = function(killObserver,unitTest)
	for i=1, 10 , 1 do	
		print("STEP: ", i) io.flush()
		at1:notify()
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)			

		if ((killObserver and observerTextScreen06) and (i == 8)) then
			print("", "observerTextScreen06:kill", observerTextScreen06:kill())
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


local observersTextScreenTest = UnitTest {

	test_textScreen01 = function(unitTest) 
		--OBSERVER TEXTSCREEN 01 
		print("OBSERVER TEXTSCREEN 01") io.flush()
		observerTextScreen01 = Observer{ subject=at1, type = "textscreen" }
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen01.type)
	end,
	test_textScreen02 = function(unitTest) 
		--OBSERVER TEXTSCREEN 02 
		observerTextScreen02 = Observer{ subject=at1, type = "textscreen" }
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen02.type)    
	end,
	test_textScreen03 = function(unitTest) 
		--OBSERVER TEXTSCREEN 03 
		print("OBSERVER TEXTSCREEN 03") io.flush()
		observerTextScreen03 = Observer{ subject=at1, type = "textscreen" }
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen03.type)
	end,
	test_textScreen04 = function(unitTest)
		-- OBSERVER TEXTSCREEN 04 
		print("OBSERVER TEXTSCREEN 04") io.flush()
		observerTextScreen04 = Observer{ subject = at1, type = "textscreen", attributes={}, location=cell }
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen04.type)
	end,

	test_textScreen05 = function(unitTest)
		-- OBSERVER TEXTSCREEN 05 
		print("OBSERVER TEXTSCREEN 05") io.flush()
		observerTextScreen05 = Observer{ subject = at1, type = "textscreen", attributes={"currentState","acum"}, location=cell}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen05.type)    
	end,

	test_textScreen06 = function(unitTest)
		-- OBSERVER TEXTSCREEN 06 
		print("OBSERVER TEXTSCREEN 06") io.flush()
		observerTextScreen06 = Observer{ subject = at1, type = "textscreen", attributes={"currentState","acum"}, location=cell}
		textScreenFor(true,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen06.type)
	end
}
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03
O programa deverá ser abortado. Não é possível utilizar observers de autômatos sem a identificação do parâmetro "location".
Deverá ser emitida mensagem de erro informando a forma correta de se utilizar este tipo de observer.

TEXTSCREEN 04
Deve apresentar na tela uma tabela textual contendo todos os atributos do autômato "at1" no cabeçalho: "acum", "cont", "currentState", "id", "it", "cObj_", "st1" e "st2". Todos esses atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. 
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 05
Deve apresentar na tela uma tabela textual  contendo os atributos do automaton "at1" no cabeçalho: "currentState" e "acum". Os atributos devem ser apresentados na ordem em que é feita a especificação.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho.
--Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 06
Este teste será idêntico ao teste 05. Porém, no tempo de simulação 8, o observador "observerTextScreen06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

observersTextScreenTest:run()
os.exit(0)
