--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-Snow"
	CF.Planet[#CF.Planet + 1] = id
	CF.PlanetName[id] = "MapPack-Snow"
	CF.PlanetGlow[id] = "Mods/VoidWanderers.rte/UI/Planets/MP3-GTC-SNW.png"
	CF.PlanetPos[id] = Vector(-26, 0)

	-- Planet locations
	local id = "Arctic Pole"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Arctic Pole"
	CF.LocationPos[id] = Vector(-6, -9)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Arctic Pole" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Summit"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Summit"
	CF.LocationPos[id] = Vector(-0, -22)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Summit" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Snow Cave"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Snow Cave"
	CF.LocationPos[id] = Vector(-2, -46)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Snow Cave" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Missile Silo"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Missile Silo"
	CF.LocationPos[id] = Vector(-43, 9)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Missile Silo" }
	CF.LocationPlanet[id] = "MapPack-Snow"
	CF.LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Evacuate" }

	local id = "Glacier"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Glacier"
	CF.LocationPos[id] = Vector(-26, 13)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Glacier" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Ice Caves"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Ice Caves"
	CF.LocationPos[id] = Vector(23, -2)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Ice Caves" }
	CF.LocationPlanet[id] = "MapPack-Snow"
	CF.LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Destroy", "Squad", "Evacuate" }

	local id = "Cold Slabs"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Cold Slabs"
	CF.LocationPos[id] = Vector(-6, 6)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 0
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Cold Slabs" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Cliffside"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Cliffside"
	CF.LocationPos[id] = Vector(21, 31)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Cliffside" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Ant Hill"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Ant Hill"
	CF.LocationPos[id] = Vector(40, -7)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Ant Hill" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Drilling Rig"
	CF.Location[#CF.Location + 1] = id
	CF.LocationName[id] = "Drilling Rig"
	CF.LocationPos[id] = Vector(14, -29)
	CF.LocationDescription[id] = ""
	CF.LocationSecurity[id] = 10
	CF.LocationGoldPresent[id] = true
	CF.LocationScenes[id] = { "Drilling Rig" }
	CF.LocationPlanet[id] = "MapPack-Snow"
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
