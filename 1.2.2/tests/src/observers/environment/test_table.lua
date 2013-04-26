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
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

cs = CellularSpace{ xdim = 0}
for i = 1, 5, 1 do 
	for j = 1, 5, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		cs:add( c )
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
			ag1.time = ag1.time + 1;
			ag1:notify(ag1.time);

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
			ag1.time = ag1.time + 1;
			ag1:notify(ag1.time);

			if (not hungry)or( ag1.energy==5) then
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
	time = 0,
	state1,
	state2
}

at1 = Automaton{
	id = "At1",
	it = Trajectory{
		target = cs
	}
}

t = Timer{
	Event{ time = 0, period = 1, action = function(event) 
			at1:execute(event) 
			env:notify(event:getTime())

			env.counter = event:getTime() + 1
			env.temperature = event:getTime() * 2

			if ((killObserver and observerKill) and (event:getTime() == 8)) then
				print("", "env:kill", env:kill(observerKill))
			end
			return true 
		end 
	}
}

env = Environment{ 
	id = "MyEnvironment",
	c1 = cs,
	-- verificar. funciona no linux. não funciona no windows.
	-- erro: index out of bounds
	--at1 = at1,
	--ag1 = ag1,
	t = t,
	counter = 0,
	temperature = 0
}
env:add(t)

tableFor = function( killObserver,unitTest ) 
	if ((killObserver and observerLogFile06) and (i == 8)) then
		print("", "observerTable06:kill", observerTable06:kill())
	end
	env:execute(10)
	unitTest:assert_true(true) 
end

local observersTableTest = UnitTest {
	test_Table01 = function(unitTest) 
		-- OBSERVER TABLE 01 
		print("OBSERVER TABLE 01") io.flush()
		observerTable01 = Observer{ subject=env, type="table" }
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable01.type)
	end,
	test_Table02 = function(unitTest) 
		-- OBSERVER TABLE 02 
		print("OBSERVER TABLE 02") io.flush()
		observerTable02 = Observer{ subject=env, type="table" }
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable02.type)
	end,
	test_Table03 = function(unitTest) 
		-- OBSERVER TABLE 03
		print("OBSERVER TABLE 03") io.flush() 
		observerTable03 = Observer{subject=env, type="table", attributes={}}
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable03.type)
	end,
	test_Table04 = function(unitTest) 
		-- OBSERVER TABLE 04
		print("OBSERVER TABLE 04") io.flush()
		observerTable04 = Observer{subject=env, type="table",attributes={}, xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable04.type)
	end,
	test_Table05 = function(unitTest) 
		-- 0BSERVER TABLE 05
		print("OBSERVER TABLE 05") io.flush()
		-- criação de atributo dinâmico antes da especificação de observers
		env.counter = 0
		observerTable05 = Observer{subject=env, type="table", attributes={"t","c1","counter"}}
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable05.type)
	end,
	test_Table06 = function(unitTest) 
		-- 0BSERVER TABLE 06
		print("OBSERVER TABLE 06") io.flush()
		-- criação de atributo dinâmico antes da especificação de observers
		env.counter = 0
		observerTable06 = Observer{subject=env, type="table", attributes={"t","c1","counter"}}
		tableFor(true,unitTest)
		unitTest:assert_equal("table",observerTable06.type)
	end
}
-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02 / TABLE 03 
Deve apresentar uma tabela contendo todos os atributos (e respectivos valores) do ambiente "env": "at1", "cObj_", "cont", "id", "t", "ag1", "c1". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 04 
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "t", "c1_" e "counter". Os atributos devem ser apresentados na ordem em que é feita a especificação. O valor do atributo "counter" deverá variar de 1 a 10 durante o teste. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 06
Este teste será idêntico ao teste TABLE 05. Porém, no tempo de simulação 8, o observador "observerKill" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.
]]

observersTableTest:run()
os.exit(0)
