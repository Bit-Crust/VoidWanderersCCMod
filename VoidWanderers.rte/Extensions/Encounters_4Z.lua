if PresetMan:GetModuleID("4Z.rte") ~= -1 then
	local id = "4ZOMBIE"
	CF.RandomEncounters[#CF.RandomEncounters + 1] = id
	CF.RandomEncountersInitialTexts[id] = ""
	CF.RandomEncountersInitialVariants[id] = { "", "" }
	CF.RandomEncountersVariantsInterval[id] = 24
	CF.RandomEncountersOneTime[id] = false
	CF.RandomEncountersFunctions[id] = 
function(self, variant) end
end
