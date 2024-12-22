--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-City"
	CF.Planet[#CF.Planet + 1] = id
	CF.PlanetName[id] = "MapPack-City"
	CF.PlanetGlow[id] = "Mods/VoidWanderers.rte/UI/Planets/MP3-GTC-CTY.png"
	CF.PlanetPos[id] = Vector(-15, 15)

	-- Planet locations
	local id = "Suburbs"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Suburbs"
	CF.LocationPos[id] = Vector(27, 22)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Suburbs" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" }

	-- Enable only if MP3 patch installed
	-- Will crash the game due to Brain Deployments if MP3 is not patched
	local id = "Tenements"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Tenements"
	CF.LocationPos[id] = Vector(-2, 54)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Tenements" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy" }

	local id = "Towers"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Towers"
	CF.LocationPos[id] = Vector(-24, -28)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Towers" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy" } --]]--

	local id = "City Prison"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "City Prison"
	CF.LocationPos[id] = Vector(-45, 19)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "City Prison" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}

	local id = "The Bank"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "The Bank"
	CF.LocationPos[id] = Vector(-10, -22)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 20
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "The Bank" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}

	local id = "Skyrise"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Skyrise"
	CF.LocationPos[id] = Vector(32, 32)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Skyrise" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}

	local id = "Office"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Office"
	CF.LocationPos[id] = Vector(27, -40)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Office" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}

	local id = "The Projects"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "The Projects"
	CF.LocationPos[id] = Vector(17, -24)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "The Projects" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}

	local id = "Sewers"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Sewers"
	CF.LocationPos[id] = Vector(-7, 44)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Sewers" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}

	local id = "UniTec"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "UniTec"
	CF.LocationPos[id] = Vector(0, -33)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "UniTec" }
	CF.LocationPlanet[id] = "MapPack-City"
	CF.LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Squad",
		"Evacuate",
	}
end
