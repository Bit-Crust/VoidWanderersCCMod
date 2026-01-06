-- Imperatus faction support file for Void Wanderers

do
	-- Unique Faction ID
	local factionid = "Imperatus"

	CF.Factions[#CF.Factions + 1] = factionid

	-- Faction name
	CF.FactionNames[factionid] = "Imperatus"
	-- Faction description
	CF.FactionDescriptions[factionid] =
		"The Imperatus rely on pure brute force and the reliability of their sturdy and easy to produce armored units. They use simple low rate of fire guns and cannons which tirelessly deals out good damage."
	-- Set true if faction is selectable by player or AI
	CF.FactionPlayable[factionid] = true
	-- Available values ORGANIC, SYNTHETIC
	CF.FactionNatures[factionid] = CF.FactionNatureTypes.SYNTHETIC

	-- Modules needed for this faction
	CF.RequiredModules[factionid] = { "Base.rte", "Imperatus.rte" }

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.RIFLE }

	-- Define brain unit
	CF.BrainPresets[factionid] = "Imperatus Brain Robot"
	CF.BrainModules[factionid] = "Imperatus.rte"
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
	CF.ActNames[factionid][i] = "All Purpose Robot"
	CF.ActPresets[factionid][i] = "All Purpose Robot"
	CF.ActModules[factionid][i] = "Imperatus.rte"
	CF.ActPrices[factionid][i] = 150
	CF.ActDescriptions[factionid][i] =
		"Standard all-purpose Imperatus frame, both mobile and durable."
	CF.ActUnlockData[factionid][i] = 0
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
	CF.ActPowers[factionid][i] = 5

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Combat Robot"
	CF.ActPresets[factionid][i] = "Combat Robot"
	CF.ActModules[factionid][i] = "Imperatus.rte"
	CF.ActPrices[factionid][i] = 200
	CF.ActDescriptions[factionid][i] =
		"A stronger version of the All Purpose Robot. This Imperatus frame is a walking tank, capable of withstanding heavy fire without shutting down."
	CF.ActUnlockData[factionid][i] = 2000
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
	CF.ActPowers[factionid][i] = 7


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
	CF.ItmNames[factionid][i] = "Chunker SP-44"
	CF.ItmPresets[factionid][i] = "Chunker SP-44"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 25
	CF.ItmDescriptions[factionid][i] =
		"All (or at least most of) the power of a shotgun crammed into a pistol. Excellent for short-range targets."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Slugger GP-03"
	CF.ItmPresets[factionid][i] = "Slugger GP-03"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 30
	CF.ItmDescriptions[factionid][i] =
		"Some refer to the Desert Eagle as a 'handcannon,' but the Slugger is far more deserving of the nickname. Firing tiny grenades instead of bullets, this pistol packs some serious power."
	CF.ItmUnlockData[factionid][i] = 700
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 4

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Bullpup AR-14"
	CF.ItmPresets[factionid][i] = "Bullpup AR-14"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 65
	CF.ItmDescriptions[factionid][i] =
		"Backbone of every Imperatus armored platoon, a nice heavy 8.2x45mm round that penetrates armored targets with ease."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Mauler SG-23"
	CF.ItmPresets[factionid][i] = "Mauler SG-23"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 90
	CF.ItmDescriptions[factionid][i] =
		"An unbelievably powerful shotgun which takes the term 'chaingun' seriously by literally firing melting hot metal chain links at your enemies."
	CF.ItmUnlockData[factionid][i] = 1300
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
	CF.ItmPowers[factionid][i] = 6

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Marauder CN-05"
	CF.ItmPresets[factionid][i] = "Marauder CN-05"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 120
	CF.ItmDescriptions[factionid][i] =
		"A brutal and powerful revolver cannon. Launches heavy slugs at high velocities that smash the living hell out of their targets."
	CF.ItmUnlockData[factionid][i] = 1800
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 7

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Banshee HSR-02"
	CF.ItmPresets[factionid][i] = "Banshee HSR-02"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 130
	CF.ItmDescriptions[factionid][i] =
		"The sniper rifle's big brother. You only get four rounds to a mag, but why settle for a headshot when you can blow the entire body apart?"
	CF.ItmUnlockData[factionid][i] = 2200
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
	CF.ItmPowers[factionid][i] = 7

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Bulldog GG-49"
	CF.ItmPresets[factionid][i] = "Bulldog GG-49"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 140
	CF.ItmDescriptions[factionid][i] =
		"Slow-firing, but incredibly powerful, this gatling gun is sure to destroy your opponents."
	CF.ItmUnlockData[factionid][i] = 2500
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 8

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Devastator CN-72"
	CF.ItmPresets[factionid][i] = "Devastator CN-72"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 140
	CF.ItmDescriptions[factionid][i] =
		"A devastating anti-air weapon that can take out a dropship from a distance easily. The proximity fuse on the flak shells ensures maximum effectiveness."
	CF.ItmUnlockData[factionid][i] = 2800
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 7

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Shredder SB-08 Bandolier"
	CF.ItmPresets[factionid][i] = "Shredder SB-08 Bandolier"
	CF.ItmModules[factionid][i] = "Imperatus.rte"
	CF.ItmPrices[factionid][i] = 35
	CF.ItmDescriptions[factionid][i] =
		"A pack of grenades that explode into 8 smaller bomblets, which detonate after a short delay."
	CF.ItmUnlockData[factionid][i] = 900
	CF.ItmClasses[factionid][i] = "TDExplosive"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
	CF.ItmPowers[factionid][i] = 3

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