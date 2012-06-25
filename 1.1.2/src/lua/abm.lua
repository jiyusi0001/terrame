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
--      Antonio Jose da Cunha Rodrigues
--      Rodrigo Reis Pereira

DEFAULT_MESSAGE_DELAY = 0

Messages_ = {}

function forEachAgent(obj, func)
    local ags = obj:getAgents()
    if ags == nil then error("Could not get agents from obj", 2) end
    for i = 1, #ags do
            if func(ags[i]) == false then return false end
    end
end

function forEachRelative(agent, func)
    for i = 1, #agent.relatives_ do
        if func(agent, agent.relatives_[i], agent.weights_[i]) == false then return false end
    end
end

Society_ = {
	type_ = "Society",
    execute   = function(self) forEachAgent(self, function(single) single:execute() end) end,
    size      = function(self) return #self.agents_ end,
    getAgents = function(self) return self.agents_ end,
    getAgent  = function(self, idx) return self.agents_[idx] end,
    sample    = function(self)
        if (#self.agents_ > 0) then
            return self.agents_[math.random(1, #self.agents_)]
        else 
            return nil
        end
    end,
    clean     = function(self) 
        self.agents_ = {}
        self.autoincrement = 1
    end,
    add = function(self, agent)
        table.insert(self.agents_, agent)
        if agent.id == nil then 
		    agent.id = self.autoincrement
        end
        self.autoincrement = self.autoincrement + 1
    end,
    -- Antonio
    -- dez/2011
    -- Verificar necessidade desse método
    remove =  function(self, agent)       
        local id = -1
        local found = false
              
        -- remove agent from agents_'s table
        for k, v in pairs(self.agents_) do
            if (v.id == agent.id) and (v == agent) then
                id = k
                found = true
                break
            end
        end
        if (found) then                 
            table.remove(self.agents_, id)
  			--local ret = agent:kill(self.observerId)            
            if(self.observerId ~= -1) then
            	local ret = agent.cObj_:kill(self.observerId)
            end           
        end
    end,
    notify = function (self, modelTime )
        if (modelTime == nil) or (type(modelTime) ~= 'number') then 
            modelTime = 0; 
        end
        forEachAgent(self, function(agent)
            agent:notify(modelTime)
        end)
    end
}

function Society(agent_, nagents_)
    soc_ = {agents_ = {}, autoincrement = 1, observerId = -1}

    local metaTable = {__index = Society_}
    setmetatable(soc_, metaTable)

    if nagents_ == nil then return soc_ end

    local ag
    if type(nagents_) == "table" then
        for i = 1, table.getn(nagents_) do
            ag = agent_(nagents_[i])
            if ag == nil then error("Agent was not created succesfully", 2) end
            soc_.agents_[i] = ag
            soc_.agents_[i].id = i
            soc_.autoincrement = soc_.autoincrement + 1
        end
    else -- integer value
        for i = 1, nagents_ do
            ag = agent_()
            if ag == nil then error("Agent was not created succesfully", 2) end
            soc_.agents_[i] = ag
            soc_.agents_[i].id = i
            soc_.autoincrement = soc_.autoincrement + 1
        end
    end

    return soc_
end

Group_ = {
    rebuild = function(self)
        self:clean()
        self:filter()
        if self.greaterThan ~=  nil then self:sort() end
    end,
    filter = function(self, func)
        if func == nil then func = self.pertinence end
        if func == nil then error("Filter function not defined.", 2) end

        self:clean()
        
        -- Verificar código
        local socTemp = Society()
        local temp = {}
        socTemp.observers_ = self.society.observers_
        forEachAgent(self.society, function(agent)
            if self.pertinence(agent) then 
                self:add(agent) 
            else
                socTemp:add(agent)
                table.insert(temp, agent)
            end
        end)
        for i = 1, #temp do
            socTemp:remove(temp[i]) 
        end
        
        self.pertinence = func
    end,
    sort = function(self, func)
        if func == nil then func = self.greaterThan end
        if func == nil then error("Sort function not defined.", 2) end

        table.sort(self.agents_, func)
        self.greaterThan = func
    end,
    randomize = function(self)
        local numagents = self:size()
        for i = 1, numagents do
            local pos1 = math.random(1, numagents)
            local pos2 = math.random(1, numagents)
            local ag1 =  self:getAgent(pos1)
            self.agents_[pos1] = self:getAgent(pos2)
            self.agents_[pos2] = ag1
        end
    end,
}

local metaTable = {__index = Society_}
setmetatable(Group_, metaTable)

Group = function(society, pertinence, greaterThan)
    g = {
        agents_ = {}, society = society, pertinence = pertinence, 
        greaterThan = greaterThan, autoincrement = 1, observers_ = society.observers_
    }
    local metaTable = {__index = Group_}
    setmetatable(g, metaTable)
    
    g:rebuild()
    return g
end

function synchronizeMessages()
    k = 1
    for i = 1, table.getn(Messages_) do
        kmessage = Messages_[k]
        kmessage.delay = kmessage.delay - 1

        if kmessage.delay == 0 then
            kmessage.receiver:onMessage(kmessage)
            table.remove(Messages_, k)
        else
            k = k + 1
        end
    end
end
