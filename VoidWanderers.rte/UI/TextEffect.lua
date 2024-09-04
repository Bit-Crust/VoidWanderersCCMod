function Create(self)
	self.speed = 0
	if self:GetNumberValue("XPGained") ~= 0 then
		--Sharpness means XP
		self:SetStringValue("Text", (self:GetNumberValue("XPGained") < 0 and "" or "+") .. self:GetNumberValue("XPGained") .. " xp")
		if self:GetNumberValue("IsLevelUp") > 1 then
			self:SetStringValue("Text", self:GetStringValue("Text") .. "\n" .. "LEVEL UP!")
		end
		self.speed = 1 / math.sqrt(math.abs(self:GetNumberValue("XPGained") + self:GetNumberValue("IsLevelUp")))
		self.Lifetime = self.Lifetime * math.sqrt(self:GetNumberValue("IsLevelUp")) + self.Lifetime / self.speed
	else
		self.Lifetime = self.Lifetime * math.sqrt(FrameMan:CalculateTextWidth(self:GetStringValue("Text"), false))
	end
end

function Update(self)
	PrimitiveMan:DrawTextPrimitive(-1, self.Pos + Vector(0, -8), self:GetStringValue("Text"), false, 1)
	self.Pos = self.Pos + Vector(0, -self.speed)
end
