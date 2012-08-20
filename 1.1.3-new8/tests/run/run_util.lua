COMPARE_PATH = TME_PATH .."//tests//dependencies//results//"
RESULT_PATH = TME_PATH.."//bin//results//"
DB_PATH = RESULT_PATH.."db.txt"

local INPUT = RESULT_PATH .."input.txt"

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

function extractFile(filename)
    str = ""
    local file=io.open(filename,"r")
    for line in file:lines() do str = str .. line .. "\n" end
    file:close()
    return str
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
    for i, name in ipairs(testName) do
	    print("\n\n\################# ", name ," #################")io.flush()
        generateAnswer(name,compareResult(name,prefixFile))
        removeTempFile()
        --TODO
        -- remove outuput.txt and temp.txt from result folder
    end
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
	print("(1) Run specific test:")io.flush()
    n = tonumber(io.read())
    if(n==1) then
        for number, test in ipairs(functionList) do
            print(string.format(" %d : %s",number,test))io.flush()
        end
        f = tonumber(io.read())
        for number, value in ipairs(SKIPS) do
            if(number~=f) then
                SKIPS[number] = true
            end
        end
    end
    
    return SKIPS
end

function execute(testType, testNames, executeFileName, prefixExec, prefixFile, fileResultName)
    print(string.format("\n**     TESTS FOR %s      **", testType:upper()))io.flush()
	print("Choose option:")io.flush()
	print("(0) Run all tests")io.flush()
	print("(1) Run specific test:")io.flush()
    n = tonumber(io.read())
    if(n==1) then
        for number, name in ipairs(testNames) do
            print(string.format(" %d : %s",number,name))
        end
        f = tonumber(io.read())
        newList = {}
        print(testNames[f])
        table.insert(newList, testNames[f])
        executeAll(testType, newList, executeFileName, prefixExec, prefixFile, fileResultName, false)
    elseif(n==0) then
        executeAll(testType, testNames, executeFileName, prefixExec, prefixFile, fileResultName, true)
    end 
end

function executeObservers(executeFileName, maxTest)
    print("Choose one of the options:")io.flush()
    print("0: Run all tests")io.flush()
    print("1: Run one test group")io.flush()
    n = tonumber(io.read())
    if(n==0) then
        for i=1, #maxTest, 1 do
            executeFileName = executeFileName .. " < " .. INPUT
            for j=1, maxTest[i], 1 do
                updateObserversInput(i,j)
                os.execute(executeFileName)
            end
        end
    end
    os.execute(executeFileName)
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

local f = io.open(RESULT_PATH, "r")
if(not f) then
	os.execute("mkdir " .. RESULT_PATH)
else
    f:close()
end
