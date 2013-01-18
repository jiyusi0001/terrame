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

local TME_VERSION = "1_2_1"
TME_PATH = os.getenv("TME_PATH_" .. TME_VERSION)
local TME_LUA_PATH = TME_PATH .. "//bin//Lua"

TME_DB_VERSION="4_2_0"
TME_DIR_SEPARATOR = package.config:sub(1,1);

if (TME_PATH == nil or TME_PATH == "") then
	error("Error: TME_PATH_" .. TME_VERSION .." environment variable should exist and point to TerraME installation folder.", 2)
end

-- includes lrandom library in TerraME scope
package.cpath = package.cpath .. ";" .. TME_PATH.."/bin/?.so;" .. TME_PATH.."/bin/?.dll"
random = require "random"

DEFAULT_RANDOM_SEED = 12345

local r = random.new(DEFAULT_RANDOM_SEED)

function randomSeed(seed)
  r = random.new(seed)
end

function rand(v)
  if(v) then return r() % v end
  return r()
end

-- substitute for table.getn(t)
function getn(t)
  local n = 0
  for k, v in pairs(t) do
    n = n +1
  end
  return n
end

function levenshtein(s, t)
	local d, sn, tn = {}, #s, #t
	local byte, min = string.byte, math.min
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = byte(s, i)
		for j = 1, tn do
			d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
		end
	end
	return d[#d]
end

function switch(attrTab, att)
	if (type(attrTab) == "number") then
		local swtbl = {
			casevar = attrTab,
			caseof = function(self, code)
				local f
				if (self.casevar) then
					f = code[self.casevar] or code.default
				else
					f = code.missing or code.default
				end

				if f then
					if type(f) == "function" then
						return f(self.casevar,self)
					else
						error("Error: case "..tostring(self.casevar).." not a function")
					end
				end
			end
		}
		return swtbl
	else
		local swtbl = {
			casevar = attrTab[att],
			caseof = function(self, code)
				local f
				if self.casevar then
					f = code[self.casevar] or code.default
				else
					f = code.missing or code.default
				end
				if f then
					if type(f) == "function" then
						return f(self.casevar,self)
					else
						error("Error: case "..tostring(self.casevar).." should be a function.")
					end
				else
					local distance = string.len(self.casevar)
					local word
					forEachElement(code, function(a)
						local d = levenshtein(a, self.casevar) 
						if d < distance then
							distance = d
							word = a
						end
					end)
					if distance < string.len(self.casevar) * 0.6 then
						word = "'. Do you mean '"..word.."'?"
					else
						word = "'. It must be one of "
						forEachElement(code, function(a)
							word = word.."'"..a.."', "
						end)
						word = string.sub(word, 0, string.len(word) - 2).."."
					end
					error("Error: Invalid value for parameter "..att..": '"..self.casevar..word, 3)
				end
			end
		}
		return swtbl
	end
end

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

-- Implements the Euler (Euler-Cauchy) Method for integrate ordinary differential equations
-- Parameters: 
--  df, is the differential equantion,
--  initCond, is the initial condition which must be satisfied
--  [a,b[, is a close defined interval,
--  delta, is the step of the independent variable
function integrationEuler(df, initCond, a, b, delta)
	if type(df) == "function" then
		local y = initCond
		local x = a
		local bb = b - delta
		for x = a, bb, delta do
			y = y + delta * df(x, y)
		end
		return y
	else
		local i = 0
		local y = initCond
		local x = a
		local bb = b - delta
		local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
		for x = a, bb, delta do
			for i = 1, #df do
				values[i] =  df[i](x, y)
			end
			for i = 1, #df do
				y[i] = y[i] + delta * values[i]
			end
		end

		return y
	end
end

-- Implements the Heun (Euler Second Order) Method for integrate ordinary differential equations
-- Method of type Predictor-Corrector
-- Parameters: 
--  df, is the differential equantion, 
--  initCond, is the initial condition which must be satisfied
--  [a,b[, is a close defined interval,
--  delta, is the step of the independent variable
function integrationHeun(df, initCond, a, b, delta)
	if type(df) == "function" then
		local x = a
		local y = initCond
		local y1 = 0
		local val = 0
		local bb = b - delta
		for x = a, bb, delta do
			val = df(x, y)
			y1 = y + delta * val
			y = y + 0.5 * delta * (val + df(x + delta, y1))
		end
		return y
	else
		local x = a
		local y = initCond
		local y1 = 0
		local val = 0
		local bb = b - delta
		local sizeDF = #df
		for x = a, bb, delta do
			local val = {}
			local y1  = {}
			for i = 1, sizeDF do
				val[i] = df[i](x, y)
				y1[i] = y[i] + delta * val[i]
			end
			local values = {}
			for i = 1, sizeDF do
				values[i] = df[i](x + delta, y1)
			end
			for i = 1, sizeDF do
				y[i] = y[i] + 0.5 * delta * (val[i] + values[i])
			end
		end
		return y
	end
end

-- Implements the Runge-Kutta Method (Forth Order) for integrate ordinary differential equations
-- Parameters: 
--  df, is the differential equantion, 
--  initCond, is the initial condition which must be satisfied
--  [a,b[, is a close defined interval,
--  delta, is the step of the independent variable
function integrationRungeKutta(df, initCond, a, b, delta)
	local i = 0
	if type(df) == "function" then
		local x = a
		local y = initCond
		local y1 = 0
		local y2 = 0
		local y3 = 0
		local y4 = 0
		local bb = b - delta
		local midDelta = 0.5 * delta
		for x = a, bb, delta do
			y1 = df(x, y)
			y2 = df(x + midDelta, y + midDelta * y1)
			y3 = df(x + midDelta, y + midDelta * y2)
			y4 = df(x + delta, y + delta* y3)
			y = y + delta * (y1 + 2 * y2 + 2 * y3 + y4)/6
		end
		return y
	else
		local x = a
		local y = initCond
		local y1 = 0
		local y2 = 0
		local y3 = 0
		local y4 = 0
		local bb = b - delta
		local midDelta = 0.5 * delta
		local sizeDF = #df
		for x = a, bb, delta do
			local yTemp = {}
			local values = {}
			for i = 1, sizeDF do
				yTemp[i] = y[i]
			end
			for i = 1, sizeDF do
				y1 = df[i](x, y)
				yTemp[i] = y[i] + midDelta * y1
				y2 = df[i](x + midDelta, yTemp )
				yTemp[i] = y[i] + midDelta * y2
				y3 = df[i](x + midDelta, yTemp )
				yTemp[i] = y[i] + delta * y3
				y4 = df[i](x + delta, yTemp)
				values[i] = y[i] + delta * (y1 + 2 * y2 + 2 * y3 + y4)/6
			end
			for i = 1, sizeDF do
				y[i] = values[i]
			end
		end
		return y

	end
end

-- Global constante to define the used integration method & step size
INTEGRATION_METHOD = integrationEuler
DELTA = 0.2

-- Constructor for an ordinary differential equation
function d(attrTab)
	local result = 0
	local delta = DELTA

	if attrTab == nil then attrTab = {}; end

	local sizeAttrTab = getn(attrTab)
	if sizeAttrTab < 4 then 
		local str = "Error: bad arguments in diferential equation constructor \"d{arguments}\". "..
			"TerraME has found ".. #attrTab.." arguments.\n"..
			" - the first attribute of a differential equantion must be a function which return a number. "..
			"It can also be a table of functions like that,\n"..
			" - the second one must be the initial condition value. "..
			"It can also be a table of initial conditions,\n"..
			" - the third one must be the lower integration limit value,\n"..
			" - the fourth one must be the upper integration limit value, and\n"..
			" - the fifth, OPTIONAL, must be the integration incretement value(default = "..DELTA.." ).\n"..
			" - the fifth, OPTIONAL, must be the integration incretement value(default = "..DELTA.." ).\n"
		error(str, 2)
	end
	if sizeAttrTab == 5 then
		delta = attrTab[5]
	end

	if ( type( attrTab[1] ) == "table" ) then
		--vardump(attrTab[1])
		--vardump(attrTab[2])

		if( #attrTab[1] ~= #attrTab[2] ) then 
			error("Error: You should provide the same number of differential equations and initial conditions.",2)
			return nil
		end
	end

	local y = INTEGRATION_METHOD(attrTab[1], attrTab[2], attrTab[3], attrTab[4], delta)
	
	if ( type( attrTab[1] ) == "table" ) then

		local str = "return "..y[1]
			for i = 2, #y do
				str = str ..", "..y[i]
			end
		return loadstring(str)()

	else
		return y
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

integrate = function(attrs)
	if attrs.event ~= nil then
		attrs.a = attrs.event:getTime() - attrs.event:getPeriod() 
		if attrs.a < 1 then attrs.a = 1 end
		attrs.b = attrs.event:getTime()
	end

	if type(attrs.equation) == "table" then
		if type(attrs.initial) == "table" then
			if getn(attrs.equation) ~= getn(attrs.initial) then
				error("Tables equation and initial shoud have the same size.", 2)
			end
		else
			error("As equation is a table, initial should also be a table, got "..type(attrs.initial)..".", 2)
		end
	end

	if attrs.step == nil  then attrs.step = 0.1      end
	if attrs.method == nil then attrs.method = "euler" end

	local result = switch(attrs, "method"): caseof {
		["euler"] = function() return integrationEuler(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
		["rungekutta"] = function() return integrationRungeKutta(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
		["heun"] = function() return integrationHeun(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end
	}

	if type(attrs.equation) == "table" then
		local str = "return "..result[1]
			for i = 2, getn(attrs.equation) do
				str = str ..", "..result[i]
			end
		return loadstring(str)()
	end
	return result
end

