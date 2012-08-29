--[[
para gerar os arquivos que servirão como comparação comente dentro do for a linha "generateAnswer(name,compareResult
(name))", esses arquivos serão gerados em /tests/dependencies/results, o arquivo final_result.txt (gerado de onde está
sendo executado o teste) exibe se está ou não OK cada teste
--]]

dofile (TME_PATH.."/tests/run/run_util.lua")

local executeFileName = "TerraME ".. TME_PATH .."/tests/run/observers/"

function createTempObservers()
	file=io.open(RESULT_PATH.."temp.txt","w")
    file:write(0 .."\n")
    str=""
    for i=1, 500, 1 do str = str..("\n") end
    file:write(str)
    file:close()
    --createDataBaseTemp()
end

local testName = {
    "agent",
    "automaton",
    "cell",
    "cellular_space",
    "environment", 
    "event",
    "society",
    "timer",
    "trajectory"
}

initialize()

createTempObservers()

execute("observers", testName, executeFileName,"run_test_observers_","result_test_observer_","observers_final_report.txt")

