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
			else
				table.remove(availableSkills, index)
				i = i - 1
			end
			if #availableSkills == 0 then
				print("Exhausted skills, should only occur with maximum security spec ops units.")
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
	--print ("CF.SpawnRandomInfantry")
	local actor = nil
	local r1, r2
	local item

	if MovableMan:GetMOIDCount() < CF.MOIDLimit then
		-- Find AHuman
		local ok = false
		-- Emergency counter in case we don't have AHumans in factions
		local counter = 0

		while not ok do
			ok = false
			r1 = #CF.ActNames[faction] > 0 and math.random(#CF.ActNames[faction]) or 0

			if
				(CF["ActClasses"][faction][r1] == nil or CF["ActClasses"][faction][r1] == "AHuman")
				and CF["ActTypes"][faction][r1] ~= CF["ActorTypes"].ARMOR
			then
				ok = true
			end

			-- Break to avoid endless loop
			counter = counter + 1
			if counter > 20 then
				break
			end
		end

		actor = CF["MakeActor"](CF["ActPresets"][faction][r1], CF["ActClasses"][faction][r1], CF["ActModules"][faction][r1])

		if actor ~= nil then
			-- Check if this is pre-equipped faction
			local preequipped = false

			if CF["PreEquippedActors"][faction] ~= nil and CF["PreEquippedActors"][faction] then
				preequpped = true
			end

			if not preequipped then
				-- Find rifle
				local ok = false
				-- Emergency counter in case we don't have AHumans in factions
				local counter = 0

				while not ok do
					ok = false
					r2 = math.random(#CF["ItmNames"][faction])

					if
						CF["ItmTypes"][faction][r2] == CF["WeaponTypes"].RIFLE
						or CF["ItmTypes"][faction][r2] == CF["WeaponTypes"].SHOTGUN
						or CF["ItmTypes"][faction][r2] == CF["WeaponTypes"].SNIPER
					then
						ok = true
					end

					-- Break to avoid endless loop
					counter = counter + 1
					if counter > 40 then
						break
					end
				end

				item = CF["MakeItem"](CF["ItmPresets"][faction][r2], CF["ItmClasses"][faction][r2], CF["ItmModules"][faction][r2])

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
		end
	end

	return nil
end
-----------------------------------------------------------------------------------------
-- Create list of weapons of wtype sorted by their power.
-----------------------------------------------------------------------------------------
CF["MakeListOfMostPowerfulWeapons"] = function(config, player, weaponType, maxTech)
	local weaps = {}
	local f = CF["GetPlayerFaction"](config, player)
	-- Filter needed items
	for i = 1, #CF["ItmNames"][f] do
		if
			CF["ItmPowers"][f][i] > 0
			and CF["ItmUnlockData"][f][i] <= maxTech
			and (CF["WeaponTypes"].ANY == weaponType or CF["ItmTypes"][f][i] == weaponType)
		then
			local n = #weaps + 1
			weaps[n] = {}
			weaps[n]["Item"] = i
			weaps[n]["Faction"] = f
			weaps[n]["Power"] = CF["ItmPowers"][f][i]
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
	--[[ If no weapons were found, try other types?
	if #weaps == 0 then
		for i = 0, #CF["WeaponTypes"] - 1 do
			weaps = CF["MakeListOfMostPowerfulWeapons"](config, player, i, maxTech)
			if weaps then
				break
			end
		end
	end
	]]
	--
	if #weaps == 0 then
		weaps = nil
	end
	return weaps
end
-----------------------------------------------------------------------------------------
-- Create list of actors of atype sorted by their power.
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
	--[[ If no actors were found, try other types?
	if #acts == 0 then
		for i = 0, #CF.ActorTypes - 1 do
			acts = CF.MakeListOfMostPowerfulActors(config, player, i, maxTech)
			if acts then
				break
			end
		end
	end
	]]
	--
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

	if MovableMan:GetMOIDCount() < CF.MOIDLimit then
		local a = c["Player" .. p .. "Preset" .. pre .. "Actor"]
		if a ~= nil then
			a = tonumber(a)
			local f = c["Player" .. p .. "Preset" .. pre .. "Faction"]
			local reputation = c["Player" .. p .. "Reputation"]
			local setRank = 0
			if reputation then
				reputation = math.abs(tonumber(reputation))
				setRank = math.min(
					math.random(0, math.floor(#CF.Ranks * (reputation / (#CF["Ranks"] * CF["ReputationPerDifficulty"])))),
					#CF["Ranks"]
				)
			end

			actor = CF["MakeActor"](CF["ActPresets"][f][a], CF["ActClasses"][f][a], CF["ActModules"][f][a], CF["Ranks"][setRank])

			if CF["ActOffsets"][f][a] then
				offset = CF["ActOffsets"][f][a]
			end

			if actor then
				-- Give weapons to human actors
				if actor.ClassName == "AHuman" then
					if setRank ~= 0 then
						if actor.ModuleID < 10 and math.random() + 0.5 < setRank / #CF["Ranks"] then
							CF["RandomizeLimbs"](actor)
						end
					end
					if actor.Head then
						actor.Head:SetNumberValue("Carriable", 1)
						actor.Head:AddScript(CF["ModuleName"] .. "/Items/AttachOnCollision.lua")
						actor.RestThreshold = 10000
						actor.Head.RestThreshold = -1
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
	else
		print("Can't spawn unit from preset we've reached the MOID limit!! lol")
	end

	return actor, offset
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["ReadPtsData"] = function(scene, ls)
	local pts = {}

	-- Create list of data objcets
	-- Add generic mission types which must be present on any map
	for i = 1, CF["GenericMissionCount"] do
		pts[CF["Mission"][i]] = {}
	end

	for i = 1, #CF["LocationMissions"][scene] do
		pts[CF["LocationMissions"][scene][i]] = {}
	end

	-- Load level data
	for k1, v1 in pairs(pts) do
		local msntype = k1

		--print (msntype)

		for k2 = 1, CF["MissionMaxSets"][msntype] do -- Enum sets
			local setnum = k2

			--print ("  "..setnum)

			for k3 = 1, #CF["MissionRequiredData"][msntype] do -- Enum Point types
				local pttype = CF["MissionRequiredData"][msntype][k3]["Name"]

				--print ("    "..pttype)

				--print (k3)
				--print (msntype)
				--print (pttype)

				for k4 = 1, CF["MissionRequiredData"][msntype][k3]["Max"] do -- Enum points
					local id = msntype .. tostring(setnum) .. pttype .. tostring(k4)

					local x = ls[id .. "X"]
					local y = ls[id .. "Y"]

					if x ~= nil and y ~= nil then
						if pts[msntype] == nil then
							pts[msntype] = {}
						end
						if pts[msntype][setnum] == nil then
							pts[msntype][setnum] = {}
						end
						if pts[msntype][setnum][pttype] == nil then
							pts[msntype][setnum][pttype] = {}
						end
						if pts[msntype][setnum][pttype][k4] == nil then
							pts[msntype][setnum][pttype][k4] = {}
						end

						pts[msntype][setnum][pttype][k4] = Vector(tonumber(x), tonumber(y))
					end
				end
			end
		end
	end

	--print ("---")

	--[[for k,v in pairs(pts) do
		print (k)
		
		for k2,v2 in pairs(v) do
			print ("  " .. k2)
			
			for k3,v3 in pairs(v2) do
				print ("    " ..k3)
				
				for k4,v4 in pairs(v3) do
					print (k4)
					print (v4)
				end
			end
		end
	end	--]]
	--

	return pts
end
-----------------------------------------------------------------------------
--	Returns available points set for specified mission from pts array
-----------------------------------------------------------------------------
CF["GetRandomMissionPointsSet"] = function(pts, msntype)
	local sets = {}

	for k, v in pairs(pts[msntype]) do
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
CF["GetPointsArray"] = function(pts, msntype, setnum, ptstype)
	local vectors = {}

	--print (msntype)
	--print (setnum)
	--print (ptstype)

	if pts[msntype] and pts[msntype][setnum] and pts[msntype][setnum][ptstype] then
		for k, v in pairs(pts[msntype][setnum][ptstype]) do
			vectors[#vectors + 1] = v
		end
	else
		print('Mission points "' .. msntype .. ", " .. ptstype .. '" not found.')
	end

	return vectors
end
-----------------------------------------------------------------------------
--	Returns array of n random points from array pts
-----------------------------------------------------------------------------
CF["SelectRandomPoints"] = function(pts, n)
	local res = {}
	local isused = {}
	local issued = 0
	local retries

	-- If length of array = n then we don't need to find random and can simply return this array
	if #pts == n then
		return pts
	elseif #pts == 0 or n <= 0 then
		return res
	else
		-- Start selecting random values
		for i = 1, #pts do
			isused[i] = false
		end

		local retries = 0

		while issued < n do
			retries = retries + 1
			local good = false
			local r = math.random(#pts)

			if not isused[r] or retries > 50 then
				isused[r] = true
				good = true
				issued = issued + 1
				res[issued] = pts[r]
			end
		end
	end

	return res
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetAngriestPlayer"] = function(c)
	local angriest
	local rep = 0

	for i = 1, CF["MaxCPUPlayers"] do
		if c["Player" .. i .. "Active"] == "True" then
			if tonumber(c["Player" .. i .. "Reputation"]) < rep then
				angriest = i
				rep = tonumber(c["Player" .. i .. "Reputation"])
			end
		end
	end

	return angriest, rep
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetLocationDifficulty"] = function(c, loc)
	local diff = CF["MaxDifficulty"]
	local sec = CF["GetLocationSecurity"](c, loc)

	diff = math.floor(sec / 10)
	if diff > CF["MaxDifficulty"] then
		diff = CF["MaxDifficulty"]
	end

	if diff < 1 then
		diff = 1
	end

	return diff
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetFullMissionDifficulty"] = function(c, loc, m)
	local ld = CF["GetLocationDifficulty"](c, loc)
	local md = tonumber(c["Mission" .. m .. "Difficulty"])
	local diff = ld + md - 1

	if diff > CF["MaxDifficulty"] then
		diff = CF["MaxDifficulty"]
	end

	if diff < 1 then
		diff = 1
	end

	return diff
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GetLocationSecurity"] = function(c, loc)
	local sec

	if c["Security_" .. loc] ~= nil then
		sec = tonumber(c["Security_" .. loc])
	else
		sec = CF["LocationSecurity"][loc]
	end

	return sec
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["SetLocationSecurity"] = function(c, loc, newsec)
	c["Security_" .. loc] = newsec
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF.GenerateRandomMission = function(c, ally_faction_override, enemy_faction_override)
	local cpus = tonumber(c["ActiveCPUs"])
	local mission = {}

	-- Select CPUs to choose mission. We'll give a bit higher priorities to CPU's with better reputation
	local selp = {}
	local r

	for i = 1, cpus do
		local rep = tonumber(c["Player" .. i .. "Reputation"])

		if rep < -2000 then
			r = 0.15
		elseif rep < -1000 then
			r = 0.30
		elseif rep < 0 then
			r = 0.45
		else
			r = 1
		end

		if math.random() < r then
			selp[#selp + 1] = i
		end
	end

	local p = ally_faction_override
	if (p == nil) then 
		p = #selp > 0 and selp[math.random(#selp)] or math.random(cpus)
	end

	-- Make list of available missions
	local rep = tonumber(c["Player" .. p .. "Reputation"])

	local missions = {}

	for m = 1, #CF.Mission do
		local msnid = CF.Mission[m]

		if CF.MissionMinReputation[msnid] <= rep then
			local newmsn = #missions + 1

			missions[newmsn] = {}
			missions[newmsn]["MissionID"] = msnid
			missions[newmsn]["Scenes"] = {}

			-- Search for locations for this mission and make a list of them
			for l = 1, #CF["Location"] do
				local locid = CF["Location"][l]
				if
					(CF["LocationPlayable"][locid] == nil or CF["LocationPlayable"][locid] == true)
					and c["Location"] ~= locid
					and not CF["IsLocationHasAttribute"](locid, CF["LocationAttributeTypes"].NOTMISSIONASSIGNABLE)
				then
					for lm = 1, #CF["LocationMissions"][locid] do
						if msnid == CF["LocationMissions"][locid][lm] then
							missions[newmsn]["Scenes"][#missions[newmsn]["Scenes"] + 1] = locid
						end
					end
				end
			end
		end
	end

	-- Pick some random mission for which we have locations
	local ok = false
	local rmsn
	local count = 1

	while not ok do
		ok = true

		rmsn = math.random(#missions)

		if #missions[rmsn]["Scenes"] == 0 then
			ok = false
		end

		count = count + 1
		if count > 100 then
			error("Endless loop at CF['GenerateRandomMission'] - mission selection")
			break
		end
	end

	-- Pick some random location for this mission
	local rloc = math.random(#missions[rmsn]["Scenes"])

	-- Pick some random difficulty for this mission
	-- Generate missions with CF["MaxDifficulty"] / 2 because additional difficulty
	-- will be applied by location security level
	local rdif = math.min(math.max(tonumber(c["MissionDifficultyBonus"]) + math.random(3), 1), CF["MaxDifficulty"])

	-- Pick some random target for this mission
	local ok = false
	local renm = enemy_faction_override
	local count = 1

	if (renm == nil or renm == p) then 

		while not ok do
			ok = true

			renm = math.random(cpus)

			if p == renm then
				ok = false
			end

			count = count + 1
			if count > 100 then
				error("Endless loop at CF['GenerateRandomMission'] - enemy selection")
				break
			end
		end

	end
	-- Return mission
	mission["SourcePlayer"] = p
	mission["TargetPlayer"] = renm
	mission["Type"] = missions[rmsn]["MissionID"]
	mission["Location"] = missions[rmsn]["Scenes"][rloc]
	mission["Difficulty"] = rdif

	return mission
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
CF["GenerateRandomMissions"] = function(c)
	
	if not c["ActiveCPUs"] then
		print("Active CPUS undefined:" .. tostring(c["ActiveCPUs"]))
		return
	end
	
	local missions = {}
	local maxMissions = math.max(CF["MaxMissions"], math.floor(tonumber(c["ActiveCPUs"]) / 4))
	for i = 1, maxMissions do
		local ok = false
		local msn
		local count = 1

		while not ok do
			ok = true

			msn = CF["GenerateRandomMission"](c)

			-- Make sure that we don't have multiple missions in single locations
			if i > 1 then
				for j = 1, i - 1 do
					if missions[j]["Location"] == msn["Location"] then
						ok = false
					end
				end
			end

			count = count + 1
			if count > 100 then
				error("Endless loop at CF['GenerateRandomMissions'] - mission generation")
				break
			end
		end

		missions[i] = msn
	end

	-- Put missions to config
	for i = 1, #missions do
		c["Mission" .. i .. "SourcePlayer"] = missions[i]["SourcePlayer"]
		c["Mission" .. i .. "TargetPlayer"] = missions[i]["TargetPlayer"]
		c["Mission" .. i .. "Type"] = missions[i]["Type"]
		c["Mission" .. i .. "Location"] = missions[i]["Location"]
		c["Mission" .. i .. "Difficulty"] = missions[i]["Difficulty"]
	end

	--return c
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
