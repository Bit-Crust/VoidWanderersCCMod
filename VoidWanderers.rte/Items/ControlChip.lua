require("Scripts/Lib_Generic");

function Create(self)
	self.attachSound = CreateSoundContainer(self:StringValueExists("AttachSound") and self:GetStringValue("AttachSound") or "Robot Stride");
	self.errorSound = CreateSoundContainer("Error");
end

function Update(self)
	if self:GetParent() and IsActor(self:GetParent()) then
	elseif self:IsActivated() then
		if not self.wasActivated then
			local parent = self:GetRootParent();
			local success = false;

			if IsActor(parent) then
				parent = ToActor(parent);

				local moCheck = SceneMan:CastMORay(self.MuzzlePos, Vector(self.Radius * self.FlipFactor * 2, 0):RadRotate(self.RotAngle), parent.ID, Activity.NOTEAM, rte.grassID, true, 4);
				local target = moCheck ~= rte.NoMOID and MovableMan:GetMOFromID(moCheck);

				if target then
					local rootParent = target:GetRootParent();

					if IsAHuman(rootParent) then
						local human = ToAHuman(rootParent);

						if human:IsDead() and (human.Team ~= parent.Team or (human:NumberValueExists("VW_CarryingTeam") and human:GetNumberValue("VW_CarryingTeam") ~= parent.Team)) then
							human:FlashWhite(50);
							self.attachSound:Play(human.Pos);
							self:GetParent():RemoveAttachable(self, false, false);
							human.Team = parent.Team;

							if human:NumberValueExists("VW_CarryingTeam") then
								human:SetNumberValue("VW_CarryingTeam", parent.Team);
							end

							success = true;
						end
					end
				end
			end

			if not success then
				self.errorSound:Play(self.Pos);
			end
		end

		self.wasActivated = true;
		self:Deactivate();
	else
		self.wasActivated = false;
	end
end
