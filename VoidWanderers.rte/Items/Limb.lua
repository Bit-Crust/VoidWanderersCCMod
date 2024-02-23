function Create(self)
	self.attachSound = CreateSoundContainer(
		self:StringValueExists("AttachSound") and self:GetStringValue("AttachSound") or "Robot Stride"
	)
	self.errorSound = CreateSoundContainer("Error")
end

function Update(self)
	if self:GetParent() and IsActor(self:GetParent()) then
		--self:DisableScript("VoidWanderers.rte/Items/Limb.lua");
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
				and CF_AttemptReplaceLimb(self, ToAHuman(actor:GetRootParent()))
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

function CF_AttemptReplaceLimb(self, actor)
	local j = 0
	local isArm = string.find(self.PresetName, " Arm")
	local isLeg = string.find(self.PresetName, " Leg")
	local isHead = string.find(self.PresetName, " Head")
	local limbName = self:StringValueExists("LimbName") and self:GetStringValue("LimbName") or self.PresetName
	if isArm then
		j = not actor.FGArm and 1 or (not actor.BGArm and 2 or j)
	elseif isLeg then
		j = not actor.FGLeg and 3 or (not actor.BGLeg and 4 or j)
	elseif isHead and actor.Head == nil then
		j = 5
	end
	if j ~= 0 then
		local reference = CreateAHuman(actor:GetModuleAndPresetName())
		local referenceLimb
		if j == 1 then
			referenceLimb = reference.FGArm
		elseif j == 2 then
			referenceLimb = reference.BGArm
		elseif j == 3 then
			referenceLimb = reference.FGLeg
		elseif j == 4 then
			referenceLimb = reference.BGLeg
		elseif j == 5 then
			referenceLimb = reference.Head
		end
		local newLimb
		if isArm then
			newLimb = CreateArm(limbName .. (j == 1 and " FG" or " BG"))
		elseif isLeg then
			newLimb = CreateLeg(limbName .. (j == 3 and " FG" or " BG"))
		else
			newLimb = self:Clone() --(limbName);
		end
		if newLimb then
			if referenceLimb then
				newLimb.ParentOffset = referenceLimb.ParentOffset
				local woundName = referenceLimb:GetEntryWoundPresetName()
				if woundName ~= "" then
					newLimb.ParentBreakWound = CreateAEmitter(woundName)
				end
			end
			for wound in newLimb.Wounds do
				if
					math.floor(wound.ParentOffset.X - newLimb.JointOffset.X + 0.5) == 0
					and math.floor(wound.ParentOffset.Y - newLimb.JointOffset.Y + 0.5) == 0
				then
					for em in wound.Emissions do
						em.ParticlesPerMinute = 0
					end
					wound.Scale = wound.Scale * 0.7
				end
			end
			if j == 1 then
				actor.FGArm = newLimb
			elseif j == 2 then
				actor.BGArm = newLimb
			elseif j == 3 then
				actor.FGLeg = newLimb
			elseif j == 4 then
				actor.BGLeg = newLimb
			elseif j == 5 then
				actor.Head = newLimb
			end
			for wound in actor.Wounds do
				if
					math.floor(wound.ParentOffset.X - newLimb.ParentOffset.X + 0.5) == 0
					and math.floor(wound.ParentOffset.Y - newLimb.ParentOffset.Y + 0.5) == 0
				then
					for em in wound.Emissions do
						em.ParticlesPerMinute = 0
					end
					wound.Scale = wound.Scale * 0.7
				end
			end
			self:RemoveNumberValue("Carriable")
		else
			j = 0
		end
		DeleteEntity(reference)
	end
	return j ~= 0
end
