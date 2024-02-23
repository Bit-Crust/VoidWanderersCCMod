function Create(self)
	if self.target then
		local targets = { self.target }
		for mo in MovableMan:GetMOsInRadius(self.target.Pos, 10 + self.target.Radius * 1.5, self.target.Team, true) do
			if IsMOSRotating(mo) then
				table.insert(targets, ToMOSRotating(mo))
			end
		end
		self.target = targets[math.random(#targets)]
	end
end

function Update(self)
	self.AngularVel = self.AngularVel + RangeRand(-0.25, 0.25) * math.sqrt(self.Vel.Magnitude)
end
