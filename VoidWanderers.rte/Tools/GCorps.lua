-- <Mod name here> <Mod URL here> by <Mod author here>
-- Faction file by <Faction file contributors here>
--
-- Unique Faction ID
local factionid = "Grimm Military service Contractors"
print("Loading " .. factionid)

CF_Factions[#CF_Factions + 1] = factionid

CF_FactionNames[factionid] = "Grimm Military service Contractors"
CF_FactionDescriptions[factionid] = ""
CF_FactionPlayable[factionid] = true

CF_RequiredModules[factionid] = { "G Corps.rte" }
-- Available values ORGANIC, SYNTHETIC
CF_FactionNatures[factionid] = CF_FactionTypes.ORGANIC

-- Define faction bonuses, in percents
-- Scan price reduction
CF_ScanBonuses[factionid] = 0
-- Relation points increase
CF_RelationsBonuses[factionid] = 0
-- Hew HQ build price reduction
CF_ExpansionBonuses[factionid] = 0

-- Gold per turn increase
CF_MineBonuses[factionid] = 0
-- Science per turn increase
CF_LabBonuses[factionid] = 0
-- Delivery time reduction
CF_AirfieldBonuses[factionid] = 0
-- Superweapon targeting reduction
CF_SuperWeaponBonuses[factionid] = 0
-- Unit price reduction
CF_FactoryBonuses[factionid] = 0
-- Body price reduction
CF_CloneBonuses[factionid] = 0
-- HP regeneration increase
CF_HospitalBonuses[factionid] = 0

-- Define brain unit
CF_Brains[factionid] = "Brain Robot"
CF_BrainModules[factionid] = "Base.rte"
CF_BrainClasses[factionid] = "AHuman"
CF_BrainPrices[factionid] = 500

-- Define dropship
CF_Crafts[factionid] = "Drop Ship MK1"
CF_CraftModules[factionid] = "Base.rte"
CF_CraftClasses[factionid] = "ACDropShip"
CF_CraftPrices[factionid] = 120

-- Define superweapon script
CF_SuperWeaponScripts[factionid] = "UnmappedLands2.rte/SuperWeapons/Bombing.lua"

-- Define buyable actors available for purchase or unlocks
CF_ActNames[factionid] = {}
CF_ActPresets[factionid] = {}
CF_ActModules[factionid] = {}
CF_ActPrices[factionid] = {}
CF_ActDescriptions[factionid] = {}
CF_ActUnlockData[factionid] = {}
CF_ActClasses[factionid] = {}
CF_ActTypes[factionid] = {}
CF_ActPowers[factionid] = {}
CF_ActOffsets[factionid] = {}

local i = 0
i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Assault Medic"
CF_ActPresets[factionid][i] = "Assault Medic"
CF_ActModules[factionid][i] = "G Corps.rte"
CF_ActPrices[factionid][i] = 75
CF_ActDescriptions[factionid][i] = "."
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Assault Infantry"
CF_ActPresets[factionid][i] = "Assault Infantry"
CF_ActModules[factionid][i] = "G Corps.rte"
CF_ActPrices[factionid][i] = 85
CF_ActDescriptions[factionid][i] = "All purpose Soldier."
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Recon"
CF_ActPresets[factionid][i] = "Recon"
CF_ActModules[factionid][i] = "G Corps.rte"
CF_ActPrices[factionid][i] = 75
CF_ActDescriptions[factionid][i] = "Stealthy, flexible and very quick. Runs like the wind."
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Miner"
CF_ActPresets[factionid][i] = "Miner"
CF_ActModules[factionid][i] = "G Corps.rte"
CF_ActPrices[factionid][i] = 80
CF_ActDescriptions[factionid][i] = "Perfect for mining"
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Combat Engineer"
CF_ActPresets[factionid][i] = "Combat Engineer"
CF_ActModules[factionid][i] = "G Corps.rte"
CF_ActPrices[factionid][i] = 85
CF_ActDescriptions[factionid][i] = "Serves as a combat engineer."
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 0

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Squad Leader"
CF_ActPresets[factionid][i] = "Squad Leader"
CF_ActModules[factionid][i] = "G Corps.rte"
CF_ActPrices[factionid][i] = 95
CF_ActDescriptions[factionid][i] = "Leads troops on the Battlefield. Can have a maximum of 3 squad members."
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
CF_ActPowers[factionid][i] = 0

-- Define buyable items available for purchase or unlocks
CF_ItmNames[factionid] = {}
CF_ItmPresets[factionid] = {}
CF_ItmModules[factionid] = {}
CF_ItmPrices[factionid] = {}
CF_ItmDescriptions[factionid] = {}
CF_ItmUnlockData[factionid] = {}
CF_ItmClasses[factionid] = {}
CF_ItmTypes[factionid] = {}
CF_ItmPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use

-- Available weapon types
-- PISTOL, RIFLE, SHOTGUN, SNIPER, HEAVY, SHIELD, DIGGER, GRENADE

local i = 0
i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Pineapple Grenade"
CF_ItmPresets[factionid][i] = "Pineapple Grenade"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 5
CF_ItmDescriptions[factionid][i] =
	"Timed grenade, make sure to throw it away after you've pulled the pin.  Features great explosive power."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Shovel"
CF_ItmPresets[factionid][i] = "Shovel"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 3
CF_ItmDescriptions[factionid][i] = "Ronin's resource collection and bashing device #1."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Compact Assault Rifle"
CF_ItmPresets[factionid][i] = "Compact Assault Rifle"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 40
CF_ItmDescriptions[factionid][i] =
	"Sacrifices stopping power and accuracy for a higher rate of fire.  It also fits easier into your backpack."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "M1 Garand"
CF_ItmPresets[factionid][i] = "M1 Garand"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 45
CF_ItmDescriptions[factionid][i] = "Semi-automatic rifle, excellent for hunting on your opponents!"
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "RPG Mk13th"
CF_ItmPresets[factionid][i] = "RPG Mk13th"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"Powerful and feared weapon in the Ronin arsenal.  Fires accelerating rockets that cause massive damage with a direct hit."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Kar98"
CF_ItmPresets[factionid][i] = "Kar98"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 110
CF_ItmDescriptions[factionid][i] =
	"Powerful sniper rifle.  Long range and precision combined make this a deadly weapon."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "AK-74"
CF_ItmPresets[factionid][i] = "AK-74"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 45
CF_ItmDescriptions[factionid][i] = "An old classic, simple design and cheap parts makes this gun a widespread design."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Desert Eagle"
CF_ItmPresets[factionid][i] = "Desert Eagle"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 25
CF_ItmDescriptions[factionid][i] = "Strong fire-power in the form of a handgun makes this a reliable sidearm."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "TommyGun"
CF_ItmPresets[factionid][i] = "TommyGun"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 35
CF_ItmDescriptions[factionid][i] = "Cheap, realiable and swift.  Buy your Tommy today!"
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Stone"
CF_ItmPresets[factionid][i] = "Stone"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 1
CF_ItmDescriptions[factionid][i] =
	"Throwable stone.  This is the cheapest weapon in the Ronin arsenal, yet very effective because of its long range.  The stone can be picked up after throwing for another go in case it didn't break."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Glock"
CF_ItmPresets[factionid][i] = "Glock"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"Great standard issue sidearm for every troop.  Twelve rounds per clip, decent stopping power and fast reloads."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Assault Rifle"
CF_ItmPresets[factionid][i] = "Assault Rifle"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 65
CF_ItmDescriptions[factionid][i] = "Workhorse of the G Corps army, satisfaction guaranteed or your money back!"
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "RPC M17"
CF_ItmPresets[factionid][i] = "RPC M17"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 240
CF_ItmDescriptions[factionid][i] =
	"Rocket Propelled Chainsaw launcher.  This sadistic weapon can mutilate multiple enemies with one shot.  The launcher holds only one round per clip, so aim wisely."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Stick Grenade"
CF_ItmPresets[factionid][i] = "Stick Grenade"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 5
CF_ItmDescriptions[factionid][i] =
	"German explosive invention which explodes immidiatly on impact.  Handle with extreme caution when using this grenade, especially dropping is not recommended.  It features longer throwing range than the frag grenade."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "MK-34"
CF_ItmPresets[factionid][i] = "MK-34"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 80
CF_ItmDescriptions[factionid][i] = "Accurate and deadly.  Great standard weapon for your troops."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Suiz 16"
CF_ItmPresets[factionid][i] = "Suiz 16"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 40
CF_ItmDescriptions[factionid][i] = "Basic low spread pump action shotgun.  Has long range and moderate power."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Thumper"
CF_ItmPresets[factionid][i] = "Thumper"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 80
CF_ItmDescriptions[factionid][i] =
	"Single-shot grenade launcher.  Can fire Bouncing or Impact grenades.  Select which grenade type to use with the buttons in the Pie Menu."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "L Mk6"
CF_ItmPresets[factionid][i] = "L Mk6"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 120
CF_ItmDescriptions[factionid][i] =
	"Light machine gun.  Its portability combined with steady rate of fire and large ammo capacity makes it a deadly weapon."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Peacemaker"
CF_ItmPresets[factionid][i] = "Peacemaker"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 20
CF_ItmDescriptions[factionid][i] =
	"The best and coolest revolver on the market, its extreme firepower is unmatched to other sidearms available."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Raz 2K6"
CF_ItmPresets[factionid][i] = "Raz 2K6"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 30
CF_ItmDescriptions[factionid][i] =
	"Automatic sidearm with a high rate of fire and quick reload time.  The Uzi can be wielded with a shield."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Chainsaw"
CF_ItmPresets[factionid][i] = "Chainsaw"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 15
CF_ItmDescriptions[factionid][i] =
	"Normally intended for cutting lumber, this tool has been repurposed to be used on light metal, flesh, and whatever else that needs to be violently dismantled."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Spas 12"
CF_ItmPresets[factionid][i] = "Spas 12"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 60
CF_ItmDescriptions[factionid][i] = "Spas 12, the shotgun of tommorow.  It has amazing firepower and high ammo capacity."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Molotov Cocktail"
CF_ItmPresets[factionid][i] = "Molotov Cocktail"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"The classic improvised explosive.  Burns stuff up pretty well, and packs a punch when it explodes too!  Explodes on impact."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Sawed-Off Shotgun"
CF_ItmPresets[factionid][i] = "Sawed-Off Shotgun"
CF_ItmModules[factionid][i] = "G Corps.rte"
CF_ItmPrices[factionid][i] = 20
CF_ItmDescriptions[factionid][i] =
	"Sawed-off double-barreled shotgun.  Can be wielded with a shield.  Only effective at close-quaters."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 0
