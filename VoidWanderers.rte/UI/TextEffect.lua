function Create(self)
	
end

function OnSave(self)
	self:SetStringValue("Text", self:GetStringValue("VW_Text"):gsub("([^\\]?)\n", "%1\\n") .. "");
end

function Update(self)
	PrimitiveMan:DrawTextPrimitive(-1, self.Pos, self:GetStringValue("VW_Text"):gsub("\\n", "\n") .. "", false, 1);
end
