dofile(TME_PATH.."/tests/dependencies/UnitTest.lua")

GENERATE_RESULT = false

extensions_ = {".png",".csv"}

function initialize()
    os.createDir(RESULT_PATH)
    os.createDir(COMPARE_PATH)
    print(">> Choose option:")
    print("(0) Fast execution")
    print("(1) Delayed execution")
    local n = tonumber(io.read())
    if(n == 1) then 
        local file = io.open(RESULT_PATH.."DELAYED_EXECUTION.txt","w")
        file:write("true")
        file:close()
    else
        local file = io.open(RESULT_PATH.."DELAYED_EXECUTION.txt","w")
        file:write("false")
        file:close()
    end
    writeResult()
    print(">> Choose option:")
    print("(0) Run to generate Comparison Files")
    print("(1) Run to generate Result File")
    local n = tonumber(io.read())
    if n == 0 then GENERATE_RESULT = true return true
    elseif n == 1 then GENERATE_RESULT = false return true
    else return false
    end
end

function runAllDirectory(directory,directoryRoot,all)
    directory = directory .. directoryRoot
    local fs = scandir(directory)
    local files = {}
    for i = 1, #fs, 1 do
        if isTestFile(fs[i]) then 
            table.insert(files,fs[i])
        end
    end
    if all then
        n = 0
    else
        n = getOptions(files)
    end
    if n == 0 then all = true end
    for j = 1, #files, 1 do
        if not all then j = n end
        os.remove(REG)
		--TODO add absolute path in this command
        local command = "TerraME "..directory..files[j]
        os.capture(command)
        command = command.." < " .. INPUT
        local file = io.open(REG,"r")
        local testNumber = tonumber(file:read())
        local tests = {}
        for k = 1, testNumber, 1 do
            table.insert(tests,file:read())
        end
        local skipsNumber = tonumber(file:read())
        local skips = {}
        for k = 1, skipsNumber, 1 do
            table.insert(skips,file:read())
        end
        file:close()
        if all then n = 0
        else n = getOptions(tests)end
        if n==0 then
            if not GENERATE_RESULT then
                writeResult(getBaseFileName(files[j]))
            end
            for i=1, testNumber, 1 do
                updateTestNumber(i)
                executeTest(command,directoryRoot,files[j],skips,tests[i], true)
            end
            if not all then
                printSkippedList(skips)
                os.remove(REG)
                return -1
            end
        elseif n > 0 and n <= testNumber then
            updateTestNumber(n)
            executeTest(command,directoryRoot,files[j],skips,tests[n], false)
            printSkippedList(skips)
            os.remove(REG)
            return -1;
        end
        printSkippedList(skips)
    end
    return 1
end

function executeTest(command, directoryRoot, file, skips, test, all)
    local output = os.capture(command)
    if contains(skips,test) then
        writeResult("\t"..getBaseFileName(directoryRoot..test..": SKIPPED"))
        if not all then print("This test was marked to be skipped.") io.flush() end
    else
        print(output)io.flush()
        local path_ = RESULT_PATH..directoryRoot..getBaseFileName(file)..TME_DIR_SEPARATOR
        local results_ = path_..getBaseFileName(test)..TME_DIR_SEPARATOR
        if hasResultFile() then
            os.createDir(results_)
            for _,v in ipairs(extensions_) do
                moveFilesToResults(".",results_,v)
            end
        end
        
        if GENERATE_RESULT then
            os.createDir(path_)
            local out = io.open(createOutPutFilename(RESULT_PATH,directoryRoot,file,test),"w")
            out:write(output)
            out:close()
        else
            local result = compareOutPut(directoryRoot,file,output,test)
            r = "FAILED"
            if result then r = "SUCCEED" end
            writeResult("\t"..getBaseFileName(directoryRoot..test..": "..r))
        end
    end
end

function printSkippedList(skips)
    if #skips > 0 then
		print("\n--------------------------------------------------------------------\n")
        print("Skipped: ")    
        for _, v in pairs(skips) do
            print("\t- Function '".. v .. "'")
        end
		print("\n--------------------------------------------------------------------\n")        
    end
