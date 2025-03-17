-----------------------------------------------------------------------------
-- Returns trimmed string
-----------------------------------------------------------------------------
CF["StringTrim"] = function(s)
	return s:gsub("^%s+", ""):gsub("%s+$", "")
end
-----------------------------------------------------------------------------
-- Returns true if string ends with 'End'
-----------------------------------------------------------------------------
CF["StringEnds"] = function(String, End)
	return End == "" or string.sub(String, -string.len(End)) == End
end
-----------------------------------------------------------------------------
-- Read data from file line by line and return the list
-----------------------------------------------------------------------------
CF["ReadFactionsList"] = function(filename, defaultpath)
	print("VoidWanderers::CF['ReadFactionsList']")
	local config = {}

	local fileid = LuaMan:FileOpen(filename, "r")

	while not LuaMan:FileEOF(fileid) do
		local line = LuaMan:FileReadLine(fileid)
		local s = string.gsub(line, "\n", "")
		s = string.gsub(s, "\r", "")

		local enabled = false

		if string.find(s, "*") == nil then
			enabled = true
		end

		if enabled then
			if CF["StringEnds"](s, ".rte") then
				local file = string.sub(s, 1, #s - 4)
				local path = s .. "/FactionFiles/" .. file .. ".lua"

				if PresetMan:GetModuleID(s) > -1 then
					if CF["IsFilePathExists"](path) then
						-- Add found .lua file if it exists
						config[#config + 1] = path
					else
						-- Check support folder for special cases popular mods
						-- if lua file don't exist
						local supportpath = "VoidWanderers.rte/Support/" .. file .. ".lua"
						if CF["IsFilePathExists"](supportpath) then
							print("SUPPORT " .. supportpath .. " FOUND, EXECUTING")
							local paths
							f = loadfile(supportpath)
							if f ~= nil then
								paths = f()

								if paths ~= nil then
									for i = 1, #paths do
										config[#config + 1] = paths[i]
									end
								end
							else
								print("ERR: CAN'T LOAD " .. supportpath .. " SUPPORT, FACTIONS DISABLED")
							end
						else
							print("ERR: FILE " .. path .. " NOT FOUND, FACTION NOT AUTOLOADED")
						end
					end
				else
					print("MSG: MODULE " .. s .. " NOT LOADED, FACTION NOT AUTOLOADED")
				end
			else
				config[#config + 1] = defaultpath .. s
			end
		end
	end

	LuaMan:FileClose(fileid)

	return config
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["ReadExtensionsList"] = function(filename, defaultpath)
	print("VoidWanderers::CF['ReadExtensionsList']")
	local config = {}

	local fileid = LuaMan:FileOpen(filename, "r")

	while not LuaMan:FileEOF(fileid) do
		line = LuaMan:FileReadLine(fileid)
		s = string.gsub(line, "\n", "")
		s = string.gsub(s, "\r", "")

		local enabled = false

		if string.find(s, "*") == nil then
			enabled = true
		end

		if enabled then
			if CF["StringEnds"](s, ".rte") then
				--local fileName = string.sub(s, 1, #s - 4)
				local supportpath = s .. "/Support/VoidWanderers.lua"
				if CF["IsFilePathExists"](supportpath) then
					print("EXTENSION SUPPORT " .. supportpath .. " FOUND, EXECUTING")
					local paths
					f = loadfile(supportpath)
					if f ~= nil then
						paths = f()

						if paths ~= nil then
							for i = 1, #paths do
								config[#config + 1] = paths[i]
							end
						end
					else
						print("ERR: CAN'T LOAD " .. supportpath .. " SUPPORT, EXTENSIONS DISABLED")
					end
				else
					print("ERR: FILE " .. supportpath .. " NOT FOUND, EXTENSION NOT AUTOLOADED")
				end
			else
				config[#config + 1] = defaultpath .. s
			end
		end
	end

	LuaMan:FileClose(fileid)

	--for i = 1, #config do
	--	print (config[i])
	--end

	return config
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["ParseLine"] = function(s)
	local pos1, pos2

	pos = string.find(s, "=")

	if pos ~= nil then
		local param, value

		s = string.gsub(s, "\n", "")
		s = string.gsub(s, "\r", "")
		param = string.sub(s, 1, pos - 1)
		value = string.sub(s, pos + 1, string.len(s))

		return param, value
	else
		return nil
	end
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["ReadConfigFile"] = function(modulename, filename)
	local config = {}

	local f = LuaMan:FileOpen("Mods/" .. modulename .. "/CampaignData/" .. filename, "r")

	while not LuaMan:FileEOF(f) do
		line = LuaMan:FileReadLine(f)
		local param, value

		param, value = CF["ParseLine"](line)
		if param ~= nil then
			config[param] = value
		end
	end

	LuaMan:FileClose(f)

	return config
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["ReadSceneConfigFile"] = function(modulename, filename)
	local config = {}

	local filepath = nil
	if CF["IsFilePathExists"]("Mods/" .. modulename .. "/Scenes/Data/" .. filename) then
		filepath = modulename .. "/Scenes/Data/" .. filename
	elseif CF["IsFilePathExists"]("Mods/" .. CF["ModuleName"] .. "/Scenes/Data/" .. filename) then
		filepath = CF["ModuleName"] .. "/Scenes/Data/" .. filename
	end
	if filepath then
		local f = LuaMan:FileOpen(filepath, "r")

		while not LuaMan:FileEOF(f) do
			line = LuaMan:FileReadLine(f)
			local param, value

			param, value = CF["ParseLine"](line)
			if param ~= nil then
				config[param] = value
			end
		end
		LuaMan:FileClose(f)
	end

	return config
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["WriteSceneConfigFile"] = function(config, modulename, filename)
	local file = LuaMan:FileOpen(modulename .. "/Scenes/Data/" .. filename, "w")

	local sorted = CF["GetSortedListFromTable"](config)

	for i = 1, #sorted do
		LuaMan:FileWriteLine(file, tostring(sorted[i]["Key"]) .. "=" .. tostring(sorted[i]["Value"]) .. "\n")
	end

	LuaMan:FileClose(file)
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["WriteConfigFile"] = function(config, modulename, filename)
	local file = LuaMan:FileOpen(modulename .. "/CampaignData/" .. filename, "w")
	local sorted = CF["GetSortedListFromTable"](config)

	for i = 1, #sorted do
		LuaMan:FileWriteLine(file, tostring(sorted[i]["Key"]) .. "=" .. tostring(sorted[i]["Value"]) .. "\n")
	end

	LuaMan:FileClose(file)
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetSortedListFromTable"] = function(arr)
	local newarr = {}

	for key, value in pairs(arr) do
		local i = #newarr + 1
		newarr[i] = {}
		newarr[i]["Key"] = key
		newarr[i]["Value"] = value
	end

	for i = 1, #newarr do
		for j = 1, #newarr - 1 do
			if newarr[j]["Key"] > newarr[j + 1]["Key"] then
				local tmp = newarr[j]
				newarr[j] = newarr[j + 1]
				newarr[j + 1] = tmp
			end
		end
	end

	return newarr
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["DeleteCurrentConfig"] = function(modulename)
	local file = LuaMan:FileOpen(modulename .. "/CampaignData/current.dat", "w")

	for i, line in pairs(config) do
		LuaMan:WriteLine(file, tostring(i) .. "=" .. tostring(line) .. "\n")
	end

	LuaMan:FileClose(file)
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["IsFileExists"] = function(modulename, filename)
	return LuaMan:FileExists(modulename .. "/CampaignData/" .. filename)
	--[[ Old method:
	local file = LuaMan:FileOpen(modulename.."/CampaignData/"..filename , "r")
	
	if file == -1 then
		return false
	end
	
	LuaMan:FileClose(file)
	return true
	]]
	--
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["IsFilePathExists"] = function(path)
	return LuaMan:FileExists(path)
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetCharPixelWidth"] = function(char)
	local ChrLen = {}
	local n = nil

	ChrLen["1"] = 4
	ChrLen[" "] = 3
	ChrLen["!"] = 3
	ChrLen[","] = 3
	ChrLen["."] = 3

	ChrLen["f"] = 5
	ChrLen["i"] = 3
	ChrLen["j"] = 4
	ChrLen["l"] = 3
	ChrLen["m"] = 8
	ChrLen["t"] = 5
	ChrLen["w"] = 8

	ChrLen["I"] = 3
	ChrLen["M"] = 8
	ChrLen["T"] = 5
	ChrLen["W"] = 8

	--print(char)

	n = ChrLen[char]

	--print (n)

	if n == nil then
		n = 6
	end

	return n
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetStringPixelWidth"] = function(str)
	local len = 0
	for i = 1, #str do
		len = len + CF["GetCharPixelWidth"](string.sub(str, i, i))
	end
	return len
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
