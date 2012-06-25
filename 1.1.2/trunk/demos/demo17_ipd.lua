-- ITERATED PRISONER'S DILEMMA MODEL
-- (C) 2010 INPE AND UFOP

-- STRATEGIES AND META-STRATEGIES
COOPERATE     = 1
NOT_COOPERATE = 2

TFT = function() -- TIT-FOR-TAT
	ag = {name = "TFT", last = COOPERATE}
	ag.play = function(ag)
		return ag.last
	end
	ag.update = function(ag, oponent_strategy)
		ag.last = oponent_strategy
	end
	return ag
end

TF2T = function() -- TIT-FOR-TWO-TATS
	ag = {name = "TF2T", action = COOPERATE, last = COOPERATE, previous = COOPERATE}
	ag.play = function(ag)
		return ag.action
	end
	ag.update = function(ag, oponent_strategy)
		ag.previous = ag.last
		ag.last = oponent_strategy
		if ag.previous == ag.last and ag.last == NOT_COOPERATE then
			ag.action = NOT_COOPERATE 
		else
			ag.action = COOPERATE
		end
	end
	return ag
end

COOP1 = function() -- COOPERATE UNTIL THE OPPONENT DEFECTS ONCE
	ag = {name = "COOP1", action = COOPERATE}
	ag.play = function(ag)
		return ag.action
	end
	ag.update = function(ag, oponent_strategy)
		if oponent_strategy == NOT_COOPERATE then
			ag.action = NOT_COOPERATE
		end
	end
	return ag
end

NTFT = function() -- NOT TIT-FOR-TAT
	ag = {name = "NTFT", action = NOT_COOPERATE}
	ag.play = function(ag)
		return ag.action
	end
	ag.update = function(ag, oponent_strategy)
		if oponent_strategy == COOPERATE then ag.action = NOT_COOPERATE
		else								  ag.action = COOPERATE end
	end
	return ag
end

AD = function() -- ALWAYS DEFECT
	ag = {name = "AD"}
	ag.play = function(ag)
		return NOT_COOPERATE
	end
	ag.update = function(ag, oponent_strategy) end
	return ag
end

AC = function() -- ALWAYS COOPERATE
	ag = {name = "AC"}
	ag.play = function(ag)
		return COOPERATE
	end
	ag.update = function(ag, oponent_strategy) end
	return ag
end

RANDOM = function(prob)
	prob = prob or 0.5
	ag = {name = "RANDOM"}
	ag.play = function(ag)
		if math.random() > prob then
			return COOPERATE
		else
			return NOT_COOPERATE
		end
	end
	ag.update = function(ag, oponent_strategy) end
	return ag
end

PAVLOV =  function() -- WIN-STAY-LOSE-SHIFT
	ag = {name = "PAVLOV", action = COOPERATE}
	ag.play = function(ag)
		return ag.action
	end
	ag.update = function(ag, oponent_strategy)
		if oponent_strategy == NOT_COOPERATE then
			if ag.action == COOPERATE then
				ag.action = NOT_COOPERATE
			else
				ag.action = COOPERATE
			end
		end
	end
	return ag
end

-- PARAMETERS
TURNS = 40
CHAMPIONSHIP = {TFT, AD, COOP1, PAVLOV, RANDOM, TF2T, TFT, NTFT}

function Game(p1, p2)
	if p1 == COOPERATE     and p2 == COOPERATE     then return {3, 3} end
	if p1 == COOPERATE     and p2 == NOT_COOPERATE then return {0, 5} end
	if p1 == NOT_COOPERATE and p2 == COOPERATE     then return {5, 0} end
	if p1 == NOT_COOPERATE and p2 == NOT_COOPERATE then return {1, 1} end
end

-- MODEL
math.randomseed(os.time())
nplayers = table.getn(CHAMPIONSHIP)

-- create a matrix with the results
results = {}
for i = 1,nplayers do
		results[i] = {}
		for j = 1,nplayers do
			results[i][j] = 0
		end
end

-- the championchip, pair by pair
for i = 1 ,nplayers do
	for j = i, nplayers do
		player1 = CHAMPIONSHIP[i]()
		player2 = CHAMPIONSHIP[j]()

		payoff1 = 0
		payoff2 = 0

		for k = 1,TURNS do
			a1 = player1:play()
			a2 = player2:play()

			player1:update(a2)
			player2:update(a1)

			payoffs = Game(a1, a2)

			payoff1 = payoff1 + payoffs[1]
			payoff2 = payoff2 + payoffs[2]
		end

		results[i][j] = payoff1
		results[j][i] = payoff2
	end
end

-- plot the results
p="\t"
for j = 1,nplayers do
	p=p..CHAMPIONSHIP[j]().name.."\t"
end
print(p.."_SUM_")

for i = 1,nplayers do
	p = CHAMPIONSHIP[i]().name.."\t"
	sum = 0
	for j = 1,nplayers do
		p = p..results[i][j].."\t"
		sum = sum + results[i][j]
	end
	print(p..sum)
end


print("Please, press <ENTER> to quit...")
io.read()