-- Browncoats faction support file for Void Wanderers

do
	-- Unique Faction ID
	local factionid = "Browncoats"

	CF.Factions[#CF.Factions + 1] = factionid

	-- Faction name
	CF.FactionNames[factionid] = "Browncoats"
	-- Faction description
	CF.FactionDescriptions[factionid] =
		"A strong mercenary group who are fearsome when confronted up-close. What they lack in range is made up for in durability, allowing them to close distances while soaking bullets."
	-- Set true if faction is selectable by player or AI
	CF.FactionPlayable[factionid] = true
	-- Available values ORGANIC, SYNTHETIC
	CF.FactionNatures[factionid] = CF.FactionNatureTypes.ORGANIC

	-- Modules needed for this faction
	CF.RequiredModules[factionid] = { "Base.rte", "Browncoats.rte" }

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.SHOTGUN, CF.WeaponTypes.HEAVY }

	-- Define brain unit
	CF.BrainPresets[factionid] = "Brain Robot"
	CF.BrainModules[factionid] = "Base.rte"
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
	CF.ActNames[factionid][i] = "Browncoat"
	CF.ActPresets[factionid][i] = "Browncoat"
	CF.ActModules[factionid][i] = "Browncoats.rte"
	CF.ActPrices[factionid][i] = 170
	CF.ActDescriptions[factionid][i] =
		"Well-padded underneath its tough yet fairly lightweight coat, this unit's durability and speed makes it a dangerous lightning-bruiser."
	CF.ActUnlockData[factionid][i] = 0
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
	CF.ActPowers[factionid][i] = 6

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Exterminator"
	CF.ActPresets[factionid][i] = "Exterminator"
	CF.ActModules[factionid][i] = "Browncoats.rte"
	CF.ActPrices[factionid][i] = 190
	CF.ActDescriptions[factionid][i] =
		"Though slow, this massively powerful unit can shrug off damage that would incapacitate or kill the average soldier."
	CF.ActUnlockData[factionid][i] = 1500
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
	CF.ActPowers[factionid][i] = 7

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Browncoat Boss"
	CF.ActPresets[factionid][i] = "Browncoat Boss"
	CF.ActModules[factionid][i] = "Browncoats.rte"
	CF.ActPrices[factionid][i] = 280
	CF.ActDescriptions[factionid][i] =
		"A baron in his heaviest kit. This veritable super-weight browncoat can take and dish punishment to rival purpose-built metal dreadnoughts."
	CF.ActUnlockData[factionid][i] = 3000
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
	CF.ActPowers[factionid][i] = 9


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
	CF.ItmNames[factionid][i] = "HG-10 Stinger"
	CF.ItmPresets[factionid][i] = "HG-10 Stinger"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 25
	CF.ItmDescriptions[factionid][i] =
		"Compact with a high rate of fire, this handgun can also function as a primary weapon."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "AR-25 Hammerfist"
	CF.ItmPresets[factionid][i] = "AR-25 Hammerfist"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 60
	CF.ItmDescriptions[factionid][i] =
		"A sturdy, powerful assault rifle with a 25-round magazine and incendiary tracer rounds."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "BR-76 Stormbringer"
	CF.ItmPresets[factionid][i] = "BR-76 Stormbringer"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 80
	CF.ItmDescriptions[factionid][i] =
		"A CQC fully-automatic battle rifle. Packs a ridiculous wallop, but too inaccurate for regular battle rifle usage."
	CF.ItmUnlockData[factionid][i] = 1200
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 6

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "SG-10 Jackhammer"
	CF.ItmPresets[factionid][i] = "SG-10 Jackhammer"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 70
	CF.ItmDescriptions[factionid][i] =
		"A fierce fully-automatic shotgun. Each magazine starts off with a special 'Dragon's Breath' shell to instill fear in the opponent."
	CF.ItmUnlockData[factionid][i] = 800
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
	CF.ItmPowers[factionid][i] = 6

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "IN-02 Backblast"
	CF.ItmPresets[factionid][i] = "IN-02 Backblast"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 70
	CF.ItmDescriptions[factionid][i] =
		"This incendiary shotgun fires two consecutive blasts of searing hot metallic pellets, tailed with a burst of flammable chemical compounds."
	CF.ItmUnlockData[factionid][i] = 1000
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "PY-07 Trailblazer"
	CF.ItmPresets[factionid][i] = "PY-07 Trailblazer"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 100
	CF.ItmDescriptions[factionid][i] =
		"This pyro-rifle can both burn and pierce enemies at a moderate distance with its blazing bullets."
	CF.ItmUnlockData[factionid][i] = 1500
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "RS-04 Eruptor"
	CF.ItmPresets[factionid][i] = "RS-04 Eruptor"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 45
	CF.ItmDescriptions[factionid][i] =
		"Ballistic shield with reactive-explosive armor plates stuck to the front. Any blow delivered to them will launch hot shrapnel right back at the attacker."
	CF.ItmUnlockData[factionid][i] = 900
	CF.ItmClasses[factionid][i] = "HeldDevice"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
	CF.ItmPowers[factionid][i] = 4

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "DG-1000 Blowtorch"
	CF.ItmPresets[factionid][i] = "DG-1000 Blowtorch"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 80
	CF.ItmDescriptions[factionid][i] =
		"Incredibly light but powerful digging device. Not the best at collecting gold, but excellent for breaching bunkers."
	CF.ItmUnlockData[factionid][i] = 600
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Fire Bomb Bandolier"
	CF.ItmPresets[factionid][i] = "Fire Bomb Bandolier"
	CF.ItmModules[factionid][i] = "Browncoats.rte"
	CF.ItmPrices[factionid][i] = 15
	CF.ItmDescriptions[factionid][i] =
		"A bundle of canisters that, when thrown, will burst into flames in 3 seconds and burn for 10 seconds."
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