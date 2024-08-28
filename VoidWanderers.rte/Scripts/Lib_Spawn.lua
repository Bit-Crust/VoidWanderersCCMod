-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.MakeRPGBrain = function(c, p, team, pos, level, giveweapons)
	if giveweapons == nil then
		giveweapons = true
	end

	local f = CF.GetPlayerFaction(c, p)
	local brain = CF.MakeBrain(
		c,
		p,
		team,
		pos,
		true
	)

	if brain then
		-- Generate a skill set, randomly distribute available points
		local skillset = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		local availableSkills = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
		print(level * 10)
		for i = 1, level * 10 do
			local index = math.random(#availableSkills)
			if skillset[availableSkills[index]] < 5 then
				skillset[availableSkills[index]] = skillset[availableSkills[index]] + 1
				if skillset[availableSkills[index]] == 5 then
					table.remove(availableSkills, index)
				end
			end
			if #availableSkills == 0 then
				break
			end
		end
		
		-- Actually assign the skills
		brain:SetNumberValue("VW_PreassignedSkills", 1)
		local i = 1
		brain:SetNumberValue("VW_ToughSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_ShieldSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_TelekenesisSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_HealthSkill", math.min(skillset[i] * 20 + math.random(20), 100))
		i = i + 1
		brain:SetNumberValue("VW_RepairSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_HealSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_SelfHealSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_ScannerSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_SplitterSkill", skillset[i])
		i = i + 1
		brain:SetNumberValue("VW_QuantumSkill", skillset[i])
		
		-- Make the brain put it's skills to work, and give it the correct pie slice for consistency
		brain:AddScript("VoidWanderers.rte/Scripts/Brain.lua")
		brain:EnableScript("VoidWanderers.rte/Scripts/Brain.lua")
		brain.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil)
	end

	return brain
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.MakeBrain = function(c, p, team, pos, giveWeapons)
	--print ("CF.MakeBrain")
	local f = CF.GetPlayerFaction(c, p)
	return CF.MakeBrainWithPreset(c, p, team, pos, CF.Brains[f], CF.BrainClasses[f], CF.BrainModules[f], giveWeapons)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.MakeBrainWithPreset = function(c, p, team, pos, preset, class, module, giveWeapons)
	--print ("CF.MakeBrainWithPreset")

	local f = CF.GetPlayerFaction(c, p)

	local actor = CF.MakeActor(preset, class, module)

	if actor ~= nil then
		if giveWeapons then
			local weapon = nil
			local weaponsgiven = 0
			-- Create list of prefered weapons for brains
			local list = CF.PreferedBrainInventory[f] or { CF.WeaponTypes.RIFLE, CF.WeaponTypes.DIGGER }
			for i = 1, #list do
				local weaps
				-- Try to give brain most powerful prefered weapon
				weaps = CF.MakeListOfMostPowerfulWeapons(c, p, list[i], 100000)

				if weaps ~= nil then
					local wf = weaps[1]["Faction"]
					weapon = CF.MakeItem(
						CF.ItmPresets[wf][weaps[1]["Item"]],
						CF.ItmClasses[wf][weaps[1]["Item"]],
						CF.ItmModules[wf][weaps[1]["Item"]]
					)
					if weapon ~= nil then
						actor:AddInventoryItem(weapon)

						if list[i] ~= CF.WeaponTypes.DIGGER and list[i] ~= CF.WeaponTypes.TOOL then
							weaponsgiven = weaponsgiven + 1
						end
					end
				end
			end

			if weaponsgiven == 0 then
				-- If we didn't get any weapins try to give other weapons, rifles
				if weaps == nil then
					weaps = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.RIFLE, 100000)
				end

				-- Sniper rifles
				if weaps == nil then
					weaps = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.SNIPER, 100000)
				end

				-- No luck - heavies then
				if weaps == nil then
					weaps = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.HEAVY, 100000)
				end

				-- No luck - pistols then
				if weaps == nil then
					weaps = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.PISTOL, 100000)
				end

				if weaps ~= nil then
					local wf = weaps[1]["Faction"]
					weapon = CF.MakeItem(
						CF.ItmPresets[wf][weaps[1]["Item"]],
						CF.ItmClasses[wf][weaps[1]["Item"]],
						CF.ItmModules[wf][weaps[1]["Item"]]
					)
					if weapon ~= nil then
						actor:AddInventoryItem(weapon)
					end
				end
			end
		end
		actor.Pos = pos

		-- Set default AI mode
		actor.AIMode = Actor.AIMODE_SENTRY
		actor.Team = team
	end

	return actor
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.SpawnAIUnitWithPreset = function(c, p, team, pos, aimode, pre)
	local act = CF.MakeUnitFromPreset(c, p, pre)

	if act ~= nil then
		act.Team = team
		if pos ~= nil then
			act.Pos = pos
		end

		if aimode ~= nil then
			act.AIMode = aimode
		end
	end

	return act
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF.SpawnAIUnit = function(c, p, team, pos, aimode)
	local pre = math.random(CF.PresetTypes.ENGINEER) --The last two presets are ENGINEER and DEFENDER
	local act = CF.MakeUnitFromPreset(c, p, pre)

	if act ~= nil then
		act.Team = team
		if pos ~= nil then
			act.Pos = pos
		end

		if aimode ~= nil then
			act.AIMode = aimode
		else
			act.AIMode = math.random() < 0.5 and Actor.AIMODE_BRAINHUNT or Actor.AIMODE_PATROL
		end
	end

	return act
