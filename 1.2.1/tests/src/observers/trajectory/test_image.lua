-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2012 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--d
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

cs = CellularSpace{ xdim = 0 }
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

tr2 = Trajectory{
	target = cs,
	select = oldFilter,
	sort = newSort
}

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

imageFor = function(killObserver)
	if(case < 8) then cs:notify() end
	print(compareDirectory("trajectory","image",case,"."))io.flush()
end

obsImage = Observer{ subject = cs, type = "image", attributes={"cover"}, legends = {coverLeg} }

local observersImageTest = UnitTest {
	-- ================================================================================#
	-- OBSERVER IMAGE
	test_image01 = function(x)
		-- OBSERVER IMAGE 01 
		print("OBSERVER IMAGE 01") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "image" )
		observerImage01 = Observer{ subject = tr1, type = "image" }
	end,
	test_image02 = function(x)
		-- OBSERVER IMAGE 02 
		print("OBSERVER IMAGE 02") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "image", {obsImage} )
		observerImage02 = Observer{ subject = tr1, type = "image", observer = obsImage}
	end,
	test_image03 = function(x)
		-- OBSERVER IMAGE 03
		print("OBSERVER IMAGE 03") io.flush()
		--@DEPRECATED
		--tr1:createObserver("image", {cs})
		observerImage03 = Observer{ subject = tr1, type = "image"}
	end,
	test_image04 = function(x)
		-- OBSERVER IMAGE 04
		print("OBSERVER IMAGE 04") io.flush()
		--@DEPRECATED
		--tr1:createObserver("image", {cs,obsImage})
		observerImage04 = Observer{ subject = tr1, type = "image", observer = obsImage}
	end,
	test_image05 = function(x) 
		-- OBSERVER IMAGE 05
		print("OBSERVER IMAGE 05") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
		observerImage05=Observer{subject=tr1, type = "image",legends={tr1Leg}, observer = obsImage }
	end,
	test_image06 = function(x)
		-- OBSERVER IMAGE 06
		print("OBSERVER IMAGE 06") io.flush()
		tr1.cont=0
		--@DEPRECATED
		--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
		observerImage06=Observer{subject=tr1, type = "image", attributes={"cont"},legends={tr1Leg}, observer = obsImage }
	end,
	test_image07 = function(x)
		-- OBSERVER IMAGE 07
		print("OBSERVER IMAGE 07") io.flush()
		--@DEPRECATED
		--tr1:createObserver( "image", {"trajectory"}, {cs,obsImage, tr1Leg } )
		observerImage07=Observer{subject=tr1, type = "image", attributes={"trajectory"},legends={tr1Leg}, observer = obsImage }
	end,
	test_image08 = function(x) --com trajetória dinamica
		-- OBSERVER IMAGE 08
		print("OBSERVER IMAGE 08") io.flush()
		--@DEPRECATED
		--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
		observerImage08=Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage} 
		-- , path="./Lua",prefix = "prefix_" }
		for i = 1, 10, 1 do
			print("STEP:",i)io.flush()
			if(i%2==0)then
				tr2:filter(newFilter)
			else
				tr2:filter(oldFilter)
			end
			cs:notify()
			delay_s(1)
		end
	end,
	test_image09 = function(x) --com trajetória dinamica
		-- OBSERVER IMAGE 09
		print("OBSERVER IMAGE 09") io.flush()
		--@DEPRECATED
		--tr2:createObserver( "map", {"trajectory"}, {cs,obsMap, tr2Leg } )
		observerImage09 = Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage}
		-- path="./Lua",prefix = "prefix_" }

		killObserver = true

		for i = 1, 10, 1 do
			print("STEP:", i)io.flush()
			if(i%2==0)then
				tr2:filter(newFilter)
			else
				tr2:filter(oldFilter)
			end

			if ((killObserver and observerImage09) and (i == 8)) then
				print("", "observerImage09:kill", observerImage09:kill())io.flush()
			end

			cs:notify()
			delay_s(1)
		end
	end
}

observersImageTest:run()
os.exit(0)
