dofile(TME_PATH.."/tests/dependencies/UnitTest.lua")

GENERATE_RESULT = false

extensions_ = {".png",".csv"}

function initialize()
    os.createDir(RESULT_PATH)
    os.createDir(COMPARE_PATH)
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
                moveFilesToResults("",results_,v)
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

function runAll(main_directory)    
    if not initialize() then return false end
    createDbFile()
    local files = generateSet(findTestsFile(main_directory))
    local n = getOptions(files)
    if n==0 then
        if not GENERATE_RESULT then
            writeResult("Started tests at:\n".. os.date() .."\n\n")
        end
        for i = 1, #files, 1 do
            runAllDirectory(main_directory,files[i]..TME_DIR_SEPARATOR,true)
        end
        if not GENERATE_RESULT then
            writeResult("\n\nFinished tests at:\n" .. os.date() .."\n")
        end
    elseif n > 0 then
        runAllDirectory(main_directory,files[n]..TME_DIR_SEPARATOR)
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
		copyCommand = "cp *"..extension.." ".. path .." ".. copyTo .." > /dev/null 2>&1 "
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

function os.capture(cmd)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    return s
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
            return "mac"
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
    print(f)
    io.read()
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

runAll(MAIN_PATH)
