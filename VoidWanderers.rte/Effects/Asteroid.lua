function Create(self)
	self.impulseThreshold = 10000 + self.Mass;
	self.screenShakeRatio = 1 / self.Mass;
	self.crashSoundLight = CreateSoundContainer("Asteroid Hit Light", "VoidWanderers.rte");
	self.crashSoundHeavy = CreateSoundContainer("Asteroid Hit Heavy", "VoidWanderers.rte");
end

function Update(self)
	if self.TravelImpulse.Magnitude > self.impulseThreshold then
		self.impulseThreshold = self.impulseThreshold + 1000;
		local scrollTargets = {};

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if ActivityMan:GetActivity():PlayerHuman(player) then
				local screen = ActivityMan:GetActivity():ScreenOfPlayer(player);
				CameraMan:SetScrollTarget(CameraMan:GetScrollTarget(screen) - self.TravelImpulse * self.screenShakeRatio, 0.5, screen);
			end
		end

		if self.TravelImpulse.Magnitude > self.impulseThreshold * 1.5 then
			self.crashSoundHeavy:Play(self.Pos);
		else
			self.crashSoundLight:Play(self.Pos);
		end
	end
end