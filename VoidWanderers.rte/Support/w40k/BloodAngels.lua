-- Unique Faction ID
local factionid = "Imperium of Man: Blood Angels"
print("Loading " .. factionid)

CF.Factions[#CF.Factions + 1] = factionid

-- Faction name
CF.FactionNames[factionid] = "Blood Angels"
-- Faction description
CF.FactionDescriptions[factionid] =
	"Ninth Legion of the twenty, the Blood Angels Chapter are bloodthirsty assault and deep strike specialists. They should not be mistaken for crude warmongers, though; the Blood Angels are long-lived and have a refined sense of aesthetics."
-- Set true if faction is selectable by player or AI
CF.FactionPlayable[factionid] = true

-- Modules needed for this faction
CF.RequiredModules[factionid] = { "Base.rte", "w40k.rte" }

-- Set faction nature - types are ORGANIC and SYNTHETIC
CF.FactionNatures[factionid] = CF.FactionTypes.ORGANIC

-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
-- Default - {CF.WeaponTypes.DIGGER, CF.WeaponTypes.RIFLE}
CF.PreferedBrainInventory[factionid] = { CF.WeaponTypes.HEAVY, CF.WeaponTypes.RIFLE }

-- Define brain unit
CF.Brains[factionid] = "Blood Angels Assault Sergeant Brain"
CF.BrainModules[factionid] = "w40k.rte"
CF.BrainClasses[factionid] = "AHuman"
CF.BrainPrices[factionid] = 500

-- Define dropship
CF.Crafts[factionid] = "Blood Angels Drop Pod"
CF.CraftModules[factionid] = "w40k.rte"
CF.CraftClasses[factionid] = "ACRocket"
CF.CraftPrices[factionid] = 0

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
CF.ActNames[factionid][i] = "Blood Angel Scout"
CF.ActPresets[factionid][i] = "Blood Angel Scout"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 100
CF.ActDescriptions[factionid][i] =
	"Neophyte Battle-Brothers, Scouts are most often armed with Bolters, Marine Sniper Rifles, or Imperium Automatic Shotguns. They serve as skirmishing and recon forces."
CF.ActUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
CF.ActPowers[factionid][i] = 0

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Blood Angel Assault Recon"
CF.ActPresets[factionid][i] = "Blood Angel Assault Recon"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 150
CF.ActDescriptions[factionid][i] =
	"Neophytes training to be Assault Marines, Assault Recon Troopers have superior mobility thanks to their Assault Packs."
CF.ActUnlockData[factionid][i] = 10 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.LIGHT
CF.ActPowers[factionid][i] = 4

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Blood Angels Space Marine"
CF.ActPresets[factionid][i] = "Blood Angels Space Marine"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 300
CF.ActDescriptions[factionid][i] =
	"Adeptus Astartes, the Emperor's Finest. Clad in ceramite armour and extensively augmented, these supersoldiers are more than a match for normal humans."
CF.ActUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
CF.ActPowers[factionid][i] = 0

i = #CF.ActNames[factionid] + 1
CF.ActNames[factionid][i] = "Blood Angels Assault Marine"
CF.ActPresets[factionid][i] = "Blood Angels Assault Marine"
CF.ActModules[factionid][i] = "w40k.rte"
CF.ActPrices[factionid][i] = 375
CF.ActDescriptions[factionid][i] =
	"Equipped with powerful jetpacks, Assault Marines prefer to close with the enemy and engage in melee combat, but are equally capable at range."
CF.ActUnlockData[factionid][i] = 1250 -- 0 means available at start
CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
CF.ActPowers[factionid][i] = 7

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
CF.ItmNames[factionid][i] = "Bolt Pistol"
CF.ItmPresets[factionid][i] = "Bolt Pistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 75
CF.ItmDescriptions[factionid][i] =
	"Standard sidearm of the Adeptus Astartes. Do not forsake your sidearm. It is the deliverer of wrath and a constant companion in a life of unending battle."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 3

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Storm Bolter"
CF.ItmPresets[factionid][i] = "Storm Bolter"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 375
CF.ItmDescriptions[factionid][i] = "Dual-barrel, rapid-fire, high-capacity. One can never have too much firepower."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 5

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Plasma Pistol"
CF.ItmPresets[factionid][i] = "Plasma Pistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 125
CF.ItmDescriptions[factionid][i] =
	"A compact plasma sidearm, firing bolts of hydrogen-based. Very dangerous, but slow to reload and fire."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 9

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Inferno Pistol"
CF.ItmPresets[factionid][i] = "Inferno Pistol"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 300
CF.ItmDescriptions[factionid][i] =
	"Miniaturized Meltagun, extremely deadly but extremely expensive. Reserved for the boldest and most battle-hardened of the Emperor's Finest."
CF.ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.PISTOL
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Automatic Shotgun"
CF.ItmPresets[factionid][i] = "Imperium Automatic Shotgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A heavy duty, fully automatic shotgun feeding from a 15-round drum magazine, with integral laser sight and bayonet. Switch ammo types using the pie menu, and press 'F' to use the bayonet. Or just shoot them. That works too."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Flamer"
CF.ItmPresets[factionid][i] = "Imperium Flamer"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 175
CF.ItmDescriptions[factionid][i] =
	"Projects a stream of burning promethium fuel, immolating any in its path. It is more than just a weapon. It is the redeemer of the corrupt and the purifier of the tainted."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHOTGUN
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Bolter"
CF.ItmPresets[factionid][i] = "Bolter"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 300
CF.ItmDescriptions[factionid][i] =
	"Standard weapon of the Adeptus Astartes, firing high-caliber self-propelled munitions at a respectable rate of fire. Can employ standard, armour-piercing, or incendiary rounds. Firepower, always firepower."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 5

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Bolter CombiPlasma"
CF.ItmPresets[factionid][i] = "Bolter CombiPlasma"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 375
CF.ItmDescriptions[factionid][i] =
	"A Bolter with an integrated Plasma Pistol. Sacrifices ease of use and reload time for a considerable firepower boost. Press 'F' to fire the Plasma Pistol. Can use same ammo types as the normal Bolter too."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.RIFLE
CF.ItmPowers[factionid][i] = 0

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
CF.ItmNames[factionid][i] = "Stalker Boltgun"
CF.ItmPresets[factionid][i] = "Stalker Boltgun"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 350
CF.ItmDescriptions[factionid][i] =
	"A highly effective battle rifle and 'short range' sniping weapon. Special barrel tempering and treatment allows the use of more exotic bolt types."
CF.ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Marine Sniper Rifle"
CF.ItmPresets[factionid][i] = "Marine Sniper Rifle"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 125
CF.ItmDescriptions[factionid][i] =
	"Ultra-long-range sniper rifle favoured by the Scout Marines. Extremely effective against infantry, vehicles, and low-flying aircraft."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SNIPER
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Heavy Bolter"
CF.ItmPresets[factionid][i] = "Heavy Bolter"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 375
CF.ItmDescriptions[factionid][i] =
	"Fully-automatic squad support weapon. Very heavy, but very deadly and still highly accurate. The Heavy Bolter sings praises to the Emperor with a voice that will never tire."
CF.ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 1

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Vengeance Launcher"
CF.ItmPresets[factionid][i] = "Vengeance Launcher"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 175
CF.ItmDescriptions[factionid][i] =
	"Experimental new remote-detonated grenade launcher developed on the Forge World of Graia, sanctioned for limited field testing with select Chapters by the resident Techmarines."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Helios RPG Launcher"
CF.ItmPresets[factionid][i] = "Helios RPG Launcher"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 200
CF.ItmDescriptions[factionid][i] =
	"Old but reliable rocket-propelled-grenade launcher. No guidance system. Can use anti-vehicle 'krak' rockets, or anti-infantry fragmentation rockets."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 1

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
CF.ItmNames[factionid][i] = "Astartes Assault Cannon"
CF.ItmPresets[factionid][i] = "Astartes Assault Cannon"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 300
CF.ItmDescriptions[factionid][i] =
	"Ultra-high capacity rotary weapon, extremely deadly and extremely heavy. Wield with caution."
CF.ItmUnlockData[factionid][i] = 2000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Astartes Lascannon"
CF.ItmPresets[factionid][i] = "Astartes Lascannon"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 500
CF.ItmDescriptions[factionid][i] =
	"Anti-vehicle weapon, occasionally used to snipe high-value targets due to its range and accuracy. As pure and wroth as justice itself."
CF.ItmUnlockData[factionid][i] = 2250 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Plasma Cannon"
CF.ItmPresets[factionid][i] = "Plasma Cannon"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 675
CF.ItmDescriptions[factionid][i] =
	"Light field artillery weapon, capable of making shots arc high over defenses to hit those who would hide from the Emperor's Fury. Employ the Plasma Cannon against clusters of heavily-armoured infantry or light vehicles."
CF.ItmUnlockData[factionid][i] = 2500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Astartes Heavy Flamer"
CF.ItmPresets[factionid][i] = "Astartes Heavy Flamer"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 325
CF.ItmDescriptions[factionid][i] =
	"Employed by the Terminators, ideal for clearing out heavily fortified locations. The fires of absolution shall cleanse. The work of the Emperor shall be done."
CF.ItmUnlockData[factionid][i] = 1750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Multi-Melta"
CF.ItmPresets[factionid][i] = "Multi-Melta"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 600
CF.ItmDescriptions[factionid][i] =
	"Short-ranged heavy anti-vehicle weapon, excellent for cutting open fortifications. It speaks with the roar of a million voices, seeking justice from an uncaring universe."
CF.ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Astartes Autocannon"
CF.ItmPresets[factionid][i] = "Astartes Autocannon"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 250
CF.ItmDescriptions[factionid][i] =
	"An antiquated but nonetheless highly-effective design, best employed against heavy infantry, light vehicles, and dropships. Can use impact or proximity detonated shells."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.HEAVY
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Storm Shield"
CF.ItmPresets[factionid][i] = "Storm Shield"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 150
CF.ItmDescriptions[factionid][i] =
	"An ultra-heavy shield, essentially little more than a solid slab of metal rated for starship hulls."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "HeldDevice"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Large Storm Shield"
CF.ItmPresets[factionid][i] = "Large Storm Shield"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 275
CF.ItmDescriptions[factionid][i] =
	"An even larger and heavier version of the smaller Storm Shield, offering superior coverage."
CF.ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "HeldDevice"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Chain Sword"
CF.ItmPresets[factionid][i] = "Chain Sword"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A heavy, crude weapon, with a whirring chain of razor-sharp teeth. Taste the fear of your enemy as he dies."
CF.ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Power Sword"
CF.ItmPresets[factionid][i] = "Power Sword"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A blade wrapped in a disruption field capable of slicing through almost any armour with ease, the Power Sword is a truly lethal weapon. Armour is no protection against the blessed tools of the righteous."
CF.ItmUnlockData[factionid][i] = 2500 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Power Axe"
CF.ItmPresets[factionid][i] = "Power Axe"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 125
CF.ItmDescriptions[factionid][i] =
	"An axe-blade wrapped in a disruption field capable of slicing through almost any armour with ease, the Power Axe is a truly lethal weapon. Armour is no protection against the blessed tools of the righteous."
CF.ItmUnlockData[factionid][i] = 2750 -- 0 means available at start
CF.ItmTypes[factionid][i] = CF.WeaponTypes.SHIELD
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Imperium Frag Grenade"
CF.ItmPresets[factionid][i] = "Imperium Frag Grenade"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 25
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
CF.ItmPrices[factionid][i] = 50
CF.ItmDescriptions[factionid][i] =
	"A belt of Imperial Meltabombs, hybrid incendiary-antiarmour grenades. Ideal for breaking through doors."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Astartes Plasma Grenade"
CF.ItmPresets[factionid][i] = "Astartes Plasma Grenade"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 25
CF.ItmDescriptions[factionid][i] =
	"A single grenade holding a powerful plasma charge in a miniature stasis cell. Adheres to targets using powerful magnets."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Whirlwind Vengeance Designator"
CF.ItmPresets[factionid][i] = "Whirlwind Vengeance Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 75
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a short barrage of anti-armour missiles. Effective against infantry and armour, but not fortifications."
CF.ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Whirlwind Incendiary Castellan Designator"
CF.ItmPresets[factionid][i] = "Whirlwind Incendiary Castellan Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 100
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a short volley of incendiary missiles, setting the target area ablaze and hindering enemy movements."
CF.ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF.ItmClasses[factionid][i] = "TDExplosive"
CF.ItmTypes[factionid][i] = CF.WeaponTypes.GRENADE
CF.ItmPowers[factionid][i] = 0

i = #CF.ItmNames[factionid] + 1
CF.ItmNames[factionid][i] = "Orbital Plasma Battery Designator"
CF.ItmPresets[factionid][i] = "Orbital Plasma Battery Designator"
CF.ItmModules[factionid][i] = "w40k.rte"
CF.ItmPrices[factionid][i] = 150
CF.ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in an imprecise volley of extremely powerful Plasma Lance shots from an orbiting warship. Despite atmospheric resistance and plasma blooming, these shots remain extremely deadly. Employ with care."
CF.ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
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
	CF.BombOwnerFactions[n] = { "Imperium of Man: Blood Angels" }
	CF.BombUnlockData[n] = 1250

	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Explosive Whirlwind Rocket"
	CF.BombPresets[n] = "Imperium Explosive Whirlwind Rocket"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 100
	CF.BombDescriptions[n] =
		"A standard explosive rocket, effective against most targets. Best used for saturation attacks."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Blood Angels" }
	CF.BombUnlockData[n] = 1250

	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Incendiary Whirlwind Rocket"
	CF.BombPresets[n] = "Imperium Incendiary Whirlwind Rocket"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 125
	CF.BombDescriptions[n] = "A larger, more powerful rocket with an added incendiary payload for area-denial."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Blood Angels" }
	CF.BombUnlockData[n] = 1500

	local n = #CF.BombNames + 1
	CF.BombNames[n] = "Imperium Plasma Shot"
	CF.BombPresets[n] = "Imperium Plasma Shot"
	CF.BombModules[n] = "w40k.rte"
	CF.BombClasses[n] = "TDExplosive"
	CF.BombPrices[n] = 250
	CF.BombDescriptions[n] = "A single powerful plasma blast capable of inflicting massive damage."
	CF.BombOwnerFactions[n] = { "Imperium of Man: Blood Angels" }
	CF.BombUnlockData[n] = 2500
end
