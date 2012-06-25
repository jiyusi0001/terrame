executeFileName = "TerraME test_observers_society.lua"

function updateInput(test,number)
	file=io.open("input.txt","w")
	file:write(test.."\n"..number)
	file:close()
end

for i=1, 9, 1 do
	test="Image"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 9, 1 do
	test="Map"
	updateInput(test,i)
	os.execute(executeFileName)
end

