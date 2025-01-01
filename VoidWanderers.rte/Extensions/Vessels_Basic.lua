-- Define Lynx vessel
local id = "Mule"
CF.Vessel[#CF.Vessel + 1] = id
CF.VesselPrice[id] = 10000
CF.VesselName[id] = "Mule"
CF.VesselScene[id] = "Vessel Mule"
CF.VesselModule[id] = "VoidWanderers.rte"

CF.VesselMaxClonesCapacity[id] = 0
CF.VesselStartClonesCapacity[id] = 0

CF.VesselMaxStorageCapacity[id] = 120
CF.VesselStartStorageCapacity[id] = 60

CF.VesselMaxLifeSupport[id] = 8
CF.VesselStartLifeSupport[id] = 4

CF.VesselMaxCommunication[id] = 6
CF.VesselStartCommunication[id] = 4

CF.VesselMaxSpeed[id] = 50
CF.VesselStartSpeed[id] = 30

CF.VesselMaxTurrets[id] = 2
CF.VesselStartTurrets[id] = 0

CF.VesselMaxTurretStorage[id] = 8
CF.VesselStartTurretStorage[id] = 0

CF.VesselMaxBombBays[id] = 1
CF.VesselStartBombBays[id] = 0

CF.VesselMaxBombStorage[id] = 20
CF.VesselStartBombStorage[id] = 0

local id = "Lynx"
CF.Vessel[#CF.Vessel + 1] = id
CF.VesselPrice[id] = 30000
CF.VesselName[id] = "Lynx"
CF.VesselScene[id] = "Vessel Lynx"
CF.VesselModule[id] = "VoidWanderers.rte"

CF.VesselMaxClonesCapacity[id] = 16
CF.VesselStartClonesCapacity[id] = 4

CF.VesselMaxStorageCapacity[id] = 100
CF.VesselStartStorageCapacity[id] = 40

CF.VesselMaxLifeSupport[id] = 10
CF.VesselStartLifeSupport[id] = 4

CF.VesselMaxCommunication[id] = 10
CF.VesselStartCommunication[id] = 4

CF.VesselMaxSpeed[id] = 55
CF.VesselStartSpeed[id] = 24

CF.VesselMaxTurrets[id] = 2
CF.VesselStartTurrets[id] = 0

CF.VesselMaxTurretStorage[id] = 6
CF.VesselStartTurretStorage[id] = 0

CF.VesselMaxBombBays[id] = 1
CF.VesselStartBombBays[id] = 0

CF.VesselMaxBombStorage[id] = 15
CF.VesselStartBombStorage[id] = 0

local id = "Gryphon"
CF.Vessel[#CF.Vessel + 1] = id
CF.VesselPrice[id] = 50000
CF.VesselName[id] = "Gryphon"
CF.VesselScene[id] = "Vessel Gryphon"
CF.VesselModule[id] = "VoidWanderers.rte"

CF.VesselMaxClonesCapacity[id] = 20
CF.VesselStartClonesCapacity[id] = 5

CF.VesselMaxStorageCapacity[id] = 200
CF.VesselStartStorageCapacity[id] = 50

CF.VesselMaxLifeSupport[id] = 15
CF.VesselStartLifeSupport[id] = 5

CF.VesselMaxCommunication[id] = 15
CF.VesselStartCommunication[id] = 5

CF.VesselMaxSpeed[id] = 40
CF.VesselStartSpeed[id] = 20

CF.VesselMaxTurrets[id] = 3
CF.VesselStartTurrets[id] = 0

CF.VesselMaxTurretStorage[id] = 8
CF.VesselStartTurretStorage[id] = 0

CF.VesselMaxBombBays[id] = 2
CF.VesselStartBombBays[id] = 0

CF.VesselMaxBombStorage[id] = 30
CF.VesselStartBombStorage[id] = 0

local id = "Titan"
CF.Vessel[#CF.Vessel + 1] = id
CF.VesselPrice[id] = 180000
CF.VesselName[id] = "Titan"
CF.VesselScene[id] = "Vessel Titan"
CF.VesselModule[id] = "VoidWanderers.rte"

CF.VesselMaxClonesCapacity[id] = 40
CF.VesselStartClonesCapacity[id] = 6

CF.VesselMaxStorageCapacity[id] = 400
CF.VesselStartStorageCapacity[id] = 60

CF.VesselMaxLifeSupport[id] = 20
CF.VesselStartLifeSupport[id] = 6

CF.VesselMaxCommunication[id] = 20
CF.VesselStartCommunication[id] = 6

CF.VesselMaxSpeed[id] = 30
CF.VesselStartSpeed[id] = 10

CF.VesselMaxTurrets[id] = 4
CF.VesselStartTurrets[id] = 1

CF.VesselMaxTurretStorage[id] = 12
CF.VesselStartTurretStorage[id] = 1

CF.VesselMaxBombBays[id] = 4
CF.VesselStartBombBays[id] = 1

CF.VesselMaxBombStorage[id] = 100
CF.VesselStartBombStorage[id] = 10

-- Abandoned vessel scenes
local id = "Abandoned Lynx Vessel"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Abandoned Lynx Vessel"
CF.LocationPos[id] = Vector(0, 0)
CF.LocationSecurity[id] = 0
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Vessel Lynx" }
CF.LocationScript[id] = {
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Zombies.lua",
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Firefight.lua",
}
CF.LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambience/Smokes.lua"
CF.LocationPlanet[id] = ""
CF.LocationPlayable[id] = true
CF.LocationMissions[id] = { "Assassinate", "Zombies" }
CF.LocationAttributes[id] = {
	CF.LocationAttributeTypes.ABANDONEDVESSEL,
	CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF.LocationAttributeTypes.ALWAYSUNSEEN,
	CF.LocationAttributeTypes.TEMPLOCATION,
	CF.LocationAttributeTypes.NOBOMBS,
}

local id = "Abandoned Gryphon Vessel"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Abandoned Gryphon Vessel"
CF.LocationPos[id] = Vector(0, 0)
CF.LocationSecurity[id] = 0
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Vessel Gryphon" }
CF.LocationScript[id] = {
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Zombies.lua",
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Firefight.lua",
}
CF.LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambience/Smokes.lua"
CF.LocationPlanet[id] = ""
CF.LocationPlayable[id] = true
CF.LocationMissions[id] = { "Assassinate", "Zombies" }
CF.LocationAttributes[id] = {
	CF.LocationAttributeTypes.ABANDONEDVESSEL,
	CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF.LocationAttributeTypes.ALWAYSUNSEEN,
	CF.LocationAttributeTypes.TEMPLOCATION,
	CF.LocationAttributeTypes.NOBOMBS,
}

local id = "Abandoned Titan Vessel"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Abandoned Titan Vessel"
CF.LocationPos[id] = Vector(0, 0)
CF.LocationSecurity[id] = 0
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Vessel Titan" }
CF.LocationScript[id] = {
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Firefight.lua",
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Missions/AbandonedVessel_Zombies.lua",
}
CF.LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambience/Smokes.lua"
CF.LocationPlanet[id] = ""
CF.LocationPlayable[id] = true
CF.LocationMissions[id] = { "Assassinate", "Zombies" }
CF.LocationAttributes[id] = {
	CF.LocationAttributeTypes.ABANDONEDVESSEL,
	CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF.LocationAttributeTypes.ALWAYSUNSEEN,
	CF.LocationAttributeTypes.TEMPLOCATION,
	CF.LocationAttributeTypes.NOBOMBS,
}
--]]--

-- Counterattack vessel scenes
local id = "Hostile Vessel Lynx"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Lynx"
CF.LocationPos[id] = Vector(0, 0)
CF.LocationSecurity[id] = 0
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Vessel Lynx" }
CF.LocationScript[id] = { "VoidWanderers.rte/Scripts/Missions/Counterattack.lua" }
CF.LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambience/Space.lua"
CF.LocationPlanet[id] = ""
CF.LocationPlayable[id] = true
CF.LocationMissions[id] = { "Assassinate", "Zombies" }
CF.LocationAttributes[id] = {
	CF.LocationAttributeTypes.VESSEL,
	CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF.LocationAttributeTypes.ALWAYSUNSEEN,
	CF.LocationAttributeTypes.TEMPLOCATION,
	CF.LocationAttributeTypes.SCOUT,
	CF.LocationAttributeTypes.CORVETTE,
	CF.LocationAttributeTypes.NOBOMBS,
}

local id = "Hostile Vessel Gryphon"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Gryphon"
CF.LocationPos[id] = Vector(0, 0)
CF.LocationSecurity[id] = 0
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Vessel Gryphon" }
CF.LocationScript[id] = { "VoidWanderers.rte/Scripts/Missions/Counterattack.lua" }
CF.LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambience/Space.lua"
CF.LocationPlanet[id] = ""
CF.LocationPlayable[id] = true
CF.LocationMissions[id] = { "Assassinate", "Zombies" }
CF.LocationAttributes[id] = {
	CF.LocationAttributeTypes.VESSEL,
	CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF.LocationAttributeTypes.ALWAYSUNSEEN,
	CF.LocationAttributeTypes.TEMPLOCATION,
	CF.LocationAttributeTypes.FRIGATE,
	CF.LocationAttributeTypes.DESTROYER,
	CF.LocationAttributeTypes.NOBOMBS,
}

local id = "Hostile Vessel Titan"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Titan"
CF.LocationPos[id] = Vector(0, 0)
CF.LocationSecurity[id] = 0
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Vessel Titan" }
CF.LocationScript[id] = { "VoidWanderers.rte/Scripts/Missions/Counterattack.lua" }
CF.LocationAmbientScript[id] = "VoidWanderers.rte/Scripts/Ambience/Space.lua"
CF.LocationPlanet[id] = ""
CF.LocationPlayable[id] = true
CF.LocationMissions[id] = { "Assassinate", "Zombies" }
CF.LocationAttributes[id] = {
	CF.LocationAttributeTypes.VESSEL,
	CF.LocationAttributeTypes.NOTMISSIONASSIGNABLE,
	CF.LocationAttributeTypes.ALWAYSUNSEEN,
	CF.LocationAttributeTypes.TEMPLOCATION,
	CF.LocationAttributeTypes.CRUISER,
	CF.LocationAttributeTypes.BATTLESHIP,
	CF.LocationAttributeTypes.NOBOMBS,
}
