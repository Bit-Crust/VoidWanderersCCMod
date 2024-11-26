--[[
	Novamind by p3lbox
	http://forums.datarealms.com/viewtopic.php?f=61&t=16238
	Supported out of the box
]]
--

if PresetMan:GetModuleID("NovaMind.rte") ~= -1 then
	--[[ Add items
	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Johnson Railgun"
	CF.ArtItmModules[id] = "NovaMind.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "SN-15"
	CF.ArtItmModules[id] = "NovaMind.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	local id = #CF.ArtItmPresets + 1
	CF.ArtItmPresets[id] = "Garrett LMG"
	CF.ArtItmModules[id] = "NovaMind.rte"
	CF.ArtItmClasses[id] = "HDFirearm"

	-- Add actors
	local id = #CF.ArtActPresets + 1
	CF.ArtActPresets[id] = "NovaMind Light"
	CF.ArtActModules[id] = "NovaMind.rte"
	CF.ArtActClasses[id] = "AHuman"

	local id = #CF.ArtActPresets + 1
	CF.ArtActPresets[id] = "Nova Mind Medium"
	CF.ArtActModules[id] = "NovaMind.rte"
	CF.ArtActClasses[id] = "AHuman"
]]
	--
	-- Add pirates only if pirate encounters are loaded
	if CF.RandomEncountersInitialTexts["PIRATE_GENERIC"] ~= nil then
		local pid = #CF.RandomEncounterPirates + 1
		CF.RandomEncounterPirates[pid] = {}
		CF.RandomEncounterPirates[pid]["Captain"] = "p3lb0x"
		CF.RandomEncounterPirates[pid]["Ship"] = "NVS-1337"
		CF.RandomEncounterPirates[pid]["Org"] = "Nova Mind Libertarians"
		CF.RandomEncounterPirates[pid]["FeeInc"] = 650

		CF.RandomEncounterPirates[pid]["Act"] = { "NovaMind Light", "Nova Mind Medium" }
		CF.RandomEncounterPirates[pid]["ActMod"] = { "NovaMind.rte", "NovaMind.rte" }

		CF.RandomEncounterPirates[pid]["Itm"] = { "Garrett LMG", "Garrett LMG", "Garrett LMG", "SN-15" }
		CF.RandomEncounterPirates[pid]["ItmMod"] = { "NovaMind.rte", "NovaMind.rte", "NovaMind.rte", "NovaMind.rte" }

		CF.RandomEncounterPirates[pid]["Units"] = 5
		CF.RandomEncounterPirates[pid]["Burst"] = 1
		CF.RandomEncounterPirates[pid]["Interval"] = 16
	end
end
