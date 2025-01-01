return function(offsetX, offsetY, input, output)
	local center = { X = offsetX, Y = offsetY };
	input = LuaMan:FileOpen(input, "r");
	output = LuaMan:FileOpen(output, "w");
	
	if input and output then
		while not LuaMan:FileEOF(input) do
			local line = LuaMan:FileReadLine(input);
			
			if line:find("\t\t\tX = ") then
				local x = tonumber(line:sub(line:find("X = ") + 4, -2));
				print(x);
				print(tostring(x - center.X));
				LuaMan:FileWriteLine(output, line:sub(1, line:find("X = ") + 3) .. tostring(x - center.X) .. line:sub(-1));
			elseif line:find("\t\t\tY = ") then
				local y = tonumber(line:sub(line:find("Y = ") + 4, -2));
				print(y);
				print(tostring(y - center.Y));
				LuaMan:FileWriteLine(output, line:sub(1, line:find("Y = ") + 3) .. tostring(y - center.Y) .. line:sub(-1));
			else
				LuaMan:FileWriteLine(output, line);
			end
		end
	end
	
	if input then
		LuaMan:FileClose(input);
	end

	if output then
		LuaMan:FileClose(output);
	end
end