-----------------------------------------------------------------------
-- Initializes all game data when new game started and returns new gameState
-----------------------------------------------------------------------
CF.MakeFreshGameState = function(playerFaction, cpus, activity)
	local gameState = {};
	local difficulty = activity.Difficulty;

	-- Init game time
	gameState["Time"] = tostring(0)

	gameState["Difficulty"] = tostring(difficulty);
	gameState["FogOfWar"] = activity.FogOfWarEnabled and "True" or "False";
	gameState["AISkillPlayer"] = tostring(activity:GetTeamAISkill(Activity.TEAM_1));
	gameState["AISkillCPU"] = tostring(activity:GetTeamAISkill(Activity.TEAM_2));

	-- Difficulty related variables
	if difficulty <= GameActivity.CAKEDIFFICULTY then
		gameState["MissionDifficultyBonus"] = -2
	elseif difficulty <= GameActivity.EASYDIFFICULTY then
		gameState["MissionDifficultyBonus"] = -1
	elseif difficulty <= GameActivity.MEDIUMDIFFICULTY then
		gameState["MissionDifficultyBonus"] = -0
	elseif difficulty <= GameActivity.HARDDIFFICULTY then
		gameState["MissionDifficultyBonus"] = 1
	elseif difficulty <= GameActivity.NUTSDIFFICULTY then
		gameState["MissionDifficultyBonus"] = 2
	else
		gameState["MissionDifficultyBonus"] = 3
	end

	-- Set up players
	gameState["PlayerFaction"] = playerFaction
	gameState["PlayerGold"] = tostring(math.floor(activity:GetStartingGold()))

	-- Set vessel attributes
	local vessel = difficulty == GameActivity.MAXDIFFICULTY and "Mule" or "Lynx";
	gameState["PlayerVesselStorageCapacity"] = tostring(CF.VesselStartStorageCapacity[vessel])
	gameState["PlayerVesselClonesCapacity"] = tostring(CF.VesselStartClonesCapacity[vessel])
	gameState["PlayerVesselLifeSupport"] = tostring(CF.VesselStartLifeSupport[vessel])
	gameState["PlayerVesselCommunication"] = tostring(CF.VesselStartCommunication[vessel])
	gameState["PlayerVesselSpeed"] = tostring(CF.VesselStartSpeed[vessel])
	gameState["PlayerVesselTurrets"] = tostring(CF.VesselStartTurrets[vessel])
	gameState["PlayerVesselTurretStorage"] = tostring(CF.VesselStartTurretStorage[vessel])
	gameState["PlayerVesselBombBays"] = tostring(CF.VesselStartBombBays[vessel])
	gameState["PlayerVesselBombStorage"] = tostring(CF.VesselStartBombStorage[vessel])
	gameState["PlayerVessel"] = vessel;

	-- Set up initial location - Tradestar
	gameState["Planet"] = tostring(CF.Planet[1])
	gameState["Location"] = tostring(CF.Location[1])

	local locpos = CF.LocationPos[gameState["Location"]]

	gameState["ShipX"] = tostring(locpos.X)
	gameState["ShipY"] = tostring(locpos.Y)
	gameState["Scene"] = CF.VesselScene[gameState["PlayerVessel"]]
	gameState["Mode"] = "Vessel"

	local activecpus = 0

	for i = 1, CF.MaxCPUPlayers do
		if cpus[i] then
			gameState["Player" .. i .. "Faction"] = cpus[i]
			gameState["Player" .. i .. "Active"] = "True"
			gameState["Player" .. i .. "Type"] = "CPU"

			if cpus[i] == playerFaction then
				gameState["Player" .. i .. "Reputation"] = 500
			else
				computedReputation = 0;

				if CF.FactionNatures[playerFaction] ~= CF.FactionNatures[cpus[i]] then
					computedReputation = computedReputation + CF.ReputationHuntThreshold * (difficulty / 100);
				end

				if CF.FactionAlignments[playerFaction] ~= CF.FactionAlignments[cpus[i]] then
					computedReputation = computedReputation + CF.ReputationHuntThreshold * (difficulty / 100);
				end

				if CF.FactionIngroupPreference[cpus[i]] then
					computedReputation = computedReputation + CF.ReputationHuntThreshold * (difficulty / 100) * 2;
				end

				gameState["Player" .. i .. "Reputation"] = math.floor(computedReputation * (0.9 + 0.2 * math.random()));
			end

			activecpus = activecpus + 1
		end
	end

	gameState["ActiveCPUs"] = activecpus

	CF.GenerateRandomMissions(gameState)

	local repBudget = 800
	local playerFaction = CF.GetPlayerFaction(gameState, 1);
	local actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "AHuman", repBudget * 2)

	local pistols = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.PISTOL, repBudget)
	local rifles = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.RIFLE, repBudget * 2)
	local shotguns = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.SHOTGUN, repBudget * 2)
	local snipers = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.SNIPER, repBudget * 2)
	local shields = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.SHIELD, repBudget)
	local diggers = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.DIGGER, repBudget * 0)
	local grenades = CF.MakeListOfMostPowerfulWeapons(playerFaction, CF.WeaponTypes.GRENADE, repBudget)

	if not actors then
		-- Pricy humans, alright.
		actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "AHuman", math.huge)
		if not actors then
			-- No humans? That's cool...
			actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "ACrab", math.huge)
			if not actors then
				-- No limbed actors??? That's hip!
				actors = CF.MakeListOfMostPowerfulActorsOfClass(playerFaction, CF.ActorTypes.ANY, "Any", math.huge)
			end
		end
	end

	-- Assign initial player actors in storage
	local cloneCapacity = tonumber(gameState["PlayerVesselClonesCapacity"]);
	local actorPrefix = "ClonesStorage"

	if cloneCapacity <= 0 then
		actorPrefix = "Actor"
		gameState["DeserializeOnboard"] = "True";
	end

	if actorPrefix == "Actor" or cloneCapacity < 4 then
		cloneCapacity = 4;
	end

	for i = 1, cloneCapacity do
		local chosenActor = actors[math.random(#actors)]
		gameState[actorPrefix .. i .. "Preset"] = CF.ActPresets[playerFaction][chosenActor["Actor"]]
		gameState[actorPrefix .. i .. "Class"] = CF.ActClasses[playerFaction][chosenActor["Actor"]]
		gameState[actorPrefix .. i .. "Module"] = CF.ActModules[playerFaction][chosenActor["Actor"]]
		gameState[actorPrefix .. i .. "Identity"] = i - 1

		local item = nil
		local slt = 1
		local list = nil
		local count = 1

		::insert::
		if list then
			if count <= 1 then
				item = list[math.random(#list)]
				gameState[actorPrefix .. i .. "Item" .. slt .. "Preset"] = CF.ItmPresets[playerFaction][item["Item"]]
				gameState[actorPrefix .. i .. "Item" .. slt .. "Class"] = CF.ItmClasses[playerFaction][item["Item"]]
				gameState[actorPrefix .. i .. "Item" .. slt .. "Module"] = CF.ItmModules[playerFaction][item["Item"]]
				slt = slt + 1
			else
				gameState[actorPrefix .. i .. "Item" .. slt .. "Preset"] = CF.ItmPresets[playerFaction][item["Item"]]
				gameState[actorPrefix .. i .. "Item" .. slt .. "Class"] = CF.ItmClasses[playerFaction][item["Item"]]
				gameState[actorPrefix .. i .. "Item" .. slt .. "Module"] = CF.ItmModules[playerFaction][item["Item"]]
				count = count - 1
				goto insert
			end
		end
		
		if slt == 1 then
			-- coin flip unless guy one, or guy two and no shotguns
			if rifles and (math.random(2) == 1 or i == 1 or (i == 2 and not shotguns)) then
				list = rifles
				goto insert
			-- coin flip unless we're guy two
			elseif shotguns and (math.random(2) == 1 or i == 2) then
				list = shotguns
				goto insert
			-- coin flip
			elseif snipers and (math.random(2) == 1) then
				list = snipers
				goto insert
			-- last chance
			elseif pistols then
				list = pistols
				goto insert
			-- give up
			else
				slt = 2
			end
		end
		if slt == 2 then
			-- grab one or two pistols if we have none
			-- grab one if we do have one and we're akimbo inclined
			if pistols and (list ~= pistols or math.random(2) == 1) then
				if list ~= pistols then
					count = math.random(2)
					list = pistols
					item = list[math.random(#list)]
					goto insert
				else
					list = pistols
					goto insert
				end
			-- grab a shield if no pistols or no akimbo inclination and no real gun
			elseif shields then
				list = shields
				goto insert
			-- give up
			else
				slt = 3
			end
		end
		if slt == 3 then
			-- coin flip unless he's the last guy
			if diggers and (math.random(2) == 1 or i == 4) then
				list = diggers
				goto insert
			-- grenade otherwise
			elseif grenades then
				list = grenades
				goto insert
			-- give up
			else
				slt = 4
			end
		end
		if slt == 4 then
			if grenades then
				count = math.random(2)
				list = grenades
				item = list[math.random(#list)]
				goto insert
			end
		end
	end

	-- Give the starting brains some small arms
	if CF.BrainClasses[playerFaction] ~= "ACrab" then
		for i = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local list = CF.PreferedBrainInventory[playerFaction] or { CF.WeaponTypes.PISTOL, CF.WeaponTypes.PISTOL, CF.WeaponTypes.TOOL };

			for j = 1, #list do
				local weapons = CF.MakeListOfMostPowerfulWeapons(playerFaction, list[j], math.huge);

				if weapons ~= nil then
					local factionIndex = weapons[1].Faction;
					local itemIndex = weapons[1].Item;
					
					gameState["Brain" .. i .. "Item" .. j .. "Preset"] = CF.ItmPresets[playerFaction][itemIndex]
					gameState["Brain" .. i .. "Item" .. j .. "Class"] = CF.ItmClasses[playerFaction][itemIndex]
					gameState["Brain" .. i .. "Item" .. j .. "Module"] = CF.ItmModules[playerFaction][itemIndex]
				end
			end
		end
	end

	return gameState;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
