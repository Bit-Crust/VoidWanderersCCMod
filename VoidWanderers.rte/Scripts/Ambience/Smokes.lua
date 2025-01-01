function VoidWanderers:AmbientCreate()
	local vesselInterior = SceneMan.Scene:GetArea("Vessel Interior") or SceneMan.Scene:GetArea("Vessel");
	self.ambientData["vesselInterior"] = vesselInterior;

	self.ambientData["smokeNextEmission"] = self.Time + math.random(3);
	self.ambientData["smokeEmitters"] = {};
	self.ambientData["smokeEmitterCount"] = 4;

	for i = 1, 10 do
		skullPos = vesselInterior:GetRandomPoint();
		skullPos = SceneMan:MovePointToGround(skullPos, 0, 1) + Vector(0, -6);
		if skullPos.Y <= SceneMan.SceneHeight * 0.9 then
			local skull = CreateAttachable("Skeleton Head", "Uzira.rte");
			skull.Pos = skullPos;
			skull.HFlipped = math.random() > 0.5;
			skull.RotAngle = math.random() * 2 * math.pi;
			skull.PinStrength = 10;
			skull.HitsMOs = false;
			skull.RestThreshold = -1;
			MovableMan:AddMO(skull);
		end
	end

	local normalish = function(x)
		return math.exp(-math.pow(x / 14, 2));
	end;

	local derivish = function(x)
		return math.exp(-math.pow(x / 14, 2)) * -x / 7;
	end;

	for i = 1, 3 do
		local setupPos = SceneMan:MovePointToGround(vesselInterior:GetRandomPoint(), 0, 1);
		local scale1, scale2 = 2 + math.random(), 2 + math.random();
		local mode1, mode2 = 20 * math.random(), 20 * math.random();

		local skullsToAddLeft = {};
		local skullsToAddRight = {};
		local thresholdY = -22;

		for x = -32, 32, 8 do
			local value = scale1 * normalish(x - mode1) + scale2 * normalish(x - mode2);
			local flip = scale1 * derivish(x - mode1) > -scale2 * derivish(x - mode2);

			if math.floor(value) * 5 > -thresholdY then
				local skull = CreateAttachable("Skeleton Head", "Uzira.rte");
				skull.PinStrength = 10;
				skull.HitsMOs = false;
				skull.RestThreshold = -1;
				skull.HFlipped = flip;
				skull.RotAngle = math.random() * 0.1 * math.pi * (flip and -1 or 1);
				skull.Pos = SceneMan:MovePointToGround(setupPos + Vector(x, 0), 0, 1) + Vector(0, thresholdY) + Vector(math.random(-2, 2), math.random(0, 2));
				
				if flip then
					table.insert(skullsToAddLeft, skull);
				else
					table.insert(skullsToAddRight, skull);
				end
			end
		end

		local n = #skullsToAddLeft;

		for i = 1, n do
			MovableMan:AddMO(skullsToAddLeft[i]);
		end

		n = #skullsToAddRight;
		
		for i = 1, n do
			MovableMan:AddMO(skullsToAddRight[n + 1 - i]);
		end
		
		skullsToAddLeft = {};
		skullsToAddRight = {};
		thresholdY = -14;

		for x = -36, 36, 8 do
			local value = scale1 * normalish(x - mode1) + scale2 * normalish(x - mode2);
			local flip = scale1 * derivish(x - mode1) > -scale2 * derivish(x - mode2);

			if math.floor(value) * 5 > -thresholdY then
				local skull = CreateAttachable("Skeleton Head", "Uzira.rte");
				skull.PinStrength = 10;
				skull.HitsMOs = false;
				skull.RestThreshold = -1;
				skull.HFlipped = flip;
				skull.RotAngle = math.random() * 0.1 * math.pi * (flip and -1 or 1);
				skull.Pos = SceneMan:MovePointToGround(setupPos + Vector(x, 0), 0, 1) + Vector(0, thresholdY) + Vector(math.random(-2, 2), math.random(0, 2));
				
				if flip then
					table.insert(skullsToAddLeft, skull);
				else
					table.insert(skullsToAddRight, skull);
				end
			end
		end

		local n = #skullsToAddLeft;

		for i = 1, n do
			MovableMan:AddMO(skullsToAddLeft[i]);
		end

		n = #skullsToAddRight;
		
		for i = 1, n do
			MovableMan:AddMO(skullsToAddRight[n + 1 - i]);
		end
		
		skullsToAddLeft = {};
		skullsToAddRight = {};
		thresholdY = -6;

		for x = -40, 40, 8 do
			local value = scale1 * normalish(x - mode1) + scale2 * normalish(x - mode2);
			local flip = scale1 * derivish(x - mode1) > -scale2 * derivish(x - mode2);

			if math.floor(value) * 5 > -thresholdY then
				local skull = CreateAttachable("Skeleton Head", "Uzira.rte");
				skull.PinStrength = 10;
				skull.HitsMOs = false;
				skull.RestThreshold = -1;
				skull.HFlipped = flip;
				skull.RotAngle = math.random() * 0.1 * math.pi * (flip and -1 or 1);
				skull.Pos = SceneMan:MovePointToGround(setupPos + Vector(x, 0), 0, 1) + Vector(0, thresholdY) + Vector(math.random(-2, 2), math.random(0, 2));
				
				if flip then
					table.insert(skullsToAddLeft, skull);
				else
					table.insert(skullsToAddRight, skull);
				end
			end
		end

		local n = #skullsToAddLeft;

		for i = 1, n do
			MovableMan:AddMO(skullsToAddLeft[i]);
		end

		n = #skullsToAddRight;
		
		for i = 1, n do
			MovableMan:AddMO(skullsToAddRight[n + 1 - i]);
		end
	end

	for i = 1, 6 do
		local setupPos = vesselInterior:GetRandomPoint();
		local toFlip = i % 2 == 0;
		local toFlipFactor = toFlip and -1 or 1;
		setupPos = SceneMan:MovePointToGround(setupPos, 0, 1) + Vector(0, -2);
		local footPos = SceneMan:MovePointToGround(setupPos + Vector(-6 * toFlipFactor, -20), 0, 1) - setupPos;
		local headPos = SceneMan:MovePointToGround(setupPos + Vector(6 * toFlipFactor, -20), 0, 1) - setupPos;
		local angularOffset = (headPos.AbsRadAngle - footPos.AbsRadAngle);

		local skeleton = CreateAHuman("Skeleton", "Uzira.rte");
		skeleton.HFlipped = toFlip;
		skeleton.Status = Actor.DEAD;
		skeleton.Health = -100;
		skeleton.RotAngle = (angularOffset + 1 / 2 * math.pi) * toFlipFactor;
		skeleton.Pos = setupPos;
		skeleton.HitsMOs = false;
		skeleton.RestThreshold = -1;
		if skeleton.Pos.Y <= SceneMan.SceneHeight * 0.9 then
			MovableMan:AddMO(skeleton);
		end
	end

	for i = 1, self.ambientData["smokeEmitterCount"] do
		self.ambientData["smokeEmitters"][i] = CreateAEmitter("White Smoke Burst", self.ModuleName)
		local newPos = self.ambientData["vesselInterior"]:GetRandomPoint();
		SceneMan:CastNotMaterialRay(newPos, Vector(0, -1000), rte.airID, newPos, 0, false);
		self.ambientData["smokeEmitters"][i].Pos = newPos + Vector(0, 1);
		self.ambientData["smokeEmitters"][i].RotAngle = math.rad(270)
		self.ambientData["smokeEmitters"][i]:EnableEmission(true)
		MovableMan:AddParticle(self.ambientData["smokeEmitters"][i])
	end

	-- Explosions
	self.ambientData["explosionInterval"] = 5
	self.ambientData["explosionVariance"] = 3
	self.ambientData["explosionSafeDistance"] = 250
	self.ambientData["explosionNext"] = self.Time + self.ambientData["explosionInterval"] + math.random(-self.ambientData["explosionVariance"], self.ambientData["explosionVariance"])
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:AmbientUpdate()
	if self.Time >= self.ambientData["smokeNextEmission"] then
		self.ambientData["smokeNextEmission"] = self.Time + math.random(2)

		for i = 1, self.ambientData["smokeEmitterCount"] do
			if MovableMan:IsParticle(self.ambientData["smokeEmitters"][i]) then
				local newPos = self.ambientData["vesselInterior"]:GetRandomPoint();
				SceneMan:CastNotMaterialRay(newPos, Vector(0, -1000), rte.airID, newPos, 0, false);
				self.ambientData["smokeEmitters"][i].Pos = newPos + Vector(0, 1);
			end
		end
	end

	-- Put explosion
	if self.Time >= self.ambientData["explosionNext"] then
		local pos = self.ambientData["vesselInterior"]:GetRandomPoint();
		local ok = true;

		for actor in MovableMan.Actors do
			if actor.Team == CF.PlayerTeam then
				if CF.Dist(pos, actor.Pos) < self.ambientData["explosionSafeDistance"] then
					ok = false;
					break;
				end
			end
		end

		for particle in MovableMan.Particles do
			if IsActor(particle) and particle.Team == CF.PlayerTeam then
				if CF.Dist(pos, particle.Pos) < self.ambientData["explosionSafeDistance"] then
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
			self.ambientData["explosionNext"] = self.Time + self.ambientData["explosionInterval"] + math.random(-self.ambientData["explosionVariance"], self.ambientData["explosionVariance"])
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
