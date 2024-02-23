local weaponGroups = {
	{ "Weapons - Light", CF_WeaponTypes.RIFLE },
	{ "Weapons - Heavy", CF_WeaponTypes.HEAVY },
	{ "Weapons - Sniper", CF_WeaponTypes.SNIPER },
	{ "Weapons - Shotguns", CF_WeaponTypes.SHOTGUN },
	{ "Weapons - Secondary", CF_WeaponTypes.PISTOL },
	{ "Weapons - Melee", CF_WeaponTypes.PISTOL }, -- Force melee weapons as "Secondary" but not as starter secondary
	{ "Tools", CF_WeaponTypes.TOOL },
	{ "Tools - Diggers", CF_WeaponTypes.DIGGER },
	{ "Shields", CF_WeaponTypes.SHIELD },
	{ "Bombs", CF_WeaponTypes.GRENADE },
	{ "Bombs - Grenades", CF_WeaponTypes.GRENADE },
}
local actorGroups = {
	{ "Actors - Light", CF_ActorTypes.LIGHT },
	{ "Actors - Heavy", CF_ActorTypes.HEAVY },
	{ "Actors - Mecha", CF_ActorTypes.ARMOR },
	{ "Actors - Turrets", CF_ActorTypes.TURRET },
}
local baseItems = {}
baseItems[#baseItems + 1] = { presetName = "Remote Explosive", class = "TDExplosive", unlockData = 500, itemPowers = 0 }
baseItems[#baseItems + 1] = {
	presetName = "Anti Personnel Mine",
	class = "TDExplosive",
	unlockData = 1000,
	itemPowers = 0,
}

baseItems[#baseItems + 1] = {
	presetName = "Light Digger",
	class = "HDFirearm",
	unlockData = 0,
	itemPowers = 1,
	weaponType = CF_WeaponTypes.DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Medium Digger",
	class = "HDFirearm",
	unlockData = 600,
	itemPowers = 3,
	weaponType = CF_WeaponTypes.DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Heavy Digger",
	class = "HDFirearm",
	unlockData = 1200,
	itemPowers = 5,
	weaponType = CF_WeaponTypes.DIGGER,
}
baseItems[#baseItems + 1] = { presetName = "Detonator", class = "HDFirearm", unlockData = 500, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Grapple Gun", class = "HDFirearm", unlockData = 800, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Medikit", class = "HDFirearm", unlockData = 700, itemPowers = 3 }
baseItems[#baseItems + 1] = { presetName = "Disarmer", class = "HDFirearm", unlockData = 900, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Constructor", class = "HDFirearm", unlockData = 1000, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Scanner", class = "HDFirearm", unlockData = 800, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Riot Shield", class = "HeldDevice", unlockData = 500, itemPowers = 1 }

local baseActors = {}
baseActors[#baseActors + 1] = { presetName = "Medic Drone", class = "ACrab", unlockData = 1300, actorPowers = 0 }
--baseActors[#baseActors + 1] = {presetName = "Green Dummy", class = "AHuman", unlockData = 750, actorPowers = 0};
for module in PresetMan.Modules do
	if
		module.FileName ~= "Base.rte"
		and module.FileName ~= "UserSavedGames.rte"
		and module.FileName ~= "UserSavedConquest.rte"
		and module.FileName ~= "UserScenes.rte"
	then
		local factionid = module.FriendlyName
		-- Find faction files in either the module or VoidWanderers support folder
		local pathNative = module.FileName .. "/FactionFiles/" .. string.gsub(module.FileName, ".rte", ".lua")
		local pathSupport = CF_ModuleName .. "/Support/" .. string.gsub(module.FileName, ".rte", ".lua")
		if CF_IsFilePathExists(pathNative) then
			print("Loading native faction file: " .. factionid)
			dofile(pathNative)
		elseif CF_IsFilePathExists(pathSupport) then
			print("Loading supported faction file: " .. factionid)
			dofile(pathSupport)
		elseif module.FileName ~= CF_ModuleName and module.IsFaction then
			print("Autoloading: " .. factionid)

			CF_Factions[#CF_Factions + 1] = factionid
			CF_FactionNames[factionid] = module.FriendlyName
			CF_FactionDescriptions[factionid] = module.Description and module.Description or "DESCRIPTION UNAVAILABLE"
			-- Set true if faction is selectable by player or AI
			CF_FactionPlayable[factionid] = true
			CF_RequiredModules[factionid] = { "Base.rte", module.FileName }
			-- Available values ORGANIC, SYNTHETIC
			CF_FactionNatures[factionid] = CF_FactionTypes.SYNTHETIC
			-- Percentage of troops sent to brainhunt or attack player LZ when AI is defending (default - CF_DefaultBrainHuntRatio)
			-- If this value is less then default then faction is marked as Defensive if it's more, then as Offensive
			CF_BrainHuntRatios[factionid] = 40
			-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
			CF_PreferedBrainInventory[factionid] = { CF_WeaponTypes.DIGGER, CF_WeaponTypes.RIFLE }
			-- Define brain unit
			CF_Brains[factionid] = "Brain Robot"
			CF_BrainModules[factionid] = "Base.rte"
			CF_BrainClasses[factionid] = "AHuman"
			CF_BrainPrices[factionid] = 500
			-- Define dropship
			CF_Crafts[factionid] = "Dropship MK1"
			CF_CraftModules[factionid] = "Base.rte"
			CF_CraftClasses[factionid] = "ACDropShip"
			CF_CraftPrices[factionid] = 500
			-- Define buyable actors available for purchase or unlocks
			CF_ActNames[factionid] = {}
			CF_ActPresets[factionid] = {}
			CF_ActModules[factionid] = {}
			CF_ActPrices[factionid] = {}
			CF_ActDescriptions[factionid] = {}
			CF_ActUnlockData[factionid] = {}
			CF_ActClasses[factionid] = {}
			CF_ActTypes[factionid] = {} -- AI will select different weapons based on this value
			CF_ActPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use
			CF_ActOffsets[factionid] = {}
			-- Define buyable items available for purchase or unlocks
			CF_ItmNames[factionid] = {}
			CF_ItmPresets[factionid] = {}
			CF_ItmModules[factionid] = {}
			CF_ItmPrices[factionid] = {}
			CF_ItmDescriptions[factionid] = {}
			CF_ItmUnlockData[factionid] = {}
			CF_ItmClasses[factionid] = {}
			CF_ItmTypes[factionid] = {}
			CF_ItmPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use
			local i = 0
			local starterPrimary, starterSecondary, starterActor
			-- Add so-called "basic" actors and items from Base.rte
			for j = 1, #baseActors do
				local actor
				i = #CF_ActNames[factionid] + 1
				if baseActors[j].class == "ACrab" then
					actor = CreateACrab(baseActors[j].presetName, "Base.rte")
					CF_ActTypes[factionid][i] = CF_ActorTypes.ARMOR
					CF_ActOffsets[factionid][i] = Vector(0, 12)
				elseif baseActors[j].class == "AHuman" then
					actor = CreateAHuman(baseActors[j].presetName, "Base.rte")
					CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
				end
				if actor then
					CF_ActNames[factionid][i] = actor.PresetName
					CF_ActPresets[factionid][i] = actor.PresetName
					CF_ActModules[factionid][i] = "Base.rte"
					CF_ActPrices[factionid][i] = actor:GetGoldValue(0, 1, 1)
					CF_ActDescriptions[factionid][i] = actor.Description

					CF_ActUnlockData[factionid][i] = baseActors[j].unlockData
					CF_ActPowers[factionid][i] = baseActors[j].actorPowers
					CF_ActClasses[factionid][i] = actor.ClassName
					DeleteEntity(actor)
				end
			end
			for j = 1, #baseItems do
				local item
				i = #CF_ItmNames[factionid] + 1
				if baseItems[j].class == "TDExplosive" then
					item = CreateTDExplosive(baseItems[j].presetName, "Base.rte")
					CF_ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType
						or CF_WeaponTypes.GRENADE
				elseif baseItems[j].class == "HDFirearm" then
					item = CreateHDFirearm(baseItems[j].presetName, "Base.rte")
					CF_ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType
						or CF_WeaponTypes.TOOL
				elseif baseItems[j].class == "HeldDevice" then
					item = CreateHeldDevice(baseItems[j].presetName, "Base.rte")
					CF_ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType
						or CF_WeaponTypes.SHIELD
				end
				if item then
					CF_ItmNames[factionid][i] = item.PresetName
					CF_ItmPresets[factionid][i] = item.PresetName
					CF_ItmModules[factionid][i] = "Base.rte"
					CF_ItmPrices[factionid][i] = item:GetGoldValue(0, 1, 1)
					CF_ItmDescriptions[factionid][i] = item.Description
					CF_ItmClasses[factionid][i] = item.ClassName

					CF_ItmUnlockData[factionid][i] = baseItems[j].unlockData
					CF_ItmPowers[factionid][i] = baseItems[j].itemPowers
					DeleteEntity(item)
				end
			end
			--Add every item found in the module
			for entity in module.Presets do
				-- the MissionCritical check was added for pre6 compat to dodge an issue with an unused mission item not being Buyable = 0
				-- everyone was being given one...
				if
					(
						entity.ClassName == "HDFirearm"
						or entity.ClassName == "TDExplosive"
						or entity.ClassName == "HeldDevice"
					)
					and ToMOSRotating(entity).Buyable
					and not ToMovableObject(entity).MissionCritical
				then
					entity = ToMOSRotating(entity)
					if entity:HasObjectInGroup("Bombs - Payloads") then
						local n = #CF_BombNames + 1
						CF_BombNames[n] = entity:GetModuleAndPresetName()
						CF_BombPresets[n] = entity.PresetName
						CF_BombModules[n] = module.FileName
						CF_BombClasses[n] = entity.ClassName
						CF_BombPrices[n] = entity:GetGoldValue(0, 1, 1)
						CF_BombDescriptions[n] = entity.Description
						CF_BombOwnerFactions[n] = { factionid }
						CF_BombUnlockData[n] = CF_BombPrices[n] * 16
					else
						i = #CF_ItmNames[factionid] + 1
						CF_ItmNames[factionid][i] = entity:GetModuleAndPresetName()
						CF_ItmPresets[factionid][i] = entity.PresetName
						CF_ItmModules[factionid][i] = module.FileName
						CF_ItmPrices[factionid][i] = entity:GetGoldValue(0, 1, 1)
						CF_ItmDescriptions[factionid][i] = entity.Description
						--[[CF_ItmDescriptions[factionid][i] = 	"Weight = ".. math.floor(entity.Mass + 0.5)
														..	"\n Durability = ".. entity.GibWoundLimit;]]
						--
						CF_ItmUnlockData[factionid][i] = CF_ItmPrices[factionid][i] * 18
						CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE --Default setting

						CF_ItmClasses[factionid][i] = entity.ClassName

						for group = 1, #weaponGroups do
							if entity:HasObjectInGroup(weaponGroups[group][1]) then
								CF_ItmTypes[factionid][i] = weaponGroups[group][2]
							end
						end
						if IsHDFirearm(entity) then
							entity = ToHDFirearm(entity)
							--Force set onehanded weapons to be secondary?
							--	if entity:IsOneHanded() then
							--		CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL;
							--	end
							--Display stats?
							--	local fireRate = entity.RateOfFire > 3600 and "Maximum" or "".. entity.RateOfFire;
							--	local ammoCap = entity.RoundInMagCount > 0 and "\n Ammo capacity = ".. entity.RoundInMagCount or "";
							--	CF_ItmDescriptions[factionid][i] = CF_ItmDescriptions[factionid][i] .."\n Rate of Fire = ".. fireRate .."".. ammoCap

							--Secondary weapons require more data because they're cheap already
							if entity:HasObjectInGroup("Weapons - Secondary") then
								CF_ItmUnlockData[factionid][i] = CF_ItmUnlockData[factionid][i] * 1.8
							end
							if entity:HasObjectInGroup("Weapons - Explosive") then
								CF_ItmUnlockData[factionid][i] = CF_ItmUnlockData[factionid][i] * 1.1
							end
							if entity.FullAuto then
								CF_ItmUnlockData[factionid][i] = CF_ItmUnlockData[factionid][i] * 1.1
							end
							--Estimate if a weapon resembles a shotgun
							if
								entity:HasObjectInGroup("Weapons - CQB")
								or (
									entity:HasObjectInGroup("Weapons")
									and entity.ParticleSpreadRange >= 5
									and (
										entity.Magazine
										and entity.Magazine.NextRound
										and (
											entity.Magazine.NextRound.ParticleCount > 1
											or entity.Magazine.NextRound.NextParticle.ClassName == "AEmitter"
										)
									)
								)
							then
								CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
							end
						elseif IsTDExplosive(entity) then
							--Bombs/grenades also require more data because they're cheap already
							if entity:HasObjectInGroup("Bombs") then
								CF_ItmUnlockData[factionid][i] = CF_ItmUnlockData[factionid][i] * 1.8
							end
							entity = ToTDExplosive(entity)
							CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
							--CF_ItmDescriptions[factionid][i] = CF_ItmDescriptions[factionid][i] .."\n Throw distance = ".. entity.MinThrowVel .."-".. entity.MaxThrowVel;
						end
						CF_ItmPowers[factionid][i] = math.ceil((CF_ItmUnlockData[factionid][i] + 1) / 250)
						CF_ItmUnlockData[factionid][i] = math.floor(CF_ItmUnlockData[factionid][i] + 0.5)
						--ConsoleMan:PrintString(entity.PresetName .. " Data: " .. CF_ItmUnlockData[factionid][i] .. ", Powers: " .. CF_ItmPowers[factionid][i]);

						if
							not starterPrimary
							or (
								(
									CF_ItmTypes[factionid][starterPrimary] ~= CF_WeaponTypes.RIFLE
									and CF_ItmTypes[factionid][i] == CF_WeaponTypes.RIFLE
								)
								or (
									CF_ItmTypes[factionid][starterPrimary] == CF_ItmTypes[factionid][i]
									and CF_ItmPrices[factionid][i] < CF_ItmPrices[factionid][starterPrimary]
								)
							)
						then
							starterPrimary = i
						end
						if
							not entity:HasObjectInGroup("Weapons - Melee")
							and (
								not starterSecondary
								or (
									(
										CF_ItmTypes[factionid][starterSecondary] ~= CF_WeaponTypes.PISTOL
										and CF_ItmTypes[factionid][i] == CF_WeaponTypes.PISTOL
									)
									or (
										CF_ItmTypes[factionid][starterSecondary] == CF_ItmTypes[factionid][i]
										and CF_ItmPrices[factionid][i] < CF_ItmPrices[factionid][starterSecondary]
									)
								)
							)
						then
							starterSecondary = i
						end
					end
				elseif
					(entity.ClassName == "AHuman" or entity.ClassName == "ACrab") and ToMOSRotating(entity).Buyable
				then
					entity = ToActor(entity)
					if entity:HasObjectInGroup("Brains") then
						CF_Brains[factionid] = entity.PresetName
						CF_BrainModules[factionid] = module.FileName
						CF_BrainClasses[factionid] = entity.ClassName
						CF_BrainPrices[factionid] = entity:GetGoldValue(0, 1, 1) * 5
					else
						i = #CF_ActNames[factionid] + 1
						CF_ActNames[factionid][i] = entity:GetModuleAndPresetName()
						CF_ActPresets[factionid][i] = entity.PresetName
						CF_ActModules[factionid][i] = module.FileName
						CF_ActPrices[factionid][i] = entity:GetGoldValue(0, 1, 1)
						CF_ActDescriptions[factionid][i] = entity.Description
						--Display stats?
						--	CF_ActDescriptions[factionid][i] =	"Weight = ".. math.floor(entity.Mass + 0.5)
						--									..	"\n Bullet resistance = ".. math.floor(entity:GetGibWoundLimit(true, false, false) + 0.5)
						--									..	"\n Impact resistance = ".. math.floor(entity.ImpulseDamageThreshold * 0.1 + entity.GibImpulseLimit * 0.05 + 0.5);
						CF_ActUnlockData[factionid][i] = CF_ActPrices[factionid][i] * 14
						CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
						CF_ActClasses[factionid][i] = entity.ClassName
						CF_ActOffsets[factionid][i] = entity.ClassName == "ACrab" and Vector(0, 12) or Vector()

						for group = 1, #actorGroups do
							if entity:HasObjectInGroup(actorGroups[group][1]) then
								CF_ActTypes[factionid][i] = actorGroups[group][2]
							end
						end
						CF_ActPowers[factionid][i] = math.ceil((CF_ActUnlockData[factionid][i] + 1) / 400)
						--Pick a starter actor, but always try to find the cheapest AHuman actor
						if
							not starterActor
							or (
								(
									CF_ActClasses[factionid][starterActor] ~= "AHuman"
									and CF_ActClasses[factionid][i] == "AHuman"
								)
								or (
									CF_ActClasses[factionid][starterActor] == CF_ActClasses[factionid][i]
									and CF_ActPrices[factionid][i] < CF_ActPrices[factionid][starterActor]
								)
							)
						then
							starterActor = i
							if
								entity.ClassName == "AHuman"
								and ToAHuman(entity).Head
								and string.find(ToAHuman(entity).Head.Material.PresetName, "Flesh")
							then
								CF_FactionNatures[factionid] = CF_FactionTypes.ORGANIC
							end
						end
					end
				end
			end
			if starterPrimary then
				CF_ItmUnlockData[factionid][starterPrimary] = 0
			end
			if starterSecondary then
				CF_ItmUnlockData[factionid][starterSecondary] = 0
			end
			if starterActor then
				CF_ActUnlockData[factionid][starterActor] = 0
			end
		else
			--print ("Failed to load faction files: "..factionid);
		end
	end
end
