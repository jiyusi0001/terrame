arg = "nada"
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_abm_basic_agent()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end
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
	assert_equal( 20,singleFooAgent.size)
	--print(singleFooAgent.size) -- 20
	assert_equal("Cell",type(singleFooAgent:getCell()))
	--print(type(singleFooAgent:getCell())) -- "Cell"

	count = 0
	forEachCell(cs, function(cell)
		count = count + cell.placement:size()
	end)
	assert_equal(1,count)
	--assert_true(true)
	--print(count) -- 1
end

function test_abm_basic_society()
	if (SKIPS[2]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

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
		self.age = math.random(10)
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
	
	assert_equal( 258,sum)
	--print(sum) -- 258


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

	assert_equal( 5,findCounter)
	--print(findCounter) -- 5

	count = 0
	forEachCell(cs, function(cell)
		count = count + cell.placement:size()
	end)
	assert_equal(51,count)
	--print(count) -- 51

end

function test_abm_basic_clone()
	if (SKIPS[3]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

	received = 0
	nonFooAgent = Agent {
		name = "nonfoo",
		init = function(self)
			self.age = math.random(10)
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
	assert_equal(3,g:size())
	--print(g:size()) -- 3
	assert_equal(3,g2:size())
	--print(g2:size()) -- 3
end

function test_abm_basic_group()
	if (SKIPS[4]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

	nonFooAgent = Agent {
	    name = "nonfoo",
	    init = function(self)
		self.age = math.random(10)
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
	assert_equal(3,g:size())
	--print(g:size()) -- 3
	sum = 0
	forEachAgent(g, function(ag)
		sum = sum + ag.age
	end)
	assert_equal(27,sum)
	--print(sum) -- 27

	g = Group {
		target = nonFooSociety,
		greater = function(a, b)
			return a.age > b.age
		end
	}
	assert_equal(10,g:size())
	--print(g:size()) -- 10
	assert_equal(10,g.agents[1].age)
	--print(g.agents[1].age) -- 10
	assert_equal(1,g.agents[10].age)
	--print(g.agents[10].age) -- 1

	g = Group {
		target = nonFooSociety,
		select = function(ag)
			return ag.age < 8
		end,
		greater = function(a, b)
			return a.age < b.age
		end
	}
	assert_equal(1,g.agents[1].age)
	--print(g.agents[1].age) -- 1
	assert_equal(7,g.agents[8].age)
	--print(g.agents[8].age) -- 7

	assert_equal(8,g:size())
	--print(g:size()) -- 8
	nonFooSociety:execute()
	g:rebuild()
	assert_equal(7,g:size())
	--print(g:size()) -- 7

	g:execute()
	g:execute()
	g:execute()
	g:rebuild()
	assert_equal(5,g:size())
	--print(g:size()) -- 5
	assert_equal(2,g.agents[1].id)
	--print(g.agents[1].id) -- 2
	g:randomize()
	assert_equal(3,g.agents[1].id)
	--print(g.agents[1].id) -- 3
end

function test_abm_basic_life_span()
	if (SKIPS[5]) then
		skip("No testing...") io.flush()
	end
	predator = Agent{
		energy = 40,
		name = "predator",
		execute = function(self) return self.energy end
	}

	predators = Society{instance = predator, quantity = 5}
	assert_equal(5,predators:size())
	--print(predators:size()) -- 5
	dead = predators.agents[2]
	predators.agents[2]:die()
	assert_equal(4,predators:size())
	--print(predators:size()) -- 4

	-- do not remove the double parentheses
	print((pcall(function() print(dead.a) end))) -- false

	predators.agents[4]:reproduce()
	assert_equal(5,predators:size())
	--print(predators:size()) -- 5

	cont = 3
	sum = 0
	forEachAgent(predators, function(agent)
		sum = sum + agent:execute()
		if cont == 3 then predators.agents[3]:die() end
		if cont == 1 then predators.agents[4]:die() end
		cont = cont - 1
	end)
	assert_equal(120,sum)
	--print(sum) -- 120
	assert_equal(3,predators:size())
	--print(predators:size()) -- 3

	forEachAgent(predators, function(agent)
		agent:reproduce()
	end)
	assert_equal(6,predators:size())
	--print(predators:size()) -- 6
end

function test_abm_basic_message()
	if (SKIPS[6]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

	received = 0
	nonFooAgent = Agent {
	    name = "nonfoo",
	    init = function(self)
		self.age = math.random(10)
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

	john   = soc:add() -- get a random agent from the society
	john.name = "john"
	mary   = soc:add()
	mary.name = "mary"
	myself = soc:add()

	friends = SocialNetwork()
	friends:add(john)
	friends:add(mary)

	myself:addSocialNetwork(friends) -- adding two connections to myself
	assert_equal(2,myself:getSocialNetwork():size())
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
	assert_equal(4,sum)
	--print(sum) -- 4

	forEachConnection(myself, function(self, friend)
	    myself:message{receiver = friend}
	end)
	assert_equal(2,received)
	--print(received) -- 2

	forEachConnection(myself, function(self, friend)
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	    myself:message{receiver = friend, delay = math.random(1, 10)}
	end)

	--[[
	-- to verify the delayed messages
	table.foreach(soc.messages, function(_, mes)
		table.foreach(mes, print)
	end)
	--]]

	soc:synchronize()
	assert_equal(5,received)
	--print(received) -- 5

	t = Timer{
		Event{period = 4, action = soc}
	}

	t:execute(8)
	assert_equal(16,received)
	--print(received) -- 16

	soc:synchronize(1.1)
	assert_equal(18,received)
	--print(received) -- 18

	soc:synchronize(20)
end

function test_abm_basic_multiple_placement()
	if (SKIPS[7]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

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
	assert_equal(100,count_house)
	--print(count_house) -- 100
	assert_equal(100,count_stay)
	--print(count_stay) -- 100
	assert_equal(0,count_wplace)
	--print(count_wplace) -- 0

	max = 0
	forEachCell(cs, function(cell)
		if max < cell.house:size() then
			max = cell.house:size()
		end
	end)
	assert_equal(1,max)
	--print(max) -- 1
	assert_equal(1,cs.cells[100].stay:size())
	--print(cs.cells[100].stay:size()) -- 1
	assert_equal(0,cs.cells[101].stay:size())
	--print(cs.cells[101].stay:size()) -- 0


	predators:execute()
	predators:sample():die()

	count_house = 0
	count_stay = 0
	forEachCell(cs, function(cell)
		count_house = count_house + cell.house:size()
		count_stay = count_stay   + cell.stay:size()
	end)
	assert_equal(99,count_house)
	--print(count_house) -- 99
	assert_equal(99,count_stay)
	--print(count_stay) -- 99
end

function test_abm_basic_placement()
	if (SKIPS[8]) then
		skip("No testing...") io.flush()
	end
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
	assert_equal(false,(pcall(function() env:createPlacement{strategy = "random", max = 1} end)))
	--print((pcall(function() env:createPlacement{strategy = "random", max = 1} end))) -- false

	forEachAgent(predators, function(ag)
		ag:reproduce()
	end)

	predators:execute()

	cont = 0
	forEachCell(cs, function(cell)
		cont = cont + cell.placement:size()
	end)
	assert_equal(40,cont)
	--print(cont) -- 40
end

function test_abm_basic_social_network()
	if (SKIPS[9]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

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
	assert_equal(5300,count_prob)
	--print(count_prob) -- 5300
	assert_equal(100,count_quant)
	--print(count_quant) -- 100
	assert_equal(10000,count_all)
	--print(count_all) -- 10000

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
	assert_equal(408,count_c)
	--print(count_c) -- 408
	assert_equal(2980,count_n)
	--print(count_n) -- 2980

end

function test_abm_basic_split()
	if (SKIPS[10]) then
		skip("No testing...") io.flush()
	end
	math.randomseed(0)

	received = 0
	nonFooAgent = Agent {
	    name = "nonfoo",
	    init = function(self)
		self.age = math.random(10)
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

	--[[
	forEachAgent(soc, function(a)
		print(a.name, a.age)
	end)
	--]]

	g = soc:split("name")
	assert_equal(7,g.foo:size())
	--print(g.foo:size()) -- 7
	assert_equal(10,g.foo:size() + g.nonfoo:size())
	--print(g.foo:size() + g.nonfoo:size()) -- 10

	g3 = soc:split(function(ag)
		if ag.age < 3 then return 1
		elseif ag.age < 7 then return 2
		else return 3
		end
	end)
	assert_equal(2,g3[1]:size())
	--print(g3[1]:size()) -- 2
	assert_equal(10,g3[1]:size() + g3[2]:size() + g3[3]:size())
	--print(g3[1]:size() + g3[2]:size() + g3[3]:size()) -- 10
end

functionList = {
    [1] = "test_AgentBasics",
    [2] = "test_CreatesAgentAndAutomatonAndAskWhereTheyAre",
    [3] = "test_AgentAndAutomatonJumpConditions",
    [4] = "test_NotDeclaredStates",
    [5] = "test_AgentAndAutomatonTrajectories",
    [6] = "test_AutomataAndAgentsworking",
    [7] = "test_TrajectoriesFiltersAndReordered",
    [8] = "test_TrajectoriesCanBeChangeNotOverwritten",
    [9] = "test_AutomatonCrash",
    [10] = "test_NeverTestTrajectoriesInUse"
    
}

SKIPS = executeBasics("agent / automaton", functionList, skips)


lunatest.run()

