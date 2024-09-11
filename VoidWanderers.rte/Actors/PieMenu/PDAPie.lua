function PDACall(pieMenuOwner, pieMenu, pieSlice)
	-- Activate PDA
	if IsAHuman(pieMenuOwner) then
		ToAHuman(pieMenuOwner):SetNumberValue("EnablePDA", 1)
	end
end
