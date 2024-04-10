-----------------------------------------------------------------------------------------
-- Generic functions to add to library
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialize global faction lists
-----------------------------------------------------------------------------------------
function CF_InitFactions(activity)
	print("CF_InitFactions")
	CF_CPUTeam = Activity.TEAM_2
	CF_PlayerTeam = Activity.TEAM_1
	CF_RogueTeam = -1
	CF_MOIDLimit = math.huge
	CF_ModuleName = "VoidWanderers.rte"

	CF_Difficulty = CHOSEN_DIFFICULTY
	CF_AISkillPlayer = CHOSEN_AISKILLPLAYER
	CF_AISkillCPU = CHOSEN_AISKILLCPU

	-- Used in flight mode
	CF_KmPerPixel = 100

	CF_BlackMarketRefreshInterval = 1200
	CF_BlackMarketPriceMultiplier = 3

	CF_MissionResultShowInterval = 10

	CF_UnknownItemPrice = 50
	CF_UnknownActorPrice = 100

	CF_TechPriceMultiplier = 1.5
	CF_SellPriceCoeff = 0.25

	CF_OrdersRange = 175

	CF_MaxMissions = 8

	CF_MaxHolograms = 23

	CF_BombsPerBay = 5
	CF_BombInterval = 1
	CF_BombLoadInterval = 2
	CF_BombFlightInterval = 10
	CF_BombSeenRange = 150
	CF_BombUnseenRange = 400

	CF_KeyRepeatDelay = 100

	CF_MaxLevel = 100
	CF_ExpPerLevel = 250

	CF_Ranks = { 50, 125, 250, 500, 1000 }
	CF_PrestigeSlice = CreatePieSlice("Prestige PieSlice", CF_ModuleName)

	CF_PermanentLimbLoss = true
	CF_LimbID = { "FG1", "BG1", "FG2", "BG2", "HEAD", "JETPAK" }

	CF_QuantumCapacityPerLevel = 50
	CF_QuantumSplitterEffectiveness = 0.2

	CF_SecurityIncrementPerMission = 10
	CF_SecurityIncrementPerDeployment = 2

	CF_ReputationPerDifficulty = 1000

	CF_RandomEncounterProbability = 0.15

	-- When reputation is below this level, the enemy starts attacking the player
	CF_ReputationHuntThreshold = -500

	-- The rate of reputation points subtracted from the mission target faction
	CF_ReputationPenaltyRatio = 1.75

	-- The rate of reputation points subtracted from both reputations when failing a mission
	CF_MissionFailedReputationPenaltyRatio = 0.3

	CF_EnableIcons = true

	-- When enabled UL2 will use special rendering techniques to improve UI rendering
	-- performance on weaker machines. Some artifacts may appear though.
	CF_LowPerformance = false

	-- The idea behind this optimization is that creation of particles eats most of the time.
	-- To avoid that we draw some words and buttons on odd frames and some on even frames.
	-- When in LowPerformance mode CF_DrawString and DrawButton functions will use special Ln-prefixed
	-- versions of UI glows, which live twice longer. In order to work main execution thread must
	-- count frames so other function can decide if it's odd or even frame right now
	CF_FrameCounter = 0

	CF_ShipAssaultDelay = 30
	CF_ShipCounterattackDelay = 20
	CF_ShipAssaultCooldown = 150

	CF_TeamReturnDelay = 5

	CF_CratesRate = 0.25 -- Percentage of cases among available case spawn points
	CF_ActorCratesRate = 0.1 -- Percentage of actor-cases among all deployed cases
	CF_CrateRandomLocationsRate = 0.5
	CF_AmbientEnemyRate = 0.5
	CF_ArtifactItemRate = 0.1
	CF_ArtifactActorRate = 0.1
	CF_AmbientEnemyDoubleSpawn = 0.25
	CF_AmbientReinforcementsInterval = 80 -- In ticks

	CF_MaxMissionReportLines = 13

	CF_ClonePrice = 1500
	CF_StoragePrice = 200
	CF_LifeSupportPrice = 2500
	CF_CommunicationPrice = 3000
	CF_EnginePrice = 500
	CF_TurretPrice = 1500
	CF_TurretStoragePrice = 1000
	CF_BombBayPrice = 5000
	CF_BombStoragePrice = 200

	CF_ShipSellCoeff = 0.25
	CF_ShipDevInstallCoeff = 0.1

	CF_AssaultDifficultyTexts = {}
	CF_AssaultDifficultyTexts[1] = "scout"
	CF_AssaultDifficultyTexts[2] = "corvette"
	CF_AssaultDifficultyTexts[3] = "frigate"
	CF_AssaultDifficultyTexts[4] = "destroyer"
	CF_AssaultDifficultyTexts[5] = "cruiser"
	CF_AssaultDifficultyTexts[6] = "battleship"

	CF_LocationDifficultyTexts = {}
	CF_LocationDifficultyTexts[1] = "minimum"
	CF_LocationDifficultyTexts[2] = "low"
	CF_LocationDifficultyTexts[3] = "moderate"
	CF_LocationDifficultyTexts[4] = "high"
	CF_LocationDifficultyTexts[5] = "extreme"
	CF_LocationDifficultyTexts[6] = "maximum"

	CF_AssaultDifficultyUnitCount = {}
	CF_AssaultDifficultyUnitCount[1] = 4
	CF_AssaultDifficultyUnitCount[2] = 8
	CF_AssaultDifficultyUnitCount[3] = 12
	CF_AssaultDifficultyUnitCount[4] = 16
	CF_AssaultDifficultyUnitCount[5] = 22
	CF_AssaultDifficultyUnitCount[6] = 30

	CF_AssaultDifficultySpawnInterval = {}
	CF_AssaultDifficultySpawnInterval[1] = 9
	CF_AssaultDifficultySpawnInterval[2] = 9
	CF_AssaultDifficultySpawnInterval[3] = 8
	CF_AssaultDifficultySpawnInterval[4] = 8
	CF_AssaultDifficultySpawnInterval[5] = 8
	CF_AssaultDifficultySpawnInterval[6] = 7

	CF_AssaultDifficultySpawnBurst = {}
	CF_AssaultDifficultySpawnBurst[1] = 1
	CF_AssaultDifficultySpawnBurst[2] = 2
	CF_AssaultDifficultySpawnBurst[3] = 2
	CF_AssaultDifficultySpawnBurst[4] = 2
	CF_AssaultDifficultySpawnBurst[5] = 3
	CF_AssaultDifficultySpawnBurst[6] = 3

	CF_MaxDifficulty = 6

	CF_MaxCPUPlayers = 200
	CF_MaxSaveGames = 6
	CF_MaxItems = 8 -- Max items per clone in clone storage
	CF_MaxItemsPerPreset = 3 -- Max items per AI unit preset
	CF_MaxStorageItems = 1000
	CF_MaxClones = 1000 -- Max clones in clone storage
	CF_MaxTurrets = 1000
	CF_MaxBombs = 1000
	CF_MaxUnitsPerDropship = 3

	CF_MaxSavedActors = 40
	CF_MaxSavedItemsPerActor = 20

	-- Set this to true to stop any UI processing. Useful when debuging and need to disable UI error message spam.
	CF_StopUIProcessing = false

	CF_LaunchActivities = true
	CF_MissionReturnInterval = 2500

	CF_TickInterval = 1000
	CF_FlightTickInterval = 25

	-- How much percents of price to add if player and ally factions natures are not the same
	CF_SynthetsToOrganicRatio = 0.70

	CF_EnableAssaults = true -- Set to false to disable assaults

	CF_FogOfWarResolution = 36

	CF_Factions = {}

	CF_Nobody = "Nobody"
	CF_PlayerFaction = "Nobody"
	CF_CPUFaction = "Nobody"

	CF_MissionEndTimer = Timer()
	CF_StartReturnCountdown = false
	CF_Activity = activity

	CF_FactionIds = {}
	CF_FactionNames = {}
	CF_FactionDescriptions = {}
	CF_FactionPlayable = {}

	CF_ScanBonuses = {}
	CF_RelationsBonuses = {}
	CF_ExpansionBonuses = {}

	CF_MineBonuses = {}
	CF_LabBonuses = {}
	CF_AirfieldBonuses = {}
	CF_SuperWeaponBonuses = {}
	CF_FactoryBonuses = {}
	CF_CloneBonuses = {}
	CF_HospitalBonuses = {}

	CF_HackTimeBonuses = {}
	CF_HackRewardBonuses = {}

	CF_DropShipCapacityBonuses = {}

	-- Special arrays for factions with pre-equipped items
	-- Everything in this array (indexed by preset name) will not be included by inventory saving routines
	CF_DiscardableItems = {}
	-- Everything in this array will be marked for deletion after actor is created
	CF_ItemsToRemove = {}

	CF_BrainHuntRatios = {}

	CF_PreferedBrainInventory = {}

	CF_SuperWeaponScripts = {}

	CF_ResearchQueues = {}

	-- Specify presets which are not affected by tactical AI unit management
	CF_UnassignableUnits = {}

	-- Set this to true if your faction uses pre-equipped actors
	CF_PreEquippedActors = {}

	CF_PresetNames = {
		"Infantry 1",
		"Infantry 2",
		"Shotgun",
		"Sniper",
		"Heavy 1",
		"Heavy 2",
		"Armor 1",
		"Armor 2",
		"Engineer",
		"Defender",
	}
	CF_PresetTypes = {
		INFANTRY1 = 1,
		INFANTRY2 = 2,
		SHOTGUN = 3,
		SNIPER = 4,
		HEAVY1 = 5,
		HEAVY2 = 6,
		ARMOR1 = 7,
		ARMOR2 = 8,
		ENGINEER = 9,
		DEFENDER = 10,
	}

	-- Arrays with a combination of presets used by this faction, script will randomly select presets for deployment from this arrays if available
	CF_PreferedTacticalPresets = {}

	-- Default presets array, everything is evenly selected by AI
	CF_DefaultTacticalPresets = {
		CF_PresetTypes.INFANTRY1,
		CF_PresetTypes.INFANTRY2,
		CF_PresetTypes.SNIPER,
		CF_PresetTypes.SHOTGUN,
		CF_PresetTypes.HEAVY1,
		CF_PresetTypes.HEAVY2,
		CF_PresetTypes.ARMOR1,
		CF_PresetTypes.ARMOR2,
		CF_PresetTypes.ENGINEER,
	}
	-- These AI models are left over from UL2 but preserved for backwards compatibility
	CF_AIModels = { "RANDOM", "SIMPLE", "CONSOLE HUNTERS", "SQUAD" }
	CF_FactionAIModels = {}

	CF_WeaponTypes = {
		ANY = -1,
		PISTOL = 0,
		RIFLE = 1,
		SHOTGUN = 2,
		SNIPER = 3,
		HEAVY = 4,
		SHIELD = 5,
		DIGGER = 6,
		GRENADE = 7,
		TOOL = 8,
		BOMB = 9,
	}
	CF_ActorTypes = { ANY = -1, LIGHT = 0, HEAVY = 1, ARMOR = 2, TURRET = 3 }
	CF_FactionTypes = { ORGANIC = 0, SYNTHETIC = 1 }

	CF_ItmNames = {}
	CF_ItmPresets = {}
	CF_ItmModules = {}
	CF_ItmPrices = {}
	CF_ItmDescriptions = {}
	CF_ItmUnlockData = {}
	CF_ItmClasses = {}
	CF_ItmTypes = {}
	CF_ItmPowers = {} -- AI will select weapons based on this value

	CF_ActNames = {}
	CF_ActPresets = {}
	CF_ActModules = {}
	CF_ActPrices = {}
	CF_ActDescriptions = {}
	CF_ActUnlockData = {}
	CF_ActClasses = {}
	CF_ActTypes = {}
	CF_EquipmentTypes = {} -- Factions with pre-equipped actors specify which weapons class this unit is equivalent
	CF_ActPowers = {}
	CF_ActOffsets = {}

	-- Bombs, used only by VoidWanderers
	CF_BombNames = {}
	CF_BombPresets = {}
	CF_BombModules = {}
	CF_BombClasses = {}
	CF_BombPrices = {}
	CF_BombDescriptions = {}
	CF_BombOwnerFactions = {}
	CF_BombUnlockData = {}

	CF_RequiredModules = {}

	CF_FactionNatures = {}

	CF_Brains = {}
	CF_BrainModules = {}
	CF_BrainClasses = {}
	CF_BrainPrices = {}

	CF_Crafts = {}
	CF_CraftModules = {}
	CF_CraftClasses = {}
	CF_CraftPrices = {}

	CF_MusicTypes = { SHIP_CALM = 0, SHIP_INTENSE = 1, MISSION_CALM = 2, MISSION_INTENSE = 3, VICTORY = 4, DEFEAT = 5 }

	CF_Music = {}
	CF_Music[CF_MusicTypes.SHIP_CALM] = {}
	CF_Music[CF_MusicTypes.SHIP_INTENSE] = {}
	CF_Music[CF_MusicTypes.MISSION_CALM] = {}
	CF_Music[CF_MusicTypes.MISSION_INTENSE] = {}

	-- Load factions
	--CF_FactionFiles = CF_ReadFactionsList(CF_ModuleName.."/Factions/Factions.cfg" , CF_ModuleName.."/Factions/")
	CF_FactionFiles = { "Mods/VoidWanderers.rte/Factions/Factions.lua" }

	-- Load factions data
	for i = 1, #CF_FactionFiles do
		--print("Loading "..CF_FactionFiles[i])
		f = loadfile(CF_FactionFiles[i])
		if f ~= nil then
			local lastfactioncount = #CF_Factions

			-- Execute script
			f()

			-- Check for faction consistency only if it is a faction file
			if lastfactioncount ~= #CF_Factions then
				local id = CF_Factions[#CF_Factions]

				--Check if faction modules installed. Check only works with old v1 or most new v2 faction files.
				--print(CF_InfantryModules[CF_Factions[#CF_Factions]])
				for m = 1, #CF_RequiredModules[id] do
					local module = CF_RequiredModules[id][m]

					if module ~= nil then
						if PresetMan:GetModuleID(module) == -1 then
							CF_FactionPlayable[id] = false
							print("ERROR!!! " .. id .. " DISABLED!!! " .. CF_RequiredModules[id][m] .. " NOT FOUND!!!")
						end
					end
				end

				-- Assume that faction file is correct
				local factionok = true
				local err = ""

				-- Verify faction file data and add mission values if any
				-- Verify items
				for i = 1, #CF_ItmNames[id] do
					if CF_ItmModules[id][i] == nil then
						factionok = false
						err = "CF_ItmModules is missing."
					end

					if CF_ItmPrices[id][i] == nil then
						factionok = false
						err = "CF_ItmPrices is missing."
					end

					if CF_ItmDescriptions[id][i] == nil then
						factionok = false
						err = "CF_ItmDescriptions is missing."
					end

					if CF_ItmUnlockData[id][i] == nil then
						factionok = false
						err = "CF_ItmUnlockData is missing."
					end

					if CF_ItmTypes[id][i] == nil then
						factionok = false
						err = "CF_ItmTypes is missing."
					end

					if CF_ItmPowers[id][i] == nil then
						factionok = false
						err = "CF_ItmPowers is missing."
					end

					-- If something is wrong then disable faction and print error message
					if not factionok then
						CF_FactionPlayable[id] = false
						print("ERROR!!! " .. id .. " DISABLED!!! " .. CF_ItmNames[id][i] .. " : " .. err)
						break
					end
				end

				-- Assume that faction file is correct
				local info = {}
				local data = {}

				-- Verify faction generic data
				info[#info + 1] = "CF_FactionNames"
				data[#info] = CF_FactionNames[id]

				info[#info + 1] = "CF_FactionDescriptions"
				data[#info] = CF_FactionDescriptions[id]

				info[#info + 1] = "CF_FactionPlayable"
				data[#info] = CF_FactionPlayable[id]

				info[#info + 1] = "CF_RequiredModules"
				data[#info] = CF_RequiredModules[id]

				info[#info + 1] = "CF_FactionNatures"
				data[#info] = CF_FactionNatures[id]
				--[[ UL2 stuff - don't need these!
				info[#info + 1] = "CF_ScanBonuses"
				data[#info] = CF_ScanBonuses[id]
				
				info[#info + 1] = "CF_RelationsBonuses"
				data[#info] = CF_RelationsBonuses[id]

				info[#info + 1] = "CF_ExpansionBonuses"
				data[#info] = CF_ExpansionBonuses[id]

				info[#info + 1] = "CF_MineBonuses"
				data[#info] = CF_MineBonuses[id]

				info[#info + 1] = "CF_LabBonuses"
				data[#info] = CF_LabBonuses[id]

				info[#info + 1] = "CF_AirfieldBonuses"
				data[#info] = CF_AirfieldBonuses[id]

				info[#info + 1] = "CF_SuperWeaponBonuses"
				data[#info] = CF_SuperWeaponBonuses[id]

				info[#info + 1] = "CF_FactoryBonuses"
				data[#info] = CF_FactoryBonuses[id]

				info[#info + 1] = "CF_CloneBonuses"
				data[#info] = CF_CloneBonuses[id]

				info[#info + 1] = "CF_HospitalBonuses"
				data[#info] = CF_HospitalBonuses[id]
]]
				--
				info[#info + 1] = "CF_Brains"
				data[#info] = CF_Brains[id]

				info[#info + 1] = "CF_BrainModules"
				data[#info] = CF_BrainModules[id]

				info[#info + 1] = "CF_BrainClasses"
				data[#info] = CF_BrainClasses[id]

				info[#info + 1] = "CF_BrainPrices"
				data[#info] = CF_BrainPrices[id]

				info[#info + 1] = "CF_Crafts"
				data[#info] = CF_Crafts[id]

				info[#info + 1] = "CF_CraftModules"
				data[#info] = CF_CraftModules[id]

				info[#info + 1] = "CF_CraftClasses"
				data[#info] = CF_CraftClasses[id]

				info[#info + 1] = "CF_CraftPrices"
				data[#info] = CF_CraftPrices[id]

				for i = 1, #info do
					if data[i] == nil then
						CF_FactionPlayable[id] = false
						print("ERROR!!! " .. id .. " DISABLED!!! " .. info[i] .. " is missing")
						break
					end
				end

				-- Assume that faction file is correct
				local factionok = true
				local err = ""

				-- Verify actors
				for i = 1, #CF_ActNames[id] do
					if CF_ActModules[id][i] == nil then
						factionok = false
						err = "CF_ActModules is missing."
					end

					if CF_ActPrices[id][i] == nil then
						factionok = false
						err = "CF_ActPrices is missing."
					end

					if CF_ActDescriptions[id][i] == nil then
						factionok = false
						err = "CF_ActDescriptions is missing."
					end

					if CF_ActUnlockData[id][i] == nil then
						factionok = false
						err = "CF_ActUnlockData is missing."
					end

					if CF_ActTypes[id][i] == nil then
						factionok = false
						err = "CF_ActTypes is missing."
					end

					if CF_ActPowers[id][i] == nil then
						factionok = false
						err = "CF_ActPowers is missing."
					end

					-- If something is wrong then disable faction and print error message
					if not factionok then
						CF_FactionPlayable[id] = false
						print("ERROR!!! " .. id .. " DISABLED!!! " .. CF_ActNames[id][i] .. " : " .. err)
						break
					end
				end
			end
		else
			print("ERROR!!! Could not load: " .. CF_FactionFiles[i])
		end
	end

	CF_InitExtensionsData(activity)

	-- Load extensions
	CF_ExtensionFiles = CF_ReadExtensionsList(
		CF_ModuleName .. "/Extensions/Extensions.cfg",
		CF_ModuleName .. "/Extensions/"
	)

	local extensionstorage = "Mods/" .. CF_ModuleName .. "/Extensions/"

	-- Load extensions data
	for i = 1, #CF_ExtensionFiles do
		--[[f = loadfile(extensionstorage..CF_ExtensionFiles[i])
		if f ~= nil then
			-- Execute script
			f()
		else
			print ("ERROR!!! Could not load: "..CF_ExtensionFiles[i])
		end]]
		--
		dofile(CF_ExtensionFiles[i])
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_GetPlayerFaction(config, p)
	return config["Player" .. p .. "Faction"]
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_GetPlayerAllyFaction(config)
	return config["Player0AllyFaction"]
end
-----------------------------------------------------------------------------------------
-- Update mission stats to store in campaign
-----------------------------------------------------------------------------------------
function CF_UpdateGenericStats(config)
	print("CF_UpdateGenericStats")

	config["Kills"] = tonumber(config["Kills"]) + CF_Activity:GetTeamDeathCount(CF_CPUTeam)
	config["Deaths"] = tonumber(config["Deaths"]) + CF_Activity:GetTeamDeathCount(CF_PlayerTeam)
end
-----------------------------------------------------------------------------------------
-- Initialize and reset mission variables
-----------------------------------------------------------------------------------------
function CF_InitMission(config)
	print("CF_InitMission")
	CF_Activity:SetTeamFunds(tonumber(config["PlayerGold"]), CF_PlayerTeam)
	CF_AIBudget = tonumber(config["LastMissionAIBudget"])

	CF_PlayerFaction = CF_GetPlayerFaction(config)
	CF_CPUFaction = CF_GetCPUFaction(config)
end
-----------------------------------------------------------------------------------------
-- Transfers player to strategy screen after 3 second of victory message
-----------------------------------------------------------------------------------------
function CF_ReturnOnMissionEnd()
	if not CF_StartReturnCountdown then
		if CF_Activity.ActivityState == Activity.OVER then
			CF_StartReturnCountdown = true
			CF_MissionEndTimer:Reset()
		end
	end

	if CF_StartReturnCountdown then
		if CF_MissionEndTimer:IsPastSimMS(CF_MissionReturnInterval) then
			--CF_LaunchMissionActivity("Unmapped Lands 2");
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_StartMusic(modulename, musicfile)
	local path = "" .. modulename .. "/Music/" .. musicfile

	if CF_IsFilePathExists(path) then
		AudioMan:ClearMusicQueue()
		AudioMan:PlayMusic(path, -1, -1)
	end
end
-----------------------------------------------------------------------------------------
-- For a given char returns its index, width, vector offsset  if any
-----------------------------------------------------------------------------------------
function CF_GetCharData(char)
	if CF_Chars == nil then
		CF_Chars = {}
		CF_Chars[" "] = { 1, 8, nil }
		CF_Chars["!"] = { 2, 5, Vector(-3, 0) }
		CF_Chars['"'] = { 3, 8, Vector(0, -2) }
		CF_Chars["#"] = { 4, 8, nil }
		CF_Chars["$"] = { 5, 8, nil }
		CF_Chars["%"] = { 6, 8, nil }
		CF_Chars["&"] = { 7, 6, Vector(-2, 0) }
		CF_Chars["`"] = { 8, 5, Vector(-3, -2) }
		CF_Chars["("] = { 9, 6, Vector(-1, 0) }
		CF_Chars[")"] = { 10, 6, Vector(-2, 0) }
		CF_Chars["*"] = { 11, 6, Vector(-2, 0) }
		CF_Chars["+"] = { 12, 8, nil }
		CF_Chars[","] = { 13, 5, Vector(-3, 5) }
		CF_Chars["-"] = { 14, 9, nil }
		CF_Chars["."] = { 15, 5, Vector(-3, 4) }
		CF_Chars["/"] = { 16, 6, Vector(-1, 0) }
		CF_Chars["0"] = { 17, 9, nil }
		CF_Chars["1"] = { 18, 6, Vector(-2, 0) }
		CF_Chars["2"] = { 19, 8, nil }
		CF_Chars["3"] = { 20, 8, nil }
		CF_Chars["4"] = { 21, 8, nil }
		CF_Chars["5"] = { 22, 8, nil }
		CF_Chars["6"] = { 23, 8, nil }
		CF_Chars["7"] = { 24, 8, nil }
		CF_Chars["8"] = { 25, 8, nil }
		CF_Chars["9"] = { 26, 8, nil }
		CF_Chars[":"] = { 27, 5, Vector(-3, -1) }
		CF_Chars[";"] = { 28, 5, Vector(-3, -1) }
		CF_Chars["<"] = { 29, 7, Vector(-1, 0) }
		CF_Chars["="] = { 30, 8, Vector(0, -1) }
		CF_Chars[">"] = { 31, 7, Vector(-1, 0) }
		CF_Chars["?"] = { 32, 8, nil }
		CF_Chars["@"] = { 33, 11, Vector(0, -1) }
		CF_Chars["A"] = { 34, 8, nil }
		CF_Chars["B"] = { 35, 8, nil }
		CF_Chars["C"] = { 36, 8, Vector(0, -3) }
		CF_Chars["D"] = { 37, 9, nil }
		CF_Chars["E"] = { 38, 8, nil }
		CF_Chars["F"] = { 39, 8, nil }
		CF_Chars["G"] = { 40, 8, nil }
		CF_Chars["H"] = { 41, 8, nil }
		CF_Chars["I"] = { 42, 6, Vector(-2, 0) }
		CF_Chars["J"] = { 43, 8, nil }
		CF_Chars["K"] = { 44, 8, nil }
		CF_Chars["L"] = { 45, 8, Vector(0, 3) }
		CF_Chars["M"] = { 46, 10, Vector(2, -1) }
		CF_Chars["N"] = { 47, 8, nil }
		CF_Chars["O"] = { 48, 8, nil }
		CF_Chars["P"] = { 49, 8, nil }
		CF_Chars["Q"] = { 50, 8, nil }
		CF_Chars["R"] = { 51, 8, nil }
		CF_Chars["S"] = { 52, 8, nil }
		CF_Chars["T"] = { 53, 7, Vector(-1, 0) }
		CF_Chars["U"] = { 54, 8, nil }
		CF_Chars["V"] = { 55, 8, nil }
		CF_Chars["W"] = { 56, 10, Vector(2, 0) }
		CF_Chars["X"] = { 57, 8, nil }
		CF_Chars["Y"] = { 58, 8, nil }
		CF_Chars["Z"] = { 59, 8, nil }
		CF_Chars["["] = { 60, 6, Vector(-1, 0) }
		CF_Chars["\\"] = { 61, 6, Vector(-1, 0) }
		CF_Chars["]"] = { 62, 6, Vector(-1, 0) }
		CF_Chars["^"] = { 63, 8, Vector(-1, -3) }
		CF_Chars["_"] = { 64, 8, Vector(0, 4) }
		CF_Chars["'"] = { 65, 8, Vector(0, -3) }
		CF_Chars["a"] = { 66, 8, nil }
		CF_Chars["b"] = { 67, 8, nil }
		CF_Chars["c"] = { 68, 8, nil }
		CF_Chars["d"] = { 69, 8, nil }
		CF_Chars["e"] = { 70, 8, nil }
		CF_Chars["f"] = { 71, 8, nil }
		CF_Chars["g"] = { 72, 8, nil }
		CF_Chars["h"] = { 73, 8, nil }
		CF_Chars["i"] = { 74, 5, Vector(-3, 0) }
		CF_Chars["j"] = { 75, 6, Vector(-2, 0) }
		CF_Chars["k"] = { 76, 8, nil }
		CF_Chars["l"] = { 77, 5, Vector(-3, 0) }
		CF_Chars["m"] = { 78, 10, nil }
		CF_Chars["n"] = { 79, 8, nil }
		CF_Chars["o"] = { 80, 8, nil }
		CF_Chars["p"] = { 81, 8, nil }
		CF_Chars["q"] = { 82, 8, nil }
		CF_Chars["r"] = { 83, 9, Vector(1, 0) }
		CF_Chars["s"] = { 84, 8, nil }
		CF_Chars["t"] = { 85, 8, nil }
		CF_Chars["u"] = { 86, 8, nil }
		CF_Chars["v"] = { 87, 8, nil }
		CF_Chars["w"] = { 88, 10, Vector(1, 0) }
		CF_Chars["x"] = { 89, 8, nil }
		CF_Chars["y"] = { 90, 8, nil }
		CF_Chars["z"] = { 91, 8, nil }
		CF_Chars["{"] = { 92, 7, nil }
		CF_Chars["|"] = { 93, 7, nil }
		CF_Chars["}"] = { 94, 7, nil }
		CF_Chars["~"] = { 95, 8, nil }
	end

	local i = nil

	i = CF_Chars[char]

	if i == nil then
		i = { 96, 8, nil }
	end

	return i[1], i[2] - 2, i[3]
end
--------------------------------------------------------------------------
-- Return size of string in pixels
-----------------------------------------------------------------------------
function CF_GetStringPixelWidth(str)
	local len = 0
	for i = 1, #str do
		local cindex, cwidth, coffset = CF_GetCharData(string.sub(str, i, i))
		len = len + cwidth
	end
	return len - #str
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_Split(str, pat)
	local t = {} -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t, cap)
		end
		last_end = e + 1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end
-----------------------------------------------------------------------------
-- Draw string on screen at speicified pos not wider that width and not higher than height
-----------------------------------------------------------------------------
function CF_DrawString(str, pos, width, height)
	--TODO: Implement Primitive version
	--PrimitiveMan:DrawTextPrimitive(pos, str, false, 0)
	local x = pos.X
	local y = pos.Y
	local chr
	local drawthistime
	local letterpreset = "Ltr"

	local words = CF_Split(str, " ")
	for w = 1, #words do
		drawthistime = true

		if x + CF_GetStringPixelWidth(words[w]) > pos.X + width then
			x = pos.X
			y = y + 11

			if y > pos.Y + height then
				return
			end
		end

		for i = 1, #words[w] do
			chr = string.sub(words[w], i, i)

			if chr == "\n" then
				x = pos.X
				y = y + 12

				if y > pos.Y + height then
					return
				end
			else
				local cindex, cwidth, coffset = CF_GetCharData(chr)

				local pix = CreateMOPixel(letterpreset .. cindex)
				local offset = coffset
				if offset ~= nil then
					pix.Pos = Vector(x, y) + offset
				else
					pix.Pos = Vector(x, y)
				end

				MovableMan:AddParticle(pix)

				x = x + cwidth
			end
		end

		-- Simulate space character, only if we're not at the begining of new line
		if x ~= pos.X then
			x = x + 6
		end
	end
end
-----------------------------------------------------------------------------
-- Converts time in second to string h:mm:ss
-----------------------------------------------------------------------------
function CF_ConvertTimeToString(timenum)
	local timestr = ""

	local hours = (timenum - timenum % 3600) / 3600
	--print ("Hours "..hours)
	timenum = timenum - hours * 3600
	local minutes = (timenum - timenum % 60) / 60
	--print ("Minutes "..minutes)
	timenum = timenum - minutes * 60
	local seconds = timenum
	--print ("Minutes "..seconds)

	if hours > 0 then
		timestr = timestr .. string.format("%d", hours) .. ":"
	end

	local s
	s = tostring(minutes)
	if #s < 2 then
		s = "0" .. s
	end
	timestr = timestr .. s .. ":"

	s = tostring(seconds)
	if #s < 2 then
		s = "0" .. s
	end
	timestr = timestr .. s

	return timestr
end
-----------------------------------------------------------------------------------------
-- Make item of specified preset, module and class
-----------------------------------------------------------------------------------------
function CF_MakeItem(preset, class, module)
	local item
	if class == nil then
		class = "HDFirearm"
	end
	if class == "HeldDevice" then
		item = module == nil and CreateHeldDevice(preset) or CreateHeldDevice(preset, module)
	elseif class == "HDFirearm" then
		item = module == nil and CreateHDFirearm(preset) or CreateHDFirearm(preset, module)
		--if ammo then
		--	item:SetNumberValue("FA_RoundCount", ammo)
		--end
	elseif class == "TDExplosive" then
		item = module == nil and CreateTDExplosive(preset) or CreateTDExplosive(preset, module)
	elseif class == "ThrownDevice" then
		item = module == nil and CreateThrownDevice(preset) or CreateThrownDevice(preset, module)
	end
	return item
end
-----------------------------------------------------------------------------------------
-- Make actor of specified preset, class, module, rank and identity
-----------------------------------------------------------------------------------------
function CF_MakeActor(item, class, module, xp, identity, prestige, name, limbs)
	local actor
	if class == nil then
		class = "AHuman"
	end
	if item == nil then
		item = "Skeleton"
	end
	if class == "AHuman" then
		actor = module == nil and CreateAHuman(item) or CreateAHuman(item, module)
		if limbs then
			CF_ReplaceLimbs(actor, limbs)
		end
		for item in actor.Inventory do
			if item then
				actor:RemoveInventoryItem(item.PresetName)
			end
		end
	elseif class == "ACrab" then
		actor = module == nil and CreateACrab(item) or CreateACrab(item, module)
	elseif class == "Actor" then
		actor = module == nil and CreateActor(item) or CreateActor(item, module)
	elseif class == "ACDropShip" then
		actor = module == nil and CreateACDropShip(item) or CreateACDropShip(item, module)
	elseif class == "ACRocket" then
		actor = module == nil and CreateACRocket(item) or CreateACRocket(item, module)
	end
	if actor then
		actor.AngularVel = 0
		if identity then
			actor:SetNumberValue("Identity", tonumber(identity))
		end
		if prestige then
			actor:SetNumberValue("VW_Prestige", tonumber(prestige))
			if name then
				actor:SetStringValue("VW_Name", name)
			end
		end
		if xp then
			xp = tonumber(xp)
			actor:SetNumberValue("VW_XP", xp)
			local setRank
			for rank = 1, #CF_Ranks do
				if xp >= CF_Ranks[rank] then
					setRank = rank
				else
					break
				end
			end
			if setRank then
				actor:SetNumberValue("VW_Rank", setRank)
				CF_BuffActor(actor, setRank, actor:GetNumberValue("VW_Prestige"))
			end
			if xp >= CF_Ranks[#CF_Ranks] then
				actor.PieMenu:AddPieSliceIfPresetNameIsUnique(CF_PrestigeSlice:Clone(), self)
			end
		end
	else
		actor = CreateAHuman("Skeleton", "Uzira.rte")
	end
	return actor
end
-----------------------------------------------------------------------------------------
-- Buff an actor based on their rank
-----------------------------------------------------------------------------------------
function CF_BuffActor(actor, rank, prestige)
	rank = tonumber(rank) * math.sqrt(prestige * 0.1 + 1)
	local rankIncrement = rank * 0.1
	rank = math.floor(rank + 0.5)
	local rankFactor = 1 + rankIncrement
	local sqrtFactor = math.sqrt(rankFactor)
	-- Positive scalar
	actor.Perceptiveness = actor.Perceptiveness * rankFactor
	actor.ImpulseDamageThreshold = actor.ImpulseDamageThreshold * rankFactor
	actor.GibImpulseLimit = actor.GibImpulseLimit * rankFactor + (prestige * actor.Mass)
	actor.GibWoundLimit = actor.GibWoundLimit * rankFactor + prestige
	-- Occasional increment
	if actor.GibWoundLimit > 0 then
		actor.GibWoundLimit = actor.GibWoundLimit + rank
	end
	if actor.GibImpulseLimit > 0 then
		actor.GibImpulseLimit = actor.GibImpulseLimit + rank * 100
	end
	-- Negative scalar
	actor.DamageMultiplier = actor.DamageMultiplier / (rankFactor + prestige)

	for att in actor.Attachables do
		att.GibWoundLimit = att.GibWoundLimit * rankFactor + prestige
		att.GibImpulseLimit = att.GibImpulseLimit * rankFactor + (prestige * att.Mass)
		att.JointStrength = att.JointStrength * rankFactor + (prestige * att.Mass)
		att.DamageMultiplier = att.DamageMultiplier / (rankFactor + prestige)
		if att.GibWoundLimit > 0 then
			att.GibWoundLimit = att.GibWoundLimit + rank
		end
		if att.JointStrength > 0 then
			att.JointStrength = att.JointStrength + rank * 25
		end
		if att.GibImpulseLimit > 0 then
			att.GibImpulseLimit = att.GibImpulseLimit + rank * 50
		end
	end
	if actor.Jetpack then
		actor.Jetpack.JetTimeTotal = actor.Jetpack.JetTimeTotal * sqrtFactor
		for em in actor.Jetpack.Emissions do
			em.ParticlesPerMinute = em.ParticlesPerMinute * sqrtFactor
			em.BurstSize = em.BurstSize * sqrtFactor
		end
	end
	local arms = { actor.FGArm, actor.BGArm }
	for _, arm in pairs(arms) do
		if arm then
			arm.GripStrength = rank * 10 + arm.GripStrength * rankFactor
			arm.ThrowStrength = arm.ThrowStrength * sqrtFactor
		end
	end
	actor:SetLimbPathSpeed(1, actor:GetLimbPathSpeed(1) * sqrtFactor)
	actor.LimbPathPushForce = actor.LimbPathPushForce * math.sqrt(sqrtFactor)
	--print("actor ".. actor.PresetName .." buffed with" .. (prestige and " prestige " or "rank ").. rank);
end
-----------------------------------------------------------------------------------------
-- Reverse buff effect
-----------------------------------------------------------------------------------------
function CF_UnBuffActor(actor, rank, prestige)
	local rankFactor = 1 + (tonumber(rank) * 0.1 * math.sqrt(prestige * 0.1 + 1))
	local sqrtFactor = math.sqrt(rankFactor)
	-- Positive scalar
	actor.Perceptiveness = actor.Perceptiveness / rankFactor
	actor.ImpulseDamageThreshold = actor.ImpulseDamageThreshold / rankFactor
	actor.GibImpulseLimit = actor.GibImpulseLimit / rankFactor
	actor.GibWoundLimit = actor.GibWoundLimit / rankFactor
	-- Negative scalar
	actor.DamageMultiplier = actor.DamageMultiplier * rankFactor

	for att in actor.Attachables do
		att.GibWoundLimit = att.GibWoundLimit / rankFactor
		att.GibImpulseLimit = att.GibImpulseLimit / rankFactor
		att.JointStrength = att.JointStrength / rankFactor
		att.DamageMultiplier = att.DamageMultiplier * rankFactor
	end
	if actor.Jetpack then
		actor.Jetpack.JetTimeTotal = actor.Jetpack.JetTimeTotal / sqrtFactor
		for em in actor.Jetpack.Emissions do
			em.ParticlesPerMinute = em.ParticlesPerMinute / sqrtFactor
			em.BurstSize = em.BurstSize / sqrtFactor
		end
	end
	local arms = { actor.FGArm, actor.BGArm }
	for _, arm in pairs(arms) do
		if arm then
			arm.GripStrength = arm.GripStrength / rankFactor
			arm.ThrowStrength = arm.ThrowStrength / sqrtFactor
		end
	end
	actor:SetLimbPathSpeed(1, actor:GetLimbPathSpeed(1) / sqrtFactor)
	actor.LimbPathPushForce = actor.LimbPathPushForce / (math.sqrt(sqrtFactor))
end
-----------------------------------------------------------------------------------------
-- Get a specific limb by ID
-----------------------------------------------------------------------------------------
function CF_GetLimbData(actor, id)
	local limb
	if IsAHuman(actor) then
		actor = ToAHuman(actor)
		if id == 1 then
			limb = actor.FGArm
		elseif id == 2 then
			limb = actor.BGArm
		elseif id == 3 then
			limb = actor.FGLeg
		elseif id == 4 then
			limb = actor.BGLeg
		elseif id == 5 then
			limb = actor.Head
		elseif id == 6 then
			limb = actor.Jetpack
		end
		return (limb and limb:GetModuleAndPresetName() or "Null")
	elseif IsACrab(actor) then
		actor = ToACrab(actor)
		if id == 1 then
			limb = actor.LFGLeg
		elseif id == 2 then
			limb = actor.LBGLeg
		elseif id == 3 then
			limb = actor.RFGLeg
		elseif id == 4 then
			limb = actor.RBGLeg
		end
		return (limb and limb:GetModuleAndPresetName() or "Null")
	end
	return ""
end
-----------------------------------------------------------------------------------------
-- Read the limb data of this AHuman and replace limbs accordingly
-----------------------------------------------------------------------------------------
function CF_ReplaceLimbs(actor, limbs)
	if IsAHuman(actor) then
		actor = ToAHuman(actor)
		for j = 1, #CF_LimbID do
			local jetTime
			local jetReplenishRate
			local particlesPerMinute

			if j == 6 and actor.Jetpack then
				-- ugly ugly ugly ugly codeeee
				jetTime = actor.Jetpack.JetTimeTotal
				jetReplenishRate = actor.Jetpack.JetReplenishRate
				particlesPerMinute = actor.Jetpack.ParticlesPerMinute
			end

			local targetLimb = j == 1 and actor.FGArm
				or (
					j == 2 and actor.BGArm
					or (j == 3 and actor.FGLeg or (j == 4 and actor.BGLeg or (j == 5 and actor.Head or actor.Jetpack)))
				)
			local origLimbName = targetLimb and targetLimb:GetModuleAndPresetName() or "Null"
			local limbString = limbs[j] or origLimbName
			if limbString ~= "Null" then
				local newLimb
				if j == 5 then --Head
					newLimb = CreateAttachable(limbString)
					--Try to create Heads of other subclasses if we can't find an Attachable
					if newLimb == nil then
						print("This is fine, trying to find Head as HeldDevice...")
						newLimb = CreateHeldDevice(limbString)
					end
					if newLimb == nil then
						print("It's still fine, trying to find Head as AEmitter...")
						newLimb = CreateAEmitter(limbString)
					end
				else
					newLimb = (j == 1 or j == 2) and CreateArm(limbString)
						or (j == 6 and CreateAEJetpack(limbString) or CreateLeg(limbString))
				end
				if newLimb == nil then
					print("ERROR: CF_ReplaceLimbs: Limb not found!! Not OK!!")
					break
				end
				if targetLimb then
					newLimb.ParentOffset = targetLimb.ParentOffset
					if j >= 5 then
						newLimb.DrawnAfterParent = targetLimb.DrawnAfterParent
					elseif targetLimb.EntryWound then
						newLimb.ParentBreakWound = ToAEmitter(targetLimb.EntryWound):Clone()
					end
				end
				--Can't use a temp pointer to set limbs... refer to the ID
				if j == 1 then
					actor.FGArm = newLimb
				elseif j == 2 then
					actor.BGArm = newLimb
				elseif j == 3 then
					actor.FGLeg = newLimb
				elseif j == 4 then
					actor.BGLeg = newLimb
				elseif j == 5 then
					actor.Head = newLimb
				elseif j == 6 then
					actor.Jetpack = newLimb
					actor.Jetpack.JetTimeTotal = jetTime
					actor.Jetpack.JetReplenishRate = jetReplenishRate
					actor.Jetpack.ParticlesPerMinute = particlesPerMinute
				end
			elseif targetLimb then
				actor:RemoveAttachable(targetLimb, false, false)
			end
			actor:SetStringValue(CF_LimbID[j], limbString)
		end
		-- Replace helmets etc.
		if actor.Head and #limbs > #CF_LimbID then
			for att in actor.Head.Attachables do
				if att.DamageMultiplier == 0 then
					actor.Head:RemoveAttachable(att, false, false)
				end
			end
			for i = #CF_LimbID + 1, #CF_LimbID + #limbs do
				local limbString = limbs[i]
				newLimb = CreateAttachable(limbString)
				if newLimb == nil then
					print("This is fine, trying to find attachable as HeldDevice...")
					newLimb = CreateHeldDevice(limbString)
				end
				if newLimb == nil then
					print("It's still fine, trying to find attachable as AEmitter...")
					newLimb = CreateAEmitter(limbString)
				end
				if newLimb then
					actor.Head:AddAttachable(newLimb)
				end
			end
		end
		return true
	elseif IsACrab(actor) then
		actor = ToACrab(actor)
		--Todo
		return false
	end
	return false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_AttemptReplaceLimb(actor, limb)
	local j = 0
	local isArm = string.find(limb.PresetName, " Arm")
	local isLeg = string.find(limb.PresetName, " Leg")
	local isHead = string.find(limb.PresetName, " Head")
	local limbName = limb:StringValueExists("LimbName") and limb:GetStringValue("LimbName") or limb.PresetName
	if isArm then
		j = not actor.FGArm and 1 or (not actor.BGArm and 2 or j)
	elseif isLeg then
		j = not actor.FGLeg and 3 or (not actor.BGLeg and 4 or j)
	elseif isHead and actor.Head == nil then
		j = 5
	end
	if j ~= 0 then
		local reference = CreateAHuman(actor:GetModuleAndPresetName())
		local referenceLimb
		if j == 1 then
			referenceLimb = reference.FGArm
		elseif j == 2 then
			referenceLimb = reference.BGArm
		elseif j == 3 then
			referenceLimb = reference.FGLeg
		elseif j == 4 then
			referenceLimb = reference.BGLeg
		elseif j == 5 then
			referenceLimb = reference.Head
		end
		local newLimb
		if isArm then
			newLimb = CreateArm(limbName .. (j == 1 and " FG" or " BG"))
		elseif isLeg then
			newLimb = CreateLeg(limbName .. (j == 3 and " FG" or " BG"))
		else
			newLimb = limb:Clone() --(limbName);
		end
		if newLimb then
			if referenceLimb then
				newLimb.ParentOffset = referenceLimb.ParentOffset
				local woundName = referenceLimb:GetEntryWoundPresetName()
				if woundName ~= "" then
					newLimb.ParentBreakWound = CreateAEmitter(woundName)
				end
			end
			for wound in newLimb.Wounds do
				if
					math.floor(wound.ParentOffset.X - newLimb.JointOffset.X + 0.5) == 0
					and math.floor(wound.ParentOffset.Y - newLimb.JointOffset.Y + 0.5) == 0
				then
					for em in wound.Emissions do
						em.ParticlesPerMinute = 0
					end
					wound.Scale = wound.Scale * 0.7
				end
			end
			if j == 1 then
				actor.FGArm = newLimb
			elseif j == 2 then
				actor.BGArm = newLimb
			elseif j == 3 then
				actor.FGLeg = newLimb
			elseif j == 4 then
				actor.BGLeg = newLimb
			elseif j == 5 then
				actor.Head = newLimb
			end
			for wound in actor.Wounds do
				if
					math.floor(wound.ParentOffset.X - newLimb.ParentOffset.X + 0.5) == 0
					and math.floor(wound.ParentOffset.Y - newLimb.ParentOffset.Y + 0.5) == 0
				then
					for em in wound.Emissions do
						em.ParticlesPerMinute = 0
					end
					wound.Scale = wound.Scale * 0.7
				end
			end
			limb:RemoveNumberValue("Carriable")
		else
			j = 0
		end
		DeleteEntity(reference)
	end
	return j ~= 0
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_RandomizeLimbs(actor, limbs)
	if IsAHuman(actor) then
		actor = ToAHuman(actor)
		local reference = RandomAHuman("Actors - Heavy", actor.ModuleName)
		if reference then
			if reference.PresetName == actor.PresetName then
				return false
			end
			local rand = math.random()
			if rand < 0.66 and actor.Head and reference.Head then
				local organicHead = string.find(actor.Head.PresetName, "Flesh")
				local matchingHead = string.find(reference.Head.PresetName, "Flesh") == organicHead
				if matchingHead and reference.Head.ClassName == "Attachable" then
					local newHead = CreateAttachable(reference.Head.PresetName, reference.ModuleName)
					newHead.ParentOffset = actor.Head.ParentOffset
					newHead.DrawnAfterParent = actor.Head.DrawnAfterParent
					actor.Head = newHead
				end
			end
			if rand < 0.33 or rand > 0.66 then
				if actor.FGArm and reference.FGArm then
					local newArm = CreateArm(reference.FGArm.PresetName, reference.ModuleName)
					newArm.ParentOffset = actor.FGArm.ParentOffset
					actor.FGArm = newArm
				end
				if actor.BGArm and reference.BGArm then
					local newArm = CreateArm(reference.BGArm.PresetName, reference.ModuleName)
					newArm.ParentOffset = actor.BGArm.ParentOffset
					actor.BGArm = newArm
				end
			end
			if math.random() <= actor:GetNumberValue("VW_XP") / CF_Ranks[#CF_Ranks] then
				CF_SetRandomName(actor)
			end
		end
		return true
	elseif IsACrab(actor) then
		actor = ToACrab(actor)
		--Todo
		return false
	end
	return false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_SetRandomName(actor)
	if not actor:StringValueExists("VW_Name") then
		actor:SetStringValue("VW_Name", CF_GenerateRandomName())
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_GenerateRandomName()
	local name = ""
	local rand = math.random()
	if rand < 0.25 then --First + Second + Third
		name = CF_RandomNames[1][math.random(#CF_RandomNames[1])]
			.. " "
			.. CF_RandomNames[2][math.random(#CF_RandomNames[2])]
			.. " "
			.. CF_RandomNames[3][math.random(#CF_RandomNames[3])]
	elseif rand < 0.50 then --First + Second
		name = CF_RandomNames[1][math.random(#CF_RandomNames[1])]
			.. " "
			.. CF_RandomNames[2][math.random(#CF_RandomNames[2])]
	elseif rand < 0.75 then --Second + Third
		name = CF_RandomNames[2][math.random(#CF_RandomNames[2])]
			.. " "
			.. CF_RandomNames[3][math.random(#CF_RandomNames[3])]
	else --First + Third
		name = CF_RandomNames[1][math.random(#CF_RandomNames[1])]
			.. " "
			.. CF_RandomNames[3][math.random(#CF_RandomNames[3])]
	end
	return name
end
-----------------------------------------------------------------------------------------
-- Set actors to hunt for nearby actors of a specific team - or regroup near actors of the same team
-----------------------------------------------------------------------------------------
function CF_HuntForActors(hunter, targetTeam)
	if hunter and MovableMan:IsActor(hunter) and hunter.AIMode == Actor.AIMODE_SENTRY then
		local enemies = {}
		local brains = {}
		local closestActor, closestDistance
		for target in MovableMan.Actors do
			if
				(targetTeam == nil or targetTeam == Activity.NOTEAM or target.Team == targetTeam)
				and target.ID ~= hunter.ID
				and (target.ClassName == "AHuman" or target.ClassName == "ACrab")
			then
				table.insert(enemies, target)
				local dist = SceneMan:ShortestDistance(hunter.Pos, target.Pos, SceneMan.SceneWrapsX)
				if not closestDistance or dist:MagnitudeIsLessThan(closestDistance) then
					closestDistance = dist.Magnitude
					closestActor = target
				end
				if target:HasObjectInGroup("Brains") then
					table.insert(brains, target)
				end
			end
		end
		local target
		if #brains > 0 and math.random(150) < CF_Difficulty then
			hunter.AIMode = Actor.AIMODE_GOTO
			target = brains[math.random(#brains)]
			hunter:AddAIMOWaypoint(target)
		elseif #enemies > 0 then
			hunter.AIMode = Actor.AIMODE_GOTO
			target = math.random() * SceneMan.SceneWidth * 0.3 > closestDistance and closestActor
				or enemies[math.random(#enemies)]
			if SceneMan:IsUnseen(target.Pos.X, target.Pos.Y, hunter.Team) then
				hunter:AddAISceneWaypoint(target.Pos)
			else
				hunter:AddAIMOWaypoint(target)
			end
		else
			hunter.AIMode = Actor.AIMODE_PATROL
		end
		return target
	end
	return nil
end
-----------------------------------------------------------------------------------------
-- Send actors after specific target(s)
-----------------------------------------------------------------------------------------
function CF_Hunt(hunter, targets)
	if hunter and MovableMan:IsActor(hunter) and #targets > 0 then
		local target = targets[math.random(#targets)]
		if target then
			hunter.AIMode = Actor.AIMODE_GOTO
			hunter:ClearMovePath()
			if MovableMan:IsActor(target) and not SceneMan:IsUnseen(target.Pos.X, target.Pos.Y, hunter.Team) then
				hunter:AddAIMOWaypoint(target)
			elseif IsActor(target) then
				hunter:AddAISceneWaypoint(target.Pos)
			end
			hunter:UpdateMovePath()
			return true
		end
		hunter.AIMode = Actor.AIMODE_PATROL
	end
	return false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_GetPlayerGold(c, p)
	local v = c["Player" .. p .. "Gold"]
	if v == nil then
		v = 0
	end

	return tonumber(v)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_SetPlayerGold(c, p, funds)
	-- Set the in-activity gold as well, although we don't use it
	CF_Activity:SetTeamFunds(funds, p)

	c["Player" .. p .. "Gold"] = math.ceil(funds)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_CommitMissionResult(c, result)
	-- Set result
	c["LastMissionResult"] = result
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_PayGold(c, p, amount)
	local gold = CF_GetPlayerGold(c, p) - amount

	CF_SetPlayerGold(c, p, gold)
end
-----------------------------------------------------------------------------------------
-- Get table with inventory of actor, inventory cleared as a result
-----------------------------------------------------------------------------------------
function CF_GetInventory(actor)
	--print("GetInventory")
	local inventory = {}
	local classes = {}
	local modules = {}

	if IsActor(actor) then
		if actor.ClassName == "AHuman" then
			local human = ToAHuman(actor)
			local equipped = { human.EquippedItem, human.EquippedBGItem }
			for _, item in pairs(equipped) do
				if item then
					local skip = false

					if CF_DiscardableItems[actor.PresetName] ~= nil then
						for i = 1, #CF_DiscardableItems[actor.PresetName] do
							if CF_DiscardableItems[actor.PresetName][i] == item.PresetName then
								skip = true
								break
							end
						end
					end

					if not skip then
						inventory[#inventory + 1] = item.PresetName
						classes[#classes + 1] = item.ClassName
						modules[#modules + 1] = item.ModuleName
					end
				end
			end
		end

		if not actor:IsInventoryEmpty() then
			for item in actor.Inventory do
				local skip = false

				if CF_DiscardableItems[actor.PresetName] ~= nil then
					for i = 1, #CF_DiscardableItems[actor.PresetName] do
						if CF_DiscardableItems[actor.PresetName][i] == item.PresetName then
							skip = true
							break
						end
					end
				end

				if not skip then
					inventory[#inventory + 1] = item.PresetName
					classes[#classes + 1] = item.ClassName
					modules[#modules + 1] = item.ModuleName
				end
			end
		end
	else
		--print("Actor: ")
		--print(actor);
	end

	return inventory, classes, modules
end
-----------------------------------------------------------------------------------------
-- Calculate distance
-----------------------------------------------------------------------------------------
function CF_Dist(pos1, pos2)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX).Magnitude
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_DistOver(pos1, pos2, magnitude)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX):MagnitudeIsGreaterThan(magnitude)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_DistUnder(pos1, pos2, magnitude)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX):MagnitudeIsLessThan(magnitude)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_CountActors(team)
	local c = 0

	for actor in MovableMan.Actors do
		if
			actor.Team == team
			and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
			and not (actor:IsInGroup("Brains") or actor:NumberValueExists("VW_Ally"))
		then
			c = c + 1
		end
	end

	return c
end
-----------------------------------------------------------------------------------------
--	Returns how many science points corresponds to selected difficulty level
-----------------------------------------------------------------------------------------
function CF_GetTechLevelFromDifficulty(c, p, diff, maxdiff)
	local maxpoints = 0
	local f = CF_GetPlayerFaction(c, p)

	for i = 1, #CF_ItmNames[f] do
		if CF_ItmUnlockData[f][i] > maxpoints then
			maxpoints = CF_ItmUnlockData[f][i]
		end
	end

	for i = 1, #CF_ActNames[f] do
		if CF_ActUnlockData[f][i] > maxpoints then
			maxpoints = CF_ActUnlockData[f][i]
		end
	end

	return math.floor(maxpoints / maxdiff * diff)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_CalculateReward(base, diff)
	local coeff = 1 + (diff - 1) * 0.35

	return math.floor(base * coeff)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_IsLocationHasAttribute(loc, attr)
	local attrs = CF_LocationAttributes[loc]

	if attrs ~= nil then
		for i = 1, #attrs do
			if attrs[i] == attr then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_GiveExp(c, exppts)
	local levelup = false

	for p = 0, 3 do
		local curexp = tonumber(c["Brain" .. p .. "Exp"])
		local cursklpts = tonumber(c["Brain" .. p .. "SkillPoints"])
		local curlvl = tonumber(c["Brain" .. p .. "Level"])

		--print ("Curexp "..curexp)
		--print ("Exppts "..exppts)

		curexp = curexp + exppts

		--print (CF_ExpPerLevel)
		--print (math.floor(curexp / CF_ExpPerLevel))

		while math.floor(curexp / CF_ExpPerLevel) > 0 do
			if curlvl < CF_MaxLevel then
				curexp = curexp - CF_ExpPerLevel
				cursklpts = cursklpts + 1
				curlvl = curlvl + 1
				levelup = true

				--print (levelup)
			else
				curexp = 0
				break
			end
		end

		c["Brain" .. p .. "SkillPoints"] = cursklpts
		c["Brain" .. p .. "Exp"] = curexp
		c["Brain" .. p .. "Level"] = curlvl
	end

	return levelup
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
