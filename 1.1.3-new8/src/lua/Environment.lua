Environment_ = { 
	type_ = "Environment",
	add = function (self, object)
		object.parent = self
        table.insert(self, object)
		return self.cObj_:add(object.cObj_);
	end,
	addAgent = function(self, agent)
		return self.cObj_:addGlobalAutomaton(agent.cObj_)
	end,
	addAutomaton = function(self, automaton)
		return self.cObj_:addLocalAutomaton(automaton.cObj_)
	end,
	addCellularSpace = function(self, cellularSpace)
		return self.cObj_:addCellularSpace(cellularSpace.cObj_)
	end,
	addTimer = function(self, time, timer) 
		return self.cObj_:addTimer(time, timer.cObj_)
	end,
	createPlacement = function(self, data)
		if type(data) ~= "table" then
			error("Error: First argument should be a table, got "..type(data)..".", 2)
		end
		local mycs
		local foundsoc

		if data.strategy == nil then data.strategy = "random" end
		local qty_agents = 0

		if data.name == nil then data.name = "placement" end

		for k, ud in pairs(self) do
			local t = type(ud)
			if t == "CellularSpace" then
				if mycs ~= nil then
					error("Error: Environment has more than one CellularSpace.", 2)
				end
				mycs = ud
			elseif t == "Society" then
				qty_agents = qty_agents + ud:size()
				forEachElement(ud.placements, function(_, value)
					if value == data.name then
						error("There is a Society within this Environment that already has this placement.", 4)
					end
				end)

				table.insert(ud.placements, data.name)
				foundsoc = true
			elseif t == "Agent" then
				qty_agents = qty_agents + 1
				foundsoc = true
			elseif t == "Group" then
				error("Placements is still not implemented for groups.", 2)
			end
		end

		if mycs == nil then
			error("Error: The Environment does not contain a CellularSpace.", 2)
		elseif not foundsoc then
			error("Error: Could not find a behavioral entity (Society or Agent) within the Environment.", 2)
		end
		if data.strategy == "random" and data.max ~= nil and qty_agents > mycs:size() * data.max then
			error("It is not possible to put that amount of agents in space", 2)
		end

		table.foreach(self, function(_, element)
			local t = type(element)
			local placement = data.name
			if t == "CellularSpace" or t == "Trajectory" then
				forEachCell(element, function(cell)
					cell[placement] = Group{build = false}
					cell[placement].agents = {}
					cell.agents = cell[placement].agents
				end)
			elseif t == "Society" then
				forEachAgent(element, function(agent)
					agent[placement] = Trajectory{build = false}
					agent[placement].cells = {}
					agent.cells = agent[placement].cells
				end)
			elseif t == "Agent" then
					element[placement] = Trajectory{build = false}
					element[placement].cells = {}
					element.cells = element[placement].cells
			end
		end)

		switch(data, "strategy"): caseof {
			["random"]  = function() createRandomPlacement(self, mycs, data.max, data.name) end,
			["uniform"] = function() createUniformPlacement(self, mycs, data.name) end,
			["void"]    = function() end
		}
	end,
	execute = function(self, finalTime) 
		self.cObj_:config(finalTime)
		self.cObj_:execute()
	end,
	loadNeighborhood = function(self, tbAttrLoad)
		if (tbAttrLoad.name == nil) then tbAttrLoad.name = "1" end
		if (tbAttrLoad.source == nil) then error("Parameter 'source' was not specified.", 2) end
		if (tbAttrLoad.bidirect == nil) then tbAttrLoad.bidirect = false; end
		
		local extension = string.match(tbAttrLoad.source, "%w+$")

		if extension == "gpm" then
			print("Loading neighborhood \""..tbAttrLoad.name.."\" from a .gpm file...")
		else
			error("Error: The file extension \""..extension.."\" is not supported!\n", 2)
		end

		local file = io.open(tbAttrLoad.source, "r")
		
		local header = file:read()
		
		local numAttribIdx = string.find(header, "%s", 1)
		local layer1Idx = string.find(header, "%s", (numAttribIdx + 1))
		local layer2Idx = string.find(header, "%s", (layer1Idx + 1))
		
		local numAttributes = tonumber(string.sub(header, 1, numAttribIdx))
		local layer1Id = string.sub(header, (numAttribIdx + 1), (layer1Idx - 1))
		local layer2Id = string.sub(header, (layer1Idx + 1), (layer2Idx - 1))

		if (numAttributes > 1) then
			error("Error: This function does not support GPM with more than one attribute.", 2)
		end

		local beginName = layer2Idx
		local attribNames = {}

		for i = 1, numAttributes do
			if (i ~= 1) then local beginName = string.find(header, "%s", (endName + 1)); end
			
			local endName = string.find(header, "%s", (beginName + 1))
			
			if (endName ~= nil) then
				attribNames[i] = string.sub(header, (beginName + 1), (endName - 1))
			else
				attribNames[i] = string.sub(header, (beginName + 1))
				break
			end
		end
		
		local cellSpaces = {}
		for i, element in pairs(self) do
			if (type(element) == "CellularSpace") then
				local cellSpaceLayer = element.layer
				
				if (cellSpaceLayer == layer1Id) then cellSpaces[1] = element
				elseif (cellSpaceLayer == layer2Id) then cellSpaces[2] = element; end
			end
		end
		
		if (cellSpaces[1] == nil or cellSpaces[2] == nil) then
			error("Error: CellularSpaces were not found in the Environment.", 2)
		end

		repeat
			local line_cell = file:read()
			if (line_cell == nil) then break; end

			local cellIdIdx = string.find(line_cell, "%s", 1)
			local cellId = string.sub(line_cell, 1, (cellIdIdx - 1))
			local numNeighbors = tonumber(string.sub(line_cell, (cellIdIdx + 1)))

			local cell = cellSpaces[1]:getCellByID(cellId)

			local neighborhood = Neighborhood()
			cell:addNeighborhood(neighborhood, tbAttrLoad.name)

			if (numNeighbors > 0) then
				line_neighbors = file:read()

				local neighIdEndIdx = string.find(line_neighbors, "%s", 1)
				local neighIdIdx = 0

				for i = 1, numNeighbors do
					if (i ~= 1) then neighIdIdx = string.find(line_neighbors, "%s", (neighIdEndIdx + 1)); end
					neighIdEndIdx = string.find(line_neighbors, "%s", (neighIdIdx + 1))
					local neighId = string.sub(line_neighbors, (neighIdIdx + 1), (neighIdEndIdx - 1))
					local neighbor = cellSpaces[2]:getCellByID(neighId)

					-- Gets the weight
					local weightEndIdx = string.find(line_neighbors, "%s", (neighIdEndIdx + 1))

					if (weightEndIdx == nil) then 
						local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1));
						weight = tonumber(weightAux)
						
						if(weight == nil)then
							error("Error: the string \""..weightAux.."\" found as weight in the file \""..tbAttrLoad.source..
								  "\" could not be converted to a number.", 2)
						end
					else
						local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1), (weightEndIdx - 1))
						weight = tonumber(weightAux)
						
						if(weight == nil)then
							error("Error: the string \""..weightAux.."\" found as weight in the file \""..tbAttrLoad.source..
								  "\" could not be converted to a number.", 2)
						end
					end

					-- Adds the neighbor in the neighborhood
					neighborhood:addNeighbor(neighbor, weight)

					if (tbAttrLoad.bidirect == true) then 
						local neighborhoodNeigh = neighbor:getNeighborhood(tbAttrLoad.name)
						if (neighborhoodNeigh == nil) then
							neighborhoodNeigh = Neighborhood()
							neighbor:addNeighborhood(neighborhoodNeigh, tbAttrLoad.name)
						end
						neighborhoodNeigh:addNeighbor(cell, weight)
					end
				end
			end
		until(line_cell == nil)
		
		file:close()
	end,
	notify = function(self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then
			modelTime = 0
		end
		self.cObj_:notify(modelTime)
	end
}

