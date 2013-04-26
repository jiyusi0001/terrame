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
--      Raian Vargas Maretto  
-- 			Rodrigo Reis Pereira
--			Henrique Cota Camêlo
--			Washington Sena França e Silva
-------------------------------------------------------------------------------------------
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

local cs1 = CellularSpace{
	xdim = 20
}

forEachCell(
cs1,
function(cell)
	cell.dist_roads = 10 * (cell.x * cell.y)/(cell.x + cell.y)
end
)

cs1:createNeighborhood{ name = "Moore_test1", strategy = "moore", self = false }

local maxWeight = 0;
local minWeight = math.huge;
local maxDist = 0;
local minDist = math.huge;

forEachCell(
cs1,
function(cell)

	if(cell.dist_roads > maxDist)then
		maxDist = cell.dist_roads;
	end	
	if(cell.dist_roads < minDist)then
		minDist = cell.dist_roads;
	end

	forEachNeighbor(
	cell, 
	"Moore_test1",
	function(cell, neigh, weight)
		if(weight > maxWeight)then
			maxWeight = weight;
		end
		if(weight < minWeight)then
			minWeight = weight;
		end
	end
	)
end
)
csLegend = Legend{
	type = TME_LEGEND_TYPE.NUMBER,
	grouping = TME_LEGEND_GROUPING.EQUALSTEPS,
	slices = 6,
	precision = 4,
	maximum = maxDist,
	minimum = minDist,
	colorBar = {
		{color = {0, 255, 0}, value = 0},
		{color = {255, 0, 0}, value = 1}
	}
}                

neighLegend = Legend{
	type = TME_LEGEND_TYPE.NUMBER,
	grouping = TME_LEGEND_GROUPING.EQUALSTEPS,
	slices = 6,
	precision = 3,
	maximum = maxWeight,
	minimum = minWeight,
	width = 5,
	colorBar = {
		{color = {0, 0, 255}, value = 0},
		{color = {255, 0, 0}, value = 1}
	}
}

obsCellSpace = Observer{
	subject = cs1,
	type = TME_OBSERVERS.MAP,
	attributes = {"dist_roads"},
	legends = {csLegend}
}
cs1:notify()

obsNeigh = nil

mapFor = function( killObserver,unitTest )
	for i = 1, 10, 1 do
		print("step", i)
		cs1.counter = i
		cs1:notify(i)

		if ((killObserver and observerTextScreen05) and (i == 8)) then
			print("", "observerTextScreen05:kill", observerTextScreen05:kill())
		end

		delay_s(1)
	end

	cs1:notify();
	unitTest:assert_true(true) 

end

-- ================================================================================#
local observersNeighborhoodTest = UnitTest {
	test_Map01 = function(unitTest) 
		-- OBSERVER MAP 01 
		print("MAP 01")
		forEachCell(
		cs1,
		function( cell )
			tabObs = {};
			obsNeigh = Observer{
				subject = cell,
				type = "neighborhood",
				observer = obsCellSpace,
				cellspace = cs1,
				neighIndex = {"Moore_test1"},
				neighType = "basic",
				legends = {neighLegend}
			}           
			cs1:notify()
			print("observer:kill(): ", obsNeigh:kill())
		end
		);
		mapFor(false,unitTest)
		unitTest:assert_equal("neighborhood",obsNeigh.type)
	end,

	test_Map02 = function(unitTest) 
		-- OBSERVER MAP 02 
		print("MAP 02")

		tabObs = {};

		forEachCell(
		cs1,
		function( cell )
			print("\n------------------------------------------------")
			print("creating Observer Neigh for the cell "..cell:getID())
			obsNeigh = Observer{
				subject = cell,
				type = "neighborhood",
				observer = obsCellSpace,
				cellspace = cs1,
				neighIndex = {"Moore_test1"},
				neighType = "basic",
				legends = {neighLegend}
			}

			cs1:notify();

			table.insert(tabObs, obsNeigh);

			if(#tabObs >= 2)then
				print("\n------------------------------------------------")
				print("Killing observer Neigh from the cell "..tabObs[1].subject:getID())
				print("Kill returned ", tabObs[1]:kill())
				table.remove(tabObs, 1)

				cs1:notify();
			end	
			cs1:notify();
		end
		);
		for i, obs in pairs(tabObs) do
			print("\n------------------------------------------------")
			print("Killing observer Neigh from the cell "..obs.subject:getID())
			print("observer:kill(): ", obs:kill())
			cs1:notify();
		end
		mapFor(false,unitTest)
		unitTest:assert_equal("neighborhood",obsNeigh.type)
	end		
}
-- TESTES OBSERVER MAP
--[[
MAP 01

MAP 02

]]

observersNeighborhoodTest:run()
os.exit(0)
