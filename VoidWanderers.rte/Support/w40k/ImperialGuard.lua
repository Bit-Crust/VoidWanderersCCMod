-- Unique Faction ID
local factionid = "Imperium of Man: Imperial Guard"
print("Loading " .. factionid)

CF.Factions[#CF.Factions + 1] = factionid

-- Faction name
CF.FactionNames[factionid] = "Imperial Guard"
-- Faction description
CF.FactionDescriptions[factionid] =
	"They may not be the Emperor's Finest, but they make up for it with superior numbers and more artillery than you can shake a squig at. Not that we recommend shaking a squig at anything, it'll probably try to bite you. Or explode. Or cover you in acid."
-- Set true if faction is selectable by player or AI
CF.FactionPlayable[factionid] = true

-- Modules needed for this faction
CF.RequiredModules[factionid] = { "Base.rte", "w40k.rte" }

-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
-- Default - {CF.WeaponTypes.DIGGER, CF.WeaponTypes.RIFLE}
CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.RIFLE }

-- Set faction nature - types are ORGANIC and SYNTHETIC
CF.FactionNatures[factionid] = CF.FactionNatureTypes.ORGANIC

-- Define brain unit
CF.Brains[factionid] = "Elysian Commissar"
CF.BrainModules[factionid] = "w40k.rte"
CF.BrainClasses[factionid] = "AHuman"
CF.BrainPrices[factionid] = 250

-- Define dropship
CF.Crafts[factionid] = "Dropship MK1"
CF.CraftModules[factionid] = "Base.rte"
CF.CraftClasses[factionid] = "ACDropShip"
CF.CraftPrices[factionid] = 120

-- Define buyable actors available for purchase or unlocks
CF.ActNames[factionid] = {}
CF.ActPresets[factionid] = {}
CF.ActModules[factionid] = {}
CF.ActPrices[factionid] = {}
CF.ActDescriptions[factionid] = {}
CF.ActUnlockData[factionid] = {}
CF.ActClasses[factionid] = {} -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF.ActTypes[factionid] = {} -- AI will select different weapons based on this value
CF.ActPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use
CF.ActOffsets[factionid] = {}

local i = 0
i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Imperial Guardsman"
CF.ActPresets[factionid][i] = "Imperial Guardsman"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 100
CF.ActDescriptions[factionid][i] = "A humble, hard-working servant of the Imperium."
CF.ActUnlockData[factionid][i] = 10 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
CF.ActPowers[factionid][i] = 0

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Death Korps Guardsman"
CF.ActPresets[factionid][i] = "Death Korps Guardsman"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 125
CF.ActDescriptions[factionid][i] =
	"The fearless Guardsmen of the Death Korps are hardier than normal Guardsmen, though they are also a little slower."
CF.ActUnlockData[factionid][i] = 10 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
CF.ActPowers[factionid][i] = 0

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Elysian Drop Trooper"
CF.ActPresets[factionid][i] = "Elysian Drop Trooper"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 125
CF.ActDescriptions[factionid][i] =
	"Elysian Drop Troopers excel at rapid assaults, using their grav chutes to attack from the air."
CF.ActUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
CF.ActPowers[factionid][i] = 1

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Imperial Guard Sergeant"
CF.ActPresets[factionid][i] = "Imperial Guard Sergeant"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 125
CF.ActDescriptions[factionid][i] =
	"A moderately experienced Guardsman, tasked with leading squads into battle and stopping them from shooting their allies."
CF.ActUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF.ActPowers[factionid][i] = 0

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Imperial Guard Kasrkin"
CF.ActPresets[factionid][i] = "Imperial Guard Kasrkin"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 200
CF.ActDescriptions[factionid][i] =
	"Elite agents of the Imperium, Kasrkin serve as shock troopers and storm troopers. Well-armoured and tougher than normal Guardsmen."
CF.ActUnlockData[factionid][i] = 2000 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF.ActPowers[factionid][i] = 0

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Elysian Stormtrooper"
CF.ActPresets[factionid][i] = "Elysian Stormtrooper"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 225
CF.ActDescriptions[factionid][i] =
	"Veteran Elysians, outfitted with superior armour and weaponry. Equivalent to Kasrkin."
CF.ActUnlockData[factionid][i] = 2250 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY -- permissable types are LIGHT, HEAVY, ARMOR, and TURRET
CF.ActPowers[factionid][i] = 3

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Widow Turret with Hellgun"
CF.ActPresets[factionid][i] = "Widow Turret with Hellgun"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 300
CF.ActDescriptions[factionid][i] =
	"Ceramite-clad turret with a tuned up Hellgun, all powered by an integral high-output plasma-fusion cell. Perfect for defending chokepoints."
