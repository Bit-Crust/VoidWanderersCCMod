function Create(self)
	self.Timer = Timer()
	self.Timer:Reset()
end
function Update(self)
	if self.Timer:IsPastSimMS(250) then
		self.ToDelete = true
	end
end
