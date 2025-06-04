-- This script serves as an example of a custom faction file for Void Wanderers!

do
	-- Unique Faction ID
	local factionID = "Free Trade";

	-- State that there is a faction with this ID
	CF.Factions[#CF.Factions + 1] = factionID;

	do
		-- Faction name
		CF.FactionNames[factionID] = "Free Trade";
		-- Faction description
		CF.FactionDescriptions[factionID] = "The enabler of interstellar trade on the multi-civilizational scale and the hand that feeds most factions, so to speak. You probably do not want to make enemies with these guys.";
		-- Set true if faction is selectable for player or AI
		CF.FactionPlayable[factionID] = false;
		-- Available values: NONE, ORGANIC, SYNTHETIC
		CF.FactionNatures[factionID] = CF.FactionNatureTypes.ORGANIC;
		-- Set true if faction is significantly hostile to outgroups
		CF.FactionIngroupPreference[factionID] = false;
		-- Set true if faction is always involved, but not selectable
		CF.FactionStaticInvolvement[factionID] = true;
	end
	--
	CF.FactionAttributes[factionID] = {
		"VENDOR"
	};
	--
	local law = {
		type = "union",
		"PRIVATE_MILITARY_COMPANY",
		"PMC",
		"LAW_ENFORCEMENT",
		"POLICE",
		"LAW",
		"Techion",
	};
	local criminal = {
		type = "union",
		"PIRATES"
		"Ronin",
	};
	CF.FactionInclinations[factionID] = {
		{
			modifier = 600,
			membership = {
				type = "intersection",
				law,
				{
					type = "complement",
					criminal,
				},
			},
		},
		{
			modifier = -1500,
			membership = {
				type = "intersection",
				criminal,
				{
					type = "complement",
					law,
				},
			},
		},
	};

	-- Modules needed for this faction
	CF.RequiredModules[factionID] = { "Base.rte" };

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionID] = {};

	-- Define brain unit
	CF.BrainPresets[factionID] = "AI Box";
	CF.BrainModules[factionID] = "Base.rte";
	CF.BrainClasses[factionID] = "ACrab";
	CF.BrainPrices[factionID] = 500;

	-- Define dropship
	CF.CraftPresets[factionID] = "Rocket MK2";
	CF.CraftModules[factionID] = "Base.rte";
	CF.CraftClasses[factionID] = "ACRocket";
	CF.CraftPrices[factionID] = 500;

	-- Define buyable actors available for purchase or unlocks
	CF.ActNames[factionID] = {};
	CF.ActClasses[factionID] = {};
	CF.ActPresets[factionID] = {};
	CF.ActModules[factionID] = {};
	CF.ActDescriptions[factionID] = {};
	CF.ActPrices[factionID] = {};
	CF.ActTypes[factionID] = {}; -- CF.ActorTypes {LIGHT, HEAVY, ARMOR, TURRET}
	CF.ActUnlockData[factionID] = {};
	CF.ActPowers[factionID] = {}; -- AI will select weapons based on this value 1 - weakest, 10 - toughest, 0 - never use
	CF.ActOffsets[factionID] = {};

	-- Available actor types
	local i = 0;

	-- Faction actors
	i = #CF.ActNames[factionID] + 1;
	CF.ActNames[factionID][i] = "Green Dummy";
	CF.ActClasses[factionID][i] = "AHuman";
	CF.ActPresets[factionID][i] = "Green Dummy";
	CF.ActModules[factionID][i] = "Base.rte";
	CF.ActDescriptions[factionID][i] = "TradeStar's factory worker unit. Agile, but not fit for warfare!";
	CF.ActPrices[factionID][i] = 150;
	CF.ActTypes[factionID][i] = CF.ActorTypes.LIGHT;
	CF.ActUnlockData[factionID][i] = 500;
	CF.ActPowers[factionID][i] = 5;
	CF.ActOffsets[factionID][i] = Vector(0, 0);

	i = #CF.ActNames[factionID] + 1;
	CF.ActNames[factionID][i] = "Medic Drone";
	CF.ActClasses[factionID][i] = "ACrab";
	CF.ActPresets[factionID][i] = "Medic Drone";
	CF.ActModules[factionID][i] = "Base.rte";
	CF.ActDescriptions[factionID][i] = "Send this into the battlefield and place it near a units to heal them.";
	CF.ActPrices[factionID][i] = 240;
	CF.ActTypes[factionID][i] = CF.ActorTypes.LIGHT;
	CF.ActUnlockData[factionID][i] = 1000;
	CF.ActPowers[factionID][i] = 1;
	CF.ActOffsets[factionID][i] = Vector(0, 0);

	i = #CF.ActNames[factionID] + 1;
	CF.ActNames[factionID][i] = "Anti-Air Drone";
	CF.ActClasses[factionID][i] = "ACrab";
	CF.ActPresets[factionID][i] = "Anti-Air Drone";
	CF.ActModules[factionID][i] = "Base.rte";
	CF.ActDescriptions[factionID][i] = "Tradstar's Gatling Drone sports a machine gun plus a pair of fully automated surface to air missiles for bringing down any unwanted visitors above your landing zone.";
	CF.ActPrices[factionID][i] = 300;
	CF.ActTypes[factionID][i] = CF.ActorTypes.HEAVY;
	CF.ActUnlockData[factionID][i] = 1400;
	CF.ActPowers[factionID][i] = 4;
	CF.ActOffsets[factionID][i] = Vector(0, 0);

	i = #CF.ActNames[factionID] + 1;
	CF.ActNames[factionID][i] = "TradeStar Turret";
	CF.ActClasses[factionID][i] = "ACrab";
	CF.ActPresets[factionID][i] = "TradeStar Turret";
	CF.ActModules[factionID][i] = "Base.rte";
	CF.ActDescriptions[factionID][i] = "Small rifled turret for medium range base defense.";
	CF.ActPrices[factionID][i] = 200;
	CF.ActTypes[factionID][i] = CF.ActorTypes.TURRET;
	CF.ActUnlockData[factionID][i] = 800;
	CF.ActPowers[factionID][i] = 4;
	CF.ActOffsets[factionID][i] = Vector(0, 0);


	-- Define buyable items available for purchase or unlocks
	CF.ItmNames[factionID] = {};
	CF.ItmClasses[factionID] = {};
	CF.ItmPresets[factionID] = {};
	CF.ItmModules[factionID] = {};
	CF.ItmDescriptions[factionID] = {};
	CF.ItmPrices[factionID] = {};
	CF.ItmTypes[factionID] = {}; -- CF.WeaponTypes {PISTOL = 0, RIFLE = 1, SHOTGUN = 2, SNIPER = 3, HEAVY = 4, SHIELD = 5, DIGGER = 6, GRENADE = 7, TOOL = 8, BOMB = 9}
	CF.ItmUnlockData[factionID] = {};
	CF.ItmPowers[factionID] = {}; -- 0 ~> don't use, 10 ~> use liberally

	local i = 0;

	-- Faction items
	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Pistol";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Pistol";
	CF.ItmModules[factionID][i] = "Base.rte";
	CF.ItmDescriptions[factionID][i] = "Trade Star's cheapest defensive option, this sidearm should really be used as a last resort.";
	CF.ItmPrices[factionID][i] = 20;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.PISTOL;
	CF.ItmUnlockData[factionID][i] = 500;
	CF.ItmPowers[factionID][i] = 2;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "SMG";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "SMG";
	CF.ItmModules[factionID][i] = "Base.rte";
	CF.ItmDescriptions[factionID][i] = "Remaining highly reliable in a wide range of bad weather conditions and dirt, Trade Star's budget SMG hasn't changed its design for over 150 years.";
	CF.ItmPrices[factionID][i] = 40;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.PISTOL;
	CF.ItmUnlockData[factionID][i] = 900;
	CF.ItmPowers[factionID][i] = 3;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Shotgun";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Shotgun";
	CF.ItmModules[factionID][i] = "Base.rte";
	CF.ItmDescriptions[factionID][i] = "A simple and reliable shotgun from Trade Star. It may not be the most powerful option, but it sure is affordable.";
	CF.ItmPrices[factionID][i] = 70;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.SHOTGUN;
	CF.ItmUnlockData[factionID][i] = 1000;
	CF.ItmPowers[factionID][i] = 3;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Battle Rifle";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Battle Rifle";
	CF.ItmModules[factionID][i] = "Base.rte";
	CF.ItmDescriptions[factionID][i] = "Standard rifle for longer range engagements than the SMG. It's a cheap way of arming your troops with decent and effective firepower.";
	CF.ItmPrices[factionID][i] = 60;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.RIFLE;
	CF.ItmUnlockData[factionID][i] = 500;
	CF.ItmPowers[factionID][i] = 3;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Rocket Launcher";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Rocket Launcher";
	CF.ItmModules[factionID][i] = "Base.rte";
	CF.ItmDescriptions[factionID][i] = "Steadfast rocket launcher capable of toppling craft and units alike.";
	CF.ItmPrices[factionID][i] = 140;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.HEAVY;
	CF.ItmUnlockData[factionID][i] = 2000;
	CF.ItmPowers[factionID][i] = 3;
end