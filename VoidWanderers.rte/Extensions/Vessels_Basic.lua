-- Define Lynx vessel
local id = "Lynx"
CF_Vessel[#CF_Vessel + 1] = id
CF_VesselPrice[id] = 30000
CF_VesselName[id] = "Lynx"
CF_VesselScene[id] = "Vessel Lynx"
CF_VesselModule[id] = "VoidWanderers.rte"

CF_VesselMaxClonesCapacity[id] = 16
CF_VesselStartClonesCapacity[id] = 4

CF_VesselMaxStorageCapacity[id] = 100
CF_VesselStartStorageCapacity[id] = 40

CF_VesselMaxLifeSupport[id] = 10
CF_VesselStartLifeSupport[id] = 4

CF_VesselMaxCommunication[id] = 10
CF_VesselStartCommunication[id] = 4

CF_VesselMaxSpeed[id] = 55
CF_VesselStartSpeed[id] = 24

CF_VesselMaxTurrets[id] = 2
CF_VesselStartTurrets[id] = 0

CF_VesselMaxTurretStorage[id] = 6
CF_VesselStartTurretStorage[id] = 0

CF_VesselMaxBombBays[id] = 1
CF_VesselStartBombBays[id] = 0

CF_VesselMaxBombStorage[id] = 15
CF_VesselStartBombStorage[id] = 0

local id = "Gryphon"
CF_Vessel[#CF_Vessel + 1] = id
CF_VesselPrice[id] = 50000
CF_VesselName[id] = "Gryphon"
CF_VesselScene[id] = "Vessel Gryphon"
CF_VesselModule[id] = "VoidWanderers.rte"

CF_VesselMaxClonesCapacity[id] = 20
CF_VesselStartClonesCapacity[id] = 5

CF_VesselMaxStorageCapacity[id] = 200
CF_VesselStartStorageCapacity[id] = 50

CF_VesselMaxLifeSupport[id] = 15
CF_VesselStartLifeSupport[id] = 5

CF_VesselMaxCommunication[id] = 15
CF_VesselStartCommunication[id] = 5

CF_VesselMaxSpeed[id] = 40
CF_VesselStartSpeed[id] = 20

CF_VesselMaxTurrets[id] = 3
CF_VesselStartTurrets[id] = 0

CF_VesselMaxTurretStorage[id] = 8
CF_VesselStartTurretStorage[id] = 0

CF_VesselMaxBombBays[id] = 2
CF_VesselStartBombBays[id] = 0

CF_VesselMaxBombStorage[id] = 30
CF_VesselStartBombStorage[id] = 0

local id = "Titan"
CF_Vessel[#CF_Vessel + 1] = id
CF_VesselPrice[id] = 180000
CF_VesselName[id] = "Titan"
CF_VesselScene[id] = "Vessel Titan"
CF_VesselModule[id] = "VoidWanderers.rte"

CF_VesselMaxClonesCapacity[id] = 40
CF_VesselStartClonesCapacity[id] = 6

CF_VesselMaxStorageCapacity[id] = 400
CF_VesselStartStorageCapacity[id] = 60

CF_VesselMaxLifeSupport[id] = 20
CF_VesselStartLifeSupport[id] = 6

CF_VesselMaxCommunication[id] = 20
CF_VesselStartCommunication[id] = 6

CF_VesselMaxSpeed[id] = 30
CF_VesselStartSpeed[id] = 10

CF_VesselMaxTurrets[id] = 4
CF_VesselStartTurrets[id] = 1

CF_VesselMaxTurretStorage[id] = 12
CF_VesselStartTurretStorage[id] = 1

CF_VesselMaxBombBays[id] = 4
CF_VesselStartBombBays[id] = 1

CF_VesselMaxBombStorage[id] = 100
CF_VesselStartBombStorage[id] = 10

-- Abandoned vessel scenes
local id = "Abandoned Lynx Vessel"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Abandoned Lynx Vessel"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Abandoned Lynx Vessel" }
CF_LocationScript[id] = {
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Zombies.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Firefight.lua",
}
--CF_LocationScript[id] = {"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Faction.lua"} -- DEBUG
--CF_LocationScript[id] = {"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Zombies.lua"} -- DEBUG
--CF_LocationScript[id] = {"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Firefight.lua"} -- DEBUG
CF_LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambient_Smokes.lua"
CF_LocationPlanet[id] = ""
CF_LocationPlayable[id] = true
CF_LocationMissions[id] = { "Assassinate", "Zombies" }
CF_LocationAttributes[id] = {
	CF_LocationAttributeTypes.ABANDONEDVESSEL,
	CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF_LocationAttributeTypes.ALWAYSUNSEEN,
	CF_LocationAttributeTypes.TEMPLOCATION,
	CF_LocationAttributeTypes.NOBOMBS,
}

local id = "Abandoned Gryphon Vessel"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Abandoned Gryphon Vessel"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Abandoned Gryphon Vessel" }
CF_LocationScript[id] = {
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Zombies.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Firefight.lua",
}
CF_LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambient_Smokes.lua"
CF_LocationPlanet[id] = ""
CF_LocationPlayable[id] = true
CF_LocationMissions[id] = { "Assassinate", "Zombies" }
CF_LocationAttributes[id] = {
	CF_LocationAttributeTypes.ABANDONEDVESSEL,
	CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF_LocationAttributeTypes.ALWAYSUNSEEN,
	CF_LocationAttributeTypes.TEMPLOCATION,
	CF_LocationAttributeTypes.NOBOMBS,
}

local id = "Abandoned Titan Vessel"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Abandoned Titan Vessel"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Abandoned Titan Vessel" }
CF_LocationScript[id] = {
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Zombies.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Firefight.lua",
}
CF_LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambient_Smokes.lua"
CF_LocationPlanet[id] = ""
CF_LocationPlayable[id] = true
CF_LocationMissions[id] = { "Assassinate", "Zombies" }
CF_LocationAttributes[id] = {
	CF_LocationAttributeTypes.ABANDONEDVESSEL,
	CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF_LocationAttributeTypes.ALWAYSUNSEEN,
	CF_LocationAttributeTypes.TEMPLOCATION,
	CF_LocationAttributeTypes.NOBOMBS,
}
--]]--

