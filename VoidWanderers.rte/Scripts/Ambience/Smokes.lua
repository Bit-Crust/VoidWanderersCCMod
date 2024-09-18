function VoidWanderers:AmbientCreate()
	self.ambientData["smokeBrokenChambers"] = SceneMan.Scene:GetArea("Vessel")
	self.ambientData["smokeNextEmission"] = self.Time + math.random(3)
	self.ambientData["smokeEmitters"] = {}
	self.ambientData["smokeEmitterCount"] = 4

	for i = 1, self.ambientData["smokeEmitterCount"] do
		self.ambientData["smokeEmitters"][i] = CreateAEmitter("White Smoke Burst", self.ModuleName)
		self.ambientData["smokeEmitters"][i].Pos = self.ambientData["smokeBrokenChambers"]:GetRandomPoint()
		self.ambientData["smokeEmitters"][i].RotAngle = math.rad(270)
		self.ambientData["smokeEmitters"][i]:EnableEmission(true)
		MovableMan:AddParticle(self.ambientData["smokeEmitters"][i])
	end

	-- Explosions
	self.ambientData["explosionTimer"] = Timer()
	self.ambientData["explosionTimer"]:Reset()
	self.ambientData["explosionInterval"] = 2500
	self.ambientData["safeExplosionDistance"] = 250
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AmbientUpdate()
	if self.Time >= self.ambientData["smokeNextEmission"] then
		self.ambientData["smokeNextEmission"] = self.Time + math.random(2)

		for i = 1, self.ambientData["smokeEmitterCount"] do
			if MovableMan:IsParticle(self.ambientData["smokeEmitters"][i]) then
				self.ambientData["smokeEmitters"][i].Pos = self.ambientData["smokeBrokenChambers"]:GetRandomPoint()
			end
		end
	end

	-- Put explosion
	if self.ambientData["explosionTimer"]:IsPastSimMS(self.ambientData["explosionInterval"]) then
		local pos
		local ok = true

		-- Select safe position for our explosion to avoid hitting any of our heroes
		pos = self.vesselData["ship"]:GetRandomPoint()

		for actor in MovableMan.Actors do
			if actor.Team == CF.PlayerTeam then
				if CF.DistUnder(pos, actor.Pos, self.ambientData["safeExplosionDistance"]) then
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
			self.ambientData["explosionTimer"]:Reset()
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AmbientDestroy()
	-- Destroy smoke emitters
	for i = 1, self.ambientData["smokeEmitterCount"] do
		if MovableMan:IsParticle(self.ambientData["smokeEmitters"][i]) then
			self.ambientData["smokeEmitters"][i].ToDelete = true
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
