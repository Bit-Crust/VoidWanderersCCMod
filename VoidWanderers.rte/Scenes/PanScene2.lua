-- A simple and dumb script that moves all objects and areas of the scene.
-- Script arguments
-- Input scene file
local input = "_VoidWanderers Vessel Gryphon.ini"
-- Resulting scene file. Those CAN NOT be the same. If they're the same original file MAY BE LOST!
local output = "VoidWanderers Vessel Gryphon.ini"
-- How many blocks to move horizontally. 1 block = 12px. Positive values move to the right, negative
-- to the left
local blocksx = 100
-- How many blocks to move vaertically. Positive values move upwards, negative downwards
local blocksy = 40
-- Width of scene
local swidth = 2592

-- END OF USER SERVICEABLE PART!!!

io = require("io")

local f = io.open(output, "w")

local px = blocksx * 12
local py = blocksy * 12

local prevstring = ""
local prevprevstring = ""

for line in io.lines(input) do
	local pos
	local num

	local tochangex = false
	local tochangey = false

	if string.find(prevstring, "Position = Vector") ~= nil or string.find(prevstring, "Corner = Vector") ~= nil then
		tochangex = true
	end

	if
		string.find(prevprevstring, "Position = Vector") ~= nil
		or string.find(prevprevstring, "Corner = Vector") ~= nil
	then
		tochangey = true
	end

	if tochangex then
		pos = string.find(line, "\tX = ")
		if pos ~= nil then
			num = tonumber(string.sub(line, pos + 5, #line))
			num = num + px

			if num > swidth then
				num = num - swidth
			end

			if num < 0 then
				num = swidth - num
			end

			line = string.sub(line, 1, pos + 4) .. tostring(num)
		end
	end

	if tochangey then
		pos = string.find(line, "\tY = ")
		if pos ~= nil then
			num = tonumber(string.sub(line, pos + 5, #line))
			num = num + py
			line = string.sub(line, 1, pos + 4) .. tostring(num)
		end
	end

	prevprevstring = prevstring
	prevstring = line

	f:write(line .. "\n")
end

f:close()
