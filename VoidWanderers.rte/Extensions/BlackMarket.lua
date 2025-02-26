--[[

	Black market goods fall into four categories:

	1. Generic items from existing factions are already inserted into the blackmarket from time to time, no need to completely crowd stuff here out.
	2. What's generic, but also hard to find. Someone out there doesn't want you to buy a mechanical prosthetic.
	3. What's custom, probably not meeting regulation, but is really pretty cool.
	4. What's counterfeit, probably not meeting regulation, but is definitely going to get you killed. Or someone, anyhow.

]]

local id = #CF.BlackMarketItmPresets;

-- Black Market exclusives :O

-- Generics

id = id + 1;
CF.BlackMarketItmPresets[id] = "Prosthetic Arm";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HeldDevice";
CF.BlackMarketItmPrices[id] = 250;
CF.BlackMarketItmDescriptions[id] = "Need a hand?";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.TOOL;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Prosthetic Leg";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HeldDevice";
CF.BlackMarketItmPrices[id] = 250;
CF.BlackMarketItmDescriptions[id] = "Break a leg!";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.TOOL;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Green Dummy Head";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HeldDevice";
CF.BlackMarketItmPrices[id] = 250;
CF.BlackMarketItmDescriptions[id] = "Quit while you're a head!";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.TOOL;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Replacement Head";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HeldDevice";
CF.BlackMarketItmPrices[id] = 500;
CF.BlackMarketItmDescriptions[id] = "Quit while you're a head!";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.TOOL;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Control Chip";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HeldDevice";
CF.BlackMarketItmPrices[id] = 10000;
CF.BlackMarketItmDescriptions[id] = "A chip, made specifically for the control of non-vacant actors. Plug this into the recently deceased to alter their allegiances, assuming you have the medical tooling to bring them back to.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.TOOL;

-- Customs

id = id + 1;
CF.BlackMarketItmPresets[id] = "Lazor Rifle";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 200;
CF.BlackMarketItmDescriptions[id] = "Your firing you're lazor!!";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.SNIPER;

id = id + 1;
CF.BlackMarketItmPresets[id] = "YAK-4700";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 200;
CF.BlackMarketItmDescriptions[id] = "Someone's tampered with this gun, I can tell...";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

--[[ Unfinished customs

id = id + 1;
CF.BlackMarketItmPresets[id] = "Uber Grenade Launcher";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 700;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Big Iron";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 250;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Vulcan MG-10";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 1000;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Nano Machinegun";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 1000;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Rail Blaster";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 1000;

id = id + 1;
CF.BlackMarketItmPresets[id] = "UZI-II";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 1000;

id = id + 1;
CF.BlackMarketItmPresets[id] = "SPAZ-1200";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 1000;
]]--

-- Counterfeits

id = id + 1;
CF.BlackMarketItmPresets[id] = "Ubor Cannon";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 100;
CF.BlackMarketItmDescriptions[id] = "Ubor Cannon. A shoulder mounted, tactical artillery weapon that fires air bursting cluster bomb. Features a trajectory guide to help with long ranged shots.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Missilo Launcher";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 100;
CF.BlackMarketItmDescriptions[id] = "Can fire powerfull automatically guided missiles, excellent at destroying enemy crafts.  Lock on to enemy units using the laser pointer!";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Devastator CNN-72";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 100;
CF.BlackMarketItmDescriptions[id] = "A devestating anti air weapon that can take out a drop ship from a distance easily with little effort. The proximity fuze on the flak shells ensures that they explodes at the right distance for maximum effectiveness.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Bulldog GG-69";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 100;
CF.BlackMarketItmDescriptions[id] = "Slow firing, but incredibly powerfull, this gatling gun is sure to destroy you're opponents.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Giga Pulser";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 100;
CF.BlackMarketItmDescriptions[id] = "With an alternative cooling system, the Giga Pulser dwarfs it's smaller siblings not only in physicle size, but also in fire power and round count. After a short charge up, this weapon deals a brief but concentrated splattering of short range lasers.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Nucleu Swarm";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 100;
CF.BlackMarketItmDescriptions[id] = "Charge this weapon before firing a swarm of 8 plasma 'missles' that home in on enemies.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.RIFLE;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Frag Nailer Machinegun";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 500;
CF.BlackMarketItmDescriptions[id] = "A larger magazine, and larger gun to account. Go number someone's days.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.HEAVY;

id = id + 1;
CF.BlackMarketItmPresets[id] = "Compact Sniper Rifle";
CF.BlackMarketItmModules[id] = CF.ModuleName;
CF.BlackMarketItmClasses[id] = "HDFirearm";
CF.BlackMarketItmPrices[id] = 500;
CF.BlackMarketItmDescriptions[id] = "A larger magazine, and larger gun to account. Go number someone's days.";
CF.BlackMarketItmTypes[id] = CF.WeaponTypes.RIFLE;

-- My meme

if PresetMan:GetModuleID("MyMod.rte") ~= -1 and PresetMan:GetPreset("HDFirearm", "My Gun", "MyMod.rte") then
	id = id + 1;
	CF.BlackMarketItmPresets[id] = "My Gun";
	CF.BlackMarketItmModules[id] = "MyMod.rte";
	CF.BlackMarketItmClasses[id] = "HDFirearm";
	CF.BlackMarketItmPrices[id] = 100;
	CF.BlackMarketItmDescriptions[id] = "It's... Wait a minute, it's my gun!";
	CF.BlackMarketItmTypes[id] = CF.WeaponTypes.PISTOL;
end