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
	--ag1:notify(ag1.time);

			if (hungry) then
				--agent.energy = agent.energy + 30
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
			--ag1:notify(ag1.time);

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

ag1Leg = Legend{
	type = "string",
	grouping = "uniquevalue",
	slices = 10,
	precision = 5,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,

	style = 3,  -- estilo da curva
	symbol = "+", -- tipo do simbolo 
	width = 2, -- largura da linha

	colorBar = {
		{color = "red", value = "walking"},
		{color = "blue", value = "sleeping"}
	}
}

statemachineFor = function( killObserver )
	for i=1, 25, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify()
		ag1:notify(i)
		if ((killObserver and observerStateMachine06) and (i == 18)) then
			print("", "observerStateMachine06:kill", observerStateMachine06:kill())
		end
		delay_s(1)
	end
end

local observersStateMachineTest = UnitTest {
	test_StateMachine1 = function(self)
		-- OBSERVER STATEMACHINE 01
		cell = cs.cells[1]
		ag1:enter(cell)
		print("OBSERVER STATEMACHINE 01")
		--@DEPRECATED
		--ag1:createObserver( "statemachine" )
		observerStateMachine01=Observer{subject=ag1, type = "statemachine"}
		statemachineFor(false)
	end,
	test_StateMachine2 = function(self)
		-- OBSERVER STATEMACHINE 02
		cell = cs.cells[1]
		ag1:enter(cell)
		print("OBSERVER STATEMACHINE 02")
		--@DEPRECATED
		--ag1:createObserver( "statemachine",{} )
		observerStateMachine02=Observer{subject=ag1, type = "statemachine", atributes={}}
		statemachineFor(false)
	end,
	test_StateMachine3 = function(self)
		-- OBSERVER STATEMACHINE 03
		cell = cs.cells[1]
		ag1:enter(cell)
		print("OBSERVER STATEMACHINE 03")
		--@DEPRECATED
		--ag1:createObserver( "statemachine", {},{})
		observerStateMachine03=Observer{subject=ag1, type = "statemachine", attributes={"energy"},legends={}}
		statemachineFor(false)
	end,
	test_StateMachine4 = function(self)
		-- OBSERVER STATEMACHINE 04
		cell = cs.cells[1]
		ag1:enter(cell)
		print("OBSERVER STATEMACHINE 04")
		--@DEPRECATED
		--ag1:createObserver( "statemachine" , {"currentState"} )
		observerStateMachine04=Observer{subject=ag1, type = "statemachine", attributes={"currentState"}}
		statemachineFor(false)
	end,
	test_StateMachine5 = function(self)
		-- OBSERVER STATEMACHINE 05
		cell = cs.cells[1]
		ag1:enter(cell)
		print("OBSERVER STATEMACHINE 05")
		--@DEPRECATED
		--ag1:createObserver( "statemachine" , {"currentState"},{ag1Leg} )
		observerStateMachine05=Observer{subject=ag1, type = "statemachine",legends={ag1Leg}}
		statemachineFor(false)
	end,
	test_StateMachine6 = function(self)
		-- OBSERVER STATEMACHINE 06
		cell = cs.cells[1]
		ag1:enter(cell)
		print("OBSERVER STATEMACHINE 06")
		--@DEPRECATED
		--ag1:createObserver( "statemachine" , {"currentState"},{ag1Leg} )
		observerStateMachine06=Observer{subject=ag1, type = "statemachine",legends={ag1Leg}}
		statemachineFor(true)
	end
}
--[[
STATEMACHINE 01
O programa deverá apresentar uma janela com a mensagem informando que o atributo selecionado não é um valor númerico.
Deve apresentar uma máquina de estados contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro deve ser cinza (legenda padrão).
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "legends".

STATEMACHINE 02 / STATEMACHINE 03
O programa deverá apresentar uma janela com a mensagem informando que o atributo selecionado não é um valor númerico.
Deve apresentar uma máquina de estados contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro deve ser cinza (legenda padrão).
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "subtitle".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

STATEMACHINE 04
O programa deverá apresentar uma janela com mensagem informando que o atributo selecionado não é um valor numérico.
Deve apresentar uma máquina de estados para o atributo "currentState" do agent "ag1" contendo dois estados. A cada iteração o estado atual deve estar preenchido com a cor verde e bordas destacadas, enquanto o outro estado deve ser cinza.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o parâmetro "subtitle".
Deverá ser emitida mensagem de "Warning" informando que a lista de atributos está sendo ignorada.

STATEMACHINE 05
Deve apresentar uma máquina de estados para o atributo "currentState" do agente "ag1" contendo dois estados, preenchidos de acordo com a legenda "currentStateLeg" ("walking" em verde e "sleeping" em marrom). A cada iteração o estado atual deve estar destacado com bordas em negrito.

STATEMACHINE 06
O prgrama deve apresentar uma máquina de estados semelhante ao STATEMACHINE 05, mas com a diferença é que as cores de "walking" e "sleeping", são vermelho e azul, respectivamente.

]]

observersStateMachineTest:run()
os.exit(0)
