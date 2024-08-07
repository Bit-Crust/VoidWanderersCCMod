-- <Mod name here> <Mod URL here> by <Mod author here>
-- Faction file by <Faction file contributors here>
--
-- Unique Faction ID
local factionid = "Grimm Military service Contractors"
print("Loading " .. factionid)

CF["Factions"][#CF["Factions"] + 1] = factionid

CF["FactionNames"][factionid] = "Grimm Military service Contractors"
CF["FactionDescriptions"][factionid] = ""
CF["FactionPlayable"][factionid] = true

CF["RequiredModules"][factionid] = { "G Corps.rte" }
-- Available values ORGANIC, SYNTHETIC
CF["FactionNatures"][factionid] = CF["FactionTypes"].ORGANIC

-- Define faction bonuses, in percents
-- Scan price reduction
CF["ScanBonuses"][factionid] = 0
-- Relation points increase
CF["RelationsBonuses"][factionid] = 0
-- Hew HQ build price reduction
CF["ExpansionBonuses"][factionid] = 0

-- Gold per turn increase
CF["MineBonuses"][factionid] = 0
-- Science per turn increase
CF["LabBonuses"][factionid] = 0
-- Delivery time reduction
CF["AirfieldBonuses"][factionid] = 0
-- Superweapon targeting reduction
CF["SuperWeaponBonuses"][factionid] = 0
-- Unit price reduction
CF["FactoryBonuses"][factionid] = 0
-- Body price reduction
CF["CloneBonuses"][factionid] = 0
-- HP regeneration increase
CF["HospitalBonuses"][factionid] = 0

-- Define brain unit
CF["Brains"][factionid] = "Brain Robot"
CF["BrainModules"][factionid] = "Base.rte"
CF["BrainClasses"][factionid] = "AHuman"
CF["BrainPrices"][factionid] = 500

-- Define dropship
CF["Crafts"][factionid] = "Drop Ship MK1"
CF["CraftModules"][factionid] = "Base.rte"
CF["CraftClasses"][factionid] = "ACDropShip"
CF["CraftPrices"][factionid] = 120

-- Define superweapon script
CF["SuperWeaponScripts"][factionid] = "UnmappedLands2.rte/SuperWeapons/Bombing.lua"

-- Define buyable actors available for purchase or unlocks
CF["ActNames"][factionid] = {}
CF["ActPresets"][factionid] = {}
CF["ActModules"][factionid] = {}
CF["ActPrices"][factionid] = {}
CF["ActDescriptions"][factionid] = {}
CF["ActUnlockData"][factionid] = {}
CF["ActClasses"][factionid] = {}
CF["ActTypes"][factionid] = {}
CF["ActPowers"][factionid] = {}
CF["ActOffsets"][factionid] = {}

local i = 0
i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Assault Medic"
CF["ActPresets"][factionid][i] = "Assault Medic"
CF["ActModules"][factionid][i] = "G Corps.rte"
CF["ActPrices"][factionid][i] = 75
CF["ActDescriptions"][factionid][i] = "."
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["ActPowers"][factionid][i] = 0

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Assault Infantry"
CF["ActPresets"][factionid][i] = "Assault Infantry"
CF["ActModules"][factionid][i] = "G Corps.rte"
CF["ActPrices"][factionid][i] = 85
CF["ActDescriptions"][factionid][i] = "All purpose Soldier."
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["ActPowers"][factionid][i] = 0

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Recon"
CF["ActPresets"][factionid][i] = "Recon"
CF["ActModules"][factionid][i] = "G Corps.rte"
CF["ActPrices"][factionid][i] = 75
CF["ActDescriptions"][factionid][i] = "Stealthy, flexible and very quick. Runs like the wind."
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["ActPowers"][factionid][i] = 0

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Miner"
CF["ActPresets"][factionid][i] = "Miner"
CF["ActModules"][factionid][i] = "G Corps.rte"
CF["ActPrices"][factionid][i] = 80
CF["ActDescriptions"][factionid][i] = "Perfect for mining"
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["ActPowers"][factionid][i] = 0

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Combat Engineer"
CF["ActPresets"][factionid][i] = "Combat Engineer"
CF["ActModules"][factionid][i] = "G Corps.rte"
CF["ActPrices"][factionid][i] = 85
CF["ActDescriptions"][factionid][i] = "Serves as a combat engineer."
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["ActPowers"][factionid][i] = 0

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Squad Leader"
CF["ActPresets"][factionid][i] = "Squad Leader"
CF["ActModules"][factionid][i] = "G Corps.rte"
CF["ActPrices"][factionid][i] = 95
CF["ActDescriptions"][factionid][i] = "Leads troops on the Battlefield. Can have a maximum of 3 squad members."
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].HEAVY
CF["ActPowers"][factionid][i] = 0