end

function createDbFile()
	local file=io.open(DB,"w")
    print(">> Choose database type: ")io.flush()
	print("(0) MySQL")io.flush()
	print("(1) MSAccess")io.flush()

    local dbType = tonumber(io.read())
    local pass="pwd"
    if(dbType==0) then
        print(">> Type database password: ")io.flush()
        pass = io.read()
    end
	file:write(dbType .."\n".. pass)
    file:close()
end

function endswith(s, send)
	return #s >= #send and s:find(send, #s-#send+1, true)
end

function startswith(s, sstart)
	return #s >= #sstart and s:find(sstart, 1, true)
end

function updateTestNumber(n)
    local file=io.open(INPUT,"w")
	file:write(n.."\n")
	file:close()
end

function isTestFile(filename)
    return endswith(filename, ".lua") and startswith(filename,"test_")
end

function isResultFile(filename)
    for _,v in ipairs(extensions_) do
        if endswith(filename,v) then return true end
    end
    return false
end

function moveFilesToResults(path,copyTo,extension)
    local copyCommand
    local removeCommand
    os.createDir(copyTo)
    if os.isUnix() then
		copyCommand = "cp ".." ".. path .."/*"..extension.." ".. copyTo .." > /dev/null 2>&1 "
		removeCommand = "rm *"..extension .." > /dev/null 2>&1 "
	else
		copyCommand = "copy /Y *"..extension.." ".. copyTo .. " >NUL 2>&1"
		removeCommand = "del *"..extension.." >NUL 2>&1"
    end
    os.capture(copyCommand)
	os.capture(removeCommand)
end

function scandir(dirname)
    local s
    if os.isUnix() then
        s = os.capture("ls -1 "..dirname)
    else
        s = os.capture("dir "..dirname.." /b")
    end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    return s:split("\n")
end

function isFile(path)
	local f = io.open(path)	
    if(f) then
		local ok, err, code = f:read(1)
		f:close()
		return err==nil
	else
		return false
	end    
end


function os.isFileExist(fn)
	local f=io.open(fn,'r')
	if f==nil then return false end
	f:close()
	return true
end

function os.createDir(path)
    if os.isFileExist(path) then return false end
    if os.isUnix() then
        os.capture('mkdir -p "'..path..'"'.." > /dev/null 2>&1 ")
    else
        os.capture("md "..string.gsub(path, '/', '\\').." >NUL 2>&1")
    end
    return true
end

function getOptions(params, f)
    local list = {}
    local cont = 0
    for i=1, #params, 1 do
        if f then
            if f(params[i]) then
                cont = cont + 1
                table.insert(list,string.format("(%d) %s",i,params[i]))
            end
        else
            cont = cont + 1
            table.insert(list,string.format("(%d) %s",i,params[i]))
        end
    end
    if cont == 0 then return 0 end
    print(">> Choose option:")io.flush()
    print("(0) Run all tests")io.flush()
    for i, v in ipairs(params) do print("("..i..") "..v) io.flush() end
    return tonumber(io.read())
end

function getBaseFileName(filename)
    pos = 0
    for i = 1, filename:len(), 1 do if filename:sub(i,i) == "." then pos = i break end end
    basename = filename:sub(1,pos-1)
    return basename
end

function extractFile(filename)
    local lines = {}
    local file=io.open(filename,"r")
    if not file then return nil end
    for line in file:lines() do table.insert(lines,line) end
    file:close()
    return lines
end

function getSOName()
    if os.isUnix() then
        if os.isLinux() then
            return "linux"
        else
            return "macos"
        end
    else
        return "windows"
    end
end

function createOutPutFilename(path,directoryRoot, filename,functionname)
    return path..directoryRoot..getBaseFileName(filename)..TME_DIR_SEPARATOR..functionname..".txt"
end

