function VoidWanderers:StartActivity()
	---- -- -- self.ModuleName = "VoidWanderers.rte";
	self.IsInitialized = false
	self.BuyMenuEnabled = false

	self.WasPaused = false

	LAUNCH_MISSION_PACK = nil
	STATE_CONFIG_FILE = "current.dat"

	self.Zone = SceneMan.Scene:GetArea("VoidWanderersAntiBugZone") 

	LIB_PATH = self.ModuleName .. "/Scripts/"
	BASE_PATH = self.ModuleName .. "/Scripts/"

	if SKIP_LIBRARIES == nil then
		dofile(LIB_PATH .. "Lib_Config.lua")
		dofile(LIB_PATH .. "Lib_Generic.lua")
		dofile(LIB_PATH .. "Lib_ExtensionsData.lua")
		dofile(LIB_PATH .. "Lib_Spawn.lua")
		dofile(LIB_PATH .. "Lib_Storage.lua")
		dofile(LIB_PATH .. "Lib_Encounters.lua")

		dofile(LIB_PATH .. "Brain_Update.lua")

		dofile(LIB_PATH .. "Panel_Clones.lua")
		dofile(LIB_PATH .. "Panel_Ship.lua")
		dofile(LIB_PATH .. "Panel_Beam.lua")
		dofile(LIB_PATH .. "Panel_Storage.lua")
		dofile(LIB_PATH .. "Panel_ItemShop.lua")
		dofile(LIB_PATH .. "Panel_CloneShop.lua")
		dofile(LIB_PATH .. "Panel_LZ.lua")
		dofile(LIB_PATH .. "Panel_Brain.lua")
		dofile(LIB_PATH .. "Panel_Turrets.lua")
		dofile(LIB_PATH .. "Panel_Bombs.lua")
	end

	-- Check delta time and fix it to avoid problems with fonts
	if TimerMan.DeltaTimeMS >= 25 then
		print("Incorrect delta time, fixed")
		TimerMan.DeltaTimeSecs = 0.0166667
	end

	SKIP_LIBRARIES = nil

	-- Load custom AI
	--print (CF_UseCustomAI)

	if TRANSFER_IN_PROGRESS == nil then
		TRANSFER_IN_PROGRESS = false
	end

	if not TRANSFER_IN_PROGRESS then
		print("\n\n\n")
		-- Reset all previouly set scenes and scripts before launch since we're starting clean
		SCENE_TO_LAUNCH = nil
		SCRIPT_TO_LAUNCH = nil
	else
		TRANSFER_IN_PROGRESS = false
	end

	print("VoidWanderers:MissionLauncher!")

	if SCENE_TO_LAUNCH == nil then
		SCENE_TO_LAUNCH = "VoidWanderers Strategy Screen"
	end

	if SCRIPT_TO_LAUNCH == nil then
		SCRIPT_TO_LAUNCH = BASE_PATH .. "StrategyScreenMain.lua"
	end

	TRANSFER_IN_PROGRESS = false

	for difficulty = GameActivity.MINDIFFICULTY, GameActivity.MAXDIFFICULTY do
		if self.Difficulty <= difficulty then
			self.Difficulty = difficulty
		else
			break
		end
	end
	-- This is ugly but that's ok
	CHOSEN_DIFFICULTY = self.Difficulty
	CHOSEN_AISKILLPLAYER = self:GetTeamAISkill(Activity.TEAM_1)
	CHOSEN_AISKILLCPU = self:GetTeamAISkill(Activity.TEAM_2)

	FORM_TO_LOAD = BASE_PATH .. "FormStart.lua"

	print("SCRIPT: " .. SCRIPT_TO_LAUNCH)
	print("SCENE : " .. SCENE_TO_LAUNCH)

	dofile(SCRIPT_TO_LAUNCH)
	SceneMan:LoadScene(SCENE_TO_LAUNCH, true)
end
-----------------------------------------------------------------------------------------
-- Launches new mission script without leaving current activity. Scene is case sensitive!
-----------------------------------------------------------------------------------------
function VoidWanderers:LaunchScript(scene, script)
	print("VoidWanderers-LaunchScript: " .. scene .. " / " .. script)
	--print(scene)
	--print(script)

	self.IsInitialized = false

	MovableMan:PurgeAllMOs()

	dofile(BASE_PATH .. script)
	SceneMan:LoadScene(scene, true)

	--Delete all added actors
	for actor in MovableMan.AddedActors do
		if actor.ClassName ~= "ADoor" then
			actor.ToDelete = true
		end
	end
end
-----------------------------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:PauseActivity(pause)
	print("PAUSE! -- VoidWanderers:PauseActivity()!")
