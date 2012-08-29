-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  ABM extension for TerraME
--  Last change: April/2012 
-- 
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: 
--      Pedro Andrade

function forEachConnection(agent, index, f)
	if type(index) == "function"  then
		f = index
		index = "1"
	elseif type(f) ~= "function" then
		error("Last parameter should be a function, got "..type(f)..".", 2)
	end

	if type(agent) ~= "Agent" then error("First arameter should be an Agent, got "..type(f)..".", 2) end
	local socialnetwork = agent:getSocialNetwork(index)
	if socialnetwork == nil then return false; end
	for index,connection in pairs(socialnetwork.connections) do
		weight = socialnetwork.weights[index]
		result = f(agent, connection, weight)
		if result == false then return false end
	end
	return true
end

function forEachAgent(obj, func)
	local t = type(obj)
	if t ~= "Society" and t ~= "Cell" and t ~= "Group" then
		error("Error: First parameter should be a Society, Group, or Cell, got "..t..".", 2)
	end
	local ags = obj.agents
	if ags == nil then error("Could not get agents from first parameter.", 2) end
	local k = 1
	-- forEachAgent needs to be different from the other forEachs because the
	-- ageng can die along its own execution and it shifts back all the other
	-- agents in society.agents. If ipairs was used instead, forEach would
	-- skip the next agent of the vector after the removed agent.
	for i = 1,#ags do
		local ag = ags[k]
		if ag and func(ag) == false then return false end
		if ag == ags[k] then k = k + 1 end
	end
	return true
end

local createSocialNetworkByQuantity = function(soc, quantity, name)
	forEachAgent(soc, function(agent)
		quant = 0
		rs = SocialNetwork()
		while quant < quantity do
			randomagent = soc:sample()
			if randomagent ~= agent and not rs:isConnection(randomagent) then
				rs:add(randomagent)
				quant = quant + 1
			end
		end
		agent:addSocialNetwork(rs, name)
	end)
end

local createSocialNetworkByProbability = function(soc, probability, name)
	forEachAgent(soc, function(agent)
		rs = SocialNetwork()
		forEachAgent(soc, function(hint)
			if hint ~= agent and math.random() < probability then
				rs:add(hint)
			end
		end)
		agent:addSocialNetwork(rs, name)
	end)
end

local function createSocialNetworkByFunction(society, func, self, name)
	forEachAgent(society, function(agent)
		rs = SocialNetwork()
		forEachAgent(society, function(hint)
			if func(agent, hint) then
				rs:add(hint)
			end
		end)
		agent:addSocialNetwork(rs, name)
	end)
end

local function createDynamicSocialNetworkByFunction(society, func, name)
	forEachAgent(society, function(agent)
		agent:addSocialNetwork(func, name)
	end)
end

local function createDynamicSocialNetworkByCell(society, self, name)
	if self == nil then self = false end 
	if name == nil then name = "1" end 
		local runfunction = function(agent)
		local  rs = SocialNetwork()
		forEachAgent(agent:getCell(), function(agentwithin)
			if agent ~= agentwithin or self then
				rs:add(agentwithin)
			end
		end)
		return rs
	end
	createDynamicSocialNetworkByFunction(society, runfunction, name)
end

local function createDynamicSocialNetworkByNeighbor(society, neighborhoodName, name)
	if name == nil then name = "1" end 
	if neighborhoodName == nil then neighborhoodName = "1" end 
	local runfunction = function(agent)
		local rs = SocialNetwork()
		forEachNeighbor(agent:getCell(),neighborhoodName, function(cell, neigh)
			forEachAgent(neigh, function(agentwithin)
				rs:add(agentwithin)
			end)
		end)
		return rs
	end
	createDynamicSocialNetworkByFunction(society, runfunction, name)
end

