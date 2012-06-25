Automaton_ = {
    type_ = "Automaton",
	autoincrement = 1,
	add 					= function(self, state) self.cObj_:add(state); end,
	getLatency 				= function(self) return self.cObj_:getLatency(); end,
	execute 				= function(self, event) self.cObj_:execute(event); end,
	build 					= function(self) self.cObj_:build(); end,
	getStateName 			= function(self) return "Where?"; end,
	setTrajectoryStatus 	= function(self, status) self.cObj_:setActionRegionStatus(status); end,
    notify = function(self, modelTime )
        if (modelTime == nil) or (type(modelTime) ~= 'number') then 
            modelTime = 0;
        end
        self.cObj_:notify(modelTime);
    end
}

local metaTableAutomaton_ = {__index = Automaton_}

function Automaton( attrTab )
	local cObj = TeLocalAutomaton()
	attrTab.cObj_ = cObj
	
	if (attrTab.class == nil) then
		attrTab.class = "automaton_" .. Automaton_.autoincrement
		Automaton_.autoincrement = Automaton_.autoincrement + 1
	end
	
	setmetatable(attrTab, metaTableAutomaton_)
	cObj:setReference(attrTab)
	for i, ud in pairs(attrTab) do 
		if type(ud) == "Trajectory" then cObj:add(ud.cObj_); end
		if type(ud) == "userdata" then cObj:add(ud); end
	end
	cObj:build()
	return attrTab
end
