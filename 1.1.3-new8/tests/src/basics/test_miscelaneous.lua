-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright � 2001-2007 INPE and TerraLAB/UFOP.
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
-- Expected result: 1 teste, 16 assertations, (1 passed, 0 failed, 0 erros)
-- 
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_miscelaneous()

    print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end

	--print("TIME:")
	t1 = os.time()
	
	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") 
	print("Testing Miscelaneous...") io.flush()
	
	f = function(x) return x^3 end
	
	-- exact value: 20.25
	method = integrationEuler
	
	v = method(f, 0, 0, 3, 0.1)
	--print(v)
	assert_equal(16.48360, v, 0.0001)
	
	v = method(f, 0, 0, 3, 0.01)
	--print(v)
	assert_equal(20.11522, v, 0.0001)
	
	v = method(f, 0, 0, 3, 0.001)
	--print(v)
	assert_equal(20.23650, v, 0.0001)

	v = method(f, 0, 0, 3, 0.0001)
	--print(v)
	assert_equal(20.24595, v, 0.0001)
	
	-- exact value: 20.25
	method = integrationRungeKutta
	v = method(f, 0, 0, 3, 0.1)
	--print(v)
	assert_equal(17.682025, v, 0.0001)
	
	v = method(f, 0, 0, 3, 0.01)
	--print(v)
	assert_equal(20.25, v, 0.0001)
	
	v = method(f, 0, 0, 3, 0.001)
	--print(v)
	assert_equal(20.25, v, 0.0001)

	v = method(f, 0, 0, 3, 0.0001)
	--print(v)
	assert_equal(20.24730, v, 0.0001)
	
	-- exact value: 20.25
	method = integrationHeun
	v = method(f, 0, 0, 3, 0.1)
	--print(v)
	assert_equal(17.70305, v, 0.0001)
	
	v = method(f, 0, 0, 3, 0.01)
	--print(v)
	assert_equal(20.250225, v, 0.0001)
	
	v = method(f, 0, 0, 3, 0.001)
	--print(v)
	assert_equal(20.25, v, 0.0001)

	v = method(f, 0, 0, 3, 0.0001)
	--print(v)
	assert_equal(20.24730, v, 0.0001)
	
	
	--print("NEW FUNC:")
	
	method = integrationHeun
	INTEGRATION_METHOD = integrationHeun
	df = function(x, y) return y - x^2+1 end
	a = 0
	b = 2
	init = 0.5
	delta = 0.2
	x = 0
	y = 0
	result1 = method(df, init, a, b, delta)
	--print(result1)
	
	a = 0
	b = 2
	init = 0.5
	delta = 0.2
	x = 0
	y = 0
	result2 = d{df, init, a, b, delta}
	--print(result2)
	assert_equal(5.23305, result1, 0.0001)
	assert_equal( result1, result2)
	
	
	for i = 1, 400000000 do end
	t2 = os.time()
	--print(t2-t1)
	--print(elapsedTime(t2-t1))
	assert_string(elapsedTime(t2-t1))
	
	print("READY!!!")
	assert_true(true)

end


functionList = {
    [1] = "test_miscelaneous"
}

SKIPS = executeBasics("miscelaneous", functionList, skips)

lunatest.run()

os.exit(0)