end
-----------------------------------------------------------------------------------------
-- End Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:EndActivity()
	print("END! -- VoidWanderers:EndActivity()!")
	CF_Self = nil
	CF_GS = nil
end
-----------------------------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	--print("VoidWanderers::Mission launcher - Update Once!")
	if TRANSFER_IN_PROGRESS then
		self:StartActivity()
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:LoadCurrentGameState()
	if CF_IsFileExists(self.ModuleName, STATE_CONFIG_FILE) then
		self.GS = CF_ReadConfigFile(self.ModuleName, STATE_CONFIG_FILE)

		self.Time = tonumber(self.GS["Time"])

		-- Move ship to tradestar if last location was removed
		if CF_PlanetName[self.GS["Planet"]] == nil then
			--print (self.GS["Location"].." not found. Relocated to tradestar.")

			self.GS["Planet"] = CF_Planet[1]
			self.GS["Location"] = nil
		end

		if self.GS["Difficulty"] then
			CF_Difficulty = tonumber(self.GS["Difficulty"])
		end
		if self.GS["AISkillPlayer"] then
			CF_AISkillPlayer = tonumber(self.GS["AISkillPlayer"])
		end
		if self.GS["AISkillCPU"] then
			CF_AISkillCPU = tonumber(self.GS["AISkillCPU"])
		end

		-- Check missions for missing scenes, if any of them found - recreate missions
		for i = 1, CF_MaxMissions do
			if CF_LocationName[self.GS["Mission" .. i .. "Location"]] == nil then
				CF_GenerateRandomMissions(self.GS)
				break
			end
		end

		-- Create RPG brain values if they are not present
		-- This is needed to update old save files, those values are not created during save-file initialization
		for plr = 0, 3 do
			local val = self.GS["Brain" .. plr .. "SkillPoints"]
			if val == nil then
				self.GS["Brain" .. plr .. "SkillPoints"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Exp"]
			if val == nil then
				self.GS["Brain" .. plr .. "Exp"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Level"]
			if val == nil then
				self.GS["Brain" .. plr .. "Level"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Toughness"]
			if val == nil then
				self.GS["Brain" .. plr .. "Toughness"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Field"]
			if val == nil then
				self.GS["Brain" .. plr .. "Field"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Telekinesis"]
			if val == nil then
				self.GS["Brain" .. plr .. "Telekinesis"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Scanner"]
			if val == nil then
				self.GS["Brain" .. plr .. "Scanner"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Heal"]
			if val == nil then
				self.GS["Brain" .. plr .. "Heal"] = 0
			end

			local val = self.GS["Brain" .. plr .. "SelfHeal"]
			if val == nil then
				self.GS["Brain" .. plr .. "SelfHeal"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Fix"]
			if val == nil then
				self.GS["Brain" .. plr .. "Fix"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Fix"]
			if val == nil then
				self.GS["Brain" .. plr .. "Fix"] = 0
			end

			local val = self.GS["Brain" .. plr .. "Splitter"]
			if val == nil then
				self.GS["Brain" .. plr .. "Splitter"] = 0
			end

			local val = self.GS["Brain" .. plr .. "QuantumStorage"]
			if val == nil then
				self.GS["Brain" .. plr .. "QuantumStorage"] = 0
			end

			local val = self.GS["Brain" .. plr .. "QuantumCapacity"]
			if val == nil then
				self.GS["Brain" .. plr .. "QuantumCapacity"] = 0
			end
		end

		local arr = CF_GetAvailableQuantumItems(self.GS)
		if #arr == 0 then
			CF_UnlockRandomQuantumItem(self.GS)
		end

		local val = self.GS["Player0VesselTurrets"]
		if val == nil then
			self.GS["Player0VesselTurrets"] = CF_VesselStartTurrets[self.GS["Player0Vessel"]]
		end

		local val = self.GS["Player0VesselTurretStorage"]
		if val == nil then
			self.GS["Player0VesselTurretStorage"] = CF_VesselStartTurretStorage[self.GS["Player0Vessel"]]
		end

		local val = self.GS["Player0VesselBombBays"]
		if val == nil then
			self.GS["Player0VesselBombBays"] = CF_VesselStartBombBays[self.GS["Player0Vessel"]]
		end

		local val = self.GS["Player0VesselBombStorage"]
		if val == nil then
			self.GS["Player0VesselBombStorage"] = CF_VesselStartBombStorage[self.GS["Player0Vessel"]]
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveCurrentGameState()
	self.GS["Time"] = tostring(self.Time)
	CF_WriteConfigFile(self.GS, self.ModuleName, STATE_CONFIG_FILE)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
