function Create(self)
	self.simFrame = 0

	self.Timer = Timer()
	self.Timer:Reset()
end

function Update(self)
	local open = false

	for actor in MovableMan.Actors do
		if
			(actor.Pos.X >= self.Pos.X - 18)
			and (actor.Pos.X <= self.Pos.X + 18)
			and (actor.Pos.Y >= self.Pos.Y - 18)
			and (actor.Pos.Y <= self.Pos.Y + 48)
		then
			open = true
			break
		end
	end

	if self.Timer:IsPastSimMS(500) then
		if open then
			if self.simFrame < 2 then
				self.simFrame = self.simFrame + 1
			end
		else
			if self.simFrame > 0 then
				self.simFrame = self.simFrame - 1
			end
		end

		self.Timer:Reset()
	end
	self.Frame = self.simFrame
end
