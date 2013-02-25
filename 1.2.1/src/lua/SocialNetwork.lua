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
--      Rodrigo Reis Pereira

SocialNetwork_ = {
	type_ = "SocialNetwork",
	add = function(self, connection, weight)
		-- if the modeller does not use weight, then the potisition in the table will be nil
		id = connection:getID()

		if self.connections[id] ~= nil then return false end
		self.connections[id] = connection
		self.weights[id] = weight
		self.count = self.count + 1
	end,
	clear = function(self)
		self.count = 0
		self.connections = {}
		self.weights = {}
	end,
	getWeight = function(self, connection)
		return self.weights[connection:getID()]
	end,
	getConnection = function(self, id)
		return self.connections[id]
	end,
	isConnection = function(self, connection)
		return self.connections[connection:getID()] ~=nil
	end,
	isEmpty = function(self)
		return self.count == 0
	end,
	remove = function(self, connection)
		if type(connection) ~= "Agent" then
			error("Error: First argument should be an Agent, got "..type(connection)..".", 2)
		end
		id = connection:getID()
		if self.connections[id] == nil then return end
		self.connections[id] = nil
		self.weights[id] = nil
		self.count = self.count - 1
	end,
	sample = function(self, randomObj)
    local pos = nil
    if(randomObj and type(randomObj) == "Random") then
      pos = randomObj:integer(self.count)                          
    else
      pos = TME_GLOBAL_RANDOM:integer(self.count)            
    end

		count = 1
		for i, j in ipairs(self.connections) do
			if count <= pos then return j end
			count = count + 1
		end
	end,
	setWeight = function(self, connection, weight)
		self.weights[connection:getID()] = weight
	end,
	size = function(self)
		return self.count
	end
}

metaTableSocialNetwork_ = {__index = SocialNetwork_}

function SocialNetwork()
	attrTab = {}
	setmetatable(attrTab, metaTableSocialNetwork_)
	attrTab:clear()
	return attrTab
end

