function Create(self)
	self.laserLength = self.laserLength * 0.75

	self.markerRotAngle = 0
	self.markerTurnSpeed = 0

	self.lockThreshold = 13

	self.missile = CreateAEmitter("Particle Coalition Missilo Launcher", "VoidWanderers.rte")
end
