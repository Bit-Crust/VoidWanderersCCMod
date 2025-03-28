require("Scripts/Lib_Generic")

function VoidWanderersPrestige(pieActor, pieMenu, pieSlice)
	if (IsAHuman(pieActor) or IsACrab(pieActor)) and (pieActor:GetController():IsMouseControlled() or pieActor:GetController():IsKeyboardOnlyControlled()) then
		pieActor = pieActor
		pieActor:RemoveWounds(pieActor.WoundCount)
		pieActor.Health = pieActor.MaxHealth

		CF.UnBuffActor(pieActor, pieActor:GetNumberValue("VW_Rank"), pieActor:GetNumberValue("VW_Prestige"))
		pieActor:RemoveNumberValue("VW_XP")
		pieActor:RemoveNumberValue("VW_Rank")
		pieActor:SetNumberValue("VW_Prestige", pieActor:GetNumberValue("VW_Prestige") + 1)
		pieActor:SetStringValue("VW_Name", "")
		CF.SetNamingActor(pieActor, pieActor:GetController().Player)

		pieMenu:RemovePieSlice(pieSlice)
	end
end