CF.ActUnlockData[factionid][i] = 1750 -- 0 means available at start
CF.ActClasses[factionid][i] = "ACrab"
CF.ActTypes[factionid][i] = CF.ActorTypes.TURRET
CF.ActPowers[factionid][i] = 1

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Widow Turret with Bolter"
CF.ActPresets[factionid][i] = "Widow Turret with Bolter"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 325
CF.ActDescriptions[factionid][i] =
	"Ceramite-clad turret with a belt-fed Heavy Bolter and integral high-capacity ammo drum. Perfect for defending chokepoints."
CF.ActUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ActClasses[factionid][i] = "ACrab"
CF.ActTypes[factionid][i] = CF.ActorTypes.TURRET
CF.ActPowers[factionid][i] = 1

-- Define buyable items available for purchase or unlocks
CF.ItmNames[factionid] = {}
CF.ItmPresets[factionid] = {}
CF.ItmModules[factionid] = {}
CF.ItmPrices[factionid] = {}
CF.ItmDescriptions[factionid] = {}
CF.ItmUnlockData[factionid] = {}
CF.ItmClasses[factionid] = {} -- permissable types are PISTOL, RIFLE, SHOTGUN, SNIPER, HEAVY, SHIELD, DIGGER, GRENADE
CF.ItmTypes[factionid] = {}
CF.ItmPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use

local i = 0
i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Light Digger"
CF.ItmPresets[factionid][i] = "Light Digger"
CF.ItmModules[factionid][i] = "Base.rte"
CF.ItmPrices[factionid][i] = 10
CF.ItmDescriptions[factionid][i] =
	"Lightest in the digger family. Cheapest of them all and works as a nice melee weapon on soft targets."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Medium Digger"
CF.ItmPresets[factionid][i] = "Medium Digger"
CF.ItmModules[factionid][i] = "Base.rte"
CF.ItmPrices[factionid][i] = 40
CF.ItmDescriptions[factionid][i] =
	"Stronger digger. This one can pierce rocks with some effort and dig impressive tunnels and its melee weapon capabilities are much greater."
CF.ItmUnlockData[factionid][i] = 500
CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
CF.ItmPowers[factionid][i] = 4

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Heavy Digger"
CF.ItmPresets[factionid][i] = "Heavy Digger"
CF.ItmModules[factionid][i] = "Base.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"Heaviest and the most powerful of them all. Eats concrete with great hunger and allows you to make complex mining caves incredibly fast. Shreds anyone unfortunate who stand in its way."
CF.ItmUnlockData[factionid][i] = 1000
CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
CF.ItmPowers[factionid][i] = 8

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Melta-Cutter"
CF.ItmPresets[factionid][i] = "Melta-Cutter"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 150
CF.ItmDescriptions[factionid][i] =
	"A lower-temperature Meltagun designed to slice through fortifications rather than vehicles or infantry."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
CF.ItmPowers[factionid][i] = 10

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Grapple Gun"
CF.ItmPresets[factionid][i] = "Grapple Gun"
CF.ItmModules[factionid][i] = "Base.rte"
CF.ItmPrices[factionid][i] = 40
CF.ItmDescriptions[factionid][i] =
	"Use this to climb walls and descend dangerous drops! Climb up by holding the crouch key, and then holding up/down or scrolling up/down."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.DIGGER
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Laspistol"
CF.ItmPresets[factionid][i] = "Laspistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 50
CF.ItmDescriptions[factionid][i] =
	"Standard sidearm of the Imperial Guard. Do not forsake your sidearm. It is the deliverer of wrath and a constant companion in a life of unending battle."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 3

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Hellpistol"
CF.ItmPresets[factionid][i] = "Hellpistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 150
CF.ItmDescriptions[factionid][i] =
	"Higher-tech Laspistol feeding from an ultra-capacity cell. Running out of ammo is not a concern, but accuracy and weight are."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 8

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Bolt Pistol"
CF.ItmPresets[factionid][i] = "Bolt Pistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 75
CF.ItmDescriptions[factionid][i] =
	"Standard sidearm of the Adeptus Astartes, favoured by some Commissars and Imperial Officers as well."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 7

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Plasma Pistol"
CF.ItmPresets[factionid][i] = "Plasma Pistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 125
CF.ItmDescriptions[factionid][i] =
	"A compact plasma sidearm, firing bolts of hydrogen-based. Very dangerous, but slow to reload and fire."
