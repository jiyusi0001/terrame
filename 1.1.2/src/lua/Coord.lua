Coord_ = {
    type_ = "Coord",
	set = function(self, attrTab)
		local xOld, yOld = self.cObj_:get()
		if(attrTab == nil) then attrTab = {x = 0, y = 0}; end
		if(attrTab.x == nil) then attrTab.x = xOld; end
		if(attrTab.y == nil) then attrTab.y = yOld; end
		self.x = attrTab.x
		self.y = attrTab.y
		self.cObj_:set(attrTab.x, attrTab.y)
	end,
	get = function(self) 
		local attrTab = {}
		attrTab.x, attrTab.y = self.cObj_:get()
		return attrTab
	end
}

local metaTableCoord_ = {__index = Coord_}

function Coord(attrTab)
	if(attrTab == nil)   then attrTab = {x = 0, y = 0}; end
	if(attrTab.x == nil) then attrTab.x = 0; end
	if(attrTab.y == nil) then attrTab.y = 0; end
	attrTab.cObj_ = TeCoord(attrTab)
	local metaTable = {__index = Coord_}
	setmetatable(attrTab, metaTableCoord_)
	attrTab.cObj_:setReference(attrTab)
	attrTab.x = nil
	attrTab.y = nil
	return attrTab
end
