-- Define vessel
local id = "Carryall"
CF["Vessel"][#CF["Vessel"] + 1] = id
CF["VesselPrice"][id] = 15000
CF["VesselName"][id] = "Carryall"
CF["VesselScene"][id] = "Vessel Carryall"
CF["VesselModule"][id] = "VoidWanderers.rte"

CF["VesselMaxClonesCapacity"][id] = 10
CF["VesselStartClonesCapacity"][id] = 3

CF["VesselMaxStorageCapacity"][id] = 300
CF["VesselStartStorageCapacity"][id] = 30

CF["VesselMaxLifeSupport"][id] = 5
CF["VesselStartLifeSupport"][id] = 3

CF["VesselMaxCommunication"][id] = 5
CF["VesselStartCommunication"][id] = 3

CF["VesselMaxSpeed"][id] = 100
CF["VesselStartSpeed"][id] = 20

CF["VesselMaxTurrets"][id] = 1
CF["VesselStartTurrets"][id] = 0

CF["VesselMaxTurretStorage"][id] = 1
CF["VesselStartTurretStorage"][id] = 1

CF["VesselMaxBombBays"][id] = 0
CF["VesselStartBombBays"][id] = 0

CF["VesselMaxBombStorage"][id] = 0
CF["VesselStartBombStorage"][id] = 0

-- Abandoned vessel scenes
local id = "Abandoned Carryall Vessel"
CF["Location"][#CF["Location"] + 1] = id
CF["LocationName"][id] = "Abandoned Carryall Vessel"
CF["LocationPos"][id] = Vector(0, 0)
CF["LocationSecurity"][id] = 0
CF["LocationGoldPresent"][id] = false
CF["LocationScenes"][id] = { "Abandoned Carryall Vessel" }
CF["LocationScript"][id] = {
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Faction.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Zombies.lua",
	"VoidWanderers.rte/Scripts/Mission_AbandonedVessel_Firefight.lua",
}
CF["LocationAmbientScript"][id] = "VoidWanderers.rte/Scripts/Ambient_Smokes.lua"
CF["LocationPlanet"][id] = ""
CF["LocationPlayable"][id] = true
CF["LocationMissions"][id] = { "Assassinate", "Zombies" }
CF["LocationAttributes"][id] = {
	CF["LocationAttributeTypes"].ABANDONEDVESSEL,
	CF["LocationAttributeTypes"].NOTMISSIONASSIGNABLE,
	CF["LocationAttributeTypes"].ALWAYSUNSEEN,
	CF["LocationAttributeTypes"].TEMPLOCATION,
	CF["LocationAttributeTypes"].NOBOMBS,
}

-- Counterattack vessel scenes
local id = "Vessel Carryall"
CF["Location"][#CF["Location"] + 1] = id
CF["LocationName"][id] = "Carryall"
CF["LocationPos"][id] = Vector(0, 0)
CF["LocationSecurity"][id] = 0
CF["LocationGoldPresent"][id] = false
CF["LocationScenes"][id] = { "Vessel Carryall" }
CF["LocationScript"][id] = { "VoidWanderers.rte/Scripts/Mission_Counterattack.lua" }
CF["LocationAmbientScript"][id] = "VoidWanderers.rte/Scripts/Ambient_Space.lua"
CF["LocationPlanet"][id] = ""
CF["LocationPlayable"][id] = true
CF["LocationMissions"][id] = { "Assassinate", "Zombies" }
CF["LocationAttributes"][id] = {
	CF["LocationAttributeTypes"].VESSEL,
	CF["LocationAttributeTypes"].NOTMISSIONASSIGNABLE,
	CF["LocationAttributeTypes"].ALWAYSUNSEEN,
	CF["LocationAttributeTypes"].TEMPLOCATION,
	CF["LocationAttributeTypes"].SCOUT,
	CF["LocationAttributeTypes"].CORVETTE,
	CF["LocationAttributeTypes"].NOBOMBS,
}
