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

SKIP = true

ev = Event{ time = 1, period = 1, priority = 1 }

textScreenFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i) io.flush()
		ev:notify(i)
		if ((killObserver and observerTextScreen05) and (i == 8)) then
			print("", "observerTextScreen05:kill", observerTextScreen05:kill())
		end
	end
	unitTest:assert_true(true)
end	


local observersTextScreenTest = UnitTest {
	test_TextScreen01 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 01 
		print("TEXTSCREEN 01")
		observerTextScreen01 = Observer{ subject = ev, type = "textscreen" }
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen01.type)
	end,
	test_TextScreen02 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 02 
		print("TEXTSCREEN 02")
		observerTextScreen02 = Observer{ subject = ev, type = "textscreen", attributes={}}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen02.type)
	end,
	test_TextScreen03 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 03 
		print("TEXTSCREEN 03")
		observerTextScreen03 = Observer{ subject = ev, type = "textscreen", attributes={}}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen03.type)
	end,
	test_TextScreen04 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 04
		print("TEXTSCREEN 04")
		observerTextScreen04 = Observer{ subject = ev, type = "textscreen", attributes={ "time", "period"}}
		textScreenFor(false,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen04.type)
	end,
	test_TextScreen05 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 05
		observerTextScreen05 = Observer{ subject = ev, type = "textscreen", attributes={ "time", "period"}}
		textScreenFor(true,unitTest)
		unitTest:assert_equal("textscreen",observerTextScreen05.type)
	end
}
-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03

Deve apresentar na tela uma tabela textual contendo todos os atributos do evento "ev" no cabe�alho: "time", "period" e "priority". Todos estes atributos dever�o estar presentes mas n�o necessariamente ser�o apresentados nesta ordem.
Dever�o ser apresentadas tamb�m 10 linhas com os valores relativos a cada um dos atributos do cabe�alho. Todas as linhas dever�o ser iguais j� que o teste em quest�o n�o altera valores.
Dever� ser apresentada uma mensagem de "Warning" informando o n�o uso da lista de par�metros, desnecess�ria a observers TEXTSCREEN.

TEXTSCREEN 04

Deve apresentar na tela uma tabela textual contendo os atributos "time" e "period". Os atributos devem ser apresentados na ordem em que � feita a especifica��o. Dever�o ser apresentadas tamb�m 10 linhas contendo os valores relativos a estes dois atributos.
Dever� ser apresentada uma mensagem de "Warning" informando o n�o uso da lista de par�metros, desnecess�ria a observers TEXTSCREEN.

TEXTSCREEN 05
Este teste ser� id�ntico ao teste TEXTSCREEN 04. Por�m, no tempo de simula��o 8, o observador "observerTextScreen05" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e a janela referente a este observer ser� fechada.

]]

observersTextScreenTest:run()
os.exit(0)
