--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-Space"
	CF["Planet"][#CF["Planet"] + 1] = id
	CF["PlanetName"][id] = "MapPack-Space"
	CF["PlanetGlow"][id] = "MapPack-Space"
	CF["PlanetPos"][id] = Vector(28, 22)
	CF["PlanetGlowModule"][id] = "VoidWanderers.rte"

	-- Planet locations
	local id = "Command"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Command"
	CF["LocationPos"][id] = Vector(3, -32)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Command" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad" }

	local id = "Craters"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Craters"
	CF["LocationPos"][id] = Vector(29, 17)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Craters" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Asteroids"
	CF["LocationPos"][id] = Vector(-50, 50)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Asteroids" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Outpost"
	CF["LocationPos"][id] = Vector(6, -16)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Outpost" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Comm Tower"
	CF["LocationPos"][id] = Vector(-28, 27)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Comm Tower" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "The Dig"
	CF["LocationPos"][id] = Vector(29, -16)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "The Dig" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Nova"
	CF["LocationPos"][id] = Vector(25, 3)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Nova" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" }

	local id = "Hollow"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Hollow"
	CF["LocationPos"][id] = Vector(34, -39)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Hollow" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Colony"
	CF["LocationPos"][id] = Vector(-8, -19)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Colony" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "In-Flight"
	CF["LocationPos"][id] = Vector(50, -50)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = false
	CF["LocationScenes"][id] = { "In-Flight" }
	CF["LocationPlanet"][id] = "MapPack-Space"
	CF["LocationMissions"][id] = { "Squad" }
end
