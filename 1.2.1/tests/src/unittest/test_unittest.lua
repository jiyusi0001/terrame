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

local unitTest = UnitTest{

    test_fail = function(self)
	    -- the true here is so the test run as a whole still succeeds.
	    --self:fail("This one *should* fail.", true)
    end,

    test_assert = function(self)
	    self:assert_true(true)
    end,

    test_skip = function(self)
	    --self:skip("(reason why this test was skipped)")
    end,

    test_assert_false = function(self)
	    self:assert_false(false)
    end,

    test_assert_nil = function(self)
	    self:assert_nil(nil)
    end,

    test_assert_not_nil = function(self)
	    self:assert_not_nil("foo")
    end,

    test_assert_equal = function(self)
	    self:assert_equal(4, 4)
    end,

    test_assert_equal_tolerance = function(self)
	    --self:assert_equal(4, 4.0001, 0.0001, "Should approximately match")
    end,

    test_assert_not_equal = function(self)
	    self:assert_not_equal("perl", "quality")
    end,

    test_assert_gt = function(self)
	    self:assert_gt(400,8)
    end,

    test_assert_gte = function(self)
	    self:assert_gte(400,8)
	    self:assert_gte(8, 8)
    end,

    test_assert_lt = function(self)
	    self:assert_lt(-2, 8)
    end,

    test_assert_lte = function(self)
	    self:assert_lte(-2, 8)
	    self:assert_lte(8, 8)
    end,

    test_assert_len = function(self)
	    self:assert_len(3, { "foo", "bar", "baz" })
    end,

    test_assert_not_len = function(self)
	    self:assert_not_len(23, { "foo", "bar", "baz" })
    end,

    test_assert_match = function(self)
	    self:assert_match("oo", "string with foo in it")
    end,

    test_assert_not_match = function(self)
	    self:assert_not_match("abba zabba", "foo")
    end,

    test_assert_boolean = function(self)
	    self:assert_boolean(true)
	    self:assert_boolean(false)
    end,

    test_assert_not_boolean = function(self)
	    self:assert_not_boolean("cheesecake")
    end,

    test_assert_number = function(self)
	    self:assert_number(47)
	    self:assert_number(0)
	    self:assert_number(math.huge)
	    self:assert_number(-math.huge)
    end,

    test_assert_not_number = function(self)
	    self:assert_not_number(_G)
	    self:assert_not_number("abc")
	    self:assert_not_number({1, 2, 3})
	    self:assert_not_number(false)
	    self:assert_not_number(function () return 3 end)
    end,

    test_assert_string = function(self)
	    self:assert_string("yarn")
	    self:assert_string("")
    end,

    test_assert_not_string = function(self)
	    self:assert_not_string(23)
	    self:assert_not_string(true)
	    self:assert_not_string(false)
	    self:assert_not_string({"1", "2", "3"})
    end,

    test_assert_table = function(self)
	    self:assert_table({})
	    self:assert_table({"1", "2", "3"})
	    self:assert_table({ foo=true, bar=true, baz=true })
    end,

    test_assert_not_table = function(self)
	    self:assert_not_table(nil)
	    self:assert_not_table(23)
	    self:assert_not_table("lapdesk")
	    self:assert_not_table(false)
	    self:assert_not_table(function () return 3 end)
    end,

    test_assert_function = function(self)
	    self:assert_function(function() return "*splat*" end)
	    self:assert_function(string.format)
    end,

    test_assert_not_function = function(self)
	    self:assert_not_function(nil)
	    self:assert_not_function(23)
	    self:assert_not_function("lapdesk")
	    self:assert_not_function(false)
	    self:assert_not_function(coroutine.create(function () return 3 end))
	    self:assert_not_function({"1", "2", "3"})
	    self:assert_not_function({ foo=true, bar=true, baz=true })
    end,

    test_assert_thread = function(self)
	    self:assert_thread(coroutine.create(function () return 3 end))
    end,

    test_assert_not_thread = function(self)
	    self:assert_not_thread(nil)
	    self:assert_not_thread(23)
	    self:assert_not_thread("lapdesk")
	    self:assert_not_thread(false)
	    self:assert_not_thread(function () return 3 end)
	    self:assert_not_thread({"1", "2", "3"})
	    self:assert_not_thread({ foo=true, bar=true, baz=true })
    end,

    test_assert_userdata = function(self)
	    --self:assert_userdata(io.open("test.lua", "r"))
    end,

    test_assert_not_userdata = function(self)
	    self:assert_not_userdata(nil)
	    self:assert_not_userdata(23)
	    self:assert_not_userdata("lapdesk")
	    self:assert_not_userdata(false)
	    self:assert_not_userdata(function () return 3 end)
	    self:assert_not_userdata({"1", "2", "3"})
	    self:assert_not_userdata({ foo=true, bar=true, baz=true })
    end,

    test_assert_metatable = function(self)
	    self:assert_metatable(getmetatable("any string"), "foo")
	    local t = { __index=string }
	    local val = setmetatable( { 1 }, t)
	    self:assert_metatable(t, val)
    end,

    test_assert_not_metatable = function(self)
	    self:assert_not_metatable(getmetatable("any string"), 23)
    end,

    test_assert_error = function(self)
	    self:assert_error(function ()
		    error("*crash!*")
	    end)
    end,

    test_failure_formatting = function(self)
	    local inv_esc = "str with invalid escape %( in it"
	    self:assert_match(inv_esc, inv_esc, "Should fail but not crash")
    end

}

unitTest.skips = {"test_fail", "test_skip","test_assert_equal_tolerance","test_assert_equal_tolerance","test_failure_formatting"}

unitTest:run()
