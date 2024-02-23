--[[
	Deployable Turret by CaveCricket48
	http://forums.datarealms.com/viewtopic.php?f=61&p=503942
	Supported out of the box
]]
--

if PresetMan:GetModuleID("Deployable Turret.rte") ~= -1 then
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Deployable Turret"
	CF_ArtItmModules[id] = "Deployable Turret.rte"
	CF_ArtItmClasses[id] = "TDExplosive"
end

-------------------------------------------------------------------------------

--[[
	High Impulse Weapon System by p3lb0x
	http://forums.datarealms.com/viewtopic.php?f=61&p=524295
	Supported out of the box
]]
--

if PresetMan:GetModuleID("HIWS.rte") ~= -1 then
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "HIWS"
	CF_ArtItmModules[id] = "HIWS.rte"
	CF_ArtItmClasses[id] = "HDFirearm"
end

-------------------------------------------------------------------------------

--[[
	The High Energy Pulse Projector by p3lb0x
	http://forums.datarealms.com/viewtopic.php?f=61&p=486586
	Supported out of the box
]]
--

if PresetMan:GetModuleID("HEPP.rte") ~= -1 then
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "HEPP"
	CF_ArtItmModules[id] = "HEPP.rte"
	CF_ArtItmClasses[id] = "HDFirearm"
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
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Dummy APR Launcher"
	CF_ArtItmModules[id] = "DummyAPRL.rte"
	CF_ArtItmClasses[id] = "HDFirearm"
end

if PresetMan:GetModuleID("DummyMRlauncher.rte") ~= -1 then
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Dummy MR Launcher"
	CF_ArtItmModules[id] = "DummyMRlauncher.rte"
	CF_ArtItmClasses[id] = "HDFirearm"
end
-------------------------------------------------------------------------------

--[[
	Aeon Tech by Arcalane
	http://forums.datarealms.com/viewtopic.php?p=534293#p534293
	Supported out of the box
]]
--

if PresetMan:GetModuleID("ATech.rte") ~= -1 then
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Rail Sniper Rifle"
	CF_ArtItmModules[id] = "ATech.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Pacifier Battle Rifle"
	CF_ArtItmModules[id] = "ATech.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Jotun Grenade Launcher"
	CF_ArtItmModules[id] = "ATech.rte"
	CF_ArtItmClasses[id] = "HDFirearm"
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
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Jia Z-KK"
	CF_ArtItmModules[id] = "Khandari.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "SKorpion"
	CF_ArtItmModules[id] = "Khandari.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Dune Spider"
	CF_ArtItmModules[id] = "Khandari.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Talon KV"
	CF_ArtItmModules[id] = "Khandari.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Aurochs T52"
	CF_ArtItmModules[id] = "Khandari.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "RAM T98"
	CF_ArtItmModules[id] = "Khandari.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	-- Add actors
	local id = #CF_ArtActPresets + 1
	CF_ArtActPresets[id] = "Khandastar Medium Infantry"
	CF_ArtActModules[id] = "Khandari.rte"
	CF_ArtActClasses[id] = "AHuman"

	-- Add pirates only if pirate encounters are loaded
	if CF_RandomEncountersInitialTexts["PIRATE_GENERIC"] ~= nil then
		local pid = #CF_RandomEncounterPirates + 1
		CF_RandomEncounterPirates[pid] = {}
		CF_RandomEncounterPirates[pid]["Captain"] = "Major"
		CF_RandomEncounterPirates[pid]["Ship"] = "Jizzrah"
		CF_RandomEncounterPirates[pid]["Org"] = "The Continent-Republic of Khandastar"
		CF_RandomEncounterPirates[pid]["FeeInc"] = 650

		CF_RandomEncounterPirates[pid]["Act"] = { "Khandastar Medium Infantry" }
		CF_RandomEncounterPirates[pid]["ActMod"] = { "Khandari.rte" }

		CF_RandomEncounterPirates[pid]["Itm"] = { "RAM T98", "Talon KV" }
		CF_RandomEncounterPirates[pid]["ItmMod"] = { "Khandari.rte", "Khandari.rte" }

		CF_RandomEncounterPirates[pid]["Units"] = 5
		CF_RandomEncounterPirates[pid]["Burst"] = 1
		CF_RandomEncounterPirates[pid]["Interval"] = 16
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
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Heavy Cannon"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "MacKinmiad Dueling Devai'l"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "M3 ShotGatler"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Needle Gun"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "SOGR"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Vista Nova"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Walden BN-76"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Walden Model 3"
	CF_ArtItmModules[id] = "SteamNon.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	-- Add actors
	local id = #CF_ArtActPresets + 1
	CF_ArtActPresets[id] = "Steamer"
	CF_ArtActModules[id] = "SteamNon.rte"
	CF_ArtActClasses[id] = "AHuman"

	local id = #CF_ArtActPresets + 1
	CF_ArtActPresets[id] = "Dampf"
	CF_ArtActModules[id] = "SteamNon.rte"
	CF_ArtActClasses[id] = "AHuman"

	local id = #CF_ArtActPresets + 1
	CF_ArtActPresets[id] = "Barton"
	CF_ArtActModules[id] = "SteamNon.rte"
	CF_ArtActClasses[id] = "AHuman"
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
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Dummy Particle Accelerator"
	CF_ArtItmModules[id] = "Dummy Particle Accelerator.rte"
	CF_ArtItmClasses[id] = "HDFirearm"
end
