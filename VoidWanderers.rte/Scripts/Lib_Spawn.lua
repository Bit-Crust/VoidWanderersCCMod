-----------------------------------------------------------------------
-- Generate a specific brain, with or without weapons
-----------------------------------------------------------------------
function CF.MakeBrainWithPreset(faction, class, preset, module, giveWeapons)
	local actor = CF.MakeActor(class, preset, module);

	if actor ~= nil and giveWeapons then
		local weapon = nil;
		local list = CF.PreferedBrainInventory[faction] or { CF.WeaponTypes.RIFLE, CF.WeaponTypes.DIGGER };

		for i = 1, #list do
			local weapons = CF.MakeListOfMostPowerfulWeapons(faction, list[i], math.huge);

			if weapons ~= nil then
				local factionIndex = weapons[1].Faction;
				local itemIndex = weapons[1].Item;
				weapon = CF.MakeItemAtIndex(factionIndex, itemIndex);

				if weapon ~= nil then
					actor:AddInventoryItem(weapon);
				end
			end
		end
	end

	return actor;
end
-----------------------------------------------------------------------
-- Generate an unremarkable brain unit, with or without weapons
-----------------------------------------------------------------------
function CF.MakeBrain(faction, giveWeapons)
	return CF.MakeBrainWithPreset(faction, CF.BrainClasses[faction], CF.Brains[faction], CF.BrainModules[faction], giveWeapons ~= false);