CF.ItmUnlockData[factionid][i] = 2250 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 9

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Inferno Pistol"
CF.ItmPresets[factionid][i] = "Inferno Pistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 10
CF.ItmDescriptions[factionid][i] =
	"Miniaturized Meltagun, extremely deadly but extremely expensive. Reserved for the boldest and most battle-hardened of the Emperor's Finest."
CF.ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Light Shotgun"
CF.ItmPresets[factionid][i] = "Imperium Light Shotgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 50
CF.ItmDescriptions[factionid][i] =
	"A light eight-round shotgun preferred by the Imperial Guard for its low recoil and uncomplicated mechanical systems. It lacks the accuracy and range of its larger fully-automatic brother that is sometimes seen in the hands of elite units or the Space Marines, but is still quite deadly."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Automatic Shotgun"
CF.ItmPresets[factionid][i] = "Imperium Automatic Shotgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A heavy duty, fully automatic shotgun feeding from a 15-round drum magazine, with integral laser sight and bayonet. Switch ammo types using the pie menu, and press 'F' to use the bayonet. Or just shoot them. That works too."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
CF.ItmPowers[factionid][i] = 3

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Flamer"
CF.ItmPresets[factionid][i] = "Imperium Flamer"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 175
CF.ItmDescriptions[factionid][i] =
	"Projects a stream of burning promethium fuel, immolating any in its path. It is more than just a weapon. It is the redeemer of the corrupt and the purifier of the tainted."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Lascarbine"
CF.ItmPresets[factionid][i] = "Lascarbine"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 65
CF.ItmDescriptions[factionid][i] =
	"A compact version of the Lasgun, usable one-handed in a pinch. Notably improved rate of fire compared to its larger cousin, but harder to aim accurately."
CF.ItmUnlockData[factionid][i] = 250 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Lasgun"
CF.ItmPresets[factionid][i] = "Lasgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 75
CF.ItmDescriptions[factionid][i] =
	"Standard weapon of the Imperial Guard - decent range, firepower, capacity, and accuracy. Easy to maintain, instant shot travel time. Rate of fire is a little lacking, though."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 6

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Lasgun with Bayonet"
CF.ItmPresets[factionid][i] = "Lasgun with Bayonet"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 85
CF.ItmDescriptions[factionid][i] =
	"Standard weapon of the Imperial Guard - decent range, firepower, capacity, and accuracy. Easy to maintain, instant shot travel time. Rate of fire is a little lacking, though."
CF.ItmUnlockData[factionid][i] = 150 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "M41-Pattern Automatic Lasgun"
CF.ItmPresets[factionid][i] = "M41-Pattern Automatic Lasgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 75
CF.ItmDescriptions[factionid][i] =
	"The M41 was developed in response to concerns that the low rate of fire on older semi-automatic Lasgun models was detrimental to close-quarters combat performance. As a result, the M41 trades firepower and accuracy for a significantly increased rate of fire. A portion of the power from the cell must also be used to operate the cooling systems, meaning the M41 manages fewer shots per cell compared to the older models."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 7

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Hellgun"
CF.ItmPresets[factionid][i] = "Hellgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 225
CF.ItmDescriptions[factionid][i] =
	"A higher-tech version of the lasgun, with improved cooling components. Inferior accuracy and high weight, but very rapid fire. Deadly at shorter ranges. Only issued to elite stormtroopers."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 8

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Plasma Rifle"
CF.ItmPresets[factionid][i] = "Plasma Rifle"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 400
CF.ItmDescriptions[factionid][i] =
	"Launches bolts of hydrogen-based plasma- superheated, ionized gas. The noblest works incur the heaviest risks."
CF.ItmUnlockData[factionid][i] = 1750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 10

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Meltagun"
CF.ItmPresets[factionid][i] = "Meltagun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 450
CF.ItmDescriptions[factionid][i] =
	"'Light' infantry-portable anti-vehicle/anti-fortification 'beam' weapon, using promethium fuel as a catalyst. The fury of the meltagun is as nothing to our righteous rage."
CF.ItmUnlockData[factionid][i] = 2500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Long Las"
CF.ItmPresets[factionid][i] = "Long Las"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 125
CF.ItmDescriptions[factionid][i] =
	"A lasgun with added capacitance and focusing systems, lending it superior range and power compared to a normal lasgun, at the cost of increased weight and unwieldiness. Favoured by snipers."
