function OnPieMenu(self, pieActor)
	self.user = nil
	if SceneMan:ShortestDistance(self.Pos, pieActor.Pos, SceneMan.SceneWrapsX):MagnitudeIsLessThan(25) then
		ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Open Crate", "VWOpenCrate", Slice.UP, true)
		self.user = pieActor
	end
end
function VWOpenCrate(actor)
	ToActor(actor):SetNumberValue("VWOpenCrate", 1)
	ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Open Crate", "VWOpenCrate")
	--ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Open Crate", "VWOpenCrate", Slice.UP, false)
end
function Update(self)
	if self.user and MovableMan:IsActor(self.user) then
		if self.user:NumberValueExists("VWOpenCrate") then
			local parent = self:GetParent()
			self:GibThis()
			if parent and IsActor(parent) then
				parent.ToDelete = true
				ActivityMan:GetActivity():ReportDeath(self.Team, -1)
			end
		end
	else
		self.user = nil
	end
end
