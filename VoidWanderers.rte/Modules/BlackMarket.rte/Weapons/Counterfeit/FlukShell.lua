function Create(self)
	self.delayTime = self.delayTime * RangeRand(0.75, 1.25)

	local rand = RangeRand(0.33, 1.0)
	self.pointCount = math.floor(self.pointCount * rand)
	self.spiralScale = math.floor(self.spiralScale / rand)
	self.GibImpulseLimit = self.GibImpulseLimit + math.random(-25, 50)
end