-- Define buyable items available for purchase or unlocks
CF["ItmNames"][factionid] = {}
CF["ItmPresets"][factionid] = {}
CF["ItmModules"][factionid] = {}
CF["ItmPrices"][factionid] = {}
CF["ItmDescriptions"][factionid] = {}
CF["ItmUnlockData"][factionid] = {}
CF["ItmClasses"][factionid] = {}
CF["ItmTypes"][factionid] = {}
CF["ItmPowers"][factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 toughest, 0 never use

-- Available weapon types
-- PISTOL, RIFLE, SHOTGUN, SNIPER, HEAVY, SHIELD, DIGGER, GRENADE

local i = 0
i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Pineapple Grenade"
CF["ItmPresets"][factionid][i] = "Pineapple Grenade"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 5
CF["ItmDescriptions"][factionid][i] =
	"Timed grenade, make sure to throw it away after you've pulled the pin.  Features great explosive power."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Shovel"
CF["ItmPresets"][factionid][i] = "Shovel"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 3
CF["ItmDescriptions"][factionid][i] = "Ronin's resource collection and bashing device #1."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Compact Assault Rifle"
CF["ItmPresets"][factionid][i] = "Compact Assault Rifle"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 40
CF["ItmDescriptions"][factionid][i] =
	"Sacrifices stopping power and accuracy for a higher rate of fire.  It also fits easier into your backpack."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "M1 Garand"
CF["ItmPresets"][factionid][i] = "M1 Garand"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 45
CF["ItmDescriptions"][factionid][i] = "Semi-automatic rifle, excellent for hunting on your opponents!"
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "RPG Mk13th"
CF["ItmPresets"][factionid][i] = "RPG Mk13th"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 150
CF["ItmDescriptions"][factionid][i] =
	"Powerful and feared weapon in the Ronin arsenal.  Fires accelerating rockets that cause massive damage with a direct hit."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Kar98"
CF["ItmPresets"][factionid][i] = "Kar98"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 110
CF["ItmDescriptions"][factionid][i] =
	"Powerful sniper rifle.  Long range and precision combined make this a deadly weapon."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "AK-74"
CF["ItmPresets"][factionid][i] = "AK-74"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 45
CF["ItmDescriptions"][factionid][i] = "An old classic, simple design and cheap parts makes this gun a widespread design."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Desert Eagle"
CF["ItmPresets"][factionid][i] = "Desert Eagle"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 25
CF["ItmDescriptions"][factionid][i] = "Strong fire-power in the form of a handgun makes this a reliable sidearm."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "TommyGun"
CF["ItmPresets"][factionid][i] = "TommyGun"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 35
CF["ItmDescriptions"][factionid][i] = "Cheap, realiable and swift.  Buy your Tommy today!"
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Stone"
CF["ItmPresets"][factionid][i] = "Stone"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 1
CF["ItmDescriptions"][factionid][i] =
	"Throwable stone.  This is the cheapest weapon in the Ronin arsenal, yet very effective because of its long range.  The stone can be picked up after throwing for another go in case it didn't break."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Glock"
CF["ItmPresets"][factionid][i] = "Glock"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 10
CF["ItmDescriptions"][factionid][i] =
	"Great standard issue sidearm for every troop.  Twelve rounds per clip, decent stopping power and fast reloads."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Assault Rifle"
CF["ItmPresets"][factionid][i] = "Assault Rifle"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 65
CF["ItmDescriptions"][factionid][i] = "Workhorse of the G Corps army, satisfaction guaranteed or your money back!"
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "RPC M17"
CF["ItmPresets"][factionid][i] = "RPC M17"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 240
CF["ItmDescriptions"][factionid][i] =
	"Rocket Propelled Chainsaw launcher.  This sadistic weapon can mutilate multiple enemies with one shot.  The launcher holds only one round per clip, so aim wisely."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Stick Grenade"
CF["ItmPresets"][factionid][i] = "Stick Grenade"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 5
CF["ItmDescriptions"][factionid][i] =
	"German explosive invention which explodes immidiatly on impact.  Handle with extreme caution when using this grenade, especially dropping is not recommended.  It features longer throwing range than the frag grenade."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "MK-34"
CF["ItmPresets"][factionid][i] = "MK-34"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 80
CF["ItmDescriptions"][factionid][i] = "Accurate and deadly.  Great standard weapon for your troops."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Suiz 16"
CF["ItmPresets"][factionid][i] = "Suiz 16"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 40
CF["ItmDescriptions"][factionid][i] = "Basic low spread pump action shotgun.  Has long range and moderate power."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Thumper"
CF["ItmPresets"][factionid][i] = "Thumper"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 80
CF["ItmDescriptions"][factionid][i] =
	"Single-shot grenade launcher.  Can fire Bouncing or Impact grenades.  Select which grenade type to use with the buttons in the Pie Menu."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "L Mk6"
CF["ItmPresets"][factionid][i] = "L Mk6"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 120
CF["ItmDescriptions"][factionid][i] =
	"Light machine gun.  Its portability combined with steady rate of fire and large ammo capacity makes it a deadly weapon."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Peacemaker"
CF["ItmPresets"][factionid][i] = "Peacemaker"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 20
CF["ItmDescriptions"][factionid][i] =
	"The best and coolest revolver on the market, its extreme firepower is unmatched to other sidearms available."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Raz 2K6"
CF["ItmPresets"][factionid][i] = "Raz 2K6"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 30
CF["ItmDescriptions"][factionid][i] =
	"Automatic sidearm with a high rate of fire and quick reload time.  The Uzi can be wielded with a shield."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Chainsaw"
CF["ItmPresets"][factionid][i] = "Chainsaw"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 15
CF["ItmDescriptions"][factionid][i] =
	"Normally intended for cutting lumber, this tool has been repurposed to be used on light metal, flesh, and whatever else that needs to be violently dismantled."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Spas 12"
CF["ItmPresets"][factionid][i] = "Spas 12"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 60
CF["ItmDescriptions"][factionid][i] = "Spas 12, the shotgun of tommorow.  It has amazing firepower and high ammo capacity."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Molotov Cocktail"
CF["ItmPresets"][factionid][i] = "Molotov Cocktail"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 10
CF["ItmDescriptions"][factionid][i] =
	"The classic improvised explosive.  Burns stuff up pretty well, and packs a punch when it explodes too!  Explodes on impact."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Sawed-Off Shotgun"
CF["ItmPresets"][factionid][i] = "Sawed-Off Shotgun"
CF["ItmModules"][factionid][i] = "G Corps.rte"
CF["ItmPrices"][factionid][i] = 20
CF["ItmDescriptions"][factionid][i] =
	"Sawed-off double-barreled shotgun.  Can be wielded with a shield.  Only effective at close-quaters."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 0
