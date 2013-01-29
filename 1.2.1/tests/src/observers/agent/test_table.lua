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

tableFor = function( killObserver )
	for i=1, 10, 1 do
		print("step ",i)
		ag1:execute(ev)
		ag1:move(cs.cells[i])
		cs:notify()            
		ag1:notify(i)
		if ((killObserver and observerTable06) and (i == 8)) then
			print("", "observerTable06:kill", observerTable06:kill())
		end
		delay_s(1)
	end
end

local observersTableTest = UnitTest {
	test_Table1 = function(self)
		-- OBSERVER TABLE 01
		print("OBSERVER TABLE 01")
		--@DEPRECATED
		--ag1:createObserver( "table" )
		observerTable01=Observer{subject=ag1, type = "table"}
		tableFor(false)
	end,
	test_Table2 = function(self)
		--OBSERVER TABLE 02 
		print("OBSERVER TABLE 02")
		--@DEPRECATED
		--ag1:createObserver( "table", {} )
		observerTable02=Observer{subject=ag1, type = "table",attributes={}}
		tableFor(false)
	end,
	test_Table3 = function(self)
		-- OBSERVER TABLE 03
		print("OBSERVER TABLE 03")
		--@DEPRECATED
		--ag1:createObserver( "table", {}, {} )
		observerTable03=Observer{subject=ag1, type = "table",attributes={}}
		tableFor(false)
	end,
	test_Table4 = function(self)
		-- OBSERVER TABLE 04
		print("OBSERVER TABLE 04")
		--@DEPRECATED
		--ag1:createObserver( "table", {},{"-- ATTRS --", "-- VALUES --"})
		observerTable04=Observer{subject=ag1, type = "table",attributes={},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		tableFor(false)
	end,
	test_Table5 = function(self)
		-- OBSERVER TABLE 05
		print("OBSERVER TABLE 05")
		--@DEPRECATED
		--ag1:createObserver( "table", {"currentState", "energy", "hungry"})
		observerTable05=Observer{subject=ag1, type = "table",attributes = {"currentState", "energy", "hungry"}}
		tableFor(false)
	end,
	test_Table6 = function(self)
		-- OBSERVER TABLE 06
		print("OBSERVER TABLE 06")
		--@DEPRECATED
		--ag1:createObserver( "table", {"currentState", "energy", "hungry"})
		observerTable06=Observer{subject=ag1, type = "table",attributes = {"currentState", "energy", "hungry"}}
		tableFor(true)
	end
}

--[[
TABLE 01 / TABLE 02 / TABLE 03
Deverá ser apresentada uma tabela contendo todos os atributos do agente "ag1" como linhas da tabela: "hungry", "id", "class", "cObj_", "weights_, "time", "relatives_", "cell", "energy", "currentState", "st1" e "st2". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 04
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "currentState", "energy" e "hungry". Os atributos devem ser apresentados na ordem em que é feita a especificação. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para o título das colunas.

TABLE 06
Este teste será idêntico ao teste 05. Porém, no tempo de simulação 8, o observador "observerTable06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observador será fechada.


]]

observersTableTest:run()
os.exit(0)
