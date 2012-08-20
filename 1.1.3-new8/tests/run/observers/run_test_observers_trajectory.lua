dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_trajectory.lua"

tests={
    [1] = 9,
    [2] = 9,
    [3] = 7,
}

executeObservers(executeFileName, tests)

