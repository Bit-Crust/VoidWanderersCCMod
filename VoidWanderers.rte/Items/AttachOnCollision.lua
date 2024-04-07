function Create(self)
	self.attachSound = (self.BreakWound and self.BreakWound.BurstSound) and self.BreakWound.BurstSound:Clone()
		or self.attachSound
	self:SetNumberValue("Carriable", 1)
end

function OnCollideWithMO(self, mo, rootMO)
	if
		not self.ToDelete
		and self.detachTimer
		and self.detachTimer:IsPastSimMS(1000)
		and self:GetNumberValue("Carriable") > 1
		and mo
		and IsAHuman(mo)
		and CF_AttemptReplaceLimb(ToAHuman(mo), self)
	then
		self.attachSound:Play(self.Pos)
		self.ToDelete = true
	end
end

function OnCollideWithTerrain(self, terrainID)
	if
		not self.ToDelete
		and self.detachTimer
		and self.detachTimer:IsPastSimMS(1000)
		and self:GetNumberValue("Carriable") > 1
	then
		local mo = MovableMan:GetMOFromID(
			SceneMan:CastMORay(self.Pos, self.Vel.Normalized, self.ID, Activity.NOTEAM, rte.airID, true, 1)
		)
		if mo and IsAHuman(mo:GetRootParent()) and CF_AttemptReplaceLimb(ToAHuman(mo:GetRootParent()), self) then
			self.attachSound:Play(self.Pos)
			self.ToDelete = true
		end
	end
end

function OnAttach(self, parent)
	self.detachTimer = nil
end

function OnDetach(self, parent)
	self.detachTimer = Timer()
	self.JointStrength = self.JointStrength * 0.7
	self:SetNumberValue("Carriable", 1)
end
