function PDACall(pieMenuOwner, pieMenu, pieSlice)
	-- Activate PDA
	if IsAHuman(pieMenuOwner) and ToAHuman(pieMenuOwner).Head then
		ToAHuman(pieMenuOwner).Head:SetNumberValue("enablePDA", 1);
	end
end
