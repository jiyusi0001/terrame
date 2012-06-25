-- Implementation of beer economic chain model
-- (C) 2010 INPE AND UFOP

math.randomseed(os.time())

NUMBER_OF_AGENTS = 3

M_REQUEST = 0
M_TRUCK   = 1

RequestBeer = function(agent, quantity)
	agent:action{receiver = agent.from, delay = 1, content = M_REQUEST, value = quantity}
	agent.requested = quantity
end

SendBeer = function(agent, quantity)
	agent:action{receiver = agent.to, content = M_TRUCK, delay = 3,  value = quantity}
	agent.sended = quantity
end

COUNTER = 1

create_agent = function()
	local agent = {stock = 20, o_ordered = 0, costs = 0, received = 0, priority = COUNTER}

	COUNTER = COUNTER + 1

	agent.update_costs = function(agent)
		agent.costs = agent.costs + math.floor(agent.stock/2) + agent.o_ordered
	end

	agent.execute = function(agent)
		if agent.o_ordered <= agent.stock then
			SendBeer(agent, agent.o_ordered)
			agent.stock = agent.stock - agent.o_ordered
			agent.o_ordered = 0
		else
			SendBeer(agent, agent.stock)
			agent.o_ordered = agent.o_ordered - agent.stock
			agent.stock = 0
		end

		----- the overall decision
		local requested = 0
		if agent.stock <= 20 then
			requested = 6
		end

		RequestBeer(agent, requested)
		----- end of the overall decision

		agent:update_costs()
	end

	agent.onMessage = function(agent, message)
		if message.content == M_REQUEST then
			agent.o_ordered = agent.o_ordered + message.value
		elseif message.content == M_TRUCK then
			agent.stock = agent.stock + message.value
			agent.received = message.value
		end
	end

	return Agent(agent)
end

create_requester = function()
	local agent = {}
	agent.priority  = 0
	agent.stock     = "."
	agent.requested = "."
	agent.sended    = "."
	agent.received  = 0
	agent.o_ordered = 0
	agent.costs     = 0
	agent.execute = function(agent)
		local requested = math.random(10)
		RequestBeer(agent, requested)
	end
	
	agent.onMessage = function(agent, message)
		if message.content == M_TRUCK then
			agent.received = message.value
		else
			print("error. message not recognized on requester")
		end
	end
	return agent
end

create_producer = function()
	local agent = {}
	agent.priority = NUMBER_OF_AGENTS + 1
	agent.stock     = "."
	agent.requested = "."
	agent.sended    = "."
	agent.received  = 0
	agent.o_ordered = 0
	agent.costs     = 0

	agent.execute = function(agent)
		SendBeer(agent, agent.o_ordered)
		agent.o_ordered = 0
	end

	agent.onMessage = function(agent, message)
		if message.content == M_REQUEST then
			agent.o_ordered = message.value
		else
			print("error. message not recognized on requester")
		end
	end
	return agent
end

s = Society(create_agent, NUMBER_OF_AGENTS)
my_requester = Agent(create_requester())
my_producer = Agent(create_producer())

s:add(my_requester)
s:add(my_producer)

-- defines the order to execute the agents
g = Group(s,
          function() return true end,
          function(a,b) return a.priority < b.priority end)
 
-- connects the i'th agent to the i+1'th
last = {}
forEachAgent(g, function(ag)
	ag.to     = last
	last.from = ag
	last      = ag
end)

forEachAgent(g, function(ag)
	ag.to = ag.to or {}
	ag.to.priority = ag.to.priority or -1
	ag.from = ag.from or {}
	ag.from.priority = ag.from.priority or -1
end)

PrintStatus = function()
	local p=""
	local s=""
	local r="\t"
	local w="\t"
	local o=""
	local c=""
	forEachAgent(g, function(ag)
		p=p.."\t"..ag.priority.."\t\t"
		s=s.."\t"..ag.stock
		if ag.o_ordered > 0 then
			s=s.."("
			s=s.."-"..ag.o_ordered
			s=s..")"
		end
		s=s.."\t"
		r=r.."  ===> "..ag.requested.." ===> \t"
		w=w.."  < "..ag.received.." <= "..ag.sended..   " < \t"
		c=c.."\t$"..ag.costs.."\t"
	end)
	print(s)
	print(string.sub(r, 1, -14))
	print(string.sub(w, 14))
	print(c)	
end

for i = 1,100 do
	print("TIME "..i)
	s:execute()
	PrintStatus()
	synchronizeMessages()
end

sum = 0
forEachAgent(s, function(ag)
	sum = sum + ag.costs
end)
print("TOTAL COSTS: "..sum)


print("READY")
print("Please, press <ENTER> to quit...")
io.flush()
io.read()
