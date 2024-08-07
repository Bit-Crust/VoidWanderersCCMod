--[[
	Southlands by uberhen
	http://forums.datarealms.com/viewtopic.php?f=24&t=37713
	Supported out of the box
	
	Cliffside by Lizardheim
	http://forums.datarealms.com/viewtopic.php?f=24&t=19321
	Supported out of the box

	Bunker Breach + by burningsky25
	http://forums.datarealms.com/viewtopic.php?f=24&t=32135
	Supported out of the box
	
	Aspect's Scene Pack 1.0! by Aspect
	http://forums.datarealms.com/viewtopic.php?f=24&t=31954
	Supported out of the box
]]
--

local activated = false

-- Planet locations
-- Requires Southlands.rte
if PresetMan:GetModuleID("Southlands.rte") ~= -1 then
	activated = true

	local id = "Southlands"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Southlands"
	CF["LocationPos"][id] = Vector(-12, 52)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 15
	CF["LocationGoldPresent"][id] = false
	CF["LocationScenes"][id] = { "Southlands" }
	CF["LocationPlanet"][id] = "Miranda"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Defend", "Squad" } --]]--
end

-- Requires MiroCliffside.rte
if PresetMan:GetModuleID("MiroCliffside.rte") ~= -1 then
	activated = true

	local id = "Mirokan's Cliffside"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Mirokan's Cliffside"
	CF["LocationPos"][id] = Vector(51, -25)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 25
	CF["LocationGoldPresent"][id] = false
	CF["LocationScenes"][id] = { "Mirokan's Cliffside" }
	CF["LocationPlanet"][id] = "Miranda"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad" } --]]--
end

-- Requires BB+.rte
if PresetMan:GetModuleID("BB+.rte") ~= -1 then
	activated = true

	local id = "Grasslands Garrison"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Grasslands Garrison"
	CF["LocationPos"][id] = Vector(10, -15)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Grasslands Garrison" }
	CF["LocationPlanet"][id] = "Miranda"
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
	} --]]--

	local id = "Silverhill Stronghold"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Silverhill Stronghold"
	CF["LocationPos"][id] = Vector(-30, 32)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Silverhill Stronghold" }
	CF["LocationPlanet"][id] = "Miranda"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" } --]]--

	-- Define BB+ planet
	local id = "The Breach"
	CF["Planet"][#CF["Planet"] + 1] = id
	CF["PlanetName"][id] = "The Breach"
	CF["PlanetGlow"][id] = "The Breach"
	CF["PlanetPos"][id] = Vector(-13, 40)
	CF["PlanetGlowModule"][id] = "VoidWanderers.rte"

	local id = "Bluffside Bastion"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Bluffside Bastion"
	CF["LocationPos"][id] = Vector(56, -5)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Bluffside Bastion" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Burraki Mining Outpost"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Burraki Mining Outpost"
	CF["LocationPos"][id] = Vector(-20, 15)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Burraki Mining Outpost" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Bywater Barracks"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Bywater Barracks"
	CF["LocationPos"][id] = Vector(-50, 25)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Bywater Barracks" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Cliffside Camp"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Cliffside Camp"
	CF["LocationPos"][id] = Vector(-3, 40)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Cliffside Camp" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Fangdor Fortress"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Fangdor Fortress"
	CF["LocationPos"][id] = Vector(47, 23)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Fangdor Fortress" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Hemslock Hold"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Hemslock Hold"
	CF["LocationPos"][id] = Vector(17, 54)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Hemslock Hold" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Hidden Research Center"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Hidden Research Center"
	CF["LocationPos"][id] = Vector(12, 14)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Hidden Research Center" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Lightbank Lair"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Lightbank Lair"
	CF["LocationPos"][id] = Vector(-42, -14)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Lightbank Lair" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Mourning Hollow"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Mourning Hollow"
	CF["LocationPos"][id] = Vector(52, 17)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Mourning Hollow" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Ramshackle Ridge"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Ramshackle Ridge"
	CF["LocationPos"][id] = Vector(13, 21)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Ramshackle Ridge" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--

	local id = "Weyton Watch"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Weyton Watch"
	CF["LocationPos"][id] = Vector(29, 35)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Weyton Watch" }
	CF["LocationPlanet"][id] = "The Breach"
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
	} --]]--
end

-- Requires Bedrock.rte
if PresetMan:GetModuleID("Bedrock.rte") ~= -1 then
	activated = true

	local id = "Canyons"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Canyons"
	CF["LocationPos"][id] = Vector(29, 5)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = { "Canyons" }
	CF["LocationPlanet"][id] = "Miranda"
	CF["LocationMissions"][id] = { "Assault", "Assassinate", "Dropships", "Mine", "Defend", "Squad" } --]]--

	--[[local id = "Stone Mountain"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Stone Mountain"
	CF["LocationPos"][id] = Vector(-49 , -7)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = {"Stone Mountain"}
	CF["LocationPlanet"][id] = "Miranda"
	CF["LocationMissions"][id] = {"Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad"}--]]
	--

	--[[local id = "Temple Cave"
	CF["Location"][#CF["Location"] + 1] = id
	CF["LocationName"][id] = "Temple Cave"
	CF["LocationPos"][id] = Vector(26 , 29)
	CF["LocationRemoveDoors"][id] = true
	CF["LocationDescription"][id] = ""
	CF["LocationSecurity"][id] = 35
	CF["LocationGoldPresent"][id] = true
	CF["LocationScenes"][id] = {"Temple Cave"}
	CF["LocationPlanet"][id] = "Miranda"
	CF["LocationMissions"][id] = {"Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad"}--]]
	--
end

if activated then
	-- Define planet
	local id = "Miranda"
	CF["Planet"][#CF["Planet"] + 1] = id
	CF["PlanetName"][id] = "Miranda"
	CF["PlanetGlow"][id] = "Miranda"
	CF["PlanetPos"][id] = Vector(-43, 10)
	CF["PlanetGlowModule"][id] = "VoidWanderers.rte"
end
