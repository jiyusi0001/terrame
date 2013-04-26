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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

DB_VERSION = "4_2_0"
HEIGHT = "height_"

db = getDataBase()
dbms = db["dbms"]
pwd = db["pwd"]

--require("XDebug")
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

cs = createCS(dbms,pwd,"cells90x90")

logfileFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i)
		cell01.counter = i
		cell01:notify(i)
		if ((killObserver and observerLogFile06) and (i == 8)) then
			print("", "observerLogFile06:kill", observerLogFile06:kill())
		end
		delay_s(1)
	end
	unitTest:assert_true(true) 
end

local observersLogFileTest = UnitTest {
	test_LogFile01 = function(unitTest) 				
		--OBSERVER LOGFILE 01 
		cell01 = cs.cells[1]
		print("LOGFILE 01") io.flush()
		observerLogFile01 = Observer{ subject = cell01, type = "logfile" }
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile01.type)
	end,
	test_LogFile02 = function(unitTest) 
		-- OBSERVER LOGFILE 02
		cell01 = cs.cells[1]
		print("LOGFILE 02") io.flush()
		observerLogFile02 = Observer{ subject = cell01, type = "logfile",attributes={} }
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile02.type)
	end,
	test_LogFile03 = function(unitTest) 
		-- OBSERVER LOGFILE 03
		cell01 = cs.cells[1]
		print("LOGFILE 03") io.flush()
		observerLogFile03 = Observer{ subject = cell01, type = "logfile", attributes={} }
		logfileFor(false,unitTest) 
		unitTest:assert_equal("logfile",observerLogFile03.type)
	end,
	test_LogFile04 = function(unitTest) 
		-- OBSERVER LOGFILE 04
		cell01 = cs.cells[1]
		print("LOGFILE 04") io.flush()
		observerLogFile04 = Observer{ subject = cell01, type = "logfile",attributes={},outfile = "logfile.csv", separator=","}
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile04.type)
	end,
	test_LogFile05 = function(unitTest) 
		-- OBSERVER LOGFILE 05
		cell01 = cs.cells[1]
		print("LOGFILE 05") io.flush()
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cell01.counter = 0
		observerLogFile05 = Observer{ subject = cell01, type = "logfile",attributes={"soilWater", HEIGHT,"counter"} }
		logfileFor(false,unitTest)
		unitTest:assert_equal("logfile",observerLogFile05.type)
	end,
	test_LogFile06 = function(unitTest) 
		-- OBSERVER LOGFILE 06
		cell01 = cs.cells[1]
		print("LOGFILE 06") io.flush()
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cell01.counter = 0
		observerLogFile06 = Observer{ subject = cell01, type = "logfile",attributes={"soilWater", HEIGHT,"counter"} }
		logfileFor(true,unitTest)
		unitTest:assert_equal("logfile",observerLogFile06.type)
	end,
	test_LogFile07 = function(unitTest) 
		-- OBSERVER LOGFILE 07
		cell01 = cs.cells[1]
		print("LOGFILE 07") io.flush()
		-- cria��o de atributo din�mico antes da especifica��o de observers
		cell01.counter = 0
		observerLogFile07 = Observer{ subject = cell01, type = "logfile",attributes={"soilWater", HEIGHT,"counter"},outfile = TME_ImagePath.."/result.csv" }
		logfileFor(false,unitTest)
		
	    moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."cell"..TME_DIR_SEPARATOR.."test_logFile"..TME_DIR_SEPARATOR.."test_logFile07",".csv")
	    
	    
	    if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/result.csv".. " > /dev/null 2>&1 ")
	    else
		    --@TODO
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end
        
		unitTest:assert_equal("logfile",observerLogFile07.type)
	end,
	
	
}
-- TESTES OBSERVER LOGFILE
--[[
LOGFILE 01 / LOGFILE 02 / LOGFILE 03
Dever� ser gerado um arquivo com nome "result_.csv" que utiliza ";" como separador. O conte�do do arquivo dever� ser uma tabela textual contendo todos os atributos da c�lula "cell01" no cabe�alho: "soilWater", "cObj_", "Lin", "y", "x", "object_id0", "Col", "height_", "past", "agents_" e "objectId_". Todos estes atributos dever�o estar presentes mas n�o necessariamente ser�o apresentados nesta ordem.
Dever�o ser apresentadas tamb�m 10 linhas com os valores relativos a cada um dos atributos do cabe�alho. Todas as linhas dever�o ser iguais j� que o teste em quest�o n�o altera valores.
Dever�o ser mostradas mensagens de "Warning" informando o uso de valores padr�o para o nome de arquivo ("result_.csv") e caractere de separa��o (";").

OBS.:
Este teste deve ser executado separadamente para cada um dos observers (LOGFILE 01 A 03), pois sem o par�metro relacionado ao arquivo de sa�da, o nome gerado para ambos os observers ser� o mesmo.

LOGFILE 04
Dever� ser gerado um arquivo "logfile.csv", que utiliza como separador o caractere ",". Todos os atributos (como em LOGFILE01, 02 e 03) dever�o ser apresentados.
Dever�o ser apresentadas 10 linhas com os valores relativos a cada um dos atributos do cabe�alho. Todas as linhas dever�o ser iguais j� que o teste em quest�o n�o altera valores.

LOGFILE 05
Dever� ser gerado o arquivo "result_.csv" contendo uma tabela textual com os atributos "soilWater", "height_" e "counter". Os atributos devem ser apresentados na ordem em que � feita a especifica��o. Dever�o ser apresentadas tamb�m 10 linhas contendo os valores relativos a estes atributos. Todas as linhas dever�o ser semelhantes, com exce��o do atributo "counter", j� que o teste em quest�o n�o altera valores dos atributos "soilWater" e "height".
Dever�o ser mostradas mensagens de "Warning" informando o uso de valores padr�o para o nome de arquivo ("result_.csv") e caractere de separa��o (";").

LOGFILE 06
Este teste ser� id�ntico ao teste LOGFILE 05. Por�m, no tempo de simula��o 8, o observador "observerLogFile06" ser� destru�do. O m�todo "kill" retornar� um valor booleano confirmando o sucesso da chamada e o arquivo "result_.csv" conter� apenas informa��es at� o 8o. tempo de simula��o
]]

observersLogFileTest:run()
os.exit(0)
