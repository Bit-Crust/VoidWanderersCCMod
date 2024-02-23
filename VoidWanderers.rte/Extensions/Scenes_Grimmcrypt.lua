-- Define planet
local id = "Sector 7"
CF_Planet[#CF_Planet + 1] = id
CF_PlanetName[id] = "Sector 7"
CF_PlanetGlow[id] = "Sector 7"
CF_PlanetPos[id] = Vector(27, 32)
CF_PlanetGlowModule[id] = "VoidWanderers_Grimmcrypt.rte"

-- planet locations
local id = "Station Alpha 9 Delta"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Station Alpha 9 Delta"
CF_LocationPos[id] = Vector(27, 32)
CF_LocationDescription[id] = "This station has been abondoned for several decades now. The reasons are unkown."
CF_LocationSecurity[id] = 0
CF_LocationGoldPresent[id] = true
CF_LocationScenes[id] = { "Station Alpha 9 Delta" }
CF_LocationPlanet[id] = "Sector 7"
CF_LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine" }
