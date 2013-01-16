--dofile(TME_PATH.."/tests/dependencies/XDebug.lua")

COMPARE_PATH = TME_PATH .. TME_DIR_SEPARATOR .."tests" .. TME_DIR_SEPARATOR .. "dependencies" .. TME_DIR_SEPARATOR .."results".. TME_DIR_SEPARATOR
MAIN_PATH = TME_PATH .. TME_DIR_SEPARATOR.."tests"..TME_DIR_SEPARATOR.."src"..TME_DIR_SEPARATOR
RESULT_PATH = TME_PATH.. TME_DIR_SEPARATOR .."bin".. TME_DIR_SEPARATOR .. "results".. TME_DIR_SEPARATOR
INPUT = RESULT_PATH.."number_test.txt"
REG = RESULT_PATH.."reg.txt"
DB = RESULT_PATH.."db.txt"
TEMP_PATH = RESULT_PATH.."temp.txt"
--DB_PATH = RESULT_PATH.."db.txt"

--@author: Rodrigo Reis
function delay_s(delay)
--delay = delay or 1
--local time_to = os.time() + delay
--while os.time() < time_to do end
end

function getn(t)
	local n = 0
	for k, v in pairs(t) do
		n = n +1
	end
	return n
end

function contains(t,value)
	if(t == nil) then return false end
	for _,v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false  
end

function os.capture(cmd)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    return s
end

function createTestFolder(subject, observer, testNumber, path)
	local copyTo = RESULT_PATH..subject..TME_DIR_SEPARATOR..observer..testNumber..TME_DIR_SEPARATOR
	local copyFrom = path

	if(TME_DIR_SEPARATOR~="\\") then
		os.execute("mkdir -p " .. copyTo)
		copyCommand = "cp *.png ".. copyFrom .." ".. copyTo .." > /dev/null 2>&1 "
		removeCommand = "rm *.png"
	else
		local fi = os.execute("mkdir " .. copyTo .. " >NUL 2>&1")
		copyCommand = "copy *.png ".." ".. copyTo .. " >NUL 2>&1"
		removeCommand = "del *.png"
	end
	os.execute(copyCommand)
	os.execute(removeCommand)
end

function getDataBase()
    db = extractFile(DB):split("\n")
    return {["dbms"] = tonumber(db[1]), ["pwd"] = db[2]}
end

function extractFile(filename)
    str = ""
    local file=io.open(filename,"r")
    for line in file:lines() do str = str .. line .. "\n" end
    file:close()
    return str
end

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function os.isUnix() 
	local isWin=string.find(string.lower(os.getenv('OS') or 'nil'),'windows')~=nil
	return not isWin
end

function os.isLinux()
    local res = os.execute("uname -o > /dev/null 2>&1")
    if res then return true
    else return false end
end

function getSOName()
    if os.isUnix() then
        if os.isLinux() then
            return "linux"
        else
            return "mac"
        end
    else
        return "windows"
    end
end

