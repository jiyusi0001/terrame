Trajectory_ = {
    type_ = "Trajectory",
	size = function( self ) return table.getn(self.cells); end,
	filter = function( self, f )
		if( f ~= nil ) then self.lastSelect = f; else return end
		self.cells = {}
		self.cObj_:clear()
		for i, cell in ipairs(self.parent.cells) do
			if f(cell) then 
				table.insert(self.cells, cell)
				self.cObj_:add(i, cell.cObj_)
			end
		end
	end,
	getCell = function(self, index)
		local x, y = index:get().x, index:get().y
		for i, cell in ipairs( self.cells ) do
			if cell.x == x and cell.y == y then
				return cell
			end
		end
		return nil
	end,
	sort = function( self, greaterThan )
		if( greaterThan ~= nil ) then self.lastGreater = greaterThan; else return end
		table.sort( self.cells, greaterThan ) 
		self.cObj_:clear();
		for i, cell in ipairs( self.cells )do
			self.cObj_:add( i, cell.cObj_ )
		end
	end,
	randomize = function(self)
		local numcells = self:size()
		for i = 1, numcells do
			local pos1 = math.random(1, numcells)
			local pos2 = math.random(1, numcells)
			local cell1 = self.cells[pos1]
			self.cells[pos1] = self.cells[pos2]
			self.cells[pos2] = cell1
		end
	end,
	rebuild = function(self)
		if self.lastSelect ~= nil then 
			self:filter(self.lastSelect)
		end
		if self.lastGreater ~= nil then
			self:sort(self.lastGreater)
		end
	end,
	notify = function (self, modelTime )
        if (modelTime == nil) or (type(modelTime) ~= 'number') then 
            modelTime = 0;
        end
		self.cObj_:notify(modelTime);
	end
}

setmetatable(Trajectory_, metaTableCellularSpace_)
metaTableTrajectory_ = {__index = Trajectory_}

function Trajectory(attrTab)
    if attrTab == nil then
        error("Attribute table is nil.", 2)
    end

    if attrTab.build == nil then
        attrTab.build = true
    end
	
	--TODO
    --if type(attrTab.target) ~= "CellularSpace" and type(attrTab.target) ~= "Trajectory" and attrTab.build ~= false then
    if type(attrTab.target) ~= "CellularSpace" and attrTab.build ~= false then
    	
        error("`target' must be a CellularSpace, and not "..type(attrTab.target)..".", 2)
    end

    attrTab.parent = attrTab.target
    attrTab.target = nil

    if attrTab.select == nil then
        --attrTab.lastSelect = function() return true end
        attrTab.select = function() return true end
    elseif type(attrTab.select) ~= "function" then
        error("`select' must be a function `bool = function(cell)', and not "..type(attrTab.select)..".", 2)
        --attrTab.lastSelect = attrTab.select
        attrTab.select = nil
    end

    if attrTab.greater ~= nil and type(attrTab.greater) ~= "function" then
        error("`greater' must be a function `bool = function(cell, cell)', and not "..type(attrTab.greater)..".", 2)
        --attrTab.lastGreater = attrTab.greater
        attrTab.greater = nil
    end

    local cObj = TeTrajectory()
    attrTab.cObj_ = cObj
    attrTab.cells = {}

    setmetatable(attrTab, metaTableTrajectory_)

    if attrTab.build then
		attrTab:filter(attrTab.select)
				
        --if attrTab.lastGreater then attrTab:sort() end
        if attrTab.greater then attrTab:sort(attrTab.greater) end
    end

    attrTab.build = nil
    cObj:setReference(attrTab)

    return attrTab
end

--## ADICIONADO PEDRO
greaterByAttribute = function(attribute, operator)
    if operator == nil then operator = "<" end

    str = "return function(o1, o2) return o1."..attribute.." "..operator.." o2."..attribute.." end"
    return loadstring(str)()
end

--## ADICIONADO PEDRO
greaterByCoord = function(operator)
    if operator == nil then operator = "<" end

    str = "return function(a,b)\n"
    str = str.."if a.x"..operator.."b.x then return true end\n"
    str = str.."if a.x == b.x and a.y"..operator.."b.y then return true end\n"
    str = str.."return false end"
    return loadstring(str)()
end
