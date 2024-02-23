function Create(self)
	self.rechargetimerTea = Timer()
	self.newItemDelay = 10000 --10 sec recharge per item
end

function OnPieMenu(self, pieActor)
	self.user = nil

	if
		SceneMan:ShortestDistance(self.Pos, pieActor.Pos, SceneMan.SceneWrapsX):MagnitudeIsLessThan(25)
		and self.rechargetimerTea:IsPastSimMS(self.newItemDelay)
	then
		ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice(
			"Take Tea",
			"TakeTea",
			Slice.UP,
			self.rechargetimerTea:IsPastSimMS(self.newItemDelay)
		)
		self.user = pieActor
	end
end

function TakeTea(actor)
	ToActor(actor):SetNumberValue("TakeTea", 1)

	actor:AddInventoryItem(CreateHDFirearm("Tea"))
	ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Take Tea", "TakeTea")
	ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Take Tea", "TakeTea", Slice.UP, false)
end

function Update(self)
	--Check if timer has passed and activates an effect to show the module is ready to use.
	if self.rechargetimerTea:IsPastSimMS(self.newItemDelay) then
		self.Frame = 1
	else
		self.Frame = 0
	end

	if self.user and MovableMan:IsActor(self.user) then
		if self.user:NumberValueExists("TakeTea") then
			self.rechargetimerTea:Reset()
			self.user:RemoveNumberValue("TakeTea")
			self.user = nil
		end
	else
		self.user = nil
	end
end
