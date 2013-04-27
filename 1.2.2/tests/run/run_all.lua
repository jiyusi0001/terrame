dofile(TME_PATH.."/tests/run/run_util.lua")

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

runAll(MAIN_PATH)
