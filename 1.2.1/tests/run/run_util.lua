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
            SKIPS[skipList[i]]=true
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
