--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
--II Games on Cellular Spaces for studying mobility  II
--II                                                 II
--II Last change: 20080827                           II
--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
-- 2010-2012 INPE AND UFOP

math.randomseed(os.time())

PLAYERS_PROPORTION = 3    -- number of players of the same strategy within each cell
                          -- in the beginning of the model
INITIAL_MONEY      = 200

-- players
--STRATEGIES = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0}
STRATEGIES = {0.1, 0.5, 1.0}

-- threshold for changing cell
THRESHOLD = -20

-- how much each player gains after each game?
GAIN = 0.0

SHOW_PLAYERS   = true
SHOW_MOVEMENTS = false
SHOW_OWNERS    = true
SHOW_MONEY     = true
SHOW_BALANCE   = false

--------------------------------------------------------------------------
-- INTERNAL VALUES
--------------------------------------------------------------------------
SHOOT     = 1
NOT_SHOOT = 0

players__         = {}
movements__       = {}
owners__          = {}
money__           = {}
balance__         = {}
count__           = 0
qtty_strategies__ = getn(STRATEGIES)

changed = true

--------------------------------------------------------------------------
-- FUNCTION WITH RULES FOR THE GAME
--------------------------------------------------------------------------

function Game(p1, p2)
	if p1 == SHOOT     and p2 == SHOOT     then return {-10,-10} end
	if p1 == SHOOT     and p2 == NOT_SHOOT then return {  1, -1} end
	if p1 == NOT_SHOOT and p2 == SHOOT     then return { -1,  1} end
	if p1 == NOT_SHOOT and p2 == NOT_SHOOT then return {  0,  0} end
end

--------------------------------------------------------------------------
-- CHAMPIONSHIP RULES
--------------------------------------------------------------------------

-- these functions work with a vector of numbers, indicating 
-- the positions of a vector of players

function RemoveOneIfOdd(players)	
	if(getn(players)% 2 == 1)
		then table.remove(players, math.random(1, getn(players)))
	end
	return players
end

function GamesTable(cell)
	local vplayers   = {}
	local vconfronts = {}

	local players = cell:getAgents()
	local tp = getn(players)

	for i = 1, tp, 1 do
		vplayers[i] = i
	end	

	local p = tp
	for i = 1, tp, 1 do
		pos = math.random(1, p)
		vconfronts[i] = vplayers[pos]
		table.remove(vplayers, pos)
		p = p - 1
	end
	
	return RemoveOneIfOdd(vconfronts)	
end

--------------------------------------------------------------------------
-- FUNCTIONS FOR MANIPULATING AGENTS
--------------------------------------------------------------------------

-- return the strategy of the next player to be created. it cycles all STRATEGIES.
function InitialStrategy()
	count__ = (count__ + 1) % qtty_strategies__
	return STRATEGIES[count__ + 1]
end

-------------------------------------------------------------------------
-- FUNCTIONS FOR MANIPULATING CELLS
-------------------------------------------------------------------------

basicAgent = Agent {
	strategy = 1.0,
	balance = 0,
	money = INITIAL_MONEY,
	init = function(self)
		self.strategy = InitialStrategy()
	end,
	play = function (self)
		if math.random() <= self.strategy then
			return SHOOT
		else
			return NOT_SHOOT
		end
	end,
	changeMoney = function(self, value)
		self.money   = self.money   + value
		self.balance = self.balance + value
	end,
	execute = function(self)
		if self.money <= 0 then -- leave the game
			players__ [self.strategy] = players__ [self.strategy] - 1 
			self:die()
		elseif self.balance < THRESHOLD then -- leave the cell
			self.balance = 0
			self:move(self:getCell():getNeighborhood():sample())
		end
	end
}

cs = CellularSpace{xdim = 20}

soc = Society {instance = basicAgent, quantity = cs:size() * PLAYERS_PROPORTION}

env = Environment {soc, cs}

env:createPlacement{strategy = "uniform"}

