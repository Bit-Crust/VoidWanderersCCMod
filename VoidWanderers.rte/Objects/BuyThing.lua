function Create(self)
	self.activity = ToGameActivity(ActivityMan:GetActivity())
	self.cost = self:GetGoldValue(0, 1, 1)
	self.text = "Open for " .. self.cost .. " gold"
	self.drop = CreateMOSRotating(self.PresetName .. " Item Spawn", "VoidWanderers.rte")
	--self.drop:SetNumberValue("VWOpenCrate", 0.5);
	self.interactDist = 25

	self.pieSliceToAdd = CreatePieSlice("VW Case PieSlice")
	self.pieSliceToAdd.Description = self.text
	self.currentUsers = {}
end
function VWOpenCrate(actor, menu, slice)
	ToActor(actor):SetNumberValue("VWOpenCrate", 1)
	slice.Enabled = false
end
function Update(self)
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT do
		local currentUser = self.currentUsers[player]
		currentUser = MovableMan:IsActor(currentUser) and currentUser or nil
		-- Handle the current user for each player - reset recharge if it's taken an item, and remove the added PieSlice if it's too far or not player controlled
		if currentUser then
			if
				currentUser:IsPlayerControlled()
				and SceneMan
					:ShortestDistance(self.Pos, currentUser.Pos, SceneMan.SceneWrapsX)
					:MagnitudeIsLessThan(self.interactDist + currentUser.IndividualRadius + 3)
			then
				if currentUser:NumberValueExists("VWOpenCrate") then
					if currentUser.GoldCarried >= self.cost then
						currentUser.GoldCarried = currentUser.GoldCarried - self.cost
					else
						self.activity:SetTeamFunds(
							self.activity:GetTeamFunds(currentUser.Team) - self.cost,
							currentUser.Team
						)
					end
					local parent = self:GetParent()
					if parent and IsActor(parent) then
						parent.ToDelete = true
						self.activity:ReportDeath(self.Team, -1)
					end
					self.drop:SetNumberValue("VWOpenCrate", 1)
					self:GibThis()
					currentUser:RemoveNumberValue("VWOpenCrate")
				else
					local existingPieSlice = currentUser.PieMenu:GetFirstPieSliceByPresetName(
						self.pieSliceToAdd.PresetName
					)
					if existingPieSlice then
						existingPieSlice.Enabled = currentUser.GoldCarried >= self.cost
							or self.activity:GetTeamFunds(currentUser.Team) >= self.cost
					end
				end
			else
				currentUser.PieMenu:RemovePieSlicesByPresetName(self.pieSliceToAdd.PresetName)
				self.currentUsers[player] = nil
			end
		end

		-- Handle finding new current users by looking to see if each player's controlled actor is close enough to this locker to get a PieSlice
		local activityControlledActor = self.activity:GetControlledActor(player)
		if
			activityControlledActor
			and (currentUser == nil or activityControlledActor.UniqueID ~= currentUser.UniqueID)
			and SceneMan
				:ShortestDistance(self.Pos, activityControlledActor.Pos, SceneMan.SceneWrapsX)
				:MagnitudeIsLessThan(self.interactDist + activityControlledActor.IndividualRadius)
		then
			self.currentUsers[player] = activityControlledActor
			activityControlledActor.PieMenu:AddPieSliceIfPresetNameIsUnique(self.pieSliceToAdd:Clone(), self)
		end
	end
end
function Destroy(self)
	if
		self.drop--[[ and math.random() < self.drop:GetNumberValue("VWOpenCrate")]]
	then
		self.drop.Pos = self.Pos
		MovableMan:AddParticle(self.drop)
		self.drop = nil
	end
end
