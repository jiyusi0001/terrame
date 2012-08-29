--[[
para gerar os arquivos que servirão como comparação comente dentro do for a linha "generateAnswer(name,compareResult
(name))", esses arquivos serão gerados em /tests/dependencies/results, o arquivo final_result.txt (gerado de onde está
sendo executado o teste) exibe se está ou não OK cada teste
--]]

dofile (TME_PATH .."//tests//run//run_util.lua")

function createTempDemo()
    local file=io.open(RESULT_PATH.."temp.txt","w")
    print(">> Database type: ")io.flush()
	print("\t0 : MySQL")io.flush()
	print("\t1 : MSAccess")io.flush()
	
    local dbType = tonumber(io.read())
    local pass="pwd"
    if(dbType==0) then
        print(">> MySQL password: ")io.flush()
        pass = io.read()
    end
    str = ""
    str = dbType.."\n"..pass
    for i=1, 500, 1 do str = str..("\n") end
    file:write(str)
    file:close()
end

local executeFileName = "TerraME ".. TME_PATH .."//demos//"

local testName ={
    "demo00_two_systems",
    "demo01_discrete_rain",
    "demo02_continuous_rain",
    "demo03_continuous_rain",
    "demo04_rain_geoDB", 
    "demo05_rain_geoDB_image",
    "demo06_deforestation", 
    "demo07_simple_fire_spread",
    "demo08_fire_spread",
    "demo09_ostrom_game",
    "demo10_ostrom_game_observer",
    "demo11_rain_geodb_observer",
    "demo12_amazonia_deforestation",
    "demo13_beer",
    "demo14_cabecadeboi",
    "demo15_el_farol",
    "demo16_gameoflife_automata",
    "demo17_ipd",
    "demo18_leotief_agents_bwss_c5",
    "demo19_mobility_initial",
    "demo20_predator_prey",
    "demo21_schelling",
    "demo22_spatial_games",
    "demo23_observer_timer",
    "demo24_observer_agent",
    "demo25_observer_automaton"
 }

createTempDemo()

execute("demos", testName, executeFileName,"","result_demos_","demos_final_report.txt")