-- this function returns the strategy of the owner, or -1 in the case when
-- there are no players within the cell
function Owner(cell)
	local players = cell:getAgents()

	if getn(players) == 0 then return -1 end

	local owner = players[1]

	forEachAgent(cell, function(player)
		if player.money > owner.money then
			owner = player
		end
	end)

	cell.owner = owner.strategy

	return owner
end

-------------------------------------------------------------------------
-- FUNCTIONS FOR MANIPULATING CELLULAR SPACES
-------------------------------------------------------------------------

mediator = Agent {
	execute = function(self)
		forEachCell(cs, function(cell)
			local np = cell.placement:size()

			if np < 2 then return true end

			forEachAgent(cell, function(agent)
				if agent.strategy > 0.01 then
					changed = true
				end
			end)

			local tab = GamesTable(cell)
			local players = cell:getAgents()

			for i = 1, getn(tab) - 1, 2 do
				local player  = players[tab[i]  ]
				local oponent = players[tab[i+1]]

				local confront = Game(player:play(), oponent:play())

				player:changeMoney(confront[1] + GAIN)
				oponent:changeMoney(confront[2] + GAIN)
			end
		end)
	end
}

-- this function uses the internal__ variables and clean them
function ShowState(cs)
	forEachCell(cs, function(cell)
		forEachAgent(cell, function(player)
			local p = player.strategy

			money__  [p] = money__  [p] + player.money
			balance__[p] = balance__[p] + player.balance
		end)

		if( cell.placement:size() > 0 ) then
			local p = Owner(cell).strategy
			owners__[p] = owners__[p] + 1
		else
			cell.owner = 0
		end
	end)

	p = "" -- strategy of the player
	m = "" -- movement
	o = "" -- owner
	s = "" -- money
	b = "" -- balance

	for i = 1, qtty_strategies__, 1 do
		idx = STRATEGIES[i]
		p = p..players__  [idx].."\t"
		m = m..movements__[idx].."\t"
		o = o..owners__   [idx].."\t"
		s = s..money__    [idx].."\t"
		b = b..balance__  [idx].."\t"
	end

	result = ""

	if SHOW_PLAYERS   then result = result..p end
	if SHOW_MOVEMENTS then result = result..m end
	if SHOW_OWNERS    then result = result..o end
	if SHOW_MONEY     then result = result..s end
	if SHOW_BALANCE   then result = result..b end

	print(result)
	io.flush()

	for i = 1, qtty_strategies__, 1 do
		idx = STRATEGIES[i]
		movements__[idx] = 0
		owners__   [idx] = 0
		money__    [idx] = 0
		balance__  [idx] = 0
	end
end

function ShowHeader(cs)
	k = PLAYERS_PROPORTION * cs:size() / getn(STRATEGIES)
	p = "" -- strategy of the player
	m = "" -- movement
	o = "" -- owner
	s = "" -- money
	b = "" -- balance

	for i = 1, qtty_strategies__, 1 do
		idx = STRATEGIES[i]
		players__  [idx] = k; p = p.."strat"..(STRATEGIES[i]*10).."\t"
		movements__[idx] = 0; m = m.."movem"..(STRATEGIES[i]*10).."\t"
		owners__   [idx] = 0; o = o.."owner"..(STRATEGIES[i]*10).."\t"
		money__    [idx] = 0; s = s.."money"..(STRATEGIES[i]*10).."\t"
		balance__  [idx] = 0; b = b.."balan"..(STRATEGIES[i]*10).."\t"
	end

	result = ""

	if SHOW_PLAYERS   then result = result..p end
	if SHOW_MOVEMENTS then result = result..m end
	if SHOW_OWNERS    then result = result..o end
	if SHOW_MONEY     then result = result..s end
	if SHOW_BALANCE   then result = result..b end

	print(result)
	io.flush()
end

--------------------------------------------------------------------------
-- RUNNING THE GAMES
--------------------------------------------------------------------------
cs:createNeighborhood()

forEachCell(cs, Owner)

ShowHeader(cs)
ShowState(cs)

while changed do
	changed = false
	mediator:execute()
	soc:execute()
	forEachCell(cs, Owner)
	
	ShowState(cs)
end

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
