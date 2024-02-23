if PresetMan:GetModuleID("4Z.rte") ~= -1 then
	local id = "4ZOMBIE"
	CF_RandomEncounters[#CF_RandomEncounters + 1] = id
	CF_RandomEncountersInitialTexts[id] = ""
	CF_RandomEncountersInitialVariants[id] = { "", "" }
	CF_RandomEncountersVariantsInterval[id] = 24
	CF_RandomEncountersOneTime[id] = false
	CF_RandomEncountersFunctions[id] = 
function(self, variant) end
end