end
-----------------------------------------------------------------------
-- Generate a remarkable brain unit, with or without weapons, at specified level
-----------------------------------------------------------------------
function CF.MakeRPGBrain(faction, giveWeapons, level)
	local brain = CF.MakeBrain(faction, giveWeapons ~= false);

	if brain then
		local skillset = {0, 0, 0, 0, 0, 0, 0, 0, 0};
		local availableSkills = {1, 2, 3, 4, 5, 6, 7, 8, 9};
		local pointsAvailable = level;

		while pointsAvailable > 0 do
			local index = math.random(#availableSkills);
			local skillIndex = availableSkills[index];
			local currentLevel = skillset[skillIndex];
			local cost = (currentLevel + 1) * (skillIndex == 1 and 2 or 1);

			-- If we can buy the one we've picked, do so, record it, subtract the cost, then increment it
			if currentLevel < 5 and pointsAvailable >= cost then
				currentLevel = currentLevel + 1;
				skillset[skillIndex] = currentLevel;
				pointsAvailable = pointsAvailable - cost;
				cost = (currentLevel + 1) * (skillIndex == 1 and 2 or 1);
			end

			-- If we couldn't buy it, or we can't anymore, forget about it going forward
			if currentLevel >= 5 or pointsAvailable < cost then
				table.remove(availableSkills, index);
			end

			-- We're done if everything's off the table
			if #availableSkills == 0 then
				break;
			end
		end
		
		-- We gotta communicate this somehow
		brain:SetNumberValue("VW_PreassignedSkills", 1);
		brain:SetNumberValue("VW_BrainLevel", level);
		brain:SetNumberValue("VW_ToughSkill", skillset[1]);
		brain:SetNumberValue("VW_ShieldSkill", skillset[2]);
		brain:SetNumberValue("VW_TelekenesisSkill", skillset[3]);
		brain:SetNumberValue("VW_RepairSkill", skillset[4]);
		brain:SetNumberValue("VW_HealSkill", skillset[5]);
		brain:SetNumberValue("VW_SelfHealSkill", skillset[6]);
		brain:SetNumberValue("VW_ScannerSkill", skillset[7]);
		brain:SetNumberValue("VW_SplitterSkill", skillset[8]);
		brain:SetNumberValue("VW_QuantumSkill", skillset[9]);
	end

	return brain;
end
-----------------------------------------------------------------------
--	Spawns some random infantry of specified faction, tries to spawn AHuman
-----------------------------------------------------------------------
function CF.SpawnRandomInfantry(team, pos, faction, aimode)
	local actor = nil;
	local weapon = nil;
	local actorCandidateName = nil;
	local weaponCandidateName = nil;

	-- Emergency counter in case we don't have AHumans in factions
	local counter = 0;

	while true do
		actorCandidateName = #CF.ActNames[faction] > 0 and math.random(#CF.ActNames[faction]) or 0;

		if
			(CF.ActClasses[faction][actorCandidateName] == nil
			or CF.ActClasses[faction][actorCandidateName] == "AHuman")
			and CF.ActTypes[faction][actorCandidateName] ~= CF.ActorTypes.ARMOR
			and CF.ActModules[faction][actorCandidateName] ~= "Base.rte"
		then
			break
		end

		-- Break to avoid endless loop
		counter = counter + 1
		if counter > 20 then
			break
		end
	end

	actor = CF.MakeActor(
		CF.ActClasses[faction][actorCandidateName], 
		CF.ActPresets[faction][actorCandidateName], 
		CF.ActModules[faction][actorCandidateName]
	)

	if actor == nil then
		return nil
	end

	-- Check if this is pre-equipped faction
	if not CF.PreEquippedActors[faction] then
		-- Emergency counter in case we don't have Rifles, Shotguns, or Snipers in faction
		local counter = 0

		while true do
			weaponCandidateName = math.random(#CF.ItmNames[faction])

			if
				CF.ItmTypes[faction][weaponCandidateName] == CF.WeaponTypes.RIFLE
				or CF.ItmTypes[faction][weaponCandidateName] == CF.WeaponTypes.SHOTGUN
				or CF.ItmTypes[faction][weaponCandidateName] == CF.WeaponTypes.SNIPER
			then
				break
			end

			-- Break to avoid endless loop
			counter = counter + 1
			if counter > 20 then
				break
			end
		end

		item = CF.MakeItem(
			CF.ItmClasses[faction][weaponCandidateName], 
			CF.ItmPresets[faction][weaponCandidateName], 
			CF.ItmModules[faction][weaponCandidateName]
		)

		if item ~= nil then
			actor:AddInventoryItem(item)
		end
	end

	actor.AIMode = aimode
	actor.Team = team

	if pos ~= nil then
		actor.Pos = pos
		MovableMan:AddActor(actor)
	end

	return actor
end
-----------------------------------------------------------------------
-- Create list of weapons of a type sorted by their power.
-----------------------------------------------------------------------
function CF.MakeListOfMostPowerfulWeapons(faction, weaponType, maxTech)
	local weapons, powers = {}, {};

	faction = CF.ItmNames[faction] and faction or error("No faction existing by name " .. tostring(faction), 2);

	-- Filter needed items
	for i = 1, #CF.ItmNames[faction] do
		if
			CF.ItmPowers[faction][i] > 0
			and CF.ItmUnlockData[faction][i] <= maxTech
			and (CF.WeaponTypes.ANY == weaponType or CF.ItmTypes[faction][i] == weaponType)
		then
			table.insert(weapons, { Item = i, Faction = faction });
			table.insert(powers, CF.ItmPowers[faction][i]);
		end
	end

	-- Sort them
	for j = 1, #weapons - 1 do
		for i = 1, #weapons - j do
			if powers[i] < powers[i + 1] then
				table.insert(weapons, i + 1, table.remove(weapons, i));
				table.insert(powers, i + 1, table.remove(powers, i));
			end
		end
	end

	if #weapons == 0 then
		weapons = nil;
	end

	return weapons, powers;
end
-----------------------------------------------------------------------
-- Create list of actors of a type sorted by their power.
-----------------------------------------------------------------------
function CF.MakeListOfMostPowerfulActors(faction, actorType, maxTech)
	local actors, powers = {}, {};

	for i = 1, #CF.ActNames[faction] do
		if
			CF.ActPowers[faction][i] > 0
			and CF.ActUnlockData[faction][i] <= maxTech
			and (CF.ActorTypes.ANY == actorType or CF.ActTypes[faction][i] == actorType)
		then
			local actor = { Actor = i, Faction = faction };
			table.insert(actors, actor);
			table.insert(powers, CF.ActPowers[faction][i]);
		end
	end

	-- Sort them
	for j = 1, #actors - 1 do
		for i = 1, #actors - j do
			if powers[i] < powers[i + 1] then
				table.insert(actors, i + 1, table.remove(actors, i));
				table.insert(powers, i + 1, table.remove(powers, i));
			end
		end
	end

	if #actors == 0 then
		actors = nil;
	end

	return actors, powers;
end
-----------------------------------------------------------------------
-- Create list of actors in faction of a type and class.
-----------------------------------------------------------------------
function CF.MakeListOfMostPowerfulActorsOfClass(faction, actorType, actorClass, maxTech)
	local actors = CF.MakeListOfMostPowerfulActors(faction, actorType, maxTech);
	local factionColumn = CF.ActClasses[faction];

	if actors and factionColumn then
		local offset = 0;

		for i = 1, #actors do
			local index = actors[i - offset].Actor;

			if "Any" ~= actorClass and (factionColumn[index] or "AHuman") ~= actorClass then
				table.remove(actors, i - offset);
				offset = offset + 1;
			end
		end

		if #actors == 0 then
			actors = nil;
		end
	end

	return actors;
end
-----------------------------------------------------------------------
-- Creates units presets for specified AI where gameState - gameState, participant - player, maxTech - max unlock data
-----------------------------------------------------------------------
function CF.CreateAIUnitPresets(gameState, participant, maxTech)
	local idealPresetActorTypes = {
		CF.ActorTypes.LIGHT,
		CF.ActorTypes.HEAVY,
		CF.ActorTypes.LIGHT,
		CF.ActorTypes.HEAVY,
		CF.ActorTypes.HEAVY,
		CF.ActorTypes.HEAVY,
		CF.ActorTypes.ARMOR,
		CF.ActorTypes.HEAVY,
		CF.ActorTypes.LIGHT,
		CF.ActorTypes.TURRET,
	};
	local idealPresetWeaponTypes = {
		CF.WeaponTypes.RIFLE,
		CF.WeaponTypes.RIFLE,
		CF.WeaponTypes.SNIPER,
		CF.WeaponTypes.SHOTGUN,
		CF.WeaponTypes.HEAVY,
		CF.WeaponTypes.HEAVY,
		CF.WeaponTypes.HEAVY,
		CF.WeaponTypes.SHIELD,
		CF.WeaponTypes.DIGGER,
		CF.WeaponTypes.SHOTGUN,
	};
	local idealPresetSecondaryTypes = {
		CF.WeaponTypes.PISTOL,
		CF.WeaponTypes.PISTOL,
		CF.WeaponTypes.PISTOL,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.RIFLE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.PISTOL,
		CF.WeaponTypes.PISTOL,
		CF.WeaponTypes.RIFLE,
		CF.WeaponTypes.GRENADE,
	};
	local idealPresetTertiaryTypes = {
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GRENADE,
		CF.WeaponTypes.GREANDE,
		CF.WeaponTypes.GRENADE,
	};

	local faction = CF.GetPlayerFaction(gameState, participant);

	if CF.PreEquippedActors[faction] then
		-- Fill presets for pre-equipped faction
		for presetType = 1, 10 do
			-- Build a list of acceptable actor types from best to worst as backup
			local potentialActorTypes = {}

			-- First add the ideal actor and weapon types
			potentialActorTypes[1] = idealPresetActorTypes[presetType]
			potentialActorTypes[2] = CF.ActorTypes.HEAVY
			potentialActorTypes[3] = CF.ActorTypes.LIGHT
			potentialActorTypes[4] = CF.ActorTypes.ARMOR
			
			-- Select a suitable actor based on his equipment class
			local match = nil

			for _, actorType in ipairs(potentialActorTypes) do
				local actors = CF.MakeListOfMostPowerfulActors(faction, actorType, maxTech)

				if actors ~= nil then
					for _, actor in ipairs(actors) do
						if CF.EquipmentTypes[faction][actor.Actor] == idealPresetWeaponTypes[presetType] then
							match = actor
							break
						end
					end

					if match ~= nil then
						break
					end
				end
			end

			if match ~= nil then
				gameState["Player" .. participant .. "Preset" .. presetType .. "Actor"] = match.Actor
				gameState["Player" .. participant .. "Preset" .. presetType .. "Faction"] = match.Faction

				--Reset all weapons
				for j = 1, CF.MaxItemsPerPreset do
					gameState["Player" .. participant .. "Preset" .. presetType .. "Item" .. j] = nil
					gameState["Player" .. participant .. "Preset" .. presetType .. "ItemFaction" .. j] = nil
				end

				-- If we didn't find a suitable engineer unit then try give digger to engineer preset
				if idealPresetWeaponTypes[presetType] == CF.WeaponTypes.DIGGER and presetType == CF.PresetTypes.ENGINEER then
					local weapons1 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.DIGGER, maxTech)

					if weapons1 ~= nil then
						gameState["Player" .. participant .. "Preset" .. presetType .. "Item" .. 1] = weapons1[1].Item
						gameState["Player" .. participant .. "Preset" .. presetType .. "ItemFaction" .. 1] = weapons1[1].Faction
					end
				end
			end
		end
	else
		for preset = CF.PresetTypes.INFANTRY1, CF.PresetTypes.DEFENDER do
			local actors, weights = CF.MakeListOfMostPowerfulActors(faction, idealPresetActorTypes[preset], maxTech);

			if not actors then
				actors, weights = CF.MakeListOfMostPowerfulActors(faction, CF.ActorTypes.LIGHT, maxTech);
			end

			if not actors then
				actors, weights = CF.MakeListOfMostPowerfulActors(faction, CF.ActorTypes.HEAVY, maxTech);
			end

			if not actors then
				actors, weights = CF.MakeListOfMostPowerfulActors(faction, CF.ActorTypes.ARMOR, maxTech);
			end

			if actors ~= nil then
				local actor = actors[CF.WeightedSelection(weights)];
				gameState["Player" .. participant .. "Preset" .. preset .. "Actor"] = actor.Actor;
				gameState["Player" .. participant .. "Preset" .. preset .. "Faction"] = actor.Faction;

				if CF.ActClasses[actor.Faction][actor.Actor] ~= "ACrab" then
					local weapons1, weights1 = CF.MakeListOfMostPowerfulWeapons(faction, idealPresetWeaponTypes[preset], maxTech);

					if not weapons1 then
						weapons1, weights1 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.RIFLE, maxTech);
					end

					if not weapons1 then
						weapons1, weights1 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.SHOTGUN, maxTech);
					end

					if not weapons1 then
						weapons1, weights1 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.SNIPER, maxTech);
					end

					if not weapons1 then
						weapons1, weights1 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.HEAVY, maxTech);
					end

					if not weapons1 then
						weapons1, weights1 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.PISTOL, maxTech);
					end

					local weapons2, weights2 = CF.MakeListOfMostPowerfulWeapons(faction, idealPresetSecondaryTypes[preset], maxTech);

					if not weapons2 then
						weapons2, weights2 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.PISTOL, maxTech);
					end

					if not weapons2 then
						weapons2, weights2 = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.DIGGER, maxTech);
					end

					local weapons3, weights3 = CF.MakeListOfMostPowerfulWeapons(faction, idealPresetTertiaryTypes[preset], maxTech);
					local weap = 1;

					if weapons1 ~= nil then
						local weapon = weapons1[CF.WeightedSelection(weights1)];
						gameState["Player" .. participant .. "Preset" .. preset .. "Item" .. weap] = weapon.Item;
						gameState["Player" .. participant .. "Preset" .. preset .. "ItemFaction" .. weap] = weapon.Faction;
						weap = weap + 1;
					end

					if weapons2 ~= nil then
						local weapon = weapons2[CF.WeightedSelection(weights2)];
						gameState["Player" .. participant .. "Preset" .. preset .. "Item" .. weap] = weapon.Item;
						gameState["Player" .. participant .. "Preset" .. preset .. "ItemFaction" .. weap] = weapon.Faction;
						weap = weap + 1;
					end

					if weapons3 ~= nil then
						local weapon = weapons3[CF.WeightedSelection(weights3)];
						gameState["Player" .. participant .. "Preset" .. preset .. "Item" .. weap] = weapon.Item;
						gameState["Player" .. participant .. "Preset" .. preset .. "ItemFaction" .. weap] = weapon.Faction;
						weap = weap + 1;
					end
				end
			end
		end
	end
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
-- Make item of specified faction and index
-----------------------------------------------------------------------
function CF.MakeItemAtIndex(faction, index)
	return CF.MakeItem(CF.ItmClasses[faction][index], CF.ItmPresets[faction][index], CF.ItmModules[faction][index]);
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
			actor:SetNumberValue("VW_Prestige", tonumber(prestige));
		end

		if name and name ~= "" then
			actor:SetStringValue("VW_Name", name);
		end

		if xp then
			actor:SetNumberValue("VW_XP", xp);
			local rank = CF.GetRankFromXP(xp);
			actor:SetNumberValue("VW_Rank", rank);
			local prestige = actor:GetNumberValue("VW_Prestige");
			CF.BuffActor(actor, 1 + (rank + math.sqrt(prestige)) * 0.1 * math.sqrt(prestige * 0.1 + 1));
		end
	end

	return actor;
