-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2010 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library.
--
--The authors reassure the license terms regarding the warranties.
--They specifically disclaim any warranties, including, but not limited to,
--the implied warranties of merchantability and fitness for a particular purpose.
--The framework provided hereunder is on an "as is" basis, and the authors have no
--obligation to provide maintenance, support, updates, enhancements, or modifications.
--In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
--indirect, special, incidental, or consequential damages arising out of the use
--of this library and its documentation.
--
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--      Antonio Jose da Cunha Rodrigues
--      Raian Vargas Maretto

if( os.setlocale(nil, "all") ~= "C" ) then os.setlocale("C", "numeric") end

local TME_VERSION = "1_2_2"
TME_PATH = os.getenv("TME_PATH_" .. TME_VERSION)
local TME_LUA_PATH = TME_PATH .. "//bin//Lua"

TME_DB_VERSION="4_2_0"
TME_DIR_SEPARATOR = package.config:sub(1,1);

if (TME_PATH == nil or TME_PATH == "") then
	error("Error: TME_PATH_" .. TME_VERSION .." environment variable should exist and point to TerraME installation folder.", 2)
end

-- To keep compatibilities with old versions of Lua
local load = load
if (_VERSION ~= "Lua 5.2") then
    load = loadstring
end	


-- includes util functions and classes in TerraME scope
dofile(TME_LUA_PATH .. "//TerraMEUtils.lua")

type__ = type

type = function(data)
	local t = type__(data)
	if t == "table" then
		if data.type_ ~= nil then
			return data.type_
		else
			return "table"
		end
	else
		return t
	end
end

dofile(TME_LUA_PATH .. "//Legend.lua")
dofile(TME_LUA_PATH .. "//Observer.lua")
dofile(TME_LUA_PATH .. "//SocialNetwork.lua")
dofile(TME_LUA_PATH .. "//Society.lua")
dofile(TME_LUA_PATH .. "//Group.lua")

-- KERNEL'S COMPONENTS 

--Space ----------------------------------------------------------------------------------
dofile(TME_LUA_PATH .. "//Coord.lua")
dofile(TME_LUA_PATH .. "//Cell.lua")
dofile(TME_LUA_PATH .. "//CellularSpace.lua")
dofile(TME_LUA_PATH .. "//Neighborhood.lua")

--Time -----------------------------------------------------------------------------------
-- The constructor Event, differently of the others, does not return a table.
-- Instead, it returns a C++ object TeEvent. This makes sense since there is 
-- no meaning on the modeller's command: ev.time = 1. This because any attribute of
-- an Event is controled by the C++ simulation engine, including the attribute ev.time.
dofile(TME_LUA_PATH .. "//Pair.lua")
dofile(TME_LUA_PATH .. "//Event.lua")
dofile(TME_LUA_PATH .. "//Action.lua")
dofile(TME_LUA_PATH .. "//Timer.lua")

--Behavior -------------------------------------------------------------------------------
dofile(TME_LUA_PATH .. "//Jump.lua")
dofile(TME_LUA_PATH .. "//Flow.lua")
dofile(TME_LUA_PATH .. "//State.lua")
dofile(TME_LUA_PATH .. "//Automaton.lua")
dofile(TME_LUA_PATH .. "//Agent.lua")
dofile(TME_LUA_PATH .. "//Trajectory.lua")

--Evironment -----------------------------------------------------------------------------
dofile(TME_LUA_PATH .. "//Environment.lua")

--Utilities functions---------------------------------------------------
function index2coord(idx, xMax)
	local term = math.floor((idx-1)/(xMax+1))
	local y =(idx-1) - xMax*term
	local x = term
	return x, y
end

function coord2index(x, y, xMax)
	return (y + 1) + x * xMax 
end

forEachElement = function(obj, func)
	for k, ud in pairs(obj) do
		local t = type(ud)
		func(k, ud, t)
	end
end

-- Format time of CPU utilization in (days:hours:minutes:seconds)
function elapsedTime(s)
	local floor = math.floor
	local seconds = s
	local minutes = floor(s / 60);     seconds = floor(seconds % 60)
	local hours = floor(minutes / 60); minutes = floor(minutes % 60)
	local days = floor(hours / 24);    hours = floor(hours % 24)

	if days > 0 then
		return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
	else
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	end
end

-- extents to the string class
function string.endswith(self, send)
	return #self >= #send and self:find(send, #self-#send+1, true) and true or false
end

-- extents to table class
function contains(t,value)
	if(t == nil) then return false end
	for _,v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false  
end

-- substitute for table.getn
function getn(t)
	local n = 0
	for k, v in pairs(t) do
		n = n +1
	end
	return n
end
