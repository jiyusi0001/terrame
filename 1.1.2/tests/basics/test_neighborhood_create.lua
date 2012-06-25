-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2007 INPE and TerraLAB/UFOP.
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
-- Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
-------------------------------------------------------------------------------------------
-- Expected result: 1 teste, 419 assertations, (1 passed, 0 failed, 0 erros)
--

arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
require "lunatest"


function test_NeighborhoodCreationMethods()

	cs = CellularSpace{
		xdim=10
	}
	assert_not_nil(cs)
	assert_equal(100, cs:size())
	
	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=")
	print("Testing Neighborhood...") io.flush()
	
	--print("MOORE")
	--createMooreNeighborhood(cs, "moore")
    cs:createNeighborhood {
		strategy = "moore",
        name = "moore"
	}	
	
	x={}
	x[9]=0
	x[4]=0
	x[6]=0
	
	forEachCell(cs, function(c)
		n = c:getNeighborhood("moore")		
        assert_not_nil(n)
		x[n:size()] = x[n:size()] + 1
	end)
	--table.foreach(x, print)
	
	assert_equal(32, x[6])
	assert_equal(4,  x[4])
	assert_equal(64, x[9])
	
	print("CREATE 3x3")
	filterF = function(c,c) return true end
	weightF = function(c,c) return 1 end
	--create3x3Neighborhood(cs, filterF, weightF, "moore")

    cs:createNeighborhood {
		strategy = "3x3",
		filter = filterF,
		weight = weightF,
        name = "moore"
	}

	x={}
	x[9]=0
	x[4]=0
	x[6]=0
	
	forEachCell(cs, function(c)
		n = c:getNeighborhood("moore")
		assert_not_nil(n)
		x[n:size()] = x[n:size()] + 1
	end)
	
	--table.foreach(x, print) io.flush()
	assert_equal(32, x[6])
	assert_equal(4,  x[4])
	assert_equal(64, x[9])
	
	
	print("CREATE MxN")
	--createMxNNeighborhood(2, 3, cs, filterF, weightF, "mxn")
    cs:createNeighborhood {
		strategy = "mxn",
   		m = 2, -- ratio
		n = 3, -- ratio
		filter = filterF,
		weight = weightF,
		name = "mxn",
        --self = false
	}

	x = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	
	forEachCell(cs, function(c)
		n = c:getNeighborhood("mxn")
		assert_not_nil(n)
		assert_gte(12,n:size())
		x[n:size()] = x[n:size()] + 1
	end)
	
	--table.foreach(x, print) io.flush()
	assert_equal(4,  x[12])
	assert_equal(4,  x[15])
	assert_equal(4,  x[18])
	assert_equal(16, x[20])
	assert_equal(8,  x[21])
	assert_equal(4,  x[24])
	assert_equal(12, x[25])
	assert_equal(8,  x[28])
	assert_equal(12, x[30])
	assert_equal(24, x[35])

		print("READY!!")
	assert_true(true)
end

SKIP = false
lunatest.run()
