-- This script serves as an example of a custom faction file for Void Wanderers!

-- Unique Faction ID
local factionid = "Coalition"

CF["Factions"][#CF["Factions"] + 1] = factionid

-- Faction name
CF["FactionNames"][factionid] = "Coalition"
-- Faction description
CF["FactionDescriptions"][factionid] =
	"A militarized organization, the Coalition produce a large array of units and weaponry to choose from. They are versatile and powerful, making them a strong ally or a dangerous foe."
-- Set true if faction is selectable by player or AI
CF["FactionPlayable"][factionid] = true

-- Modules needed for this faction
CF["RequiredModules"][factionid] = { "Base.rte", "Coalition.rte" }

-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
-- Default - {CF["WeaponTypes"].DIGGER, CF["WeaponTypes"].RIFLE}
CF["PreferedBrainInventory"][factionid] = { CF["WeaponTypes"].HEAVY, CF["WeaponTypes"].RIFLE }

-- Define brain unit
CF["Brains"][factionid] = "Brain Robot"
CF["BrainModules"][factionid] = "Base.rte"
CF["BrainClasses"][factionid] = "AHuman"
CF["BrainPrices"][factionid] = 500

-- Define dropship
CF["Crafts"][factionid] = "Dropship MK1"
CF["CraftModules"][factionid] = "Base.rte"
CF["CraftClasses"][factionid] = "ACDropShip"
CF["CraftPrices"][factionid] = 500

-- Define buyable actors available for purchase or unlocks
CF["ActNames"][factionid] = {}
CF["ActPresets"][factionid] = {}
CF["ActModules"][factionid] = {}
CF["ActPrices"][factionid] = {}
CF["ActDescriptions"][factionid] = {}
CF["ActUnlockData"][factionid] = {}
CF["ActClasses"][factionid] = {}
CF["ActTypes"][factionid] = {} -- AI will select different weapons based on this value
CF["ActPowers"][factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 - toughest, 0 - never use
CF["ActOffsets"][factionid] = {}

-- Available values ORGANIC, SYNTHETIC: both are automatically mildly disliked by each other at the start of the game
CF["FactionNatures"][factionid] = CF["FactionTypes"].ORGANIC

-- Available actor types
-- LIGHT, HEAVY, ARMOR, TURRET

local i = 0

-- Faction actors

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Soldier Light"
CF["ActPresets"][factionid][i] = "Soldier Light"
CF["ActModules"][factionid][i] = "Coalition.rte"
CF["ActPrices"][factionid][i] = 120
CF["ActDescriptions"][factionid][i] =
	"Standard Coalition soldier equipped with armor and a jetpack.  Very resilient and quick."
CF["ActUnlockData"][factionid][i] = 0 -- 0 means available at start
CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
CF["ActPowers"][factionid][i] = 5

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Soldier Heavy"
CF["ActPresets"][factionid][i] = "Soldier Heavy"
CF["ActModules"][factionid][i] = "Coalition.rte"
CF["ActPrices"][factionid][i] = 160
CF["ActDescriptions"][factionid][i] =
	"A Coalition trooper upgraded with stronger armor.  A bit heavier and a bit less agile than the Light Soldier, but more than makes up for it with its strength."
CF["ActUnlockData"][factionid][i] = 2200
CF["ActTypes"][factionid][i] = CF["ActorTypes"].HEAVY
CF["ActPowers"][factionid][i] = 6

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Gatling Drone"
CF["ActPresets"][factionid][i] = "Gatling Drone"
CF["ActModules"][factionid][i] = "Coalition.rte"
CF["ActPrices"][factionid][i] = 200
CF["ActDescriptions"][factionid][i] =
	"Heavily armored drone equipped with a Gatling Gun.  This tank can mow down waves of enemy soldiers and can take a beating."
CF["ActUnlockData"][factionid][i] = 3000
CF["ActClasses"][factionid][i] = "ACrab"
CF["ActTypes"][factionid][i] = CF["ActorTypes"].ARMOR
CF["ActPowers"][factionid][i] = 8
CF["ActOffsets"][factionid][i] = Vector(0, 12)

i = #CF["ActNames"][factionid] + 1
CF["ActNames"][factionid][i] = "Gatling Turret"
CF["ActPresets"][factionid][i] = "Gatling Turret"
CF["ActModules"][factionid][i] = "Coalition.rte"
CF["ActPrices"][factionid][i] = 250
CF["ActDescriptions"][factionid][i] =
	"Heavily armored turret equipped with a Gatling Gun. Like the Gatling Drone, but without legs and with more ammo."
CF["ActUnlockData"][factionid][i] = 1000
CF["ActClasses"][factionid][i] = "ACrab"
CF["ActTypes"][factionid][i] = CF["ActorTypes"].TURRET
CF["ActPowers"][factionid][i] = 9
CF["ActOffsets"][factionid][i] = Vector(0, 12)

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

-- Base actors and items (automatic stuff, no need to change these unless you want to)

local baseActors = {}
baseActors[#baseActors + 1] = { presetName = "Medic Drone", class = "ACrab", unlockData = 1000, actorPowers = 0 }

local baseItems = {}
baseItems[#baseItems + 1] = { presetName = "Remote Explosive", class = "TDExplosive", unlockData = 500, itemPowers = 0 }
baseItems[#baseItems + 1] = {
	presetName = "Anti Personnel Mine",
	class = "TDExplosive",
	unlockData = 900,
	itemPowers = 0,
}
baseItems[#baseItems + 1] = {
	presetName = "Light Digger",
	class = "HDFirearm",
	unlockData = 0,
	itemPowers = 1,
	weaponType = CF["WeaponTypes"].DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Medium Digger",
	class = "HDFirearm",
	unlockData = 600,
	itemPowers = 3,
	weaponType = CF["WeaponTypes"].DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Heavy Digger",
	class = "HDFirearm",
	unlockData = 1200,
	itemPowers = 5,
	weaponType = CF["WeaponTypes"].DIGGER,
}
baseItems[#baseItems + 1] = { presetName = "Detonator", class = "HDFirearm", unlockData = 500, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Grapple Gun", class = "HDFirearm", unlockData = 1100, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Medikit", class = "HDFirearm", unlockData = 700, itemPowers = 3 }
baseItems[#baseItems + 1] = { presetName = "Disarmer", class = "HDFirearm", unlockData = 900, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Constructor", class = "HDFirearm", unlockData = 1000, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Scanner", class = "HDFirearm", unlockData = 600, itemPowers = 0 }
baseItems[#baseItems + 1] = { presetName = "Riot Shield", class = "HeldDevice", unlockData = 500, itemPowers = 1 }
-- Add said actors and items
for j = 1, #baseActors do
	local actor
	i = #CF["ActNames"][factionid] + 1
	if baseActors[j].class == "ACrab" then
		actor = CreateACrab(baseActors[j].presetName, "Base.rte")
		CF["ActTypes"][factionid][i] = CF["ActorTypes"].ARMOR
		CF["ActOffsets"][factionid][i] = Vector(0, 12)
	elseif baseActors[j].class == "AHuman" then
		actor = CreateAHuman(baseActors[j].presetName, "Base.rte")
		CF["ActTypes"][factionid][i] = CF["ActorTypes"].LIGHT
	end
	if actor then
		CF["ActNames"][factionid][i] = actor.PresetName
		CF["ActPresets"][factionid][i] = actor.PresetName
		CF["ActModules"][factionid][i] = "Base.rte"
		CF["ActPrices"][factionid][i] = actor:GetGoldValue(0, 1, 1)
		CF["ActDescriptions"][factionid][i] = actor.Description

		CF["ActUnlockData"][factionid][i] = baseActors[j].unlockData
		CF["ActPowers"][factionid][i] = baseActors[j].actorPowers
		CF["ActClasses"][factionid][i] = actor.ClassName
		DeleteEntity(actor)
	end
end
for j = 1, #baseItems do
	local item
	i = #CF["ItmNames"][factionid] + 1
	if baseItems[j].class == "TDExplosive" then
		item = CreateTDExplosive(baseItems[j].presetName, "Base.rte")
		CF["ItmTypes"][factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF["WeaponTypes"].GRENADE
	elseif baseItems[j].class == "HDFirearm" then
		item = CreateHDFirearm(baseItems[j].presetName, "Base.rte")
		CF["ItmTypes"][factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF["WeaponTypes"].TOOL
	elseif baseItems[j].class == "HeldDevice" then
		item = CreateHeldDevice(baseItems[j].presetName, "Base.rte")
		CF["ItmTypes"][factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF["WeaponTypes"].SHIELD
	end
	if item then
		CF["ItmNames"][factionid][i] = item.PresetName
		CF["ItmPresets"][factionid][i] = item.PresetName
		CF["ItmModules"][factionid][i] = "Base.rte"
		CF["ItmPrices"][factionid][i] = item:GetGoldValue(0, 1, 1)
		CF["ItmDescriptions"][factionid][i] = item.Description
		CF["ItmClasses"][factionid][i] = item.ClassName

		CF["ItmUnlockData"][factionid][i] = baseItems[j].unlockData
		CF["ItmPowers"][factionid][i] = baseItems[j].itemPowers
		DeleteEntity(item)
	end
end

-- Faction items

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Auto Pistol"
CF["ItmPresets"][factionid][i] = "Auto Pistol"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 18
CF["ItmDescriptions"][factionid][i] =
	"Semi-auto is yesterday's business. High ammo capacity combined with rapid 3-round burst fire make this pistol more than just a sidearm!"
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].PISTOL
CF["ItmPowers"][factionid][i] = 2

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Heavy Pistol"
CF["ItmPresets"][factionid][i] = "Heavy Pistol"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 25
CF["ItmDescriptions"][factionid][i] =
	"Offering more firepower than any other pistol on the market, the Heavy Pistol is a reliable sidearm. It fires slowly, but its shots have some serious stopping power."
CF["ItmUnlockData"][factionid][i] = 900
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].PISTOL
CF["ItmPowers"][factionid][i] = 3

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Compact Assault Rifle"
CF["ItmPresets"][factionid][i] = "Compact Assault Rifle"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 30
CF["ItmDescriptions"][factionid][i] =
	"Sacrifices stopping power and accuracy for a higher rate of fire.  It also fits easier into your backpack."
CF["ItmUnlockData"][factionid][i] = 0
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 4

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Assault Rifle"
CF["ItmPresets"][factionid][i] = "Assault Rifle"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 50
CF["ItmDescriptions"][factionid][i] = "Workhorse of the Coalition army, satisfaction guaranteed or your money back!"
CF["ItmUnlockData"][factionid][i] = 1100
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].RIFLE
CF["ItmPowers"][factionid][i] = 5

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Sniper Rifle"
CF["ItmPresets"][factionid][i] = "Sniper Rifle"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 70
CF["ItmDescriptions"][factionid][i] =
	"Coalition special issue, semi-automatic precision rifle.  Complete with scope for long distance shooting."
CF["ItmUnlockData"][factionid][i] = 1400
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].SNIPER
CF["ItmPowers"][factionid][i] = 5

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Shotgun"
CF["ItmPresets"][factionid][i] = "Shotgun"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 40
CF["ItmDescriptions"][factionid][i] = "A light shotgun with six shots and moderate reload time."
CF["ItmUnlockData"][factionid][i] = 800
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].SHOTGUN
CF["ItmPowers"][factionid][i] = 4

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Auto Shotgun"
CF["ItmPresets"][factionid][i] = "Auto Shotgun"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 60
CF["ItmDescriptions"][factionid][i] =
	"Fully automatic shotgun. The weapon can easily take down flying and fast moving targets with its high rate of fire."
CF["ItmUnlockData"][factionid][i] = 1300
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].SHOTGUN
CF["ItmPowers"][factionid][i] = 6

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Gatling Gun"
CF["ItmPresets"][factionid][i] = "Gatling Gun"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 120
CF["ItmDescriptions"][factionid][i] =
	"Coalition's feared heavy weapon that features a large magazine and amazing firepower. Reloading is not an issue because there is enough ammo to kill everyone even remotely close."
CF["ItmUnlockData"][factionid][i] = 2600
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].HEAVY
CF["ItmPowers"][factionid][i] = 8

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Grenade Launcher"
CF["ItmPresets"][factionid][i] = "Grenade Launcher"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 90
CF["ItmDescriptions"][factionid][i] =
	"Automatic grenade launcher with three different modes.  Detonate remote-controlled grenades by selecting the 'Detonate Grenades' button in the pie menu."
CF["ItmUnlockData"][factionid][i] = 2200
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].HEAVY
CF["ItmPowers"][factionid][i] = 9

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Missile Launcher"
CF["ItmPresets"][factionid][i] = "Missile Launcher"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 150
CF["ItmDescriptions"][factionid][i] =
	"Can fire powerful automatically guided missiles, excellent at destroying enemy craft.  Lock-on to enemy units using the laser pointer!"
CF["ItmUnlockData"][factionid][i] = 3000
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].HEAVY
CF["ItmPowers"][factionid][i] = 10

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Uber Cannon"
CF["ItmPresets"][factionid][i] = "Uber Cannon"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 150
CF["ItmDescriptions"][factionid][i] =
	"Uber Cannon. A shoulder mounted, tactical artillery weapon that fires air-bursting cluster bombs. Features a trajectory guide to help with long-ranged shots."
CF["ItmUnlockData"][factionid][i] = 3200
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].HEAVY
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Frag Grenade"
CF["ItmPresets"][factionid][i] = "Frag Grenade"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 10
CF["ItmDescriptions"][factionid][i] =
	"Explosive fragmentation grenade. Perfect for clearing awkward bunkers. Blows up after a 4 second delay."
