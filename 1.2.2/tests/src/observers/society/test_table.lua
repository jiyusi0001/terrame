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

tableFor = function(killObserver,UnitTest)
	for i=1, 10 , 1 do
		print("STEP: ", i) io.flush()
		cs:notify(i)
		sc1:notify(i)
		sc1:execute(ev)
		if (sc1.count%2==0) then	
			sc1.state="par"
			sc1.count=sc1.count+1
		else
			sc1.state="inpar"
			sc1.count=sc1.count+1
		end		
		forEachCell(cs, function(cell)
			cell.soilWater=i*10
			sc1.acum=i*10
			
		end)			

		if ((killObserver and observerTable08) and (i == 8)) then
			print("", "observerTable08:kill", observerTable08:kill())
		end

		delay_s(1)
	end
	UnitTest:assert_true(true) 
end

MAX_COUNT = 9

cs = CellularSpace {
	xdim = 10
	-- -- xdim = 3,
	--cover = "pasture"
}
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1

		c.y = j - 1
		cs:add( c )
	end
end



ev = Event{ time = 1, period = 1, priority = 1 }
for i = 1, 11, 1 do 
	for j = 1, 11, 1 do 
		c = Cell{ soilWater = 0,agents_ = {} }
		c.x = i - 1
		c.y = j - 1
		
		cs:add( c )
	end
end
t = Timer{
	Event{ time = 0, action = function(event) sc1:execute(event) return true end }
}

sleeping = State {
	id = "sleeping",
	Jump {
		function( event, agent, cell )
			if (event:getTime() %3 == 0) then
				return true
			end
			--print("T:", event:getTime())
			--print("-- sleeping")
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
			--print("T:", event:getTime())
			--print("-- foraging")
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
	instance = boi(1),
	state = "none",
	--st2 = foraging,
	--st1 = sleeping,
	acum = 0,
	count=0,
	currentState = 0
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

local observersTableTest = UnitTest {
	test_table01 = function(UnitTest)
		-- OBSERVER TABLE 01 
		print("OBSERVER TABLE 01") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table" )
		observerTable01 = Observer{ subject = sc1, type = "table" }
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable01.type)
	end,

	test_table02 = function(UnitTest)
		-- OBSERVER TABLE 02
		print("OBSERVER TABLE 02") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {} )
		observerTable02 = Observer{ subject = sc1, type = "table", attributes={} }
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable02.type)
	end,

	test_table03 = function(UnitTest)
		-- OBSERVER TABLE 03 
		print("OBSERVER TABLE 03") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {}, {} )
		observerTable03 = Observer{ subject = sc1, type = "table", attributes={} }
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable03.type)
	end,

	test_table04 = function(UnitTest)
		--OBSERVER TABLE 04
		print("OBSERVER TABLE 04") io.flush()
		--at1:createObserver( "table", {},{cell} )
		observerTable04 = Observer{ subject = sc1, type = "table",attributes={}, location=cell }
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable04.type)
	end,

	test_table05 = function(UnitTest)
		-- OBSERVER TABLE 05
		print("OBSERVER TABLE 05") io.flush()
		--@DEPRECATED
		--at1:createObserver( "table", {"currentState"}, {cell,"","valores"} )
		observerTable05 = Observer{ subject = sc1, type = "table",attributes={"state"},location=cell,xLabel ="Valores" }
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable05.type)
	end,

	test_table06 = function(UnitTest)
		-- OBSERVER TABLE 06
		print("OBSERVER TABLE 06") io.flush()
		--@DEPRECATED
		--sc1:createObserver( "table", {"currentState"}, {cell,"atributos",""} )
		observerTable06 = Observer{ subject = sc1, type = "table",attributes={"acum"},yLabel = "Atributos",location=cell}
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable06.type)
	end,

	test_table07 = function(UnitTest)
		-- OBSERVER TABLE 07
		print("OBSERVER TABLE 07") io.flush()
		--@DEPRECATED
		--sc1:createObserver( "table", {"currentState","acum"}, {cell,"atributos","valores"})
		observerTable07 = Observer{ subject = sc1, type = "table",attributes={"acum","state"} ,yLabel = "Atributos", xLabel ="Valores",location=cell }
		tableFor(false,UnitTest)
		UnitTest:assert_equal("table",observerTable07.type)
	end,

	test_table08 = function(UnitTest)
		-- OBSERVER TABLE 08
		print("OBSERVER TABLE 08") io.flush()
		--@DEPRECATED
		--sc1:createObserver( "table", {"currentState","acum"}, {cell,"atributos","valores"})
		observerTable08 = Observer{ subject = sc1, type = "table",attributes={"state","acum"} ,yLabel = "Atributos", xLabel ="Valores",location=cell }
		tableFor(true,UnitTest)
		UnitTest:assert_equal("table",observerTable08.type)
	end

}

-- TESTES OBSERVER TABLE
--[[
TABLE 01
Programa apresenta uma tabla com os atributos e os valores, sendo que o atributo 'acum' varia de acordo com o andamento do modelo, crescendo o seu valor.

TABLE 02
Idem TABLE 01.

TABLE 03
Idem TABLE 01.

TABLE 04
Idem TABLE 01.

TABLE 05
Programa exibe uma tabela com atributos e valores, sendo que o atributo 'state' varia entre dois estados, que são 'par' e 'inpar'.

TABLE 06
Programa exibe uma tabela com duas colunas, uma de atributos e outra de valores. O atributo 'acum' varia de acordo com o andamento do modelo, crescendo seu valor.

TABLE 07
Idem TABLE 06, exceto que além do atributo 'acum' que cresce seu valor, há mais um atributo 'state' que varia entre dois estados, sendo eles 'inpar' e 'par'

TABLE 08
Idem TABLE 07.
]]

observersTableTest:run()
os.exit(0)
