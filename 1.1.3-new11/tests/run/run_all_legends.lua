dofile (TME_PATH.."//tests//run//run_util.lua")

local executeFileName = "TerraME ".. TME_PATH .."//tests//src//observers//"

function createTempLegends()
	file=io.open(RESULT_PATH.."temp.txt","w")
    file:write(0 .."\n")
    str=""
    for i=1, 500, 1 do str = str..("\n") end
    file:write(str)
    file:close()
end

initialize()

createTempLegends()

local testLegend = {"legends"}

execute("legends", testLegend, executeFileName,"test_","result_test_","legends_final_report.txt")