function writeResult(result)
    if GENERATE_RESULT then return end
    if result then
        local file = io.open(RESULT_PATH.."results.txt","a")
        file:write(result.."\n")
        file:close()
    else
        local file = io.open(RESULT_PATH.."results.txt","w")
        file:write("")
        file:close()
    end
    
end

function compareOutPut(directoryRoot,filename, output, functionname)
    local f = createOutPutFilename(COMPARE_PATH..getSOName()..TME_DIR_SEPARATOR, directoryRoot,filename,functionname)
    local result = extractFile(f)
    if not result then io.flush() return false end
    compare = output:split("\n")
    for i=1, #result, 1 do
        if(compare[i]~=result[i]) then
            return false;
        end
    end
    return true;
end

function table.append_list(lhs, rhs)
    local merged_table = {}
    for _, v in ipairs(lhs) do
        table.insert(merged_table, v)
    end
    for _, v in ipairs(rhs) do
        table.insert(merged_table, v)
    end
    return merged_table
end

function table.remove_all(t1, t2)
    local r = {}
    for _, v in ipairs(t1) do
        if not contains(t2,v) then
            table.insert(r,v)
        end
    end
    return r
end

function generateSet(t)
    local set = {}
    for _, v in ipairs(t) do
        if not contains(set,v) then
            table.insert(set,v)
        end
    end
    return set
end

