-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Checks whether the mission can be started from a given scene.
-----------------------------------------------------------------------
function VoidWanderers:IsCompatibleScene(scene)
	return (scene.ClassName == "Scene" and scene.PresetName == "Void Wanderers" and scene.ModuleName == "VoidWanderers.rte");
end
-----------------------------------------------------------------------
-- This starts the whole deal.
-----------------------------------------------------------------------
function VoidWanderers:StartActivity(isNewGame)
	print("VoidWanderers:StartActivity");

	-- TODO: Remove by pre 7, make em figure it out themselves
	-- Change the global metatable
	-- Localize substring function so that we're not indexing any tables in the table indexing handler
	-- Intercept indexes of CF_ anything and route them to the table instead
	local sub = string.sub;
	local mt = {};

	function mt.__index(table, key)
		if sub(key, 1, 3) == "CF_" and CF then
			local key = sub(key, 4, -1);

			--if key == "FactionNatures" then
			--	key = "FactionNatureTypes";
			--end

			if key == "FactionTypes" then
				key = "FactionNatureTypes";
			end

			return rawget(CF, key);
		end

		return rawget(table, key);
	end

	function mt.__newindex(table, key, value)
		if sub(key, 1, 3) == "CF_" and CF then
			rawset(CF, sub(key, 4, -1), value);
			return;
		end

		rawset(table, key, value);
		return;
	end

	setmetatable(_G, mt);

	STATE_CONFIG_FILE = "current.dat";
	
	LIB_PATH = self.ModuleName .. "/Scripts/";
	BASE_PATH = self.ModuleName .. "/Scripts/";

	dofile(LIB_PATH .. "Lib_Generic.lua");
	dofile(LIB_PATH .. "Lib_Config.lua");
	dofile(LIB_PATH .. "Lib_ExtensionsData.lua");
	dofile(LIB_PATH .. "Lib_NewGameData.lua");
	dofile(LIB_PATH .. "Lib_Spawn.lua");
	dofile(LIB_PATH .. "Lib_Storage.lua");
	
	-- Save Load Handler
	self.saveLoadHandler = require("Scripts/Utility/SaveLoadHandler");
	self.saveLoadHandler:Initialize(false);
	
	-- Init a couple properties and constants
	self.FirePressed = {};
	
	self.BuyMenuEnabled = false;

	-- Check delta time and fix it to avoid problems with fonts
	if TimerMan.DeltaTimeMS >= 25 then
		print("Incorrect delta time, fixed");
		TimerMan.DeltaTimeSecs = 0.0166667;
	end

	-- Panel behaviors have to be defined every time because they are methods of this activity
	dofile(LIB_PATH .. "Panel_Clones.lua");
	dofile(LIB_PATH .. "Panel_Ship.lua");
	dofile(LIB_PATH .. "Panel_Beam.lua");
	dofile(LIB_PATH .. "Panel_Storage.lua");
	dofile(LIB_PATH .. "Panel_ItemShop.lua");
	dofile(LIB_PATH .. "Panel_CloneShop.lua");
	dofile(LIB_PATH .. "Panel_LZ.lua");
	dofile(LIB_PATH .. "Panel_Brain.lua");
	dofile(LIB_PATH .. "Panel_Turrets.lua");
	dofile(LIB_PATH .. "Panel_Bombs.lua");

	-- Now that all the libraries and all caps constants are loaded, it should be safe
	-- This function basically boots the game
	CF.InitFactions(self);
	
	-- If this is a new game, IE restart or initial start, then open the correct form and scene
	-- Otherwise, just load the tactics script, we're mid game
	if isNewGame then
		print("VoidWanderers:StartActivity: Detected new game");

		FORM_TO_LOAD = BASE_PATH .. "FormStart.lua";
		self:LaunchScene("Void Wanderers");
		self:LaunchScript("StrategyScreenMain.lua");
	else
		print("VoidWanderers:StartActivity: Detected load game");
		
		self:LoadSaveData();
		dofile(BASE_PATH .. "Tactics.lua");
		self:StartSceneProcess(false);
	end
