dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_cellular_space.lua"

tests={
    [1] = 11,
    [2] = 10,
    [3] = 4
}

executeObservers(executeFileName, tests)
