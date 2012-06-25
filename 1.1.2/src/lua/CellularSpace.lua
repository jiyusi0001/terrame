CellularSpace_ = {
    type_ = "CellularSpace",
	size = function(self) return table.getn(self.cells); end,
	loadNeighborhoodFile = function(self, fileName, neighName)
        if( neighName == nil) then neighName = "1"; end;
		self.cObj_:loadNeighborhoodFile(fileName, neighName)
	end,
	loadTerraLibGPM = function(self, id)
		if id == nil then id = "1"; end
		self.cObj_:loadTerraLibGPM(id)
	end,
	load = function(self)
		self.legend = {} 
		local x = 0
		local y = 0

		self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow= self.cObj_:load()

        -- Solução temporária para a carga de legendas. Uma legenda é carregada na variavel 
        -- global "legendPOG___" na chamada do metodo "load" acima, como um efeito colateral.
		-- Uma melhor solução seria a definição de uma função especifica para a carga de 
        -- legendas, por exemplo, "loadLegend"
		self.legend = legendPOG___
		legendPOG___ = nil
        
		-- A ordenacao é necessaria pq o TerraView ordena os 
        -- objectIDs como strings:..., C00L10, C00L100, C00L11...
		table.sort( self.cells, function(a,b) 
			if a.x < b.x then return true; end
			if a.x > b.x then return false; end
			return a.y < b.y
		end);
		
		-- --Alteração Antonio
		self.xdim = self.maxCol -- - self.minCol + 1
		self.ydim = self.maxRow -- - self.minRow + 1		
                 self.cObj_:clear()
		for i, tab in pairs(self.cells) do
			tab.agents_ = {}
			self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
		end
	end,
	save = function(self, time, outputTableName, attrNames)
		if (type(attrNames) == "string") then attrNames = {attrNames} end -- in case of 'string', convert to a single position vector
		local erros = self.cObj_:save(time, outputTableName, attrNames, self.cells)
	end,
	synchronize  = function(self, values)
		if (type(values) == "string") then values = {values} end
		if values == nil then
			values = {}
            count = 1
            cell = self.cells[1]
            for k,v in pairs(cell) do
                if k ~= "past" and k ~= "cObj_" and k ~= "agents_" and k ~= "x" and k ~= "y" then
                    values[count] = k
                    count = count + 1
                end
            end
       end

       s = "return function(cell)\n"

       s = s.."cell.past = {"

       for _,v in pairs(values) do
               s = s..v.." = cell."..v..", "
       end

       s = s.."} end"
       sync = loadstring(s)()

       forEachCell(self, sync)
	end, 
	getCell = function(self, index)
		return self.cObj_:getCell(index.cObj_)
	end,
	add = function(self, cell)
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
		table.insert(self.cells, cell)
		-- Antonio
		-- Recupera o máximo e mínimo das colunas e linhas
		self.minRow = math.min(self.minRow, cell.y)
		self.minCol = math.min(self.minCol, cell.x)
		self.maxRow = math.max(self.maxRow, cell.y)
		self.maxCol = math.max(self.maxCol, cell.x)
	end,
	sample = function(self)
		return self.cells[math.random(1,self:size())]
	end,
	notify = function (self, modelTime )
        if (modelTime == nil) or (type(modelTime) ~= 'number') then 
            modelTime = 0;
        end
		self.cObj_:notify(modelTime);
	end,
    createNeighborhood = function(self, data)
        if data == nil then data = {} end
        if data.strategy == nil then data.strategy = "moore" end

        if data.target ~= nil then
            if type(data.target) ~= "CellularSpace" then
                error("Target is a "..type(data.target)..". It should be a CellularSpace", 2)
            elseif data.strategy == "coord" then
				coordCoupling(self, data.target, data.name)
            elseif data.strategy == "mxn" then
				spatialCoupling(data.m, data.n, self, data.target, data.filter, data.weight, data.name)
            else
                error("Invalid strategy for neighborhood between CellularSpaces: "..data.strategy, 2)
            end
        else
			switch1(data, "strategy") : caseof {
			    ["function"]   = function() createNeighborhood(self, data.filterF, data.weightF, data.name) end,
			    ["moore"]      = function() createMooreNeighborhood(self, data.name, data.self) end,
			    ["mxn"]        = function() createMxNNeighborhood(self, data.m, data.n, data.filter, data.weight, data.name) end,
			    ["vonneumann"] = function() createVonNeumannNeighborhood(self, data.name) end,
			    ["3x3"]        = function() create3x3Neighborhood(self, data.filter, data.weight, data.name) end
			}
		end
    end
}

metaTableCellularSpace_ = {__index = CellularSpace_}

