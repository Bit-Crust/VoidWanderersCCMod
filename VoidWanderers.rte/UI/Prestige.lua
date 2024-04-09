function VoidWanderersPrestige(pieActor, pieMenu, pieSlice)
	if IsAHuman(pieActor) then
		pieActor = ToAHuman(pieActor)
		pieActor:RemoveWounds(pieActor.WoundCount)
		pieActor.Health = pieActor.MaxHealth

		CF_UnBuffActor(ToAHuman(pieActor), pieActor:GetNumberValue("VW_Rank"), pieActor:GetNumberValue("VW_Prestige"))
		pieActor:RemoveNumberValue("VW_XP")
		pieActor:RemoveNumberValue("VW_Rank")
		pieActor:SetNumberValue("VW_Prestige", pieActor:GetNumberValue("VW_Prestige") + 1)
		pieActor:SetStringValue("VW_Name", "")
		pieActor:SetNumberValue("VW_NamingFlag", 1)

		pieMenu:RemovePieSlice(pieSlice)
	end
end
