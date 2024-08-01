local weaponGroups = {
	{ "Weapons - Light", CF["WeaponTypes"].RIFLE },
	{ "Weapons - Heavy", CF["WeaponTypes"].HEAVY },
	{ "Weapons - Sniper", CF["WeaponTypes"].SNIPER },
	{ "Weapons - Shotguns", CF["WeaponTypes"].SHOTGUN },
	{ "Weapons - Secondary", CF["WeaponTypes"].PISTOL },
	{ "Weapons - Melee", CF["WeaponTypes"].PISTOL }, -- Force melee weapons as "Secondary" but not as starter secondary
	{ "Tools", CF["WeaponTypes"].TOOL },
	{ "Tools - Diggers", CF["WeaponTypes"].DIGGER },
	{ "Shields", CF["WeaponTypes"].SHIELD },
	{ "Bombs", CF["WeaponTypes"].GRENADE },
	{ "Bombs - Grenades", CF["WeaponTypes"].GRENADE },
}
local actorGroups = {
	{ "Actors - Light", CF["ActorTypes"].LIGHT },
	{ "Actors - Heavy", CF["ActorTypes"].HEAVY },
	{ "Actors - Mecha", CF["ActorTypes"].ARMOR },
	{ "Actors - Turrets", CF["ActorTypes"].TURRET },
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
	weaponType = CF["WeaponTypes"].DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Medium Digger",
	class = "HDFirearm",
	unlockData = 600,
	itemPowers = 3,
	weaponType = CF["WeaponTypes"].DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Heavy Digger",
	class = "HDFirearm",
	unlockData = 1200,
	itemPowers = 5,
	weaponType = CF["WeaponTypes"].DIGGER,
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
		local pathSupport = CF["ModuleName"] .. "/Support/" .. string.gsub(module.FileName, ".rte", ".lua")
		if CF["IsFilePathExists"](pathNative) then
			print("Loading native faction file: " .. factionid)
			dofile(pathNative)
		elseif CF["IsFilePathExists"](pathSupport) then
			print("Loading supported faction file: " .. factionid)
			dofile(pathSupport)
		elseif module.FileName ~= CF["ModuleName"] and module.IsFaction then
			print("Autoloading: " .. factionid)

			CF["Factions"][#CF["Factions"] + 1] = factionid
			CF["FactionNames"][factionid] = module.FriendlyName
			CF["FactionDescriptions"][factionid] = module.Description and module.Description or "DESCRIPTION UNAVAILABLE"
			-- Set true if faction is selectable by player or AI
			CF["FactionPlayable"][factionid] = true
			CF["RequiredModules"][factionid] = { "Base.rte", module.FileName }
			-- Available values ORGANIC, SYNTHETIC
			CF["FactionNatures"][factionid] = CF["FactionTypes"].SYNTHETIC
			-- Percentage of troops sent to brainhunt or attack player LZ when AI is defending (default - CF["DefaultBrainHuntRatio"])
			-- If this value is less then default then faction is marked as Defensive if it's more, then as Offensive
			CF["BrainHuntRatios"][factionid] = 40
			-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
			CF["PreferedBrainInventory"][factionid] = { CF["WeaponTypes"].DIGGER, CF["WeaponTypes"].RIFLE }
			-- Define brain unit
			CF["Brains"][factionid] = "Brain Robot"
			CF["BrainModules"][factionid] = "Base.rte"
			CF["BrainClasses"][factionid] = "AHuman"
			CF["BrainPrices"][factionid] = 500
			-- Define dropship
			CF["Crafts"][factionid] = "Dropship MK1"
			CF["CraftModules"][factionid] = "Base.rte"
			CF["CraftClasses"][factionid] = "ACDropShip"
			CF["CraftPrices"][factionid] = 500
			-- Define buyable actors available for purchase or unlocks
			CF["ActNames"][factionid] = {}
			CF["ActPresets"][factionid] = {}
			CF["ActModules"][factionid] = {}
			CF["ActPrices"][factionid] = {}
			CF["ActDescriptions"][factionid] = {}
			CF["ActUnlockData"][factionid] = {}
			CF["ActClasses"][factionid] = {}
			CF["ActTypes"][factionid] = {} -- AI will select different weapons based on this value
			CF["ActPowers"][factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use
			CF["ActOffsets"][factionid] = {}
			-- Define buyable items available for purchase or unlocks
			CF["ItmNames"][factionid] = {}
			CF["ItmPresets"][factionid] = {}
			CF["ItmModules"][factionid] = {}
			CF["ItmPrices"][factionid] = {}
			CF["ItmDescriptions"][factionid] = {}
			CF["ItmUnlockData"][factionid] = {}
			CF["ItmClasses"][factionid] = {}
			CF["ItmTypes"][factionid] = {}
			CF["ItmPowers"][factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use
			local i = 0
			local starterPrimary, starterSecondary, starterActor
			-- Add so-called "basic" actors and items from Base.rte
			for j = 1, #baseActors do
				local actor
				i = #CF["ActNames"][factionid] + 1
				if baseActors[j].class == "ACrab" then
					actor = CreateACrab(baseActors[j].presetName, "Base.rte")
					CF["ActTypes"][factionid][i] = CF["ActorTypes"].ARMOR
					CF["ActOffsets"][factionid][i] = Vector(0, 12)
				elseif baseActors[j].class == "AHuman" then
					actor = CreateAHuman(baseActors[j].presetName, "Base.rte")
					CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
				end
				if actor then
					CF["ActNames"][factionid][i] = actor.PresetName
					CF["ActPresets"][factionid][i] = actor.PresetName
					CF["ActModules"][factionid][i] = "Base.rte"
					CF["ActPrices"][factionid][i] = actor:GetGoldValue(0, 1, 1)
					CF["ActDescriptions"][factionid][i] = actor.Description

					CF["ActUnlockData"][factionid][i] = baseActors[j].unlockData
					CF["ActPowers"][factionid][i] = baseActors[j].actorPowers
					CF["ActClasses"][factionid][i] = actor.ClassName
					DeleteEntity(actor)
				end
			end
			for j = 1, #baseItems do
				local item
				i = #CF["ItmNames"][factionid] + 1
				if baseItems[j].class == "TDExplosive" then
					item = CreateTDExplosive(baseItems[j].presetName, "Base.rte")
					CF["ItmTypes"][factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType
						or CF["WeaponTypes"].GRENADE
				elseif baseItems[j].class == "HDFirearm" then
					item = CreateHDFirearm(baseItems[j].presetName, "Base.rte")
					CF["ItmTypes"][factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType
						or CF["WeaponTypes"].TOOL
				elseif baseItems[j].class == "HeldDevice" then
					item = CreateHeldDevice(baseItems[j].presetName, "Base.rte")
					CF["ItmTypes"][factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType
						or CF["WeaponTypes"].SHIELD
				end
				if item then
					CF["ItmNames"][factionid][i] = item.PresetName
					CF["ItmPresets"][factionid][i] = item.PresetName
					CF["ItmModules"][factionid][i] = "Base.rte"
					CF["ItmPrices"][factionid][i] = item:GetGoldValue(0, 1, 1)
					CF["ItmDescriptions"][factionid][i] = item.Description
					CF["ItmClasses"][factionid][i] = item.ClassName

					CF["ItmUnlockData"][factionid][i] = baseItems[j].unlockData
					CF["ItmPowers"][factionid][i] = baseItems[j].itemPowers
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
						local n = #CF["BombNames"] + 1
						CF["BombNames"][n] = entity:GetModuleAndPresetName()
						CF["BombPresets"][n] = entity.PresetName
						CF["BombModules"][n] = module.FileName
						CF["BombClasses"][n] = entity.ClassName
						CF["BombPrices"][n] = entity:GetGoldValue(0, 1, 1)
						CF["BombDescriptions"][n] = entity.Description
						CF["BombOwnerFactions"][n] = { factionid }
						CF["BombUnlockData"][n] = CF["BombPrices"][n] * 16
					else
						i = #CF["ItmNames"][factionid] + 1
						CF["ItmNames"][factionid][i] = entity:GetModuleAndPresetName()
						CF["ItmPresets"][factionid][i] = entity.PresetName
						CF["ItmModules"][factionid][i] = module.FileName
						CF["ItmPrices"][factionid][i] = entity:GetGoldValue(0, 1, 1)
						CF["ItmDescriptions"][factionid][i] = entity.Description
						--[[CF["ItmDescriptions"][factionid][i] = 	"Weight = ".. math.floor(entity.Mass + 0.5)
														..	"\n Durability = ".. entity.GibWoundLimit;]]
						--
						CF["ItmUnlockData"][factionid][i] = CF["ItmPrices"][factionid][i] * 18
						CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE --Default setting

						CF["ItmClasses"][factionid][i] = entity.ClassName

						for group = 1, #weaponGroups do
							if entity:HasObjectInGroup(weaponGroups[group][1]) then
								CF["ItmTypes"][factionid][i] = weaponGroups[group][2]
							end
						end
						if IsHDFirearm(entity) then
							entity = ToHDFirearm(entity)
							--Force set onehanded weapons to be secondary?
							--	if entity:IsOneHanded() then
							--		CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].PISTOL;
							--	end
							--Display stats?
							--	local fireRate = entity.RateOfFire > 3600 and "Maximum" or "".. entity.RateOfFire;
							--	local ammoCap = entity.RoundInMagCount > 0 and "\n Ammo capacity = ".. entity.RoundInMagCount or "";
							--	CF["ItmDescriptions"][factionid][i] = CF["ItmDescriptions"][factionid][i] .."\n Rate of Fire = ".. fireRate .."".. ammoCap

							--Secondary weapons require more data because they're cheap already
							if entity:HasObjectInGroup("Weapons - Secondary") then
								CF["ItmUnlockData"][factionid][i] = CF["ItmUnlockData"][factionid][i] * 1.8
							end
							if entity:HasObjectInGroup("Weapons - Explosive") then
								CF["ItmUnlockData"][factionid][i] = CF["ItmUnlockData"][factionid][i] * 1.1
							end
							if entity.FullAuto then
								CF["ItmUnlockData"][factionid][i] = CF["ItmUnlockData"][factionid][i] * 1.1
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
								CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].SHOTGUN
							end
						elseif IsTDExplosive(entity) then
							--Bombs/grenades also require more data because they're cheap already
							if entity:HasObjectInGroup("Bombs") then
								CF["ItmUnlockData"][factionid][i] = CF["ItmUnlockData"][factionid][i] * 1.8
							end
							entity = ToTDExplosive(entity)
							CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
							--CF["ItmDescriptions"][factionid][i] = CF["ItmDescriptions"][factionid][i] .."\n Throw distance = ".. entity.MinThrowVel .."-".. entity.MaxThrowVel;
						end
						CF["ItmPowers"][factionid][i] = math.ceil((CF["ItmUnlockData"][factionid][i] + 1) / 250)
						CF["ItmUnlockData"][factionid][i] = math.floor(CF["ItmUnlockData"][factionid][i] + 0.5)
						--ConsoleMan:PrintString(entity.PresetName .. " Data: " .. CF["ItmUnlockData"][factionid][i] .. ", Powers: " .. CF["ItmPowers"][factionid][i]);

						if
							not starterPrimary
							or (
								(
									CF["ItmTypes"][factionid][starterPrimary] ~= CF["WeaponTypes"].RIFLE
									and CF["ItmTypes"][factionid][i] == CF["WeaponTypes"].RIFLE
								)
								or (
									CF["ItmTypes"][factionid][starterPrimary] == CF["ItmTypes"][factionid][i]
									and CF["ItmPrices"][factionid][i] < CF["ItmPrices"][factionid][starterPrimary]
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
										CF["ItmTypes"][factionid][starterSecondary] ~= CF["WeaponTypes"].PISTOL
										and CF["ItmTypes"][factionid][i] == CF["WeaponTypes"].PISTOL
									)
									or (
										CF["ItmTypes"][factionid][starterSecondary] == CF["ItmTypes"][factionid][i]
										and CF["ItmPrices"][factionid][i] < CF["ItmPrices"][factionid][starterSecondary]
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
						CF["Brains"][factionid] = entity.PresetName
						CF["BrainModules"][factionid] = module.FileName
						CF["BrainClasses"][factionid] = entity.ClassName
						CF["BrainPrices"][factionid] = entity:GetGoldValue(0, 1, 1) * 5
					else
						i = #CF["ActNames"][factionid] + 1
						CF["ActNames"][factionid][i] = entity:GetModuleAndPresetName()
						CF["ActPresets"][factionid][i] = entity.PresetName
						CF["ActModules"][factionid][i] = module.FileName
						CF["ActPrices"][factionid][i] = entity:GetGoldValue(0, 1, 1)
						CF["ActDescriptions"][factionid][i] = entity.Description
						--Display stats?
						--	CF["ActDescriptions"][factionid][i] =	"Weight = ".. math.floor(entity.Mass + 0.5)
						--									..	"\n Bullet resistance = ".. math.floor(entity:GetGibWoundLimit(true, false, false) + 0.5)
						--									..	"\n Impact resistance = ".. math.floor(entity.ImpulseDamageThreshold * 0.1 + entity.GibImpulseLimit * 0.05 + 0.5);
						CF["ActUnlockData"][factionid][i] = CF["ActPrices"][factionid][i] * 14
						CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
						CF["ActClasses"][factionid][i] = entity.ClassName
						CF["ActOffsets"][factionid][i] = entity.ClassName == "ACrab" and Vector(0, 12) or Vector()

						for group = 1, #actorGroups do
							if entity:HasObjectInGroup(actorGroups[group][1]) then
								CF["ActTypes"][factionid][i] = actorGroups[group][2]
							end
						end
						CF["ActPowers"][factionid][i] = math.ceil((CF["ActUnlockData"][factionid][i] + 1) / 400)
						--Pick a starter actor, but always try to find the cheapest AHuman actor
						if
							not starterActor
							or (
								(
									CF["ActClasses"][factionid][starterActor] ~= "AHuman"
									and CF["ActClasses"][factionid][i] == "AHuman"
								)
								or (
									CF["ActClasses"][factionid][starterActor] == CF["ActClasses"][factionid][i]
									and CF["ActPrices"][factionid][i] < CF["ActPrices"][factionid][starterActor]
								)
							)
						then
							starterActor = i
							if
								entity.ClassName == "AHuman"
								and ToAHuman(entity).Head
								and string.find(ToAHuman(entity).Head.Material.PresetName, "Flesh")
							then
								CF["FactionNatures"][factionid] = CF["FactionTypes"].ORGANIC
							end
						end
					end
				end
			end
			if starterPrimary then
				CF["ItmUnlockData"][factionid][starterPrimary] = 0
			end
			if starterSecondary then
				CF["ItmUnlockData"][factionid][starterSecondary] = 0
			end
			if starterActor then
				CF["ActUnlockData"][factionid][starterActor] = 0
			end
		else
			--print ("Failed to load faction files: "..factionid);
		end
	end
end
