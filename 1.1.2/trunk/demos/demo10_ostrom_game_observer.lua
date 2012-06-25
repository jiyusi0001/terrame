-------------------------------------------------------------------------------------------
-- COMMOM POOL GAME: Wood loggers - all against the government
-- (C) 2010 INPE AND UFOP
--
-- Initial Game State: 
--			Some loggers are in the forest. The locations they occupy are already
--			deforested.
--
-- Players: 
--			There are several loggers which want profits from illegal deforestation.
--         The government is the player responsible to enforce the law.
--
-- Game Dynamics: 
--			Each time step, all loggers have the chance to deforest a new location whitin their 
--			vicinity. If there are no forest around them, they move to a neighbor location looking for
--			new areas to deforest. However, at the end of the time step, the government may,
-- 			with probabiity P, detect recent deforestation and punish the responsibles.
--			The government has olny one way to detect recent deforestation: using 
--			satellite images. Send a team to visit all locations it is a very expensive way to
--			detect deforestation. Specially in a continental size forest. The satellite based 
--			detection system has a not so high operational cost. However, processing satellite 
--			images is not a 100% effective mechanism. It may cause mistakes when detects false 
--			deforestations or may fail when does not detect all real deforested areas. 
--			Due to these problems and costs, the government may also decide to not enforce the law. 
-------------------------------------------------------------------------------------------

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

-- Data paths
-- access database properties
DB_VERSION = "4_2_0"
DB_HOME = TME_PATH_1_1_2 .. "\\database"
DB_ACCESS = DB_HOME .."\\db_jogoOstrom_".. DB_VERSION .. ".mdb"

INPUT_PATH = "database\\"
OUTPUT_PATH = TME_PATH_1_1_2.."\\results\\ostrom\\"
DB_VERSION = "4_2_0"

-------------------------------------------------------------------------------------------

-- model parameters
N_LOGGERS 			= 30  	-- number of loggers
N_FISCALS			= 1		-- number of fiscals
ROUNDS  			= 50	-- number of time steps
P_ENFORCEMENT 		= 0.5	-- probability of government enforce the law
P_CAUGHT			= 0.5	-- probability of caught some illegal deforestation when enfforcing the law
P_DEFOREST			= 0.5	-- probability of a looger decide to deforest
SAVE_PERIODICITY	= 1

-- payoff parameters
C = 1	-- enforcement law
B = 1	-- gains from illegal deforestation
P = P_ENFORCEMENT * P_CAUGHT -- illegal deforestation detection probability
F = 2	-- fee due illegal deforestation
M = 1	-- enforcement bonus

-------------------------------------------------------------------------------------------

-- cell possible states
FOREST	  				= 0 -- green
RECENTLY_DEFORESTED 	= 1 -- red
DEFORESTED 				= 2 -- gray
CAUGHT 					= 3 -- white
NOT_CAUGHT				= 4 -- yellow
INHABITED				= 5 -- blue
MISTAKE					= 6 -- magenta

-- possible plays
FOLLOW_RULES   		= 0
NOT_FOLLOW_RULES 	= 1
ENFORCE		   		= 0
NOT_ENFORCE		   	= 1

-------------------------------------------------------------------------------------------

--loads database
-- Define and load a TerraLib geographical database
if(dbms == 0) then
	cs = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "db_jogoOstrom",
		user = "root",
		password = pwd,
		theme = "celulas100x100",
		select = { "Col", "lin", "cover" }
	}
else
	cs	= CellularSpace{
	 	dbType = "ADO",
	 	database = DB_ACCESS,
	 	theme = "celulas100x100",
	 	select = {"Col","Lin","cover"}
	}
end
cs:load()

createMooreNeighborhood(cs)

-------------------------------------------------------------------------------------------

function game(p1, p2)
	
	-- Ostrom
	if p1 == FOLLOW_RULES     	and p2 == ENFORCE     	then return {0, -C} 						end
	if p1 == FOLLOW_RULES     	and p2 == NOT_ENFORCE 	then return {0, 0} 							end
	if p1 == NOT_FOLLOW_RULES 	and p2 == ENFORCE     	then return {B -P*(F+B), P*M-(C+(1-P)*B)}	end
	if p1 == NOT_FOLLOW_RULES 	and p2 == NOT_ENFORCE	then return {B, -B}							end

	-- Tiago
--	if p1 == FOLLOW_RULES     and p2 == COLABORATE     then return {-C/2, -C/2} end
--	if p1 == FOLLOW_RULES     and p2 == NOT_COLABORATE then return {0, 0} end
--	if p1 == NOT_FOLLOW_RULES and p2 == COLABORATE     then return {B -P*(M/2+F+B)-C/2, P*M/2-(C/2+(1-P)*B)} end
--	if p1 == NOT_FOLLOW_RULES and p2 == NOT_COLABORATE then return {B, -B} end
end

---------------------------------------------------------------------------------------------

