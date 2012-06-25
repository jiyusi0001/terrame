-- RAIN DRAINAGE MODELS
-- (C) 2010 INPE AND UFOP

-- model parameters
C = 2 -- rain/t
K = 0.4 -- flow coefficient
dt = 0.01 -- time increment


-- GLOBAL VARIABLES
q = 0
input = 0
output = 0

-- RULES
dt = DELTA/2
--INTEGRATION_METHOD = integrationEuler
--INTEGRATION_METHOD = integrationHeun
--INTEGRATION_METHOD = integrationRungeKutta
q = d{ function (t, q) return C - K*q end, 0, 0, 100, dt }
print( q  )

print("Please, press <ENTER> to quit.")
io.flush()
io.read()