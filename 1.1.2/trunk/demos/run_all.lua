-- DBMS Type
-- 0 : mysql
-- 1 : msaccess
if(not dbms) then
	print("-- DBMS Type")
	print("-- 0 : mysql")
	print("-- 1 : msaccess")
	print("Please, enter database type: ")
  	dbms = tonumber(io.read())
end

if (not pwd) then 
  print("Please, enter database password: ")
  pwd=io.read()
end

dofile("demo00_two_systems.lua")
dofile("demo00_two_systems.lua")
dofile("demo01_discrete_rain.lua")
dofile("demo02_continuous_rain.lua")
dofile("demo03_continuous_rain.lua")
dofile("demo04_rain_geoDB.lua")
dofile("demo05_rain_geoDB_image.lua")
dofile("demo06_deforestation.lua")
dofile("demo07_simple_fire_spread.lua")
dofile("demo08_fire_spread.lua")
dofile("demo09_ostrom_game.lua")
dofile("demo10_ostrom_game_observer.lua") 
dofile("demo11_rain_geodb_observer.lua")
dofile("demo12_amazonia_deforestation.lua")
dofile("demo13_beer.lua")
dofile("demo14_cabecadeboi.lua")
dofile("demo15_el_farol.lua")
dofile("demo16_gameoflife_automata.lua")
dofile("demo17_ipd.lua")
dofile("demo18_leontief_agents_bwss_c5.lua")
dofile("demo19_mobility_initial.lua")
dofile("demo20_predator_prey.lua")
dofile("demo21_schelling.lua")
dofile("demo22_spatial_games.lua")
dofile("demo23_observer_timer.lua")
dofile("demo24_observer_agent.lua")
dofile("demo25_observer_automaton.lua")
