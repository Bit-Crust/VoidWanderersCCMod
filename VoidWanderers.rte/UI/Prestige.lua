local tempvar = nil

function CF_Read(self, keys) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("read_from_CF", {self, keys})
	return tempvar
end

function CF_Write(keys, value) 
	ActivityMan:GetActivity():SendMessage("write_to_CF", {keys, value})
end

function CF_Call(self, keys, arguments) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("call_in_CF", {self, keys, arguments})
	return tempvar
end

function OnMessage(self, message, context)
	if message == "return_from_activity" then
		tempvar = context
	end
end

function VoidWanderersPrestige(pieActor, pieMenu, pieSlice)
	if (IsAHuman(pieActor) or IsACrab(pieActor)) and (pieActor:GetController():IsMouseControlled() or pieActor:GetController():IsKeyboardOnlyControlled()) then
		pieActor = pieActor
		pieActor:RemoveWounds(pieActor.WoundCount)
		pieActor.Health = pieActor.MaxHealth

		CF_Call(nil, {"UnBuffActor"}, {pieActor, pieActor:GetNumberValue("VW_Rank"), pieActor:GetNumberValue("VW_Prestige")})
		pieActor:RemoveNumberValue("VW_XP")
		pieActor:RemoveNumberValue("VW_Rank")
		pieActor:SetNumberValue("VW_Prestige", pieActor:GetNumberValue("VW_Prestige") + 1)
		pieActor:SetStringValue("VW_Name", "")
		CF_Call(nil, {"SetNamingActor"}, {pieActor, pieActor:GetController().Player})

		pieMenu:RemovePieSlice(pieSlice)
	end
end