end
-----------------------------------------------------------------------
-- Make actor of specified faction and index
-----------------------------------------------------------------------
function CF.MakeActorAtIndex(faction, index)
	return CF.MakeActor(CF.ActClasses[faction][index], CF.ActPresets[faction][index], CF.ActModules[faction][index]);
end
-----------------------------------------------------------------------
-- Create a generic text effect
-----------------------------------------------------------------------
function CF.CreateTextEffect(text)
	local effect = CreateMOPixel("Text Effect", "VoidWanderers.rte");
	
	effect:SetStringValue("VW_Text", text);

	significance = math.max(0.001, math.sqrt(FrameMan:CalculateTextWidth(text, false)));

	effect.Lifetime = effect.Lifetime * significance;
	effect.Vel = Vector(0, -2) / significance;

	return effect;
end
-----------------------------------------------------------------------
-- Checks if a <preset> from <module> of type <class> has already been unlocked with a <kind>.
-----------------------------------------------------------------------
function CF.IsEntityUnlocked(gameState, kind, class, preset, module)
	return (not not gameState["Unlocked" .. kind .. "_" .. class .. "_" .. preset .. "_" .. module]);
end
-----------------------------------------------------------------------
-- Sets if a <preset> from <module> of type <class> has already been unlocked with a <kind>.
-----------------------------------------------------------------------
function CF.SetEntityUnlocked(gameState, kind, class, preset, module, unlocked)
	gameState["Unlocked" .. kind .. "_" .. class .. "_" .. preset .. "_" .. module] = unlocked;
