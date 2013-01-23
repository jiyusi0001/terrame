-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira


Trajectory_ = {
	type_ = "Trajectory",
	clone = function(self)
		t = Trajectory {
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}
		forEachCell(self, function(cell)
			t:add(cell)
		end)
		return g
	end,
	filter = function(self, f)
		if f ~= nil then
			self.select = f
		elseif self.select == nil then
			return false
		else
			f = self.select
		end
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
		for i, cell in ipairs(self.cells) do
			if cell.x == x and cell.y == y then
				return cell
			end
		end
		return nil
	end,
	notify = function (self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then
			modelTime = 0
		end
		self.cObj_:notify(modelTime)
	end,
	randomize = function(self)
		local numcells = self:size()
		for i = 1, numcells do
			local pos1 = random(1, numcells)
			local pos2 = random(1, numcells)
			local cell1 = self.cells[pos1]
			self.cells[pos1] = self.cells[pos2]
			self.cells[pos2] = cell1
		end
	end,
	rebuild = function(self)
		if self.select  ~= nil then self:filter() end
		if self.greater ~= nil then	self:sort()   end
	end,
	sort = function(self, greaterThan)
		if greaterThan ~= nil then
			self.greater = greaterThan
		elseif self.greater == nil then
			return false
		else
			greaterThan = self.greater
		end
		table.sort(self.cells, greaterThan) 
		self.cObj_:clear()
		for i, cell in ipairs(self.cells) do
			self.cObj_:add(i, cell.cObj_)
		end
	end
}

setmetatable(Trajectory_, metaTableCellularSpace_)
local metaTableTrajectory_ = {__index = Trajectory_}

function Trajectory(attrTab)
	if attrTab == nil then
		error("Error: Attribute table is nil.", 2)
	end

	if attrTab.build == nil then
		attrTab.build = true
	end
	
	if type(attrTab.target) ~= "CellularSpace" and attrTab.build ~= false then
		error("Error: `target' must be a CellularSpace, and not "..type(attrTab.target)..".", 2)
	end

	attrTab.parent = attrTab.target
	attrTab.target = nil

	if attrTab.select == nil then
		attrTab.select = function() return true end
	elseif type(attrTab.select) ~= "function" then
		error("Error: `select' must be a function `bool = function(cell)', and not "..type(attrTab.select)..".", 2)
	end

	if attrTab.greater ~= nil and type(attrTab.greater) ~= "function" then
	error("Error: `greater' must be a function `bool = function(cell, cell)', and not "..type(attrTab.greater)..".", 2)
	end

	local cObj = TeTrajectory()
	attrTab.cObj_ = cObj
	attrTab.cells = {}

	setmetatable(attrTab, metaTableTrajectory_)

	if attrTab.build then
		attrTab:rebuild()
		attrTab.build = nil
	end

	cObj:setReference(attrTab)

	return attrTab
end

greaterByAttribute = function(attribute, operator)
	if operator == nil then operator = "<" end

	str = "return function(o1, o2) return o1."..attribute.." "..operator.." o2."..attribute.." end"
	return loadstring(str)()
end

greaterByCoord = function(operator)
	if operator == nil then operator = "<" end

	str = "return function(a,b)\n"
	str = str.."if a.x"..operator.."b.x then return true end\n"
	str = str.."if a.x == b.x and a.y"..operator.."b.y then return true end\n"
	str = str.."return false end"
	local load = load
    if (_VERSION ~= "Lua 5.2") then
		load = loadstring
    end		
	return load(str)()
end

