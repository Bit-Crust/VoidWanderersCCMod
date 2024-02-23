-- Define vessel
local id = "Carryall"
CF_Vessel[#CF_Vessel + 1] = id
CF_VesselPrice[id] = 15000
CF_VesselName[id] = "Carryall"
CF_VesselScene[id] = "Vessel Carryall"
CF_VesselModule[id] = "VoidWanderers.rte"

CF_VesselMaxClonesCapacity[id] = 10
CF_VesselStartClonesCapacity[id] = 3

CF_VesselMaxStorageCapacity[id] = 300
CF_VesselStartStorageCapacity[id] = 30

CF_VesselMaxLifeSupport[id] = 5
CF_VesselStartLifeSupport[id] = 3

CF_VesselMaxCommunication[id] = 5
CF_VesselStartCommunication[id] = 3

CF_VesselMaxSpeed[id] = 100
CF_VesselStartSpeed[id] = 20

CF_VesselMaxTurrets[id] = 1
CF_VesselStartTurrets[id] = 0

CF_VesselMaxTurretStorage[id] = 1
CF_VesselStartTurretStorage[id] = 1

CF_VesselMaxBombBays[id] = 0
CF_VesselStartBombBays[id] = 0

CF_VesselMaxBombStorage[id] = 0
CF_VesselStartBombStorage[id] = 0

-- Abandoned vessel scenes
local id = "Abandoned Carryall Vessel"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Abandoned Carryall Vessel"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Abandoned Carryall Vessel" }
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

-- Counterattack vessel scenes
local id = "Vessel Carryall"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Carryall"
CF_LocationPos[id] = Vector(0, 0)
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Vessel Carryall" }
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
