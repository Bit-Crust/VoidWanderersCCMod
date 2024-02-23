function Create(self)
	if self.PinStrength > 0 then
		self.Status = Actor.INACTIVE
	end
	self.searchRange = 150
	self.jumpTimer = Timer()
	self.jumpTimer:SetSimTimeLimitMS(250)
end
function Update(self)
	self.AIMode = Actor.AIMODE_SENTRY
	local controller = self:GetController()
	if self.Status < Actor.INACTIVE then
		self.PinStrength = 0
		local legCount = 0
		if self.FGFoot then
			if SceneMan:GetTerrMatter(self.FGFoot.Pos.X, self.FGFoot.Pos.Y + 5) ~= rte.airID then
				legCount = legCount * 0.3 + 1
			end
			self.FGLeg.Scale = 1
		end
		if self.BGFoot then
			if SceneMan:GetTerrMatter(self.BGFoot.Pos.X, self.BGFoot.Pos.Y + 5) ~= rte.airID then
				legCount = legCount * 0.3 + 1
			end
			self.BGLeg.Scale = 1
		end
		local playerControlled = self:IsPlayerControlled()
		local crouching = controller:IsState(Controller.BODY_CROUCH)
		if crouching and playerControlled then
			if self.Head then
				self.Head.RotAngle = self.RotAngle
			end
			if self.FGLeg then
				self.FGLeg.Scale = 0
			end
			if self.BGLeg then
				self.BGLeg.Scale = 0
			end
			self.Status = Actor.UNSTABLE
		elseif self.Status == Actor.STABLE then
			local jumping = controller:IsState(Controller.BODY_JUMPSTART)
			local jumpAngle = self:GetAimAngle(true)
			if not playerControlled then
				if self.target and MovableMan:ValidMO(self.target) then
					local canJump = self.jumpTimer:IsPastSimTimeLimit()
					if self.target.Team == self.Team and canJump then
						local dist = Vector()
						local newTarget = MovableMan:GetClosestEnemyActor(self.Team, self.Pos, self.searchRange, dist)
						if newTarget then
							self.target = newTarget
						end
					end
					local dist = SceneMan:ShortestDistance(self.Pos, self.target.Pos, SceneMan.SceneWrapsX)
					if dist:MagnitudeIsLessThan(self.searchRange * 2) then
						controller:SetState(Controller.MOVE_LEFT, dist.X < 0)
						controller:SetState(Controller.MOVE_RIGHT, dist.X > 0)
						if
							canJump
							and (dist.Y < -45 or (dist:MagnitudeIsGreaterThan(30) and dist:MagnitudeIsLessThan(60)))
						then
							self.jumpTimer:Reset()
							jumpAngle = dist.AbsRadAngle
							jumping = true
						end
						controller:SetState(Controller.BODY_CROUCH, false)
					else
						self.target = nil
					end
				else
					self.target = nil
					local dist = Vector()
					local newTarget = MovableMan:GetClosestActor(self.Pos, self.searchRange, dist, self)
					if newTarget then
						self.target = newTarget
					else
						if self.FGLeg then
							self.FGLeg.Scale = 0
						end
						if self.BGLeg then
							self.BGLeg.Scale = 0
						end
						self.Status = Actor.INACTIVE
					end
				end
			end
			if not crouching then
				self.AngularVel = self.AngularVel * (1 - legCount * 0.01)
					+ self:GetAimAngle(false) * self.FlipFactor * 0.1 * legCount
				if jumping then
					local jump = 24000 * legCount
					self:AddForce(Vector(0, -jump) + Vector(jump, 0):RadRotate(jumpAngle), Vector())
					if legCount == 1 then
						self.Status = Actor.UNSTABLE
					end
				end
			end
		end
	else
		if self.FGLeg then
			self.FGLeg.Scale = 0
		end
		if self.BGLeg then
			self.BGLeg.Scale = 0
		end
		if self.Health < self.PrevHealth and RangeRand(0.3, 1.0) > self.Health / self.MaxHealth then
			self.Status = Actor.UNSTABLE
			self:MoveOutOfTerrain(1)
			controller:SetState(Controller.BODY_JUMPSTART, true)
		end
	end
	if self.FGFoot then
		self.FGFoot.Scale = self.FGLeg.Scale
	end
	if self.BGFoot then
		self.BGFoot.Scale = self.BGLeg.Scale
	end
	if self.Health < 1 then
		if self.Head then
			self.Head:GibThis()
		end
		self:GibThis()
	end
end
