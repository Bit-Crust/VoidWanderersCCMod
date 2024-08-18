-----------------------------------------------------------------------------------------
-- Generic functions to add to library
-----------------------------------------------------------------------------------------

CF = {}

-----------------------------------------------------------------------------------------
-- Initialize global faction lists
-----------------------------------------------------------------------------------------
CF.InitFactions = function(activity)
	print("CF.InitFactions")
	CF.CPUTeam = Activity.TEAM_2
	CF.PlayerTeam = Activity.TEAM_1
	CF.RogueTeam = Activity.NOTEAM
	CF.MOIDLimit = math.huge
	CF.ModuleName = "VoidWanderers.rte"

	CF.Difficulty = CHOSEN_DIFFICULTY
	CF.AISkillPlayer = CHOSEN_AISKILLPLAYER
	CF.AISkillCPU = CHOSEN_AISKILLCPU

	-- Used in flight mode
	CF.KmPerPixel = 100

	CF.BlackMarketRefreshInterval = 1200
	CF.BlackMarketPriceMultiplier = 3

	CF.MissionResultShowInterval = 10

	CF.UnknownItemPrice = 50
	CF.UnknownActorPrice = 100

	CF.TechPriceMultiplier = 1.5
	CF.SellPriceCoeff = 0.25

	CF.OrdersRange = 175

	CF.MaxMissions = 25

	CF.MaxHolograms = 23

	CF.BombsPerBay = 5
	CF.BombInterval = 1
	CF.BombLoadInterval = 2
	CF.BombFlightInterval = 10
	CF.BombSeenRange = 150
	CF.BombUnseenRange = 400

	CF.KeyRepeatDelay = 100

	CF.MaxLevel = 150
	CF.ExpPerLevel = 250

	CF.Ranks = { 50, 125, 250, 500, 1000 }
	CF.PrestigeSlice = CreatePieSlice("Prestige PieSlice", CF.ModuleName)

	CF.PermanentLimbLoss = true
	CF.LimbID = { "FG1", "BG1", "FG2", "BG2", "HEAD", "JETPAK" }

	CF.QuantumCapacityPerLevel = 50
	CF.QuantumSplitterEffectiveness = 0.2

	CF.SecurityIncrementPerMission = 10
	CF.SecurityIncrementPerDeployment = 2

	CF.ReputationPerDifficulty = 1000

	CF.RandomEncounterProbability = 0.15

	-- When reputation is below this level, the enemy starts attacking the player
	CF.ReputationHuntThreshold = -500

	-- The rate of reputation points subtracted from the mission target faction
	CF.ReputationPenaltyRatio = 1.75

	-- The rate of reputation points subtracted from both reputations when failing a mission
	CF.MissionFailedReputationPenaltyRatio = 0.3

	CF.EnableIcons = true

	-- When enabled UL2 will use special rendering techniques to improve UI rendering
	-- performance on weaker machines. Some artifacts may appear though.
	CF.LowPerformance = false

	-- The idea behind this optimization is that creation of particles eats most of the time.
	-- To avoid that we draw some words and buttons on odd frames and some on even frames.
	-- When in LowPerformance mode CF.DrawString and DrawButton functions will use special Ln-prefixed
	-- versions of UI glows, which live twice longer. In order to work main execution thread must
	-- count frames so other function can decide if it's odd or even frame right now
	CF.FrameCounter = 0

	CF.ShipAssaultDelay = 30
	CF.ShipCounterattackDelay = 20
	CF.ShipAssaultCooldown = 150

	CF.TeamReturnDelay = 5

	CF.CratesRate = 0.25 -- Percentage of cases among available case spawn points
	CF.ActorCratesRate = 0.1 -- Percentage of actor-cases among all deployed cases
	CF.CrateRandomLocationsRate = 0.5
	CF.AmbientEnemyRate = 0.5
	CF.ArtifactItemRate = 0.1
	CF.ArtifactActorRate = 0.1
	CF.AmbientEnemyDoubleSpawn = 0.25
	CF.AmbientReinforcementsInterval = 80 -- In ticks

	CF.MaxMissionReportLines = 13

	CF.ClonePrice = 1500
	CF.StoragePrice = 200
	CF.LifeSupportPrice = 2500
	CF.CommunicationPrice = 3000
	CF.EnginePrice = 500
	CF.TurretPrice = 1500
	CF.TurretStoragePrice = 1000
	CF.BombBayPrice = 5000
	CF.BombStoragePrice = 200

	CF.ShipSellCoeff = 0.25
	CF.ShipDevInstallCoeff = 0.1

	CF.AssaultDifficultyTexts = {}
	CF.AssaultDifficultyTexts[1] = "scout"
	CF.AssaultDifficultyTexts[2] = "corvette"
	CF.AssaultDifficultyTexts[3] = "frigate"
	CF.AssaultDifficultyTexts[4] = "destroyer"
	CF.AssaultDifficultyTexts[5] = "cruiser"
	CF.AssaultDifficultyTexts[6] = "battleship"

	CF.LocationDifficultyTexts = {}
	CF.LocationDifficultyTexts[1] = "minimum"
	CF.LocationDifficultyTexts[2] = "low"
	CF.LocationDifficultyTexts[3] = "moderate"
	CF.LocationDifficultyTexts[4] = "high"
	CF.LocationDifficultyTexts[5] = "extreme"
	CF.LocationDifficultyTexts[6] = "maximum"

	CF.AssaultDifficultyUnitCount = {}
	CF.AssaultDifficultyUnitCount[1] = 4
	CF.AssaultDifficultyUnitCount[2] = 8
	CF.AssaultDifficultyUnitCount[3] = 12
	CF.AssaultDifficultyUnitCount[4] = 16
	CF.AssaultDifficultyUnitCount[5] = 22
	CF.AssaultDifficultyUnitCount[6] = 30

	CF.AssaultDifficultySpawnInterval = {}
	CF.AssaultDifficultySpawnInterval[1] = 9
	CF.AssaultDifficultySpawnInterval[2] = 9
	CF.AssaultDifficultySpawnInterval[3] = 8
	CF.AssaultDifficultySpawnInterval[4] = 8
	CF.AssaultDifficultySpawnInterval[5] = 8
	CF.AssaultDifficultySpawnInterval[6] = 7

	CF.AssaultDifficultySpawnBurst = {}
	CF.AssaultDifficultySpawnBurst[1] = 1
	CF.AssaultDifficultySpawnBurst[2] = 2
	CF.AssaultDifficultySpawnBurst[3] = 2
	CF.AssaultDifficultySpawnBurst[4] = 2
	CF.AssaultDifficultySpawnBurst[5] = 3
	CF.AssaultDifficultySpawnBurst[6] = 3

	CF.MaxDifficulty = 6

	CF.MaxCPUPlayers = 300
	CF.MaxSaveGames = 16
	CF.MaxItems = 8 -- Max items per clone in clone storage
	CF.MaxItemsPerPreset = 3 -- Max items per AI unit preset
	CF.MaxStorageItems = 1000
	CF.MaxClones = 1000 -- Max clones in clone storage
	CF.MaxTurrets = 1000
	CF.MaxBombs = 1000
	CF.MaxUnitsPerDropship = 3

	CF.MaxSavedActors = 40
	CF.MaxSavedItemsPerActor = 20

	-- Set this to true to stop any UI processing. Useful when debuging and need to disable UI error message spam.
	CF.StopUIProcessing = false

	CF.LaunchActivities = true
	CF.MissionReturnInterval = 2500

	CF.TickInterval = 1000
	CF.FlightTickInterval = 25

	-- How much percents of price to add if player and ally factions natures are not the same
	CF.SyntheticsToOrganicRatio = 0.70

	CF.EnableAssaults = true -- Set to false to disable assaults

	CF.FogOfWarResolution = 36

	CF.Factions = {}

	CF.Nobody = "Nobody"
	CF.PlayerFaction = "Nobody"
	CF.CPUFaction = "Nobody"

	CF.MissionEndTimer = Timer()
	CF.StartReturnCountdown = false
	CF.Activity = activity

	CF.FactionIds = {}
	CF.FactionNames = {}
	CF.FactionDescriptions = {}
	CF.FactionPlayable = {}

	CF.ScanBonuses = {}
	CF.RelationsBonuses = {}
	CF.ExpansionBonuses = {}

	CF["MineBonuses"] = {}
	CF["LabBonuses"] = {}
	CF["AirfieldBonuses"] = {}
	CF["SuperWeaponBonuses"] = {}
	CF["FactoryBonuses"] = {}
	CF["CloneBonuses"] = {}
	CF["HospitalBonuses"] = {}

	CF["HackTimeBonuses"] = {}
	CF["HackRewardBonuses"] = {}

	CF["DropShipCapacityBonuses"] = {}

	-- Special arrays for factions with pre-equipped items
	-- Everything in this array (indexed by preset name) will not be included by inventory saving routines
	CF["DiscardableItems"] = {}
	-- Everything in this array will be marked for deletion after actor is created
	CF["ItemsToRemove"] = {}

	CF["BrainHuntRatios"] = {}

	CF["PreferedBrainInventory"] = {}

	CF["SuperWeaponScripts"] = {}

	CF["ResearchQueues"] = {}

	-- Specify presets which are not affected by tactical AI unit management
	CF["UnassignableUnits"] = {}

	-- Set this to true if your faction uses pre-equipped actors
	CF["PreEquippedActors"] = {}

	CF["PresetNames"] = {
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
	CF["PresetTypes"] = {
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
	CF["PreferedTacticalPresets"] = {}

	-- Default presets array, everything is evenly selected by AI
	CF["DefaultTacticalPresets"] = {
		CF["PresetTypes"].INFANTRY1,
		CF["PresetTypes"].INFANTRY2,
		CF["PresetTypes"].SNIPER,
		CF["PresetTypes"].SHOTGUN,
		CF["PresetTypes"].HEAVY1,
		CF["PresetTypes"].HEAVY2,
		CF["PresetTypes"].ARMOR1,
		CF["PresetTypes"].ARMOR2,
		CF["PresetTypes"].ENGINEER,
	}
	-- These AI models are left over from UL2 but preserved for backwards compatibility
	CF["AIModels"] = { "RANDOM", "SIMPLE", "CONSOLE HUNTERS", "SQUAD" }
	CF["FactionAIModels"] = {}

	CF["WeaponTypes"] = {
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
	CF["ActorTypes"] = { ANY = -1, LIGHT = 0, HEAVY = 1, ARMOR = 2, TURRET = 3 }
	CF["FactionTypes"] = { ORGANIC = 0, SYNTHETIC = 1 }

	CF["ItmNames"] = {}
	CF["ItmPresets"] = {}
	CF["ItmModules"] = {}
	CF["ItmPrices"] = {}
	CF["ItmDescriptions"] = {}
	CF["ItmUnlockData"] = {}
	CF["ItmClasses"] = {}
	CF["ItmTypes"] = {}
	CF["ItmPowers"] = {} -- AI will select weapons based on this value

	CF["ActNames"] = {}
	CF["ActPresets"] = {}
	CF["ActModules"] = {}
	CF["ActPrices"] = {}
	CF["ActDescriptions"] = {}
	CF["ActUnlockData"] = {}
	CF["ActClasses"] = {}
	CF["ActTypes"] = {}
	CF["EquipmentTypes"] = {} -- Factions with pre-equipped actors specify which weapons class this unit is equivalent
	CF["ActPowers"] = {}
	CF["ActOffsets"] = {}

	-- Bombs, used only by VoidWanderers
	CF["BombNames"] = {}
	CF["BombPresets"] = {}
	CF["BombModules"] = {}
	CF["BombClasses"] = {}
	CF["BombPrices"] = {}
	CF["BombDescriptions"] = {}
	CF["BombOwnerFactions"] = {}
	CF["BombUnlockData"] = {}

	CF["RequiredModules"] = {}

	CF["FactionNatures"] = {}

	CF["Brains"] = {}
	CF["BrainModules"] = {}
	CF["BrainClasses"] = {}
	CF["BrainPrices"] = {}

	CF["Crafts"] = {}
	CF["CraftModules"] = {}
	CF["CraftClasses"] = {}
	CF["CraftPrices"] = {}

	CF["MusicTypes"] = { SHIP_CALM = 0, SHIP_INTENSE = 1, MISSION_CALM = 2, MISSION_INTENSE = 3, VICTORY = 4, DEFEAT = 5 }

	CF["Music"] = {}
	CF["Music"][CF["MusicTypes"].SHIP_CALM] = {}
	CF["Music"][CF["MusicTypes"].SHIP_INTENSE] = {}
	CF["Music"][CF["MusicTypes"].MISSION_CALM] = {}
	CF["Music"][CF["MusicTypes"].MISSION_INTENSE] = {}

	-- Load factions
	--CF["FactionFiles"] = CF["ReadFactionsList"](CF["ModuleName"].."/Factions/Factions.cfg" , CF["ModuleName"].."/Factions/")
	CF["FactionFiles"] = { "Mods/VoidWanderers.rte/Factions/Factions.lua" }

	-- Load factions data
	for i = 1, #CF["FactionFiles"] do
		--print("Loading "..CF["FactionFiles"][i])
		f = loadfile(CF["FactionFiles"][i])
		if f ~= nil then
			local lastfactioncount = #CF["Factions"]

			-- Execute script
			f()

			-- Check for faction consistency only if it is a faction file
			if lastfactioncount ~= #CF["Factions"] then
				local id = CF["Factions"][#CF["Factions"]]

				--Check if faction modules installed. Check only works with old v1 or most new v2 faction files.
				--print(CF["InfantryModules"][CF["Factions"][#CF["Factions"]]])
				for m = 1, #CF["RequiredModules"][id] do
					local module = CF["RequiredModules"][id][m]

					if module ~= nil then
						if PresetMan:GetModuleID(module) == -1 then
							CF["FactionPlayable"][id] = false
							print("ERROR!!! " .. id .. " DISABLED!!! " .. CF["RequiredModules"][id][m] .. " NOT FOUND!!!")
						end
					end
				end

				-- Assume that faction file is correct
				local factionok = true
				local err = ""

				-- Verify faction file data and add mission values if any
				-- Verify items
				for i = 1, #CF["ItmNames"][id] do
					if CF["ItmModules"][id][i] == nil then
						factionok = false
						err = "CF["ItmModules"] is missing."
					end

					if CF["ItmPrices"][id][i] == nil then
						factionok = false
						err = "CF["ItmPrices"] is missing."
					end

					if CF["ItmDescriptions"][id][i] == nil then
						factionok = false
						err = "CF["ItmDescriptions"] is missing."
					end

					if CF["ItmUnlockData"][id][i] == nil then
						factionok = false
						err = "CF["ItmUnlockData"] is missing."
					end

					if CF["ItmTypes"][id][i] == nil then
						factionok = false
						err = "CF["ItmTypes"] is missing."
					end

					if CF["ItmPowers"][id][i] == nil then
						factionok = false
						err = "CF["ItmPowers"] is missing."
					end

					-- If something is wrong then disable faction and print error message
					if not factionok then
						CF["FactionPlayable"][id] = false
						print("ERROR!!! " .. id .. " DISABLED!!! " .. CF["ItmNames"][id][i] .. " : " .. err)
						break
					end
				end

				-- Assume that faction file is correct
				local info = {}
				local data = {}

				-- Verify faction generic data
				info[#info + 1] = "CF['FactionNames']"
				data[#info] = CF["FactionNames"][id]

				info[#info + 1] = "CF['FactionDescriptions']"
				data[#info] = CF["FactionDescriptions"][id]

				info[#info + 1] = "CF['FactionPlayable']"
				data[#info] = CF["FactionPlayable"][id]

				info[#info + 1] = "CF['RequiredModules']"
				data[#info] = CF["RequiredModules"][id]

				info[#info + 1] = "CF['FactionNatures']"
				data[#info] = CF["FactionNatures"][id]
				--[[ UL2 stuff - don't need these!
				info[#info + 1] = "CF["ScanBonuses"]"
				data[#info] = CF["ScanBonuses"][id]
				
				info[#info + 1] = "CF["RelationsBonuses"]"
				data[#info] = CF["RelationsBonuses"][id]

				info[#info + 1] = "CF["ExpansionBonuses"]"
				data[#info] = CF["ExpansionBonuses"][id]

				info[#info + 1] = "CF["MineBonuses"]"
				data[#info] = CF["MineBonuses"][id]

				info[#info + 1] = "CF["LabBonuses"]"
				data[#info] = CF["LabBonuses"][id]

				info[#info + 1] = "CF["AirfieldBonuses"]"
				data[#info] = CF["AirfieldBonuses"][id]

				info[#info + 1] = "CF["SuperWeaponBonuses"]"
				data[#info] = CF["SuperWeaponBonuses"][id]

				info[#info + 1] = "CF["FactoryBonuses"]"
				data[#info] = CF["FactoryBonuses"][id]

				info[#info + 1] = "CF["CloneBonuses"]"
				data[#info] = CF["CloneBonuses"][id]

				info[#info + 1] = "CF["HospitalBonuses"]"
				data[#info] = CF["HospitalBonuses"][id]
]]
				--
				info[#info + 1] = "CF['Brains']"
				data[#info] = CF["Brains"][id]

				info[#info + 1] = "CF['BrainModules']"
				data[#info] = CF["BrainModules"][id]

				info[#info + 1] = "CF['BrainClasses']"
				data[#info] = CF["BrainClasses"][id]

				info[#info + 1] = "CF['BrainPrices']"
				data[#info] = CF["BrainPrices"][id]

				info[#info + 1] = "CF['Crafts']"
				data[#info] = CF["Crafts"][id]

				info[#info + 1] = "CF['CraftModules']"
				data[#info] = CF["CraftModules"][id]

				info[#info + 1] = "CF['CraftClasses']"
				data[#info] = CF["CraftClasses"][id]

				info[#info + 1] = "CF['CraftPrices']"
				data[#info] = CF["CraftPrices"][id]

				for i = 1, #info do
					if data[i] == nil then
						CF["FactionPlayable"][id] = false
						print("ERROR!!! " .. id .. " DISABLED!!! " .. info[i] .. " is missing")
						break
					end
				end

				-- Assume that faction file is correct
				local factionok = true
				local err = ""

				-- Verify actors
				for i = 1, #CF["ActNames"][id] do
					if CF["ActModules"][id][i] == nil then
						factionok = false
						err = "CF['ActModules'] is missing."
					end

					if CF["ActPrices"][id][i] == nil then
						factionok = false
						err = "CF['ActPrices'] is missing."
					end

					if CF["ActDescriptions"][id][i] == nil then
						factionok = false
						err = "CF['ActDescriptions'] is missing."
					end

					if CF["ActUnlockData"][id][i] == nil then
						factionok = false
						err = "CF['ActUnlockData'] is missing."
					end

					if CF["ActTypes"][id][i] == nil then
						factionok = false
						err = "CF['ActTypes'] is missing."
					end

					if CF["ActPowers"][id][i] == nil then
						factionok = false
						err = "CF['ActPowers'] is missing."
					end

					-- If something is wrong then disable faction and print error message
					if not factionok then
						CF["FactionPlayable"][id] = false
						print("ERROR!!! " .. id .. " DISABLED!!! " .. CF["ActNames"][id][i] .. " : " .. err)
						break
					end
				end
			end
		else
			print("ERROR!!! Could not load: " .. CF["FactionFiles"][i])
		end
	end

	CF["InitExtensionsData"](activity)

	-- Load extensions
	CF["ExtensionFiles"] = CF["ReadExtensionsList"](
		CF["ModuleName"] .. "/Extensions/Extensions.cfg",
		CF["ModuleName"] .. "/Extensions/"
	)

	local extensionstorage = "Mods/" .. CF["ModuleName"] .. "/Extensions/"

	-- Load extensions data
	for i = 1, #CF["ExtensionFiles"] do
		--[[f = loadfile(extensionstorage..CF["ExtensionFiles"][i])
		if f ~= nil then
			-- Execute script
			f()
		else
			print ("ERROR!!! Could not load: "..CF["ExtensionFiles"][i])
		end]]
		--
		dofile(CF["ExtensionFiles"][i])
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["GetPlayerFaction"] = function(config, p)
	return config["Player" .. p .. "Faction"]
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["GetPlayerAllyFaction"] = function(config)
	return config["Player0AllyFaction"]
end
-----------------------------------------------------------------------------------------
-- Update mission stats to store in campaign
-----------------------------------------------------------------------------------------
CF["UpdateGenericStats"] = function(config)
	print("CF['UpdateGenericStats']")

	config["Kills"] = tonumber(config["Kills"]) + CF["Activity"]:GetTeamDeathCount(CF["CPUTeam"])
	config["Deaths"] = tonumber(config["Deaths"]) + CF["Activity"]:GetTeamDeathCount(CF["PlayerTeam"])
end
-----------------------------------------------------------------------------------------
-- Initialize and reset mission variables
-----------------------------------------------------------------------------------------
CF["InitMission"] = function(config)
	print("CF['InitMission']")
	CF["Activity"]:SetTeamFunds(tonumber(config["PlayerGold"]), CF["PlayerTeam"])
	CF["AIBudget"] = tonumber(config["LastMissionAIBudget"])

	CF["PlayerFaction"] = CF["GetPlayerFaction"](config)
	CF["CPUFaction"] = CF["GetCPUFaction"](config)
end
-----------------------------------------------------------------------------------------
-- Transfers player to strategy screen after 3 second of victory message
-----------------------------------------------------------------------------------------
CF["ReturnOnMissionEnd"] = function()
	if not CF["StartReturnCountdown"] then
		if CF["Activity"].ActivityState == Activity.OVER then
			CF["StartReturnCountdown"] = true
			CF["MissionEndTimer"]:Reset()
		end
	end

	if CF["StartReturnCountdown"] then
		if CF["MissionEndTimer"]:IsPastSimMS(CF["MissionReturnInterval"]) then
			--CF["LaunchMissionActivity"]("Unmapped Lands 2")
		end
	end
end
-----------------------------------------------------------------------------------------
-- For a given char returns its index, width, vector offsset  if any
-----------------------------------------------------------------------------------------
CF["GetCharData"] = function(char)
	if CF["Chars"] == nil then
		CF["Chars"] = {}
		CF["Chars"][" "] = { 1, 8, nil }
		CF["Chars"]["!"] = { 2, 5, Vector(-3, 0) }
		CF["Chars"]['"'] = { 3, 8, Vector(0, -2) }
		CF["Chars"]["#"] = { 4, 8, nil }
		CF["Chars"]["$"] = { 5, 8, nil }
		CF["Chars"]["%"] = { 6, 8, nil }
		CF["Chars"]["&"] = { 7, 6, Vector(-2, 0) }
		CF["Chars"]["`"] = { 8, 5, Vector(-3, -2) }
		CF["Chars"]["("] = { 9, 6, Vector(-1, 0) }
		CF["Chars"][")"] = { 10, 6, Vector(-2, 0) }
		CF["Chars"]["*"] = { 11, 6, Vector(-2, 0) }
		CF["Chars"]["+"] = { 12, 8, nil }
		CF["Chars"][","] = { 13, 5, Vector(-3, 5) }
		CF["Chars"]["-"] = { 14, 9, nil }
		CF["Chars"]["."] = { 15, 5, Vector(-3, 4) }
		CF["Chars"]["/"] = { 16, 6, Vector(-1, 0) }
		CF["Chars"]["0"] = { 17, 9, nil }
		CF["Chars"]["1"] = { 18, 6, Vector(-2, 0) }
		CF["Chars"]["2"] = { 19, 8, nil }
		CF["Chars"]["3"] = { 20, 8, nil }
		CF["Chars"]["4"] = { 21, 8, nil }
		CF["Chars"]["5"] = { 22, 8, nil }
		CF["Chars"]["6"] = { 23, 8, nil }
		CF["Chars"]["7"] = { 24, 8, nil }
		CF["Chars"]["8"] = { 25, 8, nil }
		CF["Chars"]["9"] = { 26, 8, nil }
		CF["Chars"][":"] = { 27, 5, Vector(-3, -1) }
		CF["Chars"][""] = { 28, 5, Vector(-3, -1) }
		CF["Chars"]["<"] = { 29, 7, Vector(-1, 0) }
		CF["Chars"]["="] = { 30, 8, Vector(0, -1) }
		CF["Chars"][">"] = { 31, 7, Vector(-1, 0) }
		CF["Chars"]["?"] = { 32, 8, nil }
		CF["Chars"]["@"] = { 33, 11, Vector(0, -1) }
		CF["Chars"]["A"] = { 34, 8, nil }
		CF["Chars"]["B"] = { 35, 8, nil }
		CF["Chars"]["C"] = { 36, 8, Vector(0, -3) }
		CF["Chars"]["D"] = { 37, 9, nil }
		CF["Chars"]["E"] = { 38, 8, nil }
		CF["Chars"]["F"] = { 39, 8, nil }
		CF["Chars"]["G"] = { 40, 8, nil }
		CF["Chars"]["H"] = { 41, 8, nil }
		CF["Chars"]["I"] = { 42, 6, Vector(-2, 0) }
		CF["Chars"]["J"] = { 43, 8, nil }
		CF["Chars"]["K"] = { 44, 8, nil }
		CF["Chars"]["L"] = { 45, 8, Vector(0, 3) }
		CF["Chars"]["M"] = { 46, 10, Vector(2, -1) }
		CF["Chars"]["N"] = { 47, 8, nil }
		CF["Chars"]["O"] = { 48, 8, nil }
		CF["Chars"]["P"] = { 49, 8, nil }
		CF["Chars"]["Q"] = { 50, 8, nil }
		CF["Chars"]["R"] = { 51, 8, nil }
		CF["Chars"]["S"] = { 52, 8, nil }
		CF["Chars"]["T"] = { 53, 7, Vector(-1, 0) }
		CF["Chars"]["U"] = { 54, 8, nil }
		CF["Chars"]["V"] = { 55, 8, nil }
		CF["Chars"]["W"] = { 56, 10, Vector(2, 0) }
		CF["Chars"]["X"] = { 57, 8, nil }
		CF["Chars"]["Y"] = { 58, 8, nil }
		CF["Chars"]["Z"] = { 59, 8, nil }
		CF["Chars"]["["] = { 60, 6, Vector(-1, 0) }
		CF["Chars"]["\\"] = { 61, 6, Vector(-1, 0) }
		CF["Chars"]["]"] = { 62, 6, Vector(-1, 0) }
		CF["Chars"]["^"] = { 63, 8, Vector(-1, -3) }
		CF["Chars"]["_"] = { 64, 8, Vector(0, 4) }
		CF["Chars"]["'"] = { 65, 8, Vector(0, -3) }
		CF["Chars"]["a"] = { 66, 8, nil }
		CF["Chars"]["b"] = { 67, 8, nil }
		CF["Chars"]["c"] = { 68, 8, nil }
		CF["Chars"]["d"] = { 69, 8, nil }
		CF["Chars"]["e"] = { 70, 8, nil }
		CF["Chars"]["f"] = { 71, 8, nil }
		CF["Chars"]["g"] = { 72, 8, nil }
		CF["Chars"]["h"] = { 73, 8, nil }
		CF["Chars"]["i"] = { 74, 5, Vector(-3, 0) }
		CF["Chars"]["j"] = { 75, 6, Vector(-2, 0) }
		CF["Chars"]["k"] = { 76, 8, nil }
		CF["Chars"]["l"] = { 77, 5, Vector(-3, 0) }
		CF["Chars"]["m"] = { 78, 10, nil }
		CF["Chars"]["n"] = { 79, 8, nil }
		CF["Chars"]["o"] = { 80, 8, nil }
		CF["Chars"]["p"] = { 81, 8, nil }
		CF["Chars"]["q"] = { 82, 8, nil }
		CF["Chars"]["r"] = { 83, 9, Vector(1, 0) }
		CF["Chars"]["s"] = { 84, 8, nil }
		CF["Chars"]["t"] = { 85, 8, nil }
		CF["Chars"]["u"] = { 86, 8, nil }
		CF["Chars"]["v"] = { 87, 8, nil }
		CF["Chars"]["w"] = { 88, 10, Vector(1, 0) }
		CF["Chars"]["x"] = { 89, 8, nil }
		CF["Chars"]["y"] = { 90, 8, nil }
		CF["Chars"]["z"] = { 91, 8, nil }
		CF["Chars"]["{"] = { 92, 7, nil }
		CF["Chars"]["|"] = { 93, 7, nil }
		CF["Chars"]["}"] = { 94, 7, nil }
		CF["Chars"]["~"] = { 95, 8, nil }
	end

	local i = nil

	i = CF["Chars"][char]

	if i == nil then
		i = { 96, 8, nil }
	end

	return i[1], i[2] - 2, i[3]
end
--------------------------------------------------------------------------
-- Return size of string in pixels
-----------------------------------------------------------------------------
CF["GetStringPixelWidth"] = function(str)
	local len = 0
	for i = 1, #str do
		local cindex, cwidth, coffset = CF["GetCharData"](string.sub(str, i, i))
		len = len + cwidth
	end
	return len - #str
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["Split"] = function(str, pat)
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
CF["DrawString"] = function(str, pos, width, height)
	--TODO: Implement Primitive version
	--PrimitiveMan:DrawTextPrimitive(pos, str, false, 0)
	local x = pos.X
	local y = pos.Y
	local chr
	local drawthistime
	local letterpreset = "Ltr"

	local words = CF["Split"](str, " ")
	for w = 1, #words do
		drawthistime = true

		if x + CF["GetStringPixelWidth"](words[w]) > pos.X + width then
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
				local cindex, cwidth, coffset = CF["GetCharData"](chr)

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
CF["ConvertTimeToString"] = function(timenum)
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
CF["MakeItem"] = function(preset, class, module)
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
-- Make actor of specified preset, class, module, rank, identity, and player
-----------------------------------------------------------------------------------------
CF["MakeActor"] = function(item, class, module, xp, identity, player, prestige, name, limbs)
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
			CF["ReplaceLimbs"](actor, limbs)
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
		if player then
			actor:SetNumberValue("VW_BrainOfPlayer", tonumber(player))
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
			for rank = 1, #CF["Ranks"] do
				if xp >= CF["Ranks"][rank] then
					setRank = rank
				else
					break
				end
			end
			if setRank then
				actor:SetNumberValue("VW_Rank", setRank)
				CF["BuffActor"](actor, setRank, actor:GetNumberValue("VW_Prestige"))
			end
			if xp >= CF["Ranks"][#CF["Ranks"]] then
				actor.PieMenu:AddPieSliceIfPresetNameIsUnique(CF["PrestigeSlice"]:Clone(), self)
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
CF["BuffActor"] = function(actor, rank, prestige)
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
	--print("actor ".. actor.PresetName .." buffed with" .. (prestige and " prestige " or "rank ").. rank)
end
-----------------------------------------------------------------------------------------
-- Reverse buff effect
-----------------------------------------------------------------------------------------
CF["UnBuffActor"] = function(actor, rank, prestige)
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
CF["GetLimbData"] = function(actor, id)
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
CF["ReplaceLimbs"] = function(actor, limbs)
	if IsAHuman(actor) then
		actor = ToAHuman(actor)
		for j = 1, #CF["LimbID"] do
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
					print("ERROR: CF['ReplaceLimbs']: Limb not found!! Not OK!!")
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
			actor:SetStringValue(CF["LimbID"][j], limbString)
		end
		-- Replace helmets etc.
		if actor.Head and #limbs > #CF["LimbID"] then
			for att in actor.Head.Attachables do
				if att.DamageMultiplier == 0 then
					actor.Head:RemoveAttachable(att, false, false)
				end
			end
			for i = #CF["LimbID"] + 1, #CF["LimbID"] + #limbs do
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
CF["AttemptReplaceLimb"] = function(actor, limb)
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
			newLimb = limb:Clone() --(limbName)
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
CF["RandomizeLimbs"] = function(actor, limbs)
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
			if math.random() <= actor:GetNumberValue("VW_XP") / CF["Ranks"][#CF["Ranks"]] then
				CF["SetRandomName"](actor)
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
-- Set which actor is being named right now
-----------------------------------------------------------------------------------------
CF["SetNamingActor"] = function(actor, player)
	CF["TypingActor"] = actor
	CF["TypingPlayer"] = player
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["SetRandomName"] = function(actor)
	if not actor:StringValueExists("VW_Name") then
		actor:SetStringValue("VW_Name", CF.GenerateRandomName())
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.GenerateRandomName = function()
	if not CF.RandomNames then
		CF.RandomNames = {}
		CF.RandomNames[1] = { "Big", "Just", "Killer", "Lt.", "Little", "Mad", "Major", "MC", "Sgt.", "Serious", }
		CF.RandomNames[2] = { "Alex", "Ban", "Billy", "Brian", "Buck", "Chad", "Charlie", "Chuck", "Dick", "Dixie", "Frankie", "Gordon",
								"George", "Joe", "John", "Jordan", "Mack", "Mal", "Max", "Miles", "Morgan", "Pepper",
								"Roger", "Sam", "Smoke", }
		CF.RandomNames[3] = { "Davis", "Freeman", "Function", "Griffin", "Hammer", "Hawkins", "Johnson", "McGee",
								"Moore", "Rambo", "Richards", "Simpson", "Williams", "Wilson", }
	end

	local name = ""
	local rand = math.random()
	if rand < 0.25 then --First + Second + Third
		name = CF.RandomNames[1][math.random(#CF.RandomNames[1])]
			.. " "
			.. CF.RandomNames[2][math.random(#CF.RandomNames[2])]
			.. " "
			.. CF.RandomNames[3][math.random(#CF.RandomNames[3])]
	elseif rand < 0.50 then --First + Second
		name = CF.RandomNames[1][math.random(#CF.RandomNames[1])]
			.. " "
			.. CF.RandomNames[2][math.random(#CF.RandomNames[2])]
	elseif rand < 0.75 then --Second + Third
		name = CF.RandomNames[2][math.random(#CF.RandomNames[2])]
			.. " "
			.. CF.RandomNames[3][math.random(#CF.RandomNames[3])]
	else --First + Third
		name = CF.RandomNames[1][math.random(#CF.RandomNames[1])]
			.. " "
			.. CF.RandomNames[3][math.random(#CF.RandomNames[3])]
	end
	return name
end
-----------------------------------------------------------------------------------------
-- Set actors to hunt for nearby actors of a specific team - or regroup near actors of the same team
-----------------------------------------------------------------------------------------
CF.HuntForActors = function(hunter, targetTeam)
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
				if target:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
					table.insert(brains, target)
				end
			end
		end
		local target
		if #brains > 0 and math.random(150) < CF.Difficulty then
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
CF.Hunt = function(hunter, targets)
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
CF.GetPlayerGold = function(c, p)
	local v = c["Player" .. p .. "Gold"]
	if v == nil then
		v = 0
	end

	return tonumber(v)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.SetPlayerGold = function(c, p, funds)
	-- Set the in-activity gold as well, although we don't use it
	CF.Activity:SetTeamFunds(funds, p)

	c["Player" .. p .. "Gold"] = math.ceil(funds)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.CommitMissionResult = function(c, result)
	-- Set result
	c["LastMissionResult"] = result
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.PayGold = function(c, p, amount)
	local gold = CF["GetPlayerGold"](c, p) - amount

	CF["SetPlayerGold"](c, p, gold)
end
-----------------------------------------------------------------------------------------
-- Get table with inventory of actor, inventory cleared as a result
-----------------------------------------------------------------------------------------
CF["GetInventory"] = function(actor)
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

					if CF["DiscardableItems"][actor.PresetName] ~= nil then
						for i = 1, #CF["DiscardableItems"][actor.PresetName] do
							if CF["DiscardableItems"][actor.PresetName][i] == item.PresetName then
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

				if CF["DiscardableItems"][actor.PresetName] ~= nil then
					for i = 1, #CF["DiscardableItems"][actor.PresetName] do
						if CF["DiscardableItems"][actor.PresetName][i] == item.PresetName then
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
		--print(actor)
	end

	return inventory, classes, modules
end
-----------------------------------------------------------------------------------------
-- Calculate distance
-----------------------------------------------------------------------------------------
CF["Dist"] = function(pos1, pos2)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX).Magnitude
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["DistOver"] = function(pos1, pos2, magnitude)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX):MagnitudeIsGreaterThan(magnitude)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["DistUnder"] = function(pos1, pos2, magnitude)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX):MagnitudeIsLessThan(magnitude)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["CountActors"] = function(team)
	local c = 0

	for actor in MovableMan.Actors do
		if
			actor.Team == team
			and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
			and not (actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") or actor:NumberValueExists("VW_Ally"))
		then
			c = c + 1
		end
	end

	return c
end
-----------------------------------------------------------------------------------------
--	Returns how many science points corresponds to selected difficulty level
-----------------------------------------------------------------------------------------
CF["GetTechLevelFromDifficulty"] = function(c, p, diff, maxdiff)
	local maxpoints = 0
	local f = CF["GetPlayerFaction"](c, p)

	for i = 1, #CF["ItmNames"][f] do
		if CF["ItmUnlockData"][f][i] > maxpoints then
			maxpoints = CF["ItmUnlockData"][f][i]
		end
	end

	for i = 1, #CF["ActNames"][f] do
		if CF["ActUnlockData"][f][i] > maxpoints then
			maxpoints = CF["ActUnlockData"][f][i]
		end
	end

	return math.floor(maxpoints / maxdiff * diff)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["CalculateReward"] = function(base, diff)
	local coeff = 1 + (diff - 1) * 0.35

	return math.floor(base * coeff)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["IsLocationHasAttribute"] = function(loc, attr)
	local attrs = CF["LocationAttributes"][loc]

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
CF["GiveExp"] = function(c, exppts)
	local levelup = false

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if ActivityMan:GetActivity():PlayerActive(player) and ActivityMan:GetActivity():PlayerHuman(player) then
			local curexp = tonumber(c["Brain" .. player .. "Exp"])
			local cursklpts = tonumber(c["Brain" .. player .. "SkillPoints"])
			local curlvl = tonumber(c["Brain" .. player .. "Level"])

			--print ("Curexp "..curexp)
			--print ("Exppts "..exppts)

			curexp = curexp + exppts

			--print (CF["ExpPerLevel"])
			--print (math.floor(curexp / CF["ExpPerLevel"]))

			while math.floor(curexp / CF["ExpPerLevel"]) > 0 do
				if curlvl < CF["MaxLevel"] then
					curexp = curexp - CF["ExpPerLevel"]
					cursklpts = cursklpts + 1
					curlvl = curlvl + 1
					levelup = true

					--print (levelup)
				else
					curexp = 0
					break
				end
			end

			c["Brain" .. player .. "SkillPoints"] = cursklpts
			c["Brain" .. player .. "Exp"] = curexp
			c["Brain" .. player .. "Level"] = curlvl
		end
	end

	return levelup
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
