-----------------------------------------------------------------------
-- Returns trimmed string
-----------------------------------------------------------------------
function CF.StringTrim(s)
	return s:gsub("^%s+", ""):gsub("%s+$", "");
end
-----------------------------------------------------------------------
-- Returns true if string ends with 'End'
-----------------------------------------------------------------------
function CF.StringEnds(String, End)
	return End == "" or string.sub(String, -string.len(End)) == End;
end
-----------------------------------------------------------------------
-- Read data from file line by line and return the list
-----------------------------------------------------------------------
function CF.ReadFactionsList(filename, defaultpath)
	print("VoidWanderers::CF['ReadFactionsList']");
	local config = {};
	local fileid = LuaMan:FileOpen(filename, "r");

	while not LuaMan:FileEOF(fileid) do
		local line = LuaMan:FileReadLine(fileid);
		local s = string.gsub(line, "\n", "");
		s = string.gsub(s, "\r", "");
		local enabled = false;

		if string.find(s, "*") == nil then
			enabled = true;
		end

		if enabled then
			if CF.StringEnds(s, ".rte") then
				local file = string.sub(s, 1, #s - 4);
				local path = s .. "/FactionFiles/" .. file .. ".lua";

				if PresetMan:GetModuleID(s) > -1 then
					if LuaMan:FileExists(path) then
						config[#config + 1] = path;
					else
						local supportpath = "VoidWanderers.rte/Support/" .. file .. ".lua";

						if LuaMan:FileExists(supportpath) then
							print("SUPPORT " .. supportpath .. " FOUND, EXECUTING");
							local paths;
							f = loadfile(supportpath);

							if f ~= nil then
								paths = f();

								if paths ~= nil then
									for i = 1, #paths do
										config[#config + 1] = paths[i];
									end
								end
							else
								print("ERR: CAN'T LOAD " .. supportpath .. " SUPPORT, FACTIONS DISABLED");
							end
						else
							print("ERR: FILE " .. path .. " NOT FOUND, FACTION NOT AUTOLOADED");
						end
					end
				else
					print("MSG: MODULE " .. s .. " NOT LOADED, FACTION NOT AUTOLOADED");
				end
			else
				config[#config + 1] = defaultpath .. s;
			end
		end
	end
	
	LuaMan:FileClose(fileid);
	return config;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.ReadExtensionsList(filename, defaultpath)
	print("VoidWanderers::CF['ReadExtensionsList']");
	local config = {};
	local fileid = LuaMan:FileOpen(filename, "r");

	while not LuaMan:FileEOF(fileid) do
		line = LuaMan:FileReadLine(fileid);
		local s = string.gsub(line, "\n", "");
		s = string.gsub(s, "\r", "");
		local enabled = false;

		if string.find(s, "*") == nil then
			enabled = true;
		end

		if enabled then
			if CF.StringEnds(s, ".rte") then
				local supportpath = s .. "/Support/VoidWanderers.lua";

				if LuaMan:FileExists(supportpath) then
					print("EXTENSION SUPPORT " .. supportpath .. " FOUND, EXECUTING");
					local paths;
					f = loadfile(supportpath);

					if f ~= nil then
						paths = f();

						if paths ~= nil then
							for i = 1, #paths do
								config[#config + 1] = paths[i];
							end
						end
					else
						print("ERR: CAN'T LOAD " .. supportpath .. " SUPPORT, EXTENSIONS DISABLED");
					end
				else
					print("ERR: FILE " .. supportpath .. " NOT FOUND, EXTENSION NOT AUTOLOADED");
				end
			else
				config[#config + 1] = defaultpath .. s;
			end
		end
	end

	LuaMan:FileClose(fileid);
	return config;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.ParseLine(s)
	local pos1, pos2;
	pos = string.find(s, "=");

	if pos ~= nil then
		local param, value;
		s = string.gsub(s, "\n", "");
		s = string.gsub(s, "\r", "");
		param = string.sub(s, 1, pos - 1);
		value = string.sub(s, pos + 1, string.len(s));
		return param, value;
	else
		return nil;
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.ReadDataFile(filePath)
	local config = nil;

	if LuaMan:FileExists(filePath) then
		config = {};
		local file = LuaMan:FileOpen(filePath, "r");

		while not LuaMan:FileEOF(file) do
			local param, value = CF.ParseLine(LuaMan:FileReadLine(file));

			if param then
				config[param] = value;
			end
		end

		LuaMan:FileClose(file);
	end

	return config;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.WriteDataFile(gameState, filePath)
	local file = LuaMan:FileOpen(filePath, "w");
	local sorted = CF.GetSortedListFromTable(gameState);

	for i = 1, #sorted do
		LuaMan:FileWriteLine(file, tostring(sorted[i].Key) .. "=" .. tostring(sorted[i].Value) .. "\n");
	end

	return LuaMan:FileClose(file);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.UpdateGameState(gameState)
	if CF.PlanetName[gameState["Planet"]] == nil then
		gameState["Planet"] = CF.Planet[1];
		gameState["Location"] = nil;
	end

	for i = 1, CF.MaxMissions do
		if CF.LocationName[gameState["Mission" .. i .. "Location"]] == nil then
			CF.GenerateRandomMissions(gameState);
			break;
		end
	end

	local brainDataIndices = {
		"SkillPoints", "Level", "Toughness",
		"Field", "Telekinesis", "Scanner",
		"Heal", "SelfHeal", "Fix",
		"Splitter", "QuantumStorage", "QuantumCapacity",
		"Exp",
	};

	for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
		for index, brainDataName in ipairs(brainDataIndices) do
			local dataName = "Brain" .. player .. brainDataName;
			gameState[dataName] = gameState[dataName] or 0;
		end
	end

	if #CF.GetAvailableQuantumItems(gameState) == 0 then
		CF.UnlockRandomQuantumItems(gameState);
	end

	for i = 1, CF.MaxMissionReportLines do
		local report = gameState["MissionReport" .. i];
						
		if not report then
			break;
		end

		if string.find(report, "Completion streak") then
			gameState["MissionReport" .. i] = "Completion streak: 0";
			break;
		end
	end

	gameState["PlayerVesselTurrets"] = gameState["PlayerVesselTurrets"] or CF.VesselStartTurrets[gameState["PlayerVessel"]];
	gameState["PlayerVesselTurretStorage"] = gameState["PlayerVesselTurretStorage"] or CF.VesselStartTurretStorage[gameState["PlayerVessel"]];
	gameState["PlayerVesselBombBays"] = gameState["PlayerVesselBombBays"] or CF.VesselStartBombBays[gameState["PlayerVessel"]];
	gameState["PlayerVesselBombStorage"] = gameState["PlayerVesselBombStorage"] or CF.VesselStartBombStorage[gameState["PlayerVessel"]];
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetSortedListFromTable(arr)
	local newArray = {};

	for key, value in pairs(arr) do
		table.insert(newArray, {
			Key = key,
			Value = value,
		})
	end

	for i = 1, #newArray do
		for j = 1, #newArray - 1 do
			if newArray[j].Key > newArray[j + 1].Key then
				table.insert(newArray, j + 1, table.remove(newArray, j));
			end
		end
	end

	return newArray;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.DeleteConfig(filename)
	local file = LuaMan:FileOpen(filename);
	return LuaMan:FileClose(file);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.IsFileExists(filename)
	return LuaMan:FileExists(filename);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
