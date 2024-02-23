-- Add planets
-- Define station
local id = "TradeStar"
CF_Planet[#CF_Planet + 1] = id
CF_PlanetName[id] = "FreeTrade TradeStar"
CF_PlanetGlow[id] = "Station"
CF_PlanetPos[id] = Vector(25, -20)
CF_PlanetGlowModule[id] = "VoidWanderers.rte"
CF_PlanetScale[id] = 0.05

-- Add locations
local id = "TradeStar Pier #792"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "TradeStar Pier #792"
CF_LocationPos[id] = Vector(25, 20)
CF_LocationSecurity[id] = 60
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "TradeStar Pier #792" }
CF_LocationPlanet[id] = "TradeStar"
CF_LocationPlayable[id] = false
CF_LocationAttributes[id] = { CF_LocationAttributeTypes.TRADESTAR }

local id = "TradeStar Pier #625"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "TradeStar Pier #625"
CF_LocationPos[id] = Vector(-25, 20)
CF_LocationSecurity[id] = 60
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "TradeStar Pier #625" }
CF_LocationPlanet[id] = "TradeStar"
CF_LocationPlayable[id] = false
CF_LocationAttributes[id] = { CF_LocationAttributeTypes.TRADESTAR }

-- Define vanilla planet
local id = "CC-11Y"
CF_Planet[#CF_Planet + 1] = id
CF_PlanetName[id] = "CC-11Y"
CF_PlanetGlow[id] = "CC-11Y"
CF_PlanetPos[id] = Vector(27, 32)
CF_PlanetGlowModule[id] = "VoidWanderers.rte"

-- Add black markets
local id = "Station Ypsilon-2"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Station Ypsilon-2"
CF_LocationPos[id] = Vector(52, 50)
CF_LocationSecurity[id] = 60
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Station Ypsilon-2" }
CF_LocationPlanet[id] = "CC-11Y"
CF_LocationPlayable[id] = false
CF_LocationAttributes[id] = { CF_LocationAttributeTypes.BLACKMARKET }

-- Add shipyards
local id = "Toha Shipyards"
CF_Location[#CF_Location + 1] = id
CF_LocationName[id] = "Toha Shipyards"
CF_LocationPos[id] = Vector(-32, -50)
CF_LocationSecurity[id] = 60
CF_LocationGoldPresent[id] = false
CF_LocationScenes[id] = { "Toha Shipyards" }
CF_LocationPlanet[id] = "CC-11Y"
CF_LocationPlayable[id] = false
CF_LocationAttributes[id] = { CF_LocationAttributeTypes.SHIPYARD }