function findTestsFile(path)
    local result = false
    local files = scandir(path)
    local tests={}
    for i = 1, #files, 1 do
        local file = path..files[i]        
        if not isFile(file) then
            tests = table.append_list(tests,findTestsFile(file..TME_DIR_SEPARATOR,isType))
        else
            if isTestFile(files[i]) then
                local str = path:split(TME_DIR_SEPARATOR)
                local item = path:sub(#MAIN_PATH+1,#path-1)
                table.insert(tests,item)
                result = true
            end
        end
    end
    return tests
end

function hasResultFile()
    local l = scandir("")
    for _,v in ipairs(l) do
        if isResultFile(v) then return true end
    end
    return false
end

function table.find(t, e) -- find element v of l satisfying f(v)
  for i, v in ipairs(t) do
    if v==e then return i end
  end
  return 0
end

--[[
COMPARE_PATH = TME_PATH .. TME_DIR_SEPARATOR .."tests" .. TME_DIR_SEPARATOR .. "dependencies" .. TME_DIR_SEPARATOR .."results".. TME_DIR_SEPARATOR
RESULT_PATH = TME_PATH.. TME_DIR_SEPARATOR .."bin".. TME_DIR_SEPARATOR .. "results".. TME_DIR_SEPARATOR
DB_PATH = RESULT_PATH.."db.txt"
DATE_PATH = RESULT_PATH.."date.txt"

local INPUT = RESULT_PATH .."input.txt"

-- util function
function delay_s(delay)
	--delay = delay or 1
	--local time_to = os.time() + delay
	--while os.time() < time_to do end
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

function scandir(dirname)
	if(TME_DIR_SEPARATOR~="\\") then
		return scandirLinux(dirname);
	else
		return scandirWindows(dirname);
	end
end

function scandirLinux(dirname)
	callit = os.tmpname()
	os.execute("ls -a1 "..dirname .. " >"..callit)
	f = io.open(callit,"r")
	rv = f:read("*all")
	f:close()
	os.remove(callit)
	tabby = {}
	local from  = 1
	local delim_from, delim_to = string.find( rv, "\n", from  )
	while delim_from do
		table.insert( tabby, string.sub( rv, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( rv, "\n", from  )
	end
	return tabby
end

function scandirWindows(directory)
    local i, t, popen = 0, {}, io.popen
	for filename in popen("dir "..directory .. " /b"):lines() do
		i = i + 1
		t[i] = filename
	end
	return t
end


function compareDirectory(subject, observer, testNumber, path)
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
end

function createTemp()
	local file=io.open(RESULT_PATH.."temp.txt","a")
    for i=1, 500, 1 do file:write("\n") end
    file:close()
end

function createOutput()
	local file=io.open(RESULT_PATH.."output.txt","w")
    file:write("")
    file:close()
end

function writeDate(date)
	local file=io.open(RESULT_PATH..FINAL_RESULT_NAME,"a")
    file:write(date)
    file:close()
end

function createAnswer()
    local file=io.open(RESULT_PATH..FINAL_RESULT_NAME,"w")
    file:write("")
    file:close()
end

function initialize()
    createTemp()
    createDbFile()
end

function createDbFile()
	local file=io.open(DB_PATH,"w")
    print(">> Database type: ")io.flush()
	print("\t0 : MySQL")io.flush()
	print("\t1 : MSAccess")io.flush()

    local dbType = tonumber(io.read())
    local pass="pwd"
    if(dbType==0) then
        print(">> MySQL password: ")io.flush()
        pass = io.read()
    end
	file:write(dbType .."\n".. pass)
    file:close()
end

function createResult(testName,prefix)
	print("Generating execution report...")io.flush()
    testResult = extractFile(RESULT_PATH.."output.txt")
    local file=io.open(generateFilename(testName,RESULT_PATH,prefix),"w")
    file:write(testResult)
    file:close()
end

function generateFilename(file,folder,prefix)
    return string.format("%s%s%s.txt",folder,prefix,file)
end

function compareResult(testName,prefix)
	print("Comparing results...")io.flush()
    local compare = extractFile(generateFilename(testName,COMPARE_PATH,prefix)):split("\n")
    local result = extractFile(generateFilename(testName,RESULT_PATH,prefix)):split("\n")
    for i=1, #result, 1 do
        if(compare[i]~=result[i]) then
            return false;
        end
    end
    return true;
end

function endswith(s, send)
	return #s >= #send and s:find(send, #s-#send+1, true) and true or false
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

function generateAnswer(testName, value)
	print("Generating comparison report...")io.flush()	
    local file=io.open(RESULT_PATH.. FINAL_RESULT_NAME,"a")
    if(value) then
        file:write(string.format("%s: OK\n",testName))
    else
        file:write(string.format("%s: Nao OK\n",testName))
    end
    file:close()
end

function removeTempFile()
    os.remove(RESULT_PATH.."temp.txt")
    os.remove(RESULT_PATH.."output.txt")
    os.remove(DB_PATH)
end

function executeAll(testType, testName, executeFileName, prefixExec, prefixFile, fileResultName, all)

    FINAL_RESULT_NAME = fileResultName
    createAnswer()
    
    -- generates each test execution report
    for i, name in ipairs(testName) do
        createOutput()
        if(all)then
			if(TME_DIR_SEPARATOR~="\\") then
				command = string.format("%s%s%s.lua < %stemp.txt 2>&1 | tee -a %soutput.txt", executeFileName,prefixExec, name, RESULT_PATH, RESULT_PATH)
			else
				command = string.format("%s%s%s.lua < %stemp.txt 2>&1 | wtee -a %soutput.txt", executeFileName,prefixExec, name, RESULT_PATH, RESULT_PATH)
			end
		    os.execute(command)
            createResult(name,prefixFile)
        elseif(testType == "demos") then
        	command = string.format("%s%s%s.lua < %stemp.txt", executeFileName,prefixExec, name, RESULT_PATH)
        else
			if(TME_DIR_SEPARATOR~="\\") then
				command = string.format("%s%s%s.lua 2>&1 | tee -a %soutput.txt", executeFileName,prefixExec, name, RESULT_PATH)
			else
				command = string.format("%s%s%s.lua 2>&1 | wtee -a %soutput.txt", executeFileName,prefixExec, name, RESULT_PATH)
			end
            os.execute(command)
        end
    end        
    -- compares and generates final report
	writeDate("Started tests at:\n".. INITIAL_DATE.."\n\n")
    for i, name in ipairs(testName) do
	    print("\n\n################# ", name ," #################")io.flush()
        generateAnswer(name,compareResult(name,prefixFile))
        removeTempFile()
        --TODO
        -- remove outuput.txt and temp.txt from result folder
    end
	writeDate("\n\nFinished tests at:\n" .. os.date() .."\n")
end

function executeBasics(testName, functionList, skipList)
    SKIPS = {}
    for i=1,#functionList,1 do
        SKIPS[i] = false
    end
    if skipList ~=nil then
        for i=1,#skipList,1 do
            SKIPS[skipList[i]]  --[[=true
        end
    end
    print(string.format("\n**     TESTS FOR %s      **", testName:upper()))
	print("Choose option:")io.flush()
	print("(0) Run all tests")io.flush()
	for number, test in ipairs(functionList) do
        print(string.format("(%d) %s",number,test))io.flush()
    end
    n = tonumber(io.read())
    if n~=0 then
        f = n
        for number, value in ipairs(SKIPS) do
            if(number~=f) then
                SKIPS[number] = true
            end
        end
    end
    
    return SKIPS
end

function execute(testType, testNames, executeFileName, prefixExec, prefixFile, fileResultName)
	INITIAL_DATE = os.date()
    print(string.format("\n**     TESTS FOR %s      **", testType:upper()))io.flush()
	print("Choose option:")io.flush()
	print("(0) Run all tests")io.flush()
	for number, name in ipairs(testNames) do
        print(string.format("(%d) %s",number,name))
    end
    n = tonumber(io.read())
    if(n==0) then
        executeAll(testType, testNames, executeFileName, prefixExec, prefixFile, fileResultName, true)
        return
    end
    f = n
    newList = {}
    print(testNames[f])
    table.insert(newList, testNames[f])
    executeAll(testType, newList, executeFileName, prefixExec, prefixFile, fileResultName, false)
end

function executeObservers(executeFileName, maxTest)
    print("Choose one of the options:")io.flush()
    print("0: Run all tests")io.flush()
    for i=1,#maxTest, 1 do
        print(i..": "..maxTest[i][1],"[ Cases 1.."..maxTest[i][2].."  ]")io.flush()
    end
    n = tonumber(io.read())
    executeFileName = executeFileName .. " < " .. INPUT
    if(n==0) then
        for i = 1,  #maxTest, 1 do
            for j=1, maxTest[i][2], 1 do
                updateObserversInput(i,j)
                os.execute(executeFileName)
            end
        end
    else
        print("\nTest Case:    ")io.flush()
        testNumber = tonumber(io.read())
        updateObserversInput(n,testNumber)
        os.execute(executeFileName)
    end
end

function updateObserversInput(test,number)
	file=io.open(INPUT,"w")
	file:write(test.."\n"..number)
	file:close()
end

function getDataBase()
    db = extractFile(DB_PATH):split("\n")
    return {["dbms"] = tonumber(db[1]), ["pwd"] = db[2]}
end

function extractFile(filename)
    str = ""
    local file=io.open(filename,"r")
    for line in file:lines() do str = str .. line .. "\n" end
    file:close()
    return str
end

--@Henrique
--Só funciona quando os dois arquivos existem
function compareBinaries(firstFile,secondFile)
	if TME_DIR_SEPARATOR == "/" then

    fi=os.execute("cmp "..firstFile .. " ".. secondFile)
        if (fi == 0 or fi == true) then
	        return true
        else
	        return false
        end

	else
		local fileIn = io.open("in.txt","w")
		fileIn:write("n \n")
		fileIn:close()
		local fi = os.execute("fc "..firstFile .. " ".. secondFile .. "<in.txt > resultComp.txt" )
		os.execute("del in.txt")
		if (fi == 0 or fi == true) then
			return true
		else
			return false
		end
		--fi=extractFile("resultComp.txt")
	end
end

local f = io.open(RESULT_PATH, "r")
if(not f) then
		if TME_DIR_SEPARATOR == "/" then
			local fi = os.execute("mkdir -p" .. RESULT_PATH)
		else
			os.execute("mkdir " .. RESULT_PATH .. " >NUL 2>&1")
		end
else
	f:close()
end
--]]

