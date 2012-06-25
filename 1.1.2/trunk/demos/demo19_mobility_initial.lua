--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
--II Games on Cellular Spaces for studying mobility  II
--II                                                 II
--II Last change: 20080827                           II
--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
-- (C) 2010 INPE AND UFOP

TME_PATH_1_1_2 = os.getenv("TME_PATH_1_1_2");

-- DBMS Type
-- 0 : mysql
-- 1 : msaccess
if(not dbms) then
	print("-- DBMS Type")
	print("-- 0 : mysql")
	print("-- 1 : msaccess")
	print("Please, enter database type: ")
  	dbms = tonumber(io.read())
end

if (not pwd) then 
  print("Please, enter database password: ")
  pwd=io.read()
end

-- attributes name can differ in differents DBMS's
HEIGHT= "height_"

-- access database properties
DB_VERSION = "4_2_0"
DB_HOME = TME_PATH_1_1_2 .. "\\database"
DB_ACCESS = DB_HOME .."\\mobility_jasss_" .. DB_VERSION .. ".mdb"


if(dbms == 0) then
	cs = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "mobility_jasss",
		user = "root",
		password = pwd,
		theme = "cells",
		select   = {"object_id_" , "Col", "Lin"}
	}
else
	cs = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "cells",
		select   = {"object_id_" , "Col", "Lin"}	
	}		
end

math.randomseed(os.time())

-- environment
PLAYERS_PROPORTION = 3    -- number of players of the same strategy within each cell
                          -- in the beginning of the model
INITIAL_MONEY      = 200

-- players
--STRATEGIES = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0}
STRATEGIES = {0.1, 0.5, 1.0}

--TURNS = 3000

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
qtty_strategies__ = table.getn(STRATEGIES)

changed = false

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
	if(math.mod(table.getn(players), 2) == 1)
		then table.remove(players, math.random(1, table.getn(players)))
	end
	return players
end

function GamesTable(cell)
	local vplayers   = {}
	local vconfronts = {}

	local players = cell:getAgents()
	local tp = table.getn(players)

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
	count__ = math.mod(count__ + 1, qtty_strategies__)
	return STRATEGIES[count__ + 1]
end

function NewPlayer() -- creates a new agent
	return Agent{money    = INITIAL_MONEY,
			     strategy = InitialStrategy(),
			     balance  = 0}
end

function Play(player)
	if math.random() <= player.strategy then
		return SHOOT
	else
		return NOT_SHOOT
	end
end

function ChangeMoney(player, value)
	player.money   = player.money   + value
	player.balance = player.balance + value
end

-------------------------------------------------------------------------
-- FUNCTIONS FOR MANIPULATING CELLS
-------------------------------------------------------------------------

function RunTurn(cell)
	local np = cell:numberOfAgents()

	if np < 2 then return true end

	forEachAgent(cell, function(agent)
		if agent.strategy > 0.01 then
			changed = true
		end
	end)

	local tab     = GamesTable(cell)
	local players = cell:getAgents()

	for i = 1, table.getn(tab) - 1, 2 do
		local player  = players[tab[i]  ]
		local oponent = players[tab[i+1]]

		local confront = Game(Play(player), Play(oponent))

		ChangeMoney(player,  confront[1] + GAIN)
		ChangeMoney(oponent, confront[2] + GAIN)
	end	
end

function EndTurn(cell)
	local i = 1
	local players = cell:getAgents()

	while i <= table.getn(players) do
		local player = players[i]

		if player.money <= 0 then -- leave the game
			pos = player.strategy
			players__[pos] = players__[pos] - 1
			player:leave()
		elseif player.balance < THRESHOLD then -- leave the cell
			pos = player.strategy
			movements__[pos] = movements__[pos] + 1

			player.balance = 0
			player:move(cell:getNeighborhood():sample())
		else
			i = i + 1
		end
	end
end

-- this function returns the strategy of the owner, or -1 in the case when
-- there are no players within the cell
function Owner(cell)
	local players = cell:getAgents()

	if table.getn(players) == 0 then return -1 end

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

function Populate(cs)
	local quantity = PLAYERS_PROPORTION * table.getn(STRATEGIES)

	forEachCell(cs, function(cell)
		for i = 1, quantity, 1 do
			agent = NewPlayer()
			agent:enter(cell)
		end
	end)
end

-- this function uses the internal__ variables and clean them
function ShowState(cs)
	forEachCell(cs, function(cell)
		forEachAgent(cell, function(player)
			local p = player.strategy

			money__  [p] = money__  [p] + player.money
			balance__[p] = balance__[p] + player.balance
		end)

		if( cell:numberOfAgents() > 0 ) then
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
	k = PLAYERS_PROPORTION * cs:size()
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
cs:load()
createMooreNeighborhood(cs, "1", false)

Populate(cs)

forEachCell(cs, Owner)

ShowHeader(cs)
ShowState(cs)

changed = true
while changed do
	changed = false
	forEachCell(cs, RunTurn)
	forEachCell(cs, EndTurn)
	forEachCell(cs, Owner)
	
	ShowState(cs)

--	if i == 1 or i == 2 or i == 3 then
--		cs:save( i, "ownercells", {"owner"} );
--	end
end

--cs:save( TURNS, "ownercells", {"owner"} );

print("READY!")
print("Please, press <ENTER> to quit...")
io.read()
