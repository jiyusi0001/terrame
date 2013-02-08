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
dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

local abmTest = UnitTest {
	test_abm_basic_agent = function(unitTest)
		singleFooAgent = Agent {
			size = 10,
			name = "foo",
			execute = function(self)
				self.size = self.size + 1
				self:move(self:getCell():getNeighborhood():sample())
			end
		}

		cs = CellularSpace {
			xdim = 10,
			ydim = 10
		}

		cs:createNeighborhood{strategy = "moore"}

		e = Environment {
			cs,
			singleFooAgent
		}

		e:createPlacement{strategy = "random"}

		t = Timer {
			Event{action = singleFooAgent}
		}

		t:execute(10)
		unitTest:assert_equal( 20,singleFooAgent.size)
		--print(singleFooAgent.size) -- 20
		unitTest:assert_equal("Cell",type(singleFooAgent:getCell()))
		--print(type(singleFooAgent:getCell())) -- "Cell"

		count = 0
		forEachCell(cs, function(cell)
			count = count + cell.placement:size()
		end)
		unitTest:assert_equal(1,count)
		--assert_true(true)
		--print(count) -- 1
	end,

	test_abm_basic_society = function(unitTest)

		--randomizeseed(0)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)    

		singleFooAgent = Agent {
			size = 10,
			name = "foo",
			execute = function(self)
				self.size = self.size + 1
				self:randomWalk()
			end
		}

		findCounter = 0
		nonFooAgent = Agent {
			name = "nonfoo",
			init = function(self)
				--self.age = random(10)
        self.age = randomObj:integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
				self:randomWalk()

				forEachAgent(self:getCell(), function(agent)
					if agent.name == "foo" then
						findCounter = findCounter + 1
					end
				end)
			end
		}

		nonFooSociety = Society {
			instance = nonFooAgent,
			quantity = 50
		}

		sum = 0
		forEachAgent(nonFooSociety, function(ag)
			sum = sum + ag.age
		end)

    unitTest:assert_equal(239,sum)
		--print("ttttt", sum) -- 258

		cs = CellularSpace {
			xdim = 10,
			ydim = 10
		}

		cs:createNeighborhood{strategy = "moore"}

		env = Environment {nonFooSociety, cs, singleFooAgent}

		env:createPlacement{strategy = "random", max = 1}

		t = Timer {
			Event {action = nonFooSociety},
			Event {action = singleFooAgent}
		}

		t:execute(10)

		--unitTest:assert_equal( 5,findCounter)
    unitTest:assert_equal(5,findCounter)
		--print("opa---->>>", findCounter) -- 5

		count = 0
		forEachCell(cs, function(cell)
			count = count + cell.placement:size()
		end)
		unitTest:assert_equal(51,count)
		--print(count) -- 51
	end,

	test_abm_basic_clone = function(unitTest)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)

		received = 0
		nonFooAgent = Agent {
			name = "nonfoo",
			init = function(self)
				--self.age = random(10)
        self.age = randomObj:integer(10)
				if self.age < 5 then
					self.name = "foo"
				end
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		soc = Society {
			instance = nonFooAgent,
			quantity = 10
		}

		g = Group{
			target = soc,
			select = function(ag) return ag.age > 5 end
		}	

		g2 = g:clone()
    
    unitTest:assert_equal(6,g:size())
    unitTest:assert_equal(6,g2:size())
	end,

	test_abm_basic_group = function(unitTest)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)

		nonFooAgent = Agent {
			name = "nonfoo",
			init = function(self)
				--self.age = random(10)
        self.age = randomObj:integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		nonFooSociety = Society {
			instance = nonFooAgent,
			quantity = 10
		}

		g = Group {
			target = nonFooSociety,
			select = function(ag)
				return ag.age > 5
			end
		}
    
    unitTest:assert_equal(6,g:size())
		sum = 0
		forEachAgent(g, function(ag)
			sum = sum + ag.age
		end)
    
		unitTest:assert_equal(49,sum)

		g = Group {
			target = nonFooSociety,
			greater = function(a, b)
				return a.age > b.age
			end
		}

		unitTest:assert_equal(10,g:size())
		--print(g:size()) -- 10
		unitTest:assert_equal(10,g.agents[1].age)
		--print(g.agents[1].age) -- 10
		unitTest:assert_equal(0,g.agents[10].age)
		--print("opa>>>",g.agents[10].age) -- 1

		g = Group {
			target = nonFooSociety,
			select = function(ag)
				return ag.age < 8
			end,
			greater = function(a, b)
				return a.age < b.age
			end
		}

    --print("aaaa", g.agents[1].age)
		unitTest:assert_equal(0, g.agents[1].age)
    --print("bbbb", g.agents[7].age)
		unitTest:assert_equal(6,g.agents[6].age)
		nonFooSociety:execute()
		g:rebuild()
    --print("cccc", g:size())
		unitTest:assert_equal(6,g:size())

		g:execute()
		g:execute()
		g:execute()
		g:rebuild()

		unitTest:assert_equal(3,g:size())
		--print("dddd", g:size()) -- 5

		unitTest:assert_equal(5,g.agents[1].id)
		--print("eeeee",g.agents[1].id) -- 2
		
		g:randomize()
		unitTest:assert_equal(5,g.agents[1].id)
		--print("fffff",g.agents[1].id) -- 3
	end,

	test_abm_basic_life_span = function(unitTest)

		predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self) return self.energy end
		}

		predators = Society{instance = predator, quantity = 5}
		unitTest:assert_equal(5,predators:size())
		--print(predators:size()) -- 5
		dead = predators.agents[2]
		predators.agents[2]:die()
		unitTest:assert_equal(4,predators:size())
		--print(predators:size()) -- 4

		-- do not remove the double parentheses
		print((pcall(function() print(dead.a) end))) -- false

		predators.agents[4]:reproduce()
		unitTest:assert_equal(5,predators:size())
		--print(predators:size()) -- 5

		cont = 3
		sum = 0
		forEachAgent(predators, function(agent)
			sum = sum + agent:execute()
			if cont == 3 then predators.agents[3]:die() end
			if cont == 1 then predators.agents[4]:die() end
			cont = cont - 1
		end)
		unitTest:assert_equal(120,sum)
		--print(sum) -- 120
		unitTest:assert_equal(3,predators:size())
		--print(predators:size()) -- 3

		forEachAgent(predators, function(agent)
			agent:reproduce()
		end)
		unitTest:assert_equal(6,predators:size())
		--print(predators:size()) -- 6
	end,

	test_abm_basic_message = function(unitTest)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)

		received = 0
		nonFooAgent = Agent {
			name = "nonfoo",
			init = function(self)
				--self.age = random(10)
          self.age = randomObj:integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end,
			on_message = function(m)
				received = received + 1
			end
		}

		soc = Society {
			instance = nonFooAgent,
			quantity = 0
		}

		john   = soc:add() -- get a randomize agent from the society
		john.name = "john"
		mary   = soc:add()
		mary.name = "mary"
		myself = soc:add()

		friends = SocialNetwork()
		friends:add(john)
		friends:add(mary)

		myself:addSocialNetwork(friends) -- adding two connections to myself
		unitTest:assert_equal(2,myself:getSocialNetwork():size())
		--print(myself:getSocialNetwork():size()) -- 2

		--[[
		forEachAgent(soc, function(ag)
		print(ag.age)
		end)
		--]]

		sum = 0
		forEachConnection(myself, function(self, friend)
			sum = sum + friend.age
		end)

		unitTest:assert_equal(12,sum)
		--print("gggg", sum) -- 4

		forEachConnection(myself, function(self, friend)
			myself:message{receiver = friend}
		end)
		unitTest:assert_equal(2,received)
		--print(received) -- 2

		forEachConnection(myself, function(self, friend)
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
		end)

		--[[
		-- to verify the delayed messages
		forEachElement(soc.messages, function(_, mes)
		forEachElement(mes, print)
		end)
		--]]

		soc:synchronize()
		unitTest:assert_equal(5,received)
		--print(received) -- 5

		t = Timer{
			Event{period = 4, action = soc}
		}

		t:execute(8)
		unitTest:assert_equal(14,received)
		--print("received", received) -- 16

		soc:synchronize(1.1)

		unitTest:assert_equal(16,received)
		--print(received) -- 18

		soc:synchronize(20)
	end,

	test_abm_basic_multiple_placement = function(unitTest)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)

		predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				new_cell = self:getCell("house"):getNeighborhood():sample()
				self:move(new_cell, "house")
				self:randomWalk("stay")
			end
		}

		predators = Society{
			instance = predator,
			quantity = 100
		}

		cs = CellularSpace{xdim = 20}
		cs:createNeighborhood()

		env = Environment{cs, predators}
		env:createPlacement{strategy = "random", max = 1, name = "house"}
		env:createPlacement{strategy = "uniform", name = "stay"}
		env:createPlacement{strategy = "void", name = "workingplace"}

		count_house = 0
		count_stay = 0
		count_wplace = 0
		forEachCell(cs, function(cell)
			count_house  = count_house  + cell.house:size()
			count_stay   = count_stay   + cell.stay:size()
			count_wplace = count_wplace + cell.workingplace:size()
		end)
		unitTest:assert_equal(100,count_house)
		--print(count_house) -- 100
		unitTest:assert_equal(100,count_stay)
		--print(count_stay) -- 100
		unitTest:assert_equal(0,count_wplace)
		--print(count_wplace) -- 0

		max = 0
		forEachCell(cs, function(cell)
			if max < cell.house:size() then
				max = cell.house:size()
			end
		end)
		unitTest:assert_equal(1,max)
		--print(max) -- 1
		unitTest:assert_equal(1,cs.cells[100].stay:size())
		--print(cs.cells[100].stay:size()) -- 1
		unitTest:assert_equal(0,cs.cells[101].stay:size())
		--print(cs.cells[101].stay:size()) -- 0


		predators:execute()
		predators:sample():die()

		count_house = 0
		count_stay = 0
		forEachCell(cs, function(cell)
			count_house = count_house + cell.house:size()
			count_stay = count_stay   + cell.stay:size()
		end)
		unitTest:assert_equal(99,count_house)
		--print(count_house) -- 99
		unitTest:assert_equal(99,count_stay)
		--print(count_stay) -- 99
	end,

	test_abm_basic_placement = function(unitTest)

		predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				self:move(self:getCell():getNeighborhood():sample())
			end
		}

		predators = Society{
			instance = predator,
			quantity = 20
		}

		cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		env = Environment{cs, predators}
		env:createPlacement{strategy = "random", max = 1}

		-- do not remove the double parentheses
		unitTest:assert_equal(false,(pcall(function() env:createPlacement{strategy = "random", max = 1} end)))
		--print((pcall(function() env:createPlacement{strategy = "random", max = 1} end))) -- false

		forEachAgent(predators, function(ag)
			ag:reproduce()
		end)

		predators:execute()

		cont = 0
		forEachCell(cs, function(cell)
			cont = cont + cell.placement:size()
		end)
		unitTest:assert_equal(40,cont)
	end,

	test_abm_basic_social_network = function(unitTest)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)

		predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				new_cell = self:getCell("house"):getNeighborhood():sample()
				self:move(new_cell, "house")
				self:randomWalk("stay")
			end
		}

    print("OPA2")

		predators = Society{
			instance = predator,
			quantity = 100
		}

		predators:createSocialNetwork{probability = 0.5, name = "friends"}
		predators:createSocialNetwork{quantity = 1, name = "boss"}
		predators:createSocialNetwork{func = function() return true end, name = "all"}

		count_prob = 0
		count_quant = 0
		count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + ag:getSocialNetwork("friends"):size()
			count_quant = count_quant + ag:getSocialNetwork("boss"):size()
			count_all   = count_all   + ag:getSocialNetwork("all"):size()
		end)
		
		unitTest:assert_equal(9900,count_prob)
		--print("opa1",count_prob) -- 5300
		unitTest:assert_equal(100,count_quant)
		--print(count_quant) -- 100
		unitTest:assert_equal(10000,count_all)
		--print("opa3",count_all) -- 10000

		cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		env = Environment{cs, predators}
		env:createPlacement{strategy = "random"}

		predators:createSocialNetwork{strategy = "cell", name = "c"}
		predators:createSocialNetwork{strategy = "neighbor", name = "n"}

		count_c = 0
		count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c  + ag:getSocialNetwork("c"):size()
			count_n  = count_n  + ag:getSocialNetwork("n"):size()
		end)

		unitTest:assert_equal(390,count_c)
		--print("opa2", count_c) -- 408

		unitTest:assert_equal(2672,count_n)
		--print("opa3", count_n) -- 2980

	end,

	test_abm_basic_split = function(unitTest)
    local randomObj = RandomObject{}
    randomObj:reSeed(0)

		received = 0
		nonFooAgent = Agent {
			name = "nonfoo",
			init = function(self)
				self.age = randomObj:integer(10)
				if self.age < 5 then
					self.name = "foo"
				end
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		soc = Society {
			instance = nonFooAgent,
			quantity = 10
		}

		g = soc:split("name")

		unitTest:assert_equal(4,g.foo:size())
		--print("opa1", g.foo:size()) -- 7
		unitTest:assert_equal(10,g.foo:size() + g.nonfoo:size())
		--print(g.foo:size() + g.nonfoo:size()) -- 10

		g3 = soc:split(function(ag)
			if ag.age < 3 then return 1
			elseif ag.age < 7 then return 2
			else return 3
			end
		end)

		unitTest:assert_equal(4,g3[2]:size())
		--print("opa2", g3[2]:size()) -- 2
		unitTest:assert_equal(10,g3[1]:size() + g3[2]:size() + g3[3]:size())
		--print("opa3",g3[1]:size() + g3[2]:size() + g3[3]:size()) -- 10
	end
}

abmTest:run()
