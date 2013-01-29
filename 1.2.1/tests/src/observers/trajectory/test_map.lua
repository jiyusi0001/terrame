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

mim = 0
max = 9
start = 10

--require "XDebug"

-- define o espaco celular
cs = CellularSpace{ xdim = 0}

for i = 1, 10, 1 do 
	for j = 1, 10, 1 do 
		c = Cell{ cover = AGUA,agents_ = {}}
		c.height_ = i
		c.path = 0
		c.x = i - 1
		c.y = j - 1
		c.cont=i*j
		c.cover = 1
		cs:add( c )
	end
end

-- Define a trajetória tr1

down = 1
up = 2
left = 3
right = 4

tr1 = Trajectory{
	target = cs,
	select = function(cell)
		if((cell.cont <= max+1 and cell.cont > mim+1) and cell.x==mim) then
			cell.path = up
			return true
		end
		if((cell.cont <= max and cell.cont > mim) and cell.y==mim) then
			cell.path = right
			return true
		end
		if((cell.cont >= max and cell.cont <= max*max+2*max+1) and cell.x == max) then
			cell.path = down
			return true
		end
		return false
	end,
	sort = function(a,b)
		if(a.path == right) then	
			return a.x<b.x 
		elseif(a.path == left) then	
			return a.x>b.x 
		elseif(a.path == down) then
			return a.y<b.y;	
		elseif(a.path == up) then
			return a.y>b.y
		end
	end,
	valor1 = 1,
	valor2 = 1,
	t = 0
}

-- Define a trajetória tr2

oldFilter = function(cell)
	if(cell.x == cell.y) then
		return true
	end
	return false
end

oldSort = function(a,b)
	return a.x<b.x
end


newFilter = function(cell)
	if(cell.x+cell.y == 9) then
		return true
	end
	return false
end

newSort = function(a,b)
	return a.x<b.x
end

tr2 = Trajectory{
	target = cs,
	select = oldFilter,
	sort = newSort
}

-- Define as legendas

coverLeg = Legend{
	type = "number",
	grouping = "uniquevalue",
	slices = 5,
	precision = 6,
	stdDeviation = "none",
	maximum = 1,
	minimum = 0,
	colorBar = {
		{
			color = "black", 
			value = 1
		},
		{
			color = "blue",
			value = 0
		}						
	}
}

tr1Leg = Legend {
	type = "number",
	grouping = "equalsteps",
	stdDeviation = "none",
	maximum = 28,
	minimum = 0,
	slices = 28,
	precision = 2,
	colorBar = {
		{
			color = "green",
			value = 0
		},
		{	
			color = "blue", 
			value = 28
		}
	},
	style = "dots",
	width = 5,
	symbol = CROSS
}

tr2Leg = Legend {
	type = "number",
	grouping = "equalsteps",
	stdDeviation = "none",
	maximum = 10,
	minimum = 0,
	slices = 10,
	precision = 2,
	colorBar = {
		{
			color = "red",
			value = 0
		},
		{	
			color = "yellow",
			value = 10
		}
	},
	symbol = UTRIANGLE
}

obsMap = Observer{ subject = cs, type = "map", attributes={"cover"}, legends = {coverLeg} }

local observersMapTest = UnitTest {
	-- ================================================================================ #
	-- OBSERVER MAP
	test_map01 = function(x)
		-- OBSERVER MAP 01 
		print("OBSERVER MAP 01") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "map" )
		observerMap01 = Observer{ subject = tr1, type = "map" }
	end,
	test_map02 = function(x)
		-- OBSERVER MAP 02 
		print("OBSERVER MAP 02") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "map", {obsMap} )
		observerMap02 = Observer{ subject = tr1, type = "map", observer = obsMap}
	end,
	test_map03 = function(x)
		-- OBSERVER MAP 03
		print("OBSERVER MAP 03") io.flush()
		--@DEPRECATED
		--tr1:createObserver("map", {cs})
		observerMap03 = Observer{ subject = tr1, type = "map"}
	end,
	test_map04 = function(x)
		-- OBSERVER MAP 04
		print("OBSERVER MAP 04") io.flush()
		--@DEPRECATED
		--tr1:createObserver("map", {cs,obsMap})
		observerMap04 = Observer{ subject = tr1, type = "map", observer = obsMap}
	end,
	test_map05 = function(x)
		-- OBSERVER MAP 05
		print("OBSERVER MAP 05") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
		observerMap05=Observer{subject=tr1, type = "map", legends={tr1Leg}, observer = obsMap }
	end,
	test_map06 = function(x)
		-- OBSERVER MAP 06
		print("OBSERVER MAP 06") io.flush()
		tr1.cont=0
		--@DEPRECATED
		--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
		observerMap06=Observer{subject=tr1, type = "map", attributes={"cont"},legends={tr1Leg}, observer = obsMap }
	end,
	test_map07 = function(x)
		-- OBSERVER MAP 07
		print("OBSERVER MAP 07") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "map", {"trajectory"}, {cs,obsMap, tr1Leg } )
		observerMap07=Observer{subject=tr1, type = "map", attributes={"trajectory"},legends={tr1Leg}, observer = obsMap }
	end,
	test_map08 = function(x) --com trajetória dinamica
		-- OBSERVER MAP 08
		print("OBSERVER MAP 08") io.flush()
		--@DEPRECATED
		--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
		observerMap08=Observer{subject=tr2, type = "map", legends={tr2Leg}, attributes={"trajectory"}, observer = obsMap }
		for i = 1, 10, 1 do
			print("STEP:",i)
			if(i%2==0)then
				tr2:filter(newFilter)
			else
				tr2:filter(oldFilter)
			end
			cs:notify()
			delay_s(1)
		end
	end,
	test_map09 = function(x) --com trajetória dinamica
		-- OBSERVER MAP 09
		print("OBSERVER MAP 09") io.flush()
		--@DEPRECATED
		--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
		observerMap09=Observer{subject=tr2, type = "map", legends={tr2Leg}, attributes={"trajectory"}, observer = obsMap }

		killObserver = true

		for i = 1, 10, 1 do
			print("STEP:",i)io.flush()
			if(i%2==0)then
				tr2:filter(newFilter)
			else
				tr2:filter(oldFilter)
			end

			if ((killObserver and observerMap09) and (i == 8)) then
				print("", "observerMap09:kill", observerMap09:kill())io.flush()
			end

			cs:notify()
			delay_s(1)
		end
	end
}

-- TESTES OBSERVER MAP
--[[

MAP 01/06
Programa deverá apresentar um erro, pois não será achado o parâmetro do observer.

MAP 02 / MAP 03 / MAP 04
Programa deverá criar um 'observer' do tipo 'map', para então rodar o modelo de MAP.

MAP 05
Programa deverá criar um 'observer' do tipo 'map' e legenda 'tr1Leg', para então rodar o modelo de MAP.

MAP 06
Idem MAP 05, mas com um atributo a mais 'cont'.

MAP 07
Idem MAP 05, mas com um atributo a mais 'trajectory'.

MAP 08
Programa deverá criar um 'observer' do tipo 'map', legendas 'tr2Leg' e atributo 'trajectory' e então apresentará um mapa que a cada passo de execução deverá haver uma faixa na diagonal com escala de vermelho a amarelo, mudando da diagonal principal par a secundária e assim por diante.

MAP 09
Idem MAP 08, exceto que o map deverá ser abortado após o passo 8, ou seja, antes de acabar a execução do modelo.

]]

observersMapTest:run()
os.exit(0)
