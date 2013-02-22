-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  Observers for TerraME
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
--      Antonio Jose da Cunha Rodrigues
--      Rodrigo Reis Pereira

-- Observer Types
TME_OBSERVERS = {
	TEXTSCREEN         = 1,
	LOGFILE            = 2,
	TABLE              = 3,
	CHART              = 45,
	GRAPHIC            = 4,
	DYNAMICGRAPHIC     = 5,
	MAP                = 6,
	UDPSENDER          = 7,
	SCHEDULER          = 8,
	IMAGE              = 9,
	STATEMACHINE       = 10, 
	NEIGHBORHOOD       = 11
}

TME_OBSERVERS_USER = {
	["textscreen"]   = TME_OBSERVERS.TEXTSCREEN,
	["logfile"]      = TME_OBSERVERS.LOGFILE,
	["table"]        = TME_OBSERVERS.TABLE,
	["chart"]        = TME_OBSERVERS.CHART,
	["map"]          = TME_OBSERVERS.MAP,
	["udpsender"]    = TME_OBSERVERS.UDPSENDER,
	["scheduler"]    = TME_OBSERVERS.SCHEDULER,
	["image"]        = TME_OBSERVERS.IMAGE,
	["statemachine"] = TME_OBSERVERS.STATEMACHINE,
	["neighborhood"] = TME_OBSERVERS.NEIGHBORHOOD
}

-- Subject Types
TME_TYPES = {
	CELL            = 1,
	CELLSPACE       = 2,
	NEIGHBORHOOD    = 3,
	TIMER           = 4,
	EVENT           = 5,
	AGENT           = 6,
	AUTOMATON       = 7,
	TRAJECTORY      = 8,
	ENVIRONMENT     = 9,
	SOCIETY         = 10 
	-- MESSAGE          -- it isn't a Subject
	-- STATE            -- it isn't a Subject
	-- JUMPCONDITION    -- it isn't a Subject
	-- FLOWCONDITION    -- it isn't a Subject
}

TME_TYPES_USER = {
	["Cell"]            = TME_TYPES.CELL,
	["CellularSpace"]   = TME_TYPES.CELLSPACE,
	["Neighborhood"]    = TME_TYPES.NEIGHBORHOOD,
	["Timer"]           = TME_TYPES.TIMER,
	["Event"]           = TME_TYPES.EVENT,
	["Agent"]           = TME_TYPES.AGENT,
	["Automaton"]       = TME_TYPES.AUTOMATON,
	["Trajectory"]      = TME_TYPES.TRAJECTORY,
	["Environment"]     = TME_TYPES.ENVIRONMENT,
	["Society"]         = TME_TYPES.SOCIETY
}

