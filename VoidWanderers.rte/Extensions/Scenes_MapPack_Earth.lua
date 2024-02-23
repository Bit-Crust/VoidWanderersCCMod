--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-Earth"
	CF_Planet[#CF_Planet + 1] = id
	CF_PlanetName[id] = "MapPack-Earth"
	CF_PlanetGlow[id] = "MapPack-Earth"
	CF_PlanetPos[id] = Vector(-12, 42)
	CF_PlanetGlowModule[id] = "VoidWanderers.rte"

	-- Planet locations
	local id = "Wastelands"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Wastelands"
	CF_LocationPos[id] = Vector(-34, 27)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Wastelands" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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

	-- Enable only if MP3 patch installed
	-- Will crash the game due to Base.rte/Mine if MP3 is not patched
	local id = "Excavation"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Excavation"
	CF_LocationPos[id] = Vector(-7, 12)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Excavation" }
	CF_LocationPlanet[id] = "MapPack-Earth"
	CF_LocationMissions[id] = {
		"Assault",
		"Assassinate",
		"Dropships",
		"Mine",
		"Zombies",
		"Defend",
		"Destroy",
		"Evacuate",
	} --]]--

	local id = "Ragnarok"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Ragnarok"
	CF_LocationPos[id] = Vector(-14, 31)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Ragnarok" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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

	local id = "Gryphon"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Gryphon"
	CF_LocationPos[id] = Vector(25, 9)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = "Gryphon"
	CF_LocationSecurity[id] = 30
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Gryphon" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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

	local id = "Old Dam"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Old Dam"
	CF_LocationPos[id] = Vector(23, -22)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 20
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Old Dam" }
	CF_LocationPlanet[id] = "MapPack-Earth"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" }

	local id = "Station 134"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Station 134"
	CF_LocationRemoveDoors[id] = true
	CF_LocationPos[id] = Vector(14, 8)
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Station 134" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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

	local id = "Dry Flats"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Dry Flats"
	CF_LocationRemoveDoors[id] = true
	CF_LocationPos[id] = Vector(-8, -45)
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 0
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Dry Flats" }
	CF_LocationPlanet[id] = "MapPack-Earth"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad" }

	local id = "Snaggleteeth"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Snaggleteeth"
	CF_LocationPos[id] = Vector(34, -39)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Snaggleteeth" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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

	local id = "Sand Crawler"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Sand Crawler"
	CF_LocationPos[id] = Vector(-14, -39)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Sand Crawler" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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

	local id = "Bunker S57-A"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Bunker S57-A"
	CF_LocationPos[id] = Vector(-18, -29)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 10
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Bunker S57-A" }
	CF_LocationPlanet[id] = "MapPack-Earth"
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
