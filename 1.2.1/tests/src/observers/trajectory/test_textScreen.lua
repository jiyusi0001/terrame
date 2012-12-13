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

textScreenFor = function(killObserver)
	for i = 1, 10, 1 do
		print("STEP:",i)io.flush()
		tr1.valor1 = tr1.valor1*i
		tr1.valor2 = 1/tr1.valor2*i
		tr1.t = i*2
		tr1:notify(i)
		if ((killObserver and observerTextScreen04) and (i == 8)) then
			print("", "observerTextScreen04:kill", observerTextScreen04:kill())io.flush()
		end
		delay_s(1)
	end
end

local observersTextScreenTest = UnitTest {
	-- ================================================================================#
	-- OBSERVER TEXTSCREEN
	test_textScreen01 = function(x)
		-- OBSERVER TEXTSCREEN 01
		print("OBSERVER TEXTSCREEN 01") io.flush()
		observerTextScreen01 = Observer{subject = tr1, type = "textscreen"}
    textScreenFor(false)
	end,
	test_textScreen02 = function(x)
		-- OBSERVER TEXTSCREEN 02
		print("OBSERVER TEXTSCREEN 02") io.flush()
		observerTextScreen02 = Observer{subject = tr1, type = "textscreen", attributes={}}
    textScreenFor(false)
	end,
	test_textScreen03 = function(x)
		-- OBSERVER TEXTSCREEN 03
		print("OBSERVER TEXTSCREEN 03") io.flush()
		observerTextScreen03 = Observer{subject = tr1, type = "textscreen", attributes={"valor1","valor2"}}
    textScreenFor(false)
	end,
	test_textScreen04 = function(x)
		-- OBSERVER TEXTSCREEN 04
		print("OBSERVER TEXTSCREEN 04")io.flush()
		observerTextScreen04 = Observer{ subject = tr1, type = "textscreen", attributes={}}
    textScreenFor(true)
	end
}

observersTextScreenTest:run()
os.exit(0)
