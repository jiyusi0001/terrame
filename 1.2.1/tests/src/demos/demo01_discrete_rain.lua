-- RAIN DRAINAGE MODELS
-- (C) 2010 INPE AND UFOP

-- model parameters
C = 2 -- rain/t
K = 0.4 -- flow coefficient

-- GLOBAL VARIABLES
q = 0
input = 0
output = 0

-- RULES
for time = 0, 100, 1 do
	-- rain
	input = C
	-- soil water
	q = q + input - output
	-- drainage
	output = K*q
	-- report
	print(time, input, output, q)
end

print("READY!")
print("Please, press <ENTER> to quit.")
io.flush()
io.read()
os.exit(1)
