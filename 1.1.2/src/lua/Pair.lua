function Pair(attrTab)
	local metaAttr = {
        cObj_ = attrTab,
        notify = function(self, modelTime )
            if (modelTime == nil) or (type(modelTime) ~= 'number') then 
                modelTime = 0;
            end
            if (type(self.cObj_[1]) == 'userdata') then
                self.cObj_[1]:notify(modelTime);  
            end
        end,
        getType = function(self) 
            return self.cObj_[1]:getType(); 
        end
    }
	local metaTable = {__index = metaAttr}
	if table.getn(attrTab) ~= 2 then
		error("A pair must have two attributes!", 2)
	end
	local metaTable = {__index = metaAttr}
	setmetatable(attrTab, metaTable)

	return attrTab
end