CF["ItmUnlockData"][factionid][i] = 300
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 1

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Incendiary Grenade"
CF["ItmPresets"][factionid][i] = "Incendiary Grenade"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 20
CF["ItmDescriptions"][factionid][i] =
	"Upon detonation, this grenade produces molten iron by means of a chemical reaction.  In other words: use the three seconds you have to get out of its way!"
CF["ItmUnlockData"][factionid][i] = 700
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 2

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Cluster Grenade"
CF["ItmPresets"][factionid][i] = "Cluster Grenade"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 20
CF["ItmDescriptions"][factionid][i] =
	"Explosive cluster grenade.  Awesome power!  Blows up spreading many explosive clusters after a 4 second delay."
CF["ItmUnlockData"][factionid][i] = 700
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 3

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Timed Explosive"
CF["ItmPresets"][factionid][i] = "Timed Explosive"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 30
CF["ItmDescriptions"][factionid][i] =
	"Destructive plantable explosive charge.  You can stick this into a wall, door or anything else stationary.  After planting, run for your life, as it explodes after 10 seconds."
CF["ItmUnlockData"][factionid][i] = 1000
CF["ItmClasses"][factionid][i] = "TDExplosive"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].GRENADE
CF["ItmPowers"][factionid][i] = 0

i = #CF["ItmNames"][factionid] + 1
CF["ItmNames"][factionid][i] = "Combat Shield"
CF["ItmPresets"][factionid][i] = "Combat Shield"
CF["ItmModules"][factionid][i] = "Coalition.rte"
CF["ItmPrices"][factionid][i] = 30
CF["ItmDescriptions"][factionid][i] =
	"In addition to offering enhanced protection from ballistics, this lightweight shield is also designed to fit any Coalition-manufactured firearm as an attachment."
CF["ItmUnlockData"][factionid][i] = 1000
CF["ItmClasses"][factionid][i] = "HeldDevice"
CF["ItmTypes"][factionid][i] = CF["WeaponTypes"].SHIELD
CF["ItmPowers"][factionid][i] = 3
