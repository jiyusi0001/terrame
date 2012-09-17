dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_timer.lua"

tests={
    [1] = 13,
    [2] = 13,
    [3] = 13,
    [4] = 7,
    --[5] = 11
}

executeObservers(executeFileName, tests)
