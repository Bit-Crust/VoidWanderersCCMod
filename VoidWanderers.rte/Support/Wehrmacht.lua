-- Wehrmacht http://forums.datarealms.com/viewtopic.php?f=61&t=20028 by Kettenkrad
-- Faction file by Weegee
-- Unique Faction ID
local factionid = "Wehrmacht"
print("Loading " .. factionid)

CF["Factions"][#CF["Factions"] + 1] = factionid

-- Faction name
CF["FactionNames"][factionid] = "Wehrmacht"
-- Faction description
CF["FactionDescriptions"][factionid] = ""
-- Set true if faction is selectable by player or AI
CF["FactionPlayable"][factionid] = true

-- Modules needed for this faction
CF["RequiredModules"][factionid] = { "Base.rte", "Wehrmacht.rte" }

-- Set faction nature
CF["FactionNatures"][factionid] = CF["FactionTypes"].ORGANIC

-- Define brain unit
CF["Brains"][factionid] = "Brain Robot"
CF["BrainModules"][factionid] = "Base.rte"
CF["BrainClasses"][factionid] = "AHuman"
CF["BrainPrices"][factionid] = 500

-- Define dropship
CF["Crafts"][factionid] = "Lwf.gPz Saucer D3"
CF["CraftModules"][factionid] = "Wehrmacht.rte"
CF["CraftClasses"][factionid] = "ACDropShip"
CF["CraftPrices"][factionid] = 120

-- Set this flag to indicate that actors of this faction come with pre-equipped weapons
CF["PreEquippedActors"][factionid] = true

-- Define buyable actors available for purchase or unlocks
CF["ActNames"][factionid] = {}
CF["ActPresets"][factionid] = {}
CF["ActModules"][factionid] = {}
CF["ActPrices"][factionid] = {}
CF["ActDescriptions"][factionid] = {}
CF["ActUnlockData"][factionid] = {}
CF["ActClasses"][factionid] = {}
CF["ActTypes"][factionid] = {}
CF["EquipmentTypes"][factionid] = {}
CF["ActPowers"][factionid] = {}
CF["ActOffsets"][factionid] = {}

local i = 0
i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Volks Grenadier"
CF["ActPresets"][factionid][i] = "Volks Grenadier"
CF["ActModules"][factionid][i] = "Wehrmacht.rte"
CF["ActPrices"][factionid][i] = 25
CF["ActDescriptions"][factionid][i] =
	"Standard 2nd Regiment Infantrymen, conscripted fom the masses. These expendable soldiers are perfect for your light duties and forward infantry."
CF["ActUnlockData"][factionid][i] = 0
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ActPowers"][factionid][i] = 2

if CF["ItemsToRemove"] then
	CF["ItemsToRemove"]["Volks Grenadier"] = { "Kar-98k", "Luger", "Panzerfaust", "Model 24" }
end

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Sturm Infanterie"
CF["ActPresets"][factionid][i] = "Sturm Infanterie"
CF["ActModules"][factionid][i] = "Wehrmacht.rte"
CF["ActPrices"][factionid][i] = 120
CF["ActDescriptions"][factionid][i] = "Elite stormtrooper. Armed with an STG-44, an M1912, and M39 grenades."
CF["ActUnlockData"][factionid][i] = 850
CF["ActTypes"][factionid][i] = CF["ActorTypes"].HEAVY
CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ActPowers"][factionid][i] = 4

if CF["ItemsToRemove"] then
	CF["ItemsToRemove"]["Sturm Infanterie"] = { "StG44", "M1912", "M39", "M39" }
end

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Scharfschutze"
CF["ActPresets"][factionid][i] = "Scharfschutze"
CF["ActModules"][factionid][i] = "Wehrmacht.rte"
CF["ActPrices"][factionid][i] = 130
CF["ActDescriptions"][factionid][i] =
	"German sharpshooter. Armed with the deadly semi-automatic sniper rifle G43. As a back-up wapon carries the VSG 1-5, and two land mines for strategic sniping scenarios."
CF["ActUnlockData"][factionid][i] = 1000
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].SNIPER
CF["ActPowers"][factionid][i] = 4

if CF["ItemsToRemove"] then
	CF["ItemsToRemove"]["Scharfschutze"] = { "Gewehr 43", "C96", "S-mine", "S-mine" }
end

-- Looks like these folks are incompatible with 1.05
--i = #CF["ActNames"][factionid] + 1
--CF["ActNames"][factionid][i] = "MG-Schutze"
--CF["ActPresets"][factionid][i] = "MG-Schutze"
--CF["ActModules"][factionid][i] = "Wehrmacht.rte"
--CF["ActPrices"][factionid][i] = 150
--CF["ActDescriptions"][factionid][i] = "All around support trooper, armed primarily with an MG-42 for heavy suppression, VSG 1-5 for backup, and medical supplies."
--CF["ActUnlockData"][factionid][i] = 1500
--CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT;
--CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].HEAVY;
--CF["ActPowers"][factionid][i] = 2

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Fallschirmjager"
CF["ActPresets"][factionid][i] = "Fallschirmjager"
CF["ActModules"][factionid][i] = "Wehrmacht.rte"
CF["ActPrices"][factionid][i] = 185
CF["ActDescriptions"][factionid][i] =
	"Elite paratroopers, masters of camoflauge, equipped with an FG-42, P-24 Revolver, and a deployable recoilless AT rifle."
