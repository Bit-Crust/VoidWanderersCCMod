function VoidWanderers:AmbientCreate()
	self.AmbientSmokesBrokenChambers = SceneMan.Scene:GetArea("Vessel")
	self.AmbientSmokesNextEmission = self.Time + math.random(3)
	self.AmbientSmokesEmitters = {}
	self.AmbientSmokesEmitterCount = 4
	for i = 1, self.AmbientSmokesEmitterCount do
		self.AmbientSmokesEmitters[i] = CreateAEmitter("White Smoke Burst", self.ModuleName)
		self.AmbientSmokesEmitters[i].Pos = self.AmbientSmokesBrokenChambers:GetRandomPoint()
		self.AmbientSmokesEmitters[i].RotAngle = math.rad(270)
		self.AmbientSmokesEmitters[i]:EnableEmission(true)
		MovableMan:AddParticle(self.AmbientSmokesEmitters[i])
	end

	self.AmbientSmokesNextHealthDamage = self.Time
	self.Ship = SceneMan.Scene:GetArea("Vessel")

	-- Explosions
	self.ExplosionTimer = Timer()
	self.ExplosionTimer:Reset()
	self.ExplosionInterval = 2500
	self.SafeExplosionDistance = 250

	self.LastExplosionPos = self.Ship:GetRandomPoint()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AmbientUpdate()
	if self.Time >= self.AmbientSmokesNextEmission then
		self.AmbientSmokesNextEmission = self.Time + math.random(2)

		for i = 1, self.AmbientSmokesEmitterCount do
			if MovableMan:IsParticle(self.AmbientSmokesEmitters[i]) then
				self.AmbientSmokesEmitters[i].Pos = self.AmbientSmokesBrokenChambers:GetRandomPoint()
			end
		end
	end

	-- Put explosion
	if self.ExplosionTimer:IsPastSimMS(self.ExplosionInterval) then
		local pos
		local ok = true

		-- Select safe position for our explosion to avoid hitting any of our heroes
		pos = self.Ship:GetRandomPoint()

		for actor in MovableMan.Actors do
			if actor.Team == CF_PlayerTeam then
				if CF_DistUnder(pos, actor.Pos, self.SafeExplosionDistance) then
					ok = false
					break
				end
			end
		end

		if ok then
			local preset = "Explosion " .. math.random(10)

			-- When all evacuated - destroy the ship with terrain eating explosions
			local Charge = CreateMOSRotating(preset, self.ModuleName)
			Charge.Pos = pos
			MovableMan:AddParticle(Charge)
			Charge:GibThis()
			self.ExplosionTimer:Reset()
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AmbientDestroy()
	-- Destroy smoke emitters
	for i = 1, self.AmbientSmokesEmitterCount do
		if MovableMan:IsParticle(self.AmbientSmokesEmitters[i]) then
			self.AmbientSmokesEmitters[i].ToDelete = true
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
