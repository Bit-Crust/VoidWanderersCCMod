require("Scripts/Lib_Generic")

function Create(self)
	self.attachSound = CreateSoundContainer(
		self:StringValueExists("AttachSound") and self:GetStringValue("AttachSound") or "Robot Stride"
	)
	self.errorSound = CreateSoundContainer("Error")
end

function Update(self)
	if self:GetParent() and IsActor(self:GetParent()) then
		--self:DisableScript("VoidWanderers.rte/Items/Limb.lua")
	elseif self:IsActivated() then
		local parent = self:GetRootParent()
		if IsActor(parent) and not self.wasActivated then
			parent = ToActor(parent)
			local moCheck = SceneMan:CastMORay(
				self.MuzzlePos,
				Vector(self.Radius * self.FlipFactor, 0):RadRotate(self.RotAngle),
				parent.ID,
				Activity.NOTEAM,
				rte.grassID,
				true,
				4
			)
			local actor = moCheck == rte.NoMOID and parent or MovableMan:GetMOFromID(moCheck)
			if
				actor
				and IsAHuman(actor:GetRootParent())
				and CF.AttemptReplaceLimb(ToAHuman(actor:GetRootParent()), self)
			then
				ToAHuman(actor:GetRootParent()):FlashWhite(50)
				self.attachSound:Play(self.Pos)
				self:GetParent():RemoveAttachable(self, false, false)
			else
				self.errorSound:Play(self.Pos)
			end
		end
		self.wasActivated = true
		self:Deactivate()
	else
		self.wasActivated = false
	end
end
