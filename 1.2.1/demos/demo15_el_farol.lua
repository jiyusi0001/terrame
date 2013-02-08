-- implementation of el farol model
-- based on Brian Arthur's paper available at
-- http://www.santafe.edu/~wbarthur/Papers/El_Farol.html
-- (C) 2010 INPE AND UFOP

math.randomseed(os.time())

N = 100
K = 3
MAX = 60
TIME = 100
LAST_TURNS = {0,0,0,0,0,0,0,0,0,0}

update_last_turns = function(new_value)
	for i = 9,1,-1 do
		LAST_TURNS[i+1] = LAST_TURNS[i]
	end
	LAST_TURNS[1] = new_value
end

function d_same_last_week(t)    return t[1]                    end
function d_same_plus_10(t)      return t[1]+10                 end
function d_mirror_last_week(t)  return 100 - t[1]              end
function d_67()                 return 67                      end
function d_same_2_weeks(t)      return t[2]                    end
function d_same_5_weeks(t)      return t[5]                    end
function d_average_4_weeks(t)   return (t[1]+t[2]+t[3]+t[4])/4 end
function d_average_2_weeks(t)   return (t[1]+t[2])/2           end
function d_max_2_weeks(t)       return math.max(t[1],t[2])     end
function d_min_2_weeks(t)       return math.min(t[1],t[2])     end

STRATEGIES = {
	d_same_last_week,
	d_same_plus_10,
	d_mirror_last_week,
	d_67,
	d_same_2_weeks,
	d_same_5_weeks,
	d_average_4_weeks,
	d_max_2_weeks,
	d_min_2_weeks
}

INV_STRAT = {
	[d_same_last_week]   = "d_same_last_week  ",
	[d_same_plus_10]     = "d_same_plus_10    ",
	[d_mirror_last_week] = "d_mirror_last_week",
	[d_67]               = "d_67              ",
	[d_same_2_weeks]     = "d_same_2_weeks    ",
	[d_same_5_weeks]     = "d_same_5_weeks    ",
	[d_average_4_weeks]  = "d_average_4_weeks ",
	[d_max_2_weeks]      = "d_max_2_weeks     ",
	[d_min_2_weeks]      = "d_min_2_weeks     "
}

function count_strategies(soc)
	tot = {}
	for i = 1, getn(STRATEGIES) do
		tot[STRATEGIES[i]] = 0
	end

	forEachAgent(soc, function(agent)
		strat = agent.strategies[agent.last_strategy]
		tot[strat] = tot[strat] + 1
	end)

	for i = 1, getn(STRATEGIES) do
		strat = STRATEGIES[i]
		print(INV_STRAT[strat]..": "..tot[strat])
	end
end

basicAgent = Agent{
	init = function(agent)
		agent.strategies = {}
		agent.count_fails = {}
		agent.last_strategy = 1

		-- choose K different strategies
		choosen = {0,0,0,0,0,0,0,0,0}
		for i = 1, K do
			agent.count_fails[i] = 0
			p = 0
			repeat
				p = math.random(1, getn(STRATEGIES))
			until choosen[p] == 0
			agent.strategies [i] = STRATEGIES[p]
			choosen[p] = 1
		end
	end,
	execute = function(ag)
		best = 1
		for i = 2, K do
			if ag.count_fails[best] > ag.count_fails[i] then
				best = i
			end
		end

		ag.last_strategy = best

		last = ag.strategies[best](LAST_TURNS)
		if last < 60 then
			return 1
		else
			return 0
		end
	end,
	update = function(ag, quantity)
		for i = 1, K do
			-- punishment is equal to the difference btw the predicted value
			-- and the number of attendances
			diff = ag.strategies[i](LAST_TURNS) - quantity
			ag.count_fails[i] = ag.count_fails[i] + math.abs(diff)
		end
	end,
	print = function(ag)
		print("\n\nLast strategy: "..INV_STRAT[ag.strategies[ag.last_strategy]])
		for i = 1, K do
			choose = ag.strategies[i](LAST_TURNS)
			print(INV_STRAT[ag.strategies[i]].." failed "..ag.count_fails[i])
		end
	end
}

s = Society{instance = basicAgent, quantity = N}

for time = 1, TIME do
	quant = 0
	forEachAgent(s, function(ag)
		quant = quant + ag:execute()
	end)
	print(quant)
	forEachAgent(s, function(ag)
		ag:update(quant)
	end)
	
	update_last_turns(quant)
end

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)

