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

tableFor = function(killObserver)
	for i=1, 10 , 1 do
		print("STEP: ", i) io.flush()
		cs:notify(i)
		at1:notify(i)
		at1.cont = 0
		at1:execute(ev)
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
		end)			

		if ((killObserver and observerTable08) and (i == 8)) then
			print("", "observerTable08:kill", observerTable08:kill())
		end

		delay_s(1)
	end
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

local observersTableTest = UnitTest {
	test_table01 = function(x)
		-- OBSERVER TABLE 01 
		print("OBSERVER TABLE 01") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table" )
		observerTable01 = Observer{ subject = at1, type = "table" }
		tableFor(false)
	end,

	test_table02 = function(x)
		-- OBSERVER TABLE 02
		print("OBSERVER TABLE 02") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {} )
		observerTable02 = Observer{ subject = at1, type = "table", attributes={} }
		tableFor(false)
	end,

	test_table03 = function(x)
		-- OBSERVER TABLE 03 
		print("OBSERVER TABLE 03") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {}, {} )
		observerTable03 = Observer{ subject = at1, type = "table", attributes={} }
		tableFor(false)
	end,

	test_table04 = function(x)
		--OBSERVER TABLE 04
		print("OBSERVER TABLE 04") io.flush()
		--at1:createObserver( "table", {},{cell} )
		observerTable04 = Observer{ subject = at1, type = "table",attributes={}, location=cell }
		tableFor(false)
	end,

	test_table05 = function(x)
		-- OBSERVER TABLE 05
		print("OBSERVER TABLE 05") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {"currentState"}, {cell,"","valores"} )
		observerTable05 = Observer{ subject = at1, type = "table",attributes={"currentState"},location=cell,xLabel ="Valores" }
		tableFor(false)
	end,

	test_table06 = function(x)
		-- OBSERVER TABLE 06
		print("OBSERVER TABLE 06") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {"currentState"}, {cell,"atributos",""} )
		observerTable06 = Observer{ subject = at1, type = "table",attributes={"acum"},yLabel = "Atributos",location=cell}
		tableFor(false)
	end,

	test_table07 = function(x)
		-- OBSERVER TABLE 07
		print("OBSERVER TABLE 07") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {"currentState","acum"}, {cell,"atributos","valores"})
		observerTable07 = Observer{ subject = at1, type = "table",attributes={"currentState","acum"} ,yLabel = "Atributos", xLabel ="Valores",location=cell }
		tableFor(false)
	end,

	test_table08 = function(x)
		-- OBSERVER TABLE 08
		print("OBSERVER TABLE 08") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {"currentState","acum"}, {cell,"atributos","valores"})
		observerTable08 = Observer{ subject = at1, type = "table",attributes={"currentState","acum"} ,yLabel = "Atributos", xLabel ="Valores",location=cell }
		tableFor(true)
	end

}

-- TESTES OBSERVER TABLE
--[[
TABLE 01
Programa não será executado, pois para obsercar um autômato é requerido um parâmetro 'localização' para que seja uma célula, sendo assim ocorrerá um erro.

TABLE 02
Idem TABLE 01.

TABLE 03
Idem TABLE 01.

TABLE 04
Programa apresenta uma tabla com os atributos e os valores, sendo que o atributo 'acum' varia de acordo com o andamento do modelo, crescendo o seu valor.

TABLE 05
Programa exibe uma tabela com atributos e valores, sendo que o atributo 'currentState' varia entre dois estados, que são 'seco' e 'molhado'.

TABLE 06
Programa exibe uma tabela com duas colunas, uma de atributos e outra de valores. O atributo 'acum' varia de acordo com o andamento do modelo, crescendo seu valor.

TABLE 07
Idem TABLE 06, exceto que além do atributo 'acum' que cresce seu valor, há mais um atributo 'currentState' que varia entre dois estados, sendo eles 'seco' e 'molhado'

TABLE 08
Idem TABLE 07.
]]

observersTableTest:run()
os.exit(0)