UnitTest_ = {
	assert_nil = function(self,v)
		return self:compute(v == nil)
	end,
	assert_not_nil = function(self,v)
		return self:compute(v ~= nil)
	end,
	assert_equal = function(self,v1,v2,tol)
		if(tol == nil) then
			return self:compute(v1 == v2)
		else
			return self:compute((v1 - v2) <= tol)
		end
	end,
	assert_not_equal = function(self,v1,v2)
		return self:compute(v1 ~= v2)
	end,
	assert_true = function(self, v)
		return self:compute(v == true)
	end,
	assert_false = function(self, v)
		return self:compute(v == false)
	end,
	assert_gt = function(self,v1,v2)
		return self:compute(v1 > v2)    
	end,
	assert_lt = function(self,v1,v2)
		return self:compute(v1 < v2)    
	end,
	assert_gte = function(self,v1,v2)
		return self:compute(v1 >= v2)    
	end,
	assert_lte = function(self,v1,v2)
		return self:compute(v1 <= v2)    
	end,
	assert_len = function(self,size,table)
		return self:compute(size == getn(table))
	end,
	assert_not_len = function(self,size,table)
		return self:compute(size ~= getn(table))   
	end,
	assert_match = function(self,pat,s)
		local s = tostring(s)
		return self:compute((type(s) == "string") and s:match(pat))
	end,
	assert_not_match = function(self,pat,s)
		local s = tostring(s)
		return self:compute((type(s) == "string") and not s:match(pat))
	end,
	assert_boolean = function(self, v)
		return self:compute(type(v) == "boolean")
	end,
	assert_not_boolean = function(self, v)
		return self:compute(type(v) ~= "boolean")
	end,
	assert_number = function(self, v)
		return self:compute(type(v) == "number")
	end,
	assert_not_number = function(self, v)
		return self:compute(type(v) ~= "number")
	end,
	assert_string = function(self, v)
		return self:compute(type(v) == "string")
	end,
	assert_not_string = function(self, v)
		return self:compute(type(v) ~= "string")
	end,
	assert_table = function(self, v)
		return self:compute(type(v) == "table")
	end,
	assert_not_table = function(self, v)
		return self:compute(type(v) ~= "table")
	end,
	assert_function = function(self, v)
		return self:compute(type(v) == "function")
	end,
	assert_not_function = function(self, v)
		return self:compute(type(v) ~= "function")  
	end,
	assert_thread = function(self, v)
		return self:compute(type(v) == "thread")
	end,
	assert_not_thread = function(self, v)
		return self:compute(type(v) ~= "thread")   
	end,
	assert_userdata = function(self, v)
		return self:compute(type(v) == "userdata")
	end,
	assert_not_userdata = function(self, v)
		return self:compute(type(v) ~= "userdata")
	end,
	assert_metatable = function(self, exp, v)
		local mt = getmetatable(v)
		return self:compute(mt == exp)
	end,
	assert_not_metatable = function(self, exp, v)
		local mt = getmetatable(v)
		return self:compute(mt ~= exp)
	end,
	assert_image_match = function(self,img1,img2)
		--TODO
		return true
	end,
	assert_not_image_match = function(self,img1,img2)
		--TODO
		return false
	end,
	assert_error = function(self, v)
		local ok, err = pcall(v)
		return self:compute(not ok)
	end,
	assert_equal_binaries = function(self, firstFile,secondFile)
		--unix	  
		if TME_DIR_SEPARATOR == "/" then

			fi=os.execute("cmp "..firstFile .. " ".. secondFile)
			if (fi == 0 or fi == true) then
				return self:compute(true)
			else
				return self:compute(false)
			end
			--windows
		else
			local fileIn = io.open("in.txt","w")
			fileIn:write("n \n")
			fileIn:close()
			local fi = os.execute("fc "..firstFile .. " ".. secondFile .. "<in.txt > resultComp.txt" )
			os.execute("del in.txt")
			if (fi == 0 or fi == true) then
				return self:compute(true)
			else
				return self:compute(false)
			end
		end
	end,
	assert_equal_directory_structure = function (subject, observer, testNumber, path)
		createTestFolder(subject,observer,testNumber,path)
		local file1 = RESULT_PATH..subject..TME_DIR_SEPARATOR..observer..testNumber..TME_DIR_SEPARATOR
		local file2 = COMPARE_PATH..subject..TME_DIR_SEPARATOR..observer..testNumber..TME_DIR_SEPARATOR
		local files1 = scandir(file1)
		local files2 = scandir(file2)

		local files1Size = 0    
		for i=1,#files1, 1 do
			if (endswith(files1[i],".png")) then
				files1Size = files1Size + 1
			end
		end

		local files2Size = 0    
		for i=1,#files2, 1 do
			if (endswith(files2[i],".png")) then
				files2Size = files2Size + 1
			end
		end

		if(files1Size ~= files2Size) then
			return "Error: Different Number of Files.\nIn:\t".. subject .."\t".. observer .. testNumber
		elseif(not (subject == "agent" or subject == "society")) then
			for i=1,#files1,1 do
				if endswith(files1[i],".png") and endswith(files2[i],".png") then
					if not compareBinaries(file1..files1[i],file2..files2[i]) then
						return "Error: Images Do Not Match.\nIn:\t".. subject .."\t".. observer .. testNumber
					end
				end
			end
		end
		return "Image Comparison Succeed!"
	end,  
	getTestList = function(self)
	    if not self.testList then
		    self.testList = {}
		    for k, v in pairs(self) do
			    if(type(v) == "function") then
				    table.insert(self.testList,k)
			    end
		    end
		    table.sort(self.testList,function(a,b)
                return a < b
            end)
		end
		return self.testList
	end,

	executeRun = function(self)
		local tests = self:getTestList()
		for k, v in ipairs(tests) do
			if(not contains(self.skips,v)) then
				-- this is necessary to avoid test crashes on error situations
				f,vrf = pcall(self[v],self)
				if(not f) then
					print(vrf)         
				end
			end
		end
		self:printReport()
	end,

	selectOneTest = function(self,test)
    self.funcName = test
    
		local w = debug.getinfo(3, "S")
		self.currentFile = string.sub(w.source,2,string.len(w.source))

		local tests = self:getTestList()
		for k, v in ipairs(tests) do
			if(v ~= test and not contains(self.skips,v)) then
				table.insert(self.skips,v)
			end
		end
	end,

	run = function(self)
		local tests = self:getTestList()
		local tryopen = io.open(REG,"r")
		if tryopen then
			tempSkips = self.skips
			n = tonumber(io.read())
			self:selectOneTest(tests[n])
			self:executeRun()
			self.skips = tempSkips
		end
		local file = io.open(REG,"w")
		file:write(#tests.."\n")
		for i=1,#tests, 1 do
			file:write(tests[i].."\n")
		end
		file:write(#self.skips.."\n")
		for i=1,#self.skips, 1 do
			file:write(self.skips[i].."\n")
		end
		file:close()
	end,

	compute = function(self,value)
    
    if(self.currentFile == nil ) then print("caraca!!! ", value) end


		local w = debug.getinfo(2, "S")

		local l = debug.getinfo(2, "l")
		local currentLine = l.currentline

		local f = debug.getinfo(2, "f")
		local fAddress = nil
		for k,v in pairs(f) do
			fAddress = "".. tostring(v):gsub("function: ", "")        
		end

		self.assertions = self.assertions + 1
		if(value) then
			self.succeed = self.succeed + 1
			return true
		else
			self.failed = self.failed + 1
			local msg = "File '".. self.currentFile .."'"
			if(self.funcName ~= nil) then msg = msg .." function '".. self.funcName .."'" end
			msg = msg .." in line ".. currentLine
			table.insert(self.fails,msg)
			return false
		end
	end,
	
	printReport = function(self)
		print("\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
		print("Testing function: ", self.funcName)
    local curFile = string.gsub(self.currentFile, TME_PATH, "")
    curFile = string.gsub(curFile, '\\', '/')
	  print("File:", "..."..curFile)
		print("")
		print("Assertions: ".. self.assertions .." total, ".. self.succeed .. " succeed, ".. self.failed .." failed.")
		if(getn(self.fails) > 0) then
			print("Failed: ")    
			for k, v in pairs(self.fails) do
				print("\t- ".. v)
			end
		end
		print("\n= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =")
	end,

	checkEnd = function(self, n)
		file=io.open(INPUT,"w")
		if(n >= #self:getTestList()) then file:write(-1) end
		file:close()
	end
}

local metaTable_ = {__index = UnitTest_}

function UnitTest(attrTab)
	setmetatable(attrTab, metaTable_)
	attrTab.assertions = 0
	attrTab.succeed = 0
	attrTab.failed = 0
	attrTab.fails = {}
	if(attrTab.skips == nil ) then attrTab.skips = {} end
	return attrTab
end
