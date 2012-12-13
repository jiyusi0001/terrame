-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  ABM extension for TerraME
--  Last change: April/2012 
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
--      Pedro Andrade

Group_ = {
	type_ = "Group",
	add = function(self, agent)
		if type(agent) ~= "Agent" then
			error("Error: First parameter should be Agent, got "..type(agent)..".", 2)
		end

		table.insert(self.agents, agent)
	end,
	clone = function(self)
		g = Group{
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}
		forEachAgent(self, function(agent)
			g:add(agent)
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

		self:clear()

		forEachAgent(self.parent, function(agent)
			if f(agent) then self:add(agent) end
		end)
	end,
	randomize = function(self)
		local numagents = self:size()
		for i = 1, numagents do
			local pos1 = math.random(1, numagents)
			local pos2 = math.random(1, numagents)
			local ag1 =  self:getAgent(pos1)
			self.agents[pos1] = self:getAgent(pos2)
			self.agents[pos2] = ag1
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

		table.sort(self.agents, greaterThan)
	end
}

setmetatable(Group_, metaTableSociety_)
local metaTableGroup_ = {__index = Group_} 

Group = function(attrTab)
	if attrTab == nil then error("Attribute table is nil.", 2) end
	if attrTab.build == nil then attrTab.build = true end

	if type(attrTab.target) ~= "Society" and attrTab.build ~= false then
		error("Parameter 'target' must be a Society, and not "..type(attrTab.target)..".", 2)
	end

	if attrTab.select == nil then
		attrTab.select = function() return true end
	elseif type(attrTab.select) ~= "function" then
		error("Parameter 'select' must be a function 'bool = function(cell)', and not "..type(attrTab.select)..".", 2)
	end

	if attrTab.greater ~= nil and type(attrTab.greater) ~= "function" then
		error("Parameter 'sort' must be a function 'bool = function(cell, cell)', and not "..type(attrTab.sort)..".", 2)
	end

	setmetatable(attrTab, metaTableGroup_)
	attrTab.parent = attrTab.target
	attrTab.target = nil
	attrTab.agents = {}
	attrTab.placements = {}

	if attrTab.build then
		attrTab:rebuild()
		attrTab.build = nil
	end

	return attrTab
end

