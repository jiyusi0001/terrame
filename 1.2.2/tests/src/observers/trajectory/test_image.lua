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
dofile(TME_PATH.."/tests/run/run_util.lua")
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")
dofile(TME_PATH.."/tests/dependencies/TestConf.lua")

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

imageFor = function( killObserver,unitTest,testNumber,prefix) 
    if prefix == nil then
        prefix = "result_"
    end
	for i = 1, 10, 1 do
		print("STEP:",i)io.flush()
		if(i%2==0)then
			tr2:filter(newFilter)
		else
			tr2:filter(oldFilter)
		end
		cs:notify()
		delay_s(1)
        
        if i<10 then
            unitTest:assert_image_match("./"..prefix.."00000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/trajectory/test_image/test_image"..testNumber.."/"..prefix.."00000"..i..".png")
        else
            unitTest:assert_image_match("./"..prefix.."0000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/trajectory/test_image/test_image"..testNumber.."/"..prefix.."0000"..i..".png")
        end
	end
end

obsImage = Observer{ subject = cs, type = "image", attributes={"cover"}, legends = {coverLeg} }

local observersImageTest = UnitTest {
	test_image01 = function(unitTest)
		-- OBSERVER IMAGE 01 
		print("OBSERVER IMAGE 01") io.flush()
		observerImage01 = Observer{ subject = tr1, type = "image" }
		imageFor(false,unitTest,"01")
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage01.type)
	end,
	test_image02 = function(unitTest)
		-- OBSERVER IMAGE 02 
		print("OBSERVER IMAGE 02") io.flush()
		observerImage02 = Observer{ subject = tr1, type = "image", observer = obsImage}
		imageFor(false,unitTest,"02")
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage02.type)
	end,
	test_image03 = function(unitTest) 
		-- OBSERVER IMAGE 03
		print("OBSERVER IMAGE 03") io.flush()
		observerImage03=Observer{subject=tr1, type = "image",legends={tr1Leg}, observer = obsImage }
		imageFor(false,unitTest,"03")
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage03.type)
	end,
	test_image04 = function(unitTest)
		-- OBSERVER IMAGE 04
		print("OBSERVER IMAGE 04") io.flush()
		tr1.cont=0
		observerImage04=Observer{subject=tr1, type = "image", attributes={"cont"},legends={tr1Leg}, observer = obsImage }
		imageFor(false,unitTest,"04")
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage04.type)
	end,
	test_image05 = function(unitTest)
		-- OBSERVER IMAGE 05
		print("OBSERVER IMAGE 05") io.flush()
		observerImage05=Observer{subject=tr1, type = "image", attributes={"trajectory"},legends={tr1Leg}, observer = obsImage }
		imageFor(false,unitTest,"05")
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage05.type)
	end,
	test_image06 = function(unitTest)
		-- OBSERVER IMAGE 06
		print("OBSERVER IMAGE 06") io.flush()
		observerImage06=Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage} 
		imageFor(false,unitTest,"06")
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage06.type)
	end,
	test_image07 = function(unitTest)
		-- OBSERVER IMAGE 07
		print("OBSERVER IMAGE 07") io.flush()
		observerImage07 = Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage}

		killObserver = true

		for i = 1, 10, 1 do
			print("STEP:", i)io.flush()
			if(i%2==0)then
				tr2:filter(newFilter)
			else
				tr2:filter(oldFilter)
			end

			if ((killObserver and observerImage07) and (i == 8)) then
				print("", "observerImage07:kill", observerImage07:kill())io.flush()
			end

			cs:notify()
			delay_s(1)
		end
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage07.type)
	end,
	test_image08 = function(unitTest)
		-- OBSERVER IMAGE 08
		print("OBSERVER IMAGE 08") io.flush()
		obsImage08 = Observer{ subject = cs, type = "image", attributes={"cover"}, legends = {coverLeg},path =TME_ImagePath ,prefix = "prefix_" }
		observerImage08=Observer{subject=tr2, type = "image",legends={tr2Leg}, attributes={"trajectory"}, observer = obsImage08} 
		-- , path="./Lua",prefix = "prefix_" }
		for i = 1, 10, 1 do
			print("STEP:",i)io.flush()
			if(i%2==0)then
				tr2:filter(newFilter)
			else
				tr2:filter(oldFilter)
			end
			cs:notify()
			if i<10 then
                unitTest:assert_image_match(TME_ImagePath.."/".."prefix_00000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/trajectory/test_image/test_image08".."/".."prefix_00000"..i..".png")
            else
                unitTest:assert_image_match(TME_ImagePath.."/".."prefix_0000"..i..".png",TME_PATH.."/tests/dependencies/results/linux/observers/trajectory/test_image/test_image08".."/".."prefix_0000"..i..".png")
            end
		end        
        	
        moveFilesToResults(TME_ImagePath,TME_PATH..TME_DIR_SEPARATOR.."bin"..TME_DIR_SEPARATOR.."results"..TME_DIR_SEPARATOR.."observers".. TME_DIR_SEPARATOR.."trajectory"..TME_DIR_SEPARATOR.."test_image"..TME_DIR_SEPARATOR.."test_image08",".png")
        
        if os.isUnix() then
		    os.capture("rm "..TME_ImagePath.."/prefix_*".. " > /dev/null 2>&1 ")
	    else
		    --removeCommand = "del *"..extension.." >NUL 2>&1"
        end	
		unitTest:assert_true(true) 
		unitTest:assert_equal("image",observerImage08.type)
	end
}

-- TESTES OBSERVER IMAGE
--[[

IMAGE 01 / IMAGE 03
Programa deverá apresentar um erro com relação ao parâmetro 'observer', que não será achado.

IMAGE 02 / IMAGE 04
Programa deverá criar uma 'image' do tipo 'observer, mas sem apresentar ou criar alguma imagem.


IMAGE 05 
Programa deverá  criar uma 'image' do tipo observer e com a legenda 'tr1leg'.

IMAGE 06
Idem IMAGE 05, com exceção do atributo adicional 'cont'.

IMAGE 07 / IMAGE 08
Programa deverá apresentar uma janela com os parâmetros enquanto o modelo é executado. Dez imagens são geradas como resultado, todas com uma escala de vermelhor para amarelo no canto esquerdo.

IMAGE 08
TODO
]]

observersImageTest:run()
os.exit(0)
