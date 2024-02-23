--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-City"
	CF_Planet[#CF_Planet + 1] = id
	CF_PlanetName[id] = "MapPack-City"
	CF_PlanetGlow[id] = "MapPack-City"
	CF_PlanetPos[id] = Vector(-15, 15)
	CF_PlanetGlowModule[id] = "VoidWanderers.rte"

	-- Planet locations
	local id = "Suburbs"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Suburbs"
	CF_LocationPos[id] = Vector(27, 22)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Suburbs" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" }

	-- Enable only if MP3 patch installed
	-- Will crash the game due to Brain Deployments if MP3 is not patched
	local id = "Tenements"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Tenements"
	CF_LocationPos[id] = Vector(-2, 54)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Tenements" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy" }

	local id = "Towers"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Towers"
	CF_LocationPos[id] = Vector(-24, -28)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Towers" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy" } --]]--

	local id = "City Prison"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "City Prison"
	CF_LocationPos[id] = Vector(-45, 19)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "City Prison" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "The Bank"
	CF_LocationPos[id] = Vector(-10, -22)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 20
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "The Bank" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Skyrise"
	CF_LocationPos[id] = Vector(32, 32)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Skyrise" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Office"
	CF_LocationPos[id] = Vector(27, -40)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Office" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "The Projects"
	CF_LocationPos[id] = Vector(17, -24)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "The Projects" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Sewers"
	CF_LocationPos[id] = Vector(-7, 44)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Sewers" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "UniTec"
	CF_LocationPos[id] = Vector(0, -33)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "UniTec" }
	CF_LocationPlanet[id] = "MapPack-City"
	CF_LocationMissions[id] = {
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