-- Wood logger payer constructor function
function Logger()
	ag = {}
	
	ag.execute = function(agent)
	
		-- select forest and non-forest neighbors
		ag.deforestedNeighs = {}
		ag.forestNeighs = {}
		forEachNeighbor(agent.cell, function(cell, neigh)
			if neigh.cover == FOREST then
				table.insert(ag.forestNeighs, neigh)
			else
				table.insert(ag.deforestedNeighs, neigh)
			end
		end)
		
		-- loggers may decide to be legal
		if( math.random() < P_DEFOREST ) and ( #ag.forestNeighs > 0 )then 
			local neigh = ag.forestNeighs[math.random(#ag.forestNeighs)]
			neigh.agent = agent
			neigh.cover = RECENTLY_DEFORESTED
			agent.decision =  NOT_FOLLOW_RULES
		else
			-- loggers move searching for new areas			
			if ( #ag.deforestedNeighs > 0 ) then
				local neigh = ag.deforestedNeighs[math.random(#ag.deforestedNeighs)]
				-- print("FROM: "..ag.cell.x.." "..ag.cell.y)
				-- print("MOVE TO: "..neigh.x.." "..neigh.y)
				agent.cell.agent = agent
				agent:move(neigh)
			end
			agent.cell.cover = INHABITED
			agent.decision = FOLLOW_RULES
		
		end
	end
	
	return Agent( ag )
end

-- Government employee responsible for enforce the law
function Fiscal()
	ag = {}
	
	ag.decision = NOT_ENFORCE
	
	
	ag.execute = function(agent)
			local it = Trajectory{ 
				target = cs, 
				select = function( cell ) return cell.cover == RECENTLY_DEFORESTED or cell.cover == INHABITED end
			}

			forEachCell(it, function(cell)

				if ( math.random() < P_ENFORCEMENT ) then

					if math.random() < P_CAUGHT then 
						--print( "logger "..cell.agent.id.." has been caught...")
						if (cell.cover == INHABITED) then cell.cover = MISTAKE else cell.cover = CAUGHT end
					else 
						if (cell.cover == INHABITED) then cell.cover = MISTAKE else cell.cover = NOT_CAUGHT end
					end
			
					agent.decision = ENFORCE	
 				else
					agent.decision = NOT_ENFORCE
				end
				
			end)
	end
	
	return Agent( ag )
end

-- calculate payoff
calculatePayoff = function( cs )
	local totalPayoff = {0,0}
	forEachCell(cs, function(cell)	
		local payoff = {0,0} 
		if cell.cover == RECENTLY_DEFORESTED 	then payoff = game( NOT_FOLLOW_RULES, 	NOT_ENFORCE )  	
		elseif cell.cover == CAUGHT 			then payoff = game( NOT_FOLLOW_RULES, 	ENFORCE ) 		
		elseif cell.cover == NOT_CAUGHT 		then payoff = game( NOT_FOLLOW_RULES, 	ENFORCE ) 		-- does not matter the efficiency of the law enfforcement mechanism 
		elseif cell.cover == INHABITED	 		then payoff = game( FOLLOW_RULES, 		NOT_ENFORCE ) 	
		elseif cell.cover == MISTAKE	 		then payoff = game( FOLLOW_RULES, 		ENFORCE ) 	
		end
		totalPayoff = { totalPayoff[1] + payoff[1], totalPayoff[2] + payoff[2]}
	end)

	return totalPayoff;
end

-- Commit rounds deforestation
commitDeforestation = function( cs )
	forEachCell(cs, function(cell)	
		if cell.cover ~= FOREST then
			cell.cover = DEFORESTED
		end
	end)
end

-- Selects a new seed for the random number generator 
math.randomseed( os.time() )

-- Initially, the forest is everywhere 
forEachCell(cs, function(cell)
	cell.cover = FOREST
end)

--creates a legend
coverLeg = Legend{
		-- Attribute: cover
		type = "number",
		groupingMode = "uniquevalue",
		slices = 7,
		precision = 5,
		stdDeviation = "none",
		maximum = 6,
		minimum = 0,
		colorBar = {
			{color = {0, 255, 0}, value = 0},
			{color = {255, 0, 0}, value = 1},
			{color = {200, 200, 200}, value = 2},
			{color = {255, 255, 255}, value = 3},
			{color = {255, 255, 0}, value = 4},
			{color = {0, 0, 255}, value = 5},
			{color = {255, 85, 255}, value = 6}
		}
}

-- creates observer
obs = Observer{ subject = cs, type = "map", attributes={"cover"}, legends= {coverLeg} }
cs:notify()

-- Locate Logger agents
loggers = Society( Logger, N_LOGGERS)
forEachAgent(loggers, function(agent)
	local cell = cs:sample()
	cell.cover = DEFORESTED
	cell.agent = agent
	agent:enter(cell)
end)

-- Locate Fiscal 
fiscals = Society( Fiscal, N_FISCALS)
forEachAgent(fiscals, function(agent)
	local cell = cs:sample()
	cell.agent = agent
	agent:enter(cell)
end)

-- Alternative END: 1
-- Model main loop
totalPayoff = {0, 0}

t = Timer{
	Event{ action = function(event)
		print (event:getTime(),"ROUND")
		loggers:execute()
		fiscals:execute()
		synchronizeMessages()
		local payoff = calculatePayoff(cs)
		totalPayoff = { totalPayoff[1] + payoff[1], totalPayoff[2] + payoff[2] } 
		--if event:getTime() % SAVE_PERIODICITY == 0 then 
			cs:notify()
		--end
		commitDeforestation(cs)
	end}
}
t:execute(ROUNDS)

print("PAYOFF:","Loggers = "..totalPayoff[1], "Government = "..totalPayoff[2])

print("READY!")

