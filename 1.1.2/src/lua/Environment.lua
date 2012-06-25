Environment_ = { 
    type_ = "Environment",
	--add = function (self, object) return self.cObj_:add(object.cObj_); end,
	add = function (self, object)
		object.parent = self
		return self.cObj_:add(object.cObj_);
	end,
	addTimer = function(self, time, timer) return self.cObj_:addTimer(time, timer.cObj_); end,
	addCellularSpace = function(self, cellularSpace) return self.cObj_:addCellularSpace(cellularSpace.cObj_); end,
	addAgent = function(self, agent) return self.cObj_:addGlobalAutomaton(agent.cObj_); end,
	addAutomaton = function(self, automaton) return self.cObj_:addLocalAutomaton(automaton.cObj_); end,
	execute = function(self, finalTime) 
		self.cObj_:config(finalTime)
		self.cObj_:execute()
	end,
    notify = function (self, modelTime )
        if (modelTime == nil) or (type(modelTime) ~= 'number') then 
            modelTime = 0;
        end
		self.cObj_:notify(modelTime);
	end
}

local metaTableEnvironment_ = {__index = Environment_}

function Environment(attrTab)
	if attrTab.id == nil then 
		--error("Environment ID not defined!", 2)
		attrTab.id = "Environment"
	end
	local cObj = TeScale(attrTab.id)
	setmetatable(attrTab, metaTableEnvironment_)
	cObj:setReference(attrTab)
	for k, ud in pairs(attrTab) do
		--print("lua",k,ud);io.flush(); 
		local t = type(ud)
		if type(ud) == "table" then cObj:add(ud.cObj_); end
		if type(ud) == "userdata" then cObj:add(ud); end
		if (t == "CellularSpace" or t == "Society") then ud.parent = attrTab end
	end
	attrTab.cObj_ = cObj -- do not insert the attribute "cObj" in the "attrTab" table before de loop above
	return attrTab
end
