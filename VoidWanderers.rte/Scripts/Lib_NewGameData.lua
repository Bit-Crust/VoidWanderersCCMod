-----------------------------------------------------------------------------------------
-- Initializes all game data when new game started and returns new config
-----------------------------------------------------------------------------------------
function CF_MakeNewConfig(difficulty, playerSkill, cpuSkill, f, cpus, activity)
	local config = {}
	local gameplay = true

	-- Init game time
	config["Time"] = 0

	local PositiveIndex
	local NegativeIndex

	local aiscience = 0

	-- Difficulty related variables
	if difficulty <= GameActivity.CAKEDIFFICULTY then
		PositiveIndex = 1.5
		NegativeIndex = 0.5

		config["MissionDifficultyBonus"] = -2
	elseif difficulty <= GameActivity.EASYDIFFICULTY then
		PositiveIndex = 1.25
		NegativeIndex = 0.75

		config["MissionDifficultyBonus"] = -1
	elseif difficulty <= GameActivity.MEDIUMDIFFICULTY then
		PositiveIndex = 1.0
		NegativeIndex = 1.0

		config["MissionDifficultyBonus"] = -0
	elseif difficulty <= GameActivity.HARDDIFFICULTY then
		PositiveIndex = 0.90
		NegativeIndex = 1.10

		config["MissionDifficultyBonus"] = 1
	elseif difficulty <= GameActivity.NUTSDIFFICULTY then
		PositiveIndex = 0.80
		NegativeIndex = 1.20

		config["MissionDifficultyBonus"] = 2
	elseif difficulty <= GameActivity.MAXDIFFICULTY then
		PositiveIndex = 0.70
		NegativeIndex = 1.30

		config["MissionDifficultyBonus"] = 3
	end

	config["Difficulty"] = difficulty
	config["AISkillPlayer"] = playerSkill
	config["AISkillCPU"] = cpuSkill

	config["PositiveIndex"] = PositiveIndex
	config["NegativeIndex"] = NegativeIndex

	config["FogOfWar"] = activity:GetFogOfWarEnabled()

	-- Set up players
	config["Player0Faction"] = f
	config["Player0Active"] = "True"
	config["Player0Type"] = "Player"
	config["Player0Gold"] = math.floor(activity:GetStartingGold())

	-- Assign player ship
	config["Player0Vessel"] = "Lynx"
	--config["Player0Vessel"] = "Titan" -- DEBUG
	--config["Player0Vessel"] = "Ager 9th" -- DEBUG

	-- Set vessel attrs
	config["Player0VesselStorageCapacity"] = CF_VesselStartStorageCapacity[config["Player0Vessel"]]
	config["Player0VesselClonesCapacity"] = CF_VesselStartClonesCapacity[config["Player0Vessel"]]

	config["Player0VesselLifeSupport"] = CF_VesselStartLifeSupport[config["Player0Vessel"]]
	config["Player0VesselCommunication"] = CF_VesselStartCommunication[config["Player0Vessel"]]

	config["Player0VesselSpeed"] = CF_VesselStartSpeed[config["Player0Vessel"]]
	config["Player0VesselTurrets"] = CF_VesselStartTurrets[config["Player0Vessel"]]
	config["Player0VesselTurretStorage"] = CF_VesselStartTurretStorage[config["Player0Vessel"]]
	config["Player0VesselBombBays"] = CF_VesselStartBombBays[config["Player0Vessel"]]
	config["Player0VesselBombStorage"] = CF_VesselStartBombStorage[config["Player0Vessel"]]

	config["Time"] = 1

	-- Set up initial location - Tradestar
	config["Planet"] = CF_Planet[1]
	config["Location"] = CF_Location[1]

	local locpos = CF_LocationPos[config["Location"]]

	config["ShipX"] = locpos.X
	config["ShipY"] = locpos.Y

	--Debug
	--config["Planet"] = "CC-11Y"
	--config["Location"] = "Ketanot Hills"

	local found = 0

	-- Find available player actor
	for i = 1, #CF_ActNames[f] do
		if CF_ActUnlockData[f][i] == 0 then
			found = i
			break
		end
	end

	-- Find available player weapon
	local weaps = {}

	-- Find available player items
	for i = 1, #CF_ItmNames[f] do
		if CF_ItmUnlockData[f][i] == 0 then
			weaps[#weaps + 1] = i
		end
	end

	-- DEBUG Add all available weapons
	--local weaps = {}
	--for i = 1, #CF_ItmNames[f] do
	--	weaps[#weaps + 1] = i
	--end

	-- Assign initial player actors in storage
	for i = 1, 4 do
		config["ClonesStorage" .. i .. "Preset"] = CF_ActPresets[f][found]
		if CF_ActClasses[f][found] ~= nil then
			config["ClonesStorage" .. i .. "Class"] = CF_ActClasses[f][found]
		else
			config["ClonesStorage" .. i .. "Class"] = "AHuman"
		end
		config["ClonesStorage" .. i .. "Module"] = CF_ActModules[f][found]
		config["ClonesStorage" .. i .. "Identity"] = i - 1

		local slt = 1
		for j = #weaps, 1, -1 do
			config["ClonesStorage" .. i .. "Item" .. slt .. "Preset"] = CF_ItmPresets[f][weaps[j]]
			if CF_ItmClasses[f][weaps[j]] ~= nil then
				config["ClonesStorage" .. i .. "Item" .. slt .. "Class"] = CF_ItmClasses[f][weaps[j]]
			else
				config["ClonesStorage" .. i .. "Item" .. slt .. "Class"] = "HDFirearm"
			end
			config["ClonesStorage" .. i .. "Item" .. slt .. "Module"] = CF_ItmModules[f][weaps[j]]
			slt = slt + 1
		end
	end --]]--

	-- Set initial scene
	config["Scene"] = CF_VesselScene[config["Player0Vessel"]]

	-- Set initial scene type
	config["SceneType"] = "Vessel"

	-- Set operation mode
	config["Mode"] = "Vessel"

	local activecpus = 0

	for i = 1, CF_MaxCPUPlayers do
		if cpus[i] then
			config["Player" .. i .. "Faction"] = cpus[i]
			config["Player" .. i .. "Active"] = "True"
			config["Player" .. i .. "Type"] = "CPU"

			if config["Player" .. i .. "Faction"] == config["Player0Faction"] then
				config["Player" .. i .. "Reputation"] = 500
			else
				-- Organic factions automatically get negative rep from synthetic factions and vice versa
				if
					CF_FactionNatures[config["Player0Faction"]] == CF_FactionNatures[config["Player" .. i .. "Faction"]]
				then
					config["Player" .. i .. "Reputation"] = 0
				else
					config["Player" .. i .. "Reputation"] = math.floor(
						CF_ReputationHuntThreshold * (CF_Difficulty * 0.01) + 0.5
					)
				end
			end

			activecpus = activecpus + 1
		else
			config["Player" .. i .. "Faction"] = "Nobody"
			config["Player" .. i .. "Active"] = "False"
			config["Player" .. i .. "Type"] = "None"
		end
	end

	config["ActiveCPUs"] = activecpus

	CF_GenerateRandomMissions(config)

	return config
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
