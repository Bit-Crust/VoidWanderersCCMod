--[[
	Map Pack by Gotcha!
	http://forums.datarealms.com/viewtopic.php?f=24&t=12224
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Mappack.rte") ~= -1 then
	-- Define planet
	local id = "MapPack-Earth"
	CF["Planet"][#CF["Planet"] + 1] = id
	CF["PlanetName"][id] = "MapPack-Earth"
	CF["PlanetGlow"][id] = "MapPack-Earth"
	CF["PlanetPos"][id] = Vector(-12, 42)
	CF["PlanetGlowModule"][id] = "VoidWanderers.rte"

	-- Planet locations
	local id = "Wastelands"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Wastelands"
	CF["LocationPos"][id] = Vector(-34, 27)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Wastelands" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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

	-- Enable only if MP3 patch installed
	-- Will crash the game due to Base.rte/Mine if MP3 is not patched
	local id = "Excavation"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Excavation"
	CF["LocationPos"][id] = Vector(-7, 12)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Excavation" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
	CF["LocationMissions"][id] = {
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
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Ragnarok"
	CF["LocationPos"][id] = Vector(-14, 31)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Ragnarok" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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

	local id = "Gryphon"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Gryphon"
	CF["LocationPos"][id] = Vector(25, 9)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = "Gryphon"
	CF["LocationSecurity"][id] = 30
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Gryphon" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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

	local id = "Old Dam"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Old Dam"
	CF["LocationPos"][id] = Vector(23, -22)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 20
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Old Dam" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" }

	local id = "Station 134"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Station 134"
	CF["LocationRemoveDoors"][id] = true
	CF["LocationPos"][id] = Vector(14, 8)
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Station 134" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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

	local id = "Dry Flats"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Dry Flats"
	CF["LocationRemoveDoors"][id] = true
	CF["LocationPos"][id] = Vector(-8, -45)
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 0
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Dry Flats" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad" }

	local id = "Snaggleteeth"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Snaggleteeth"
	CF["LocationPos"][id] = Vector(34, -39)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Snaggleteeth" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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

	local id = "Sand Crawler"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Sand Crawler"
	CF["LocationPos"][id] = Vector(-14, -39)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Sand Crawler" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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

	local id = "Bunker S57-A"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Bunker S57-A"
	CF["LocationPos"][id] = Vector(-18, -29)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 10
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Bunker S57-A" }
	CF["LocationPlanet"][id] = "MapPack-Earth"
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
end
