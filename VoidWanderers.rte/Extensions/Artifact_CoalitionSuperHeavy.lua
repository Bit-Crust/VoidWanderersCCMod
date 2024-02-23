--[[
	The Coalition SuperHeavy by ryry1237
	http://forums.datarealms.com/viewtopic.php?f=61&t=29649
	Supported out of the box
]]
--

if PresetMan:GetModuleID("CoalitionHeavy.rte") ~= -1 then
	-- Add coalition unit to coalition faction
	local factionid = "Coalition"
	i = #CF_ActNames[factionid] + 1
	CF_ActNames[factionid][i] = "Soldier SuperHeavy"
	CF_ActPresets[factionid][i] = "Soldier SuperHeavy"
	CF_ActModules[factionid][i] = "CoalitionHeavy.rte"
	CF_ActPrices[factionid][i] = 260
	CF_ActDescriptions[factionid][i] =
		"Elite Coalition soldier equipped in full armor plating and outfitted with a reinforced metal helmet. Extra powerful jetpack also comes attached for better maneuverability."
	CF_ActUnlockData[factionid][i] = 2750
	CF_ActTypes[factionid][i] = CF_ActorTypes.HEAVY
	CF_ActPowers[factionid][i] = 8
end