end
-----------------------------------------------------------------------------------------
--	Spawns some random infantry of specified faction, tries to spawn AHuman
-----------------------------------------------------------------------------------------
CF.SpawnRandomInfantry = function(team, pos, faction, aimode)
	local actor = nil
	local weapon = nil
	local actorCandidateName = nil
	local weaponCandidateName = nil

	-- Emergency counter in case we don't have AHumans in factions
	local counter = 0
	while true do
		actorCandidateName = #CF.ActNames[faction] > 0 and math.random(#CF.ActNames[faction]) or 0

		if
			(CF.ActClasses[faction][actorCandidateName] == nil
			or CF.ActClasses[faction][actorCandidateName] == "AHuman")
			and CF.ActTypes[faction][actorCandidateName] ~= CF.ActorTypes.ARMOR
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
		CF.ActPresets[faction][actorCandidateName], 
		CF.ActClasses[faction][actorCandidateName], 
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
			CF.ItmPresets[faction][weaponCandidateName], 
			CF.ItmClasses[faction][weaponCandidateName], 
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
		return actor
	else
		return actor
	end

	return nil
end
-----------------------------------------------------------------------------------------
-- Create list of actors in faction of certain class.
-----------------------------------------------------------------------------------------
CF.MakeListOfMostPowerfulActorsOfClass = function(config, player, actorType, actorClass, maxTech)
	local acts = CF.MakeListOfMostPowerfulActors(config, player, actorType, maxTech)
	local f = CF.GetPlayerFaction(config, player)

	if acts then
		-- Filter only humans
		local tempActs = {}

		for i = 1, #acts do
			local ind = acts[i]["Actor"]

			if CF.ActClasses[f][ind] == actorClass then
				table.insert(tempActs, acts[i])
			end
		end

		if #tempActs == 0 then
			acts = nil
		else
			acts = tempActs
		end
	end

	return acts
end
-----------------------------------------------------------------------------------------
-- Create list of weapons of wtype sorted by their power.
-----------------------------------------------------------------------------------------
CF.MakeListOfMostPowerfulWeapons = function(config, player, weaponType, maxTech)
	local weaps = {}
	local f = CF.GetPlayerFaction(config, player)
	-- Filter needed items
	for i = 1, #CF.ItmNames[f] do
		if
			CF.ItmPowers[f][i] > 0
			and CF.ItmUnlockData[f][i] <= maxTech
			and (CF.WeaponTypes.ANY == weaponType or CF.ItmTypes[f][i] == weaponType)
		then
			local n = #weaps + 1
			weaps[n] = {}
			weaps[n]["Item"] = i
			weaps[n]["Faction"] = f
			weaps[n]["Power"] = CF.ItmPowers[f][i]
		end
	end
	-- Sort them
	for j = 1, #weaps - 1 do
		for i = 1, #weaps - j do
			if weaps[i]["Power"] < weaps[i + 1]["Power"] then
				local temp = weaps[i]
				weaps[i] = weaps[i + 1]
				weaps[i + 1] = temp
			end
		end
	end
	if #weaps == 0 then
		weaps = nil
	end
	return weaps
