function Create(self)
	self.turnStrength = 5
	self.lifeTimer = Timer()
	self.targetSound = CreateSoundContainer("Explosive Device Detonate", "Base.rte")

	self.lifeTimer:SetSimTimeLimitMS(self.Lifetime - math.ceil(TimerMan.DeltaTimeMS))
end
function Update(self)
	self.GlobalAccScalar = 1 / math.sqrt(1 + math.abs(self.Vel.X) * 0.1)
	if self.target and self.target.ID ~= rte.NoMOID then
		local targetDist = SceneMan:ShortestDistance(self.Pos, self.target.Pos, SceneMan.SceneWrapsX)
		if targetDist:MagnitudeIsLessThan(self.Radius) then
			--self:GibThis()
		else
			local targetVel = targetDist:SetMagnitude(self.turnStrength)

			local turnAngle = self.Vel.AbsRadAngle - targetVel.AbsRadAngle
			turnAngle = turnAngle > math.pi and turnAngle - (math.pi * 2)
				or (turnAngle < -math.pi and turnAngle + (math.pi * 2) or turnAngle)

			self.Vel = (self.Vel + targetVel):SetMagnitude(self.Vel.Magnitude)
			self.AngularVel = self.AngularVel * 0.5 - (turnAngle * self.turnStrength)
		end
	else
		local moRay = SceneMan:CastMORay(
			self.Pos,
			Vector(250 * self.FlipFactor, 0):RadRotate(self.RotAngle + RangeRand(-0.2, 0.2)),
			self.ID,
			self.Team,
			rte.airID,
			false,
			5
		)
		if moRay ~= rte.NoMOID then
			local mo = ToMOSRotating(MovableMan:GetMOFromID(moRay))
			if mo then
				local rootMO = mo:GetRootParent()
				if rootMO and (rootMO.Radius * rootMO.Mass) > 10000 then
					self.target = mo
					self.targetSound:Play(self.Pos)
				end
			end
		end
	end
	if self.lifeTimer:IsPastSimTimeLimit() then
		self:GibThis()
	end
end
function OnCollideWithMO(self, mo, rootMO)
	if rootMO and rootMO.ClassName == "ADoor" and IsMOSRotating(mo) and mo.ToDelete == false then
		ToMOSRotating(mo).Vel = Vector(self.PrevVel.X, self.PrevVel.Y) / math.sqrt(math.max(mo.Mass - self.Mass, 1))
		ToMOSRotating(mo):GibThis()
	end
end
