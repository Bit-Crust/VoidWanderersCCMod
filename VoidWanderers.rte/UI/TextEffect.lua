function Create(self)
	self.speed = 0
	if self.Sharpness ~= 0 then
		--Sharpness means XP
		self.PresetName = (self.Sharpness < 0 and "" or "+") .. self.Sharpness .. " xp"
		if self.Mass > 1 then
			self.PresetName = self.PresetName .. "\n" .. "LEVEL UP!"
		end
		self.speed = 1 / math.sqrt(math.abs(self.Sharpness + self.Mass))
		self.Lifetime = self.Lifetime * math.sqrt(self.Mass) + self.Lifetime / self.speed
	else
		self.Lifetime = self.Lifetime * math.sqrt(FrameMan:CalculateTextWidth(self.PresetName, false))
	end
	self.Sharpness = 0
end
function Update(self)
	PrimitiveMan:DrawTextPrimitive(-1, self.Pos + Vector(0, -8), self.PresetName, false, 1)
	self.Pos = self.Pos + Vector(0, -self.speed)
end