end
-----------------------------------------------------------------------
-- Creates a blueprint for given <faction>.
-- Returns the blueprint, and whether an unlock could be found.
-----------------------------------------------------------------------
function CF.CreateBluePrint(gameState, faction)
	local blueprint = CreateHeldDevice("Blueprint", CF.ModuleName);

	-- Spec ops carries their own data, or your data, or someone's data, anyhow
	local participant = faction or math.random(tonumber(gameState["ActiveCPUs"]));
	local factionName = gameState["Player" .. participant .. "Faction"];
	local unlock = nil;

	-- If we've got a faction, look for items or actors.
	-- If the data owner has a strong enough opinion of us we can have anything.
	-- In the other case, pick something, doesn't have to be valid.
	if factionName ~= nil then
		-- What we're pulling from, and what we're pulling from it.
		local itemList;
		local contentIndex;

		local classes, presets, modules;
		local faction = CF.GetPlayerFaction(gameState, participant)
		-- Look for actors sometimes, but usually just items.
		if math.random() < 0.25 then
			itemList = CF.MakeListOfMostPowerfulActors(faction, CF.ActorTypes.ANY, math.abs(tonumber(gameState["Player" .. participant .. "Reputation"])));
			contentIndex = "Actor";

			classes = CF.ActClasses[factionName];
			presets = CF.ActPresets[factionName];
			modules = CF.ActModules[factionName];
		else
			itemList = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.ANY, math.abs(tonumber(gameState["Player" .. participant .. "Reputation"])));
			contentIndex = "Item";

			classes = CF.ItmClasses[factionName];
			presets = CF.ItmPresets[factionName];
			modules = CF.ItmModules[factionName];
		end
					
		-- Check the item list.
		-- TODO: Do not excuse leaving out class information in public release.
		if itemList ~= nil then
			for _, potentialUnlock in pairs(itemList) do
				local objectClass = classes[potentialUnlock[contentIndex]] or (contentIndex == "Item" and "HDFirearm" or "AHuman");
				local objectPreset = presets[potentialUnlock[contentIndex]];
				local objectModule = modules[potentialUnlock[contentIndex]];
				
				if objectPreset and objectModule ~= "Base.rte" and not CF.IsEntityUnlocked(gameState, "Blueprint", objectClass, objectPreset, objectModule) then
					unlock = { objectClass, objectPreset, objectModule };
					break;
				end
			end
		end

		-- Do a random pull as backup.
		if unlock == nil then
			local index = math.random(#presets);
			local objectClass = classes[index];
			local objectPreset = presets[index];
			local objectModule = modules[index];
			unlock = { objectClass, objectPreset, objectModule };
		end
	end
				
	if unlock ~= nil then
		blueprint:SetStringValue("VW_Text", unlock[2] .. " blueprint unlocked!\\nThe Trade Star will update their catalog shortly.");
		blueprint:SetStringValue("VW_ClassUnlock", unlock[1]);
		blueprint:SetStringValue("VW_PresetUnlock", unlock[2]);
		blueprint:SetStringValue("VW_ModuleUnlock", unlock[3]);
	end
	
	return blueprint;
end
-----------------------------------------------------------------------
-- Creates a blackprint.
-- Returns the blackprint, and whether an unlock was found.
-----------------------------------------------------------------------
function CF.CreateBlackPrint(gameState)
	local blackprint = CreateHeldDevice("Blueprint", CF.ModuleName);
	
	local unlock = nil;
	local classes, presets, modules;

	if math.random() < 0.25 then
		classes = CF.ArtActClasses;
		presets = CF.ArtActPresets;
		modules = CF.ArtActModules;
	else
		classes = CF.ArtItmClasses;
		presets = CF.ArtItmPresets;
		modules = CF.ArtItmModules;
	end

	local index = math.random(#presets);
	local objectClass = classes[index];
	local objectPreset = presets[index];
	local objectModule = modules[index];

	unlock = { objectClass, objectPreset, objectModule };
				
	if unlock ~= nil then
		blackprint:SetStringValue("VW_Text", unlock[2] .. " blackprint unlocked!\nThe Black Market will update their catalog shortly.");
		blackprint:SetStringValue("VW_ClassUnlock", unlock[1]);
		blackprint:SetStringValue("VW_PresetUnlock", unlock[2]);
		blackprint:SetStringValue("VW_ModuleUnlock", unlock[3]);
	end
	
	return blackprint;
end
-----------------------------------------------------------------------
-- Makes a unit of specified preset for participant faction specified using given gameState
-----------------------------------------------------------------------
function CF.MakeUnitWithPreset(gameState, participant, preset)
	local actor = nil;
	local offset = Vector();
	local weapon = nil;

	participant = participant or error("No faction of origin specified in CF.MakeUnitWithPreset.", 2);
	preset = preset or error("No preset specified in CF.MakeUnitWithPreset.", 2);

	local a = tonumber(gameState["Player" .. participant .. "Preset" .. preset .. "Actor"])
	if a ~= nil then
		local f = gameState["Player" .. participant .. "Preset" .. preset .. "Faction"]
		local reputation = gameState["Player" .. participant .. "Reputation"]
		local setRank = 0
		if reputation then
			reputation = math.abs(tonumber(reputation))
			setRank = math.min(
				math.random(0, math.floor(#CF.Ranks * reputation / (#CF.Ranks * CF.ReputationPerDifficulty))),
				#CF.Ranks
			)
		end

		actor = CF.MakeActor(CF.ActClasses[f][a], CF.ActPresets[f][a], CF.ActModules[f][a], CF.Ranks[setRank])

		if CF.ActOffsets[f][a] then
			offset = CF.ActOffsets[f][a]
		end

		if actor then
			-- Give weapons to human actors
			if actor.ClassName == "AHuman" then
				if setRank ~= 0 then
					if actor.ModuleID < 10 and math.random() + 0.5 < setRank / #CF.Ranks then
						CF.RandomizeLimbs(actor)
					end
				end
				for i = 1, math.ceil(CF.MaxItemsPerPreset * RangeRand(0.5, 1.0)) do
					if gameState["Player" .. participant .. "Preset" .. preset .. "Item" .. i] ~= nil then
						local w = tonumber(gameState["Player" .. participant .. "Preset" .. preset .. "Item" .. i])
						local wf = gameState["Player" .. participant .. "Preset" .. preset .. "ItemFaction" .. i]

						weapon = CF.MakeItem(CF.ItmClasses[wf][w], CF.ItmPresets[wf][w], CF.ItmModules[wf][w])

						if weapon ~= nil then
							actor:AddInventoryItem(weapon)
						end
					end
				end
				if math.random() < 0.5 / (1 + actor.InventorySize) then
					actor:AddInventoryItem(CreateHDFirearm("Medikit", "Base.rte"))
				end
			end
			-- Set default AI mode
			actor.AIMode = Actor.AIMODE_SENTRY
		end
	else
		error("No preset " .. preset .. " for specified faction " .. participant .. " in CF.MakeUnitWithPreset", 2);
	end

	actor = actor or error("No actor produced in CF.MakeUnitWithPreset", 2);
	return actor, offset
end
-----------------------------------------------------------------------
-- Creates a unit of any variety from the participant faction specified
-----------------------------------------------------------------------
function CF.MakeUnit(gameState, participant)
	local preset = math.random(CF.PresetTypes.ENGINEER);
	return CF.MakeUnitWithPreset(gameState, participant, preset);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.ReadPtsData(sceneName, sceneConfig)
	local points = {}

	for i = 1, CF.GenericMissionCount do
		points[CF.Mission[i]] = {}
	end

	for i = 1, #CF.LocationMissions[sceneName] do
		points[CF.LocationMissions[sceneName][i]] = {}
	end

	-- Load level data
	for k1, v1 in pairs(points) do
		local msntype = k1

		--print (msntype)

		for k2 = 1, CF.MissionMaxSets[msntype] do -- Enum sets
			local setnum = k2

			--print ("  "..setnum)

			for k3 = 1, #CF.MissionRequiredData[msntype] do -- Enum Point types
				local pttype = CF.MissionRequiredData[msntype][k3].Name

				--print ("    "..pttype)

				--print (k3)
				--print (msntype)
				--print (pttype)

				for k4 = 1, CF.MissionRequiredData[msntype][k3].Max do -- Enum points
					local id = msntype .. tostring(setnum) .. pttype .. tostring(k4)

					local x = sceneConfig[id .. "X"]
					local y = sceneConfig[id .. "Y"]

					if x ~= nil and y ~= nil then
						if points[msntype] == nil then
							points[msntype] = {}
						end
						if points[msntype][setnum] == nil then
							points[msntype][setnum] = {}
						end
						if points[msntype][setnum][pttype] == nil then
							points[msntype][setnum][pttype] = {}
						end
						if points[msntype][setnum][pttype][k4] == nil then
							points[msntype][setnum][pttype][k4] = {}
						end

						points[msntype][setnum][pttype][k4] = Vector(tonumber(x), tonumber(y))
					end
				end
			end
		end
	end

	return points
end
-----------------------------------------------------------------------
--	Returns available points set for specified mission from points array
-----------------------------------------------------------------------
function CF.GetRandomMissionPointsSet(points, missionType)
	local sets = {}

	for k, v in pairs(points[missionType]) do
		sets[#sets + 1] = k
	end
	-- TODO: Sometimes only first set works, fix this!
	local set = sets[math.random(#sets)] or sets[1]

	return set
end
-----------------------------------------------------------------------
--	Returns int indexed array of vectors with available points of specified
--	mission type, points set and points type
-----------------------------------------------------------------------
function CF.GetPointsArray(points, missionType, setIndex, pointsType)
	local vectors = {};

	--print (missionType)
	--print (setIndex)
	--print (pointsType)

	if
		points[missionType]
	and points[missionType][setIndex]
	and points[missionType][setIndex][pointsType]
	then
		for k, v in pairs(points[missionType][setIndex][pointsType]) do
			vectors[#vectors + 1] = v
		end
	else
		print('Mission points "' .. tostring(missionType) .. ", " .. tostring(setIndex) .. ", " .. tostring(pointsType) .. '" not found.')
	end

	return vectors
end
-----------------------------------------------------------------------
--	Returns array of n random elements from array list
-----------------------------------------------------------------------
function CF.RandomSampleOfList(list, n)
	local selection = {};

	-- If empty set or no elements requested, return empty selection
	-- If need real number, properly grab a handful
	if #list > 0 and n > 0 then
		-- Make a list of indices not once picked
		local remainder = {};

		for i = 1, #list do
			table.insert(remainder, i);
		end

		-- For as many as requested, or as many indices as there are, whichever is smaller, grab of remaining options
		for i = 1, math.min(#list, n) do
			local index = math.random(#remainder);
			table.insert(selection, list[remainder[index]]);
			table.remove(remainder, index);
		end

		-- And if we need even more, pick randomly from there
		if #list < n then
			for i = 1, n - #list do
				table.insert(selection, list[math.random(#list)]);
			end
		end
	end

	return selection;
end
-----------------------------------------------------------------------
-- Returns a weighted selection out of a list of values
-----------------------------------------------------------------------
function CF.WeightedSelection(list)
	if list or error("No list passed to CF.WeightedSelection", 2) then
		local candidates = {};
		local sum = 0;

		for i = 1, #list do
			sum = sum + list[i];
			table.insert(candidates, sum);
		end

		local pick = math.random() * sum;

		for i = 1, #candidates do
			if pick <= candidates[i] then
				return i;
			end
		end
	end
	
	return nil;
end
-----------------------------------------------------------------------
-- Obtains the worst enemy of the player
-----------------------------------------------------------------------
function CF.GetAngriestPlayer(gameState)
	local angriest;
	local reputation = 0;

	for i = 1, CF.MaxCPUPlayers do
		if gameState["Player" .. i .. "Active"] == "True" then
			if tonumber(gameState["Player" .. i .. "Reputation"]) < reputation then
				angriest = i;
				reputation = tonumber(gameState["Player" .. i .. "Reputation"]);
			end
		end
	end

	return angriest, reputation;
end
-----------------------------------------------------------------------
-- Obtains the best friend of the player
-----------------------------------------------------------------------
function CF.GetFriendliestPlayer(gameState)
	local friendliest;
	local reputation = 0;

	for i = 1, CF.MaxCPUPlayers do
		if gameState["Player" .. i .. "Active"] == "True" then
			if tonumber(gameState["Player" .. i .. "Reputation"]) > reputation then
				friendliest = i;
				reputation = tonumber(gameState["Player" .. i .. "Reputation"]);
			end
		end
	end

	return friendliest, reputation;
end
-----------------------------------------------------------------------
-- Gets the current security at a location
-----------------------------------------------------------------------
function CF.GetLocationSecurity(gameState, location)
	local securityLevel = 0;

	if location then
		if gameState["Security_" .. location] ~= nil then
			securityLevel = tonumber(gameState["Security_" .. location]);
		else
			securityLevel = CF.LocationSecurity[location];
		end
	end

	return securityLevel;
end
-----------------------------------------------------------------------
-- Sets the security of a location
-----------------------------------------------------------------------
function CF.SetLocationSecurity(gameState, location, securityLevel)
	gameState["Security_" .. location] = securityLevel;
end
-----------------------------------------------------------------------
-- Change the security of a location
-----------------------------------------------------------------------
function CF.ChangeLocationSecurity(gameState, location, increment)
	CF.SetLocationSecurity(gameState, location, CF.GetLocationSecurity(gameState, location) + increment);
end
-----------------------------------------------------------------------
-- Puts a difficulty within the normal integer range (should be 1-6)
-----------------------------------------------------------------------
function CF.NormalizeDifficulty(difficulty)
	return math.floor(math.min(CF.MaxDifficulty, math.max(1, difficulty)));
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function CF.GetFullMissionDifficulty(gameState, location, missionID)
	local locationDifficulty = CF.GetLocationSecurity(gameState, location) / 10;
	local missionDifficulty = tonumber(gameState["Mission" .. missionID .. "Difficulty"]);
	return CF.NormalizeDifficulty(locationDifficulty + missionDifficulty - 1);
end
-----------------------------------------------------------------------
-- Generate a random mission with ally/enemy/location overrides
-----------------------------------------------------------------------
function CF.GenerateRandomMission(gameState, ally, enemy, prohibitedLocations)
	local cpus = tonumber(gameState["ActiveCPUs"]);

	if not prohibitedLocations then
		prohibitedLocations = {};
	end

	-- Determine for whom we're working
	local contractor = ally;

	if not contractor then
		-- Build list of potential contractors' cumulative weights
		local candidateContractors = {};
		local sum = 0;

		for id = 1, cpus do
			local rep = tonumber(gameState["Player" .. id .. "Reputation"]);
			local weight = 1 / math.max(1, 1 - rep / 1000);
			sum = sum + weight;
			table.insert(candidateContractors, {sum, id});
		end

		local pick = math.random() * sum;

		for id = 1, #candidateContractors do
			if pick <= candidateContractors[id][1] then
				contractor = candidateContractors[id][2];
				break;
			end
		end
	end
	
	-- Determine for whom the bell tolls
	local target = enemy;

	if not target then
		-- Build list of potential targets' cumulative weights
		local candidateTargets = {};
		local sum = 0;

		for id = 1, cpus do
			if id ~= contractor then
				local rep = tonumber(gameState["Player" .. id .. "Reputation"]);
				local weight = 1 / math.max(1, 1 + rep / 1000);
				sum = sum + weight;
				table.insert(candidateTargets, {sum, id});
			end
		end

		local pick = math.random() * sum;

		for id = 1, #candidateTargets do
			if pick <= candidateTargets[id][1] then
				target = candidateTargets[id][2];
				break;
			end
		end
	end

	-- Make list of valid mission types and where they can occur
	local reputation = tonumber(gameState["Player" .. contractor .. "Reputation"]);
	local illReputation = tonumber(gameState["Player" .. target .. "Reputation"]);
	local validMissionTypes = {};

	for _, missionType in pairs(CF.Mission) do
		if CF.MissionMinReputation[missionType] <= reputation then
			local missionTypeCandidate = {};
			missionTypeCandidate.MissionID = missionType;
			missionTypeCandidate.Scenes = {};

			for _, locationName in pairs(CF.Location) do
				local locationProhibited = false;

				for _, prohibitedLocation in pairs(prohibitedLocations) do
					if locationName == prohibitedLocation then
						locationProhibited = true;
						break;
					end
				end

				if
					not locationProhibited
					and CF.LocationPlayable[locationName] ~= false
					and gameState.Location ~= locationName
					and not CF.IsLocationHasAttribute(locationName, CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE)
				then
					for _, allowedType in pairs(CF.LocationMissions[locationName]) do
						if missionType == allowedType then
							table.insert(missionTypeCandidate.Scenes, locationName);
							break;
						end
					end
				end
			end

			if #missionTypeCandidate.Scenes > 0 then
				table.insert(validMissionTypes, missionTypeCandidate);
			end
		end
	end

	-- Pick some random mission type
	local randomMissionType = validMissionTypes[math.random(#validMissionTypes)];

	-- Pick scene
	local typeScenes = randomMissionType.Scenes;
	local randomMissionScene = typeScenes[math.random(#typeScenes)];

	-- Return mission
	local mission = {};
	mission.SourcePlayer = contractor;
	mission.TargetPlayer = target;
	mission.Type = randomMissionType.MissionID;
	mission.Location = randomMissionScene;
	mission.Difficulty = tonumber(gameState["MissionDifficultyBonus"]) + math.random(-1, 1) + math.max(math.abs(reputation), math.abs(illReputation)) / CF.ReputationPerDifficulty;

	return mission;
end
-----------------------------------------------------------------------
-- Generate a new set of missions
-----------------------------------------------------------------------
function CF.GenerateRandomMissions(gameState)
	local missions = {};
	local maxMissions = math.max(CF.MaxMissions, math.floor(tonumber(gameState["ActiveCPUs"]) / 4));
	local usedLocations = {};

	for i = 1, maxMissions do
		missions[i] = CF.GenerateRandomMission(gameState, nil, nil, usedLocations);
		table.insert(usedLocations, missions[i].Location);
	end

	-- Put missions to gameState
	for i = 1, #missions do
		gameState["Mission" .. i .. "SourcePlayer"] = missions[i].SourcePlayer;
		gameState["Mission" .. i .. "TargetPlayer"] = missions[i].TargetPlayer;
		gameState["Mission" .. i .. "Type"] = missions[i].Type;
		gameState["Mission" .. i .. "Location"] = missions[i].Location;
		gameState["Mission" .. i .. "Difficulty"] = missions[i].Difficulty;
	end
end
-----------------------------------------------------------------------
-- Sets whether an actor is an NPC on the player's team
-----------------------------------------------------------------------
function CF.SetAlly(actor, yes)
	if yes then
		actor:SetNumberValue("VW_Ally", 1);
		actor.PlayerControllable = false;
		actor.CanRevealUnseen = false;

		if actor:HasScript("Mods/VoidWanderers.rte/Actors/Shared/Conscript.lua") then
			actor:EnableScript("Mods/VoidWanderers.rte/Actors/Shared/Conscript.lua");
		else
			actor:AddScript("Mods/VoidWanderers.rte/Actors/Shared/Conscript.lua");
		end
	else
		actor:RemoveNumberValue("VW_Ally");
		actor.PlayerControllable = true;
		actor.CanRevealUnseen = true;
		actor:FlashWhite(50);

		actor:DisableScript("Mods/VoidWanderers.rte/Actors/Shared/Conscript.lua");
	end
end
-----------------------------------------------------------------------
-- Whether an actor is an NPC on the player's team
-----------------------------------------------------------------------
function CF.IsAlly(actor)
	return actor:NumberValueExists("VW_Ally");
end
-----------------------------------------------------------------------
-- Whether an actor is a VW brain for anyone
-----------------------------------------------------------------------
function CF.IsBrain(actor)
	return (MovableMan:ValidMO(actor) or error("Bad reference or nil value passed to CF::IsBrain!", 2))
		and (actor.PresetName == "Brain Case" or actor:HasScript("VoidWanderers.rte/Actors/Shared/Brain.lua"));
end
-----------------------------------------------------------------------
-- Whether an actor is the brain or otherwise prestigious
-----------------------------------------------------------------------
function CF.IsCommander(actor)
	return (CF.IsBrain(actor) or actor:GetNumberValue("VW_Prestige") ~= 0);
end
-----------------------------------------------------------------------
-- Whether an actor is a generic player usable unit
-----------------------------------------------------------------------
function CF.IsPlayerUnit(actor)
	return (IsAHuman(actor) or IsACrab(actor))
		and actor.Team == CF.PlayerTeam
		and not (CF.IsBrain(actor) or CF.IsAlly(actor));
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