end
-----------------------------------------------------------------------------------------
-- Create list of actors of a type sorted by their power.
-----------------------------------------------------------------------------------------
CF.MakeListOfMostPowerfulActors = function(config, player, actorType, maxTech)
	local acts = {}
	local f = CF.GetPlayerFaction(config, player)
	-- Filter needed items
	for i = 1, #CF.ActNames[f] do
		if
			CF.ActPowers[f][i] > 0
			and CF.ActUnlockData[f][i] <= maxTech
			and (CF.ActorTypes.ANY == actorType or CF.ActTypes[f][i] == actorType)
		then
			local n = #acts + 1
			acts[n] = {}
			acts[n]["Actor"] = i
			acts[n]["Faction"] = f
			acts[n]["Power"] = CF.ActPowers[f][i]
		end
	end
	-- Sort them
	for j = 1, #acts - 1 do
		for i = 1, #acts - j do
			if acts[i]["Power"] < acts[i + 1]["Power"] then
				local temp = acts[i]
				acts[i] = acts[i + 1]
				acts[i + 1] = temp
			end
		end
	end
	if #acts == 0 then
		acts = nil
	end
	return acts
end
-----------------------------------------------------------------------------------------
--	Creates units presets for specified AI where c - config, p - player, tech - max unlock data
-----------------------------------------------------------------------------------------
CF.CreateAIUnitPresets = function(c, p, tech)
	--[[ Each ideal list refers to the ideal type of given item for the corresponding preset.
	IE idealActors[5] is the first heavy unit variant's ideal unit type
	while idealWeapons[9] is digger type for the engineer, preset 9
	I wish I could make these constant, but declaring them outside the function kills it
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
	]]
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
	}
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
	}
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
	}
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
	}

	local f = CF.GetPlayerFaction(c, p)
	if CF.PreEquippedActors[f] == true then
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
				local actors = CF.MakeListOfMostPowerfulActors(c, p, actorType, tech)

				if actors ~= nil then
					for _, actor in ipairs(actors) do
						if CF.EquipmentTypes[f][actor["Actor"]] == idealPresetWeaponTypes[presetType] then
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
				c["Player" .. p .. "Preset" .. presetType .. "Actor"] = match["Actor"]
				c["Player" .. p .. "Preset" .. presetType .. "Faction"] = match["Faction"]

				--Reset all weapons
				for j = 1, CF.MaxItemsPerPreset do
					c["Player" .. p .. "Preset" .. presetType .. "Item" .. j] = nil
					c["Player" .. p .. "Preset" .. presetType .. "ItemFaction" .. j] = nil
				end

				-- If we didn't find a suitable engineer unit then try give digger to engineer preset
				if idealPresetWeaponTypes[presetType] == CF.WeaponTypes.DIGGER and presetType == CF.PresetTypes.ENGINEER then
					local weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.DIGGER, tech)

					if weapons1 ~= nil then
						c["Player" .. p .. "Preset" .. presetType .. "Item" .. 1] = weapons1[1]["Item"]
						c["Player" .. p .. "Preset" .. presetType .. "ItemFaction" .. 1] = weapons1[1]["Faction"]
					end
				end
			end
		end
	else
		-- Fill presets for generic faction
		for i = 1, 10 do
			local actors
			actors = CF.MakeListOfMostPowerfulActors(c, p, idealPresetActorTypes[i], tech)

			if actors == nil then
				actors = CF.MakeListOfMostPowerfulActors(c, p, CF.ActorTypes.LIGHT, tech)
			end
			if actors == nil then
				actors = CF.MakeListOfMostPowerfulActors(c, p, CF.ActorTypes.HEAVY, tech)
			end
			if actors == nil then
				actors = CF.MakeListOfMostPowerfulActors(c, p, CF.ActorTypes.ARMOR, tech)
			end

			local weapons1
			weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, idealPresetWeaponTypes[i], tech)

			if weapons1 == nil then
				weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.RIFLE, tech)
			end
			if weapons1 == nil then
				weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.SHOTGUN, tech)
			end
			if weapons1 == nil then
				weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.SNIPER, tech)
			end
			if weapons1 == nil then
				weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.HEAVY, tech)
			end
			if weapons1 == nil then
				weapons1 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.PISTOL, tech)
			end

			local weapons2
			weapons2 = CF.MakeListOfMostPowerfulWeapons(c, p, idealPresetSecondaryTypes[i], tech)

			if weapons2 == nil then
				weapons2 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.PISTOL, tech)
			end
			if weapons2 == nil then
				weapons2 = CF.MakeListOfMostPowerfulWeapons(c, p, CF.WeaponTypes.DIGGER, tech)
			end

			local weapons3
			weapons3 = CF.MakeListOfMostPowerfulWeapons(c, p, idealPresetTertiaryTypes[i], tech)

			if actors ~= nil then
				c["Player" .. p .. "Preset" .. i .. "Actor"] = actors[1]["Actor"]
				c["Player" .. p .. "Preset" .. i .. "Faction"] = actors[1]["Faction"]

				local class = CF.ActClasses[actors[1]["Faction"]][actors[1]["Actor"]]

				-- Don't give weapons to ACrabs
				if class ~= "ACrab" then
					local weap = 1

					if weapons1 ~= nil then
						-- Add small random spread for primary weapons
						local spread = math.min(#weapons1, 2)

						local w = math.random(spread)
						--print ("Selected weapon: "..w)

						c["Player" .. p .. "Preset" .. i .. "Item" .. weap] = weapons1[w]["Item"]
						c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. weap] = weapons1[w]["Faction"]
						weap = weap + 1
					end

					if weapons2 ~= nil then
						-- Add small random spread for secondary weapons
						local spread = math.min(#weapons2, 2)

						local w = math.random(spread)
						--print ("Selected sec weapon: "..w)

						c["Player" .. p .. "Preset" .. i .. "Item" .. weap] = weapons2[w]["Item"]
						c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. weap] = weapons2[w]["Faction"]
						weap = weap + 1
					end

					if weapons3 ~= nil then
						-- Add small random spread for grenades
						local spread = math.min(#weapons3, 2)

						local w = math.random(spread)
						--print ("Selected tri weapon: "..w)

						c["Player" .. p .. "Preset" .. i .. "Item" .. weap] = weapons3[w]["Item"]
						c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. weap] = weapons3[w]["Faction"]
						weap = weap + 1
					end

					if CF.AIDebugOutput then
						--print ("------")
						--print(CF.ActPresets[c["Player"..p.."Preset"..i.."Faction"]][c["Player"..p.."Preset"..i.."Actor"]])
						--print(CF.ItmPresets[c["Player"..p.."Preset"..i.."ItemFaction1"]][c["Player"..p.."Preset"..i.."Item1"]])
						--print(CF.ItmPresets[c["Player"..p.."Preset"..i.."ItemFaction2"]][c["Player"..p.."Preset"..i.."Item2"]])
						--print(CF.ItmPresets[c["Player"..p.."Preset"..i.."ItemFaction3"]][c["Player"..p.."Preset"..i.."Item3"]])
					end
				end
			end
		end
	end -- If preequipped
