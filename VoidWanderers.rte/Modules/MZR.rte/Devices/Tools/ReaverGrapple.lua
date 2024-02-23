function Create(self)
	AudioMan:PlaySound("Base.rte/Devices/Tools/GrappleGun/Sounds/ClawFire.wav", self.Pos)

	self.mapWrapsX = SceneMan.SceneWrapsX
	self.climbTimer = Timer()
	self.mouseClimbTimer = Timer()
	self.actionMode = 0 -- 0 = start, 1 = flying, 2 = grab terrain, 3 = grab MO
	self.climb = 0
	self.canRelease = false

	self.maxLineLength = 500

	self.setLineLength = 0
	self.lineLength = 0
	self.lineVec = Vector()

	self.limitReached = false
	self.stretchMode = false -- Alternative elastic pull mode a là Liero

	self.climbDelay = 10 -- MS time delay between "climbs" to keep the speed consistant
	self.tapTime = 150 -- Maximum amount of time between tapping for claw to return
	self.tapAmount = 2 -- How many times to tap to bring back rope
	self.mouseClimbLength = 250 -- How long to climb per mouse wheel for mouse users
	self.climbInterval = 3.5 -- How many pixels the rope retracts/extends at a time
	self.autoClimbIntervalA = 4.0 -- How many pixels the rope retracts/extends at a time when auto-climbing (fast)
	self.autoClimbIntervalB = 2.0 -- How many pixels the rope retracts/extends at a time when auto-climbing (slow)

	if self.Sharpness ~= rte.NoMOID then
		local mo = MovableMan:GetMOFromID(self.Sharpness)
		if mo and IsActor(mo) and mo.Team == self.Team then
			self.parent = ToActor(mo)
			self.parentRadius = self.parent.IndividualRadius
			self.actionMode = 1
		end
	end
	if self.parent == nil then
		self.ToDelete = true
	end
	--self.stickSound =
	--self.clickSound =
