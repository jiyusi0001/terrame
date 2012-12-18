local function coordCoupling(cs1, cs2, name)
	if name == nil then name = "1"; end
	local lin
	local col
	local i = 0
	forEachCell(cs1, function(cell)
		local neighborhood = Neighborhood()
		local coord = Coord{x = cell.x, y = cell.y}
		local neighCell = cs2:getCell(coord)
		if neighCell then
			neighborhood:addCell(coord, cs2, 1)
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	forEachCell(cs2, function(cell)
		local neighborhood = Neighborhood()
		local coord = Coord{x = cell.x, y = cell.y}
		local neighCell = cs1:getCell(coord)
		if neighCell then 
			if filterF(cell, neighCell) then
				neighborhood:addCell(coord, cs1, 1)
			end 
		end
		cell:addNeighborhood(neighborhood, name)
	end)
end

local function createMooreNeighborhood(cs, name, self)
	local weight = 1/8
	if self == nil then self = true end
	if self then weight = 1/9 end
	if name == nil then name = "1"; end
	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood()
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do 
				if self or (lin ~= col or col ~= 0) then
					local index = Coord{x = (cell.x + col), y = (cell.y + lin)}
					neigh:addCell(index, cs, weight)
				end

				col = col + 1
			end
			lin = lin + 1
		end
		cell:addNeighborhood(neigh, name)
	end
end

-- Creates a von Neumann neighborhood for each cell
local function createVonNeumannNeighborhood(cs, name)
	local weight = 1/4
	if name == nil then name = "1"; end
	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood()
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do
				if (lin == 0 or col == 0) and lin ~= col then
					local index = Coord{x = (cell.x + col), y = (cell.y + lin)}
					neigh:addCell(index, cs, weight)
				end

				col = col + 1
			end
			lin = lin + 1
		end
		cell:addNeighborhood(neigh, name)
	end
end

-- Creates a neighborhood for each cell according to a modeler defined function
local function createNeighborhood(cs, filterF, weightF, name)
	if name == nil then name = "1"; end
	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood()
		forEachCell(cs, function(neighCell)
			if filterF(cell, neighCell) then
				neighborhood:addNeighbor(neighCell, weightF(cell, neighCell))
			end
		end)
		cell:addNeighborhood(neighborhood, name)
	end)
end

-- Creates a 3x3 stationary (couclelis) neighborhood
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be 
--                              included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function create3x3Neighborhood(cs, filterF, weightF, name)
	if name == nil then name = "1"; end
	weightF = weightF or function() return 1 end

	local lin
	local col
	local i = 0
	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood()
		for lin = -1, 1, 1 do
			for col = -1, 1, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)}
				local neighCell = cs:getCell(coord)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs, weightF(cell,neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
end

-- Creates a M (collumns) x N (rows) stationary (couclelis) neighborhood
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be 
--                              included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function createMxNNeighborhood(cs, M, N, filterF, weightF, name)
	if name == nil then name = "1"; end
	M = math.floor(M/2)
	N = math.floor(N/2)
	if N < 0 then N = 1; end
	if M < 0 then M = 1; end
	local lin
	local col
	local i = 0
	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood()
		for lin = -N, N, 1 do
			for col = -M, M, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)}
				local neighCell = cs:getCell(coord)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs, weightF(cell,neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
end


-- Creates a M (collumns) x N (rows) stationary (couclelis) neighborhood bettween TWO different CellularSpace
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be 
--                              included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function spatialCoupling(M, N, cs1, cs2, filterF, weightF, name)
	if name == nil then name = "1"; end
	M = math.floor(M/2)
	N = math.floor(N/2)
	if N < 0 then N = 1; end
	if M < 0 then M = 1; end
	local lin
	local col
	local i = 0
	forEachCell(cs1, function(cell)
		local neighborhood = Neighborhood()
		for lin = -N, N, 1 do
			for col = -M, M, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)}
				local neighCell = cs2:getCell(coord)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs2, weightF(cell,neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	forEachCell(cs2, function(cell)
		local neighborhood = Neighborhood()
		for lin = -N, N, 1 do
			for col = -M, M, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)}
				local neighCell = cs1:getCell(coord)
				if neighCell then 
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs1, weightF(cell,neighCell))
					end
				end
			end
		end	
		cell:addNeighborhood(neighborhood, name)
	end)
end

