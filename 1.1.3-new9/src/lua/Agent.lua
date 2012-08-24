
local deadAgentMetaTable_ = {__index = function()
	error("Trying to use a function or an attribute of a dead Agent.", 2)
end}

Agent_ = {
	type_ = "Agent",
	add = function(self, object)
		self.cObj_:add(object)
	end,
	addSocialNetwork = function(self, set, name)
		if name == nil then name = "1" end
		self.socialnetworks[name] = set
	end,
	build = function(self, event)
		self.cObj_:build()
	end,
	die = function(self, remove_placements)
		if remove_placements == true and not self.parent then
			error("Error: Can not remove the placements of an Agent that do not belong to a Society.", 2)
		end

		if remove_placements == nil then remove_placements = true end

		-- remove all the placements
		if remove_placements and self.parent then
			forEachElement(self.parent.placements, function(_, value)
				self:leave(nil, value)
			end)
		end
		self.execute = function() end
		-- remove all the possible ways of getting delayed messages
		forEachElement(self, function(idx, _, mtype)
			if mtype == "function" and idx:sub(1, 3) == "on_" then
				self[idx] = function() end
			end
		end)
		self.on_message = function() end
		self.parent:remove(self)
		setmetatable(self, deadAgentMetaTable_)
	end,
	enter = function(agent, cell, placement)
		if placement == nil then placement = "placement" end
		if (agent[placement]) then 
			agent[placement].cells[1] = cell
		end
		if (cell[placement]) then
			cell[placement]:add(agent)
		end
		agent.cell = cell

		--table.insert(cell.agents_, #cell.agents_ + 1, agent)
	end,
	execute = function(self, event)
		self.cObj_:execute(event)
	end,
	getCell = function(agent, placement)
		if placement == nil then placement = "placement" end
		if agent[placement] == nil or type(agent[placement]) ~= "Trajectory" then
			if placement == "placement" then
				error("Placement not found.", 2)
			else
				error("Placement '"..placement.."' not found.", 2)
			end
		end
		return agent[placement].cells[1]
	end,
	getCells = function(agent, placement)
		if placement == nil then placement = "placement" end
		return agent[placement].cells
	end,
	getID = function(self)
		return self.id
	end,
	getLatency = function(self)
		return self.cObj_:getLatency()
	end,
	getSocialNetwork = function(self, name)
		if name == nil then name = "1" end
		local s = self.socialnetworks[name] 
		if type(s) == "function" then
			s = s(self)
		end
		return s
	end,
	getStateName = function(self)
		return self.cObj_:getControlModeName()
	end,
	init = function() -- virtual function that might be implemented by the modeler
	end,
	leave = function(agent, cell, placement)
		if placement == nil then placement = "placement" end
		if agent[placement] == nil or type(agent[placement]) ~= "Trajectory" then
			if placement == "placement" then
				error("Error: Placement not found.", 2)
			else
				error("Error: Placement '"..placement.."' not found.", 3)
			end
		end
		if cell == nil and agent[placement] then
			cell = agent[placement].cells[1]
		end

		agent.cell = nil
		if (agent[placement]) then
			agent[placement].cells[1] = nil
		end

		if cell and cell[placement] then
			local ags = cell[placement].agents
			if table.getn(ags) == 0 then
				return true
			end

			for i = 1, #ags do
				if agent.id == ags[i].id and agent.parent == ags[i].parent then
					table.remove(ags, i)
					return true
				end
			end
		end
	end,
	message = function(self, data)
		data.sender = self
		if type(data.receiver) ~= "Agent" then
			error("Error: Parameter 'receiver' should be an Agent, got "..type(data.receiver)..".", 2) 
		end
		if data.delay == nil or data.delay == 0 then
			if data.subject then
				local call = "on_"..data.subject
				if type(data.receiver[call]) ~= "function" then
					error("Receiver (id = "..data.receiver:getID()..") does not implement function "..call..".", 2)
				end
				data.receiver[call](data.receiver, data)
			else
				data.receiver:on_message(data)
			end
		elseif type(self.parent) ~= "Society" then
			error("Agent must be within a Society to send messages with delay.", 2)
		else
			table.insert(self.parent.messages, data)
		end
	end,
	move = function(agent, newcell, placement)
		agent:leave(nil, placement)
		agent:enter(newcell, placement)
	end,
	notify = function (self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		self.cObj_:notify(modelTime)
	end,
	on_message = function(ag)
		error("Error: Agent "..ag:getID().." does not implement 'on_message'.", 2)
	end,
	randomWalk = function(self, placement)
		self:move(self:getCell(placement):getNeighborhood():sample(), placement)
	end,
	reproduce = function(self, data)
		if self.parent == nil then
			error("Agent should belong to a Society to reproduce.", 2)
		end

		ag = self.parent:add(data)

		if self.placement ~= nil then
			ag:enter(self:getCell())
		end
		return ag
	end,
	setTrajectoryStatus = function(self, status)
		self.cObj_:setActionRegionStatus(status)
	end
}

local metaTableAgent_ = {__index = Agent_}

function Agent(attrTab)
	local metaTable = {__index = Agent_}
	setmetatable(attrTab, metaTableAgent_)

	-- TODO: para que serve isto?
	if (attrTab.class == nil) then
		attrTab.class = "undefined"
	end

	local cObj = TeGlobalAutomaton()
	attrTab.cObj_ = cObj
	cObj:setReference(attrTab)

	for i, ud in pairs(attrTab) do
		if type(ud) == "Trajectory" then cObj:add(ud.cObj_); end
		if type(ud) == "userdata" then cObj:add(ud); end
	end
			
	cObj:build()
	attrTab.socialnetworks = {}
	return attrTab
end

