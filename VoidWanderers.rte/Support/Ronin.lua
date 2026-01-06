-- Ronin faction support file for Void Wanderers

do
	-- Unique Faction ID
	local factionid = "Ronin"

	CF.Factions[#CF.Factions + 1] = factionid

	-- Faction name
	CF.FactionNames[factionid] = "Ronin"
	-- Faction description
	CF.FactionDescriptions[factionid] =
		"Rag-tag parties of bandits who prey on weak and unsuspecting explorers. Their soldiers are nigh unarmored and weapons prehistoric, but they manage to get the job done."
	-- Set true if faction is selectable by player or AI
	CF.FactionPlayable[factionid] = true
	-- Available values ORGANIC, SYNTHETIC
	CF.FactionNatures[factionid] = CF.FactionNatureTypes.ORGANIC

	-- Modules needed for this faction
	CF.RequiredModules[factionid] = { "Base.rte", "Ronin.rte" }

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.RIFLE }

	-- Define brain unit
	CF.BrainPresets[factionid] = "Commander"
	CF.BrainModules[factionid] = "Ronin.rte"
	CF.BrainClasses[factionid] = "AHuman"
	CF.BrainPrices[factionid] = 500

	-- Define dropship
	CF.CraftPresets[factionid] = "Rocket MK1"
	CF.CraftModules[factionid] = "Ronin.rte"
	CF.CraftClasses[factionid] = "ACRocket"
	CF.CraftPrices[factionid] = 500

	-- Define buyable actors available for purchase or unlocks
	CF.ActNames[factionid] = {}
	CF.ActPresets[factionid] = {}
	CF.ActModules[factionid] = {}
	CF.ActPrices[factionid] = {}
	CF.ActDescriptions[factionid] = {}
	CF.ActUnlockData[factionid] = {}
	CF.ActClasses[factionid] = {}
	CF.ActTypes[factionid] = {} -- CF.ActorTypes {LIGHT, HEAVY, ARMOR, TURRET}
	CF.ActPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 - toughest, 0 - never use
	CF.ActOffsets[factionid] = {}

	-- Available actor types
	local i = 0

	-- Faction actors
	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Bandit"
	CF.ActPresets[factionid][i] = "Bandit"
	CF.ActModules[factionid][i] = "Ronin.rte"
	CF.ActPrices[factionid][i] = 75
	CF.ActDescriptions[factionid][i] =
		"The Ronin infantry unit: a random rag-tag human soldier that is prone to injury. Comes equipped with a standard issue jetpack."
	CF.ActUnlockData[factionid][i] = 0
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
	CF.ActPowers[factionid][i] = 4

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Raider"
	CF.ActPresets[factionid][i] = "Raider"
	CF.ActModules[factionid][i] = "Ronin.rte"
	CF.ActPrices[factionid][i] = 90
	CF.ActDescriptions[factionid][i] =
		"A hefty Ronin soldier equipped with pieces of makeshift armor as protection."
	CF.ActUnlockData[factionid][i] = 1000
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
	CF.ActPowers[factionid][i] = 5


	-- Define buyable items available for purchase or unlocks
	CF.ItmNames[factionid] = {}
	CF.ItmPresets[factionid] = {}
	CF.ItmModules[factionid] = {}
	CF.ItmPrices[factionid] = {}
	CF.ItmDescriptions[factionid] = {}
	CF.ItmUnlockData[factionid] = {}
	CF.ItmClasses[factionid] = {}
	CF.ItmTypes[factionid] = {} -- CF.WeaponTypes {PISTOL, RIFLE, SHOTGUN, SNIPER, HEAVY, SHIELD, DIGGER, GRENADE}
	CF.ItmPowers[factionid] = {} -- 0 ~> don't use, 10 ~> use liberally

	local i = 0

	-- Faction items - Pistols
	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Desert Eagle"
	CF.ItmPresets[factionid][i] = "Desert Eagle"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 25
	CF.ItmDescriptions[factionid][i] =
		"This monster of a handgun requires strong arms in order to withstand the immense recoil."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "UZI"
	CF.ItmPresets[factionid][i] = "UZI"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 35
	CF.ItmDescriptions[factionid][i] =
		"Automatic sidearm with a high rate of fire and quick reload time."
	CF.ItmUnlockData[factionid][i] = 600
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 4

	-- Rifles
	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "AK-47"
	CF.ItmPresets[factionid][i] = "AK-47"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 40
	CF.ItmDescriptions[factionid][i] =
		"An old classic, simple design and cheap parts makes this gun a widespread design."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 4

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "M16A2"
	CF.ItmPresets[factionid][i] = "M16A2"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 50
	CF.ItmDescriptions[factionid][i] =
		"Accurate and deadly. Great standard weapon for your troops."
	CF.ItmUnlockData[factionid][i] = 700
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 5

	-- Sniper Rifles
	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Kar98k"
	CF.ItmPresets[factionid][i] = "Kar98k"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 80
	CF.ItmDescriptions[factionid][i] =
		"Long effective range and precision combined make this sniper rifle a deadly weapon."
	CF.ItmUnlockData[factionid][i] = 1200
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
	CF.ItmPowers[factionid][i] = 5

	-- Heavy Weapons
	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "M60"
	CF.ItmPresets[factionid][i] = "M60"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 100
	CF.ItmDescriptions[factionid][i] =
		"The most fearsome machine gun the Ronin have to offer. Its sheer firepower is offset only by its poor accuracy."
	CF.ItmUnlockData[factionid][i] = 1800
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 7

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "RPG-7"
	CF.ItmPresets[factionid][i] = "RPG-7"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 150
	CF.ItmDescriptions[factionid][i] =
		"Powerful and feared weapon in the Ronin arsenal. Fires accelerating rockets that cause massive damage with a direct hit."
	CF.ItmUnlockData[factionid][i] = 2500
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 8

	-- Tools
	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Chainsaw"
	CF.ItmPresets[factionid][i] = "Chainsaw"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 10
	CF.ItmDescriptions[factionid][i] =
		"Normally intended for cutting lumber, this tool has been repurposed to be used on flesh, light metal and whatever else that needs to be violently dismantled."
	CF.ItmUnlockData[factionid][i] = 500
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
	CF.ItmPowers[factionid][i] = 2

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Shovel"
	CF.ItmPresets[factionid][i] = "Shovel"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 3
	CF.ItmDescriptions[factionid][i] =
		"Ronin's tunneling and bashing device #1! Turn gathered dirt into sandbags using the Pie Menu."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
	CF.ItmPowers[factionid][i] = 1

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Medical Dart Gun"
	CF.ItmPresets[factionid][i] = "Medical Dart Gun"
	CF.ItmModules[factionid][i] = "Ronin.rte"
	CF.ItmPrices[factionid][i] = 25
	CF.ItmDescriptions[factionid][i] =
		"A remote healing device for organic targets. Aim at friendlies! Make sure they aren't too weak though, so that the shot doesn't kill them."
	CF.ItmUnlockData[factionid][i] = 800
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.TOOL
	CF.ItmPowers[factionid][i] = 0

	-- Base actors and items (automatic stuff, no need to change these unless you want to)

	local baseActors = {
		{ presetName = "Medic Drone", class = "ACrab", unlockData = 1000, actorPowers = 0 }
	}

	for j = 1, #baseActors do
		local actor
		i = #CF.ActNames[factionid] + 1

		if baseActors[j].class == "ACrab" then
			actor = CreateACrab(baseActors[j].presetName, "Base.rte")
			CF.ActTypes[factionid][i] = CF.ActorTypes.ARMOR
			CF.ActOffsets[factionid][i] = Vector(0, 12)
		elseif baseActors[j].class == "AHuman" then
			actor = CreateAHuman(baseActors[j].presetName, "Base.rte")
			CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
		end

		if actor then
			CF.ActNames[factionid][i] = actor.PresetName
			CF.ActPresets[factionid][i] = actor.PresetName
			CF.ActModules[factionid][i] = "Base.rte"
			CF.ActPrices[factionid][i] = actor:GetGoldValue(0, 1, 1)
			CF.ActDescriptions[factionid][i] = actor.Description

			CF.ActUnlockData[factionid][i] = baseActors[j].unlockData
			CF.ActPowers[factionid][i] = baseActors[j].actorPowers
			CF.ActClasses[factionid][i] = actor.ClassName
			DeleteEntity(actor)
		end
	end

	local baseItems = {
		{ presetName = "Remote Explosive", class = "TDExplosive", unlockData = 500, itemPowers = 0 },
		{ presetName = "Anti Personnel Mine", class = "TDExplosive", unlockData = 900, itemPowers = 0 },
		{ presetName = "Light Digger", class = "HDFirearm", unlockData = 0, itemPowers = 1, weaponType = CF.WeaponTypes.DIGGER },
		{ presetName = "Medium Digger", class = "HDFirearm", unlockData = 600, itemPowers = 3, weaponType = CF.WeaponTypes.DIGGER },
		{ presetName = "Heavy Digger", class = "HDFirearm", unlockData = 1200, itemPowers = 5, weaponType = CF.WeaponTypes.DIGGER },
		{ presetName = "Detonator", class = "HDFirearm", unlockData = 500, itemPowers = 0 },
		{ presetName = "Grapple Gun", class = "HDFirearm", unlockData = 1100, itemPowers = 0 },
		{ presetName = "Medikit", class = "HDFirearm", unlockData = 700, itemPowers = 3 },
		{ presetName = "Disarmer", class = "HDFirearm", unlockData = 900, itemPowers = 0 },
		{ presetName = "Constructor", class = "HDFirearm", unlockData = 1000, itemPowers = 0 },
		{ presetName = "Scanner", class = "HDFirearm", unlockData = 600, itemPowers = 0 },
		{ presetName = "Riot Shield", class = "HeldDevice", unlockData = 500, itemPowers = 1 }
	}

	for j = 1, #baseItems do
		local item
		i = #CF.ItmNames[factionid] + 1

		if baseItems[j].class == "TDExplosive" then
			item = CreateTDExplosive(baseItems[j].presetName, "Base.rte")
			CF.ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF.WeaponTypes.GRENADE
		elseif baseItems[j].class == "HDFirearm" then
			item = CreateHDFirearm(baseItems[j].presetName, "Base.rte")
			CF.ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF.WeaponTypes.TOOL
		elseif baseItems[j].class == "HeldDevice" then
			item = CreateHeldDevice(baseItems[j].presetName, "Base.rte")
			CF.ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF.WeaponTypes.SHIELD
		end

		if item then
			CF.ItmNames[factionid][i] = item.PresetName
			CF.ItmPresets[factionid][i] = item.PresetName
			CF.ItmModules[factionid][i] = "Base.rte"
			CF.ItmPrices[factionid][i] = item:GetGoldValue(0, 1, 1)
			CF.ItmDescriptions[factionid][i] = item.Description
			CF.ItmClasses[factionid][i] = item.ClassName

			CF.ItmUnlockData[factionid][i] = baseItems[j].unlockData
			CF.ItmPowers[factionid][i] = baseItems[j].itemPowers
			DeleteEntity(item)
		end
	end
end