--#######################################################################################################################
-------------------------------------------------------------------------------------------
-- OBSERVERS CREATION
-- TME_OBSERVERS.TEXTSCREEN
function observerTextScreen(subjType, subject, observerAttrs, attrTable)
	local observerParams = {}

	if (subjType == TME_TYPES.AUTOMATON) then
		local locatedInCell = attrTable["location"]
		if type(locatedInCell) ~= "Cell" then
			error("Error: Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".", 3)
		else
			table.insert(observerParams, locatedInCell)
		end
	end

	if (subject.cObj_) then
		if (type(subject) == "CellularSpace") then
			return subject.cObj_:createObserver(TME_OBSERVERS.TEXTSCREEN, {}, observerAttrs, observerParams, subject.cells)
		else
			return subject.cObj_:createObserver(TME_OBSERVERS.TEXTSCREEN, observerAttrs, observerParams)
		end
	else
		return subject:createObserver(TME_OBSERVERS.TEXTSCREEN, observerAttrs, observerParams)
	end	
end

-- TME_OBSERVERS.LOGFILE
function observerLogFile(subjType, subject, observerAttrs, attrTable)
	local outfile = attrTable["outfile"] or "result_.csv"
	local separator = attrTable["separator"] or ";"

	local observerParams = {}
	if (subjType == TME_TYPES.AUTOMATON) then
		local locatedInCell = attrTable["location"]
		if type(locatedInCell) ~= "Cell" then
			error("Error: Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".", 3)
		else 
			table.insert(observerParams, locatedInCell)
		end
	end 

	table.insert(observerParams, outfile)
	table.insert(observerParams, separator)
    
	if (subject.cObj_) then
		if (type(subject) == "CellularSpace") then
			return subject.cObj_:createObserver(TME_OBSERVERS.LOGFILE, {}, observerAttrs, observerParams, subject.cells)
		else
			return subject.cObj_:createObserver(TME_OBSERVERS.LOGFILE, observerAttrs, observerParams)
		end
	else
		return subject:createObserver(TME_OBSERVERS.LOGFILE, observerAttrs, observerParams)
	end	
end

-- TME_OBSERVERS.TABLE
function observerTable(subjType, subject, observerAttrs, attrTable)
	local column1Label = attrTable["yLabel"] or "Attributes"
	local column2Label = attrTable["xLabel"] or "Values"

	local observerParams = {}
	if (subjType == TME_TYPES.AUTOMATON) then
		local locatedInCell = attrTable["location"]
		if type(locatedInCell) ~= "Cell" then
			error("Error: Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".", 3)
		else
			table.insert(observerParams, locatedInCell)
		end
	end
	table.insert(observerParams, column1Label)
	table.insert(observerParams, column2Label)

        -- print("table")
    -- print("observerAttrs")
    -- for k,v in pairs(observerAttrs) do
        -- print(k, v)
    -- end
    -- print("\nobserverParams")
    -- for k,v in pairs(observerParams) do
        -- print(k, v)
    -- end
    -- print("-----")
    
	if (subject.cObj_) then
		if (type(subject) == "CellularSpace") then
			return subject.cObj_:createObserver(TME_OBSERVERS.TABLE, {}, observerAttrs, observerParams, subject.cells)
		else
			return subject.cObj_:createObserver(TME_OBSERVERS.TABLE, observerAttrs, observerParams)
		end
	else
		return subject:createObserver(TME_OBSERVERS.TABLE, observerAttrs, observerParams)
	end	
end

-- TME_OBSERVERS.CHART
function observerChart(subjType, subject, observerAttrs, attrTable)  
    if(#observerAttrs < 1) then
        error("Error: Chart observers must have at least one attribute.", 3)
    end

	local chartTitle = attrTable["title"] or "$graphTitle"
	local yLabel = attrTable["yLabel"] or "$yLabel"
	local xLabel = ""
	local observerType = ""
	local curveLabels = ""
		
    local DEF_CURVE_NAME = "$curve "
    local DEF_CURVE_SEP = ";"
        
	if (attrTable["curveLabels"] == nil) then
		for i = 1, #observerAttrs do 
			curveLabels = curveLabels .. DEF_CURVE_NAME .. tostring(i) .. DEF_CURVE_SEP
		end
	else
        local curveLabelsCount = #attrTable["curveLabels"]
        local attrCount = #observerAttrs
        
        if (curveLabelsCount < attrCount) then
            curveLabels = table.concat( attrTable["curveLabels"], DEF_CURVE_SEP)                       
            for i = curveLabelsCount + 1, attrCount do 
                curveLabels = curveLabels .. DEF_CURVE_SEP .. DEF_CURVE_NAME .. tostring(i) .. DEF_CURVE_SEP
            end
        else
            curveLabels = table.concat( attrTable["curveLabels"], DEF_CURVE_SEP)
        end
	end
	
	if (not attrTable["xAxis"]) then
		-- dynamic graphic
		xLabel = attrTable["xLabel"] or "time"
		observerType = TME_OBSERVERS.DYNAMICGRAPHIC
	else
		-- graphic 
		observerType = TME_OBSERVERS.GRAPHIC
		xLabel = attrTable["xLabel"] or "$xLabel"
		table.insert(observerAttrs, attrTable["xAxis"])
	end

	local observerParams = {}
	if (subjType == TME_TYPES.AUTOMATON) then
		local locatedInCell = attrTable["location"]
		if type(locatedInCell) ~= "Cell" then
			error("Error: Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".", 3)
		else
			table.insert(observerParams, locatedInCell)
		end
	end
	table.insert(observerParams, chartTitle)
	table.insert(observerParams, xLabel)
	table.insert(observerParams, yLabel)
	table.insert(observerParams, curveLabels)
      
    if (attrTable.legends ~= nil) then
        for i=1, #attrTable.legends do
            table.insert(observerParams, attrTable.legends[i])
        end
	end
    
	if (subject.cObj_) then
		if (type(subject) == "CellularSpace") then
			return subject.cObj_:createObserver(observerType, {}, observerAttrs, observerParams, subject.cells)
		else
			return subject.cObj_:createObserver(observerType, observerAttrs, observerParams)
		end
	else
		return subject:createObserver(observerType, observerAttrs, observerParams)
	end	
end

--#####################################################################################################
-- DEFAULT MAP AND IMAGE OBSERVERS LEGENDS colobar functions
function getDefaultCellspaceNumberColorBars(i)
	local defaultCellspaceNumberColorBars = {
		{ {color = TME_LEGEND_COLOR.WHITE, value = 0}, {color = TME_LEGEND_COLOR.BLACK, value = 1} },--grouping = TME_GROUPING.EQUALSTEPS
		{ {color = TME_LEGEND_COLOR.YELLOW, value = 0}, {color = TME_LEGEND_COLOR.BLUE, value = 1} },
		{ {color = TME_LEGEND_COLOR.GREEN, value = 0}, {color = TME_LEGEND_COLOR.RED, value = 1} }
	}
	--if (i > 2) then return defaultCellspaceNumberColorBars[3]
	--else return defaultCellspaceNumberColorBars[i]
	return defaultCellspaceNumberColorBars[i % #defaultCellspaceNumberColorBars+1]
end

function getDefaultCellspaceTextColorBars(i)
	local defaultCellspaceTextColorBars = {
		{ {color = TME_LEGEND_COLOR.WHITE, value = "WHITE"}, {color = TME_LEGEND_COLOR.BLACK, value = "BLACK"} },--type = TME_DATA_TYPES.TEXT,grouping = TME_GROUPING.UNIQUEVALUE
		{ {color = TME_LEGEND_COLOR.YELLOW, value = "YELLOW"}, {color = TME_LEGEND_COLOR.BLUE, value = "BLUE"} },
		{ {color = TME_LEGEND_COLOR.GREEN, value = "GREEN"}, {color = TME_LEGEND_COLOR.RED, value = "GREEN"} }
	}
	--if (i > 2) then return defaultCellspaceTextColorBars[3]
	--else return defaultCellspaceTextColorBars[i]
	return defaultCellspaceTextColorBars[i % #defaultCellspaceTextColorBars+1]
end

function getDefaultCellspaceBooleanColorBars(i)
	local defaultCellspaceBooleanColorBars = {
		{ {color = TME_LEGEND_COLOR.WHITE, value = true}, {color = TME_LEGEND_COLOR.BLACK, value = false} },--grouping = TME_GROUPING.UNIQUEVALUE
		{ {color = TME_LEGEND_COLOR.YELLOW, value = true}, {color = TME_LEGEND_COLOR.BLUE, value = false} },
		{ {color = TME_LEGEND_COLOR.GREEN, value = true}, {color = TME_LEGEND_COLOR.RED, value = false} }
	}
	--if (i > 2) then return defaultCellspaceBooleanColorBars[3]
	--else return defaultCellspaceBooleanColorBars[i]
	return defaultCellspaceBooleanColorBars[i % #defaultCellspaceBooleanColorBars+1]
end

function getDefaultAgentColorBar(i)
	local defaultAgentColorBars = {  
		{ {color = TME_LEGEND_COLOR.GREEN, value = "state1"}, {color = TME_LEGEND_COLOR.RED, value = "state2"} }--type = TME_DATA_TYPES.TEXT
	}
	return defaultAgentColorBars[i % #defaultAgentColorBars+1]
end

function getDefaultAutomatonColorBar(i)
	local defaultAutomatonColorBars = {
		{ {color = TME_LEGEND_COLOR.GREEN, value = "state1"}, {color = TME_LEGEND_COLOR.RED, value = "state2"} }
	}
	return defaultAutomatonColorBars[i % #defaultAutomatonColorBars+1]
end

function getDefaultTrajectoryColorBar(trajectorySize, i)
	local defaultTrajectoryColorBars = {
		{ {color = TME_LEGEND_COLOR.GREEN, value = 0}, {color = TME_LEGEND_COLOR.RED, value = trajectorySize } }
	}
	return defaultTrajectoryColorBars[i % #defaultTrajectoryColorBars+1]
end

function getDefaultNeighborhoodColorBar(i)
	local defaultNeighborhoodColorBars = {  
		{ {color = TME_LEGEND_COLOR.GREEN, value = "GREEN"}, {color = TME_LEGEND_COLOR.RED, value = "RED"} }
	}
	return defaultNeighborhoodColorBars[i % #defaultNeighborhoodColorBars+1]
end

function getDefaultSocietyColorBar(i)
	local defaultSocietyColorBar = {  
		{ {color = TME_LEGEND_COLOR.GREEN, value = "GREEN"}, {color = TME_LEGEND_COLOR.RED, value = "RED"} }
	}
	return defaultSocietyColorBar[i % #defaultSocietyColorBar+1]
end

--#####################################################################################################
-- OBSERVER MAP
-- In this function the second parameter can assume two types of entities: a lua class ou a c++ one depending on the subject type
-- This is necessary for Society type.
-- Last parameter is used only for trajectories
function observerMap(subjType, subject, tbDimensions, observerAttrs, attrTable, csCells, trajectorySize)
	if (subjType == TME_TYPES.TRAJECTORY) then
		-- qq coisa informada na lista de atributos deve ser substituida por isto
		observerAttrs = {"trajectory"}		
	elseif (#observerAttrs > 2 or #observerAttrs == 0) then
		error("Error: Map observers must have exactly one or two attributes.", 3)
	end

	local observerParams = {}
	if (not attrTable.legends) then attrTable.legends = {} end

	if (#attrTable.legends == 0) then
		local caseof = {
		[TME_TYPES.CELLSPACE] = function()
			local cellspaceColorBar = ""
			local legs = {}
			for i=1,#observerAttrs do
				local t = type(csCells[1][observerAttrs[i]])
				local leg = {}
				if (t == "number") then
					leg = Legend { type = TME_LEGEND_TYPE.NUMBER, colorBar = getDefaultCellspaceNumberColorBars(i) }			
				elseif (t == "boolean") then
					leg = Legend { grouping = TME_LEGEND_GROUPING.UNIQUEVALUE,
						maximum = 1, minimum = 0, 
						type = TME_LEGEND_TYPE.BOOL,
						colorBar = getDefaultCellspaceBooleanColorBars(i) 
					}
				else
					leg = Legend { grouping = TME_LEGEND_GROUPING.UNIQUEVALUE,
						maximum = 1, minimum = 0,
						type = TME_LEGEND_TYPE.TEXT,
						colorBar = getDefaultCellspaceTextColorBars(i)
					}
				end
				table.insert(legs, leg)
			end
			attrTable.legends = legs
		end,
		[TME_TYPES.AGENT] = function()
			local agentColorBar = getDefaultAgentColorBar(1)
			attrTable.legends = { Legend { colorBar = agentColorBar } }
		end,
		[TME_TYPES.AUTOMATON] = function()
			local automatonColorBar = getDefaultAutomatonColorBar(1)
			attrTable.legends = { Legend { colorBar = automatonColorBar } }
		end,
		[TME_TYPES.TRAJECTORY] = function()
			-- qq coisa informada na lista de atributos deve ser substituída por isto
			observerAttrs = {"trajectory"}
			local trajectoryColorBar = getDefaultTrajectoryColorBar(trajectorySize,1)
			attrTable.legends = { Legend { colorBar = trajectoryColorBar, slices = trajectorySize } }
		end,
		[TME_TYPES.NEIGHBORHOOD] = function()
			local neighborhoodColorBar = getDefaultNeighborhoodColorBar(1)
			attrTable.legends = { Legend { colorBar = neighborhoodColorBar } }
		end,
		[TME_TYPES.SOCIETY] = function()
			local societyColorBar = getDefaultSocietyColorBar(1)
			attrTable.legends = { Legend { colorBar = defaultSocietyColorBar } }
		end
		}
		caseof[subjType]()
	end

	if (subjType == TME_TYPES.AUTOMATON or subjType == TME_TYPES.AGENT 
	or subjType==TME_TYPES.TRAJECTORY or subjType == TME_TYPES.SOCIETY) then

		local csObserver = attrTable["observer"]
		if (not csObserver) then error("Error: Parameter 'observer' not found.", 3) end
		local cs = csObserver.subject
		--if (not cs) then error("Error: 'cellspace' not found", 2) end

		table.insert(observerParams, cs)
		table.insert(observerParams, csObserver.id)
	end

	for i=1, #attrTable.legends do
		table.insert(observerParams, attrTable.legends[i])
	end

	if (#tbDimensions ~= 0) then
		-- cellularspace
		return subject.cObj_:createObserver(TME_OBSERVERS.MAP, tbDimensions, observerAttrs, observerParams, csCells)
	else
		-- society
		if (type(subject) == "Society") then
			local obsId = -1
			forEachAgent(subject, function(ag)
				if (ag.cObj_ == nil) then
					error("Error: It is simple agent and it can not be observable!", 3)
				end
				obsId = ag.cObj_:createObserver(TME_OBSERVERS.MAP, observerAttrs, observerParams)
			end)
			subject.observerId = obsId
			return obsId 
		else
			if (subject.cObj_) then
				return subject.cObj_:createObserver(TME_OBSERVERS.MAP, observerAttrs, observerParams)
			else
				return subject:createObserver(TME_OBSERVERS.MAP, observerAttrs, observerParams)
			end
		end
	end
end

-- OBSERVER NEIGHBORHOOD
function observerNeighborhood(subject, neighborhoods, attrTable)
	if (#neighborhoods > 2 or #neighborhoods == 0) then
		error("Error: Neighborhood Observers must have exactly one or two neighborhoods.", 3)
	end

	observerParams = {}
	legends = attrTable["legends"] or {}

	csObserver = attrTable["observer"]
	if (not csObserver) then error("Error: Parameter 'observer' was not found.", 3); end

	cs = attrTable["cellspace"] or nil
	if (not cs) then error("Error: Parameter 'cellspace' was not found.", 3); end

	table.insert(observerParams, cs)
	table.insert(observerParams, csObserver.id)

	for i = 1, #legends do
		table.insert(observerParams, legends[i])
	end

	obs = subject.cObj_:createObserver(TME_OBSERVERS.NEIGHBORHOOD, neighborhoods, observerParams)
	-- @RAIAN: Acrescentando o ID do observer
	subject.observerId = obs
	return obs
end

-- OBSERVER IMAGE
-- Last parameter is used only for trajectories
function observerImage(subjType, subject, tbDimensions, observerAttrs, attrTable, csCells, trajectorySize)
	if (subjType == TME_TYPES.TRAJECTORY) then
		-- qq coisa informada na lista de atributos deve ser substituida por isto
		observerAttrs = {"trajectory"}
	elseif (#observerAttrs > 2 or #observerAttrs == 0) then
		error("Error: Image observers must have exactly one or two attributes.", 3)
	end

	local observerParams = {}
	local legends = attrTable["legends"] or {} 

	if (subjType == TME_TYPES.CELLSPACE) then
		local path = attrTable["path"] or "."
		local prefix = attrTable["prefix"] or "result_"
		observerParams = { path, prefix }
	end

	if (not attrTable.legends) then attrTable.legends = { } end

	if (#attrTable.legends == 0) then
		local caseof = {
		[TME_TYPES.CELLSPACE] = function()
			local cellspaceColorBar = ""
			local legs = {}
			for i = 1, #observerAttrs do
				local t = type(csCells[1][observerAttrs[i]])
				local leg = {}
				if (t == "number") then
					leg = Legend { type = TME_LEGEND_TYPE.NUMBER, colorBar = getDefaultCellspaceNumberColorBars(i) }
				elseif (t == "boolean") then
					leg = Legend {  type = TME_LEGEND_TYPE.BOOL, colorBar = getDefaultCellspaceBooleanColorBars(i) }
				else
					leg = Legend { type = TME_LEGEND_TYPE.TEXT, colorBar = getDefaultCellspaceTextColorBars(i) }
				end
				table.insert(legs, leg)
			end
			attrTable.legends = legs
		end,
		[TME_TYPES.AGENT] = function()
			local agentColorBar = getDefaultAgentColorBar(1)
			attrTable.legends = { Legend { colorBar = agentColorBar } }
		end,
		[TME_TYPES.AUTOMATON] = function()
			local automatonColorBar = getDefaultAutomatonColorBar(1)
			attrTable.legends = { Legend { colorBar = automatonColorBar } }
		end,
		[TME_TYPES.TRAJECTORY] = function()
			-- qq coisa informada na lista de atributos deve ser substituída por isto
			observerAttrs = {"trajectory"}
			local trajectoryColorBar = getDefaultTrajectoryColorBar(trajectorySize,1)
			attrTable.legends = { Legend { colorBar = trajectoryColorBar, slices = trajectorySize } }
		end,
		[TME_TYPES.NEIGHBORHOOD] = function()
			local neighborhoodColorBar = getDefaultNeighborhoodColorBar(1)
			attrTable.legends = { Legend { colorBar = neighborhoodColorBar } }
		end,
		[TME_TYPES.SOCIETY] = function()
			local societyColorBar = getDefaultSocietyColorBar(1)
			attrTable.legends = { Legend { colorBar = defaultSocietyColorBar } }
		end
		}
		caseof[subjType]()
	end

	if (subjType == TME_TYPES.AUTOMATON or subjType == TME_TYPES.AGENT 
	or subjType==TME_TYPES.TRAJECTORY or subjType == TME_TYPES.SOCIETY) then

		local csObserver = attrTable["observer"] or nil
		if (not csObserver) then error("Error: Parameter 'observer' not found.", 3) end

		local cs = csObserver.subject
		if (not cs) then error("Error: Parameter 'cellspace' not found.", 3) end

		table.insert(observerParams, cs)
		table.insert(observerParams, csObserver.id)
	end

	for i = 1, #attrTable.legends do
		table.insert(observerParams, attrTable.legends[i])
	end

	if (#tbDimensions ~= 0) then
		-- cellularspace
		return subject.cObj_:createObserver(TME_OBSERVERS.IMAGE, tbDimensions, observerAttrs, observerParams, csCells)
	else
		-- society
		if (type(subject) == "Society") then
			local obsId = -1
			forEachAgent(subject, function(ag)
				if (ag.cObj_ == nil) then
					error("Error: It is simple agent and it can not be observable!", 3)
				end
				obsId = ag.cObj_:createObserver(TME_OBSERVERS.IMAGE, observerAttrs, observerParams)
			end)
			subject.observerId = obsId
			return obsId 
		else
			if (subject.cObj_) then
				return subject.cObj_:createObserver(TME_OBSERVERS.IMAGE, observerAttrs, observerParams)
			else
				return subject:createObserver(TME_OBSERVERS.IMAGE, observerAttrs, observerParams)
			end
		end
	end
end

-- OBSERVER UDPSENDER
function observerUDPSender(subjType, subject, tbDimensions, observerAttrs, attrTable,csCells)
	local observerParams = {}
	local port = attrTable["port"] or 456456
	local hosts = attrTable["hosts"] or {""}

	-- if visible parameter not exist so it is defined as true (default)
	if (attrTable["visible"] ~= nil) and (attrTable["visible"] == false) then
		observerParams["visible"] = attrTable["visible"]
	end

	-- if compress parameter not exist so it is defined as false (default)
	if (attrTable["compress"] ~= nil) and (attrTable["compress"] == true) then
		observerParams["compress"] = attrTable["compress"]
	end
	table.insert(observerParams, port)

	for i=1,#hosts,1 do
		table.insert(observerParams, hosts[i])
	end

	if (#tbDimensions ~= 0) then
		-- cellularspace
		local aux = observerParams
		observerParams = {aux}
		return subject.cObj_:createObserver(TME_OBSERVERS.UDPSENDER, tbDimensions, observerAttrs, observerParams, csCells)
	end

	if (subject.cObj_) then
		return subject.cObj_:createObserver(TME_OBSERVERS.UDPSENDER, observerAttrs, observerParams)
	else
		return subject:createObserver(TME_OBSERVERS.UDPSENDER, observerAttrs, observerParams)
	end
	--return subject:createObserver(TME_OBSERVERS.UDPSENDER, observerAttrs, observerParams)
end

-- OBSERVER SCHEDULER
function observerScheduler(subjType, subject, observerAttrs, attrTable)
	local observerAttrs = {}
	local observerParams = {"", ""}

	if (subject.cObj_) then
		return subject.cObj_:createObserver(TME_OBSERVERS.SCHEDULER, observerAttrs, observerParams)
	else
		return subject:createObserver(TME_OBSERVERS.SCHEDULER, observerAttrs, observerParams)
	end
	--return subject:createObserver(TME_OBSERVERS.SCHEDULER, observerAttrs, observerParams)
end

-- OBSERVER STATEMACHINE
function observerStateMachine(subjType, subject, observerAttrs, attrTable)
	local observerAttrs = {"currentState"}
	local legends = attrTable["legends"] or {}

	if (#legends > 1) then
		error("Error: State machine observers can have only one legend.", 3)
	end

	local observerParams = {}
	if (subjType == TME_TYPES.AUTOMATON) then
		local locatedInCell = attrTable["location"]
		if type(locatedInCell) ~= "Cell" then
			error("Error: Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".", 3)
		else 
			table.insert(observerParams,locatedInCell)
		end
	end
	table.insert(observerParams, legends[1])

	if (subject.cObj_) then
		return subject.cObj_:createObserver(TME_OBSERVERS.STATEMACHINE, observerAttrs, observerParams)
	else
		return subject:createObserver(TME_OBSERVERS.STATEMACHINE, observerAttrs, observerParams)
	end
	--return subject.cObj_:createObserver(TME_OBSERVERS.STATEMACHINE, observerAttrs, observerParams)
end

--##########################################################################
-- Constructor for Observers
Observer_ = {
    type_ = "Observer",
    kill = function(self, func)
        if (self.subject.cObj_) then 
        	if(self.type == TME_OBSERVERS.NEIGHBORHOOD or self.type == "neighborhood")then
        		return self.subject.cObj_:kill(self.id, self.cellspace.cObj_)
        	else
            	return self.subject.cObj_:kill(self.id)
            end
        else
            if (type(self.subject) == "Society") then
                return self.subject:remove(func)
            else
                print("Warning: cObj is nil.")
                return false
            end
        end
    end,
    killAll = function(self)
        if (type(self.subject) == "Society") then
            return self.subject:remove(function(ag) return true end)
        else
            error("Error: This function is not applicable to this type.", 3)
            return false
        end
    end
}

function Observer(attrTab)
	if type(attrTab) ~= "table" then
		error("Error: Observer requires a table as argument.", 3)
	end

	local metaTable = {__index = Observer_}
	setmetatable(attrTab, metaTable)

	local subject = ""
	local cppSubject = nil
	local subjectType = ""

	subject = attrTab["subject"]    
	if (subject == nil) then
		error("Error: Parameter 'subject' is compulsory.", 3)
	else
		-- Checks the Lua subject type
		if (type(subject) == "table") and (subject.cObj_ ~= nil) then
			if (type(subject.cObj_) == "table") then
				cppSubject = subject.cObj_[1]
			else
				cppSubject = subject.cObj_
			end
		else
			-- Este teste causa bug no ObsSociety
			-- if (type(subject) == "userdata") then
			cppSubject = subject
			--end
		end

		if (type(subjectType) == "string") then subjectType = TME_TYPES_USER[type(subject)] end
	end
  
	neighborhoods = attrTab["neighIndex"] or {}

	-- retrieve observer basic items
	observerId = -1
	local observerType = attrTab["type"] or nil
	if (type(observerType) == "string") then observerType = TME_OBSERVERS_USER[observerType] end

	observerAttrs = attrTab["attributes"] or {}

	-- sets (if not defined) default observer according to subject type
	if (observerType == nil) then
		local caseof = {
			[TME_TYPES.CELL] = TME_OBSERVERS.TABLE,
			[TME_TYPES.CELLSPACE] = TME_OBSERVERS.MAP,
			[TME_TYPES.TIMER] = TME_OBSERVERS.SCHEDULER,
			[TME_TYPES.EVENT] = TME_OBSERVERS.TABLE,
			[TME_TYPES.AGENT] = TME_OBSERVERS.MAP,
			[TME_TYPES.AUTOMATON] = TME_OBSERVERS.MAP,
			[TME_TYPES.TRAJECTORY] = TME_OBSERVERS.MAP,
			[TME_TYPES.SOCIETY] = TME_OBSERVERS.MAP
		}
		observerType = caseof[subjectType]
	end

	-- each type of observer retrieves specific attributes
	-- attrTab is passed here to retrieve them fastly
	local caseof = {
		[TME_OBSERVERS.TEXTSCREEN] = function()
			return observerTextScreen(subjectType, cppSubject, observerAttrs, attrTab)
		end,
		[TME_OBSERVERS.LOGFILE] = function()
			return observerLogFile(subjectType, cppSubject, observerAttrs, attrTab)
		end,
		[TME_OBSERVERS.TABLE] = function()
			return observerTable(subjectType, cppSubject, observerAttrs, attrTab)
		end,
		[TME_OBSERVERS.CHART] = function()
			return observerChart(subjectType, cppSubject, observerAttrs, attrTab)
		end,
		[TME_OBSERVERS.MAP] = function()
			local tbDimensions = {}
			local cells = {}
			if (subjectType == TME_TYPES.CELLSPACE) then
				tbDimensions = { tonumber(subject.maxCol - subject.minCol + 1),
				tonumber(subject.maxRow - subject.minRow + 1) }
				cells = subject.cells
			end

			if (subjectType == TME_TYPES.TRAJECTORY) then
				return observerMap(subjectType, cppSubject, tbDimensions, observerAttrs, attrTab, cells, subject:size())
			else
				return observerMap(subjectType, cppSubject, tbDimensions, observerAttrs, attrTab, cells)
			end
		end,
		[TME_OBSERVERS.UDPSENDER] = function()
			local tbDimensions = {}
			local cells = {}
			if (subjectType == TME_TYPES.CELLSPACE) then
				tbDimensions = { tonumber(subject.maxCol - subject.minCol + 1),
				tonumber(subject.maxRow - subject.minRow + 1) }
				cells = subject.cells
			end
			return observerUDPSender(subjectType, cppSubject, tbDimensions, observerAttrs, attrTab, cells)
		end,
		[TME_OBSERVERS.SCHEDULER] = function() 
			return observerScheduler(subjectType, cppSubject, observerAttrs, attrTab)
		end,
		[TME_OBSERVERS.IMAGE] = function()
			local tbDimensions = {}
			local cells = {}
			if (subjectType == TME_TYPES.CELLSPACE) then
				tbDimensions = { tonumber(subject.maxCol - subject.minCol + 1),
				tonumber(subject.maxRow - subject.minRow + 1) }
				cells = subject.cells
			end

			if (subjectType == TME_TYPES.TRAJECTORY) then
				return observerImage(subjectType, cppSubject, tbDimensions, observerAttrs, attrTab, cells, subject:size())
			else
				return observerImage(subjectType, cppSubject, tbDimensions, observerAttrs, attrTab, cells)
			end
		end,
		[TME_OBSERVERS.STATEMACHINE] = function() 
			return observerStateMachine(subjectType, cppSubject, observerAttrs, attrTab)
		end,
		[TME_OBSERVERS.NEIGHBORHOOD] = function() 
			return observerNeighborhood(cppSubject, neighborhoods, attrTab)
		end
	}

	observerId = caseof[observerType]()
	attrTab.id = observerId 
	return attrTab

end