end
-----------------------------------------------------------------------
-- Scene is case sensitive!
-----------------------------------------------------------------------
function VoidWanderers:LaunchScene(scene)
	print("VoidWanderers:LaunchScene: " .. scene);

	MovableMan:PurgeAllMOs();
	SceneMan:LoadScene(scene, true);

	for actor in MovableMan.AddedActors do
		if actor and actor.ClassName ~= "ADoor" then
			actor.ToDelete = true;
		end
	end
end
-----------------------------------------------------------------------
-- Launches new mission script without leaving current activity.
-----------------------------------------------------------------------
function VoidWanderers:LaunchScript(script)
	print("VoidWanderers:LaunchScript: " .. script);
	
	dofile(BASE_PATH .. script);
	self:StartSceneProcess(true);
end
-----------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------
function VoidWanderers:PauseActivity(pause)
	print("PAUSE! -- VoidWanderers:PauseActivity()!");
end
-----------------------------------------------------------------------
-- End Activity
-----------------------------------------------------------------------
function VoidWanderers:EndActivity()
	print("END! -- VoidWanderers:EndActivity()!");
end
-----------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	if self.sceneToLaunch then
		self:LaunchScene(self.sceneToLaunch);
		self.sceneToLaunch = nil;
	end

	if self.scriptToLaunch then
		self:LaunchScript(self.scriptToLaunch);
		self.scriptToLaunch = nil;
	end
	
	self:UpdateSceneProcess();
