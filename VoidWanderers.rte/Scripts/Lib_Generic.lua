-----------------------------------------------------------------------
-- Generic functions to add to library
-----------------------------------------------------------------------

CF = {}

-----------------------------------------------------------------------
-- Initialize global faction lists
-----------------------------------------------------------------------
function CF.InitFactions(activity)
	print("CF.InitFactions")
	CF.PlayerTeam = Activity.TEAM_1
	CF.CPUTeam = Activity.TEAM_2
	CF.RogueTeam = Activity.NOTEAM
	CF.MOIDLimit = math.huge
	CF.ModuleName = "VoidWanderers.rte"

	-- Used in flight mode
	CF.KmPerPixel = 100

	CF.BlackMarketRefreshInterval = 1200
	CF.BlackMarketPriceMultiplier = 3

	CF.MissionResultShowInterval = 10
	CF.MissionStages = { ACTIVE = 0, COMPLETED = 1, FAILED = 2 }

	CF.UnknownItemPrice = 50
	CF.UnknownActorPrice = 100

	CF.TechPriceMultiplier = 1.5
	CF.SellPriceCoeff = 0.25

	CF.OrdersRange = 175

	CF.MaxMissions = 30

	CF.UniqueHolograms = 24

	CF.BombsPerBay = 5
	CF.BombInterval = 1
	CF.BombLoadInterval = 2
	CF.BombFlightInterval = 10
	CF.BombSeenRange = 150
	CF.BombUnseenRange = 400

	CF.KeyRepeatDelay = 100

	CF.MaxLevel = 150
	CF.ExpPerLevel = 250

	CF.ElementTypes = { BUTTON = 0, LABEL = 1, PLANET = 2 };
	CF.ElementStates = { IDLE = 0, MOUSE_OVER = 1, PRESSED = 2 };
	
	CF.MenuNormalIdle = { 228, 50, 191 };
	CF.MenuNormalMouseOver = { 228, 50, 190 };
	CF.MenuNormalPressed = { 228, 224, 190 };
	CF.MenuNormalPalette = {
		[CF.ElementStates.IDLE] = CF.MenuNormalIdle,
		[CF.ElementStates.MOUSE_OVER] = CF.MenuNormalMouseOver,
		[CF.ElementStates.PRESSED] = CF.MenuNormalPressed
	};
	
	CF.MenuSelectIdle = { 228, 50, 192 };
	CF.MenuSelectMouseOver = { 228, 50, 191 };
	CF.MenuSelectPressed = { 228, 224, 191 };
	CF.MenuSelectPalette = {
		[CF.ElementStates.IDLE] = CF.MenuSelectIdle,
		[CF.ElementStates.MOUSE_OVER] = CF.MenuSelectMouseOver,
		[CF.ElementStates.PRESSED] = CF.MenuSelectPressed
	};
	
	CF.MenuDeniedIdle = { 228, 50, 240 };
	CF.MenuDeniedMouseOver = { 228, 50, 241 };
	CF.MenuDeniedPressed = { 228, 224, 241 };
	CF.MenuDeniedPalette = {
		[CF.ElementStates.IDLE] = CF.MenuDeniedIdle,
		[CF.ElementStates.MOUSE_OVER] = CF.MenuDeniedMouseOver,
		[CF.ElementStates.PRESSED] = CF.MenuDeniedPressed
	};

	local fontIcons = {};
	fontIcons[242] = "Mods/VoidWanderers.rte/UI/Letters/242.png";
	fontIcons[243] = "Mods/VoidWanderers.rte/UI/Letters/243.png";
	CF.FontIcons = fontIcons;

	CF.Ranks = { 50, 125, 250, 500, 1000 }
	CF.PrestigeSlice = CreatePieSlice("Claim Prestige PieSlice", CF.ModuleName)

	CF.HumanLimbID = { "FGArm", "BGArm", "FGLeg", "BGLeg", "Head", "Jetpack" }
	CF.CrabLimbID = { "LeftFGLeg", "LeftBGLeg", "RightFGLeg", "RightBGLeg", "Turret", "Jetpack" }

	CF.QuantumCapacityPerLevel = 50;
	CF.QuantumSplitterEffectiveness = 1 / 6;

	CF.SecurityIncrementPerMission = 10
	CF.SecurityIncrementPerDeployment = 2

	CF.ReputationPerDifficulty = 1000

	-- When reputation is below this level, the enemy starts attacking the player
	CF.ReputationHuntThreshold = -500

	-- The rate of reputation points subtracted from the mission target faction
	CF.ReputationPenaltyRatio = 1.75

	-- The rate of reputation points subtracted from both reputations when failing a mission
	CF.MissionFailedReputationPenaltyRatio = 0.3

	CF.EnableIcons = true

	CF.TeamReturnDelay = 5

	CF.CratesRate = 0.25 -- Percentage of cases among available case spawn points
	CF.ActorCratesRate = 0.1 -- Percentage of actor-cases among all deployed cases
	CF.CrateRandomLocationsRate = 0.5
	CF.AmbientEnemyRate = 0.5
	CF.ArtifactItemRate = 0.1
	CF.ArtifactActorRate = 0.1
	CF.AmbientEnemyDoubleSpawn = 0.25
	CF.AmbientReinforcementsInterval = 80 -- In ticks

	CF.MaxMissionReportLines = 10

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

	CF.MaxCPUPlayers = 255
	CF.MaxSaveGames = 16
	CF.MaxStoredActorInventory = 32 -- Good luck exceeding this haha
	CF.MaxItemsPerPreset = 3 -- Max items per AI unit preset
	CF.MaxStorageItems = 1000
	CF.MaxClones = 100 -- Max clones in clone storage
	CF.MaxTurrets = 1000
	CF.MaxBombs = 1000
	CF.MaxUnitsPerDropship = 3

	CF.MaxSavedActors = 40
	CF.MaxSavedItemsPerActor = 20

	CF.LaunchActivities = true
	CF.MissionReturnInterval = 2500

	CF.TickInterval = 1000

	-- How much percents of price to add if player and ally factions natures are not the same
	CF.SyntheticsToOrganicRatio = 0.70

	CF.RandomEncountersEnabled = true
	CF.RandomEncounterProbability = 0.0015

	CF.FogOfWarResolution = 4

	CF.Factions = {}

	CF.Nobody = "Nobody"
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

	CF.MineBonuses = {}
	CF.LabBonuses = {}
	CF.AirfieldBonuses = {}
	CF.SuperWeaponBonuses = {}
	CF.FactoryBonuses = {}
	CF.CloneBonuses = {}
	CF.HospitalBonuses = {}

	CF.HackTimeBonuses = {}
	CF.HackRewardBonuses = {}

	CF.DropShipCapacityBonuses = {}

	-- Special arrays for factions with pre-equipped items
	-- Everything in this array (indexed by preset name) will not be included by inventory saving routines
	CF.DiscardableItems = {}
	-- Everything in this array will be marked for deletion after actor is created
	CF.ItemsToRemove = {}

	CF.BrainHuntRatios = {}

	CF.PreferedBrainInventory = {}

	CF.SuperWeaponScripts = {}

	CF.ResearchQueues = {}

	-- Specify presets which are not affected by tactical AI unit management
	CF.UnassignableUnits = {}

	-- Set this to true if your faction uses pre-equipped actors
	CF.PreEquippedActors = {}

	CF.PresetNames = {
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

	CF.PresetTypes = {
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
	CF.PreferedTacticalPresets = {}

	-- Default presets array, everything is evenly selected by AI
	CF.DefaultTacticalPresets = {
		CF.PresetTypes.INFANTRY1,
		CF.PresetTypes.INFANTRY2,
		CF.PresetTypes.SNIPER,
		CF.PresetTypes.SHOTGUN,
		CF.PresetTypes.HEAVY1,
		CF.PresetTypes.HEAVY2,
		CF.PresetTypes.ARMOR1,
		CF.PresetTypes.ARMOR2,
		CF.PresetTypes.ENGINEER,
	}
	-- These AI models are left over from UL2 but preserved for backwards compatibility
	CF.AIModels = { "RANDOM", "SIMPLE", "CONSOLE HUNTERS", "SQUAD" }
	CF.FactionAIModels = {}

	CF.WeaponTypes = {
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
	CF.ActorTypes = {
		ANY = -1,
		LIGHT = 0,
		HEAVY = 1,
		ARMOR = 2,
		TURRET = 3
	}
	CF.FactionTypes = { ORGANIC = 0, SYNTHETIC = 1 }

	CF.ItmNames = {}
	CF.ItmPresets = {}
	CF.ItmModules = {}
	CF.ItmPrices = {}
	CF.ItmDescriptions = {}
	CF.ItmUnlockData = {}
	CF.ItmClasses = {}
	CF.ItmTypes = {}
	CF.ItmPowers = {} -- AI will select weapons based on this value

	CF.ActNames = {}
	CF.ActPresets = {}
	CF.ActModules = {}
	CF.ActPrices = {}
	CF.ActDescriptions = {}
	CF.ActUnlockData = {}
	CF.ActClasses = {}
	CF.ActTypes = {}
	CF.EquipmentTypes = {} -- Factions with pre-equipped actors specify which weapons class this unit is equivalent
	CF.ActPowers = {}
	CF.ActOffsets = {}

	-- Bombs, used only by VoidWanderers
	CF.BombNames = {}
	CF.BombPresets = {}
	CF.BombModules = {}
	CF.BombClasses = {}
	CF.BombPrices = {}
	CF.BombDescriptions = {}
	CF.BombOwnerFactions = {}
	CF.BombUnlockData = {}

	CF.RequiredModules = {}

	CF.FactionNatures = {}

	CF.Brains = {}
	CF.BrainModules = {}
	CF.BrainClasses = {}
	CF.BrainPrices = {}

	CF.Crafts = {}
	CF.CraftModules = {}
	CF.CraftClasses = {}
	CF.CraftPrices = {}

	CF.MusicTypes = { SHIP_CALM = 0, SHIP_INTENSE = 1, MISSION_CALM = 2, MISSION_INTENSE = 3, VICTORY = 4, DEFEAT = 5, COMMERCE = 6 }

	CF.Music = {}
	CF.Music[CF.MusicTypes.SHIP_CALM] = {}
	CF.Music[CF.MusicTypes.SHIP_INTENSE] = {}
	CF.Music[CF.MusicTypes.MISSION_CALM] = {}
	CF.Music[CF.MusicTypes.MISSION_INTENSE] = {}

	-- Load factions
	local lastfactioncount = #CF.Factions

	-- Execute script
	dofile("Mods/VoidWanderers.rte/Extensions/Factions.lua")

	-- Check for faction consistency only if it is a faction file
	if lastfactioncount ~= #CF.Factions then
		local id = CF.Factions[#CF.Factions]

		--Check if faction modules installed. Check only works with old v1 or most new v2 faction files.
		--print(CF.InfantryModules[CF.Factions[#CF.Factions]])
		for m = 1, #CF.RequiredModules[id] do
			local module = CF.RequiredModules[id][m]

			if module ~= nil then
				if PresetMan:GetModuleID(module) == -1 then
					CF.FactionPlayable[id] = false
					print("ERROR!!! " .. id .. " DISABLED!!! " .. CF.RequiredModules[id][m] .. " NOT FOUND!!!")
				end
			end
		end

		-- Assume that faction file is correct
		local factionok = true
		local err = ""

		-- Verify faction file data and add mission values if any
		-- Verify items
		for i = 1, #CF.ItmNames[id] do
			if CF.ItmModules[id][i] == nil then
				factionok = false
				err = "CF.ItmModules is missing."
			end

			if CF.ItmPrices[id][i] == nil then
				factionok = false
				err = "CF.ItmPrices is missing."
			end

			if CF.ItmDescriptions[id][i] == nil then
				factionok = false
				err = "CF.ItmDescriptions is missing."
			end

			if CF.ItmUnlockData[id][i] == nil then
				factionok = false
				err = "CF.ItmUnlockData is missing."
			end

			if CF.ItmTypes[id][i] == nil then
				factionok = false
				err = "CF.ItmTypes is missing."
			end

			if CF.ItmPowers[id][i] == nil then
				factionok = false
				err = "CF.ItmPowers is missing."
			end

			-- If something is wrong then disable faction and print error message
			if not factionok then
				CF.FactionPlayable[id] = false
				print("ERROR!!! " .. id .. " DISABLED!!! " .. CF.ItmNames[id][i] .. " : " .. err)
				break
			end
		end

		-- Assume that faction file is correct
		local info = {}
		local data = {}

		-- Verify faction generic data
		info[#info + 1] = "CF['FactionNames']"
		data[#info] = CF.FactionNames[id]

		info[#info + 1] = "CF['FactionDescriptions']"
		data[#info] = CF.FactionDescriptions[id]

		info[#info + 1] = "CF['FactionPlayable']"
		data[#info] = CF.FactionPlayable[id]

		info[#info + 1] = "CF['RequiredModules']"
		data[#info] = CF.RequiredModules[id]

		info[#info + 1] = "CF['FactionNatures']"
		data[#info] = CF.FactionNatures[id]
		--[[ UL2 stuff - don't need these!
		info[#info + 1] = "CF.ScanBonuses"
		data[#info] = CF.ScanBonuses[id]
				
		info[#info + 1] = "CF.RelationsBonuses"
		data[#info] = CF.RelationsBonuses[id]

		info[#info + 1] = "CF.ExpansionBonuses"
		data[#info] = CF.ExpansionBonuses[id]

		info[#info + 1] = "CF.MineBonuses"
		data[#info] = CF.MineBonuses[id]

		info[#info + 1] = "CF.LabBonuses"
		data[#info] = CF.LabBonuses[id]

		info[#info + 1] = "CF.AirfieldBonuses"
		data[#info] = CF.AirfieldBonuses[id]

		info[#info + 1] = "CF.SuperWeaponBonuses"
		data[#info] = CF.SuperWeaponBonuses[id]

		info[#info + 1] = "CF.FactoryBonuses"
		data[#info] = CF.FactoryBonuses[id]

		info[#info + 1] = "CF.CloneBonuses"
		data[#info] = CF.CloneBonuses[id]

		info[#info + 1] = "CF.HospitalBonuses"
		data[#info] = CF.HospitalBonuses[id]
		]]
		--
		info[#info + 1] = "CF['Brains']"
		data[#info] = CF.Brains[id]

		info[#info + 1] = "CF['BrainModules']"
		data[#info] = CF.BrainModules[id]

		info[#info + 1] = "CF['BrainClasses']"
		data[#info] = CF.BrainClasses[id]

		info[#info + 1] = "CF['BrainPrices']"
		data[#info] = CF.BrainPrices[id]

		info[#info + 1] = "CF['Crafts']"
		data[#info] = CF.Crafts[id]

		info[#info + 1] = "CF['CraftModules']"
		data[#info] = CF.CraftModules[id]

		info[#info + 1] = "CF['CraftClasses']"
		data[#info] = CF.CraftClasses[id]

		info[#info + 1] = "CF['CraftPrices']"
		data[#info] = CF.CraftPrices[id]

		for i = 1, #info do
			if data[i] == nil then
				CF.FactionPlayable[id] = false
				print("ERROR!!! " .. id .. " DISABLED!!! " .. info[i] .. " is missing")
				break
			end
		end

		-- Assume that faction file is correct
		local factionok = true
		local err = ""

		-- Verify actors
		for i = 1, #CF.ActNames[id] do
			if CF.ActModules[id][i] == nil then
				factionok = false
				err = "CF['ActModules'] is missing."
			end

			if CF.ActPrices[id][i] == nil then
				factionok = false
				err = "CF['ActPrices'] is missing."
			end

			if CF.ActDescriptions[id][i] == nil then
				factionok = false
				err = "CF['ActDescriptions'] is missing."
			end

			if CF.ActUnlockData[id][i] == nil then
				factionok = false
				err = "CF['ActUnlockData'] is missing."
			end

			if CF.ActTypes[id][i] == nil then
				factionok = false
				err = "CF['ActTypes'] is missing."
			end

			if CF.ActPowers[id][i] == nil then
				factionok = false
				err = "CF['ActPowers'] is missing."
			end

			-- If something is wrong then disable faction and print error message
			if not factionok then
				CF.FactionPlayable[id] = false
				print("ERROR!!! " .. id .. " DISABLED!!! " .. CF.ActNames[id][i] .. " : " .. err)
				break
			end
		end
	end

	CF.InitExtensionsData(activity)

	-- Load extensions
	CF.ExtensionFiles = CF.ReadExtensionsList(
		CF.ModuleName .. "/Extensions/Extensions.cfg",
		CF.ModuleName .. "/Extensions/"
	)

	local extensionstorage = "Mods/" .. CF.ModuleName .. "/Extensions/"

	-- Load extensions data
	for i = 1, #CF.ExtensionFiles do
		dofile(CF.ExtensionFiles[i])
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetPlayerFaction(config, p)
	return config["Player" .. p .. "Faction"]
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
do
	local defaultPos = Vector(0, 0);
	local widthCaches = { [true] = {}, [false] = {} };
	
	-----------------------------------------------------------------------
	-- Return size of string in pixels
	-----------------------------------------------------------------------
	function CF.GetStringPixelWidth(str, width, smallFont)
		smallFont = smallFont or false;
		width = width or math.huge;

		local fontCache = widthCaches[smallFont];
		local totalX = 0;
		local length = #str;
		for i = 1, #str do
			local ch = str:sub(i, i);
			local w = fontCache[ch:byte()];

			if not w then
				if ch ~= "\t" then
					w = FrameMan:CalculateTextWidth(ch, smallFont);
					fontCache[ch:byte()] = w;
				else
					w = 13;
					fontCache[ch:byte()] = w;
				end
			end

			totalX = totalX + w;

			if totalX > width then
				break;
			end
		end

		return totalX;
	end
	-----------------------------------------------------------------------
	-- Split a string for display
	-----------------------------------------------------------------------
	function CF.SplitStringToFitWidth(str, width, smallFont)
		smallFont = smallFont or false;

		local fontCache = widthCaches[smallFont];
		local totalX = 0;
		local string = "";
		local lastIndex = 0;
		local lastWhiteSpace;
		local lastWhiteIndex;
		local lastLine = 1;
		local length = #str;
		local offsets = {};

		for i = 1, length do
			local ch = str:sub(i, i);
			local w = fontCache[ch:byte()];

			if not w then
				if ch ~= "\t" then
					w = FrameMan:CalculateTextWidth(ch, smallFont);
					fontCache[ch:byte()] = w;
				else
					w = 13;
					fontCache[ch:byte()] = w;
				end
			end

			totalX = totalX + w;

			local isNewLine = ch == "\n";
			local isWhiteSpace = isNewLine or ch == "\t" or ch == " ";
			local isLastChar = i == length;
			local isWidthExceeded = totalX > width;

			if isWhiteSpace and not isWidthExceeded then
				lastWhiteIndex = i;
			end

			if (isWhiteSpace or (isWidthExceeded and lastWhiteIndex)) and (isWidthExceeded or isNewLine) or isLastChar then
				local endLine = isLastChar and i or (lastWhiteIndex and lastWhiteIndex or i);
				string = string .. str:sub(lastLine, endLine) .. (not (isLastChar or isNewLine) and "\n" or "");
				lastLine = lastWhiteIndex and (lastWhiteIndex + 1) or (i + 1);
				lastWhiteIndex = nil;
				totalX = FrameMan:CalculateTextWidth(str:sub(endLine + 1, i), smallFont);
			end
		end

		return string;
	end
	-----------------------------------------------------------------------
	-- Draw string on screen at speicified pos not wider that width and not higher than height
	-----------------------------------------------------------------------
	function CF.DrawString(str, pos, width, height, smallFont, lineOffset, halignment, valignment, rotation, player)
		str = str or (error("You forgot the valid string!!!", 2));
		pos = pos or defaultPos;
		width = width or math.huge;
		height = height or math.huge;
		smallFont = smallFont or false;
		lineOffset = lineOffset or (smallFont and 9 or 11);
		halignment = halignment or 0;
		valignment = valignment or 0;
		rotation = rotation or 0;
		player = player or Activity.PLAYER_NONE;

		local fontCache = widthCaches[smallFont];
		local totalX = 0;
		local totalY = 0;
		local lineString = "";
		local lastIndex = 0;
		local length = #str;
		local offsets = {};
		local lines = {};
		local lineWidths = {};
		local icons = {};
		local iconOffsets = {};
		local iconFromLine = {};

		for i = 1, length do
			local ch = str:sub(i, i);
			local byte = ch:byte();
			local w = fontCache[byte];

			if not w then
				if byte >= 242 and byte < 255 then
					w = 9;
					table.insert(icons, ch:byte());
					table.insert(iconOffsets, Vector(totalX + 4, totalY + 7));
					table.insert(iconFromLine, #lines + 1);
					ch = "  \207\207";
				elseif ch == "\t" then
					w = 15;
					ch = "     ";
					fontCache[ch:byte()] = w;
				else
					w = FrameMan:CalculateTextWidth(ch, smallFont);
					fontCache[ch:byte()] = w;
				end
			end

			local newLine = ch == "\n";
			local drawFlag = newLine or totalX + w > width;

			if not drawFlag then
				lineString = lineString .. ch;
				lastIndex = i;
				totalX = totalX + w;
			end

			if i == length or drawFlag then
				table.insert(offsets, Vector(0, totalY));
				table.insert(lines, lineString);
				table.insert(lineWidths, totalX);

				if i ~= length and totalY + lineOffset * 2 <= height then
					totalY = totalY + lineOffset;
					if not newLine then
						totalX = w;
						lineString = ch;
					else
						totalX = 0;
						lineString = "";
					end
				else
					break;
				end
			end
		end

		-- Offset has to be adjusted by both the number of lines and a constant 4
		local alignmentOffset = Vector(0, - (lineOffset * #lines + (smallFont and -4 or 4)) * valignment / 2);

		for i, line in pairs(lines) do
			local offset = offsets[i] + alignmentOffset;
				-- + Vector(0, lineOffset * (1 - math.cos(rotation)) / 2);
			PrimitiveMan:DrawTextPrimitive(player, pos + offset:RadRotate(rotation), line, smallFont, halignment, rotation);
		end
		
		for i, icon in pairs(icons) do
			local offset = Vector(iconOffsets[i].X - lineWidths[iconFromLine[i]] * halignment / 2, iconOffsets[i].Y) + alignmentOffset;
			PrimitiveMan:DrawBitmapPrimitive(player, pos + offset:RadRotate(rotation), CF.FontIcons[icon], rotation, false, false);
		end

		return Vector(0, totalY + lineOffset), str:sub(lastIndex + 1, -1);
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
do
	-----------------------------------------------------------------------
	-- Draw boxes for menus
	-----------------------------------------------------------------------
	local emptyBlend = { 000, 000, 000, 000 };
	function CF.DrawMenuBox(player, x1, y1, x2, y2, palette, blendMode, blend)
		player = player or Activity.PLAYER_NONE;
		palette = palette or CF.MenuNormalIdle;
		blendMode = blendMode or DrawBlendMode.Transparency;
		blend = blend or emptyBlend;

		local outter = BoxPrimitive(player, Vector(x1, y1), Vector(x2, y2), palette[1]);
		local inner = BoxPrimitive(player, Vector(x1, y1) + Vector(1, 1), Vector(x2, y2) - Vector(1, 1), palette[2]);
		local panel = BoxFillPrimitive(player, Vector(x1, y1) + Vector(2, 2), Vector(x2, y2) - Vector(2, 2), palette[3]);
		PrimitiveMan:DrawPrimitives(blendMode, blend[1], blend[2], blend[3], blend[4], { outter, inner, panel });
	end
	-----------------------------------------------------------------------
	-- Draw questionable frame for menus
	-----------------------------------------------------------------------
	function CF.DrawMenuFrame(player, x1, y1, x2, y2, palette, blendMode, blend)
		player = player or Activity.PLAYER_NONE;
		palette = palette or CF.MenuNormalIdle;
		blendMode = blendMode or DrawBlendMode.Transparency;
		blend = blend or emptyBlend;

		local outter = BoxPrimitive(player, Vector(x1, y1), Vector(x2, y2), palette[1]);
		local inner = BoxPrimitive(player, Vector(x1, y1) + Vector(1, 1), Vector(x2, y2) + Vector(-1, -1), palette[2]);
		local panel = BoxFillPrimitive(player, Vector(x1, y1) + Vector(2, 2), Vector(x2, y1) + Vector(-2, 11), palette[3]);
		PrimitiveMan:DrawPrimitives(blendMode, blend[1], blend[2], blend[3], blend[4], { outter, inner, panel });
	end
	-----------------------------------------------------------------------
	-- Draw progress bars for menus
	-----------------------------------------------------------------------
	function CF.DrawProgressBar(player, left, top, right, bottom, progress, palette, blendMode, blend)
		player = player or Activity.PLAYER_NONE;
		blendMode = blendMode or DrawBlendMode.Transparency;
		blend = blend or emptyBlend;

		local width = right - left + 1;
		local height = bottom - top - 4;
		local primitives = {};

		-- Shade
		local start, stop;
		start, stop = Vector(left + 1, bottom), Vector(right, bottom);
		table.insert(primitives, LinePrimitive(player, start, stop, palette[3]));
		start, stop = Vector(right, top + 1), Vector(right, bottom - 1);
		table.insert(primitives, LinePrimitive(player, start, stop, palette[3]));

		-- Box
		start, stop = Vector(left, top), Vector(right - 1, bottom - 1);
		table.insert(primitives, BoxPrimitive(player, start, stop, palette[1]));

		-- Segments
		local n = math.floor(progress * (width / 2 - 2));
		for i = 1, n do
			start, stop = Vector(left + i * 2 - 1, top + 1), Vector(left + i * 2, top + 1);
			table.insert(primitives, LinePrimitive(player, start, stop, palette[3]));
			start, stop = Vector(left + i * 2 - 1, bottom - 2), Vector(left + i * 2, bottom - 2);
			table.insert(primitives, LinePrimitive(player, start, stop, palette[3]));
			start, stop = Vector(left + i * 2 - 1, top + 2), Vector(left + i * 2 - 1, bottom - 3);
			table.insert(primitives, LinePrimitive(player, start, stop, palette[3]));
			start, stop = Vector(left + i * 2, top + 2), Vector(left + i * 2, top + 2);
			table.insert(primitives, LinePrimitive(player, start, stop, palette[2]));
			start, stop = Vector(left + i * 2, bottom - 3), Vector(left + i * 2, bottom - 3);
			table.insert(primitives, LinePrimitive(player, start, stop, palette[2]));
			start, stop = Vector(left + i * 2, top + 3), Vector(left + i * 2, bottom - 4);
			table.insert(primitives, LinePrimitive(player, start, stop, palette[1]));
		end
	
		-- Remainder
		start, stop = Vector(left + 1 + n * 2, top + 1), Vector(right - 2, bottom - 2);
		table.insert(primitives, BoxFillPrimitive(player, start, stop, palette[3]));
		PrimitiveMan:DrawPrimitives(blendMode, blend[1], blend[2], blend[3], blend[4], primitives);
	end
	-----------------------------------------------------------------------
	-- Draw label element
	-----------------------------------------------------------------------
	function CF.DrawLabel(el, player)
		player = player or Activity.PLAYER_NONE;
		-- Labels can ommit presets or texts
		if el.Backdrop then
			local x = el.Pos.X;
			local y = el.Pos.Y;
			local w = el.Width;
			local h = el.Height;
			local palettes = el.Palettes or CF.MenuNormalPalette;
			local state = el.State or CF.ElementStates.IDLE;
			CF.DrawMenuBox(player, x - w / 2, y - h / 2, x + w / 2 - 1, y + h / 2 - 1, palettes[state]);
		end

		if el.Text then
			CF.DrawString(el.Text, el.Pos, el.Width, el.Height, nil, nil, el.Centered and 1 or 0, el.Centered and 1 or 0, nil, player);
		end
	end
	-----------------------------------------------------------------------
	-- Draw button element
	-----------------------------------------------------------------------
	function CF.DrawButton(el, player)
		player = player or Activity.PLAYER_NONE;
		if el.Visible ~= false then
			local x = el.Pos.X;
			local y = el.Pos.Y;
			local w = el.Width;
			local h = el.Height;
			local palettes = el.Palettes or CF.MenuNormalPalette;
			local state = el.State or CF.ElementStates.IDLE;
			if el.Backdrop ~= false then
				CF.DrawMenuBox(player, x - w / 2, y - h / 2, x + w / 2 - 1, y + h / 2 - 1, palettes[state]);
			else
				CF.DrawMenuFrame(player, x - w / 2, y - h / 2, x + w / 2 - 1, y + h / 2 - 1, palettes[state]);
			end

			if el.Text then
				CF.DrawString(el.Text, el.Pos, el.Width - 6, el.Height - 6, nil, nil, 1, 1, nil, player);
			end
		end
	end
end
-----------------------------------------------------------------------
-- Converts time in second to string h:mm:ss
-----------------------------------------------------------------------
function CF.ConvertTimeToString(period)
	local timestr = "";

	local hours = (period - period % 3600) / 3600;
	period = period - hours * 3600;
	local minutes = (period - period % 60) / 60;
	period = period - minutes * 60;
	local seconds = period;

	if hours > 0 then
		timestr = timestr .. string.format("%d", hours) .. ":";
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
-----------------------------------------------------------------------
-- Make item of specified preset, module and class
-----------------------------------------------------------------------
function CF.MakeItem(class, preset, module)
	local item = nil;
	class = class or "HDFirearm";

	if class == "HeldDevice" then
		item = module == nil and CreateHeldDevice(preset) or CreateHeldDevice(preset, module);
	elseif class == "HDFirearm" then
		item = module == nil and CreateHDFirearm(preset) or CreateHDFirearm(preset, module);
	elseif class == "TDExplosive" then
		item = module == nil and CreateTDExplosive(preset) or CreateTDExplosive(preset, module);
	elseif class == "ThrownDevice" then
		item = module == nil and CreateThrownDevice(preset) or CreateThrownDevice(preset, module);
	end

	return item;
end
-----------------------------------------------------------------------
-- Make actor of specified preset, class, module, rank, identity, and player, and prestige, name, and limbs, wow
-----------------------------------------------------------------------
function CF.MakeActor(class, preset, module, xp, identity, player, prestige, name, limbs)
	local actor = nil;
	class = class or "AHuman";
	preset = preset or "Skeleton";

	if class == "AHuman" then
		actor = module == nil and CreateAHuman(preset) or CreateAHuman(preset, module);
	elseif class == "ACrab" then
		actor = module == nil and CreateACrab(preset) or CreateACrab(preset, module);
	elseif class == "Actor" then
		actor = module == nil and CreateActor(preset) or CreateActor(preset, module);
	elseif class == "ACDropShip" then
		actor = module == nil and CreateACDropShip(preset) or CreateACDropShip(preset, module);
	elseif class == "ACRocket" then
		actor = module == nil and CreateACRocket(preset) or CreateACRocket(preset, module);
	end

	if limbs then
		CF.ReplaceLimbs(actor, limbs);
	end

	for item in actor.Inventory do
		if item then
			actor:RemoveInventoryItem(item.PresetName);
		end
	end

	xp = tonumber(xp);

	if actor then
		actor.AngularVel = 0;
		if identity then
			actor:SetNumberValue("Identity", tonumber(identity));
		end
		if player then
			actor:SetNumberValue("VW_BrainOfPlayer", tonumber(player));
		end
		if prestige then
			actor:SetNumberValue("VW_Prestige", tonumber(prestige))
		end
		if name and name ~= "" then
			actor:SetStringValue("VW_Name", name)
		end
		if xp then
			actor:SetNumberValue("VW_XP", xp);
			local rank = CF.GetRankFromXP(xp);
			actor:SetNumberValue("VW_Rank", rank);
			CF.BuffActor(actor, rank, actor:GetNumberValue("VW_Prestige"));
		end
	end

	return actor;
end
-----------------------------------------------------------------------
-- Use class name to get reference type
-----------------------------------------------------------------------
function CF.GetRankFromXP(xp)
	local maxRank = #CF.Ranks;
	for rank = 1, maxRank do
		if xp < CF.Ranks[rank] then
			return rank - 1;
		end
	end
	return maxRank;
end
-----------------------------------------------------------------------
-- Use class name to get reference type
-----------------------------------------------------------------------
CF.FixActorReference = function(actor)
	local cl = actor.ClassName
	if cl == "AHuman" then
		return ToAHuman(actor)
	elseif cl == "ACrab" then
		return ToACrab(actor)
	elseif cl == "ACraft" then
		return ToACraft(actor)
	elseif cl == "ACRocket" then
		return ToACRocket(actor)
	elseif cl == "ACDropship" then
		return ToACDropship(actor)
	end
	return ToActor(actor)
end
-----------------------------------------------------------------------
-- Buff an actor based on their rank
-----------------------------------------------------------------------
CF.BuffActor = function(actor, rank, prestige)
	local actor = CF.FixActorReference(actor)
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
	if actor.LimbPathPushForce then
		actor:SetLimbPathTravelSpeed(1, actor:GetLimbPathTravelSpeed(1) * sqrtFactor)
		actor.LimbPathPushForce = actor.LimbPathPushForce * (math.sqrt(sqrtFactor))
	end
	--print("actor ".. actor.PresetName .." buffed with" .. (prestige and " prestige " or "rank ").. rank)
end
-----------------------------------------------------------------------
-- Reverse buff effect
-----------------------------------------------------------------------
CF.UnBuffActor = function(actor, rank, prestige)
	local actor = CF.FixActorReference(actor)
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
	if actor.LimbPathPushForce then
		actor:SetLimbPathTravelSpeed(1, actor:GetLimbPathTravelSpeed(1) / sqrtFactor)
		actor.LimbPathPushForce = actor.LimbPathPushForce / (math.sqrt(sqrtFactor))
	end
end
-----------------------------------------------------------------------
-- Get a specific limb by ID
-----------------------------------------------------------------------
function CF.GetLimbData(actor, id)
	local limb;

	if IsAHuman(actor) then
		actor = ToAHuman(actor);
		limb = actor[id];
		if limb then
			return limb:GetModuleAndPresetName();
		end
	elseif IsACrab(actor) then
		actor = ToACrab(actor);
		limb = actor[id];
		if limb then
			return limb:GetModuleAndPresetName();
		end
	end

	return "None";
end
-----------------------------------------------------------------------
-- Read the limb data of this AHuman and replace limbs accordingly
-----------------------------------------------------------------------
CF.ReplaceLimbs = function(actor, limbs)
	if IsAHuman(actor) then
		actor = ToAHuman(actor);
		
		for i, limbID in pairs(CF.CrabLimbID) do
			local targetLimb = actor[limbID];
			local limbString = limbs[limbID];

			if limbString == "None" then
				actor:RemoveAttachable(targetLimb, false, false);
			elseif limbString then
				local newLimb = nil;

				if limbID == "Head" then
					newLimb = CreateAttachable(limbString) or CreateHeldDevice(limbString) or CreateAEmitter(limbString);
				elseif limbID == "Jetpack" then
					newLimb = CreateAEJetpack(limbString);
				elseif limbID == "FGArm" or limbID == "BGArm" then
					newLimb = CreateArm(limbString);
				elseif limbID == "FGLeg" or limbID == "BGLeg" then
					newLimb = CreateLeg(limbString);
				end

				if targetLimb then
					newLimb.ParentOffset = targetLimb.ParentOffset;
					newLimb.DrawnAfterParent = targetLimb.DrawnAfterParent;
					if targetLimb.ParentBreakWound then
						newLimb.ParentBreakWound = ToAEmitter(targetLimb.ParentBreakWound):Clone();
					end
				end

				actor[limbID] = newLimb;
			end
		end

		return true;
	elseif IsACrab(actor) then
		actor = ToACrab(actor);
		
		for i, limbID in pairs(CF.CrabLimbID) do
			local targetLimb = actor[limbID];
			local limbString = limbs[limbID];

			if limbString == "None" then
				actor:RemoveAttachable(targetLimb, false, false);
			elseif limbString then
				local newLimb = nil;

				if limbID == "Head" then
					newLimb = CreateAttachable(limbString) or CreateHeldDevice(limbString) or CreateAEmitter(limbString);
				elseif limbID == "Jetpack" then
					newLimb = CreateAEJetpack(limbString);
				elseif limbID == "FGArm" or limbID == "BGArm" then
					newLimb = CreateArm(limbString);
				elseif limbID == "FGLeg" or limbID == "BGLeg" then
					newLimb = CreateLeg(limbString);
				end

				if targetLimb then
					newLimb.ParentOffset = targetLimb.ParentOffset;
					newLimb.DrawnAfterParent = targetLimb.DrawnAfterParent;
					if targetLimb.ParentBreakWound then
						newLimb.ParentBreakWound = ToAEmitter(targetLimb.ParentBreakWound):Clone();
					end
				end

				actor[limbID] = newLimb;
			end
		end

		return true;
	end

	return false;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.AttemptReplaceLimb = function(actor, limb)
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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.RandomizeLimbs = function(actor, limbs)
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
			if math.random() <= actor:GetNumberValue("VW_XP") / CF.Ranks[#CF.Ranks] then
				CF.SetRandomName(actor)
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
-----------------------------------------------------------------------
-- Set which actor is being named right now
-----------------------------------------------------------------------
CF.SetNamingActor = function(actor, player)
	CF.TypingActor = actor
	CF.TypingPlayer = player
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.SetRandomName = function(actor)
	if not actor:StringValueExists("VW_Name") then
		actor:SetStringValue("VW_Name", CF.GenerateRandomName())
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
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
-----------------------------------------------------------------------
-- Set actors to hunt for nearby actors of a specific team - or regroup near actors of the same team
-----------------------------------------------------------------------
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
				if CF.IsBrain(actor) then
					table.insert(brains, target)
				end
			end
		end
		local target
		if #brains > 0 and math.random(3) <= 1 then
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
-----------------------------------------------------------------------
-- Send actors after specific target(s)
-----------------------------------------------------------------------
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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.GetPlayerGold = function(gs)
	return tonumber(gs["PlayerGold"])
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.SetPlayerGold = function(gs, funds)
	-- Set the in-activity gold as well, although we don't use it
	gs["PlayerGold"] = math.ceil(funds)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.CommitMissionResult = function(gs, result)
	-- Set result
	gs["LastMissionResult"] = result
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.ChangeGold = function(gs, amount)
	CF.SetPlayerGold(gs, CF.GetPlayerGold(gs) + amount)
	return CF.GetPlayerGold(gs);
end
-----------------------------------------------------------------------
-- Get table with inventory of actor, inventory cleared as a result
-----------------------------------------------------------------------
CF.GetInventory = function(actor)
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

					if CF.DiscardableItems[actor.PresetName] ~= nil then
						for i = 1, #CF.DiscardableItems[actor.PresetName] do
							if CF.DiscardableItems[actor.PresetName][i] == item.PresetName then
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

				if CF.DiscardableItems[actor.PresetName] ~= nil then
					for i = 1, #CF.DiscardableItems[actor.PresetName] do
						if CF.DiscardableItems[actor.PresetName][i] == item.PresetName then
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
-----------------------------------------------------------------------
-- Calculate distance
-----------------------------------------------------------------------
CF.Dist = function(pos1, pos2)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX).Magnitude
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.DistOver = function(pos1, pos2, magnitude)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX):MagnitudeIsGreaterThan(magnitude)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.DistUnder = function(pos1, pos2, magnitude)
	return SceneMan:ShortestDistance(pos1, pos2, SceneMan.SceneWrapsX):MagnitudeIsLessThan(magnitude)
end
-----------------------------------------------------------------------
-- Save mission report
-----------------------------------------------------------------------
CF.SaveMissionReport = function(gs, rep)
	-- Dump mission report to config to be saved
	for i = 1, CF.MaxMissionReportLines do
		gs["MissionReport" .. i] = nil
	end

	for i = 1, #rep do
		gs["MissionReport" .. i] = rep[i]
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.CountActors = function(team)
	local gs = 0

	for actor in MovableMan.Actors do
		if
			actor.Team == team
			and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
			and not (CF.IsBrain(actor) or actor:NumberValueExists("VW_Ally"))
		then
			gs = gs + 1
		end
	end

	return gs
end
-----------------------------------------------------------------------
--	Returns how many science points corresponds to selected difficulty level
-----------------------------------------------------------------------
CF.GetTechLevelFromDifficulty = function(faction, difficulty)
	local maxpoints = 0

	for i = 1, #CF.ItmNames[faction] do
		if CF.ItmUnlockData[faction][i] > maxpoints then
			maxpoints = CF.ItmUnlockData[faction][i]
		end
	end

	for i = 1, #CF.ActNames[faction] do
		if CF.ActUnlockData[faction][i] > maxpoints then
			maxpoints = CF.ActUnlockData[faction][i]
		end
	end

	return math.floor(maxpoints / CF.MaxDifficulty * difficulty)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.CalculateReward = function(base, diff)
	local coeff = 1 + (diff - 1) * 0.35

	return math.floor(base * coeff)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.IsLocationHasAttribute = function(loc, attr)
	local attrs = CF.LocationAttributes[loc]

	if attrs ~= nil then
		for i = 1, #attrs do
			if attrs[i] == attr then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
CF.GiveExp = function(gs, exppts)
	local levelup = false

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if ActivityMan:GetActivity():PlayerActive(player) and ActivityMan:GetActivity():PlayerHuman(player) then
			local curexp = tonumber(gs["Brain" .. player .. "Exp"])
			local cursklpts = tonumber(gs["Brain" .. player .. "SkillPoints"])
			local curlvl = tonumber(gs["Brain" .. player .. "Level"])

			--print ("Curexp "..curexp)
			--print ("Exppts "..exppts)

			curexp = curexp + exppts

			--print (CF.ExpPerLevel)
			--print (math.floor(curexp / CF.ExpPerLevel))

			while math.floor(curexp / CF.ExpPerLevel) > 0 do
				if curlvl < CF.MaxLevel then
					curexp = curexp - CF.ExpPerLevel
					cursklpts = cursklpts + 1
					curlvl = curlvl + 1
					levelup = true

					--print (levelup)
				else
					curexp = 0
					break
				end
			end

			gs["Brain" .. player .. "SkillPoints"] = cursklpts
			gs["Brain" .. player .. "Exp"] = curexp
			gs["Brain" .. player .. "Level"] = curlvl
		end
	end

	return levelup
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