function CellularSpace( attrTab )
	local cObj = TeCellularSpace()

	attrTab.cells = {}
	attrTab.cObj_= cObj
	if attrTab.minRow == nil then attrTab.minRow = 100000 end
	if attrTab.minCol == nil then attrTab.minCol = 100000 end
	if attrTab.maxRow == nil then attrTab.maxRow = -attrTab.minRow end
	if attrTab.maxCol == nil then attrTab.maxCol = -attrTab.minCol end

	local metaTable = {__index = CellularSpace_}

	if attrTab.xdim ~= nil then -- rectangular "virtual" cellular space
		attrTab.ydim = attrTab.ydim or attrTab.xdim
		-- Antonio
		-- Recuperação transferida para o método self.add
		-- attrTab.minRow = 1
		-- attrTab.minCol = 1
		-- attrTab.maxRow = attrTab.ydim
		-- attrTab.maxCol = attrTab.xdim
		attrTab.load = function(self)
			self.cells = {} -- Tiago: in the case CellularSpace is not empty
			self.cObj_:clear() -- Tiago: in the case CellularSpace is not empty
			for i = 1, self.xdim do
				for j = 1, self.ydim do
					-- Tiago (C++ CelularSpace, including TerraLib, starts from (0,0): 
					-- c = Cell{x = i, y = j}
					c = Cell{x = i-1, y = j-1}
					self:add(c)
				end
			end
		end
	else
		if attrTab.database ~= nil then cObj:setDBName(attrTab.database); else error("Database name not defined!", 2); end
		if attrTab.host == nil     then cObj:setHostName("localhost");    else cObj:setHostName(attrTab.host); end
		if attrTab.user == nil     then cObj:setUser("");                 else cObj:setUser(attrTab.user); end
		if attrTab.password == nil then cObj:setPassword("");             else cObj:setPassword(attrTab.password); end
		if attrTab.theme ~= nil    then cObj:setTheme(attrTab.theme);     else error("Theme name not defined!", 2) end
		if attrTab.layer ~= nil    then cObj:setLayer(attrTab.layer);     else cObj:setLayer(""); end

		if (attrTab.dbType == nil) then 
			local dbname = attrTab.database
			local extension = string.sub(dbname, #dbname-3, #dbname)

			if extension == ".mdb" then
				cObj:setDBType("ado")
			else
				cObj:setDBType("mysql")
			end
		else
			cObj:setDBType(string.lower(attrTab.dbType))
		end

		if (attrTab.select ~= nil) then
			if (type(attrTab.select) == "string") then attrTab.select = {attrTab.select} end -- in case of 'string', convert to a single position vector
			cObj:clearAttrName()
			for i in ipairs(attrTab.select) do
				cObj:addAttrName(attrTab.select[i])
			end
		end
		if(attrTab.where ~= nil) then cObj:setWhereClause(attrTab.where); end
	end
	setmetatable(attrTab, metaTable)
	cObj:setReference(attrTab)

	--if attrTab.xdim ~= nil then -- rectangular "virtual" cellular space
		attrTab:load()
	--end

	return attrTab
end


-- Traverses the cellular space "cs" applying the "f(cell)" function
-- to each cell
function forEachCell(cs, f)
	-- TODO or Trajectory or Agent
	if type(cs)~= "CellularSpace" and type(cs) ~= "Trajectory" then error("First parameter should be a CellularSpace or a Trajectory, got "..type(cs)..".", 2) end
	if type(f) ~= "function" then error("Second parameter should be a function, got "..type(f)..".", 2) end
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

-- Creates a neighborhood for each cell according to a modeler defined function
function createNeighborhood( cs, filterF, weightF, name )
	if( name == nil ) then name = "1"; end
	forEachCell(
		cs,
		function(cell, i)
			local neighborhood = Neighborhood();
			forEachCell(
				cs, 
				function(neighCell, i)
					if(filterF(cell, neighCell)) then
						neighborhood:addNeighbor(neighCell, weightF(cell, neighCell));
					end
				end
			);
			cell:addNeighborhood(neighborhood, name);
		end
	);
end

-- Creates a von Neumann neighborhood for each cell
function createVonNeumannNeighborhood(cs, name)
	local weight = 1/4
	if name == nil then name = "1"; end
	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood()
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do 
				-- add neighbor
				if lin == 0 or col == 0 then
					if lin ~= col then
						local index = Coord{x = (cell.x + col), y = (cell.y + lin)}
						neigh:addCell(index, cs, weight)
					end
				end

				col = col + 1
			end
			lin = lin + 1
		end
		cell:addNeighborhood(neigh, name)
	end
end

-- Creates a Moore neighborhood for each cell
function createMooreNeighborhood(cs, name, self)
	local weight = 1/8
	if self == nil then self = true; weight = 1/9 end
	if name == nil then name = "1"; end
	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood()
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do 
				-- add neighbor
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

-- Creates a 3x3 stationary (couclelis) neighborhood
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be 
--                              included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
function create3x3Neighborhood(cs,filterF, weightF, name)
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
function createMxNNeighborhood(cs, M, N,filterF, weightF, name)
	if name == nil then name = "1"; end
	if N < 0 then N = 1; end
	if M < 0 then M = 1; end
	local lin
	local col
	local i = 0
	forEachCell( cs, function(cell)
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
function spatialCoupling(M, N, cs1,cs2, filterF, weightF, name)
	if name == nil then name = "1"; end
	if N < 0 then N = 1; end
	if M < 0 then M = 1; end
	local lin
	local col
	local i = 0
	forEachCell( cs1, function(cell)
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