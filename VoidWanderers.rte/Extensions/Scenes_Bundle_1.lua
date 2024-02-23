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
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Southlands"
	CF_LocationPos[id] = Vector(-12, 52)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 15
	CF_LocationGoldPresent[id] = false
	CF_LocationScenes[id] = { "Southlands" }
	CF_LocationPlanet[id] = "Miranda"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Defend", "Squad" } --]]--
end

-- Requires MiroCliffside.rte
if PresetMan:GetModuleID("MiroCliffside.rte") ~= -1 then
	activated = true

	local id = "Mirokan's Cliffside"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Mirokan's Cliffside"
	CF_LocationPos[id] = Vector(51, -25)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 25
	CF_LocationGoldPresent[id] = false
	CF_LocationScenes[id] = { "Mirokan's Cliffside" }
	CF_LocationPlanet[id] = "Miranda"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad" } --]]--
end

-- Requires BB+.rte
if PresetMan:GetModuleID("BB+.rte") ~= -1 then
	activated = true

	local id = "Grasslands Garrison"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Grasslands Garrison"
	CF_LocationPos[id] = Vector(10, -15)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Grasslands Garrison" }
	CF_LocationPlanet[id] = "Miranda"
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
	} --]]--

	local id = "Silverhill Stronghold"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Silverhill Stronghold"
	CF_LocationPos[id] = Vector(-30, 32)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Silverhill Stronghold" }
	CF_LocationPlanet[id] = "Miranda"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Zombies", "Defend", "Destroy", "Squad", "Evacuate" } --]]--

	-- Define BB+ planet
	local id = "The Breach"
	CF_Planet[#CF_Planet + 1] = id
	CF_PlanetName[id] = "The Breach"
	CF_PlanetGlow[id] = "The Breach"
	CF_PlanetPos[id] = Vector(-13, 40)
	CF_PlanetGlowModule[id] = "VoidWanderers.rte"

	local id = "Bluffside Bastion"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Bluffside Bastion"
	CF_LocationPos[id] = Vector(56, -5)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Bluffside Bastion" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Burraki Mining Outpost"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Burraki Mining Outpost"
	CF_LocationPos[id] = Vector(-20, 15)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Burraki Mining Outpost" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Bywater Barracks"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Bywater Barracks"
	CF_LocationPos[id] = Vector(-50, 25)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Bywater Barracks" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Cliffside Camp"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Cliffside Camp"
	CF_LocationPos[id] = Vector(-3, 40)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Cliffside Camp" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Fangdor Fortress"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Fangdor Fortress"
	CF_LocationPos[id] = Vector(47, 23)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Fangdor Fortress" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Hemslock Hold"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Hemslock Hold"
	CF_LocationPos[id] = Vector(17, 54)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Hemslock Hold" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Hidden Research Center"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Hidden Research Center"
	CF_LocationPos[id] = Vector(12, 14)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Hidden Research Center" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Lightbank Lair"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Lightbank Lair"
	CF_LocationPos[id] = Vector(-42, -14)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Lightbank Lair" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Mourning Hollow"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Mourning Hollow"
	CF_LocationPos[id] = Vector(52, 17)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Mourning Hollow" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Ramshackle Ridge"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Ramshackle Ridge"
	CF_LocationPos[id] = Vector(13, 21)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Ramshackle Ridge" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--

	local id = "Weyton Watch"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Weyton Watch"
	CF_LocationPos[id] = Vector(29, 35)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Weyton Watch" }
	CF_LocationPlanet[id] = "The Breach"
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
	} --]]--
end

-- Requires Bedrock.rte
if PresetMan:GetModuleID("Bedrock.rte") ~= -1 then
	activated = true

	local id = "Canyons"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Canyons"
	CF_LocationPos[id] = Vector(29, 5)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = { "Canyons" }
	CF_LocationPlanet[id] = "Miranda"
	CF_LocationMissions[id] = { "Assault", "Assassinate", "Dropships", "Mine", "Defend", "Squad" } --]]--

	--[[local id = "Stone Mountain"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Stone Mountain"
	CF_LocationPos[id] = Vector(-49 , -7)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = {"Stone Mountain"}
	CF_LocationPlanet[id] = "Miranda"
	CF_LocationMissions[id] = {"Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad"}--]]
	--

	--[[local id = "Temple Cave"
	CF_Location[#CF_Location + 1] = id
	CF_LocationName[id] = "Temple Cave"
	CF_LocationPos[id] = Vector(26 , 29)
	CF_LocationRemoveDoors[id] = true
	CF_LocationDescription[id] = ""
	CF_LocationSecurity[id] = 35
	CF_LocationGoldPresent[id] = true
	CF_LocationScenes[id] = {"Temple Cave"}
	CF_LocationPlanet[id] = "Miranda"
	CF_LocationMissions[id] = {"Assault", "Assassinate", "Dropships", "Mine", "Zombies", "Defend", "Destroy", "Squad"}--]]
	--
end

if activated then
	-- Define planet
	local id = "Miranda"
	CF_Planet[#CF_Planet + 1] = id
	CF_PlanetName[id] = "Miranda"
	CF_PlanetGlow[id] = "Miranda"
	CF_PlanetPos[id] = Vector(-43, 10)
	CF_PlanetGlowModule[id] = "VoidWanderers.rte"
end