CellularSpace_ = {
	type_ = "CellularSpace",
	--## ADICIONADO PEDRO REQUER Lua 4.2
	--__len = function(self) print(" BB" ) return table.getn(self.cells); end,
	--## ADICIONADO PEDRO REQUER Lua 4.2
	--__index = function(self, pos) print(">>"); return self.cells[pos] end, 
	add = function(self, cell)
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
		table.insert(self.cells, cell)
		self.minRow = math.min(self.minRow, cell.y)
		self.minCol = math.min(self.minCol, cell.x)
		self.maxRow = math.max(self.maxRow, cell.y)
		self.maxCol = math.max(self.maxCol, cell.x)
	end,
	createNeighborhood = function(self, data)
		if data == nil then data = {} end
		if data.strategy == nil then data.strategy = "moore" end

		if data.target ~= nil then
			if type(data.target) ~= "CellularSpace" then
				error("Error: Type of attribute target is "..type(data.target)..". It should be CellularSpace.", 2)
			end
			
			switch(data, "strategy"): caseof {
				["coord"] = function() coordCoupling(self, data.target, data.name) end,
				["mxn"]   = function() spatialCoupling(data.m, data.n, self, data.target, data.filter, data.weight, data.name) end
			}
		else
			switch(data, "strategy") : caseof {
				["function"]   = function() createNeighborhood(self, data.filter, data.weight, data.name) end,
				["moore"]      = function() createMooreNeighborhood(self, data.name, data.self) end,
				["mxn"]        = function() createMxNNeighborhood(self, data.m, data.n, data.filter, data.weight, data.name) end,
				["vonneumann"] = function() createVonNeumannNeighborhood(self, data.name) end,
				["3x3"]        = function() create3x3Neighborhood(self, data.filter, data.weight, data.name) end
			}			
		end
	end,
	getCell = function(self, index)
		return self.cObj_:getCell(index.cObj_)
	end,
	getCells = function(self)
		return self.cells
	end,
	-- Esta funcao e necessaria para o loadNeighborhood a partir do Environment
	getCellByID = function(self, cellID)
		return self.cObj_:getCellByID(cellID)
	end,
	load = function(self)
		self.legend = {} 
		local x = 0
		local y = 0
		local legendStr = ""
		
		local load = load
        if (_VERSION ~= "Lua 5.2") then
           load = loadstring
        end		
		
		self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow, legendStr = self.cObj_:load()
		self.legend = load(legendStr)()

		-- A ordenacao eh necessaria pq o TerraView ordena os 
		-- objectIDs como strings:..., C00L10, C00L100, C00L11...
		table.sort(self.cells, function(a, b) 
			if a.x < b.x then return true; end
			if a.x > b.x then return false; end
			return a.y < b.y
		end)

		self.xdim = self.maxCol
		self.ydim = self.maxRow
		self.cObj_:clear()
		for i, tab in pairs(self.cells) do
			tab.agents_ = {}
			self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
		end
		--trecho necessario no loadNeighborhood do Environment)
		self.layer = self.cObj_:getLayerName()
	end,
	
	loadShape = function(self)
		self.legend = {} 
		local x = 0
		local y = 0
		local legendStr = ""
		self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow = self.cObj_:loadShape()
		self.legend = loadstring(legendStr)()
		-- A ordenacao eh necessaria pq o TerraView ordena os 
		-- objectIDs como strings:..., C00L10, C00L100, C00L11...
		table.sort(self.cells, function(a, b) 
			if a.x < b.x then return true; end
			if a.x > b.x then return false; end
			return a.y < b.y
		end)

		self.xdim = self.maxCol
		self.ydim = self.maxRow
		self.cObj_:clear()
		for i, tab in pairs(self.cells) do
			tab.agents_ = {}
			self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
		end
		self.layer = self.cObj_:getLayerName()
	end,
	
	loadNeighborhood = function(self, tbAttrLoad)
		if tbAttrLoad.name == nil then tbAttrLoad.name = "1"; end
		if tbAttrLoad.source == nil then error("'source' is a compulsory argument", 2) end
		self.cObj_:loadNeighborhood(tbAttrLoad.source, tbAttrLoad.name)
	end,
	notify = function (self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		self.cObj_:notify(modelTime)
	end,
	sample = function(self)
		return self.cells[math.random(1,self:size())]
	end,
	save = function(self, time, outputTableName, attrNames)
		if (type(attrNames) == "string") then attrNames = {attrNames} end
		local erros = self.cObj_:save(time, outputTableName, attrNames, self.cells)
	end,
	size = function(self) return getn(self.cells); end,
	split = function(self, argument)
		if type(argument) == "string" then
			local value = argument
			argument = function(cell)
				return cell[value]
			end
		end

		if type(argument) ~= "function" then
			error("First argument should be a function or a string, got "..type(argument)..".", 2)
		end

		local result = {}
		local class
		local i = 1
		forEachCell(self, function(cell)
			class = argument(cell)

			if result[class] == nil then
				result[class] = Trajectory{target = self, build = false}
			end
			table.insert(result[class].cells, cell)
			result[class].cObj_:add(i, cell.cObj_)
			i = i + 1
		end)
		return result
	end,
	synchronize = function(self, values)
		if type(values) == "string" then values = {values} end
		if values == nil then
			values = {}
			local count = 1
			local cell = self.cells[1]
			for k,v in pairs(cell) do
				if k ~= "past" and k ~= "cObj_" and k ~= "agents_" and k ~= "x" and k ~= "y" then
					values[count] = k
					count = count + 1
				end
			end
		end

		local s = "return function(cell)\n"
		s = s.."cell.past = {"

		for _,v in pairs(values) do
			s = s..v.." = cell."..v..", "
		end

		s = s.."} end"

		
		local load = load
		if (_VERSION ~= "Lua 5.2") then
           load = loadstring
		end
		forEachCell(self, load(s)())
	end
}