end
function Update(self)
	if self.parent and IsActor(self.parent) then
		local startPos = self.parent.Pos
		local controller = self.parent:GetController()
		self.ToDelete = false
		self.ToSettle = false

		self.lineVec = SceneMan:ShortestDistance(self.parent.Pos, self.Pos, self.mapWrapsX)
		self.lineLength = self.lineVec.Magnitude

		if self.parent.Status > Actor.STABLE then
			self.parent.AngularVel = self.parent.AngularVel / (1 + math.abs(self.parent.AngularVel) * 0.01)
		end
		-- Add sound when extending/retracting
		if MovableMan:IsParticle(self.crankSound) then
			self.crankSound.PinStrength = 1000
			self.crankSound.ToDelete = false
			self.crankSound.ToSettle = false
			self.crankSound.Pos = startPos
			if self.lastSetLineLength ~= self.setLineLength then
				self.crankSound:EnableEmission(true)
			else
				self.crankSound:EnableEmission(false)
			end
		else
			self.crankSound = CreateAEmitter("Grapple Gun Sound Crank")
			self.crankSound.Pos = startPos
			MovableMan:AddParticle(self.crankSound)
		end

		self.lastSetLineLength = self.setLineLength

		if self.actionMode == 1 then -- Hook is in flight
			self.rayVec = Vector()
			-- Stretch mode: gradually retract the hook for a return hit
			if self.stretchMode then
				self.Vel = self.Vel - self.lineVec / self.maxLineLength
			end
			local length = math.sqrt(self.Diameter + self.Vel.Magnitude)
			-- Detect terrain and stick if found
			local ray = Vector(length, 0):RadRotate(self.Vel.AbsRadAngle)
			if SceneMan:CastStrengthRay(self.Pos, ray, 0, self.rayVec, 0, 0, self.mapWrapsX) then
				self.actionMode = 2
			else -- Detect MOs and stick if found
				local moRay = SceneMan:CastMORay(self.Pos, ray, self.parent.ID, -2, 0, false, 0)
				if moRay ~= rte.NoMOID then
					self.target = MovableMan:GetMOFromID(moRay)
					-- Treat pinned MOs as terrain
					if self.target.PinStrength > 0 then
						self.actionMode = 2
					else
						self.stickPosition = SceneMan:ShortestDistance(self.target.Pos, self.Pos, self.mapWrapsX)
						self.stickRotation = self.target.RotAngle
						self.stickDirection = self.RotAngle
						self.actionMode = 3
					end
					-- Inflict damage
					local part = CreateMOPixel("Grapple Gun Damage Particle")
					part.Pos = self.Pos
					part.Vel = SceneMan
						:ShortestDistance(self.Pos, self.target.Pos, self.mapWrapsX)
						:SetMagnitude(self.Vel.Magnitude)
					MovableMan:AddParticle(part)
				end
			end
			if self.actionMode > 1 then
				AudioMan:PlaySound("Base.rte/Devices/Tools/GrappleGun/Sounds/ClawStick.wav", self.Pos)
				self.setLineLength = math.floor(self.lineLength)
				self.Vel = Vector()
				self.PinStrength = 1000
				self.Frame = 1
				self.lastVel = Vector(self.Pos.X, self.Pos.Y)
			end
			if self.lineLength > self.maxLineLength then
				if self.limitReached == false then
					self.limitReached = true
					AudioMan:PlaySound("Base.rte/Devices/Tools/GrappleGun/Sounds/Click.wav", startPos)
				end
				local movetopos = self.parent.Pos + (self.lineVec):SetMagnitude(self.maxLineLength)
				if self.mapWrapsX == true then
					if movetopos.X > SceneMan.SceneWidth then
						movetopos = Vector(movetopos.X - SceneMan.SceneWidth, movetopos.Y)
					elseif movetopos.X < 0 then
						movetopos = Vector(SceneMan.SceneWidth + movetopos.X, movetopos.Y)
					end
				end
				self.Pos = movetopos

				local pullamountnumber = math.abs(-self.lineVec.AbsRadAngle + self.Vel.AbsRadAngle) / 6.28
				self.Vel = self.Vel - self.lineVec:SetMagnitude(self.Vel.Magnitude * pullamountnumber)
			end
		elseif self.actionMode > 1 then -- Hook has stuck
			-- Actor mass and velocity affect pull strength negatively, rope length affects positively (diminishes the former)
			local parentForces = 1 + (self.parent.Vel.Magnitude * 10 + self.parent.Mass) / (1 + self.lineLength)
			local terrVector = Vector()
			-- Check if there is terrain between the hook and the user
			if self.parentRadius ~= nil then
				self.terrcheck = SceneMan:CastStrengthRay(
					self.parent.Pos,
					self.lineVec:SetMagnitude(self.parentRadius),
					0,
					terrVector,
					2,
					0,
					self.mapWrapsX
				)
			else
				self.terrcheck = false
			end
			if self.lineLength < self.parent.Radius or self.Age > 6000 then
				self.parent.Vel = self.parent.Vel + Vector(self.lineVec.X * 2, -self.lineVec.Y):SetMagnitude(10)
				self:GibThis()
			end
			-- Control automatic extension and retraction
			if self.climbTimer:IsPastSimMS(self.climbDelay) then
				self.climbTimer:Reset()

				if self.setLineLength > self.autoClimbIntervalA and self.terrcheck == false then
					self.setLineLength = self.setLineLength - (self.autoClimbIntervalA / parentForces)
				end
			end
			if self.actionMode == 2 then -- Stuck terrain
				if self.stretchMode then
					local pullVec = self.lineVec:SetMagnitude(0.15 * math.sqrt(self.lineLength) / parentForces)
					self.parent.Vel = self.parent.Vel + pullVec
				elseif self.lineLength > self.setLineLength then
					local hookVel = SceneMan:ShortestDistance(
						Vector(self.lastVel.X, self.lastVel.Y),
						Vector(self.Pos.X, self.Pos.Y),
						self.mapWrapsX
					)

					local pullAmountNumber = self.lineVec.AbsRadAngle - self.parent.Vel.AbsRadAngle
					if pullAmountNumber < 0 then
						pullAmountNumber = pullAmountNumber * -1
					end
					pullAmountNumber = pullAmountNumber / 6.28
					self.parent:AddAbsForce(
						self.lineVec:SetMagnitude(((self.lineLength - self.setLineLength) ^ 3) * pullAmountNumber)
							+ hookVel:SetMagnitude(math.pow(self.lineLength - self.setLineLength, 2) * 0.8),
						self.parent.Pos
					)

					local moveToPos = self.Pos + (self.lineVec * -1):SetMagnitude(self.setLineLength)
					if self.mapWrapsX == true then
						if moveToPos.X > SceneMan.SceneWidth then
							moveToPos = Vector(moveToPos.X - SceneMan.SceneWidth, moveToPos.Y)
						elseif moveToPos.X < 0 then
							moveToPos = Vector(SceneMan.SceneWidth + moveToPos.X, moveToPos.Y)
						end
					end
					self.parent.Pos = moveToPos

					local pullAmountNumber = math.abs(self.lineVec.AbsRadAngle - self.parent.Vel.AbsRadAngle) / 6.28
					self.parent.Vel = self.parent.Vel
						+ self.lineVec:SetMagnitude(self.parent.Vel.Magnitude * pullAmountNumber)
				end
			elseif self.actionMode == 3 then -- Stuck MO
				if self.target.ID ~= rte.NoMOID then
					self.Pos = self.target.Pos
						+ Vector(self.stickPosition.X, self.stickPosition.Y):RadRotate(
							self.target.RotAngle - self.stickRotation
						)
					self.RotAngle = self.stickDirection + (self.target.RotAngle - self.stickRotation)
					if self.lineLength > self.setLineLength then
						local jointStiffness
						local target = self.target
						if target.ID ~= target.RootID then
							local mo = MovableMan:GetMOFromID(target.RootID)
							if mo.ID ~= rte.NoMOID and IsAttachable(target) then
								-- It's best to apply all the forces to the parent instead of utilizing JointStiffness
								target = mo
							end
						end
						-- Take wrapping to account, treat all distances relative to hook
						local parentPos = target.Pos
							+ SceneMan:ShortestDistance(target.Pos, self.parent.Pos, self.mapWrapsX)
						-- Add forces to both user and the target MO
						local hookVel = SceneMan:ShortestDistance(
							Vector(self.lastVel.X, self.lastVel.Y),
							Vector(self.Pos.X, self.Pos.Y),
							self.mapWrapsX
						)

						local pullAmountNumber = self.lineVec.AbsRadAngle - self.parent.Vel.AbsRadAngle
						if pullAmountNumber < 0 then
							pullAmountNumber = pullAmountNumber * -1
						end
						pullAmountNumber = pullAmountNumber / 6.28
						self.parent:AddAbsForce(
							self.lineVec:SetMagnitude(((self.lineLength - self.setLineLength) ^ 3) * pullAmountNumber)
								+ hookVel:SetMagnitude(math.pow(self.lineLength - self.setLineLength, 2) * 0.8),
							self.parent.Pos
						)

						pullAmountNumber = (self.lineVec * -1).AbsRadAngle - (hookVel).AbsRadAngle
						if pullAmountNumber < 0 then
							pullAmountNumber = pullAmountNumber * -1
						end
						pullAmountNumber = pullAmountNumber / 6.28
						local targetforce = (
								(self.lineVec * -1):SetMagnitude(
									((self.lineLength - self.setLineLength) ^ 3) * pullAmountNumber
								)
								+ (self.lineVec * -1):SetMagnitude(
									math.pow(self.lineLength - self.setLineLength, 2) * 0.8
								)
							)

						target:AddAbsForce(targetforce, self.Pos) --target.Pos + SceneMan:ShortestDistance(target.Pos, self.Pos, self.mapWrapsX));
						target.AngularVel = target.AngularVel * 0.99

						self.lastVel = Vector(self.Pos.X, self.Pos.Y)
					end
				else -- Our MO has been destroyed, return hook
					self:GibThis()
				end
			end
		end
		-- Fine tuning: take the seam into account when drawing the rope
		local drawPos = self.parent.Pos + self.lineVec:SetMagnitude(self.lineLength)
		PrimitiveMan:DrawLinePrimitive(startPos, drawPos, 2)
	else
		self:GibThis()
	end
end
function Destroy(self)
	if MovableMan:IsParticle(self.crankSound) then
		self.crankSound.ToDelete = true
	end
end
