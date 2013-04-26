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

SKIP = true

ev = Event{ time = 1, period = 1, priority = 1 }

tableFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i) io.flush()
		ev:notify(i)
		if ((killObserver and observerTable06) and (i == 8)) then
			print("", "observerTable06:kill", observerTable06:kill())
		end
	end
	unitTest:assert_true(true)
end

local observersTableTest = UnitTest {
	test_Table01 = function(unitTest) 
		-- OBSERVER TABLE 01 
		print("OBSERVER TABLE 01") io.flush()
		observerTable01 = Observer{ subject = ev, type = "table" }
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable01.type)
	end,
	test_Table02 = function(unitTest) 
		-- OBSERVER TABLE 02 
		print("OBSERVER TABLE 02") io.flush()
		observerTable02 = Observer{ subject = ev, type = "table", attributes={} }
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable02.type)
	end,
	test_Table03 = function(unitTest)
		-- OBSERVER TABLE 03
		print("TABLE 03") io.flush()
  	observerTable03 = Observer{ subject = ev, type = "table", attributes={} }
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable03.type)
	end,        
	test_Table04 = function(unitTest)
		-- OBSERVER TABLE 04
		print("TABLE 04") io.flush()
		observerTable04 = Observer{ subject = ev, type = "table",attributes={}, xLabel = "-- ATTRS --", yLabel ="-- VALUES --"}
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable04.type)
	end,
	test_Table05 = function(unitTest)
		-- OBSERVER TABLE 05
		print("TABLE 05") io.flush()
		observerTable05 = Observer{ subject = ev, type = "table", attributes={"time", "priority"} }
		tableFor(false,unitTest)
		unitTest:assert_equal("table",observerTable05.type)
	end,
	test_Table06 = function(unitTest)
		-- OBSERVER TABLE 06
		print("TABLE 06") io.flush()
		observerTable06 = Observer{ subject = ev, type = "table", attributes={"time", "priority"} }
		tableFor(true,unitTest)
		unitTest:assert_equal("table",observerTable06.type)
	end
}
-- TESTES OBSERVER TABLE
--[[
TABLE01 / TABLE02 / TABLE03

Deverá ser apresentada uma tabela contendo todos os atributos do evento "ev" como linhas da tabela: "time", "period" e "priority". Todos estes atributos deverão estar presentes mas, não necessariamente serão apresentados nesta ordem. O cabeçalho da tabela deverá usar os valores padrões para atributos e valores: "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 04
Resultados idênticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo título das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "time" e "priority". Os atributos devem ser apresentados na ordem em que é feita a especificação. As colunas deverão ter os valores padrão "Attributes" e "Values".
Deverá ser emitida mensagem de "Warning" informando o uso de valores padrão para as colunas.

TABLE 06
Este teste será idêntico ao teste TABLE 04. Porém, no tempo de simulação 8, o observador "observerTable06" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.
]]

observersTableTest:run()
os.exit(0)
