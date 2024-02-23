-- This script serves as an example of a custom faction file for Void Wanderers!

-- Unique Faction ID
local factionid = "Coalition"

CF_Factions[#CF_Factions + 1] = factionid

-- Faction name
CF_FactionNames[factionid] = "Coalition"
-- Faction description
CF_FactionDescriptions[factionid] =
	"A militarized organization, the Coalition produce a large array of units and weaponry to choose from. They are versatile and powerful, making them a strong ally or a dangerous foe."
-- Set true if faction is selectable by player or AI
CF_FactionPlayable[factionid] = true

-- Modules needed for this faction
CF_RequiredModules[factionid] = { "Base.rte", "Coalition.rte" }

-- Prefered brain inventory items. Brain gets the best available items of the classes specified in list for free.
-- Default - {CF_WeaponTypes.DIGGER, CF_WeaponTypes.RIFLE}
CF_PreferedBrainInventory[factionid] = { CF_WeaponTypes.HEAVY, CF_WeaponTypes.RIFLE }

-- Define brain unit
CF_Brains[factionid] = "Brain Robot"
CF_BrainModules[factionid] = "Base.rte"
CF_BrainClasses[factionid] = "AHuman"
CF_BrainPrices[factionid] = 500

-- Define dropship
CF_Crafts[factionid] = "Dropship MK1"
CF_CraftModules[factionid] = "Base.rte"
CF_CraftClasses[factionid] = "ACDropShip"
CF_CraftPrices[factionid] = 500

-- Define buyable actors available for purchase or unlocks
CF_ActNames[factionid] = {}
CF_ActPresets[factionid] = {}
CF_ActModules[factionid] = {}
CF_ActPrices[factionid] = {}
CF_ActDescriptions[factionid] = {}
CF_ActUnlockData[factionid] = {}
CF_ActClasses[factionid] = {}
CF_ActTypes[factionid] = {} -- AI will select different weapons based on this value
CF_ActPowers[factionid] = {} -- AI will select weapons based on this value 1 - weakest, 10 - toughest, 0 - never use
CF_ActOffsets[factionid] = {}

-- Available values ORGANIC, SYNTHETIC: both are automatically mildly disliked by each other at the start of the game
CF_FactionNatures[factionid] = CF_FactionTypes.ORGANIC

-- Available actor types
-- LIGHT, HEAVY, ARMOR, TURRET

local i = 0

-- Faction actors

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Soldier Light"
CF_ActPresets[factionid][i] = "Soldier Light"
CF_ActModules[factionid][i] = "Coalition.rte"
CF_ActPrices[factionid][i] = 120
CF_ActDescriptions[factionid][i] =
	"Standard Coalition soldier equipped with armor and a jetpack.  Very resilient and quick."
CF_ActUnlockData[factionid][i] = 0 -- 0 means available at start
CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
CF_ActPowers[factionid][i] = 5

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Soldier Heavy"
CF_ActPresets[factionid][i] = "Soldier Heavy"
CF_ActModules[factionid][i] = "Coalition.rte"
CF_ActPrices[factionid][i] = 160
CF_ActDescriptions[factionid][i] =
	"A Coalition trooper upgraded with stronger armor.  A bit heavier and a bit less agile than the Light Soldier, but more than makes up for it with its strength."
CF_ActUnlockData[factionid][i] = 2200
CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
CF_ActPowers[factionid][i] = 6

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Gatling Drone"
CF_ActPresets[factionid][i] = "Gatling Drone"
CF_ActModules[factionid][i] = "Coalition.rte"
CF_ActPrices[factionid][i] = 200
CF_ActDescriptions[factionid][i] =
	"Heavily armored drone equipped with a Gatling Gun.  This tank can mow down waves of enemy soldiers and can take a beating."
CF_ActUnlockData[factionid][i] = 3000
CF_ActClasses[factionid][i] = "ACrab"
CF_ActTypes[factionid][i] = CF_ActorTypes.ARMOR
CF_ActPowers[factionid][i] = 8
CF_ActOffsets[factionid][i] = Vector(0, 12)

i = #CF_ActNames[factionid] + 1
CF_ActNames[factionid][i] = "Gatling Turret"
CF_ActPresets[factionid][i] = "Gatling Turret"
CF_ActModules[factionid][i] = "Coalition.rte"
CF_ActPrices[factionid][i] = 250
CF_ActDescriptions[factionid][i] =
	"Heavily armored turret equipped with a Gatling Gun. Like the Gatling Drone, but without legs and with more ammo."
CF_ActUnlockData[factionid][i] = 1000
CF_ActClasses[factionid][i] = "ACrab"
CF_ActTypes[factionid][i] = CF_ActorTypes.TURRET
CF_ActPowers[factionid][i] = 9
CF_ActOffsets[factionid][i] = Vector(0, 12)

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
	weaponType = CF_WeaponTypes.DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Medium Digger",
	class = "HDFirearm",
	unlockData = 600,
	itemPowers = 3,
	weaponType = CF_WeaponTypes.DIGGER,
}
baseItems[#baseItems + 1] = {
	presetName = "Heavy Digger",
	class = "HDFirearm",
	unlockData = 1200,
	itemPowers = 5,
	weaponType = CF_WeaponTypes.DIGGER,
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
	i = #CF_ActNames[factionid] + 1
	if baseActors[j].class == "ACrab" then
		actor = CreateACrab(baseActors[j].presetName, "Base.rte")
		CF_ActTypes[factionid][i] = CF_ActorTypes.ARMOR
		CF_ActOffsets[factionid][i] = Vector(0, 12)
	elseif baseActors[j].class == "AHuman" then
		actor = CreateAHuman(baseActors[j].presetName, "Base.rte")
		CF_ActTypes[factionid][i] = CF_ActorTypes.LIGHT
	end
	if actor then
		CF_ActNames[factionid][i] = actor.PresetName
		CF_ActPresets[factionid][i] = actor.PresetName
		CF_ActModules[factionid][i] = "Base.rte"
		CF_ActPrices[factionid][i] = actor:GetGoldValue(0, 1, 1)
		CF_ActDescriptions[factionid][i] = actor.Description

		CF_ActUnlockData[factionid][i] = baseActors[j].unlockData
		CF_ActPowers[factionid][i] = baseActors[j].actorPowers
		CF_ActClasses[factionid][i] = actor.ClassName
		DeleteEntity(actor)
	end
end
for j = 1, #baseItems do
	local item
	i = #CF_ItmNames[factionid] + 1
	if baseItems[j].class == "TDExplosive" then
		item = CreateTDExplosive(baseItems[j].presetName, "Base.rte")
		CF_ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF_WeaponTypes.GRENADE
	elseif baseItems[j].class == "HDFirearm" then
		item = CreateHDFirearm(baseItems[j].presetName, "Base.rte")
		CF_ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF_WeaponTypes.TOOL
	elseif baseItems[j].class == "HeldDevice" then
		item = CreateHeldDevice(baseItems[j].presetName, "Base.rte")
		CF_ItmTypes[factionid][i] = baseItems[j].weaponType and baseItems[j].weaponType or CF_WeaponTypes.SHIELD
	end
	if item then
		CF_ItmNames[factionid][i] = item.PresetName
		CF_ItmPresets[factionid][i] = item.PresetName
		CF_ItmModules[factionid][i] = "Base.rte"
		CF_ItmPrices[factionid][i] = item:GetGoldValue(0, 1, 1)
		CF_ItmDescriptions[factionid][i] = item.Description
		CF_ItmClasses[factionid][i] = item.ClassName

		CF_ItmUnlockData[factionid][i] = baseItems[j].unlockData
		CF_ItmPowers[factionid][i] = baseItems[j].itemPowers
		DeleteEntity(item)
	end
end

-- Faction items

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Auto Pistol"
CF_ItmPresets[factionid][i] = "Auto Pistol"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 18
CF_ItmDescriptions[factionid][i] =
	"Semi-auto is yesterday's business. High ammo capacity combined with rapid 3-round burst fire make this pistol more than just a sidearm!"
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 2

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Heavy Pistol"
CF_ItmPresets[factionid][i] = "Heavy Pistol"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 25
CF_ItmDescriptions[factionid][i] =
	"Offering more firepower than any other pistol on the market, the Heavy Pistol is a reliable sidearm. It fires slowly, but its shots have some serious stopping power."
CF_ItmUnlockData[factionid][i] = 900
CF_ItmTypes[factionid][i] = CF_WeaponTypes.PISTOL
CF_ItmPowers[factionid][i] = 3

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Compact Assault Rifle"
CF_ItmPresets[factionid][i] = "Compact Assault Rifle"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 30
CF_ItmDescriptions[factionid][i] =
	"Sacrifices stopping power and accuracy for a higher rate of fire.  It also fits easier into your backpack."
CF_ItmUnlockData[factionid][i] = 0
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 4

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Assault Rifle"
CF_ItmPresets[factionid][i] = "Assault Rifle"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 50
CF_ItmDescriptions[factionid][i] = "Workhorse of the Coalition army, satisfaction guaranteed or your money back!"
CF_ItmUnlockData[factionid][i] = 1100
CF_ItmTypes[factionid][i] = CF_WeaponTypes.RIFLE
CF_ItmPowers[factionid][i] = 5

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Sniper Rifle"
CF_ItmPresets[factionid][i] = "Sniper Rifle"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 70
CF_ItmDescriptions[factionid][i] =
	"Coalition special issue, semi-automatic precision rifle.  Complete with scope for long distance shooting."
CF_ItmUnlockData[factionid][i] = 1400
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SNIPER
CF_ItmPowers[factionid][i] = 5

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Shotgun"
CF_ItmPresets[factionid][i] = "Shotgun"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 40
CF_ItmDescriptions[factionid][i] = "A light shotgun with six shots and moderate reload time."
CF_ItmUnlockData[factionid][i] = 800
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 4

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Auto Shotgun"
CF_ItmPresets[factionid][i] = "Auto Shotgun"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 60
CF_ItmDescriptions[factionid][i] =
	"Fully automatic shotgun. The weapon can easily take down flying and fast moving targets with its high rate of fire."
CF_ItmUnlockData[factionid][i] = 1300
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHOTGUN
CF_ItmPowers[factionid][i] = 6

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Gatling Gun"
CF_ItmPresets[factionid][i] = "Gatling Gun"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 120
CF_ItmDescriptions[factionid][i] =
	"Coalition's feared heavy weapon that features a large magazine and amazing firepower. Reloading is not an issue because there is enough ammo to kill everyone even remotely close."
CF_ItmUnlockData[factionid][i] = 2600
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 8

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Grenade Launcher"
CF_ItmPresets[factionid][i] = "Grenade Launcher"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 90
CF_ItmDescriptions[factionid][i] =
	"Automatic grenade launcher with three different modes.  Detonate remote-controlled grenades by selecting the 'Detonate Grenades' button in the pie menu."
CF_ItmUnlockData[factionid][i] = 2200
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 9

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Missile Launcher"
CF_ItmPresets[factionid][i] = "Missile Launcher"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"Can fire powerful automatically guided missiles, excellent at destroying enemy craft.  Lock-on to enemy units using the laser pointer!"
CF_ItmUnlockData[factionid][i] = 3000
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 10

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Uber Cannon"
CF_ItmPresets[factionid][i] = "Uber Cannon"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 150
CF_ItmDescriptions[factionid][i] =
	"Uber Cannon. A shoulder mounted, tactical artillery weapon that fires air-bursting cluster bombs. Features a trajectory guide to help with long-ranged shots."
CF_ItmUnlockData[factionid][i] = 3200
CF_ItmTypes[factionid][i] = CF_WeaponTypes.HEAVY
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Frag Grenade"
CF_ItmPresets[factionid][i] = "Frag Grenade"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 10
CF_ItmDescriptions[factionid][i] =
	"Explosive fragmentation grenade. Perfect for clearing awkward bunkers. Blows up after a 4 second delay."
CF_ItmUnlockData[factionid][i] = 300
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 1

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Incendiary Grenade"
CF_ItmPresets[factionid][i] = "Incendiary Grenade"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 20
CF_ItmDescriptions[factionid][i] =
	"Upon detonation, this grenade produces molten iron by means of a chemical reaction.  In other words: use the three seconds you have to get out of its way!"
CF_ItmUnlockData[factionid][i] = 700
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 2

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Cluster Grenade"
CF_ItmPresets[factionid][i] = "Cluster Grenade"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 20
CF_ItmDescriptions[factionid][i] =
	"Explosive cluster grenade.  Awesome power!  Blows up spreading many explosive clusters after a 4 second delay."
CF_ItmUnlockData[factionid][i] = 700
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 3

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Timed Explosive"
CF_ItmPresets[factionid][i] = "Timed Explosive"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 30
CF_ItmDescriptions[factionid][i] =
	"Destructive plantable explosive charge.  You can stick this into a wall, door or anything else stationary.  After planting, run for your life, as it explodes after 10 seconds."
CF_ItmUnlockData[factionid][i] = 1000
CF_ItmClasses[factionid][i] = "TDExplosive"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.GRENADE
CF_ItmPowers[factionid][i] = 0

i = #CF_ItmNames[factionid] + 1
CF_ItmNames[factionid][i] = "Combat Shield"
CF_ItmPresets[factionid][i] = "Combat Shield"
CF_ItmModules[factionid][i] = "Coalition.rte"
CF_ItmPrices[factionid][i] = 30
CF_ItmDescriptions[factionid][i] =
	"In addition to offering enhanced protection from ballistics, this lightweight shield is also designed to fit any Coalition-manufactured firearm as an attachment."
CF_ItmUnlockData[factionid][i] = 1000
CF_ItmClasses[factionid][i] = "HeldDevice"
CF_ItmTypes[factionid][i] = CF_WeaponTypes.SHIELD
CF_ItmPowers[factionid][i] = 3
