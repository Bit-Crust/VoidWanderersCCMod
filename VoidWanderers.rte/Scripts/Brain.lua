function Create(self)
	ActivityMan:GetActivity():SendMessage("BrainCreate", self);
end

function Update(self)
	ActivityMan:GetActivity():SendMessage("BrainUpdate", self);
end

function Destroy(self)
	ActivityMan:GetActivity():SendMessage("BrainDestroy", self);
end
