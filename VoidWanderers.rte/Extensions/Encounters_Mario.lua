if PresetMan:GetModuleID("Mario.rte") ~= -1 then
	local pid = #CF["RandomEncounterPirates"] + 1
	CF["RandomEncounterPirates"][pid] = {}
	CF["RandomEncounterPirates"][pid]["Captain"] = "Miyamoto-san"
	CF["RandomEncounterPirates"][pid]["Ship"] = "Nintendo"
	CF["RandomEncounterPirates"][pid]["Org"] = "the Mushroom Kingdom"
	CF["RandomEncounterPirates"][pid]["FeeInc"] = 320
	--
	CF["RandomEncounterPirates"][pid]["MsgBribe"] = "Thank you so much for to playing my game!"
	CF["RandomEncounterPirates"][pid]["MsgHostile"] = "So long, eh Bowser?"
	CF["RandomEncounterPirates"][pid]["MsgDefeat"] = "Mama mia!"
	--
	CF["RandomEncounterPirates"][pid]["Act"] = { "Mario", "Luigi" }
	CF["RandomEncounterPirates"][pid]["ActMod"] = { "Mario.rte", "Mario.rte" }

	CF["RandomEncounterPirates"][pid]["Itm"] = { "SMG" }
	CF["RandomEncounterPirates"][pid]["ItmMod"] = { "Base.rte" }

	CF["RandomEncounterPirates"][pid]["Thrown"] = { "Hammer", "Bob-omb" }
	CF["RandomEncounterPirates"][pid]["ThrownMod"] = { "Mario.rte", "Mario.rte" }

	CF["RandomEncounterPirates"][pid]["Units"] = 64
	CF["RandomEncounterPirates"][pid]["Burst"] = 1
	CF["RandomEncounterPirates"][pid]["Interval"] = 5
end