metaTableCellularSpace_ = {__index = CellularSpace_}

function CellularSpace(attrTab)
	local cObj = TeCellularSpace()
    
    local shpType = false    
    
	attrTab.cells = {}
	attrTab.cObj_= cObj
	if attrTab.minRow == nil then attrTab.minRow = 100000 end
	if attrTab.minCol == nil then attrTab.minCol = 100000 end
	if attrTab.maxRow == nil then attrTab.maxRow = -attrTab.minRow end
	if attrTab.maxCol == nil then attrTab.maxCol = -attrTab.minCol end

	if attrTab.xdim ~= nil then -- rectangular "virtual" cellular space
		attrTab.ydim = attrTab.ydim or attrTab.xdim
		
		attrTab.minRow = 1
		attrTab.minCol = 1
		attrTab.maxRow = attrTab.ydim
		attrTab.maxCol = attrTab.xdim
		
		attrTab.load = function(self)
			self.cells = {}
			self.cObj_:clear()
			for i = 1, self.xdim do
				for j = 1, self.ydim do
					c = Cell{x = i-1, y = j-1}
					c.agents_ = {}
					c.parent = self
					--self:add(c)
					-- The line obove was replaced by the two following lines in order to get better performance
					self.cObj_:addCell(c.x, c.y, c.cObj_)
					table.insert(self.cells, c)
				end
			end
		end
	else
		if attrTab.database ~= nil then cObj:setDBName(attrTab.database); else error("Error: Parameter `database' is required.", 2); end
		local dbname = attrTab.database
		local extension = string.sub(dbname, #dbname-3, #dbname)		
		if extension == ".shp" then 
		    shpType=true
            local shapeExists = io.open(dbname,"r")
            if shapeExists==nil then error("Error: Shapefile not Found",2)
            else io.close(shapeExists)
            end
        else
		    if attrTab.host == nil     then cObj:setHostName("localhost");    else cObj:setHostName(attrTab.host); end
		    if attrTab.user == nil     then cObj:setUser("");                 else cObj:setUser(attrTab.user); end
		    if attrTab.password == nil then cObj:setPassword("");             else cObj:setPassword(attrTab.password); end
		    if attrTab.theme ~= nil    then cObj:setTheme(attrTab.theme);     else error("Error: Parameter `theme' is required.", 2); end
		    if attrTab.layer ~= nil    then cObj:setLayer(attrTab.layer);     else cObj:setLayer(""); end

		    if (attrTab.dbType == nil) then 
			    --local dbname = attrTab.database
			    --local extension = string.sub(dbname, #dbname-3, #dbname)

			    if extension == ".mdb" then
				    cObj:setDBType("ado")
			    else
				    cObj:setDBType("mysql")
			    end
		    else
			    cObj:setDBType(string.lower(attrTab.dbType))
		    end
        end        
        
		if (attrTab.select ~= nil) then
			if (type(attrTab.select) == "string") then attrTab.select = {attrTab.select} end
			cObj:clearAttrName()
			for i in ipairs(attrTab.select) do
				cObj:addAttrName(attrTab.select[i])
			end
		end
		
		if(attrTab.where ~= nil) then cObj:setWhereClause(attrTab.where); end
	end
	setmetatable(attrTab, metaTableCellularSpace_)
	cObj:setReference(attrTab)
    if(shpType) then attrTab:loadShape()
	else attrTab:load()
	end
	return attrTab
end

-- Traverses "cs" applying the "f(cell)" function to each cell
function forEachCell(cs, f)
	local t = type(cs)
	if t ~= "CellularSpace" and t ~= "Trajectory" and t ~= "Agent" then
		error("Error: First parameter should be a CellularSpace, a Trajectory, or an Agent, got "..t..".", 2)
	end
	if type(f) ~= "function" then
		error("Error: Second parameter should be a function, got "..type(f)..".", 2)
	end
	for i, cell in ipairs(cs.cells) do
		result = f(cell, i)
		if result == false then return false end
	end
	return true
end

-- Traverses the cellular spaces "cs1" and "cs2" applying the 
-- "f(cell1, cell2)" function to each correspondent cell pair.
-- "cell1" belongs to "cs1" and "cell2" belongs to "cs2".
-- The cellular spaces must have the same size.
function forEachCellPair(cs1, cs2, f)
	for i, cell1 in ipairs(cs1.cells) do
		cell2 = cs2.cells[i]
		result = f(cell1, cell2, i)
		if result == false then return false end
	end
	return true
end

