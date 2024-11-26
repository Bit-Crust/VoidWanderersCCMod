--[[
	The Coalition SuperHeavy by ryry1237
	http://forums.datarealms.com/viewtopic.php?f=61&t=29649
	Supported out of the box
]]
--

if PresetMan:GetModuleID("CoalitionHeavy.rte") ~= -1 then
	-- Add coalition unit to coalition faction
	local factionid = "Coalition"
	i = #CF.ActNames[factionid] + 1
	CF.ActNames[factionid][i] = "Soldier SuperHeavy"
	CF.ActPresets[factionid][i] = "Soldier SuperHeavy"
	CF.ActModules[factionid][i] = "CoalitionHeavy.rte"
	CF.ActPrices[factionid][i] = 260
	CF.ActDescriptions[factionid][i] =
		"Elite Coalition soldier equipped in full armor plating and outfitted with a reinforced metal helmet. Extra powerful jetpack also comes attached for better maneuverability."
	CF.ActUnlockData[factionid][i] = 2750
	CF.ActTypes[factionid][i] = CF.ActorTypes.HEAVY
	CF.ActPowers[factionid][i] = 8
end
