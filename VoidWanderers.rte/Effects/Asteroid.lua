function Create(self)
	self.impulseThreshold = 10000 + self.Mass
	self.screenShakeRatio = 1 / self.Mass
	self.crashSoundLight = CreateSoundContainer("Asteroid Hit Light", "VoidWanderers.rte")
	self.crashSoundHeavy = CreateSoundContainer("Asteroid Hit Heavy", "VoidWanderers.rte")
end
function Update(self)
	if self.TravelImpulse:MagnitudeIsGreaterThan(self.impulseThreshold) then
		self.impulseThreshold = self.impulseThreshold + 1000
		local scrollTargets = {}

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if ActivityMan:GetActivity():PlayerHuman(player) then
				local screen = ActivityMan:GetActivity():ScreenOfPlayer(player)
				CameraMan:SetScrollTarget(
					CameraMan:GetScrollTarget(screen) - self.TravelImpulse * self.screenShakeRatio,
					0.5,
					false,
					screen
				)
			end
		end
		local size = math.sqrt(self.Mass)
		local sound = self.TravelImpulse:MagnitudeIsGreaterThan(self.impulseThreshold * 1.5) and self.crashSoundHeavy
			or self.crashSoundLight
		sound:Play(self.Pos)
	end
end
