function Update(self)
	if self.FiredFrame and math.random() < 0.5 then
		self.RateOfFire = math.max(self.RateOfFire * (self.decreasePerFrame / self.increasePerShot), self.minRateOfFire)
	end
end
