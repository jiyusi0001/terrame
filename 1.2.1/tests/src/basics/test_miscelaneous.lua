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
	test_random_integer01 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:integer()
      print("Random value: ", v)
      self:assert_gte(v,0)
      self:assert_lte(v,1)  
    end
  end,
	test_random_integer02 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:integer(10)
      print("Random value: ", v)
      self:assert_lte(v,10)
      self:assert_gte(v,0)
    end
  end,
	test_random_integer03 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do   
      local v = randomObj:integer(-10)
      print("Random value: ", v)
      self:assert_lte(v,0)
      self:assert_gte(v,-10)
    end    
  end,
  test_random_integer04 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:integer(10,20)
      print("Random value: ", v)
      self:assert_lte(v,20)
      self:assert_gte(v,10)
    end
  end,
  test_random_integer05 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:integer(10,10)
      print("Random value: ", v)
      self:assert_equal(v,10)
    end
  end,
  test_random_integer06 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:integer(-10,10)
      print("Random value: ", v)
      self:assert_lte(v,10)
      self:assert_gte(v,-10)
    end
  end,
	test_random_integer07 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:integer(-10,-10)
      print("Random value: ", v)
      self:assert_equal(v,-10)
    end
  end,
	test_random_float01 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:float()
      print("Random value: ", v)
      self:assert_gte(v,0)
      self:assert_lte(v,1)
      self:assert_gte_number_precision(v,0)
    end    
  end,
  test_random_float02 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(54321)
    for i=1,10 do
      local v = randomObj:float(10.1)
      print("Random value: ", v)
      self:assert_gte(v,0)
      self:assert_lte(v,10.505)
      self:assert_gte_number_precision(v,0)
    end
  end,
  test_random_float03 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(54321)
    for i=1,10 do
      local v = randomObj:float(-10.1)
      print("Random value: ", v)
      self:assert_lte(v,0)
      self:assert_gte(v,-10.505)
      self:assert_gte_number_precision(v,0)
    end
  end,
  test_random_float04 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:float(10.1,20.2)
      print("Random value: ", v)
      self:assert_lte(v,20.2)
      self:assert_gte(v,10.1)
      self:assert_gte_number_precision(v,0)
    end
  end,
  test_random_float05 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:float(10.1,10.1)
      print("Random value: ", v)
      self:assert_equal(v,10.1)
      self:assert_gte_number_precision(v,0)
    end
  end,
  test_random_float06 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:float(-10.1,10.1)
      print("Random value: ", v)
      self:assert_lte(v,10.1)
      self:assert_gte(v,-10.1)
      self:assert_gte_number_precision(v,0)
    end
  end,
  test_random_float07 = function(self)
    randomObj = RandomObject {}
    randomObj:reSeed(12345)
    for i=1,10 do
      local v = randomObj:float(-10.1,-10.1)
      print("Random value: ", v)
      self:assert_equal(v,-10.1)
      self:assert_gte_number_precision(v,0)
    end
  end,
  test_random_reseed = function(self)
    randomObj = RandomObject {}
    print("First run with seed value '98765'")
    randomObj:reSeed(98765)
    print("1st try with argument '3':", randomObj:integer(3))
    print("2nd try with argument '3':", randomObj:integer(3))
    print("3rd try with argument '3':", randomObj:integer(3))
    print("1st try with arguments '33' and '45':", randomObj:integer(15,20))
    print("2nd try with arguments '33' and '45':", randomObj:integer(15,20))
    print("3rd try with arguments '33' and '45':", randomObj:integer(15,20))
    print("")
    print("Second run with value seed '56789'")
    randomObj:reSeed(56789)
    print("1st try with argument '3':", randomObj:integer(3))
    print("2nd try with argument '3':", randomObj:integer(3)) 
    print("3rd try with argument '3':", randomObj:integer(3))
    print("1st try with arguments '33' and '45':", randomObj:integer(15,20))
    print("2nd try with arguments '33' and '45':", randomObj:integer(15,20))
    print("3rd try with arguments '33' and '45':", randomObj:integer(15,20))    
  end
}

miscelaneousTest:run()