Society_ = {
	type_ = "Society",
	add = function(self, agent)
		if agent == nil then agent = {} end

		local mtype = type(agent)
		if mtype == "table" then
			agent.xxx = State{id="aa"} -- remove this in the next version
			agent = Agent(agent)

			local metaTable = {__index = self.instance}
			setmetatable(agent, metaTable)
			agent:init()
		elseif mtype ~= "Agent" then
			error("Invalid type: "..mtype..". It should be an Agent or a table", 2)
		end

		agent.parent = self
		table.insert(self.agents, agent)
		self.autoincrement = self.autoincrement + 1

		if agent.id == nil then agent.id = self.autoincrement end
		forEachElement(self.placements, function(_, placement)
			if agent[placement] == nil then
				-- if the agent already has this placement then
				-- it does not need to be built again
				agent[placement] = Trajectory{build = false}
				agent[placement].cells = {}
				if placement == "placement" then
					agent.cells = agent.placement.cells
				end
			end
		end)
		return agent
	end,
	clear = function(self) 
		self.agents = {}
		self.autoincrement = 1
	end,
	createSocialNetwork = function(self, data)
		if data.strategy == nil then
			if data.probability ~= nil then
				data.strategy = "probability"
			elseif data.quantity ~= nil then
				data.strategy = "quantity"
			elseif data.func ~= nil then
				data.strategy = "func"
			else
				error("Error: Argument 'strategy' is missing.", 2)
			end
		end

		if data.self == nil then data.self = false end

		if data.strategy == "probability" and type(data.probability) ~= "number" then
			error("Error: Argument 'probability' should be a number, got "..type(data.probability)..".", 2)
		elseif data.strategy == "quantity" and type(data.quantity) ~= "number" then
			error("Error: Argument 'quantity' should be a number, got "..type(data.quantity)..".", 2)
		end

		switch(data, "strategy"): caseof {
			["probability"] = function() createSocialNetworkByProbability(self, data.probability, data.name) end,
			["quantity"]    = function() createSocialNetworkByQuantity(self, data.quantity, data.name) end,
			["func"]        = function() createSocialNetworkByFunction(self, data.func, data.self, data.name) end,
			["cell"]        = function() createDynamicSocialNetworkByCell(self, data.self, data.name) end,
			["neighbor"]    = function() createDynamicSocialNetworkByNeighbor(self, data.neighborhood, data.name) end
		}
	end,
	execute = function(self)
		forEachAgent(self, function(single)
			single:execute()
		end)
	end,
	getAgent = function(self, idx)
		return self.agents[idx]
	end,
	getAgents = function(self)
		return self.agents
	end,
	notify = function (self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then
			modelTime = 0
		end
		forEachAgent(self, function(agent)
			agent:notify(modelTime)
		end)
	end,
	remove = function(self, agent)
		local id = -1
		local found = false

		-- remove agent from agents's table
		for k, v in pairs(self.agents) do
			if (v.id == agent.id) and (v == agent) then
				id = k
				found = true
				break
			end
		end
		if (found) then
			-- found = false
			table.remove(self.agents, id)
			--local ret = agent:kill(self.observerId)
		end
	end,
	sample = function(self)
		if (#self.agents > 0) then
			return self.agents[math.random(1, #self.agents)]
		else 
			return nil
		end
	end,
	size = function(self)
		return #self.agents
	end,
	split = function(self, argument)
		if type(argument) == "string" then
			local value = argument
			argument = function(agent)
				return agent[value]
			end
		end

		if type(argument) ~= "function" then
			error("First argument should be a function or a string, got "..type(argument)..".", 2)
		end

		local result = {}
		local class
		local i = 1
		forEachAgent(self, function(agent)
			class = argument(agent)

			if result[class] == nil then
				result[class] = Group{target = self, build = false}
			end
			table.insert(result[class].agents, agent)
			i = i + 1
		end)
		return result
	end,
	synchronize = function(self, delay)
		if delay == nil then delay = 1 end

		local k = 1
		for i = 1, table.getn(self.messages) do
			local kmessage = self.messages[k]
			kmessage.delay = kmessage.delay - delay

			if kmessage.delay <= 0 then
				kmessage.delay = true
				if kmessage.subject then
					kmessage.receiver["on_"..kmessage.subject](kmessage.receiver, kmessage)
				else
					kmessage.receiver:on_message(kmessage)
				end
				table.remove(self.messages, k)
			else
				k = k + 1
			end
		end
	end
}

metaTableSociety_ = {__index = Society_}

function Society(attrTab)
	if attrTab == nil then attrTab = {} end

	attrTab.agents = {}
	attrTab.messages = {}
	attrTab.observerId = -1 --## PEDRO: para que serve isto?
	attrTab.autoincrement = 1
	attrTab.placements = {}

	setmetatable(attrTab, metaTableSociety_)

	if attrTab.instance == nil then error("Any Society requires an 'instance', got nil.", 2) end
	if type(attrTab.instance) ~= "Agent" then
		error("Parameter 'instance' should be an Agent, got "..type(attrTab.instance)..".", 2)
	end

	if attrTab.quantity == nil then
		attrTab.quantity = 0
		return attrTab
	else
		local quantity = attrTab.quantity
		attrTab.quantity = 0
		for i = 1, quantity do
			attrTab:add()
		end
	end
	return attrTab
end

