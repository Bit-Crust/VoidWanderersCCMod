function Create(self)
	self.searchRange = 250
	self.ammo = self.EmitCountLimit
	self.showAim = false
end
function Update(self)
	local parent = self:GetParent()
	if self.ammo > 0 and parent and IsActor(parent) then
		parent = ToActor(parent)
		local target
		local aimTrace = Vector(self.searchRange, 0):RadRotate(self.RotAngle + 1.57)
		-- Search for MOs directly in line of sight of two rays
		local mocheck1 = SceneMan:CastMORay(
			self.Pos,
			aimTrace:RadRotate(1 / math.sqrt(self.searchRange)),
			parent.ID,
			self.Team,
			0,
			false,
			5
		)
		if mocheck1 ~= rte.NoMOID then
			target = MovableMan:GetMOFromID(MovableMan:GetMOFromID(mocheck1).RootID)
		else
			local mocheck2 = SceneMan:CastMORay(
				self.Pos,
				aimTrace:RadRotate(-1 / math.sqrt(self.searchRange)),
				parent.ID,
				self.Team,
				0,
				false,
				5
			)
			if mocheck2 ~= rte.NoMOID then
				target = MovableMan:GetMOFromID(MovableMan:GetMOFromID(mocheck2).RootID)
			end
		end
		local color = 13
		if target and IsActor(target) then
			self:EnableEmission(true)
			self:TriggerBurst()
			if self:IsSetToBurst() then
				color = 254
				if self:CanTriggerBurst() then
					self.ammo = self.ammo - 1
				end
			end
		end
		if self.showAim then
			PrimitiveMan:DrawLinePrimitive(
				self.Team,
				self.Pos,
				self.Pos + aimTrace:RadRotate(1 / math.sqrt(self.searchRange)),
				color
			)
			PrimitiveMan:DrawLinePrimitive(
				self.Team,
				self.Pos,
				self.Pos + aimTrace:RadRotate(-1 / math.sqrt(self.searchRange)),
				color
			)
		end
	end
end