end
-----------------------------------------------------------------------------------------
--	Create actor from preset pre, where c - config, p - player, t - territory, pay gold is pay == true
-- 	returns actor or nil, also returns actor offset, value wich you must add to default actor position to
-- 	avoid actor hang in the air, used mainly for turrets
-----------------------------------------------------------------------------------------
CF.MakeUnitFromPreset = function(c, p, pre)
	local actor = nil
	local offset = Vector()
	local weapon = nil

	local a = tonumber(c["Player" .. p .. "Preset" .. pre .. "Actor"])
	if a ~= nil then
		local f = c["Player" .. p .. "Preset" .. pre .. "Faction"]
		local reputation = c["Player" .. p .. "Reputation"]
		local setRank = 0
		if reputation then
			reputation = math.abs(tonumber(reputation))
			setRank = math.min(
				math.random(0, math.floor(#CF.Ranks * reputation / (#CF.Ranks * CF.ReputationPerDifficulty))),
				#CF.Ranks
			)
		end

		actor = CF.MakeActor(CF.ActPresets[f][a], CF.ActClasses[f][a], CF.ActModules[f][a], CF.Ranks[setRank])

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
				for i = 1, math.ceil(CF["MaxItemsPerPreset"] * RangeRand(0.5, 1.0)) do
					if c["Player" .. p .. "Preset" .. pre .. "Item" .. i] ~= nil then
						local w = tonumber(c["Player" .. p .. "Preset" .. pre .. "Item" .. i])
						local wf = c["Player" .. p .. "Preset" .. pre .. "ItemFaction" .. i]

						weapon = CF["MakeItem"](CF["ItmPresets"][wf][w], CF["ItmClasses"][wf][w], CF["ItmModules"][wf][w])

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
	end

	return actor, offset
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.ReadPtsData = function(sceneName, sceneConfig)
	-- 
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
				local pttype = CF.MissionRequiredData[msntype][k3]["Name"]

				--print ("    "..pttype)

				--print (k3)
				--print (msntype)
				--print (pttype)

				for k4 = 1, CF.MissionRequiredData[msntype][k3]["Max"] do -- Enum points
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
-----------------------------------------------------------------------------
--	Returns available points set for specified mission from points array
-----------------------------------------------------------------------------
CF.GetRandomMissionPointsSet = function(points, missionType)
	local sets = {}

	for k, v in pairs(points[missionType]) do
		sets[#sets + 1] = k
	end
	-- TODO: Sometimes only first set works, fix this!
	local set = sets[math.random(#sets)] or sets[1]

	return set
end
-----------------------------------------------------------------------------
--	Returns int indexed array of vectors with available points of specified
--	mission type, points set and points type
-----------------------------------------------------------------------------
CF.GetPointsArray = function(points, missionType, presetType, pointsType)
	local vectors = {}

	--print (missionType)
	--print (presetType)
	--print (pointsType)

	if
		points[missionType]
	and points[missionType][presetType]
	and points[missionType][presetType][pointsType]
	then
		for k, v in pairs(points[missionType][presetType][pointsType]) do
			vectors[#vectors + 1] = v
		end
	else
		print('Mission points "' .. missionType .. ", " .. presetType .. ", " .. pointsType .. '" not found.')
	end

	return vectors
end
-----------------------------------------------------------------------------
--	Returns array of n random elements from array list
-----------------------------------------------------------------------------
CF.RandomSampleOfList = function(list, n)
	local selection = {}

	-- If empty set or no elements requested, return empty selection
	-- If need real number, properly grab a handful
	if #list > 0 and n > 0 then
		-- Make a list of indices not once picked
		local remainder = {}
		for i = 1, #list do
			table.insert(remainder, i)
		end

		-- For as many as requested, or as many indices as there are, whichever is smaller, grab of remaining options
		for i = 1, math.min(#list, n) do
			local index = math.random(#remainder)
			table.insert(selection, list[remainder[index]])
			table.remove(remainder, index)
		end

		-- And if we need even more, pick randomly from there
		if #list < n then
			for i = 1, n - #list do
				local index = math.random(#list)
				table.insert(selection, list[index])
			end
		end
	end

	return selection
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.GetAngriestPlayer = function(gamestate)
	local angriest
	local reputation = 0

	for i = 1, CF.MaxCPUPlayers do
		if gamestate["Player" .. i .. "Active"] == "True" then
			if tonumber(gamestate["Player" .. i .. "Reputation"]) < reputation then
				angriest = i
				reputation = tonumber(gamestate["Player" .. i .. "Reputation"])
			end
		end
	end

	return angriest, reputation
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.GetLocationSecurity = function(gamestate, location)
	local securityLevel

	if gamestate["Security_" .. location] ~= nil then
		securityLevel = tonumber(gamestate["Security_" .. location])
	else
		securityLevel = CF.LocationSecurity[location]
	end

	return securityLevel
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.GetLocationDifficulty = function(gamestate, location)
	return math.min(CF.MaxDifficulty, math.max(1, math.floor(CF.GetLocationSecurity(gamestate, location) / 10)))
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.GetFullMissionDifficulty = function(gamestate, location, missionID)
	local locationDifficulty = CF.GetLocationDifficulty(gamestate, location)
	local missionDifficulty = tonumber(gamestate["Mission" .. missionID .. "Difficulty"])
	return math.min(CF.MaxDifficulty, math.max(1, locationDifficulty + missionDifficulty - 1))
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.SetLocationSecurity = function(gamestate, location, securityLevel)
	gamestate["Security_" .. location] = securityLevel
end
-----------------------------------------------------------------------------
-- Generate a random mission with ally/enemy/location overrides
-----------------------------------------------------------------------------
CF.GenerateRandomMission = function(gamestate, ally, enemy, prohibitedLocations)
	local cpus = tonumber(gamestate["ActiveCPUs"])

	if not prohibitedLocations then
		prohibitedLocations = {}
	end

	-- Determine for whom we're working
	local contractor = ally
	if not contractor then
		-- Build list of potential contractors' cumulative weights
		local candidateContractors = {}
		local sum = 0
		for id = 1, cpus do
			local rep = tonumber(gamestate["Player" .. id .. "Reputation"])
			local weight = 1 / math.max(1, 1 - rep / 1000)
			sum = sum + weight
			table.insert(candidateContractors, {sum, id})
		end
		local pick = math.random() * sum
		for id = 1, #candidateContractors do
			if pick <= candidateContractors[id][1] then
				contractor = candidateContractors[id][2]
				break
			end
		end
	end
	
	-- Determine for whom the bell tolls
	local target = enemy
	if not target then
		-- Build list of potential targets' cumulative weights
		local candidateTargets = {}
		local sum = 0
		for id = 1, cpus do
			if id ~= contractor then
				local rep = tonumber(gamestate["Player" .. id .. "Reputation"])
				local weight = 1 / math.max(1, 1 + rep / 1000)
				sum = sum + weight
				table.insert(candidateTargets, {sum, id})
			end
		end
		local pick = math.random() * sum
		for id = 1, #candidateTargets do
			if pick <= candidateTargets[id][1] then
				target = candidateTargets[id][2]
				break
			end
		end
	end

	-- Make list of valid mission types and where they can occur
	local reputation = tonumber(gamestate["Player" .. contractor .. "Reputation"])
	local validMissionTypes = {}
	for _, missionType in pairs(CF.Mission) do
		if CF.MissionMinReputation[missionType] <= reputation then
			local missionTypeCandidate = {}
			missionTypeCandidate["MissionID"] = missionType
			missionTypeCandidate["Scenes"] = {}

			for _, locationName in pairs(CF.Location) do
				local locationProhibited = false
				for _, prohibitedLocation in pairs(prohibitedLocations) do
					if locationName == prohibitedLocation then
						locationProhibited = true
						break
					end
				end
				if
					not locationProhibited
					and CF.LocationPlayable[locationName] ~= false
					and gamestate["Location"] ~= locationName
					and not CF.IsLocationHasAttribute(locationName, CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE)
				then
					for _, allowedType in pairs(CF.LocationMissions[locationName]) do
						if missionType == allowedType then
							table.insert(missionTypeCandidate["Scenes"], locationName)
							break
						end
					end
				end
			end

			if #missionTypeCandidate["Scenes"] > 0 then
				table.insert(validMissionTypes, missionTypeCandidate)
			end
		end
	end

	-- Pick some random mission type
	local randomMissionType = validMissionTypes[math.random(#validMissionTypes)]

	-- Return mission
	local mission = {}
	mission["SourcePlayer"] = contractor
	mission["TargetPlayer"] = target
	mission["Type"] = randomMissionType["MissionID"]
	mission["Location"] = randomMissionType["Scenes"][math.random(#randomMissionType["Scenes"])]
	mission["Difficulty"] = math.min(CF.MaxDifficulty, math.max(1, tonumber(gamestate["MissionDifficultyBonus"]) + math.random(3)))

	return mission
end
-----------------------------------------------------------------------------
-- Generate a new set of missions
-----------------------------------------------------------------------------
CF.GenerateRandomMissions = function(gamestate)
	local missions = {}
	local maxMissions = math.max(CF.MaxMissions, math.floor(tonumber(gamestate["ActiveCPUs"]) / 4))
	local usedLocations = {}

	for i = 1, maxMissions do
		missions[i] = CF.GenerateRandomMission(gamestate, nil, nil, usedLocations)
		table.insert(usedLocations, missions[i]["Location"])
	end

	-- Put missions to config
	for i = 1, #missions do
		gamestate["Mission" .. i .. "SourcePlayer"] = missions[i]["SourcePlayer"]
		gamestate["Mission" .. i .. "TargetPlayer"] = missions[i]["TargetPlayer"]
		gamestate["Mission" .. i .. "Type"] = missions[i]["Type"]
		gamestate["Mission" .. i .. "Location"] = missions[i]["Location"]
		gamestate["Mission" .. i .. "Difficulty"] = missions[i]["Difficulty"]
	end
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
