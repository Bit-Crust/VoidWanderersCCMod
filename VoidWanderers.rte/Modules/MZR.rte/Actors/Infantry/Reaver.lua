dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")
--require("AI/HumanFunctions")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.armSway = true
	self.alternativeGib = true
end
function Update(self)
	self.controller = self:GetController()
	--HumanFunctions.DoAlternativeGib(self);
	local healthRatio = self.Health / self.MaxHealth
	--HumanFunctions.DoArmSway(self, healthRatio);
	if self.Status < Actor.DEAD then
		self.AngularVel = self.AngularVel
			+ (RangeRand(-1, 1) * healthRatio)
				/ (math.abs(self.AngularVel) + 1 + math.sin(self.RotAngle) + math.sqrt(self.Vel.Magnitude))
	end
end
function UpdateAI(self)
	self.AI:Update(self)
end
function Destroy(self)
	self.AI:Destroy(self)
end
