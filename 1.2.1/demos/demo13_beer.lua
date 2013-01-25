-- Implementation of beer economic chain model
-- (C) 2010 INPE AND UFOP

math.randomseed(os.time())

NUMBER_OF_AGENTS = 3

RequestBeer = function(agent, quantity)
	agent:message{receiver = agent.from, delay = 1, subject = "request", value = quantity}
	agent.requested = quantity
end

SendBeer = function(agent, quantity)
	agent:message{receiver = agent.to, subject = "truck", delay = 3, value = quantity}
	agent.sended = quantity
end

COUNTER = 1

basicAgent = Agent{
	stock = 20, o_ordered = 0, costs = 0, received = 0, priority = COUNTER,
	build = function(self)
		self.priority = COUNTER
		COUNTER = COUNTER + 1
	end,
	update_costs = function(agent)
		agent.costs = agent.costs + math.floor(agent.stock/2) + agent.o_ordered
	end,
	execute = function(agent)
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
			requested = 10
		end
		RequestBeer(agent, requested)
		----- end of the overall decision
		agent:update_costs()
	end,
	on_truck = function(agent, message)
		agent.stock = agent.stock + message.value
		agent.received = message.value
	end,
	on_request = function(agent, message)
		agent.o_ordered = agent.o_ordered + message.value
	end
}

requester = Agent{
	priority  = 0,
	stock     = ".",
	requested = ".",
	sended    = ".",
	received  = 0,
	o_ordered = 0,
	costs     = 0,
	execute = function(agent)
		local requested = math.random(10)
		RequestBeer(agent, requested)
	end,
	on_truck = function(agent, message)
		agent.received = message.value
	end
}

producer = Agent{
	priority = NUMBER_OF_AGENTS + 1,
	stock     = ".",
	requested = ".",
	sended    = ".",
	received  = 0,
	o_ordered = 0,
	costs     = 0,
	execute = function(agent)
		SendBeer(agent, agent.o_ordered)
		agent.o_ordered = 0
	end,
	on_request = function(agent, message)
		agent.o_ordered = message.value
	end
}

s = Society{instance = basicAgent, quantity = NUMBER_OF_AGENTS}
s:add(requester)
s:add(producer)

-- defines the order to execute the agents
g = Group{
	target = s,
	greater = function(a, b) return a.priority < b.priority end
}

-- connects the i'th agent to the i+1'th
last = {}

forEachAgent(g, function(ag)
	ag.to     = last
	--print(type(ag.to))
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

for i = 1,50 do
	print("TIME "..i)
	s:execute()
	PrintStatus()
	s:synchronize()
end

sum = 0
forEachAgent(s, function(ag)
	sum = sum + ag.costs
end)
print("TOTAL COSTS: "..sum)

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
