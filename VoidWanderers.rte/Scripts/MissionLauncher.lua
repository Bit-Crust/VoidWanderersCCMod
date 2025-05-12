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
	
	self.BuyMenuEnabled = false;

	-- TODO: Remove by pre 7, make em figure it out themselves
	-- Localize substring function so it isn't taken from the global table
	local sub = string.sub;
	
	-- Intercept indexes of CF_ anything and route them to the table instead
	setmetatable(_G, {
		__index = function(table, key)
			if sub(key, 1, 3) == "CF_" and CF then
				key = sub(key, 4, -1);

				if key == "FactionTypes" then
					key = "FactionNatureTypes";
				end

				return rawget(CF, key);
			end

			return rawget(table, key);
		end,
		__newindex = function(table, key, value)
			if sub(key, 1, 3) == "CF_" and CF then
				rawset(CF, sub(key, 4, -1), value);
				return;
			end

			rawset(table, key, value);
			return;
		end,
	});
	
	-- Save Load Handler
	self.saveLoadHandler = require("Scripts/Utility/SaveLoadHandler");
	self.saveLoadHandler:Initialize(false);
	
	-- Init a couple properties and constants
	self.firePressed = {};

	-- Check delta time and fix it to avoid problems with fonts
	-- this maddens me
	if TimerMan.DeltaTimeMS >= 25 then
		print("Incorrect delta time, fixed");
		TimerMan.DeltaTimeSecs = 0.0166667;
	end

	self.stateConfigFileName = "current.dat";
	self.basePath = self.ModuleName .. "/Scripts/";
	self.libPath = self.basePath .. "/Library/";
	self.panelPath = self.basePath .. "/Panels/";
	self.formPath = self.basePath .. "/Forms/";
	
	-- Panel behaviors have to be defined every time because they are methods of this activity
	-- The config libraries are also loaded every time to overwrite old versions of functions
	dofile(self.libPath .. "Lib_Generic.lua");
	dofile(self.libPath .. "Lib_Config.lua");
	dofile(self.libPath .. "Lib_Spawn.lua");
	dofile(self.libPath .. "Lib_Storage.lua");
	dofile(self.panelPath .. "Panel_Clones.lua");
	dofile(self.panelPath .. "Panel_Ship.lua");
	dofile(self.panelPath .. "Panel_Beam.lua");
	dofile(self.panelPath .. "Panel_Storage.lua");
	dofile(self.panelPath .. "Panel_ItemShop.lua");
	dofile(self.panelPath .. "Panel_CloneShop.lua");
	dofile(self.panelPath .. "Panel_LZ.lua");
	dofile(self.panelPath .. "Panel_Brain.lua");
	dofile(self.panelPath .. "Panel_Turrets.lua");
	dofile(self.panelPath .. "Panel_Bombs.lua");

	-- Now that all the libraries and all caps constants are loaded, it should be safe
	-- This function basically boots the game
	CF.InitFactions(self);
	
	-- If this is a new game, IE restart or initial start, then open the correct form and scene
	-- Otherwise, just load the tactics script, we're mid game
	if isNewGame then
		print("VoidWanderers:StartActivity: Detected new game");
		self.formToLoad = "FormStart.lua";

		self.sceneToLaunch = "Void Wanderers";
		self.scriptToLaunch = "StrategyScreenMain.lua";
	else
		print("VoidWanderers:StartActivity: Detected load game");
		self:loadSaveData();
		
		self.sceneToLaunch = self.GS["Scene"];
		self.scriptToLaunch = "Tactics.lua";
	end
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
	local deploymentToSerialize = self.deploymentToSerialize;
	
	if deploymentToSerialize then
		CF.ClearDeployed(self.GS);
		self.deployedActors = {};
		local returningUnits = 0;

		for _, actor in ipairs(deploymentToSerialize) do
			if actor and actor.Team == CF.PlayerTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				returningUnits = returningUnits + 1;
				self.GS["Deployed" .. returningUnits .. "Preset"] = actor.PresetName;
				self.GS["Deployed" .. returningUnits .. "Class"] = actor.ClassName;
				self.GS["Deployed" .. returningUnits .. "Module"] = actor.ModuleName;
				self.GS["Deployed" .. returningUnits .. "XP"] = actor:GetNumberValue("VW_XP");
				self.GS["Deployed" .. returningUnits .. "Identity"] = actor:GetNumberValue("Identity");
				self.GS["Deployed" .. returningUnits .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer");
				self.GS["Deployed" .. returningUnits .. "Prestige"] = actor:GetNumberValue("VW_Prestige");
				self.GS["Deployed" .. returningUnits .. "Name"] = actor:GetStringValue("VW_Name");
				
				for _, limbName in ipairs(CF.LimbIDs[actor.ClassName]) do
					self.GS["Deployed" .. returningUnits .. limbName] = CF.GetLimbData(actor, limbName);
				end

				local pre, cls, mdl = CF.GetInventory(actor);
				self.GS["Deployed" .. returningUnits .. "Item#"] = #pre;

				for j = 1, #pre do
					self.GS["Deployed" .. returningUnits .. "Item" .. j .. "Preset"] = pre[j];
					self.GS["Deployed" .. returningUnits .. "Item" .. j .. "Class"] = cls[j];
					self.GS["Deployed" .. returningUnits .. "Item" .. j .. "Module"] = mdl[j];
				end

				self.deployedActors[returningUnits] = actor:Clone();
			end
		end

		self.GS["Deployed#"] = returningUnits;
		self.deploymentToSerialize = nil;
	end

	local onboardToSerialize = self.onboardToSerialize;

	if onboardToSerialize then
		CF.ClearOnboard(self.GS);
		local returningUnits = 0;

		for _, actor in ipairs(onboardToSerialize) do
			if actor.Team == CF.PlayerTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				returningUnits = returningUnits + 1;
				self.GS["Onboard" .. returningUnits .. "Preset"] = actor.PresetName;
				self.GS["Onboard" .. returningUnits .. "Class"] = actor.ClassName;
				self.GS["Onboard" .. returningUnits .. "Module"] = actor.ModuleName;
				self.GS["Onboard" .. returningUnits .. "XP"] = actor:GetNumberValue("VW_XP");
				self.GS["Onboard" .. returningUnits .. "Identity"] = actor:GetNumberValue("Identity");
				self.GS["Onboard" .. returningUnits .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer");
				self.GS["Onboard" .. returningUnits .. "Prestige"] = actor:GetNumberValue("VW_Prestige");
				self.GS["Onboard" .. returningUnits .. "Name"] = actor:GetStringValue("VW_Name");
				self.GS["Onboard" .. returningUnits .. "X"] = actor.Pos.X;
				self.GS["Onboard" .. returningUnits .. "Y"] = actor.Pos.Y;
				
				for _, limbName in ipairs(CF.LimbIDs[actor.ClassName]) do
					self.GS["Onboard" .. returningUnits .. limbName] = CF.GetLimbData(actor, limbName);
				end

				local pre, cls, mdl = CF.GetInventory(actor);
				self.GS["Onboard" .. returningUnits .. "Item#"] = #pre;

				for j = 1, #pre do
					self.GS["Onboard" .. returningUnits .. "Item" .. j .. "Preset"] = pre[j];
					self.GS["Onboard" .. returningUnits .. "Item" .. j .. "Class"] = cls[j];
					self.GS["Onboard" .. returningUnits .. "Item" .. j .. "Module"] = mdl[j];
				end
			end
		end

		self.GS["Onboard#"] = returningUnits;
		self.onboardToSerialize = nil;
	end

	if self.cacheCurrentGameState then
		self:saveCurrentGameState();
		self.cacheCurrentGameState = false;
	end
	
	if self.sceneToLaunch then
		self:launchScene(self.sceneToLaunch);
		self.sceneToLaunch = nil;
	end

	if self.scriptToLaunch then
		self:launchScript(self.scriptToLaunch);
		self.scriptToLaunch = nil;
	end

	if self.formToLoad then
		self:loadForm(self.formToLoad);
		self.formToLoad = nil;
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
-- Scene is case sensitive!
-----------------------------------------------------------------------
function VoidWanderers:launchScene(scene)
	print("VoidWanderers:launchScene: " .. scene);

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
function VoidWanderers:launchScript(script)
	print("VoidWanderers:launchScript: " .. script);

	local processClose = self.CloseSceneProcess;

	if processClose then
		processClose(self);
	end
	
	dofile(self.basePath .. script);
	self:StartSceneProcess(true);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:loadForm(formToLoad)
	if self.form then
		self.form:Close(self, self);
	end

	self.form = dofile(self.formPath .. formToLoad);
	self.ui = self.form:Load(self, self);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:loadCurrentGameState()
	if CF.IsFileExists(self.ModuleName, self.stateConfigFileName) then
		self.GS = CF.ReadDataFile("Mods/" .. self.ModuleName .. "/CampaignData/" .. self.stateConfigFileName)

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
function VoidWanderers:saveCurrentGameState()
	CF.WriteDataFile(self.GS, "Mods/" .. self.ModuleName .. "/CampaignData/" .. self.stateConfigFileName)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:loadSaveData()
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
function VoidWanderers:makeFreshGameState(playerFaction, cpus)
	local gameState = {};
	gameState["Time"] = tostring(0);
	gameState["Difficulty"] = self.Difficulty;
	gameState["FogOfWar"] = self:GetFogOfWarEnabled() and "True" or "False";
	gameState["AISkillPlayer"] = tostring(self:GetTeamAISkill(Activity.TEAM_1));
	gameState["AISkillCPU"] = tostring(self:GetTeamAISkill(Activity.TEAM_2));
	gameState["PlayerGold"] = tostring(math.floor(self:GetStartingGold()));
	gameState["PlayerFaction"] = playerFaction;
	gameState["Planet"] = tostring(CF.Planet[1]);
	gameState["Location"] = tostring(CF.Location[1]);

	local locpos = CF.LocationPos[gameState["Location"]];
	gameState["ShipX"] = tostring(locpos.X);
	gameState["ShipY"] = tostring(locpos.Y);

	-- Set vessel attributes
	local vessel = self.Difficulty == GameActivity.MAXDIFFICULTY and "Mule" or "Lynx";
	gameState["PlayerVesselStorageCapacity"] = tostring(CF.VesselStartStorageCapacity[vessel]);
	gameState["PlayerVesselClonesCapacity"] = tostring(CF.VesselStartClonesCapacity[vessel]);
	gameState["PlayerVesselLifeSupport"] = tostring(CF.VesselStartLifeSupport[vessel]);
	gameState["PlayerVesselCommunication"] = tostring(CF.VesselStartCommunication[vessel]);
	gameState["PlayerVesselSpeed"] = tostring(CF.VesselStartSpeed[vessel]);
	gameState["PlayerVesselTurrets"] = tostring(CF.VesselStartTurrets[vessel]);
	gameState["PlayerVesselTurretStorage"] = tostring(CF.VesselStartTurretStorage[vessel]);
	gameState["PlayerVesselBombBays"] = tostring(CF.VesselStartBombBays[vessel]);
	gameState["PlayerVesselBombStorage"] = tostring(CF.VesselStartBombStorage[vessel]);
	gameState["PlayerVessel"] = vessel;

	gameState["Scene"] = CF.VesselScene[gameState["PlayerVessel"]];
	gameState["Mode"] = "Vessel";

	-- Difficulty related variables
	if self.Difficulty <= GameActivity.CAKEDIFFICULTY then
		gameState["MissionDifficultyBonus"] = -2;
	elseif self.Difficulty <= GameActivity.EASYDIFFICULTY then
		gameState["MissionDifficultyBonus"] = -1;
	elseif self.Difficulty <= GameActivity.MEDIUMDIFFICULTY then
		gameState["MissionDifficultyBonus"] = -0;
	elseif self.Difficulty <= GameActivity.HARDDIFFICULTY then
		gameState["MissionDifficultyBonus"] = 1;
	elseif self.Difficulty <= GameActivity.NUTSDIFFICULTY then
		gameState["MissionDifficultyBonus"] = 2;
	else
		gameState["MissionDifficultyBonus"] = 3;
	end

	local activecpus = 0;

	for i = 1, CF.MaxCPUPlayers do
		local cpu = cpus[i];
		
		if cpu then
			gameState["Player" .. i .. "Faction"] = cpu;
			gameState["Player" .. i .. "Active"] = "True";
			gameState["Player" .. i .. "Type"] = "CPU";

			if cpu == playerFaction then
				gameState["Player" .. i .. "Reputation"] = 500;
			else
				computedReputation = 0;

				if CF.FactionNatures[playerFaction] ~= CF.FactionNatures[cpu] then
					computedReputation = computedReputation + CF.ReputationHuntThreshold * (self.Difficulty / 100);
				end

				if CF.FactionAlignments[playerFaction] ~= CF.FactionAlignments[cpu] then
					computedReputation = computedReputation + CF.ReputationHuntThreshold * (self.Difficulty / 100);
				end

				if CF.FactionIngroupPreference[cpu] then
					computedReputation = computedReputation + CF.ReputationHuntThreshold * (self.Difficulty / 100) * 2;
				end

				gameState["Player" .. i .. "Reputation"] = math.floor(computedReputation * (0.9 + 0.2 * math.random()));
			end

			activecpus = activecpus + 1;
		end
	end

	gameState["ActiveCPUs"] = activecpus;

	CF.GenerateRandomMissions(gameState);

	local repBudget = 800;
	local playerFaction = CF.GetPlayerFaction(gameState, 1);

	local pistols = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.PISTOL, repBudget);
	local rifles = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.RIFLE, repBudget * 2);
	local shotguns = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.SHOTGUN, repBudget * 2);
	local snipers = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.SNIPER, repBudget * 2);
	local shields = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.SHIELD, repBudget);
	local diggers = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.DIGGER, repBudget * 0);
	local grenades = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.GRENADE, repBudget);

	local actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "AHuman", repBudget * 2);

	if not actors then
		-- Pricy humans, alright.
		actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "AHuman", math.huge);

		if not actors then
			-- No humans? That's cool...
			actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "ACrab", math.huge);

			if not actors then
				-- No limbed actors??? That's hip!
				actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "Any", math.huge);
			end
		end
	end

	-- Assign initial player actors in storage
	local cloneCapacity = tonumber(gameState["PlayerVesselClonesCapacity"]);
	local actorPrefix = "ClonesStorage";

	if cloneCapacity <= 0 then
		actorPrefix = "Actor";
		-- TODO make them spawn, obviously
	end

	if actorPrefix == "Actor" or cloneCapacity < 4 then
		cloneCapacity = 4;
	end

	for i = 1, cloneCapacity do
		local chosenActor = actors[math.random(#actors)];
		gameState[actorPrefix .. i .. "Preset"] = CF.ActPresets[playerFaction][chosenActor["Actor"]];
		gameState[actorPrefix .. i .. "Class"] = CF.ActClasses[playerFaction][chosenActor["Actor"]];
		gameState[actorPrefix .. i .. "Module"] = CF.ActModules[playerFaction][chosenActor["Actor"]];
		gameState[actorPrefix .. i .. "Identity"] = i - 1;

		local item = nil;
		local slt = 1;
		local list = nil;
		local count = 1;

		::insert::
		if list then
			if count <= 1 then
				item = list[math.random(#list)];
				gameState[actorPrefix .. i .. "Item" .. slt .. "Preset"] = CF.ItmPresets[playerFaction][item["Item"]];
				gameState[actorPrefix .. i .. "Item" .. slt .. "Class"] = CF.ItmClasses[playerFaction][item["Item"]];
				gameState[actorPrefix .. i .. "Item" .. slt .. "Module"] = CF.ItmModules[playerFaction][item["Item"]];
				slt = slt + 1;
			else
				gameState[actorPrefix .. i .. "Item" .. slt .. "Preset"] = CF.ItmPresets[playerFaction][item["Item"]];
				gameState[actorPrefix .. i .. "Item" .. slt .. "Class"] = CF.ItmClasses[playerFaction][item["Item"]];
				gameState[actorPrefix .. i .. "Item" .. slt .. "Module"] = CF.ItmModules[playerFaction][item["Item"]];
				count = count - 1;
				goto insert;
			end
		end
		
		if slt == 1 then
			-- coin flip unless guy one, or guy two and no shotguns
			if rifles and (math.random(2) == 1 or i == 1 or (i == 2 and not shotguns)) then
				list = rifles;
				goto insert;
			-- coin flip unless we're guy two
			elseif shotguns and (math.random(2) == 1 or i == 2) then
				list = shotguns;
				goto insert;
			-- coin flip
			elseif snipers and (math.random(2) == 1) then
				list = snipers;
				goto insert
			-- last chance
			elseif pistols then
				list = pistols;
				goto insert;
			-- give up
			else
				slt = 2;
			end
		end
		if slt == 2 then
			-- grab one or two pistols if we have none
			-- grab one if we do have one and we're akimbo inclined
			if pistols and (list ~= pistols or math.random(2) == 1) then
				if list ~= pistols then
					count = math.random(2);
					list = pistols;
					item = list[math.random(#list)];
					goto insert;
				else
					list = pistols;
					goto insert;
				end
			-- grab a shield if no pistols or no akimbo inclination and no real gun
			elseif shields then
				list = shields;
				goto insert;
			-- give up
			else
				slt = 3;
			end
		end
		if slt == 3 then
			-- coin flip unless he's the last guy
			if diggers and (math.random(2) == 1 or i == 4) then
				list = diggers;
				goto insert;
			-- grenade otherwise
			elseif grenades then
				list = grenades;
				goto insert;
			-- give up
			else
				slt = 4;
			end
		end
		if slt == 4 then
			if grenades then
				count = math.random(2);
				list = grenades;
				item = list[math.random(#list)];
				goto insert;
			end
		end
	end

	-- Give the starting brains some small arms
	if CF.BrainClasses[playerFaction] ~= "ACrab" then
		for i = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local list = { CF.WeaponTypes.PISTOL, CF.WeaponTypes.PISTOL, CF.WeaponTypes.TOOL };

			for j = 1, #list do
				local weapons = CF.MakeListOfMostPowerfulWeapons(playerFaction, list[j], math.huge);

				if weapons ~= nil then
					local factionIndex = weapons[#weapons].Faction;
					local itemIndex = weapons[#weapons].Item;
					
					gameState["Brain" .. i .. "Item" .. j .. "Preset"] = CF.ItmPresets[playerFaction][itemIndex];
					gameState["Brain" .. i .. "Item" .. j .. "Class"] = CF.ItmClasses[playerFaction][itemIndex];
					gameState["Brain" .. i .. "Item" .. j .. "Module"] = CF.ItmModules[playerFaction][itemIndex];
				end
			end
		end
	end

	return gameState;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