-- Counterattack vessel scenes
local id = "Vessel Lynx"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Lynx"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Vessel Lynx" }
CF_LocationScript[id] = { "VoidWanderers.rte/Scripts/Mission_Counterattack.lua" }
CF_LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambient_Space.lua"
CF_LocationPlanet[id] = ""
CF_LocationPlayable[id] = true
CF_LocationMissions[id] = { "Assassinate", "Zombies" }
CF_LocationAttributes[id] = {
	CF_LocationAttributeTypes.VESSEL,
	CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF_LocationAttributeTypes.ALWAYSUNSEEN,
	CF_LocationAttributeTypes.TEMPLOCATION,
	CF_LocationAttributeTypes.SCOUT,
	CF_LocationAttributeTypes.CORVETTE,
	CF_LocationAttributeTypes.NOBOMBS,
}

local id = "Vessel Gryphon"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Gryphon"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Vessel Gryphon" }
CF_LocationScript[id] = { "VoidWanderers.rte/Scripts/Mission_Counterattack.lua" }
CF_LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambient_Space.lua"
CF_LocationPlanet[id] = ""
CF_LocationPlayable[id] = true
CF_LocationMissions[id] = { "Assassinate", "Zombies" }
CF_LocationAttributes[id] = {
	CF_LocationAttributeTypes.VESSEL,
	CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF_LocationAttributeTypes.ALWAYSUNSEEN,
	CF_LocationAttributeTypes.TEMPLOCATION,
	CF_LocationAttributeTypes.FRIGATE,
	CF_LocationAttributeTypes.DESTROYER,
	CF_LocationAttributeTypes.NOBOMBS,
}

local id = "Vessel Titan"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Titan"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Vessel Titan" }
CF_LocationScript[id] = { "VoidWanderers.rte/Scripts/Mission_Counterattack.lua" }
CF_LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambient_Space.lua"
CF_LocationPlanet[id] = ""
CF_LocationPlayable[id] = true
CF_LocationMissions[id] = { "Assassinate", "Zombies" }
CF_LocationAttributes[id] = {
	CF_LocationAttributeTypes.VESSEL,
	CF_LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF_LocationAttributeTypes.ALWAYSUNSEEN,
	CF_LocationAttributeTypes.TEMPLOCATION,
	CF_LocationAttributeTypes.CRUISER,
	CF_LocationAttributeTypes.BATTLESHIP,
	CF_LocationAttributeTypes.NOBOMBS,
}
