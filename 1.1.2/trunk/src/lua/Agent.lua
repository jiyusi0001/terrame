Agent_ = {
    type_ = "Agent",
	add = function(self, object) self.cObj_:add(object); end,
	getLatency = function(self) return self.cObj_:getLatency(); end,
	execute = function(self, event) self.cObj_:execute(event); end,
	build = function(self, event) self.cObj_:build(); end,
	getStateName = function(self) return self.cObj_:getControlModeName(); end,
	setTrajectoryStatus = function(self, status) self.cObj_:setActionRegionStatus(status); end,
	action = function(ag, data)
		data.sender = ag
		data.delay = data.delay or DEFAULT_MESSAGE_DELAY
		if data.delay == 0 then
			data.receiver:onMessage(data)
		else
			table.insert(Messages_, data)
		end
	end,
	onMessage = function()
		error("Agent does not implement 'onMessage'.", 2)
	end,
	addRelative = function(ag, neigh, weight)
		table.insert(ag.relatives_, neigh)
		table.insert(ag.weights_, weight)
	end,
	getRelatives = function(at)
		return ag.relatives_
	end,
	enter = function(agent, cell)
		agent.cell = cell

		table.insert(cell.agents_, #cell.agents_ + 1, agent)
	end,
	leave = function(agent, cell)
		if cell == nil then cell = agent.cell end

		agent.cell = nil
		local ags = cell.agents_

		for i = 1, #cell.agents_, 1 do
			if agent == ags[i] then
				table.remove(ags, i)
				return
			end
		end
	end,
	move = function(agent, newcell)
		agent:leave()
		agent:enter(newcell)
	end,
	getLocation = function(agent)
		return agent.cell
	end,
    notify = function (self, modelTime )
        if (modelTime == nil) or (type(modelTime) ~= 'number') then 
            modelTime = 0;
        end
        self.cObj_:notify(modelTime);
    end
}

local metaTableAgent_ = {__index = Agent_}

function Agent(attrTab)
	local metaTable = {__index = Agent_}
	setmetatable(attrTab, metaTableAgent_)

	if (attrTab.class == nil) then
		attrTab.class = "undefined"
	end
	
	for i, ud in pairs(attrTab) do
		if type(ud) == "userdata" then -- if there is an 'userdata' then it is a State and we need the state machine functionalities
			local cObj = TeGlobalAutomaton()
			attrTab.cObj_ = cObj
			cObj:setReference(attrTab)
			for i, ud in pairs(attrTab) do 
				if type(ud) == "Trajectory" then cObj:add(ud.cObj_); end
				if type(ud) == "userdata" then cObj:add(ud); end
			end
			
			cObj:build()
			attrTab.relatives_ = {}
			attrTab.weights_   = {}
			return attrTab
		end
	end

	attrTab.relatives_ = {}
	attrTab.weights_   = {}
	return attrTab
end
