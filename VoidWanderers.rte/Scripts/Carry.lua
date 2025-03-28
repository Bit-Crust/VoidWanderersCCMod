function Create(self)
	self.pickupIcon = CreateMOSParticle("Pickup Icon", "VoidWanderers.rte")
	self.activity = ActivityMan:GetActivity()
end
function Update(self)
	local armToUse = self.FGArm or self.BGArm
	if
		self.pickedUpObject
		and IsMOSRotating(self.pickedUpObject)
		and self.Status == Actor.STABLE
		and armToUse
		and self.EquippedItem
		and self.EquippedItem.PresetName == self.pickedUpObjectName
		and (not IsActor(self.pickedUpObject) or self.pickedUpObject.Status ~= Actor.STABLE)
	then
		--TODO: Transfer impulse forces?
		self.pickedUpObject:NotResting()
		self.pickedUpObject.Pos = armToUse.HandPos
		self.pickedUpObject.RotAngle = math.sin(armToUse.RotAngle) * (1 - self.SharpAimProgress)
		self.pickedUpObject.AngularVel = self.AngularVel
		self.pickedUpObject.Vel = self.Vel
		self.EquippedItem.Mass = self.pickedUpObject.Mass
		self.pickedUpObject:SetWhichMOToNotHit(self, 10)
		self:SetWhichMOToNotHit(self.pickedUpObject, 10)
		if self:GetController():IsState(Controller.WEAPON_DROP) then
			local tossVec = Vector(
				1.0
					+ math.sqrt(math.abs(armToUse.ThrowStrength) - self.AngularVel * 0.5 * self.FlipFactor)
						/ math.sqrt(math.abs(self.pickedUpObject.Mass) + 1.0),
				RangeRand(-1, 1)
			):RadRotate(self:GetAimAngle(true))
			self.pickedUpObject.Vel = self.Vel * 0.5 + tossVec
			self.pickedUpObject.AngularVel = self.AngularVel * 0.5 + 3.0 * RangeRand(-1, 1)

			armToUse.HandPos = armToUse.HandPos + tossVec
			self.pickedUpObject.Pos = armToUse.HandPos

			self:RemoveInventoryItem(self.pickedUpObjectName)
			self.pickedUpObject = nil
		end
	else
		--Remove any dummy items that might have been left over
		if self.pickedUpObjectName then
			self:RemoveInventoryItem(self.pickedUpObjectName)
			if self.EquippedItem and self.EquippedItem.PresetName == self.pickedUpObjectName then
				self.EquippedItem.ToDelete = true
			end
			self.pickedUpObjectName = nil
			self:SetWhichMOToNotHit(nil, -1)
		end
		self.pickedUpObject = nil
		if self:IsPlayerControlled() and self.Status == Actor.STABLE then
			if self.ItemInReach then
				self.objectInReach = nil
			elseif armToUse then
				local adjustedAimAngle = self:GetAimAngle(false) * self.FlipFactor

				local reach = armToUse.MaxLength * 1.5
				local reachPoint = armToUse.HandPos

				local itemMOID = SceneMan:CastMORay(
					reachPoint,
					Vector(reach * RangeRand(0.5, 1.0) * self.FlipFactor, 0):RadRotate(
						self.ItemInReach and adjustedAimAngle
							or RangeRand(
									-(math.pi * 0.5 + math.pi * 0.125),
									self:GetAimAngle(false) * 0.75 + math.pi * 0.125
								)
								* self.FlipFactor
					),
					self.ID,
					Activity.NOTEAM,
					rte.grassID,
					true,
					3
				)
				local foundMO = MovableMan:GetMOFromID(itemMOID)
				if foundMO and IsMOSRotating(foundMO) then
					if
						IsAttachable(foundMO)
						and ToAttachable(foundMO):NumberValueExists("Carriable")
						and (
							not IsActor(foundMO:GetRootParent())
							or (
								ToActor(foundMO:GetRootParent()).Status ~= Actor.STABLE
								and ToAttachable(foundMO).JointStrength > 0
								and ToAttachable(foundMO).JointStrength <= armToUse.GripStrength
							)
						)
					then
						foundMO = ToAttachable(foundMO)
					else
						foundMO = ToMOSRotating(foundMO:GetRootParent())
					end
					local radius = IsActor(foundMO) and foundMO.IndividualRadius + 1 or foundMO.Radius
					if
						(IsActor(foundMO) or foundMO:NumberValueExists("Carriable"))
						and SceneMan
							:ShortestDistance(reachPoint, foundMO.Pos, SceneMan.SceneWrapsX)
							:MagnitudeIsLessThan(reach + radius)
					then
						self.objectInReach = foundMO
					end
				end

				if self.objectInReach then
					if
						not IsMOSRotating(self.objectInReach)
						or (IsActor(self.objectInReach) and ToActor(self.objectInReach).Status == Actor.STABLE)
						or self.objectInReach.ID == self.ID
						or SceneMan
							:ShortestDistance(reachPoint, self.objectInReach.Pos, SceneMan.SceneWrapsX)
							:MagnitudeIsGreaterThan(
								reach
									+ (IsActor(self.objectInReach) and self.objectInReach.IndividualRadius or self.objectInReach.Radius)
									+ 5
							)
					then
						self.objectInReach = nil
					else
						self.ItemInReach = nil
						local displayName = self.objectInReach:GetStringValue("VW_Name") == ""
								and self.objectInReach.PresetName
							or self.objectInReach:GetStringValue("VW_Name")
						local screen = self.activity:ScreenOfPlayer(self:GetController().Player)
						if screen ~= -1 then
							local drawPos = self.AboveHUDPos
								+ Vector(
									1
										+ (
												self.pickupIcon:GetSpriteWidth()
												- FrameMan:CalculateTextWidth(displayName, true)
											)
											* 0.5,
									-3
								)
							PrimitiveMan:DrawBitmapPrimitive(
								screen,
								drawPos + Vector(-6, 5),
								self.pickupIcon,
								0,
								0,
								false,
								false
							)
							PrimitiveMan:DrawTextPrimitive(screen, drawPos, displayName, true, 0)
						end
						if self:GetController():IsState(Controller.WEAPON_PICKUP) then
							self.pickedUpObject = self.objectInReach
							self.pickedUpObjectName = displayName
							self.objectInReach = nil
							local actorItem = CreateHeldDevice("Null Item", "Base.rte")
							self.pickedUpObject.Team = self.Team
							if IsActor(self.pickedUpObject) then
								self.pickedUpObject = ToActor(self.pickedUpObject)
								local sound = self.pickedUpObject.AlarmSound or self.pickedUpObject.PainSound
								if sound and self.pickedUpObject.Status < Actor.INACTIVE then
									sound:Play(self.pickedUpObject.Pos)
								end
								actorItem.StanceOffset = Vector(armToUse.MaxLength * 0.5, armToUse.MaxLength * 0.5)
							else
								if
									IsAttachable(self.pickedUpObject) and ToAttachable(self.pickedUpObject):GetParent()
								then
									ToAttachable(self.pickedUpObject)
										:GetParent()
										:RemoveAttachable(ToAttachable(self.pickedUpObject), true, true)
								end
								self.pickedUpObject:SetNumberValue(
									"Carriable",
									self.pickedUpObject:GetNumberValue("Carriable") + 1
								)
								self.pickedUpObject.IgnoresTeamHits = true
								actorItem.StanceOffset = Vector(armToUse.MaxLength * 0.66, armToUse.MaxLength * 0.33)
							end
							local totalMass = self.pickedUpObject.Mass + self.Mass
							if totalMass >= 1 then
								self.Vel = self.Vel * (self.pickedUpObject.Mass / totalMass)
									+ self.pickedUpObject.Vel * (self.Mass / totalMass)
							end
							local massRatio = self.pickedUpObject.Mass > 1
									and math.min(
										(self.Mass - self.InventoryMass) / self.pickedUpObject.Mass,
										2
									)
								or 1
							actorItem.SharpStanceOffset = Vector(armToUse.MaxLength * 0.75, 1)
							actorItem.Lifetime = -1
							actorItem.SharpLength = 1
							actorItem.PresetName = self.pickedUpObjectName
							actorItem.DeleteWhenRemovedFromParent = true

							self:AddInventoryItem(actorItem)
							self:EquipNamedDevice(self.pickedUpObjectName, true)
							armToUse.HandPos = self.pickedUpObject.Pos
						end
					end
				end
			end
		end
	end
end
