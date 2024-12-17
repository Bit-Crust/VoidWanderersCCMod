-- Add planets
-- Define station
local id = "TradeStar"
CF.Planet[#CF.Planet + 1] = id
CF.PlanetName[id] = "FreeTrade TradeStar"
CF.PlanetGlow[id] = "Mods/VoidWanderers.rte/UI/Planets/Station.png"
CF.PlanetPos[id] = Vector(25, -20)
CF.PlanetScale[id] = 0.05

-- Add locations
local id = "TradeStar Pier #792"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "TradeStar Pier #792"
CF.LocationPos[id] = Vector(25, 20)
CF.LocationSecurity[id] = 60
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "TradeStar Pier #792" }
CF.LocationPlanet[id] = "TradeStar"
CF.LocationPlayable[id] = false
CF.LocationAttributes[id] = { CF.LocationAttributeTypes.TRADESTAR }

local id = "TradeStar Pier #625"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "TradeStar Pier #625"
CF.LocationPos[id] = Vector(-25, 20)
CF.LocationSecurity[id] = 60
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "TradeStar Pier #625" }
CF.LocationPlanet[id] = "TradeStar"
CF.LocationPlayable[id] = false
CF.LocationAttributes[id] = { CF.LocationAttributeTypes.TRADESTAR }

-- Define vanilla planet
local id = "CC-11Y"
CF.Planet[#CF.Planet + 1] = id
CF.PlanetName[id] = "CC-11Y"
CF.PlanetGlow[id] = "Mods/VoidWanderers.rte/UI/Planets/CC-11Y.png"
CF.PlanetPos[id] = Vector(27, 32)

-- Add black markets
local id = "Station Ypsilon-2"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Station Ypsilon-2"
CF.LocationPos[id] = Vector(52, 50)
CF.LocationSecurity[id] = 60
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Station Ypsilon-2" }
CF.LocationPlanet[id] = "CC-11Y"
CF.LocationPlayable[id] = false
CF.LocationAttributes[id] = { CF.LocationAttributeTypes.BLACKMARKET }

-- Add shipyards
local id = "Toha Shipyards"
CF.Location[#CF.Location + 1] = id
CF.LocationName[id] = "Toha Shipyards"
CF.LocationPos[id] = Vector(-32, -50)
CF.LocationSecurity[id] = 60
CF.LocationGoldPresent[id] = false
CF.LocationScenes[id] = { "Toha Shipyards" }
CF.LocationPlanet[id] = "CC-11Y"
CF.LocationPlayable[id] = false
CF.LocationAttributes[id] = { CF.LocationAttributeTypes.SHIPYARD }
