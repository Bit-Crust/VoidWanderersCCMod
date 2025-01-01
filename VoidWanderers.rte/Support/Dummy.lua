-- This script serves as an example of a custom faction file for Void Wanderers!

do
	-- Unique Faction ID
	local factionID = "Dummy";

	-- State that there is a faction with this ID
	CF.Factions[#CF.Factions + 1] = factionID;

	-- Faction name
	CF.FactionNames[factionID] = "Dummy";
	-- Faction description
	CF.FactionDescriptions[factionID] = "These robots were originally test subjects for various lethal experiments, until an AI controller became sentient and broke off from its manufacturers, starting a new line of robots and weapons to defend itself.";
	-- Set true if faction is selectable by player or AI
	CF.FactionPlayable[factionID] = true;
	-- Available values ORGANIC, SYNTHETIC
	CF.FactionNatures[factionID] = CF.FactionNatureTypes.SYNTHETIC;

	-- Modules needed for this faction
	CF.RequiredModules[factionID] = { "Base.rte", "Dummy.rte" };

	-- Preferred brain inventory items. Brain gets the best available items of the classes specified.
	CF.PreferedBrainInventory[factionID] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.PISTOL, CF.WeaponTypes.PISTOL };

	-- Define brain unit
	CF.Brains[factionID] = "Dummy Coordinator";
	CF.BrainModules[factionID] = "Dummy.rte";
	CF.BrainClasses[factionID] = "AHuman";
	CF.BrainPrices[factionID] = 500;

	-- Define dropship
	CF.Crafts[factionID] = "Dummy Dropship";
	CF.CraftModules[factionID] = "Base.rte";
	CF.CraftClasses[factionID] = "ACDropShip";
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
	CF.ActNames[factionID][i] = "Dummy";
	CF.ActClasses[factionID][i] = "AHuman";
	CF.ActPresets[factionID][i] = "Dummy";
	CF.ActModules[factionID][i] = "Dummy.rte";
	CF.ActDescriptions[factionID][i] = "Standard dummy soldier.  Quite resilient to impacts and falls, and very agile.  Made of plastic, it is weak to bullets.";
	CF.ActPrices[factionID][i] = 60;
	CF.ActTypes[factionID][i] = CF.ActorTypes.LIGHT;
	CF.ActUnlockData[factionID][i] = 0;
	CF.ActPowers[factionID][i] = 5;
	CF.ActOffsets[factionID][i] = Vector(0, 0);

	i = #CF.ActNames[factionID] + 1;
	CF.ActNames[factionID][i] = "Dreadnought";
	CF.ActClasses[factionID][i] = "ACrab";
	CF.ActPresets[factionID][i] = "Dreadnought";
	CF.ActModules[factionID][i] = "Dummy.rte";
	CF.ActDescriptions[factionID][i] = "Armored tank on 4 legs.  Armed with a machine gun and covered with multiple layers of armor.";
	CF.ActPrices[factionID][i] = 150;
	CF.ActTypes[factionID][i] = CF.ActorTypes.ARMOR;
	CF.ActUnlockData[factionID][i] = 2000;
	CF.ActPowers[factionID][i] = 8;
	CF.ActOffsets[factionID][i] = Vector(0, 12);
		
	i = #CF.ActNames[factionID] + 1;
	CF.ActNames[factionID][i] = "Small Turret";
	CF.ActClasses[factionID][i] = "ACrab";
	CF.ActPresets[factionID][i] = "Small Turret";
	CF.ActModules[factionID][i] = "Dummy.rte";
	CF.ActDescriptions[factionID][i] = "Small turret with a machine gun for general base defense.";
	CF.ActPrices[factionID][i] = 250;
	CF.ActTypes[factionID][i] = CF.ActorTypes.TURRET;
	CF.ActUnlockData[factionID][i] = 3000;
	CF.ActPowers[factionID][i] = 9;
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
	CF.ItmNames[factionID][i] = "Nailgun";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Nailgun";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "A sidearm that fires heated nails at high velocities.";
	CF.ItmPrices[factionID][i] = 20;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.PISTOL;
	CF.ItmUnlockData[factionID][i] = 0;
	CF.ItmPowers[factionID][i] = 2;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Rail Pistol";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Rail Pistol";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "A compact sidearm for a good price and decent performance!";
	CF.ItmPrices[factionID][i] = 25;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.PISTOL;
	CF.ItmUnlockData[factionID][i] = 1100;
	CF.ItmPowers[factionID][i] = 5;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Blaster";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Blaster";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Energy based sub machine gun.  Has a much shorter range than ballistic weapons, but its power and fast reloading make it an effective weapon.";
	CF.ItmPrices[factionID][i] = 70;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.RIFLE;
	CF.ItmUnlockData[factionID][i] = 0;
	CF.ItmPowers[factionID][i] = 3;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Repeater";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Repeater";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Effective rapid fire support weapon.  Doubles as a good assault weapon due to its low weight, but users should be warned of the long reload time.";
	CF.ItmPrices[factionID][i] = 150;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.RIFLE;
	CF.ItmUnlockData[factionID][i] = 700;
	CF.ItmPowers[factionID][i] = 7;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Scouting Rifle";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Scouting Rifle";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Long range rifle with a scope.  It doesn't exactly have a high ammo capacity or rate of fire, nor is it particularly accurate or powerful, but its' plastic parts make it dirt cheap.";
	CF.ItmPrices[factionID][i] = 120;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.SNIPER;
	CF.ItmUnlockData[factionID][i] = 800;
	CF.ItmPowers[factionID][i] = 4;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Lancer";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Lancer";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "One of the first Dummy energy weapons, this low-cost rifle quickly recharges its capacitor when not in use, and discharges all of its energy upon firing.";
	CF.ItmPrices[factionID][i] = 160;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.SNIPER;
	CF.ItmUnlockData[factionID][i] = 1400;
	CF.ItmPowers[factionID][i] = 5;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Frag Nailer";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Frag Nailer";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "A rapid-fire, four-barreled grenade launcher that lobs packets of nails that stick to objects and explode after a set time.";
	CF.ItmPrices[factionID][i] = 150;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.SHOTGUN;
	CF.ItmUnlockData[factionID][i] = 2700;
	CF.ItmPowers[factionID][i] = 3;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Nailer Machinegun";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Nailer Machinegun";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Rapid fire version of the Nail Gun.  Fire lots of heated nails at an incredible rate!";
	CF.ItmPrices[factionID][i] = 190;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.HEAVY;
	CF.ItmUnlockData[factionID][i] = 2500;
	CF.ItmPowers[factionID][i] = 6;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Impulse Grenade Launcher";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Impulse Grenade Launcher";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Devastating weapon that fires concussive grenades.  Releases no shrapnel upon detonation, but direct hits are extremely powerful.";
	CF.ItmPrices[factionID][i] = 230;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.HEAVY;
	CF.ItmUnlockData[factionID][i] = 3000;
	CF.ItmPowers[factionID][i] = 6;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Annihiliator";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Annihiliator";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Destructive heavy laser cannon. Hold down fire to charge the laser, then release it to unleash hot laser death on your enemies! Charge up the beam completely for maximum power!";
	CF.ItmPrices[factionID][i] = 300;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.HEAVY;
	CF.ItmUnlockData[factionID][i] = 4000;
	CF.ItmPowers[factionID][i] = 4;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Destroyer Cannon";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Destroyer Cannon";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "This cannon fires orbs of energy that mow down multiple enemies in a row without slowing. Hold down the trigger to charge your shot and release to dispense the beam!";
	CF.ItmPrices[factionID][i] = 250;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.HEAVY;
	CF.ItmUnlockData[factionID][i] = 3700;
	CF.ItmPowers[factionID][i] = 8;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Disruptor Grenade";
	CF.ItmClasses[factionID][i] = "TDExplosive";
	CF.ItmPresets[factionID][i] = "Disruptor Grenade";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Area denial grenade.  Sets a deadly field upon detonation that lasts for 10 seconds.";
	CF.ItmPrices[factionID][i] = 20;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.GRENADE;
	CF.ItmUnlockData[factionID][i] = 700;
	CF.ItmPowers[factionID][i] = 2;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Impulse Grenade";
	CF.ItmClasses[factionID][i] = "TDExplosive";
	CF.ItmPresets[factionID][i] = "Impulse Grenade";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Standard dummy grenade. Explodes into a devastating kinetic blast that will knock away or even tear apart its target.";
	CF.ItmPrices[factionID][i] = 20;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.GRENADE;
	CF.ItmUnlockData[factionID][i] = 700;
	CF.ItmPowers[factionID][i] = 3;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Turbo Digger";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Turbo Digger";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "Dummy mining tool.  Doubles as a powerful close range weapon.";
	CF.ItmPrices[factionID][i] = 30;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.DIGGER;
	CF.ItmUnlockData[factionID][i] = 1000;
	CF.ItmPowers[factionID][i] = 2;

	i = #CF.ItmNames[factionID] + 1;
	CF.ItmNames[factionID][i] = "Shielder";
	CF.ItmClasses[factionID][i] = "HDFirearm";
	CF.ItmPresets[factionID][i] = "Shielder";
	CF.ItmModules[factionID][i] = "Dummy.rte";
	CF.ItmDescriptions[factionID][i] = "This tool materializes a temporary energy shield in front of the user for protection and/or slowing down enemy pursuers.";
	CF.ItmPrices[factionID][i] = 30;
	CF.ItmTypes[factionID][i] = CF.WeaponTypes.SHIELD;
	CF.ItmUnlockData[factionID][i] = 500;
	CF.ItmPowers[factionID][i] = 6;

	-- Base actors and items (automatic stuff, no need to change these unless you want to)

	local baseActors = {
		{ presetName = "Medic Drone", class = "ACrab", unlockData = 1000, actorPowers = 0 },
	};

	for j = 1, #baseActors do
		local actor;
		i = #CF.ActNames[factionID] + 1;

		if baseActors[j].class == "ACrab" then
			actor = CreateACrab(baseActors[j].presetName, "Base.rte");
			CF.ActTypes[factionID][i] = CF.ActorTypes.ARMOR;
			CF.ActOffsets[factionID][i] = Vector(0, 12);
		elseif baseActors[j].class == "AHuman" then
			actor = CreateAHuman(baseActors[j].presetName, "Base.rte");
			CF.ActTypes[factionID][i] = CF.ActorTypes.LIGHT;
		end

		if actor then
			CF.ActNames[factionID][i] = actor.PresetName;
			CF.ActPresets[factionID][i] = actor.PresetName;
			CF.ActClasses[factionID][i] = actor.ClassName;
			CF.ActModules[factionID][i] = "Base.rte";
			CF.ActDescriptions[factionID][i] = actor.Description;
			CF.ActPrices[factionID][i] = actor:GetGoldValue(0, 1, 1);
			
			CF.ActUnlockData[factionID][i] = baseActors[j].unlockData;
			CF.ActPowers[factionID][i] = baseActors[j].actorPowers;

			DeleteEntity(actor);
		end
	end

	local baseItems = {
		{ presetName = "Remote Explosive", class = "TDExplosive", unlockData = 500, itemPowers = 0 },
		{ presetName = "Anti Personnel Mine", class = "TDExplosive", unlockData = 900, itemPowers = 0 },
		{ presetName = "Light Digger", class = "HDFirearm", unlockData = 0, itemPowers = 1, weaponType = CF.WeaponTypes.DIGGER },
		{ presetName = "Medium Digger", class = "HDFirearm", unlockData = 1200, itemPowers = 3, weaponType = CF.WeaponTypes.DIGGER },
		{ presetName = "Heavy Digger", class = "HDFirearm", unlockData = 2400, itemPowers = 5, weaponType = CF.WeaponTypes.DIGGER },
		{ presetName = "Detonator", class = "HDFirearm", unlockData = 500, itemPowers = 0 },
		{ presetName = "Grapple Gun", class = "HDFirearm", unlockData = 1100, itemPowers = 0 },
		{ presetName = "Medikit", class = "HDFirearm", unlockData = 700, itemPowers = 3 },
		{ presetName = "Disarmer", class = "HDFirearm", unlockData = 900, itemPowers = 0 },
		{ presetName = "Constructor", class = "HDFirearm", unlockData = 1000, itemPowers = 0 },
		{ presetName = "Scanner", class = "HDFirearm", unlockData = 600, itemPowers = 0 },
		{ presetName = "Riot Shield", class = "HeldDevice", unlockData = 500, itemPowers = 0 }
	};

	for j = 1, #baseItems do
		local item;
		i = #CF.ItmNames[factionID] + 1;

		if baseItems[j].class == "TDExplosive" then
			item = CreateTDExplosive(baseItems[j].presetName, "Base.rte");
			CF.ItmTypes[factionID][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF.WeaponTypes.GRENADE;
		elseif baseItems[j].class == "HDFirearm" then
			item = CreateHDFirearm(baseItems[j].presetName, "Base.rte");
			CF.ItmTypes[factionID][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF.WeaponTypes.TOOL;
		elseif baseItems[j].class == "HeldDevice" then
			item = CreateHeldDevice(baseItems[j].presetName, "Base.rte");
			CF.ItmTypes[factionID][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF.WeaponTypes.SHIELD;
		end

		if item then
			CF.ItmNames[factionID][i] = item.PresetName;
			CF.ItmClasses[factionID][i] = item.ClassName;
			CF.ItmPresets[factionID][i] = item.PresetName;
			CF.ItmModules[factionID][i] = "Base.rte";
			CF.ItmDescriptions[factionID][i] = item.Description;
			CF.ItmPrices[factionID][i] = item:GetGoldValue(0, 1, 1);

			CF.ItmUnlockData[factionID][i] = baseItems[j].unlockData;
			CF.ItmPowers[factionID][i] = baseItems[j].itemPowers;

			DeleteEntity(item);
		end
	end
end