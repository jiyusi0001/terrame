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
-- Expected result: 1 teste, 16 assertations, (1 passed, 0 failed, 0 erros)
-- 

dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

local miscelaneousTest = UnitTest {
	test_miscelaneous = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()

		--print("TIME:")
		t1 = os.time()

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") 
		print("Testing Miscelaneous...") io.flush()

		f = function(x) return x^3 end

		-- exact value: 20.25
		method = integrationEuler

		v = method(f, 0, 0, 3, 0.1)
		--print(v)
		self:assert_equal(16.48360, v, 0.0001)

		v = method(f, 0, 0, 3, 0.01)
		--print(v)
		self:assert_equal(20.11522, v, 0.0001)

		v = method(f, 0, 0, 3, 0.001)
		--print(v)
		self:assert_equal(20.23650, v, 0.0001)

		v = method(f, 0, 0, 3, 0.0001)
		--print(v)
		self:assert_equal(20.24595, v, 0.0001)

		-- exact value: 20.25
		method = integrationRungeKutta
		v = method(f, 0, 0, 3, 0.1)
		--print(v)
		self:assert_equal(17.682025, v, 0.0001)

		v = method(f, 0, 0, 3, 0.01)
		--print(v)
		self:assert_equal(20.25, v, 0.0001)

		v = method(f, 0, 0, 3, 0.001)
		--print(v)
		self:assert_equal(20.25, v, 0.0001)

		v = method(f, 0, 0, 3, 0.0001)
		--print(v)
		self:assert_equal(20.24730, v, 0.0001)

		-- exact value: 20.25
		method = integrationHeun
		v = method(f, 0, 0, 3, 0.1)
		--print(v)
		self:assert_equal(17.70305, v, 0.0001)

		v = method(f, 0, 0, 3, 0.01)
		--print(v)
		self:assert_equal(20.250225, v, 0.0001)

		v = method(f, 0, 0, 3, 0.001)
		--print(v)
		self:assert_equal(20.25, v, 0.0001)

		v = method(f, 0, 0, 3, 0.0001)
		--print(v)
		self:assert_equal(20.24730, v, 0.0001)


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
		self:assert_equal(5.23305, result1, 0.0001)
		self:assert_equal( result1, result2)


		for i = 1, 400000000 do end
		t2 = os.time()
		--print(t2-t1)
		--print(elapsedTime(t2-t1))
		self:assert_string(elapsedTime(t2-t1))

		print("READY!!!")
		self:assert_true(true)

	end,
	test_random_fail01 = function(self)
    print("Fail 01:", random(-1))
  end,
  test_random_fail02 = function(self)
    print("Fail 02", random(10,-1))
  end,
  test_random_fail03 = function(self)
    print("Fail 03", random(-1,-1))
  end,
  test_random_fail04 = function(self)
    print("Fail 04", random(-1,10))
  end,
  test_random_fail05 = function(self)
    print("Fail 05", random())
  end,
  test_random_one_argument = function(self)
    print("1st try with argument '5':", random(5))
    print("2nd try with argument '5':", random(5))
    print("3rd try with argument '5':", random(5))
  end,
  test_random_two_arguments = function(self)
    print("1st try with arguments '15' and '20':", random(15,20))
    print("2nd try with arguments '15' and '20':", random(15,20))
    print("3rd try with arguments '15' and '20':", random(15,20))
  end,
  test_random_reseed = function(self)
    print("First run with seed value '98765'")
    reSeed(98765)
    print("1st try with argument '3':", random(3))
    print("2nd try with argument '3':", random(3))
    print("3rd try with argument '3':", random(3))
    print("1st try with arguments '33' and '45':", random(15,20))
    print("2nd try with arguments '33' and '45':", random(15,20))
    print("3rd try with arguments '33' and '45':", random(15,20))
    print("")
    print("Second run with value seed '56789'")
    reSeed(56789)
    print("1st try with argument '3':", random(3))
    print("2nd try with argument '3':", random(3)) 
    print("3rd try with argument '3':", random(3))
    print("1st try with arguments '33' and '45':", random(15,20))
    print("2nd try with arguments '33' and '45':", random(15,20))
    print("3rd try with arguments '33' and '45':", random(15,20))    
  end
}

miscelaneousTest:run()
