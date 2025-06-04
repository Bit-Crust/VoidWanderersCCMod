function Create(self)
	self.range = math.sqrt(FrameMan.PlayerScreenWidth ^ 2 + FrameMan.PlayerScreenHeight ^ 2) / 2
	self.penetrationStrength = 400
	self.strengthVariation = 5
	self.shotCounter = 0
	self.activity = ActivityMan:GetActivity()

	function self.emitSmoke(particleCount)
		for i = 1, particleCount do
			local smoke = CreateMOSParticle("Tiny Smoke Ball 1" .. (math.random() < 0.5 and " Glow Red" or ""))
			smoke.Pos = self.MuzzlePos
			smoke.Lifetime = smoke.Lifetime * RangeRand(0.5, 1.0)
			smoke.Vel = self.Vel * 0.5 + Vector(RangeRand(0, i), 0):RadRotate(RangeRand(-math.pi, math.pi))
			MovableMan:AddParticle(smoke)
		end
	end
end

function Update(self)
	if self.FiredFrame then
		local actor = self:GetRootParent()
		local range = self.range + math.random(8)
		if IsActor(actor) then
			actor = ToActor(actor)
			range = range + actor.AimDistance
			if actor:GetController():IsState(Controller.AIM_SHARP) then
				range = range + self.SharpLength * actor.SharpAimProgress
			end
		end

		local startPos = self.MuzzlePos + Vector(0, RangeRand(-0.5, 0.5)):RadRotate(self.RotAngle)
		local skipPx = 4
		local ignoreID = actor.ID
		local penetrationStrength = self.penetrationStrength
		local yes = true
		while yes do
			yes = false
			local hitPos = Vector(startPos.X, startPos.Y)
			local gapPos = Vector(startPos.X, startPos.Y)
			local trace = Vector(range * self.FlipFactor, 0):RadRotate(self.RotAngle)
			local rayLength = SceneMan:CastObstacleRay(
				startPos,
				trace,
				hitPos,
				gapPos,
				ignoreID,
				self.Team,
				rte.airID,
				skipPx
			)
			if rayLength >= 0 then
				gapPos = gapPos - Vector(trace.X, trace.Y):SetMagnitude(skipPx)
				skipPx = 1
				local shortRay = SceneMan:CastObstacleRay(
					gapPos,
					Vector(trace.X, trace.Y):SetMagnitude(range - rayLength + skipPx),
					hitPos,
					gapPos,
					ignoreID,
					self.Team,
					rte.airID,
					skipPx
				)
				gapPos = gapPos - Vector(trace.X, trace.Y):SetMagnitude(skipPx)
				local strengthFactor = math.max(1 - rayLength / self.range, math.random())
					* (self.shotCounter + 1)
					/ self.strengthVariation

				local moID = SceneMan:GetMOIDPixel(hitPos.X, hitPos.Y)
				if moID ~= rte.NoMOID and moID ~= self.ID then
					local mo = ToMOSRotating(MovableMan:GetMOFromID(moID))
					local penet = (penetrationStrength * strengthFactor) / mo.Material.StructuralIntegrity
					if penet >= 1 then
						local moAngle = -mo.RotAngle * mo.FlipFactor

						local dist = SceneMan:ShortestDistance(mo.Pos, hitPos, true)
						local woundName = mo:GetEntryWoundPresetName()
						if woundName ~= "" then
							local wound = CreateAEmitter(woundName)

							local woundOffset = Vector(dist.X * mo.FlipFactor, dist.Y)
								:RadRotate(moAngle)
								:SetMagnitude(dist.Magnitude - (wound.Radius - 1) * wound.Scale)
							wound.InheritedRotAngleOffset = woundOffset.AbsRadAngle
							mo:AddWound(wound, woundOffset:RadRotate(-mo.RotAngle), true)
						end
						if penet > 2.5 then
							yes = true
							ignoreID = mo:GetRootParent().ID

							local woundName = mo:GetExitWoundPresetName()
							if woundName ~= "" and not mo.ToDelete then
								local wound = CreateAEmitter(woundName)
								local lastPos = Vector(hitPos.X, hitPos.Y)
								for i = 1, mo.Radius do
									local checkPos = hitPos + Vector(trace.X, trace.Y):SetMagnitude(i)
									if SceneMan:GetMOIDPixel(checkPos.X, checkPos.Y) ~= mo.ID then
										break
									end
									lastPos = checkPos
								end
								dist = SceneMan:ShortestDistance(mo.Pos, lastPos, true)
								local woundOffset = Vector(dist.X * mo.FlipFactor, dist.Y)
									:RadRotate(moAngle)
									:SetMagnitude(dist.Magnitude - (wound.Radius - 1) * wound.Scale)
								wound.InheritedRotAngleOffset = woundOffset.AbsRadAngle - math.pi
								mo:AddWound(wound, woundOffset:RadRotate(-mo.RotAngle), true)
							end
						end
					end
				end
				local smoke = CreateMOSParticle("Tiny Smoke Ball 1" .. (math.random() < 0.5 and " Glow Red" or ""))
				smoke.Pos = gapPos
				smoke.Vel = Vector(-trace.X, -trace.Y):SetMagnitude(math.random(3, 6)):RadRotate(RangeRand(-1.5, 1.5))
				smoke.Lifetime = smoke.Lifetime * strengthFactor
				MovableMan:AddParticle(smoke)

				local pix = CreateMOPixel(self.PresetName .. " Glow " .. math.floor(strengthFactor * 4 + 0.5))
				pix.Pos = gapPos
				pix.Sharpness = penetrationStrength / 6
				pix.Vel = Vector(trace.X, trace.Y):SetMagnitude(6)
				MovableMan:AddParticle(pix)
			end
			trace = SceneMan:ShortestDistance(startPos, gapPos, true)
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				local team = self.activity:GetTeamOfPlayer(player)
				local screen = self.activity:ScreenOfPlayer(player)
				if
					screen ~= -1
					and not (
						SceneMan:IsUnseen(startPos.X, startPos.Y, team) or SceneMan:IsUnseen(hitPos.X, hitPos.Y, team)
					)
				then
					PrimitiveMan:DrawLinePrimitive(screen, startPos, startPos + trace, 254)
				end
			end
			local particleCount = trace.Magnitude * RangeRand(0.4, 0.8)
			for i = 0, particleCount do
				local pix = CreateMOPixel(self.PresetName .. " Glow 0")
				pix.Pos = startPos + trace * (i / particleCount)
				pix.Vel = self.Vel
				MovableMan:AddParticle(pix)
			end
			startPos = hitPos
			range = range - rayLength
			skipPx = 4
			penetrationStrength = penetrationStrength * 0.5
		end
		self.shotCounter = (self.shotCounter + 1) % self.strengthVariation
	end
	if self.Magazine and self.Magazine.RoundCount > 0 then
		self.FireSound.Pitch = (1.0 - (1 - self.Magazine.RoundCount / self.Magazine.Capacity) * 0.1) ^ 2
	elseif self.RoundInMagCount >= 0 then
		self:Reload()
	end
end
