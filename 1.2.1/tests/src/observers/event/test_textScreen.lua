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

-- TEST FOR EVENT OBSERVERS
ev = Event{ time = 1, period = 1, priority = 1 }

textScreenFor = function( killObserver )
	for i = 1, 10, 1 do
		print("step", i) io.flush()
		ev:notify(i)
		if ((killObserver and observerTextScreen05) and (i == 8)) then
			print("", "observerTextScreen05:kill", observerTextScreen05:kill())
		end
			-- delay_s(1)
	end
end	


local observersTextScreenTest = UnitTest {
	test_TextScreen1 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 01 
		print("TEXTSCREEN 01")
		--@DEPRECATED
		--ev:createObserver( "textscreen" )
		observerTextScreen01 = Observer{ subject = ev, type = "textscreen" }
		textScreenFor(false)
	end,
	test_TextScreen2 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 02 
		print("TEXTSCREEN 02")
		--@DEPRECATED
		--ev:createObserver( "textscreen", {} )
		observerTextScreen02 = Observer{ subject = ev, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_TextScreen3 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 03 
		print("TEXTSCREEN 03")
		--@DEPRECATED
		--ev:createObserver( "textscreen", {}, {} )
		observerTextScreen03 = Observer{ subject = ev, type = "textscreen", attributes={}}
		textScreenFor(false)
	end,
	test_TextScreen4 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 04
		print("TEXTSCREEN 04")
		--@DEPRECATED
		--ev:createObserver( "textscreen", { "time", period, "priority" }, {} )
		observerTextScreen04 = Observer{ subject = ev, type = "textscreen", attributes={ "time", "period"}}
		textScreenFor(false)
	end,
	test_TextScreen5 = function(unitTest) 
		-- OBSERVER TEXTSCREEN 05
		print("TEXTSCREEN 05")
		--@DEPRECATED
		--ev:createObserver( "textscreen", { "time", period, "priority" }, {} )
		observerTextScreen05 = Observer{ subject = ev, type = "textscreen", attributes={ "time", "period"}}
		textScreenFor(true)
	end
}
-- TESTES OBSERVER TEXTSCREEN
--[[
TEXTSCREEN 01 / TEXTSCREEN 02 / TEXTSCREEN 03

Deve apresentar na tela uma tabela textual contendo todos os atributos do evento "ev" no cabeçalho: "time", "period" e "priority". Todos estes atributos deverão estar presentes mas não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.
Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 04

Deve apresentar na tela uma tabela textual contendo os atributos "time" e "period". Os atributos devem ser apresentados na ordem em que é feita a especificação. Deverão ser apresentadas também 10 linhas contendo os valores relativos a estes dois atributos.
Deverá ser apresentada uma mensagem de "Warning" informando o não uso da lista de parâmetros, desnecessária a observers TEXTSCREEN.

TEXTSCREEN 05
Este teste será idêntico ao teste TEXTSCREEN 04. Porém, no tempo de simulação 8, o observador "observerTextScreen05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e a janela referente a este observer será fechada.

]]

observersTextScreenTest:run()
os.exit(0)
