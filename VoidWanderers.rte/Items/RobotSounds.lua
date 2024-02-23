function OnAttach(self, parent)
	if IsAHuman(parent) then
		ToAHuman(parent).PainSound = CreateSoundContainer("Robot Pain", "Base.rte")
		ToAHuman(parent).DeathSound = CreateSoundContainer("Robot Death", "Base.rte")
	end
end