CF.ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
CF.ItmPowers[factionid][i] = 7

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Grenade Launcher"
CF.ItmPresets[factionid][i] = "Imperium Grenade Launcher"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 150
CF.ItmDescriptions[factionid][i] =
	"Classic six-shot 'revolver'-style grenade launcher. Can fire impact-detonated grenades, bouncing timed grenades, or sticky timed grenades. Versatile and useful."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 3

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Helios RPG Launcher"
CF.ItmPresets[factionid][i] = "Helios RPG Launcher"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 200
CF.ItmDescriptions[factionid][i] =
	"Old but reliable rocket-propelled-grenade launcher. Can use anti-vehicle 'krak' rockets, or anti-infantry fragmentation rockets."
CF.ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 7

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Thunderstrike Missile Launcher"
CF.ItmPresets[factionid][i] = "Thunderstrike Missile Launcher"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 350
CF.ItmDescriptions[factionid][i] =
	"High-versatility laser-guided missile launcher, ideal for engaging infantry, vehicles, or aircraft. Never permit your enemy to find you unprepared for the battle."
CF.ItmUnlockData[factionid][i] = 1250 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Combat Shield"
CF.ItmPresets[factionid][i] = "Combat Shield"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 75
CF.ItmDescriptions[factionid][i] = "A solid and durable metal shield similar to those used by the Adeptus Arbites."
CF.ItmUnlockData[factionid][i] = 150 -- 0 means available at start
CF.ItmClasses[factionid][i] = "HeldDevice"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Chain Sword"
CF.ItmPresets[factionid][i] = "Chain Sword"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A heavy, crude weapon, with a whirring chain of razor-sharp teeth. Taste the fear of your enemy as he dies."
CF.ItmUnlockData[factionid][i] = 150 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Power Sword"
CF.ItmPresets[factionid][i] = "Power Sword"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A blade wrapped in a disruption field capable of slicing through almost any armour with ease, the Power Sword is a truly lethal weapon. Armour is no protection against the blessed tools of the righteous."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Frag Grenade"
CF.ItmPresets[factionid][i] = "Imperium Frag Grenade"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 10
CF.ItmDescriptions[factionid][i] =
	"A belt of the Imperium's finest fragmentation grenades. Pull the pin and throw as hard as you dare."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 4

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Meltabomb"
CF.ItmPresets[factionid][i] = "Imperium Meltabomb"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 10
CF.ItmDescriptions[factionid][i] =
	"A belt of Imperial Meltabombs, hybrid incendiary-antiarmour grenades. Ideal for breaking through doors."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Thudd Designator"
CF.ItmPresets[factionid][i] = "Thudd Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 25
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a prolonged barrage of anti-infantry mortar fire. Not very effective against heavy armour."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Cluster Mortar Designator"
CF.ItmPresets[factionid][i] = "Cluster Mortar Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 50
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a quick barrage of shells full of cluster bombs that split above the target area, showering it with their payload. Very effective against infantry."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Basilisk Designator"
CF.ItmPresets[factionid][i] = "Basilisk Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 50
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a moderate length barrage of Basilisk artillery shells, effective against infantry and armour. Limited use against fortifications."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Bombard Designator"
CF.ItmPresets[factionid][i] = "Bombard Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a single pinpoint-accurate 'bunker buster' shell from above. Ideal for breaking into fortifications."
CF.ItmUnlockData[factionid][i] = 2000 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

-- This is important, UL2 don't support bombs,
-- if you won't check for this UL2 won't load this file
if CF.BombNames ~= nil then
	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Cluster Mortar"
	CF.BombPresets[n] = "Imperium Cluster Mortar"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 75
	CF.BombDescriptions[n] =
		"A hollow deployment device with a payload of sixteen submunitions. Extremely effective against infantry."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF.BombUnlockData[n] = 1250

	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Basilisk Shell"
	CF.BombPresets[n] = "Imperium Basilisk Shell"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 100
	CF.BombDescriptions[n] = "Standard high-power explosive shell, reasonably effective against all kinds of targets."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF.BombUnlockData[n] = 1500

	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Bombard Shell"
	CF.BombPresets[n] = "Imperium Bombard Shell"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 125
	CF.BombDescriptions[n] =
		"An extremely powerful explosive shell designed to create a breach in bunkers and other fortified structures."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF.BombUnlockData[n] = 2000

	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Plasma Shot"
	CF.BombPresets[n] = "Imperium Plasma Shot"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 250
	CF.BombDescriptions[n] = "A single powerful plasma blast capable of inflicting massive damage."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Imperial Guard" }
	CF.BombUnlockData[n] = 2500
end
