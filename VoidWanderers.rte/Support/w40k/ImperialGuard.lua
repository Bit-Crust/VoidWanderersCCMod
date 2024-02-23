-- Unique Faction ID
local factionid = "Imperium of Man: Imperial Guard"
print("Loading " .. factionid)

CF_Factions[#CF_Factions + 1] = factionid

-- Faction name
CF_FactionNames[factionid] = "Imperial Guard"
-- Faction description
CF_FactionDescriptions[factionid] =
	"They may not be the Emperor's Finest, but they make up for it with superior numbers and more artillery than you can shake a squig at. Not that we recommend shaking a squig at anything, it'll probably try to bite you. Or explode. Or cover you in acid."
-- Set true if faction is selectable by player or AI
CF_FactionPlayable[factionid] = true

-- Modules needed for this faction
CF_RequiredModules[factionid] = { "Base.rte", "w40k.rte" }

-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
-- Default - {CF_WeaponTypes.DIGGER, CF_WeaponTypes.RIFLE}
CF_PreferedBrainInventory[factionid] = { CF_WeaponTypes.HEAVY, CF_WeaponTypes.RIFLE }

-- Set faction nature - types are ORGANIC and SYNTHETIC
CF_FactionNatures[factionid] = CF_FactionTypes.ORGANIC

-- Define brain unit
CF_Brains[factionid] = "Elysian Commissar"
CF_BrainModules[factionid] = "w40k.rte"
CF_BrainClasses[factionid] = "AHuman"
CF_BrainPrices[factionid] = 250

-- Define dropship
CF_Crafts[factionid] = "Dropship MK1"
CF_CraftModules[factionid] = "Base.rte"
CF_CraftClasses[factionid] = "ACDropShip"
CF_CraftPrices[factionid] = 120

-- Define buyable actors available for purchase or unlocks
CF_ActNames[factionid] = {}
CF_ActPresets[factionid] = {}
CF_ActModules[factionid] = {}
CF_ActPrices[factionid] = {}
CF_ActDescriptions[factionid] = {}
CF_ActUnlockData[factionid] = {}
CF_ActClasses[factionid] = {} -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF_ActTypes[factionid] = {} -- AI will select different weapons based on this value
CF_ActPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use
CF_ActOffsets[factionid] = {}

local i = 0
i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Imperial Guardsman"
CF_ActPresets[factionid][i] = "Imperial Guardsman"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 100
CF_ActDescriptions[factionid][i] = "A humble, hard-working servant of the Imperium."
CF_ActUnlockData[factionid][i] = 10 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Death Korps Guardsman"
CF_ActPresets[factionid][i] = "Death Korps Guardsman"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 125
CF_ActDescriptions[factionid][i] =
	"The fearless Guardsmen of the Death Korps are hardier than normal Guardsmen, though they are also a little slower."
CF_ActUnlockData[factionid][i] = 10 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Elysian Drop Trooper"
CF_ActPresets[factionid][i] = "Elysian Drop Trooper"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 125
CF_ActDescriptions[factionid][i] =
	"Elysian Drop Troopers excel at rapid assaults, using their grav chutes to attack from the air."
CF_ActUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 1

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Imperial Guard Sergeant"
CF_ActPresets[factionid][i] = "Imperial Guard Sergeant"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 125
CF_ActDescriptions[factionid][i] =
	"A moderately experienced Guardsman, tasked with leading squads into battle and stopping them from shooting their allies."
CF_ActUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Imperial Guard Kasrkin"
CF_ActPresets[factionid][i] = "Imperial Guard Kasrkin"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 200
CF_ActDescriptions[factionid][i] =
	"Elite agents of the Imperium, Kasrkin serve as shock troopers and storm troopers. Well-armoured and tougher than normal Guardsmen."
CF_ActUnlockData[factionid][i] = 2000 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Elysian Stormtrooper"
CF_ActPresets[factionid][i] = "Elysian Stormtrooper"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 225
CF_ActDescriptions[factionid][i] =
	"Veteran Elysians, outfitted with superior armour and weaponry. Equivalent to Kasrkin."
CF_ActUnlockData[factionid][i] = 2250 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF_ActPowers[factionid][i] = 3

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Widow Turret with Hellgun"
CF_ActPresets[factionid][i] = "Widow Turret with Hellgun"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 300
CF_ActDescriptions[factionid][i] =
	"Ceramite-clad turret with a tuned up Hellgun, all powered by an integral high-output plasma-fusion cell. Perfect for defending chokepoints."
CF_ActUnlockData[factionid][i] = 1750 -- 0 means available at start
CF_ActClasses[factionid][i] = "ACrab"
CF_ActTypes[factionid][i] = CF_ActorTypes.TURRET
CF_ActPowers[factionid][i] = 1

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Widow Turret with Bolter"
CF_ActPresets[factionid][i] = "Widow Turret with Bolter"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 325
CF_ActDescriptions[factionid][i] =
	"Ceramite-clad turret with a belt-fed Heavy Bolter and integral high-capacity ammo drum. Perfect for defending chokepoints."
CF_ActUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ActClasses[factionid][i] = "ACrab"
CF_ActTypes[factionid][i] = CF_ActorTypes.TURRET
CF_ActPowers[factionid][i] = 1

-- Define buyable items available for purchase or unlocks
CF_ItmNames[factionid] = {}
CF_ItmPresets[factionid] = {}
CF_ItmModules[factionid] = {}
CF_ItmPrices[factionid] = {}
CF_ItmDescriptions[factionid] = {}
CF_ItmUnlockData[factionid] = {}
CF_ItmClasses[factionid] = {} -- permissable types are PISTOL, RIFLE, SHOTGUN, SNIPER, HEAVY, SHIELD, DIGGER, GRENADE
CF_ItmTypes[factionid] = {}
CF_ItmPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use

local i = 0
i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Light Digger"
CF_ItmPresets[factionid][i] = "Light Digger"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"Lightest in the digger family. Cheapest of them all and works as a nice melee weapon on soft targets."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.DIGGER
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Medium Digger"
CF_ItmPresets[factionid][i] = "Medium Digger"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 40
CF_ItmDescriptions[factionid][i] =
	"Stronger digger. This one can pierce rocks with some effort and dig impressive tunnels and its melee weapon capabilities are much greater."
CF_ItmUnlockData[factionid][i] = 500
CF_ItmTypes[factionid][i] = CF_WeaponTypes.DIGGER
CF_ItmPowers[factionid][i] = 4

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Heavy Digger"
CF_ItmPresets[factionid][i] = "Heavy Digger"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"Heaviest and the most powerful of them all. Eats concrete with great hunger and allows you to make complex mining caves incredibly fast. Shreds anyone unfortunate who stand in its way."
CF_ItmUnlockData[factionid][i] = 1000
CF_ItmTypes[factionid][i] = CF_WeaponTypes.DIGGER
CF_ItmPowers[factionid][i] = 8

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Melta-Cutter"
CF_ItmPresets[factionid][i] = "Melta-Cutter"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"A lower-temperature Meltagun designed to slice through fortifications rather than vehicles or infantry."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.DIGGER
CF_ItmPowers[factionid][i] = 10

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Grapple Gun"
CF_ItmPresets[factionid][i] = "Grapple Gun"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 40
CF_ItmDescriptions[factionid][i] =
	"Use this to climb walls and descend dangerous drops! Climb up by holding the crouch key, and then holding up/down or scrolling up/down."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.DIGGER
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Laspistol"
CF_ItmPresets[factionid][i] = "Laspistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 50
CF_ItmDescriptions[factionid][i] =
	"Standard sidearm of the Imperial Guard. Do not forsake your sidearm. It is the deliverer of wrath and a constant companion in a life of unending battle."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 3

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Hellpistol"
CF_ItmPresets[factionid][i] = "Hellpistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"Higher-tech Laspistol feeding from an ultra-capacity cell. Running out of ammo is not a concern, but accuracy and weight are."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 8

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Bolt Pistol"
CF_ItmPresets[factionid][i] = "Bolt Pistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 75
CF_ItmDescriptions[factionid][i] =
	"Standard sidearm of the Adeptus Astartes, favoured by some Commissars and Imperial Officers as well."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 7

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Plasma Pistol"
CF_ItmPresets[factionid][i] = "Plasma Pistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 125
CF_ItmDescriptions[factionid][i] =
	"A compact plasma sidearm, firing bolts of hydrogen-based. Very dangerous, but slow to reload and fire."
CF_ItmUnlockData[factionid][i] = 2250 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 9

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Inferno Pistol"
CF_ItmPresets[factionid][i] = "Inferno Pistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"Miniaturized Meltagun, extremely deadly but extremely expensive. Reserved for the boldest and most battle-hardened of the Emperor's Finest."
CF_ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Light Shotgun"
CF_ItmPresets[factionid][i] = "Imperium Light Shotgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 50
CF_ItmDescriptions[factionid][i] =
	"A light eight-round shotgun preferred by the Imperial Guard for its low recoil and uncomplicated mechanical systems. It lacks the accuracy and range of its larger fully-automatic brother that is sometimes seen in the hands of elite units or the Space Marines, but is still quite deadly."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Automatic Shotgun"
CF_ItmPresets[factionid][i] = "Imperium Automatic Shotgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A heavy duty, fully automatic shotgun feeding from a 15-round drum magazine, with integral laser sight and bayonet. Switch ammo types using the pie menu, and press 'F' to use the bayonet. Or just shoot them. That works too."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 3

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Flamer"
CF_ItmPresets[factionid][i] = "Imperium Flamer"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 175
CF_ItmDescriptions[factionid][i] =
	"Projects a stream of burning promethium fuel, immolating any in its path. It is more than just a weapon. It is the redeemer of the corrupt and the purifier of the tainted."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Lascarbine"
CF_ItmPresets[factionid][i] = "Lascarbine"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 65
CF_ItmDescriptions[factionid][i] =
	"A compact version of the Lasgun, usable one-handed in a pinch. Notably improved rate of fire compared to its larger cousin, but harder to aim accurately."
CF_ItmUnlockData[factionid][i] = 250 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Lasgun"
CF_ItmPresets[factionid][i] = "Lasgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 75
CF_ItmDescriptions[factionid][i] =
	"Standard weapon of the Imperial Guard - decent range, firepower, capacity, and accuracy. Easy to maintain, instant shot travel time. Rate of fire is a little lacking, though."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 6

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Lasgun with Bayonet"
CF_ItmPresets[factionid][i] = "Lasgun with Bayonet"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 85
CF_ItmDescriptions[factionid][i] =
	"Standard weapon of the Imperial Guard - decent range, firepower, capacity, and accuracy. Easy to maintain, instant shot travel time. Rate of fire is a little lacking, though."
CF_ItmUnlockData[factionid][i] = 150 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "M41-Pattern Automatic Lasgun"
CF_ItmPresets[factionid][i] = "M41-Pattern Automatic Lasgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 75
CF_ItmDescriptions[factionid][i] =
	"The M41 was developed in response to concerns that the low rate of fire on older semi-automatic Lasgun models was detrimental to close-quarters combat performance. As a result, the M41 trades firepower and accuracy for a significantly increased rate of fire. A portion of the power from the cell must also be used to operate the cooling systems, meaning the M41 manages fewer shots per cell compared to the older models."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 7

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Hellgun"
CF_ItmPresets[factionid][i] = "Hellgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 225
CF_ItmDescriptions[factionid][i] =
	"A higher-tech version of the lasgun, with improved cooling components. Inferior accuracy and high weight, but very rapid fire. Deadly at shorter ranges. Only issued to elite stormtroopers."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 8

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Plasma Rifle"
CF_ItmPresets[factionid][i] = "Plasma Rifle"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 400
CF_ItmDescriptions[factionid][i] =
	"Launches bolts of hydrogen-based plasma- superheated, ionized gas. The noblest works incur the heaviest risks."
CF_ItmUnlockData[factionid][i] = 1750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 10

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Meltagun"
CF_ItmPresets[factionid][i] = "Meltagun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 450
CF_ItmDescriptions[factionid][i] =
	"'Light' infantry-portable anti-vehicle/anti-fortification 'beam' weapon, using promethium fuel as a catalyst. The fury of the meltagun is as nothing to our righteous rage."
CF_ItmUnlockData[factionid][i] = 2500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Long Las"
CF_ItmPresets[factionid][i] = "Long Las"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 125
CF_ItmDescriptions[factionid][i] =
	"A lasgun with added capacitance and focusing systems, lending it superior range and power compared to a normal lasgun, at the cost of increased weight and unwieldiness. Favoured by snipers."
CF_ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SNIPER
CF_ItmPowers[factionid][i] = 7

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Grenade Launcher"
CF_ItmPresets[factionid][i] = "Imperium Grenade Launcher"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"Classic six-shot 'revolver'-style grenade launcher. Can fire impact-detonated grenades, bouncing timed grenades, or sticky timed grenades. Versatile and useful."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 3

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Helios RPG Launcher"
CF_ItmPresets[factionid][i] = "Helios RPG Launcher"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 200
CF_ItmDescriptions[factionid][i] =
	"Old but reliable rocket-propelled-grenade launcher. Can use anti-vehicle 'krak' rockets, or anti-infantry fragmentation rockets."
CF_ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 7

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Thunderstrike Missile Launcher"
CF_ItmPresets[factionid][i] = "Thunderstrike Missile Launcher"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 350
CF_ItmDescriptions[factionid][i] =
	"High-versatility laser-guided missile launcher, ideal for engaging infantry, vehicles, or aircraft. Never permit your enemy to find you unprepared for the battle."
CF_ItmUnlockData[factionid][i] = 1250 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Combat Shield"
CF_ItmPresets[factionid][i] = "Combat Shield"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 75
CF_ItmDescriptions[factionid][i] = "A solid and durable metal shield similar to those used by the Adeptus Arbites."
CF_ItmUnlockData[factionid][i] = 150 -- 0 means available at start
CF_ItmClasses[factionid][i] = "HeldDevice"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Chain Sword"
CF_ItmPresets[factionid][i] = "Chain Sword"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A heavy, crude weapon, with a whirring chain of razor-sharp teeth. Taste the fear of your enemy as he dies."
CF_ItmUnlockData[factionid][i] = 150 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Power Sword"
CF_ItmPresets[factionid][i] = "Power Sword"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A blade wrapped in a disruption field capable of slicing through almost any armour with ease, the Power Sword is a truly lethal weapon. Armour is no protection against the blessed tools of the righteous."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Frag Grenade"
CF_ItmPresets[factionid][i] = "Imperium Frag Grenade"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"A belt of the Imperium's finest fragmentation grenades. Pull the pin and throw as hard as you dare."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 4

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Meltabomb"
CF_ItmPresets[factionid][i] = "Imperium Meltabomb"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"A belt of Imperial Meltabombs, hybrid incendiary-antiarmour grenades. Ideal for breaking through doors."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Thudd Designator"
CF_ItmPresets[factionid][i] = "Thudd Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 25
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a prolonged barrage of anti-infantry mortar fire. Not very effective against heavy armour."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Cluster Mortar Designator"
CF_ItmPresets[factionid][i] = "Cluster Mortar Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 50
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a quick barrage of shells full of cluster bombs that split above the target area, showering it with their payload. Very effective against infantry."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Basilisk Designator"
CF_ItmPresets[factionid][i] = "Basilisk Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 50
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a moderate length barrage of Basilisk artillery shells, effective against infantry and armour. Limited use against fortifications."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Bombard Designator"
CF_ItmPresets[factionid][i] = "Bombard Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a single pinpoint-accurate 'bunker buster' shell from above. Ideal for breaking into fortifications."
CF_ItmUnlockData[factionid][i] = 2000 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

-- This is important, UL2 don't support bombs,
-- if you won't check for this UL2 won't load this file
if CF_BombNames ~= nil then
	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Cluster Mortar"
	CF_BombPresets[n] = "Imperium Cluster Mortar"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 75
	CF_BombDescriptions[n] =
		"A hollow deployment device with a payload of sixteen submunitions. Extremely effective against infantry."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF_BombUnlockData[n] = 1250

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Basilisk Shell"
	CF_BombPresets[n] = "Imperium Basilisk Shell"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 100
	CF_BombDescriptions[n] = "Standard high-power explosive shell, reasonably effective against all kinds of targets."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF_BombUnlockData[n] = 1500

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Bombard Shell"
	CF_BombPresets[n] = "Imperium Bombard Shell"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 125
	CF_BombDescriptions[n] =
		"An extremely powerful explosive shell designed to create a breach in bunkers and other fortified structures."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF_BombUnlockData[n] = 2000

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Plasma Shot"
	CF_BombPresets[n] = "Imperium Plasma Shot"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 250
	CF_BombDescriptions[n] = "A single powerful plasma blast capable of inflicting massive damage."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF_BombUnlockData[n] = 2500
end
