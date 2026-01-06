-- Uzira faction support file for Void Wanderers

do
	-- Unique Faction ID
	local factionid = "Uzira"

	CF.Factions[#CF.Factions + 1] = factionid

	-- Faction name
	CF.FactionNames[factionid] = "Uzira"
	-- Faction description
	CF.FactionDescriptions[factionid] =
		"Uzira, one of the early explorers and ruler of the undead, has awoken from her cryo-sleep. Clad in powerful armour, she commands an endless army of skeletons with antique guns."
	-- Set true if faction is selectable by player or AI
	CF.FactionPlayable[factionid] = true
	-- Available values ORGANIC, SYNTHETIC
	CF.FactionNatures[factionid] = CF.FactionNatureTypes.ORGANIC

	-- Modules needed for this faction
	CF.RequiredModules[factionid] = { "Base.rte", "Uzira.rte" }

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.SHOTGUN }

	-- Define brain unit
	CF.BrainPresets[factionid] = "Uzira"
	CF.BrainModules[factionid] = "Uzira.rte"
	CF.BrainClasses[factionid] = "AHuman"
	CF.BrainPrices[factionid] = 500

	-- Define dropship
	CF.CraftPresets[factionid] = "Dropship MK1"
	CF.CraftModules[factionid] = "Base.rte"
	CF.CraftClasses[factionid] = "ACDropShip"
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
	CF.ActNames[factionid][i] = "Culled Clone"
	CF.ActPresets[factionid][i] = "Culled Clone"
	CF.ActModules[factionid][i] = "Uzira.rte"
	CF.ActPrices[factionid][i] = 25
	CF.ActDescriptions[factionid][i] =
		"A half-baked clone, rejected because of various flaws from the production plant and sold at a discount without jetpack and armor. Very effective in large groups armed with cheap weapons."
	CF.ActUnlockData[factionid][i] = 0
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
	CF.ActPowers[factionid][i] = 3

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Thin Culled Clone"
	CF.ActPresets[factionid][i] = "Thin Culled Clone"
	CF.ActModules[factionid][i] = "Uzira.rte"
	CF.ActPrices[factionid][i] = 25
	CF.ActDescriptions[factionid][i] =
		"A thin half-baked clone, rejected because of various flaws from the production plant and sold at a discount without jetpack and armor. Faster than standard clones."
	CF.ActUnlockData[factionid][i] = 0
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
	CF.ActPowers[factionid][i] = 3

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Fat Culled Clone"
	CF.ActPresets[factionid][i] = "Fat Culled Clone"
	CF.ActModules[factionid][i] = "Uzira.rte"
	CF.ActPrices[factionid][i] = 30
	CF.ActDescriptions[factionid][i] =
		"A fat, slow half-baked clone, rejected because of various flaws from the production plant and sold at a discount without jetpack and armor. More durable than standard clones."
	CF.ActUnlockData[factionid][i] = 500
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
	CF.ActPowers[factionid][i] = 4


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

	-- Faction items
	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Blunderpop"
	CF.ItmPresets[factionid][i] = "Blunderpop"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 5
	CF.ItmDescriptions[factionid][i] =
		"Smaller version of the mighty blunderbuss. It has shorter range, but the fast reload time and large spread make it a great sidearm."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 2

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Blunderbuss"
	CF.ItmPresets[factionid][i] = "Blunderbuss"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 15
	CF.ItmDescriptions[factionid][i] =
		"Single shot shotgun. Features large spread and power, but must be reloaded after each shot."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
	CF.ItmPowers[factionid][i] = 4

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Musket"
	CF.ItmPresets[factionid][i] = "Musket"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 20
	CF.ItmDescriptions[factionid][i] =
		"Single shot rifle. Features lower spread and longer range than the Blunderbuss."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Crossbow"
	CF.ItmPresets[factionid][i] = "Crossbow"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 25
	CF.ItmDescriptions[factionid][i] =
		"This thing is ancient, but it oughta hurt!"
	CF.ItmUnlockData[factionid][i] = 600
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
	CF.ItmPowers[factionid][i] = 4

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Boomstick"
	CF.ItmPresets[factionid][i] = "Boomstick"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 40
	CF.ItmDescriptions[factionid][i] =
		"Single shot handheld mortar. Aim it well!"
	CF.ItmUnlockData[factionid][i] = 1000
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Buckler"
	CF.ItmPresets[factionid][i] = "Buckler"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 10
	CF.ItmDescriptions[factionid][i] =
		"An antiquated, but surprisingly effective shield. Great for keeping your skeletal armies safely undead, instead of just dead!"
	CF.ItmUnlockData[factionid][i] = 500
	CF.ItmClasses[factionid][i] = "HeldDevice"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Spade"
	CF.ItmPresets[factionid][i] = "Spade"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 3
	CF.ItmDescriptions[factionid][i] =
		"You'll only be digging your own grave!"
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
	CF.ItmPowers[factionid][i] = 1

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Blue Bomb Bandolier"
	CF.ItmPresets[factionid][i] = "Blue Bomb Bandolier"
	CF.ItmModules[factionid][i] = "Uzira.rte"
	CF.ItmPrices[factionid][i] = 10
	CF.ItmDescriptions[factionid][i] =
		"A bountiful bundle of beautiful, blue bombs!"
	CF.ItmUnlockData[factionid][i] = 500
	CF.ItmClasses[factionid][i] = "TDExplosive"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
	CF.ItmPowers[factionid][i] = 2

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