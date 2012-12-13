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

function createMySQLTable()
	local parametrosMySQL = {
		dbType = "mysql",
		host = "127.0.0.1",
		database = "cabeca",
		user = "root",
		password = PWD,
		theme = "cells90x90"
	}
	return parametrosMySQL
end

function createAccessTable()
	local parametrosAccess = {
		dbType = "ADO",
		database = "database\\cabecaDeBoi_" .. DB_VERSION ..".mdb",
		theme = "cells90x90"	
	}	
	return parametrosAccess;
end

--db = getDataBase()
--dbms = db["dbms"]
--PWD = db["pwd"]
dbms = 0
DB_VERSION = "4_2_0"
HEIGHT = "height_"
PWD= "terralab0705"


cs1 = nil
if(dbms == 0) then
	cs1 = CellularSpace(createMySQLTable())
else
	cs1 = CellularSpace(createAccessTable())
end

textScreenFor = function( killObserver )
	for i = 1, 10, 1 do
		print("step", i)
		cs1.counter = i
		cs1:notify(i)
		if ((killObserver and observerTextScreen05) and (i == 8)) then
			print("", "observerTextScreen05:kill", observerTextScreen05:kill())
		end
		delay_s(1)
	end		
end

local observersTextScreenTest = UnitTest { 
	test_TextScreen1 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 01
		--cs1 = cs.cells[1] 
		print("TEXTSCREEN 01")
		--@DEPRECATED
		--cs1:createObserver( "textscreen" )
		observerTextScreen01 = Observer{ subject = cs1, type = "textscreen" }
		textScreenFor(false)
	end,
	test_TextScreen2 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 02 
		print("TEXTSCREEN 02")
		--@DEPRECATED
		--cs1:createObserver( "textscreen", {} )
		observerTextScreen02 = Observer{ subject = cs1, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_TextScreen3 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 03 
		print("TEXTSCREEN 03")
		--@DEPRECATED
		--cs1:createObserver( "textscreen", {}, {} )
		observerTextScreen03 = Observer{ subject = cs1, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_TextScreen4 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 04
		print("TEXTSCREEN 04")
		--@DEPRECATED
		--cs1:createObserver( "textscreen", { "soilWater", HEIGHT, "counter" }, {} )
		-- cria��o de atributo din�mico antes da especifica��o de observers	
		cs1.counter = 0
		observerTextScreen04 = Observer{ subject = cs1, type = "textscreen", attributes={ "counter"}}
		textScreenFor(false)
	end,
	test_TextScreen5 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 05
		print("TEXTSCREEN 05")
		--@DEPRECATED
		--cs1:createObserver( "textscreen", { "soilWater", HEIGHT, "counter" }, {} )
		-- cria��o de atributo din�mico antes da especifica��o de observers	
		cs1.counter = 0
		observerTextScreen05 = Observer{ subject = cs1, type = "textscreen", attributes={ "counter"}}
		textScreenFor(true)
	end
}

-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN01 / TEXTSCREEN02 / TEXTSCREEN03

Deve apresentar na tela uma tabela textual contendo todos os atributos da c�lula "cs1" no cabe�alho: "soilWater", "cObj_", "Lin", "y", "x", "object_id0", "Col", "height_", "past", "agents_" e "objectId_". Todos estes atributos dever�o estar presentes mas, n�o necessariamente ser�o apresentados nesta ordem.
Dever�o ser apresentadas tamb�m 10 linhas com os valores relativos a cada um dos atributos do cabe�alho. Todas as linhas dever�o ser iguais j� que o teste em quest�o n�o altera valores.
--Dever� ser apresentada uma mensagem de "Warning" informando o n�o uso da lista de par�metros, desnecess�ria a observers TEXTSCREEN.

TEXTSCREEN 04

Deve apresentar na tela uma tabela textual contendo os atributos "soilWater", "height_" e "counter". Os atributos devem ser apresentados na ordem em que � feita a especifica��o. Dever�o ser apresentadas tamb�m 10 linhas contendo os valores relativos a estes tr�s atributos. Todas as linhas (com exce��o do atributo din�mico "counter") dever�o ser iguais j� que o teste em quest�o n�o altera valores dos atributos "soilWater" e "height".
Dever� ser apresentada uma mensagem de "Warning" informando o n�o uso da lista de par�metros, desnecess�ria a observers TEXTSCREEN.

TEXTSCREEN 05
Este teste ser� id�ntico ao teste TEXTSCREEN 04. Por�m, no tempo de simula��o 8, o observador "observerTextScreen05" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e a janela referente a este observer ser� fechada.


]]

observersTextScreenTest:run()
os.exit(0)
