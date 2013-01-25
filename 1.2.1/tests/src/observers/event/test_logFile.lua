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

SKIP = true

-- TEST FOR EVENT OBSERVERS
ev = Event{ time = 1, period = 1, priority = 1 }

logFileFor = function( killObserver )
	for i = 1, 10, 1 do
		print("step", i) io.flush()
		ev:notify(i)
		if ((killObserver and observerLogFile05) and (i == 8)) then
			print("", "observerLogFile05:kill", observerLogFile05:kill())
		end
		-- delay_s(1)
	end
end

local observersLogFileTest = UnitTest {
	test_LogFile1 = function(unitTest) 
		--OBSERVER LOGFILE 01 
		print("OBSERVER LOGFILE 01") io.flush()
		--@DEPRECATED
		--ev:createObserver( "logfile" )
		observerLogFile01 = Observer{ subject = ev, type = "logfile" }
		logFileFor(false)
	end,
	test_LogFile2 = function(unitTest) 
		-- OBSERVER LOGFILE 02
		print("OBSERVER LOGFILE 02") io.flush()
		--@DEPRECATED
		--ev:createObserver( "logfile", {} )
		observerLogFile02 = Observer{ subject = ev, type = "logfile",attributes={} }
		logFileFor(false)
	end,
	test_LogFile3 = function(unitTest) 
		-- OBSERVER LOGFILE 03
		print("OBSERVER LOGFILE 03") io.flush()
		--@DEPRECATED
		--ev:createObserver( "logfile", {}, {} )
		observerLogFile03 = Observer{ subject = ev, type = "logfile",attributes={} }
		logFileFor(false)	
	end,
	test_LogFile4 = function(unitTest) 
		-- OBSERVER LOGFILE 04
		print("OBSERVER LOGFILE 04") io.flush()
		--@DEPRECATED
		--ev:createObserver( "logfile", {}, {"rain.csv", ","} )
		observerLogFile04 = Observer{ subject=ev,type="logfile",attributes={}, outfile = "logfile.csv", separator="," }
		logFileFor(false)	
	end,
	test_LogFile5 = function(unitTest) 
		-- OBSERVER LOGFILE 05
		print("OBSERVER LOGFILE 05") io.flush()
		--@DEPRECATED
		--ev:createObserver( "logfile", {}, {"rain.csv", ","} )
		observerLogFile05 = Observer{ subject=ev,type="logfile",attributes={}, outfile = "logfile.csv", separator="," }
		logFileFor(true)	
	end
}
-- TESTES OBSERVER LOGFILE
--[[
LOGFILE01 / LOGFILE02 / LOGFILE03

Os arquivos gerados deverão ser idênticos, com nome ("result_.csv" usando ";" como separador). O conteúdo destes arquivos deverá ser uma tabela textual contendo todos os atributos do evento "ev" no cabeçalho: "time", "period" e "priority". Todos estes atributos deverão estar presentes mas, não necessariamente serão apresentados nesta ordem.
Deverão ser apresentadas também 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser idênticas, já que o teste em questão não altera valores dos atributos.
Deverão ser mostradas mensagens de "Warning" informando o uso de valores padrão para o nome de arquivo ("result_.csv") e caractere de separação (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o parâmetro relacionado ao arquivo de saída, o nome gerado para ambos os observers será o mesmo.

LOGFILE 04
Deverá ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE01, 02 e 03) deverão ser apresentados.
Deverão ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabeçalho. Todas as linhas deverão ser iguais já que o teste em questão não altera valores.

LOGFILE 05
Este teste será idêntico ao teste LOGFILE 04. Porém, no tempo de simulação 8, o observador "observerLogFile05" será destruído. O método "kill" retornará um valor booleano confirmando o sucesso da chamada e o arquivo "logfile.csv" conterá apenas informações até o 8o. tempo de simulação
]]

observersLogFileTest:run()
os.exit(0)