CF["ActUnlockData"][factionid][i] = 1500
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].SNIPER
CF["ActPowers"][factionid][i] = 6

if CF["ItemsToRemove"] then
	CF["ItemsToRemove"]["Fallschirmjager"] = { "FG42", "P-24 Revolver", "Deployable AT Rifle", "SD2 Designator" }
end

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Flammenkrieger"
CF["ActPresets"][factionid][i] = "Flammenkrieger"
CF["ActModules"][factionid][i] = "Wehrmacht.rte"
CF["ActPrices"][factionid][i] = 350
CF["ActDescriptions"][factionid][i] = "Mrrph mrrph!"
CF["ActUnlockData"][factionid][i] = 2000
CF["ActTypes"][factionid][i] = CF["ActorTypes"].HEAVY
CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].SHOTGUN
CF["ActPowers"][factionid][i] = 7

if CF["DiscardableItems"] then
	CF["DiscardableItems"]["Flammenkrieger"] = { "Der Flammenkrieg" }
end
if CF["ItemsToRemove"] then
	CF["ItemsToRemove"]["Flammenkrieger"] = { "MP40" }
end

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "20mm FlaK 88"
CF["ActPresets"][factionid][i] = "20mm FlaK 88"
CF["ActModules"][factionid][i] = "Wehrmacht.rte"
CF["ActPrices"][factionid][i] = 235
CF["ActDescriptions"][factionid][i] = ""
CF["ActUnlockData"][factionid][i] = 950
CF["ActTypes"][factionid][i] = CF["ActorTypes"].TURRET
CF["EquipmentTypes"][factionid][i] = CF["WeaponTypes"].HEAVY
CF["ActClasses"][factionid][i] = "ACrab"
CF["ActPowers"][factionid][i] = 6

-- Define buyable items available for purchase or unlocks
CF["ItmNames"][factionid] = {}
CF["ItmPresets"][factionid] = {}
CF["ItmModules"][factionid] = {}
CF["ItmPrices"][factionid] = {}
CF["ItmDescriptions"][factionid] = {}
CF["ItmUnlockData"][factionid] = {}
CF["ItmClasses"][factionid] = {}
CF["ItmTypes"][factionid] = {}
CF["ItmPowers"][factionid] = {}

local i = 0
i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Light Digger"
CF["ItmPresets"][factionid][i] = "Light Digger"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 10
CF["ItmDescriptions"][factionid][i] =
	"Lightest in the digger family. Cheapest of them all and works as a nice melee weapon on soft targets."
CF["ItmUnlockData"][factionid][i] = 0 -- 0 means available at start
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].DIGGER
CF["ItmPowers"][factionid][i] = 1

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Medium Digger"
CF["ItmPresets"][factionid][i] = "Medium Digger"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 40
CF["ItmDescriptions"][factionid][i] =
	"Stronger digger. This one can pierce rocks with some effort and dig impressive tunnels and its melee weapon capabilities are much greater."
CF["ItmUnlockData"][factionid][i] = 500
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].DIGGER
CF["ItmPowers"][factionid][i] = 4

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Heavy Digger"
CF["ItmPresets"][factionid][i] = "Heavy Digger"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 100
CF["ItmDescriptions"][factionid][i] =
	"Heaviest and the most powerful of them all. Eats concrete with great hunger and allows you to make complex mining caves incredibly fast. Shreds anyone unfortunate who stand in its way."
CF["ItmUnlockData"][factionid][i] = 1000
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].DIGGER
CF["ItmPowers"][factionid][i] = 8

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Riot Shield"
CF["ItmPresets"][factionid][i] = "Riot Shield"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 20
CF["ItmDescriptions"][factionid][i] =
	"This metal shield provides excellent additional frontal protection to the user and it can stop numerous hits before breaking up."
CF["ItmUnlockData"][factionid][i] = 500
CF["ItmClasses"][factionid][i] = "HeldDevice"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].SHIELD
CF["ItmPowers"][factionid][i] = 1

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Light Scanner"
CF["ItmPresets"][factionid][i] = "Light Scanner"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 10
CF["ItmDescriptions"][factionid][i] =
	"Lightest in the scanner family. Cheapest of them all and can only scan a small area."
CF["ItmUnlockData"][factionid][i] = 150
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].TOOL
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Medium Scanner"
CF["ItmPresets"][factionid][i] = "Medium Scanner"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 40
CF["ItmDescriptions"][factionid][i] = "Medium scanner. This scanner is stronger and can reveal a larger area."
CF["ItmUnlockData"][factionid][i] = 250
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].TOOL
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Heavy Scanner"
CF["ItmPresets"][factionid][i] = "Heavy Scanner"
CF["ItmModules"][factionid][i] = "Base.rte"
CF["ItmPrices"][factionid][i] = 70
CF["ItmDescriptions"][factionid][i] = "Strongest scanner out of the three. Can reveal a large area."
CF["ItmUnlockData"][factionid][i] = 450
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].TOOL
CF["ItmPowers"][factionid][i] = 0
