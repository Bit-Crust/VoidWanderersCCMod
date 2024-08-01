-- Define planet
local id = "Sector 7"
CF["Planet"][#CF["Planet"] + 1] = id
CF["PlanetName"][id] = "Sector 7"
CF["PlanetGlow"][id] = "Sector 7"
CF["PlanetPos"][id] = Vector(27, 32)
CF["PlanetGlowModule"][id] = "VoidWanderers_Grimmcrypt.rte"

-- planet locations
local id = "Station Alpha 9 Delta"
CF["Location"][#CF["Location"] + 1] = id
CF["LocationName"][id] = "Station Alpha 9 Delta"
CF["LocationPos"][id] = Vector(27, 32)
CF["LocationDescription"][id] = "This station has been abondoned for several decades now. The reasons are unkown."
CF["LocationSecurity"][id] = 0
CF["LocationGoldPresent"][id] = true
CF["LocationScenes"][id] = { "Station Alpha 9 Delta" }
CF["LocationPlanet"][id] = "Sector 7"
CF["LocationMissions"][id] = { "Assault", "Assassinate", "Dropships", "Mine" }
