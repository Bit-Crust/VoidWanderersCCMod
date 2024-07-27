-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_MakeRPGBrain(c, p, team, pos, level)
	local levels = {}
	levels[1] = {}
	levels[1]["BrainBasicPreset"] = "RPG Brain Robot Base LVL0"
	levels[1]["BrainPresetRename"] = "RPG Brain Robot Base LVL0::HLTH1"

	levels[2] = {}
	levels[2]["BrainBasicPreset"] = "RPG Brain Robot Base LVL1"
	levels[2]["BrainPresetRename"] = "RPG Brain Robot Base LVL1::LTH3 SHLD1 TLKN1 HEAL1 RGEN1 STOR1 QCAP1"

	levels[3] = {}
	levels[3]["BrainBasicPreset"] = "RPG Brain Robot Base LVL2"
	levels[3]["BrainPresetRename"] = "RPG Brain Robot Base LVL2::HLTH5 SHLD2 TLKN2 HEAL2 RGEN2 STOR2 QCAP2"

	levels[4] = {}
	levels[4]["BrainBasicPreset"] = "RPG Brain Robot Base LVL3"
	levels[4]["BrainPresetRename"] = "RPG Brain Robot Base LVL3::HLTH7 SHLD3 TLKN3 HEAL3 RGEN3 STOR3 QCAP3"

	levels[5] = {}
	levels[5]["BrainBasicPreset"] = "RPG Brain Robot Base LVL4"
	levels[5]["BrainPresetRename"] = "RPG Brain Robot Base LVL4::HLTH9 SHLD4 TLKN4 HEAL4 RGEN4 STOR4 QCAP4"

	levels[6] = {}
	levels[6]["BrainBasicPreset"] = "RPG Brain Robot Base LVL5"
	levels[6]["BrainPresetRename"] = "RPG Brain Robot Base LVL5::HLTH9 SHLD5 TLKN5 HEAL5 RGEN5 STOR5 QCAP5"

	--print ("CF_MakeBrain");
	local f = CF_GetPlayerFaction(c, p)
	local brain = CF_MakeBrainWithPreset(
		c,
		p,
		team,
		pos,
		levels[level]["BrainBasicPreset"],
		"AHuman",
		CF_ModuleName,
		true
	)
	if brain then
		brain.PresetName = levels[level]["BrainPresetRename"]
	end
	return brain
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_MakeBrain(c, p, team, pos, giveWeapons)
	--print ("CF_MakeBrain");
	local f = CF_GetPlayerFaction(c, p)
	return CF_MakeBrainWithPreset(c, p, team, pos, CF_Brains[f], CF_BrainClasses[f], CF_BrainModules[f], giveWeapons)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_MakeBrainWithPreset(c, p, team, pos, preset, class, module, giveWeapons)
	--print ("CF_MakeBrainWithPreset");

	local f = CF_GetPlayerFaction(c, p)

	local actor = CF_MakeActor(preset, class, module)

	if actor ~= nil then
		if giveWeapons then
			local weapon = nil
			local weaponsgiven = 0
			-- Create list of prefered weapons for brains
			local list = CF_PreferedBrainInventory[f] or { CF_WeaponTypes.RIFLE, CF_WeaponTypes.DIGGER }
			for i = 1, #list do
				local weaps
				-- Try to give brain most powerful prefered weapon
				weaps = CF_MakeListOfMostPowerfulWeapons(c, p, list[i], 100000)

				if weaps ~= nil then
					local wf = weaps[1]["Faction"]
					weapon = CF_MakeItem(
						CF_ItmPresets[wf][weaps[1]["Item"]],
						CF_ItmClasses[wf][weaps[1]["Item"]],
						CF_ItmModules[wf][weaps[1]["Item"]]
					)
					if weapon ~= nil then
						actor:AddInventoryItem(weapon)

						if list[i] ~= CF_WeaponTypes.DIGGER and list[i] ~= CF_WeaponTypes.TOOL then
							weaponsgiven = weaponsgiven + 1
						end
					end
				end
			end

			if weaponsgiven == 0 then
				-- If we didn't get any weapins try to give other weapons, rifles
				if weaps == nil then
					weaps = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.RIFLE, 100000)
				end

				-- Sniper rifles
				if weaps == nil then
					weaps = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.SNIPER, 100000)
				end

				-- No luck - heavies then
				if weaps == nil then
					weaps = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.HEAVY, 100000)
				end

				-- No luck - pistols then
				if weaps == nil then
					weaps = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.PISTOL, 100000)
				end

				if weaps ~= nil then
					local wf = weaps[1]["Faction"]
					weapon = CF_MakeItem(
						CF_ItmPresets[wf][weaps[1]["Item"]],
						CF_ItmClasses[wf][weaps[1]["Item"]],
						CF_ItmModules[wf][weaps[1]["Item"]]
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
function CF_SpawnAIUnitWithPreset(c, p, team, pos, aimode, pre)
	local act = CF_MakeUnitFromPreset(c, p, pre)

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
function CF_SpawnAIUnit(c, p, team, pos, aimode)
	local pre = math.random(CF_PresetTypes.ENGINEER) --The last two presets are ENGINEER and DEFENDER
	local act = CF_MakeUnitFromPreset(c, p, pre)

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
function CF_SpawnRandomInfantry(team, pos, faction, aimode)
	--print ("CF_SpawnRandomInfantry");
	local actor = nil
	local r1, r2
	local item

	if MovableMan:GetMOIDCount() < CF_MOIDLimit then
		-- Find AHuman
		local ok = false
		-- Emergency counter in case we don't have AHumans in factions
		local counter = 0

		while not ok do
			ok = false
			r1 = #CF_ActNames[faction] > 0 and math.random(#CF_ActNames[faction]) or 0

			if
				(CF_ActClasses[faction][r1] == nil or CF_ActClasses[faction][r1] == "AHuman")
				and CF_ActTypes[faction][r1] ~= CF_ActorTypes.ARMOR
			then
				ok = true
			end

			-- Break to avoid endless loop
			counter = counter + 1
			if counter > 20 then
				break
			end
		end

		actor = CF_MakeActor(CF_ActPresets[faction][r1], CF_ActClasses[faction][r1], CF_ActModules[faction][r1])

		if actor ~= nil then
			-- Check if this is pre-equipped faction
			local preequipped = false

			if CF_PreEquippedActors[faction] ~= nil and CF_PreEquippedActors[faction] then
				preequpped = true
			end

			if not preequipped then
				-- Find rifle
				local ok = false
				-- Emergency counter in case we don't have AHumans in factions
				local counter = 0

				while not ok do
					ok = false
					r2 = math.random(#CF_ItmNames[faction])

					if
						CF_ItmTypes[faction][r2] == CF_WeaponTypes.RIFLE
						or CF_ItmTypes[faction][r2] == CF_WeaponTypes.SHOTGUN
						or CF_ItmTypes[faction][r2] == CF_WeaponTypes.SNIPER
					then
						ok = true
					end

					-- Break to avoid endless loop
					counter = counter + 1
					if counter > 40 then
						break
					end
				end

				item = CF_MakeItem(CF_ItmPresets[faction][r2], CF_ItmClasses[faction][r2], CF_ItmModules[faction][r2])

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
function CF_MakeListOfMostPowerfulWeapons(config, player, weaponType, maxTech)
	local weaps = {}
	local f = CF_GetPlayerFaction(config, player)
	-- Filter needed items
	for i = 1, #CF_ItmNames[f] do
		if
			CF_ItmPowers[f][i] > 0
			and CF_ItmUnlockData[f][i] <= maxTech
			and (CF_WeaponTypes.ANY == weaponType or CF_ItmTypes[f][i] == weaponType)
		then
			local n = #weaps + 1
			weaps[n] = {}
			weaps[n]["Item"] = i
			weaps[n]["Faction"] = f
			weaps[n]["Power"] = CF_ItmPowers[f][i]
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
		for i = 0, #CF_WeaponTypes - 1 do
			weaps = CF_MakeListOfMostPowerfulWeapons(config, player, i, maxTech)
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
function CF_MakeListOfMostPowerfulActors(config, player, actorType, maxTech)
	local acts = {}
	local f = CF_GetPlayerFaction(config, player)
	-- Filter needed items
	for i = 1, #CF_ActNames[f] do
		if
			CF_ActPowers[f][i] > 0
			and CF_ActUnlockData[f][i] <= maxTech
			and (CF_ActorTypes.ANY == actorType or CF_ActTypes[f][i] == actorType)
		then
			local n = #acts + 1
			acts[n] = {}
			acts[n]["Actor"] = i
			acts[n]["Faction"] = f
			acts[n]["Power"] = CF_ActPowers[f][i]
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
		for i = 0, #CF_ActorTypes - 1 do
			acts = CF_MakeListOfMostPowerfulActors(config, player, i, maxTech)
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
function CF_CreateAIUnitPresets(c, p, tech)
	--print ("CF_CreateAIUnitPresets "..p)
	-- Presets -            	"Infantry 1", 				"Infantry 2", 			"Sniper", 				"Shotgun", 				"Heavy 1", 				"Heavy 2", 				"Armor 1", 				"Armor 2", 				"Engineer", 			"Defender"
	local desiredactors = {
		CF_ActorTypes.LIGHT,
		CF_ActorTypes.HEAVY,
		CF_ActorTypes.LIGHT,
		CF_ActorTypes.HEAVY,
		CF_ActorTypes.HEAVY,
		CF_ActorTypes.HEAVY,
		CF_ActorTypes.ARMOR,
		CF_ActorTypes.HEAVY,
		CF_ActorTypes.LIGHT,
		CF_ActorTypes.TURRET,
	}

	local desiredweapons = {
		CF_WeaponTypes.RIFLE,
		CF_WeaponTypes.RIFLE,
		CF_WeaponTypes.SNIPER,
		CF_WeaponTypes.SHOTGUN,
		CF_WeaponTypes.HEAVY,
		CF_WeaponTypes.HEAVY,
		CF_WeaponTypes.HEAVY,
		CF_WeaponTypes.SHIELD,
		CF_WeaponTypes.DIGGER,
		CF_WeaponTypes.SHOTGUN,
	}
	local desiredsecweapons = {
		CF_WeaponTypes.PISTOL,
		CF_WeaponTypes.PISTOL,
		CF_WeaponTypes.PISTOL,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.RIFLE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.PISTOL,
		CF_WeaponTypes.PISTOL,
		CF_WeaponTypes.RIFLE,
		CF_WeaponTypes.GRENADE,
	}
	local desiredtretweapons = {
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GRENADE,
		CF_WeaponTypes.GREANDE,
		CF_WeaponTypes.GRENADE,
	}

	local f = CF_GetPlayerFaction(c, p)
	local preequipped = false

	if CF_PreEquippedActors[f] ~= nil and CF_PreEquippedActors[f] then
		preequipped = true
	end

	if preequipped then
		--print ("Pre-equipped")
		--print ("")
		print(#desiredactors)
		-- Fill presets for pre-equpped faction
		for i = 1, 10 do
			-- Select a suitable actor based on his equipment class
			local selected = 1
			local match = false

			local actors
			local lastgoodactors
			local weakestactor

			-- Build a list of desired actors and weapons
			local da = {}
			local dw = {}
			-- What is this system??
			da[1] = desiredactors[i]
			dw[1] = desiredweapons[i]
			da[2] = CF_ActorTypes.HEAVY
			dw[2] = desiredweapons[i]
			da[3] = CF_ActorTypes.LIGHT
			dw[3] = desiredweapons[i]
			da[4] = CF_ActorTypes.ARMOR
			dw[4] = desiredweapons[i]
			da[5] = CF_ActorTypes.HEAVY
			dw[5] = nil
			da[6] = CF_ActorTypes.LIGHT
			dw[6] = nil
			da[7] = CF_ActorTypes.ARMOR
			dw[7] = nil

			for k = 1, #da do
				actors = CF_MakeListOfMostPowerfulActors(c, p, da[k], tech)

				if actors ~= nil and dw[k] ~= nil then
					for j = 1, #actors do
						if CF_EquipmentTypes[f][actors[j]["Actor"]] ~= nil then
							if CF_EquipmentTypes[f][actors[j]["Actor"]] == dw[k] then
								selected = j
								match = true
								break
							end
						end
					end
				end

				if match then
					break
				end

				if actors ~= nil then
					lastgoodactors = actors
				end
			end

			if actors == nil then
				actors = lastgoodactors
			end

			if actors ~= nil then
				c["Player" .. p .. "Preset" .. i .. "Actor"] = actors[selected]["Actor"]
				c["Player" .. p .. "Preset" .. i .. "Faction"] = actors[selected]["Faction"]

				--Reset all weapons
				for j = 1, CF_MaxItemsPerPreset do
					c["Player" .. p .. "Preset" .. i .. "Item" .. j] = nil
					c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. j] = nil
				end

				-- If we didn't find a suitable engineer unit then try give digger to engineer preset
				if desiredweapons[i] == CF_WeaponTypes.DIGGER and not match then
					local weapons1
					weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, desiredweapons[i], tech)

					local class = CF_ActClasses[actors[selected]["Faction"]][actors[selected]["Actor"]]
					-- Don't give weapons to ACrabs
					if class ~= "ACrab" then
						if weapons1 ~= nil then
							c["Player" .. p .. "Preset" .. i .. "Item" .. 1] = weapons1[1]["Item"]
							c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. 1] = weapons1[1]["Faction"]
							--print (CF_PresetNames[i].." + Digger")
						end
					end
				end

				--print(CF_PresetNames[i].." "..CF_ActPresets[c["Player"..p.."Preset"..i.."Faction"]][c["Player"..p.."Preset"..i.."Actor"]] .." "..tostring(match))
				--print(c["Player"..p.."Preset"..i.."Item1"])
				--print(c["Player"..p.."Preset"..i.."Item2"])
				--print(c["Player"..p.."Preset"..i.."Item3"])
			end
		end
	else
		--print ("Empty actors")

		-- Fill presets for generic faction
		for i = 1, 10 do
			local actors
			actors = CF_MakeListOfMostPowerfulActors(c, p, desiredactors[i], tech)

			if actors == nil then
				actors = CF_MakeListOfMostPowerfulActors(c, p, CF_ActorTypes.LIGHT, tech)
			end
			if actors == nil then
				actors = CF_MakeListOfMostPowerfulActors(c, p, CF_ActorTypes.HEAVY, tech)
			end
			if actors == nil then
				actors = CF_MakeListOfMostPowerfulActors(c, p, CF_ActorTypes.ARMOR, tech)
			end

			local weapons1
			weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, desiredweapons[i], tech)

			if weapons1 == nil then
				weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.RIFLE, tech)
			end
			if weapons1 == nil then
				weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.SHOTGUN, tech)
			end
			if weapons1 == nil then
				weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.SNIPER, tech)
			end
			if weapons1 == nil then
				weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.HEAVY, tech)
			end
			if weapons1 == nil then
				weapons1 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.PISTOL, tech)
			end

			local weapons2
			weapons2 = CF_MakeListOfMostPowerfulWeapons(c, p, desiredsecweapons[i], tech)

			if weapons2 == nil then
				weapons2 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.PISTOL, tech)
			end
			if weapons2 == nil then
				weapons2 = CF_MakeListOfMostPowerfulWeapons(c, p, CF_WeaponTypes.DIGGER, tech)
			end

			local weapons3
			weapons3 = CF_MakeListOfMostPowerfulWeapons(c, p, desiredtretweapons[i], tech)

			if actors ~= nil then
				c["Player" .. p .. "Preset" .. i .. "Actor"] = actors[1]["Actor"]
				c["Player" .. p .. "Preset" .. i .. "Faction"] = actors[1]["Faction"]

				local class = CF_ActClasses[actors[1]["Faction"]][actors[1]["Actor"]]

				-- Don't give weapons to ACrabs
				if class ~= "ACrab" then
					local weap = 1

					if weapons1 ~= nil then
						-- Add small random spread for primary weapons
						local spread = 2

						if #weapons1 < spread then
							spread = 1
						end

						local w = math.random(spread)
						--print ("Selected weapon: "..w)

						c["Player" .. p .. "Preset" .. i .. "Item" .. weap] = weapons1[w]["Item"]
						c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. weap] = weapons1[w]["Faction"]
						weap = weap + 1
					end

					if weapons2 ~= nil then
						-- Add small random spread for secondary weapons
						local spread = 2

						if #weapons2 < spread then
							spread = 1
						end

						local w = math.random(spread)
						--print ("Selected sec weapon: "..w)

						c["Player" .. p .. "Preset" .. i .. "Item" .. weap] = weapons2[w]["Item"]
						c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. weap] = weapons2[w]["Faction"]
						weap = weap + 1
					end

					if weapons3 ~= nil then
						-- Add small random spread for grenades
						local spread = 2

						if #weapons3 < spread then
							spread = 1
						end

						local w = math.random(spread)
						--print ("Selected tri weapon: "..w)

						c["Player" .. p .. "Preset" .. i .. "Item" .. weap] = weapons3[w]["Item"]
						c["Player" .. p .. "Preset" .. i .. "ItemFaction" .. weap] = weapons3[w]["Faction"]
						weap = weap + 1
					end

					if CF_AIDebugOutput then
						--print ("------")
						--print(CF_ActPresets[c["Player"..p.."Preset"..i.."Faction"]][c["Player"..p.."Preset"..i.."Actor"]])
						--print(CF_ItmPresets[c["Player"..p.."Preset"..i.."ItemFaction1"]][c["Player"..p.."Preset"..i.."Item1"]])
						--print(CF_ItmPresets[c["Player"..p.."Preset"..i.."ItemFaction2"]][c["Player"..p.."Preset"..i.."Item2"]])
						--print(CF_ItmPresets[c["Player"..p.."Preset"..i.."ItemFaction3"]][c["Player"..p.."Preset"..i.."Item3"]])
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
function CF_MakeUnitFromPreset(c, p, pre)
	local actor = nil
	local offset = Vector()
	local weapon = nil

	if MovableMan:GetMOIDCount() < CF_MOIDLimit then
		local a = c["Player" .. p .. "Preset" .. pre .. "Actor"]
		if a ~= nil then
			a = tonumber(a)
			local f = c["Player" .. p .. "Preset" .. pre .. "Faction"]
			local reputation = c["Player" .. p .. "Reputation"]
			local setRank = 0
			if reputation then
				reputation = math.abs(tonumber(reputation))
				setRank = math.min(
					math.random(0, math.floor(#CF_Ranks * (reputation / (#CF_Ranks * CF_ReputationPerDifficulty)))),
					#CF_Ranks
				)
			end

			actor = CF_MakeActor(CF_ActPresets[f][a], CF_ActClasses[f][a], CF_ActModules[f][a], CF_Ranks[setRank])

			if CF_ActOffsets[f][a] then
				offset = CF_ActOffsets[f][a]
			end

			if actor then
				-- Give weapons to human actors
				if actor.ClassName == "AHuman" then
					if setRank ~= 0 then
						if actor.ModuleID < 10 and math.random() + 0.5 < setRank / #CF_Ranks then
							CF_RandomizeLimbs(actor)
						end
					end
					if actor.Head then
						actor.Head:SetNumberValue("Carriable", 1)
						actor.Head:AddScript(CF_ModuleName .. "/Items/AttachOnCollision.lua")
						actor.RestThreshold = 10000
						actor.Head.RestThreshold = -1
					end
					for i = 1, math.ceil(CF_MaxItemsPerPreset * RangeRand(0.5, 1.0)) do
						if c["Player" .. p .. "Preset" .. pre .. "Item" .. i] ~= nil then
							local w = tonumber(c["Player" .. p .. "Preset" .. pre .. "Item" .. i])
							local wf = c["Player" .. p .. "Preset" .. pre .. "ItemFaction" .. i]

							weapon = CF_MakeItem(CF_ItmPresets[wf][w], CF_ItmClasses[wf][w], CF_ItmModules[wf][w])

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
		print("Can't spawn unit from preset; we've reached the MOID limit!!")
	end

	return actor, offset
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_ReadPtsData(scene, ls)
	local pts = {}

	-- Create list of data objcets
	-- Add generic mission types which must be present on any map
	for i = 1, CF_GenericMissionCount do
		pts[CF_Mission[i]] = {}
	end

	for i = 1, #CF_LocationMissions[scene] do
		pts[CF_LocationMissions[scene][i]] = {}
	end

	-- Load level data
	for k1, v1 in pairs(pts) do
		local msntype = k1

		--print (msntype)

		for k2 = 1, CF_MissionMaxSets[msntype] do -- Enum sets
			local setnum = k2

			--print ("  "..setnum)

			for k3 = 1, #CF_MissionRequiredData[msntype] do -- Enum Point types
				local pttype = CF_MissionRequiredData[msntype][k3]["Name"]

				--print ("    "..pttype)

				--print (k3)
				--print (msntype)
				--print (pttype)

				for k4 = 1, CF_MissionRequiredData[msntype][k3]["Max"] do -- Enum points
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
function CF_GetRandomMissionPointsSet(pts, msntype)
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
function CF_GetPointsArray(pts, msntype, setnum, ptstype)
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
function CF_SelectRandomPoints(pts, n)
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
function CF_GetAngriestPlayer(c)
	local angriest
	local rep = 0

	for i = 1, CF_MaxCPUPlayers do
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
function CF_GetLocationDifficulty(c, loc)
	local diff = CF_MaxDifficulty
	local sec = CF_GetLocationSecurity(c, loc)

	diff = math.floor(sec / 10)
	if diff > CF_MaxDifficulty then
		diff = CF_MaxDifficulty
	end

	if diff < 1 then
		diff = 1
	end

	return diff
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_GetFullMissionDifficulty(c, loc, m)
	local ld = CF_GetLocationDifficulty(c, loc)
	local md = tonumber(c["Mission" .. m .. "Difficulty"])
	local diff = ld + md - 1

	if diff > CF_MaxDifficulty then
		diff = CF_MaxDifficulty
	end

	if diff < 1 then
		diff = 1
	end

	return diff
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_GetLocationSecurity(c, loc)
	local sec

	if c["Security_" .. loc] ~= nil then
		sec = tonumber(c["Security_" .. loc])
	else
		sec = CF_LocationSecurity[loc]
	end

	return sec
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_SetLocationSecurity(c, loc, newsec)
	c["Security_" .. loc] = newsec
end
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
function CF_GenerateRandomMission(c, ally_faction_override, enemy_faction_override)
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

	for m = 1, #CF_Mission do
		local msnid = CF_Mission[m]

		if CF_MissionMinReputation[msnid] <= rep then
			local newmsn = #missions + 1

			missions[newmsn] = {}
			missions[newmsn]["MissionID"] = msnid
			missions[newmsn]["Scenes"] = {}

			-- Search for locations for this mission and make a list of them
			for l = 1, #CF_Location do
				local locid = CF_Location[l]
				if
					(CF_LocationPlayable[locid] == nil or CF_LocationPlayable[locid] == true)
					and c["Location"] ~= locid
					and not CF_IsLocationHasAttribute(locid, CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE)
				then
					for lm = 1, #CF_LocationMissions[locid] do
						if msnid == CF_LocationMissions[locid][lm] then
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
			error("Endless loop at CF_GenerateRandomMission - mission selection")
			break
		end
	end

	-- Pick some random location for this mission
	local rloc = math.random(#missions[rmsn]["Scenes"])

	-- Pick some random difficulty for this mission
	-- Generate missions with CF_MaxDifficulty / 2 because additional difficulty
	-- will be applied by location security level
	local rdif = math.min(math.max(tonumber(c["MissionDifficultyBonus"]) + math.random(3), 1), CF_MaxDifficulty)

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
				error("Endless loop at CF_GenerateRandomMission - enemy selection")
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
function CF_GenerateRandomMissions(c)
	
	if not c["ActiveCPUs"] then
		print("Active CPUS undefined:" .. tostring(c["ActiveCPUs"]))
		return
	end
	
	local missions = {}
	local maxMissions = math.max(CF_MaxMissions, math.floor(tonumber(c["ActiveCPUs"]) / 4))
	for i = 1, maxMissions do
		local ok = false
		local msn
		local count = 1

		while not ok do
			ok = true

			msn = CF_GenerateRandomMission(c)

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
				error("Endless loop at CF_GenerateRandomMissions - mission generation")
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
