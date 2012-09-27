dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_environment.lua"

tests={
    [1] = 5,
    [2] = 6,
    [3] = 6,
    [4] = 9
    --[5] = 6
}

executeObservers(executeFileName, tests)
