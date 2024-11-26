local tempvar = nil

function CF_Read(self, keys) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("read_from_CF", {self, keys})
	return tempvar
end

function CF_Write(keys, value) 
	ActivityMan:GetActivity():SendMessage("write_to_CF", {keys, value})
end

function CF_Call(self, keys, arguments) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("call_in_CF", {self, keys, arguments})
	return tempvar
end

function OnMessage(self, message, context)
	if message == "return_from_activity" then
		tempvar = context
	end
end

function Create(self)
	local itm

	local playerTeam = CF_Read(self, {"PlayerTeam"})
	local difficulty = CF_Read(self, {"Difficulty"})
	local artifactActorRate = 0
	local weaponTypes = CF_Read(self, {"WeaponTypes"})
	local factions = CF_Read(self, {"Factions"})
	local factionPlayable = CF_Read(self, {"FactionPlayable"})
	local artItmPresets = CF_Read(self, {"ArtItmPresets"})
	local artItmClasses = CF_Read(self, {"ArtItmClasses"})
	local artItmModules = CF_Read(self, {"ArtItmModules"})
	local itmPresets = CF_Read(self, {"ItmPresets"})
	local itmClasses = CF_Read(self, {"ItmClasses"})
	local itmModules = CF_Read(self, {"ItmModules"})

	if playerTeam ~= nil then
		if not self:NumberValueExists("VWOpenCrate") and math.random(50, 1000) < difficulty then
			for i = 1, math.random(3) do
				itm = CreateTDExplosive("Base.rte/Frag Grenade")
				itm.Pos = self.Pos
				itm.Vel = Vector(math.random(-2, 2), math.random(-5, -3))
				itm:Activate()
				MovableMan:AddItem(itm)
			end
		else
			if #artItmPresets == 0 then
				CF_Write({"ArtifactItemRate"}, 0)
			end
			artifactActorRate = CF_Read(self, {"ArtifactItemRate"})
			local artifactChance =artifactActorRate - (artifactActorRate / (0.5 + math.sqrt(#artItmPresets)))

			local f
			local ok = false

			while not ok do
				f = factions[math.random(#factions)]
				if factionPlayable[f] then
					ok = true
				end
			end

			-- We need this fake gameState because CF.MakeList operates only on configs to get data
			local fakeState = {}
			fakeState["Player1Faction"] = f

			--print (cfg)
			local weaps = CF_Call(self, {"MakeListOfMostPowerfulWeapons"}, {fakeState, 1, weaponTypes.ANY, 100000})[1]

			if math.random() < artifactChance or weaps == nil then
				local r = math.random(#artItmPresets)
				itm = CF_Call(self, {"MakeItem"}, {artItmPresets[r], artItmClasses[r], artItmModules[r]})[1]:Clone()
			else
				local r = #weaps > 1 and math.random(#weaps) or 1
				local itmindex = weaps[r]["Item"]
				itm = CF_Call(self, {"MakeItem"}, {itmPresets[f][itmindex], itmClasses[f][itmindex], itmModules[f][itmindex]})[1]:Clone()
			end
			if itm then
				itm.AngularVel = 0
				itm.Vel = Vector(0, -3)
				itm.Pos = self.Pos + Vector(0, -5)
				MovableMan:AddItem(itm)
			end
		end
	end
	if itm == nil then
		local sizes = { 10, 15, 24 }
		for i = 20, math.random(20, 40) do
			itm = CreateMOSRotating(sizes[math.random(#sizes)] .. "oz Gold Brick", "Base.rte")
			itm.Pos = self.Pos
			itm.Vel = Vector(0, -2) + Vector(math.random(4), 0):RadRotate(RangeRand(-math.pi, math.pi))
			itm.AngularVel = math.random(-3, 3)
			MovableMan:AddParticle(itm)
		end
	end
	self.ToDelete = true
end
