Pair_ = {
	notify = function(self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		if (type(self.cObj_[1]) == 'userdata') then
			self.cObj_[1]:notify(modelTime)
		end
	end
}

local metaTablePair_ = {__index = Pair_}

function Pair(attrTab)
	if(attrTab == nil) then attrTab = {}; end

	if table.getn(attrTab) ~= 2 then
		error("Error: A pair must have two attributes.", 2)
	end
	
	setmetatable(attrTab, metaTablePair_)
	attrTab.cObj_ = attrTab	

	return attrTab
end