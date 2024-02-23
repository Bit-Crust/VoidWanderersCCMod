--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-Space"
	CF_Planet[#CF_Planet + 1] = id
	CF_PlanetName[id] = "MapPack-Space"
	CF_PlanetGlow[id] = "MapPack-Space"
	CF_PlanetPos[id] = Vector(28, 22)
	CF_PlanetGlowModule[id] = "VoidWanderers.rte"

	-- Planet locations
	local id = "Command"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Command"
	CF_LocationPos[id] = Vector(3, -32)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Command" }
	CF_LocationPlanet[id] = "MapPack-Space"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad" }

	local id = "Craters"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Craters"
	CF_LocationPos[id] = Vector(29, 17)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Craters" }
	CF_LocationPlanet[id] = "MapPack-Space"
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

	local id = "Asteroids"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Asteroids"
	CF_LocationPos[id] = Vector(-50, 50)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Asteroids" }
	CF_LocationPlanet[id] = "MapPack-Space"
	CF_LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Evacuate",
	}

	local id = "Outpost"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Outpost"
	CF_LocationPos[id] = Vector(6, -16)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Outpost" }
	CF_LocationPlanet[id] = "MapPack-Space"
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

	local id = "Comm Tower"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Comm Tower"
	CF_LocationPos[id] = Vector(-28, 27)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Comm Tower" }
	CF_LocationPlanet[id] = "MapPack-Space"
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

	local id = "The Dig"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "The Dig"
	CF_LocationPos[id] = Vector(29, -16)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "The Dig" }
	CF_LocationPlanet[id] = "MapPack-Space"
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

	local id = "Nova"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Nova"
	CF_LocationPos[id] = Vector(25, 3)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Nova" }
	CF_LocationPlanet[id] = "MapPack-Space"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" }

	local id = "Hollow"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Hollow"
	CF_LocationPos[id] = Vector(34, -39)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Hollow" }
	CF_LocationPlanet[id] = "MapPack-Space"
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

	local id = "Colony"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Colony"
	CF_LocationPos[id] = Vector(-8, -19)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Colony" }
	CF_LocationPlanet[id] = "MapPack-Space"
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

	local id = "In-Flight"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "In-Flight"
	CF_LocationPos[id] = Vector(50, -50)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = false
	CF_LocationScenes[id] = { "In-Flight" }
	CF_LocationPlanet[id] = "MapPack-Space"
	CF_LocationMissions[id] = { "Squad" }
end
