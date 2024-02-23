--[[
	Novamind by p3lbox
	http://forums.datarealms.com/viewtopic.php?f=61&t=16238
	Supported out of the box
]]
--

if PresetMan:GetModuleID("NovaMind.rte") ~= -1 then
	--[[ Add items
	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Johnson Railgun"
	CF_ArtItmModules[id] = "NovaMind.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "SN-15"
	CF_ArtItmModules[id] = "NovaMind.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	local id = #CF_ArtItmPresets + 1
	CF_ArtItmPresets[id] = "Garrett LMG"
	CF_ArtItmModules[id] = "NovaMind.rte"
	CF_ArtItmClasses[id] = "HDFirearm"

	-- Add actors
	local id = #CF_ArtActPresets + 1
	CF_ArtActPresets[id] = "NovaMind Light"
	CF_ArtActModules[id] = "NovaMind.rte"
	CF_ArtActClasses[id] = "AHuman"

	local id = #CF_ArtActPresets + 1
	CF_ArtActPresets[id] = "Nova Mind Medium"
	CF_ArtActModules[id] = "NovaMind.rte"
	CF_ArtActClasses[id] = "AHuman"
]]
	--
	-- Add pirates only if pirate encounters are loaded
	if CF_RandomEncountersInitialTexts["PIRATE_GENERIC"] ~= nil then
		local pid = #CF_RandomEncounterPirates + 1
		CF_RandomEncounterPirates[pid] = {}
		CF_RandomEncounterPirates[pid]["Captain"] = "p3lb0x"
		CF_RandomEncounterPirates[pid]["Ship"] = "NVS-1337"
		CF_RandomEncounterPirates[pid]["Org"] = "Nova Mind Libertarians"
		CF_RandomEncounterPirates[pid]["FeeInc"] = 650

		CF_RandomEncounterPirates[pid]["Act"] = { "NovaMind Light", "Nova Mind Medium" }
		CF_RandomEncounterPirates[pid]["ActMod"] = { "NovaMind.rte", "NovaMind.rte" }

		CF_RandomEncounterPirates[pid]["Itm"] = { "Garrett LMG", "Garrett LMG", "Garrett LMG", "SN-15" }
		CF_RandomEncounterPirates[pid]["ItmMod"] = { "NovaMind.rte", "NovaMind.rte", "NovaMind.rte", "NovaMind.rte" }

		CF_RandomEncounterPirates[pid]["Units"] = 5
		CF_RandomEncounterPirates[pid]["Burst"] = 1
		CF_RandomEncounterPirates[pid]["Interval"] = 16
	end
end
