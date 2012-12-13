Cell_ = {
	type_ = "Cell",
	addNeighborhood = function(self, neigh, name)
		if (name == nil) then name = "1"; end
		return self.cObj_:addNeighborhood(name, neigh.cObj_)
	end,
	first = function(self)
		return self.cObj_:first()
	end,
	getAgent = function(cell, placement)
		if placement == nil then placement = "placement" end
		return cell[placement].agents[1]
	end,
	getAgents = function(cell, placement)
		if placement == nil then placement = "placement" end
		if(cell[placement]) then 		
			return cell[placement].agents
		else
			return cell.agents_
		end
	end,
	getCurrentNeighborhood = function(self)
		return self.cObj_:getCurrentNeighborhood()
	end,
	getID = function(self)
		return self.cObj_:getID()
	end,
	getNeighborhood = function(self, index)
		index = index or "1"
		return self.cObj_:getNeighborhood(index)
	end,
	getPast = function(self)
		return self.past
	end,
	getRandomAgent = function(cell)
		return cell.agents_[math.random(1, #cell.agents_)]
	end,
	getStateName = function(self, agent)
		return self.cObj_:getCurrentStateName(agent.cObj_)
	end, 
	isFirst = function(self) 
		return self.cObj_:isFirst()
	end,
	isLast = function(self)
	        return self.cObj_:isLast()
	end,
	last = function(self) 
		return self.cObj_:last()
	end,
	next = function(self) 
		return self.cObj_:next()
	end,
	notify = function (self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		self.cObj_:notify(modelTime)
	end,
	numberOfAgents = function(cell)
		return #cell.agents_
	end,
	size = function(self)
		return self.cObj_:size()
	end,
	synchronize = function(self) 
		self.past = {}
		for k,v in pairs(self) do if(k ~= "past") then self.past[k] = v; end end
	end
}

local metaTableCell_ = {__index = Cell_}

function Cell(attrTab)
	if(attrTab == nil) then attrTab = {}; end

	attrTab.cObj_ = TeCell()
	attrTab.past = {}
	attrTab.agents_ = {}

	setmetatable(attrTab, metaTableCell_)
	attrTab.cObj_:setReference(attrTab)
	
	if(attrTab.objectId_ ~= nil) then
		attrTab.cObj_:setID(attrTab.objectId_)
	else
		if(not attrTab.x) then attrTab.x = 0 end
		if(not attrTab.y) then attrTab.y = 0 end
		
		attrTab.cObj_:setID("C"..attrTab.x.."L"..attrTab.y)
		attrTab.objectId_ = attrTab.cObj_:getID()
	end
	attrTab.cObj_:setIndex(attrTab.x, attrTab.y)
	return attrTab
end

-- Transverse the neighborhood "index" from cell "cell" applying the
-- function "f( cell, neigh, weight )" to each neighbor
-- Transverse the neighborhood "index" from cell "cell" applying the
-- function "f( cell, neigh, weight )" to each neighbor
function forEachNeighbor(cell, index, f)
	if type(index) == "function" then
		f = index
		index = "1"
	end

	if type(cell) ~= "Cell" then error("Error: Parameter `cell' should be a Cell, got "..type(cell)..".", 2) end
	if type(f) ~= "function" then error("Error: Parameter `f' should be a function, got "..type(f)..".", 2) end
	local neighborhood = cell:getNeighborhood(index)
	if neighborhood == nil then return false; end
	neighborhood:first()
	while not neighborhood:isLast() do
		neigh = neighborhood:getNeighbor()
		weight = neighborhood:getWeight()
		result = f(cell, neigh, weight)
		if result == false then return false end
		neighborhood:next()
	end
	return true
end

-- Transverse all neighborhoods from cell "cell" applying the
-- function "f(neighborhood)" to each neighborhood
function forEachNeighborhood(cell, f)
	cell:first()
	while not cell:isLast() do
		local nh = cell:getCurrentNeighborhood()
		result = f(nh)
		if result == false then return false end
		cell:next()
	end
	return true
end

