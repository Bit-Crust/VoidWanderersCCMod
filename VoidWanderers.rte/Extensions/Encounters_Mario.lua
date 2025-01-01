if PresetMan:GetModuleID("Mario.rte") ~= -1 then
	local pid = #CF.PirateBands + 1
	CF.PirateBands[pid] = {}
	CF.PirateBands[pid]["Captain"] = "Miyamoto-san"
	CF.PirateBands[pid]["Ship"] = "Nintendo"
	CF.PirateBands[pid]["Org"] = "the Mushroom Kingdom"
	CF.PirateBands[pid]["FeeInc"] = 320
	--
	CF.PirateBands[pid]["MsgBribe"] = "Thank you so much for to playing my game!"
	CF.PirateBands[pid]["MsgHostile"] = "So long, eh Bowser?"
	CF.PirateBands[pid]["MsgDefeat"] = "Mama mia!"
	--
	CF.PirateBands[pid]["Act"] = { "Mario", "Luigi" }
	CF.PirateBands[pid]["ActMod"] = { "Mario.rte", "Mario.rte" }

	CF.PirateBands[pid]["Itm"] = { "SMG" }
	CF.PirateBands[pid]["ItmMod"] = { "Base.rte" }

	CF.PirateBands[pid]["Thrown"] = { "Hammer", "Bob-omb" }
	CF.PirateBands[pid]["ThrownMod"] = { "Mario.rte", "Mario.rte" }

	CF.PirateBands[pid]["Units"] = 64
	CF.PirateBands[pid]["Burst"] = 1
	CF.PirateBands[pid]["Interval"] = 5
end
