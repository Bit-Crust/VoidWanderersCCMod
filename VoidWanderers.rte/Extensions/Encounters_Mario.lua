if PresetMan:GetModuleID("Mario.rte") ~= -1 then
	local pid = #CF_RandomEncounterPirates + 1
	CF_RandomEncounterPirates[pid] = {}
	CF_RandomEncounterPirates[pid]["Captain"] = "Miyamoto-san"
	CF_RandomEncounterPirates[pid]["Ship"] = "Nintendo"
	CF_RandomEncounterPirates[pid]["Org"] = "the Mushroom Kingdom"
	CF_RandomEncounterPirates[pid]["FeeInc"] = 320
	--
	CF_RandomEncounterPirates[pid]["MsgBribe"] = "Thank you so much for to playing my game!"
	CF_RandomEncounterPirates[pid]["MsgHostile"] = "So long, eh Bowser?"
	CF_RandomEncounterPirates[pid]["MsgDefeat"] = "Mama mia!"
	--
	CF_RandomEncounterPirates[pid]["Act"] = { "Mario", "Luigi" }
	CF_RandomEncounterPirates[pid]["ActMod"] = { "Mario.rte", "Mario.rte" }

	CF_RandomEncounterPirates[pid]["Itm"] = { "SMG" }
	CF_RandomEncounterPirates[pid]["ItmMod"] = { "Base.rte" }

	CF_RandomEncounterPirates[pid]["Thrown"] = { "Hammer", "Bob-omb" }
	CF_RandomEncounterPirates[pid]["ThrownMod"] = { "Mario.rte", "Mario.rte" }

	CF_RandomEncounterPirates[pid]["Units"] = 64
	CF_RandomEncounterPirates[pid]["Burst"] = 1
	CF_RandomEncounterPirates[pid]["Interval"] = 5
end
