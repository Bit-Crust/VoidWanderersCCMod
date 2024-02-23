-- Unique Faction ID
local factionid = "Imperium of Man: Space Wolves"
print("Loading " .. factionid)

CF_Factions[#CF_Factions + 1] = factionid

-- Faction name
CF_FactionNames[factionid] = "Space Wolves"
-- Faction description
CF_FactionDescriptions[factionid] =
	"Vlka Fenryka in their native language, the Space Wolves were the sixth Legion of the twenty. They are one of the few Chapters to have no descendant Chapters, and are well-known for their ferocity in battle."
-- Set true if faction is selectable by player or AI
CF_FactionPlayable[factionid] = true

-- Modules needed for this faction
CF_RequiredModules[factionid] = { "Base.rte", "w40k.rte" }

-- Set faction nature - types are ORGANIC and SYNTHETIC
CF_FactionNatures[factionid] = CF_FactionTypes.ORGANIC

-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
-- Default - {CF_WeaponTypes.DIGGER, CF_WeaponTypes.RIFLE}
CF_PreferedBrainInventory[factionid] = { CF_WeaponTypes.HEAVY, CF_WeaponTypes.RIFLE }

-- Define brain unit
CF_Brains[factionid] = "Space Wolves Assault Sergeant Brain"
CF_BrainModules[factionid] = "w40k.rte"
CF_BrainClasses[factionid] = "AHuman"
CF_BrainPrices[factionid] = 500

-- Define dropship
CF_Crafts[factionid] = "Space Wolves Drop Pod"
CF_CraftModules[factionid] = "w40k.rte"
CF_CraftClasses[factionid] = "ACRocket"
CF_CraftPrices[factionid] = 0

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
CF_ActNames[factionid][i] = "Wolf Scout"
CF_ActPresets[factionid][i] = "Wolf Scout"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 100
CF_ActDescriptions[factionid][i] =
	"Neophyte Battle-Brothers, Scouts are most often armed with Bolters, Marine Sniper Rifles, or Imperium Automatic Shotguns. They serve as skirmishing and recon forces."
CF_ActUnlockData[factionid][i] = 10 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Wolf Assault Recon"
CF_ActPresets[factionid][i] = "Wolf Assault Recon"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 150
CF_ActDescriptions[factionid][i] =
	"Neophytes training to be Assault Marines, Assault Recon Troopers have superior mobility thanks to their Assault Packs."
CF_ActUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 4

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Blood Claw"
CF_ActPresets[factionid][i] = "Blood Claw"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 225
CF_ActDescriptions[factionid][i] =
	"Impetuous recruits, the Blood Claws have earned their armour, but have not seen many battles. They tend to be used as shock troopers."
CF_ActUnlockData[factionid][i] = 750 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Grey Hunter"
CF_ActPresets[factionid][i] = "Grey Hunter"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 300
CF_ActDescriptions[factionid][i] =
	"Adeptus Astartes, the Emperor's Finest. Clad in ceramite armour and extensively augmented, these supersoldiers are more than a match for normal humans."
CF_ActUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.ARMOR
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Skyclaw"
CF_ActPresets[factionid][i] = "Skyclaw"
CF_ActModules[factionid][i] = "w40k.rte"
CF_ActPrices[factionid][i] = 300
CF_ActDescriptions[factionid][i] =
	"Equipped with powerful jetpacks, Assault Marines prefer to close with the enemy and engage in melee combat, but are equally capable at range."
CF_ActUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
CF_ActPowers[factionid][i] = 7

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
CF_ItmNames[factionid][i] = "Bolt Pistol"
CF_ItmPresets[factionid][i] = "Bolt Pistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 75
CF_ItmDescriptions[factionid][i] =
	"Standard sidearm of the Adeptus Astartes. Do not forsake your sidearm. It is the deliverer of wrath and a constant companion in a life of unending battle."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 3

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Storm Bolter"
CF_ItmPresets[factionid][i] = "Storm Bolter"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 375
CF_ItmDescriptions[factionid][i] = "Dual-barrel, rapid-fire, high-capacity. One can never have too much firepower."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 5

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Plasma Pistol"
CF_ItmPresets[factionid][i] = "Plasma Pistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 125
CF_ItmDescriptions[factionid][i] =
	"A compact plasma sidearm, firing bolts of hydrogen-based. Very dangerous, but slow to reload and fire."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 9

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Inferno Pistol"
CF_ItmPresets[factionid][i] = "Inferno Pistol"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 300
CF_ItmDescriptions[factionid][i] =
	"Miniaturized Meltagun, extremely deadly but extremely expensive. Reserved for the boldest and most battle-hardened of the Emperor's Finest."
CF_ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Automatic Shotgun"
CF_ItmPresets[factionid][i] = "Imperium Automatic Shotgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A heavy duty, fully automatic shotgun feeding from a 15-round drum magazine, with integral laser sight and bayonet. Switch ammo types using the pie menu, and press 'F' to use the bayonet. Or just shoot them. That works too."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Flamer"
CF_ItmPresets[factionid][i] = "Imperium Flamer"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 175
CF_ItmDescriptions[factionid][i] =
	"Projects a stream of burning promethium fuel, immolating any in its path. It is more than just a weapon. It is the redeemer of the corrupt and the purifier of the tainted."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Bolter"
CF_ItmPresets[factionid][i] = "Bolter"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 300
CF_ItmDescriptions[factionid][i] =
	"Standard weapon of the Adeptus Astartes, firing high-caliber self-propelled munitions at a respectable rate of fire. Can employ standard, armour-piercing, or incendiary rounds. Firepower, always firepower."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 5

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Bolter CombiPlasma"
CF_ItmPresets[factionid][i] = "Bolter CombiPlasma"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 375
CF_ItmDescriptions[factionid][i] =
	"A Bolter with an integrated Plasma Pistol. Sacrifices ease of use and reload time for a considerable firepower boost. Press 'F' to fire the Plasma Pistol. Can use same ammo types as the normal Bolter too."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

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
CF_ItmNames[factionid][i] = "Stalker Boltgun"
CF_ItmPresets[factionid][i] = "Stalker Boltgun"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 350
CF_ItmDescriptions[factionid][i] =
	"A highly effective battle rifle and 'short range' sniping weapon. Special barrel tempering and treatment allows the use of more exotic bolt types."
CF_ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SNIPER
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Marine Sniper Rifle"
CF_ItmPresets[factionid][i] = "Marine Sniper Rifle"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 125
CF_ItmDescriptions[factionid][i] =
	"Ultra-long-range sniper rifle favoured by the Scout Marines. Extremely effective against infantry, vehicles, and low-flying aircraft."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SNIPER
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Heavy Bolter"
CF_ItmPresets[factionid][i] = "Heavy Bolter"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 375
CF_ItmDescriptions[factionid][i] =
	"Fully-automatic squad support weapon. Very heavy, but very deadly and still highly accurate. The Heavy Bolter sings praises to the Emperor with a voice that will never tire."
CF_ItmUnlockData[factionid][i] = 750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Vengeance Launcher"
CF_ItmPresets[factionid][i] = "Vengeance Launcher"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 175
CF_ItmDescriptions[factionid][i] =
	"Experimental new remote-detonated grenade launcher developed on the Forge World of Graia, sanctioned for limited field testing with select Chapters by the resident Techmarines."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Helios RPG Launcher"
CF_ItmPresets[factionid][i] = "Helios RPG Launcher"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 200
CF_ItmDescriptions[factionid][i] =
	"Old but reliable rocket-propelled-grenade launcher. No guidance system. Can use anti-vehicle 'krak' rockets, or anti-infantry fragmentation rockets."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 1

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
CF_ItmNames[factionid][i] = "Astartes Assault Cannon"
CF_ItmPresets[factionid][i] = "Astartes Assault Cannon"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 300
CF_ItmDescriptions[factionid][i] =
	"Ultra-high capacity rotary weapon, extremely deadly and extremely heavy. Wield with caution."
CF_ItmUnlockData[factionid][i] = 2000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Astartes Lascannon"
CF_ItmPresets[factionid][i] = "Astartes Lascannon"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 500
CF_ItmDescriptions[factionid][i] =
	"Anti-vehicle weapon, occasionally used to snipe high-value targets due to its range and accuracy. As pure and wroth as justice itself."
CF_ItmUnlockData[factionid][i] = 2250 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Plasma Cannon"
CF_ItmPresets[factionid][i] = "Plasma Cannon"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 675
CF_ItmDescriptions[factionid][i] =
	"Light field artillery weapon, capable of making shots arc high over defenses to hit those who would hide from the Emperor's Fury. Employ the Plasma Cannon against clusters of heavily-armoured infantry or light vehicles."
CF_ItmUnlockData[factionid][i] = 2500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Astartes Heavy Flamer"
CF_ItmPresets[factionid][i] = "Astartes Heavy Flamer"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 325
CF_ItmDescriptions[factionid][i] =
	"Employed by the Terminators, ideal for clearing out heavily fortified locations. The fires of absolution shall cleanse. The work of the Emperor shall be done."
CF_ItmUnlockData[factionid][i] = 1750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Multi-Melta"
CF_ItmPresets[factionid][i] = "Multi-Melta"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 600
CF_ItmDescriptions[factionid][i] =
	"Short-ranged heavy anti-vehicle weapon, excellent for cutting open fortifications. It speaks with the roar of a million voices, seeking justice from an uncaring universe."
CF_ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Astartes Autocannon"
CF_ItmPresets[factionid][i] = "Astartes Autocannon"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 250
CF_ItmDescriptions[factionid][i] =
	"An antiquated but nonetheless highly-effective design, best employed against heavy infantry, light vehicles, and dropships. Can use impact or proximity detonated shells."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Storm Shield"
CF_ItmPresets[factionid][i] = "Storm Shield"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"An ultra-heavy shield, essentially little more than a solid slab of metal rated for starship hulls."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "HeldDevice"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Large Storm Shield"
CF_ItmPresets[factionid][i] = "Large Storm Shield"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 275
CF_ItmDescriptions[factionid][i] =
	"An even larger and heavier version of the smaller Storm Shield, offering superior coverage."
CF_ItmUnlockData[factionid][i] = 1500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "HeldDevice"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Chain Sword"
CF_ItmPresets[factionid][i] = "Chain Sword"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A heavy, crude weapon, with a whirring chain of razor-sharp teeth. Taste the fear of your enemy as he dies."
CF_ItmUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Power Sword"
CF_ItmPresets[factionid][i] = "Power Sword"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A blade wrapped in a disruption field capable of slicing through almost any armour with ease, the Power Sword is a truly lethal weapon. Armour is no protection against the blessed tools of the righteous."
CF_ItmUnlockData[factionid][i] = 2500 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Power Axe"
CF_ItmPresets[factionid][i] = "Power Axe"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 125
CF_ItmDescriptions[factionid][i] =
	"An axe-blade wrapped in a disruption field capable of slicing through almost any armour with ease, the Power Axe is a truly lethal weapon. Armour is no protection against the blessed tools of the righteous."
CF_ItmUnlockData[factionid][i] = 2750 -- 0 means available at start
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Imperium Frag Grenade"
CF_ItmPresets[factionid][i] = "Imperium Frag Grenade"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 25
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
CF_ItmPrices[factionid][i] = 50
CF_ItmDescriptions[factionid][i] =
	"A belt of Imperial Meltabombs, hybrid incendiary-antiarmour grenades. Ideal for breaking through doors."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Astartes Plasma Grenade"
CF_ItmPresets[factionid][i] = "Astartes Plasma Grenade"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 25
CF_ItmDescriptions[factionid][i] =
	"A single grenade holding a powerful plasma charge in a miniature stasis cell. Adheres to targets using powerful magnets."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Whirlwind Vengeance Designator"
CF_ItmPresets[factionid][i] = "Whirlwind Vengeance Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 75
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a short barrage of anti-armour missiles. Effective against infantry and armour, but not fortifications."
CF_ItmUnlockData[factionid][i] = 500 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Whirlwind Incendiary Castellan Designator"
CF_ItmPresets[factionid][i] = "Whirlwind Incendiary Castellan Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 100
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in a short volley of incendiary missiles, setting the target area ablaze and hindering enemy movements."
CF_ItmUnlockData[factionid][i] = 1000 -- 0 means available at start
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Orbital Plasma Battery Designator"
CF_ItmPresets[factionid][i] = "Orbital Plasma Battery Designator"
CF_ItmModules[factionid][i] = "w40k.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"A single-use beacon used to designate an area for fire support. Calls in an imprecise volley of extremely powerful Plasma Lance shots from an orbiting warship. Despite atmospheric resistance and plasma blooming, these shots remain extremely deadly. Employ with care."
CF_ItmUnlockData[factionid][i] = 3000 -- 0 means available at start
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
	CF_BombOwnerFactions[n] = { "Imperium of Man: Space Wolves" }
	CF_BombUnlockData[n] = 1250

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Explosive Whirlwind Rocket"
	CF_BombPresets[n] = "Imperium Explosive Whirlwind Rocket"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 100
	CF_BombDescriptions[n] =
		"A standard explosive rocket, effective against most targets. Best used for saturation attacks."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Space Wolves" }
	CF_BombUnlockData[n] = 1250

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Incendiary Whirlwind Rocket"
	CF_BombPresets[n] = "Imperium Incendiary Whirlwind Rocket"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 125
	CF_BombDescriptions[n] = "A larger, more powerful rocket with an added incendiary payload for area-denial."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Space Wolves" }
	CF_BombUnlockData[n] = 1500

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "Imperium Plasma Shot"
	CF_BombPresets[n] = "Imperium Plasma Shot"
	CF_BombModules[n] = "w40k.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 250
	CF_BombDescriptions[n] = "A single powerful plasma blast capable of inflicting massive damage."
	CF_BombOwnerFactions[n] = { "Imperium of Man: Space Wolves" }
	CF_BombUnlockData[n] = 2500
end
