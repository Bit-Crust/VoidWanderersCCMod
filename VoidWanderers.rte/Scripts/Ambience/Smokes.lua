function VoidWanderers:AmbientCreate()
	self.ambientData["smokeBrokenChambers"] = SceneMan.Scene:GetArea("Vessel Interior") or SceneMan.Scene:GetArea("Vessel")
	self.ambientData["smokeNextEmission"] = self.Time + math.random(3)
	self.ambientData["smokeEmitters"] = {}
	self.ambientData["smokeEmitterCount"] = 4
	
	local skeletonSpawn = SceneMan.Scene:GetArea("Vessel Assault Spawn") or SceneMan.Scene:GetArea("Vessel Interior") or SceneMan.Scene:GetArea("Vessel")

	for i = 1, 10 do
		local head = CreateAttachable("Skeleton Head", "Uzira.rte");
		head.Pos = skeletonSpawn:GetRandomPoint();
		head.HFlipped = math.random() > 0.5;
		head.RotAngle = math.random() * 2 * math.pi;
		head.Pos = SceneMan:MovePointToGround(head.Pos, 0, 1) + Vector(0, -6);
		head.HitsMOs = false;
		head.RestThreshold = -1;
		if head.Pos.Y <= SceneMan.SceneHeight * 0.9 then
			MovableMan:AddMO(head);
		end
	end

	for i = 1, 3 do
		local setupPos = skeletonSpawn:GetRandomPoint();
		setupPos = SceneMan:MovePointToGround(setupPos, 0, 1) + Vector(0, -20);

		for i = 1, 10 do
			local head = CreateAttachable("Skeleton Head", "Uzira.rte");
			local toFlip = i % 2 == 0;
			local offset = Vector(20 * math.random() * math.sqrt(i / 10) * (toFlip and -1 or 1), i * 1.6);
			head.HFlipped = toFlip;
			head.RotAngle = math.random() * 0.1 * math.pi * (toFlip and -1 or 1);
			head.Pos = setupPos + offset;
			head.PinStrength = 1;
			head.HitsMOs = false;
			head.RestThreshold = -1;
			if head.Pos.Y <= SceneMan.SceneHeight * 0.9 then
				MovableMan:AddMO(head);
			end
		end
	end

	for i = 1, 3 do
		local setupPos = skeletonSpawn:GetRandomPoint();
		setupPos = SceneMan:MovePointToGround(setupPos, 0, 1) + Vector(0, -20);

		for i = 1, 10 do
			local head = CreateAttachable("Skeleton Head", "Uzira.rte");
			local toFlip = i % 2 == 0;
			local offset = Vector(20 * math.random() * math.sqrt(i / 10) * (toFlip and -1 or 1), i * 1.6);
			head.HFlipped = toFlip;
			head.RotAngle = math.random() * 0.1 * math.pi * (toFlip and -1 or 1);
			head.Pos = setupPos + offset;
			head.PinStrength = 1;
			head.HitsMOs = false;
			head.RestThreshold = -1;
			if head.Pos.Y <= SceneMan.SceneHeight * 0.9 then
				MovableMan:AddMO(head);
			end
		end
	end

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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
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
		local pos = self.vesselData["ship"]:GetRandomPoint();
		local ok = true;

		for actor in MovableMan.Actors do
			if actor.Team == CF.PlayerTeam then
				if CF.DistUnder(pos, actor.Pos, self.ambientData["safeExplosionDistance"]) then
					ok = false;
					break;
				end
			end
		end

		for particle in MovableMan.Particles do
			if IsActor(particle) and particle.Team == CF.PlayerTeam then
				if CF.DistUnder(pos, particle.Pos, self.ambientData["safeExplosionDistance"]) then
					ok = false;
					break;
				end
			end
		end

		if ok then
			local r = math.random();
			local preset = "";

			if r <= 2/6 then
				preset = "Explosion";
			elseif r <= 3/6 then
				preset = "Big Explosion";
			elseif r <= 4/6 then
				preset = "Bridge Explosion";
			elseif r <= 5/6 then
				preset = "Digger Explosion";
			elseif r <= 6/6 then 
				preset = "Fire Explosion";
			end

			-- When all evacuated - destroy the ship with terrain eating explosions
			local explosion = CreateMOSRotating(preset, "VoidWanderers.rte");
			explosion.Pos = pos;
			MovableMan:AddParticle(explosion);
			explosion:GibThis();
			self.ambientData["explosionTimer"]:Reset();
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:AmbientDestroy()
	-- Destroy smoke emitters
	for i = 1, self.ambientData["smokeEmitterCount"] do
		if MovableMan:IsParticle(self.ambientData["smokeEmitters"][i]) then
			self.ambientData["smokeEmitters"][i].ToDelete = true
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
