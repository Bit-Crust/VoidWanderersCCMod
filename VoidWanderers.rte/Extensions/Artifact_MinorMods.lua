--[[
	Deployable Turret by CaveCricket48
	http://forums.datarealms.com/viewtopic.php?f=61&p=503942
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Deployable Turret.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Deployable Turret"
	CF.ArtItmModules[id] = "Deployable Turret.rte"
	CF.ArtItmClasses[id] = "TDExplosive"
end

-------------------------------------------------------------------------------

--[[
	High Impulse Weapon System by p3lb0x
	http://forums.datarealms.com/viewtopic.php?f=61&p=524295
	Supported out of the box
]]
--

if PresetMan:GetModuleID("HIWS.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "HIWS"
	CF.ArtItmModules[id] = "HIWS.rte"
	CF.ArtItmClasses[id] = "HDFirearm"
end

-------------------------------------------------------------------------------

--[[
	The High Energy Pulse Projector by p3lb0x
	http://forums.datarealms.com/viewtopic.php?f=61&p=486586
	Supported out of the box
]]
--

if PresetMan:GetModuleID("HEPP.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "HEPP"
	CF.ArtItmModules[id] = "HEPP.rte"
	CF.ArtItmClasses[id] = "HDFirearm"
end

-------------------------------------------------------------------------------

--[[
	Dummy Rocket Launchers by p3lb0x
	http://forums.datarealms.com/viewtopic.php?f=61&t=14458	
	Supported out of the box
]]
--

-- Add items
if PresetMan:GetModuleID("DummyAPRL.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Dummy APR Launcher"
	CF.ArtItmModules[id] = "DummyAPRL.rte"
	CF.ArtItmClasses[id] = "HDFirearm"
end

if PresetMan:GetModuleID("DummyMRlauncher.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Dummy MR Launcher"
	CF.ArtItmModules[id] = "DummyMRlauncher.rte"
	CF.ArtItmClasses[id] = "HDFirearm"
end
-------------------------------------------------------------------------------

--[[
	Aeon Tech by Arcalane
	http://forums.datarealms.com/viewtopic.php?p=534293#p534293
	Supported out of the box
]]
--

if PresetMan:GetModuleID("ATech.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Rail Sniper Rifle"
	CF.ArtItmModules[id] = "ATech.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Pacifier Battle Rifle"
	CF.ArtItmModules[id] = "ATech.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Jotun Grenade Launcher"
	CF.ArtItmModules[id] = "ATech.rte"
	CF.ArtItmClasses[id] = "HDFirearm"
end
-------------------------------------------------------------------------------

--[[
	Khandari by Major
	http://forums.datarealms.com/viewtopic.php?f=61&p=495858
	Supported out of the box
]]
--

-- Add items
if PresetMan:GetModuleID("Khandari.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Jia Z-KK"
	CF.ArtItmModules[id] = "Khandari.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "SKorpion"
	CF.ArtItmModules[id] = "Khandari.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Dune Spider"
	CF.ArtItmModules[id] = "Khandari.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Talon KV"
	CF.ArtItmModules[id] = "Khandari.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Aurochs T52"
	CF.ArtItmModules[id] = "Khandari.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "RAM T98"
	CF.ArtItmModules[id] = "Khandari.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	-- Add actors
	local id = #CF.ArtActPresets + 1
	CF.ArtActPresets[id] = "Khandastar Medium Infantry"
	CF.ArtActModules[id] = "Khandari.rte"
	CF.ArtActClasses[id] = "AHuman"

	-- Add pirates only if pirate encounters are loaded
	if CF.RandomEncountersInitialTexts["PIRATE_GENERIC"] ~= nil then
		local pid = #CF.RandomEncounterPirates + 1
		CF.RandomEncounterPirates[pid] = {}
		CF.RandomEncounterPirates[pid]["Captain"] = "Major"
		CF.RandomEncounterPirates[pid]["Ship"] = "Jizzrah"
		CF.RandomEncounterPirates[pid]["Org"] = "The Continent-Republic of Khandastar"
		CF.RandomEncounterPirates[pid]["FeeInc"] = 650

		CF.RandomEncounterPirates[pid]["Act"] = { "Khandastar Medium Infantry" }
		CF.RandomEncounterPirates[pid]["ActMod"] = { "Khandari.rte" }

		CF.RandomEncounterPirates[pid]["Itm"] = { "RAM T98", "Talon KV" }
		CF.RandomEncounterPirates[pid]["ItmMod"] = { "Khandari.rte", "Khandari.rte" }

		CF.RandomEncounterPirates[pid]["Units"] = 5
		CF.RandomEncounterPirates[pid]["Burst"] = 1
		CF.RandomEncounterPirates[pid]["Interval"] = 16
	end
end

-------------------------------------------------------------------------------

--[[
	The Flagship by Nonsequitorian
	http://forums.datarealms.com/viewtopic.php?f=61&t=21276
	Outdated, compatible version here - https://dl.dropboxusercontent.com/u/1741337/VoidWanderers/ArtifactMods/SteamNon_V105.rte.zip
]]
--

-- CURRENTLY DISABLED DUE TO GAME CRASH PROBLEMS

--[[if PresetMan:GetModuleID("SteamNon.rte") ~= -1 then
	-- Add items
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Heavy Cannon"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "MacKinmiad Dueling Devai'l"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "M3 ShotGatler"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Needle Gun"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "SOGR"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Vista Nova"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Walden BN-76"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Walden Model 3"
	CF.ArtItmModules[id] = "SteamNon.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	-- Add actors
	local id = #CF.ArtActPresets + 1
	CF.ArtActPresets[id] = "Steamer"
	CF.ArtActModules[id] = "SteamNon.rte"
	CF.ArtActClasses[id] = "AHuman"

	local id = #CF.ArtActPresets + 1
	CF.ArtActPresets[id] = "Dampf"
	CF.ArtActModules[id] = "SteamNon.rte"
	CF.ArtActClasses[id] = "AHuman"

	local id = #CF.ArtActPresets + 1
	CF.ArtActPresets[id] = "Barton"
	CF.ArtActModules[id] = "SteamNon.rte"
	CF.ArtActClasses[id] = "AHuman"
end--]]
--

-------------------------------------------------------------------------------

--[[
	Dummy Particle Accelerator by CaveCricket48
	http://forums.datarealms.com/viewtopic.php?f=61&t=17667
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Dummy Particle Accelerator.rte") ~= -1 then
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Dummy Particle Accelerator"
	CF.ArtItmModules[id] = "Dummy Particle Accelerator.rte"
	CF.ArtItmClasses[id] = "HDFirearm"
end