end
-----------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------
function VoidWanderers:OnSave()
	print("SAVE! -- VoidWanderers:OnSave()!");

	if self.GS then
		self.saveLoadHandler:SaveTableAsString("gameState", self.GS);
	end

	if self.missionData then
		self.saveLoadHandler:SaveTableAsString("missionData", self.missionData);
	end

	if self.ambientData then
		self.saveLoadHandler:SaveTableAsString("ambientData", self.ambientData);
	end

	if self.encounterData then
		self.saveLoadHandler:SaveTableAsString("encounterData", self.encounterData);
	end

	if self.vesselData then
		self.saveLoadHandler:SaveTableAsString("vesselData", self.vesselData);
	end

	if self.reportData then
		self.saveLoadHandler:SaveTableAsString("reportData", self.reportData);
	end

	local controlledActors = {};

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		controlledActors[#controlledActors + 1] = self:GetControlledActor(player);
	end

	self.saveLoadHandler:SaveTableAsString("controlledActors", controlledActors);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:LoadCurrentGameState()
	if CF.IsFileExists(self.ModuleName, STATE_CONFIG_FILE) then
		self.GS = CF.ReadDataFile("Mods/" .. self.ModuleName .. "/CampaignData/" .. STATE_CONFIG_FILE)

		self.Time = tonumber(self.GS["Time"])

		-- Move ship to tradestar if last location was removed
		if CF.PlanetName[self.GS["Planet"]] == nil then
			--print (self.GS["Location"].." not found. Relocated to tradestar.")

			self.GS["Planet"] = CF.Planet[1]
			self.GS["Location"] = nil
		end

		if self.GS["Difficulty"] then
			CF.Difficulty = tonumber(self.GS["Difficulty"])
		end
		if self.GS["AISkillPlayer"] then
			CF.AISkillPlayer = tonumber(self.GS["AISkillPlayer"])
		end
		if self.GS["AISkillCPU"] then
			CF.AISkillCPU = tonumber(self.GS["AISkillCPU"])
		end

		-- Check missions for missing scenes, if any of them found - recreate missions
		for i = 1, CF.MaxMissions do
			if CF.LocationName[self.GS["Mission" .. i .. "Location"]] == nil then
				CF.GenerateRandomMissions(self.GS)
				break
			end
		end

		-- Create RPG brain values if they are not present
		-- This is needed to update old save files, those values are not created during save-file initialization
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local val = self.GS["Brain" .. player .. "SkillPoints"]
			if val == nil then
				self.GS["Brain" .. player .. "SkillPoints"] = 0
			end

			local val = self.GS["Brain" .. player .. "Exp"]
			if val == nil then
				self.GS["Brain" .. player .. "Exp"] = 0
			end

			local val = self.GS["Brain" .. player .. "Level"]
			if val == nil then
				self.GS["Brain" .. player .. "Level"] = 0
			end

			local val = self.GS["Brain" .. player .. "Toughness"]
			if val == nil then
				self.GS["Brain" .. player .. "Toughness"] = 0
			end

			local val = self.GS["Brain" .. player .. "Field"]
			if val == nil then
				self.GS["Brain" .. player .. "Field"] = 0
			end

			local val = self.GS["Brain" .. player .. "Telekinesis"]
			if val == nil then
				self.GS["Brain" .. player .. "Telekinesis"] = 0
			end

			local val = self.GS["Brain" .. player .. "Scanner"]
			if val == nil then
				self.GS["Brain" .. player .. "Scanner"] = 0
			end

			local val = self.GS["Brain" .. player .. "Heal"]
			if val == nil then
				self.GS["Brain" .. player .. "Heal"] = 0
			end

			local val = self.GS["Brain" .. player .. "SelfHeal"]
			if val == nil then
				self.GS["Brain" .. player .. "SelfHeal"] = 0
			end

			local val = self.GS["Brain" .. player .. "Fix"]
			if val == nil then
				self.GS["Brain" .. player .. "Fix"] = 0
			end

			local val = self.GS["Brain" .. player .. "Fix"]
			if val == nil then
				self.GS["Brain" .. player .. "Fix"] = 0
			end

			local val = self.GS["Brain" .. player .. "Splitter"]
			if val == nil then
				self.GS["Brain" .. player .. "Splitter"] = 0
			end

			local val = self.GS["Brain" .. player .. "QuantumStorage"]
			if val == nil then
				self.GS["Brain" .. player .. "QuantumStorage"] = 0
			end

			local val = self.GS["Brain" .. player .. "QuantumCapacity"]
			if val == nil then
				self.GS["Brain" .. player .. "QuantumCapacity"] = 0
			end
		end

		local arr = CF.GetAvailableQuantumItems(self.GS)
		if #arr == 0 then
			CF.UnlockRandomQuantumItem(self.GS)
		end

		local val = self.GS["PlayerVesselTurrets"]
		if val == nil then
			self.GS["PlayerVesselTurrets"] = CF.VesselStartTurrets[self.GS["PlayerVessel"]]
		end

		local val = self.GS["PlayerVesselTurretStorage"]
		if val == nil then
			self.GS["PlayerVesselTurretStorage"] = CF.VesselStartTurretStorage[self.GS["PlayerVessel"]]
		end

		local val = self.GS["PlayerVesselBombBays"]
		if val == nil then
			self.GS["PlayerVesselBombBays"] = CF.VesselStartBombBays[self.GS["PlayerVessel"]]
		end

		local val = self.GS["PlayerVesselBombStorage"]
		if val == nil then
			self.GS["PlayerVesselBombStorage"] = CF.VesselStartBombStorage[self.GS["PlayerVessel"]]
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SaveCurrentGameState()
	CF.WriteDataFile(self.GS, "Mods/" .. self.ModuleName .. "/CampaignData/" .. STATE_CONFIG_FILE)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:LoadSaveData()
	local gsRead = self.saveLoadHandler:ReadSavedStringAsTable("gameState")
	if next(gsRead) ~= nil then
		self.GS = gsRead

		self.Time = tonumber(self.GS["Time"])

		-- Move ship to tradestar if last location was removed
		if CF.PlanetName[self.GS["Planet"]] == nil then
			--print (self.GS["Location"].." not found. Relocated to tradestar.")

			self.GS["Planet"] = CF.Planet[1]
			self.GS["Location"] = nil
		end

		if self.GS["Difficulty"] then
			CF.Difficulty = tonumber(self.GS["Difficulty"])
		end
		if self.GS["AISkillPlayer"] then
			CF.AISkillPlayer = tonumber(self.GS["AISkillPlayer"])
		end
		if self.GS["AISkillCPU"] then
			CF.AISkillCPU = tonumber(self.GS["AISkillCPU"])
		end

		-- Check missions for missing scenes, if any of them found - recreate missions
		for i = 1, CF.MaxMissions do
			if CF.LocationName[self.GS["Mission" .. i .. "Location"]] == nil then
				CF.GenerateRandomMissions(self.GS)
				break
			end
		end

		-- Create RPG brain values if they are not present
		-- This is needed to update old save files, those values are not created during save-file initialization
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local val = self.GS["Brain" .. player .. "SkillPoints"]
			if val == nil then
				self.GS["Brain" .. player .. "SkillPoints"] = 0
			end

			local val = self.GS["Brain" .. player .. "Exp"]
			if val == nil then
				self.GS["Brain" .. player .. "Exp"] = 0
			end

			local val = self.GS["Brain" .. player .. "Level"]
			if val == nil then
				self.GS["Brain" .. player .. "Level"] = 0
			end

			local val = self.GS["Brain" .. player .. "Toughness"]
			if val == nil then
				self.GS["Brain" .. player .. "Toughness"] = 0
			end

			local val = self.GS["Brain" .. player .. "Field"]
			if val == nil then
				self.GS["Brain" .. player .. "Field"] = 0
			end

			local val = self.GS["Brain" .. player .. "Telekinesis"]
			if val == nil then
				self.GS["Brain" .. player .. "Telekinesis"] = 0
			end

			local val = self.GS["Brain" .. player .. "Scanner"]
			if val == nil then
				self.GS["Brain" .. player .. "Scanner"] = 0
			end

			local val = self.GS["Brain" .. player .. "Heal"]
			if val == nil then
				self.GS["Brain" .. player .. "Heal"] = 0
			end

			local val = self.GS["Brain" .. player .. "SelfHeal"]
			if val == nil then
				self.GS["Brain" .. player .. "SelfHeal"] = 0
			end

			local val = self.GS["Brain" .. player .. "Fix"]
			if val == nil then
				self.GS["Brain" .. player .. "Fix"] = 0
			end

			local val = self.GS["Brain" .. player .. "Fix"]
			if val == nil then
				self.GS["Brain" .. player .. "Fix"] = 0
			end

			local val = self.GS["Brain" .. player .. "Splitter"]
			if val == nil then
				self.GS["Brain" .. player .. "Splitter"] = 0
			end

			local val = self.GS["Brain" .. player .. "QuantumStorage"]
			if val == nil then
				self.GS["Brain" .. player .. "QuantumStorage"] = 0
			end

			local val = self.GS["Brain" .. player .. "QuantumCapacity"]
			if val == nil then
				self.GS["Brain" .. player .. "QuantumCapacity"] = 0
			end
		end

		local arr = CF.GetAvailableQuantumItems(self.GS)
		if #arr == 0 then
			CF.UnlockRandomQuantumItem(self.GS)
		end

		local val = self.GS["PlayerVesselTurrets"]
		if val == nil then
			self.GS["PlayerVesselTurrets"] = CF.VesselStartTurrets[self.GS["PlayerVessel"]]
		end

		local val = self.GS["PlayerVesselTurretStorage"]
		if val == nil then
			self.GS["PlayerVesselTurretStorage"] = CF.VesselStartTurretStorage[self.GS["PlayerVessel"]]
		end

		local val = self.GS["PlayerVesselBombBays"]
		if val == nil then
			self.GS["PlayerVesselBombBays"] = CF.VesselStartBombBays[self.GS["PlayerVessel"]]
		end

		local val = self.GS["PlayerVesselBombStorage"]
		if val == nil then
			self.GS["PlayerVesselBombStorage"] = CF.VesselStartBombStorage[self.GS["PlayerVessel"]]
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
