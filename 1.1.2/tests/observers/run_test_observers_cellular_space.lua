executeFileName = "TerraME test_observers_cellular_space.lua"

function updateInput(test,number)
	file=io.open("input.txt","w")
	file:write(test.."\n"..number)
	file:close()
end

for i=1, 10, 1 do
	test="Map"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 11, 1 do
	test="Image"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 4, 1 do
	test="UDP"
	updateInput(test,i)
	os.execute(executeFileName)
end
