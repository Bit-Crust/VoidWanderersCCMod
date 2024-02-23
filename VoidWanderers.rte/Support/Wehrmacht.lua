-- Wehrmacht http://forums.datarealms.com/viewtopic.php?f=61&t=20028 by Kettenkrad
-- Faction file by Weegee
-- Unique Faction ID
local factionid = "Wehrmacht"
print("Loading " .. factionid)

CF_Factions[#CF_Factions + 1] = factionid

-- Faction name
CF_FactionNames[factionid] = "Wehrmacht"
-- Faction description
CF_FactionDescriptions[factionid] = ""
-- Set true if faction is selectable by player or AI
CF_FactionPlayable[factionid] = true

-- Modules needed for this faction
CF_RequiredModules[factionid] = { "Base.rte", "Wehrmacht.rte" }

-- Set faction nature
CF_FactionNatures[factionid] = CF_FactionTypes.ORGANIC

-- Define brain unit
CF_Brains[factionid] = "Brain Robot"
CF_BrainModules[factionid] = "Base.rte"
CF_BrainClasses[factionid] = "AHuman"
CF_BrainPrices[factionid] = 500

-- Define dropship
CF_Crafts[factionid] = "Lwf.gPz Saucer D3"
CF_CraftModules[factionid] = "Wehrmacht.rte"
CF_CraftClasses[factionid] = "ACDropShip"
CF_CraftPrices[factionid] = 120

-- Set this flag to indicate that actors of this faction come with pre-equipped weapons
CF_PreEquippedActors[factionid] = true

-- Define buyable actors available for purchase or unlocks
CF_ActNames[factionid] = {}
CF_ActPresets[factionid] = {}
CF_ActModules[factionid] = {}
CF_ActPrices[factionid] = {}
CF_ActDescriptions[factionid] = {}
CF_ActUnlockData[factionid] = {}
CF_ActClasses[factionid] = {}
CF_ActTypes[factionid] = {}
CF_EquipmentTypes[factionid] = {}
CF_ActPowers[factionid] = {}
CF_ActOffsets[factionid] = {}

local i = 0
i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Volks Grenadier"
CF_ActPresets[factionid][i] = "Volks Grenadier"
CF_ActModules[factionid][i] = "Wehrmacht.rte"
CF_ActPrices[factionid][i] = 25
CF_ActDescriptions[factionid][i] =
	"Standard 2nd Regiment Infantrymen, conscripted fom the masses. These expendable soldiers are perfect for your light duties and forward infantry."
CF_ActUnlockData[factionid][i] = 0
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ActPowers[factionid][i] = 2

if CF_ItemsToRemove then
	CF_ItemsToRemove["Volks Grenadier"] = { "Kar-98k", "Luger", "Panzerfaust", "Model 24" }
end

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Sturm Infanterie"
CF_ActPresets[factionid][i] = "Sturm Infanterie"
CF_ActModules[factionid][i] = "Wehrmacht.rte"
CF_ActPrices[factionid][i] = 120
CF_ActDescriptions[factionid][i] = "Elite stormtrooper. Armed with an STG-44, an M1912, and M39 grenades."
CF_ActUnlockData[factionid][i] = 850
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ActPowers[factionid][i] = 4

if CF_ItemsToRemove then
	CF_ItemsToRemove["Sturm Infanterie"] = { "StG44", "M1912", "M39", "M39" }
end

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Scharfschutze"
CF_ActPresets[factionid][i] = "Scharfschutze"
CF_ActModules[factionid][i] = "Wehrmacht.rte"
CF_ActPrices[factionid][i] = 130
CF_ActDescriptions[factionid][i] =
	"German sharpshooter. Armed with the deadly semi-automatic sniper rifle G43. As a back-up wapon carries the VSG 1-5, and two land mines for strategic sniping scenarios."
CF_ActUnlockData[factionid][i] = 1000
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.SNIPER
CF_ActPowers[factionid][i] = 4

if CF_ItemsToRemove then
	CF_ItemsToRemove["Scharfschutze"] = { "Gewehr 43", "C96", "S-mine", "S-mine" }
end

-- Looks like these folks are incompatible with 1.05
--i = #CF_ActNames[factionid] + 1
--CF_ActNames[factionid][i] = "MG-Schutze"
--CF_ActPresets[factionid][i] = "MG-Schutze"
--CF_ActModules[factionid][i] = "Wehrmacht.rte"
--CF_ActPrices[factionid][i] = 150
--CF_ActDescriptions[factionid][i] = "All around support trooper, armed primarily with an MG-42 for heavy suppression, VSG 1-5 for backup, and medical supplies."
--CF_ActUnlockData[factionid][i] = 1500
--CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT;
--CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.HEAVY;
--CF_ActPowers[factionid][i] = 2

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Fallschirmjager"
CF_ActPresets[factionid][i] = "Fallschirmjager"
CF_ActModules[factionid][i] = "Wehrmacht.rte"
CF_ActPrices[factionid][i] = 185
CF_ActDescriptions[factionid][i] =
	"Elite paratroopers, masters of camoflauge, equipped with an FG-42, P-24 Revolver, and a deployable recoilless AT rifle."
CF_ActUnlockData[factionid][i] = 1500
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.SNIPER
CF_ActPowers[factionid][i] = 6

if CF_ItemsToRemove then
	CF_ItemsToRemove["Fallschirmjager"] = { "FG42", "P-24 Revolver", "Deployable AT Rifle", "SD2 Designator" }
end

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Flammenkrieger"
CF_ActPresets[factionid][i] = "Flammenkrieger"
CF_ActModules[factionid][i] = "Wehrmacht.rte"
CF_ActPrices[factionid][i] = 350
CF_ActDescriptions[factionid][i] = "Mrrph mrrph!"
CF_ActUnlockData[factionid][i] = 2000
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ActPowers[factionid][i] = 7

if CF_DiscardableItems then
	CF_DiscardableItems["Flammenkrieger"] = { "Der Flammenkrieg" }
end
if CF_ItemsToRemove then
	CF_ItemsToRemove["Flammenkrieger"] = { "MP40" }
end

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "20mm FlaK 88"
CF_ActPresets[factionid][i] = "20mm FlaK 88"
CF_ActModules[factionid][i] = "Wehrmacht.rte"
CF_ActPrices[factionid][i] = 235
CF_ActDescriptions[factionid][i] = ""
CF_ActUnlockData[factionid][i] = 950
CF_ActTypes[factionid][i] = CF_ActorTypes.TURRET
CF_EquipmentTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ActClasses[factionid][i] = "ACrab"
CF_ActPowers[factionid][i] = 6

-- Define buyable items available for purchase or unlocks
CF_ItmNames[factionid] = {}
CF_ItmPresets[factionid] = {}
CF_ItmModules[factionid] = {}
CF_ItmPrices[factionid] = {}
CF_ItmDescriptions[factionid] = {}
CF_ItmUnlockData[factionid] = {}
CF_ItmClasses[factionid] = {}
CF_ItmTypes[factionid] = {}
CF_ItmPowers[factionid] = {}

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
CF_ItmNames[factionid][i] = "Riot Shield"
CF_ItmPresets[factionid][i] = "Riot Shield"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 20
CF_ItmDescriptions[factionid][i] =
	"This metal shield provides excellent additional frontal protection to the user and it can stop numerous hits before breaking up."
CF_ItmUnlockData[factionid][i] = 500
CF_ItmClasses[factionid][i] = "HeldDevice"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Light Scanner"
CF_ItmPresets[factionid][i] = "Light Scanner"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"Lightest in the scanner family. Cheapest of them all and can only scan a small area."
CF_ItmUnlockData[factionid][i] = 150
CF_ItmTypes[factionid][i] = CF_WeaponTypes.TOOL
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Medium Scanner"
CF_ItmPresets[factionid][i] = "Medium Scanner"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 40
CF_ItmDescriptions[factionid][i] = "Medium scanner. This scanner is stronger and can reveal a larger area."
CF_ItmUnlockData[factionid][i] = 250
CF_ItmTypes[factionid][i] = CF_WeaponTypes.TOOL
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Heavy Scanner"
CF_ItmPresets[factionid][i] = "Heavy Scanner"
CF_ItmModules[factionid][i] = "Base.rte"
CF_ItmPrices[factionid][i] = 70
CF_ItmDescriptions[factionid][i] = "Strongest scanner out of the three. Can reveal a large area."
CF_ItmUnlockData[factionid][i] = 450
CF_ItmTypes[factionid][i] = CF_WeaponTypes.TOOL
CF_ItmPowers[factionid][i] = 0