local metaTableEnvironment_ = {__index = Environment_}

function Environment(attrTab)
	if attrTab.id == nil then 
		attrTab.id = "Environment"
	end
	local cObj = TeScale(attrTab.id)
	setmetatable(attrTab, metaTableEnvironment_)
	cObj:setReference(attrTab)
	for k, ud in pairs(attrTab) do
		local t = type(ud)
		if t == "table" then cObj:add(ud.cObj_); end
		if t == "userdata" then cObj:add(ud); end
		if t == "CellularSpace" or t == "Society" or t == "Agent" then ud.parent = attrTab; end
	end
	attrTab.cObj_ = cObj
	return attrTab
end

--PEDROO: removi o 'local' 
createRandomPlacement = function(environment, cs, max, placement)
	if max == nil then
		table.foreach(environment, function(_, element)
			local t = type(element)
			if t == "Society" then
				forEachAgent(element, function(agent)
					agent:enter(cs:sample(), placement)
				end)
			elseif t == "Agent" then
				element:enter(cs:sample(), placement)
			end 
		end)
	else -- max ~= nil
		table.foreach(environment, function(_, element)
			local t = type(element)
			if t == "Society" then
				forEachAgent(element, function(agent)
					local cell = cs:sample()
					while cell[placement]:size() >= max do
						cell = cs:sample()
					end
					agent:enter(cell, placement)
				end)
			elseif t == "Agent" then
				local cell = cs:sample()
				while cell[placement]:size() >= max do
					cell = cs:sample()
				end 
				element:enter(cell, placement)
			end 
		end)
	end
end

--PEDROO: removi o 'local' 
createUniformPlacement = function(environment, cs, placement)
	local counter = 1 
	forEachElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			forEachAgent(element, function(agent)
				agent:enter(cs.cells[counter], placement)
				counter = counter + 1 
				if counter > cs:size() then
					counter = 1 
				end 
			end)
		elseif mtype == "Agent" then
			agent:enter(cs.cells[counter], placement)
			counter = counter + 1 
			if counter > cs:size() then
				counter = 1 
			end 
		end 
	end)
end

