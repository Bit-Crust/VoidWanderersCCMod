-- Techion faction support file for Void Wanderers

do
	-- Unique Faction ID
	local factionid = "Techion"

	CF.Factions[#CF.Factions + 1] = factionid

	-- Faction name
	CF.FactionNames[factionid] = "Techion"
	-- Faction description
	CF.FactionDescriptions[factionid] =
		"The Techion were formed by a small group of elite corporations focusing on high-tech research and manufacture. They are sometimes employed and trusted by the TradeStars to do guard and escort duty."
	-- Set true if faction is selectable by player or AI
	CF.FactionPlayable[factionid] = true
	-- Available values ORGANIC, SYNTHETIC
	CF.FactionNatures[factionid] = CF.FactionNatureTypes.SYNTHETIC

	-- Modules needed for this faction
	CF.RequiredModules[factionid] = { "Base.rte", "Techion.rte" }

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.SNIPER }

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
	CF.ActNames[factionid][i] = "Whitebot"
	CF.ActPresets[factionid][i] = "Whitebot"
	CF.ActModules[factionid][i] = "Techion.rte"
	CF.ActPrices[factionid][i] = 110
	CF.ActDescriptions[factionid][i] =
		"Light-weight yet sturdy, the versatile Whitebot performs well on and off the battlefield."
	CF.ActUnlockData[factionid][i] = 0
	CF.ActClasses[factionid][i] = "AHuman"
	CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
	CF.ActPowers[factionid][i] = 5

	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Silver Man"
	CF.ActPresets[factionid][i] = "Silver Man"
	CF.ActModules[factionid][i] = "Techion.rte"
	CF.ActPrices[factionid][i] = 180
	CF.ActDescriptions[factionid][i] =
		"The Silver Man has a strong nanite coating which minimizes penetration damage and patches holes in seconds. As a result, it does not bleed out like other units."
	CF.ActUnlockData[factionid][i] = 1800
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
	CF.ItmNames[factionid][i] = "Micro Pulsar"
	CF.ItmPresets[factionid][i] = "Micro Pulsar"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 35
	CF.ItmDescriptions[factionid][i] =
		"A powerful pistol which fires short homing laser shots. Zooming in will highlight targets that the lasers are likely to lock on to."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
	CF.ItmPowers[factionid][i] = 4

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Laser Rifle"
	CF.ItmPresets[factionid][i] = "Laser Rifle"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 50
	CF.ItmDescriptions[factionid][i] =
		"Techion's primary anti-personnel armament. This self-charging energy rifle can slice up soft targets from long ranges with great accuracy."
	CF.ItmUnlockData[factionid][i] = 0
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Pulse Rifle"
	CF.ItmPresets[factionid][i] = "Pulse Rifle"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 65
	CF.ItmDescriptions[factionid][i] =
		"A compact assault rifle based on similar technology to the Micro Pulsar. This deals somewhat less damage, but fires shots much faster and farther."
	CF.ItmUnlockData[factionid][i] = 800
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 6

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Nucleo"
	CF.ItmPresets[factionid][i] = "Nucleo"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 80
	CF.ItmDescriptions[factionid][i] =
		"Fires balls of plasma which link up with lasers. If an enemy interrupts one of the lasers, the plasma balls will teleport to the enemy and detonate."
	CF.ItmUnlockData[factionid][i] = 1200
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
	CF.ItmPowers[factionid][i] = 5

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Nano Rifle"
	CF.ItmPresets[factionid][i] = "Nano Rifle"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 100
	CF.ItmDescriptions[factionid][i] =
		"This weapon's shot releases nanobots into the target, quickly disintegrating the limb it hits. The rifle is equipped with a laser sight to allow pin-point accuracy."
	CF.ItmUnlockData[factionid][i] = 1500
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
	CF.ItmPowers[factionid][i] = 7

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Dihelical Cannon"
	CF.ItmPresets[factionid][i] = "Dihelical Cannon"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 100
	CF.ItmDescriptions[factionid][i] =
		"This cannon unleashes a deadly beam that penetrates through enemies and soft terrain alike. Hold the trigger to charge-up your shot."
	CF.ItmUnlockData[factionid][i] = 1600
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 6

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Giga Pulsar"
	CF.ItmPresets[factionid][i] = "Giga Pulsar"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 150
	CF.ItmDescriptions[factionid][i] =
		"With an alternate cooling system, the Giga Pulsar dwarfs its smaller siblings not only in physical size, but also in firepower and round count."
	CF.ItmUnlockData[factionid][i] = 2400
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 8

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Nucleo Swarm"
	CF.ItmPresets[factionid][i] = "Nucleo Swarm"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 150
	CF.ItmDescriptions[factionid][i] =
		"Charge this weapon before firing a swarm of 8 plasma 'missiles' that home in on enemies."
	CF.ItmUnlockData[factionid][i] = 2600
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
	CF.ItmPowers[factionid][i] = 7

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Nanolyzer"
	CF.ItmPresets[factionid][i] = "Nanolyzer"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 100
	CF.ItmDescriptions[factionid][i] =
		"This tool analyzes materials and destabilizes them into a gray goo, making it extremely easy to dig through. Ideal for breaking bunkers, but not for mining."
	CF.ItmUnlockData[factionid][i] = 1400
	CF.ItmClasses[factionid][i] = "HDFirearm"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
	CF.ItmPowers[factionid][i] = 3

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Warp Grenade"
	CF.ItmPresets[factionid][i] = "Warp Grenade"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 20
	CF.ItmDescriptions[factionid][i] =
		"This device warps its user to the location of its detonation."
	CF.ItmUnlockData[factionid][i] = 800
	CF.ItmClasses[factionid][i] = "TDExplosive"
	CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
	CF.ItmPowers[factionid][i] = 0

	i = #CF.ItmNames[factionid] + 1
	CF.ItmNames[factionid][i] = "Nanoswarm Canister Bandolier"
	CF.ItmPresets[factionid][i] = "Nanoswarm Canister Bandolier"
	CF.ItmModules[factionid][i] = "Techion.rte"
	CF.ItmPrices[factionid][i] = 50
	CF.ItmDescriptions[factionid][i] =
		"These metal cans hold a swarm of nanobots that, when released, attack nearby enemies. Be careful around attacking swarms, as high-speed nanobots may also damage teammates!"
	CF.ItmUnlockData[factionid][i] = 1000
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