-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright � 2001-2012 INPE and TerraLAB/UFOP.
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
--			Henrique Cota Cam�lo
--			Washington Sena Fran�a e Silva
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")


--db = getDataBase()
--dbms = db["dbms"]
--PWD = db["pwd"]
DB_VERSION = "4_2_0"
HEIGHT = "height_"

db = getDataBase()
dbms = db["dbms"]
pwd = db["pwd"]


function createCS(dbms, pwd, t)
        -- defines and loads the celular space from a TerraLib theme 
        local cs = nil 
        if(dbms == 0) then 
            cs = CellularSpace{ 
                dbType = "mysql", 
                host = "127.0.0.1", 
                database = "cabeca", 
                user = "root", 
                password = pwd, 
                theme = t 
            } 
        else 
            cs = CellularSpace{ 
                dbType = "ADO", 
                database = TME_PATH .. "\\database\\cabecaDeBoi_" .. DB_VERSION ..".mdb", 
                theme = t     
            }         
        end
    return cs
end

cs1 = createCS(dbms,pwd,"cells90x90")

tableFor = function( killObserver )
	for i = 1, 10, 1 do
		print("step", i)
		cs1.counter = i
		cs1:notify(i)
		if ((killObserver and observerTable06) and (i == 8)) then
			print("", "observerTable06:kill", observerTable06:kill())
		end
		delay_s(1)
	end
end


local observersTableTest = UnitTest { 
	test_Table1 = function(unitTest) 
		-- OBSERVER TABLE 01 
		--cs1 = cs.cells[1]
		print("TABLE 01") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "table" )
		observerTable01 = Observer{ subject = cs1, type = "table" }
		tableFor(false)
	end,                
	test_Table2 = function(unitTest) 
		--OBSERVER TABLE 02
		--cs1 = cs.cells[1] 
		print("TABLE 02") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "table", {} )
		observerTable02 = Observer{ subject = cs1, type = "table",attributes={} }
		tableFor(false)
	end,        
	test_Table3 = function(unitTest)
		-- OBSERVER TABLE 03
		--cs1 = cs.cells[1]
		print("TABLE 03") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "table", {}, {} )
		observerTable03 = Observer{ subject = cs1, type = "table",attributes={} }
		tableFor(false)
	end,        
	test_Table4 = function(unitTest)
		-- OBSERVER TABLE 04
		--cs1 = cs.cells[1]
		print("TABLE 04") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "table", {}, {"attr","vvv"} )
		observerTable04 = Observer{ subject = cs1, type = "table",attributes={},xLabel = "-- VALUES --", yLabel ="-- ATTRS --"}
		tableFor(false)
	end,
	test_Table5 = function(unitTest)
		-- OBSERVER TABLE 05
		--cs1 = cs.cells[1]
		print("TABLE 05") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "table", {"soilWater", HEIGHT, "counter"})
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cs1.counter = 0
		observerTable05 = Observer{ subject = cs1, type = "table",attributes={"counter"} }
		tableFor(false)
	end,
	test_Table6 = function(unitTest)
		-- OBSERVER TABLE 06
		--cs1 = cs.cells[1]
		print("TABLE 06") io.flush()
		--@DEPRECATED
		--cs1:createObserver( "table", {"soilWater", HEIGHT, "counter"})
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cs1.counter = 0
		observerTable06 = Observer{ subject = cs1, type = "table",attributes={"counter"} }
		tableFor(true)
	end
}

-- TESTES OBSERVER TABLE
--[[
TABLE 01 / TABLE 02 / TABLE 03
Dever� ser apresentada uma tabela contendo todos os atributos da c�lula "cs1" como linhas da tabela: "soilWater", "cObj_", "Lin", "y", "x", "object_id0", "Col", "height_", "past", "agents_" e "objectId_". Todos estes atributos dever�o estar presentes mas, n�o necessariamente ser�o apresentados nesta ordem. O atributo din�mico "counter" dever� ser exibido e seu valor deve variar entre 1 e 10 durante o teste. O cabe�alho da tabela dever� usar os valores padr�es para atributos e valores: "Attributes" e "Values".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para as colunas.

TABLE 04
Resultados id�nticos aos dos observers TABLE01, TABLE02 e TABLE03, exceto pelo t�tulo das colunas: "-- ATTRS --" e "-- VALUES --".

TABLE 05
Deve apresentar na tela uma tabela contendo os atributos "soilWater", "height_" e "counter". Os atributos devem ser apresentados na ordem em que � feita a especifica��o. O valor do atributo "counter" dever� variar de 1 a 10 durante o teste. As colunas dever�o ter os valores padr�o "Attributes" e "Values".
Dever� ser emitida mensagem de "Warning" informando o uso de valores padr�o para o t�tulo das colunas.

TABLE 05
Este teste ser� id�ntico ao teste TABLE 05. Por�m, no tempo de simula��o 8, o observador "observerTextScreen05" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e a janela referente a este observer ser� fechada.

]]

observersTableTest:run()
os.exit(0)
