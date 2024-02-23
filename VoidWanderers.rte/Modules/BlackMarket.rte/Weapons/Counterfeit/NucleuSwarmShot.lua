function Create(self)
	self.speed = 9 + math.random()
	self.adjustmentAmount = math.random(35, 70)
	self.targetingAdjustmentAmount = self.adjustmentAmount

	self.seekerDelay = math.random(250, 2500)
end

function Update(self)
	if self.tPos then
		self.tPos = self.tPos + Vector(math.random(-5, 5), math.random(-5, 5))
	end
end
