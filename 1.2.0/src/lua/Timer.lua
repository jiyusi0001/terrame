Timer_ = {
	type_ = "Timer",
	add = function (self, event) 
		if type(event) == "table" then self.cObj_:add(event.cObj_[1],event.cObj_[2].cObj_); end
	end,
	getTime = function(self) return self.cObj_:getTime(); end,
	execute = function(self, finalTime)
		if type(finalTime) ~= "number" then
			error("Error: First argument should be a number, got "..type(finalTime)..".", 2)
		end
		self.cObj_:execute(finalTime)
	end,
	reset = function(self) self.cObj_:reset(); end,
	notify = function (self, modelTime )
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		return self.cObj_:notify(modelTime)
	end
}

local metaTableTimer_ = {__index = Timer_}

function Timer(attrTab)
	local cObj = TeTimer()

	if attrTab == nil then attrTab = {}; end
	attrTab.cObj_ = cObj

	for i, ud in pairs(attrTab) do
		if type(ud) == "table" then cObj:add(ud.cObj_[1], ud.cObj_[2].cObj_); end
	end
	setmetatable(attrTab, metaTableTimer_)
	cObj:setReference(attrTab)
	return attrTab
end

