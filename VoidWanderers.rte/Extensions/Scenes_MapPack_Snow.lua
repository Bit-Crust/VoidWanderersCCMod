--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-Snow"
	CF_Planet[#CF_Planet + 1] = id
	CF_PlanetName[id] = "MapPack-Snow"
	CF_PlanetGlow[id] = "MapPack-Snow"
	CF_PlanetPos[id] = Vector(-26, 0)
	CF_PlanetGlowModule[id] = "VoidWanderers.rte"

	-- Planet locations
	local id = "Arctic Pole"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Arctic Pole"
	CF_LocationPos[id] = Vector(-6, -9)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Arctic Pole" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Summit"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Summit"
	CF_LocationPos[id] = Vector(-0, -22)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Summit" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Snow Cave"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Snow Cave"
	CF_LocationPos[id] = Vector(-2, -46)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Snow Cave" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Missile Silo"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Missile Silo"
	CF_LocationPos[id] = Vector(-43, 9)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Missile Silo" }
	CF_LocationPlanet[id] = "MapPack-Snow"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Evacuate" }

	local id = "Glacier"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Glacier"
	CF_LocationPos[id] = Vector(-26, 13)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Glacier" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Ice Caves"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Ice Caves"
	CF_LocationPos[id] = Vector(23, -2)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Ice Caves" }
	CF_LocationPlanet[id] = "MapPack-Snow"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Destroy", "Squad", "Evacuate" }

	local id = "Cold Slabs"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Cold Slabs"
	CF_LocationPos[id] = Vector(-6, 6)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Cold Slabs" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Cliffside"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Cliffside"
	CF_LocationPos[id] = Vector(21, 31)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Cliffside" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Ant Hill"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Ant Hill"
	CF_LocationPos[id] = Vector(40, -7)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Ant Hill" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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

	local id = "Drilling Rig"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Drilling Rig"
	CF_LocationPos[id] = Vector(14, -29)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Drilling Rig" }
	CF_LocationPlanet[id] = "MapPack-Snow"
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
