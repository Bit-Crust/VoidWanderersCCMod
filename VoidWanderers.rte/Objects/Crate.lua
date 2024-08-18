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
	local act, itm

	local playerTeam = CF_Read(self, {"PlayerTeam"})
	local difficulty = CF_Read(self, {"Difficulty"})
	local artifactActorRate = 0
	local actorTypes = CF_Read(self, {"ActorTypes"})
	local factions = CF_Read(self, {"Factions"})
	local factionPlayable = CF_Read(self, {"FactionPlayable"})
	local artActPresets = CF_Read(self, {"ArtActPresets"})
	local artActClasses = CF_Read(self, {"ArtActClasses"})
	local artActModules = CF_Read(self, {"ArtActModules"})
	local actPresets = CF_Read(self, {"ActPresets"})
	local actClasses = CF_Read(self, {"ActClasses"})
	local actModules = CF_Read(self, {"ActModules"})

	if playerTeam ~= nil then
		if not self:NumberValueExists("VWOpenCrate") and math.random(50, 1000) < difficulty then
			if math.random() < 0.9 then
				act = CreateACrab("Crab", "Base.rte")
				act.Pos = self.Pos
				act.Vel = Vector(0, -5)
				act.Team = Activity.NOTEAM
				act.AIMode = Actor.AIMODE_PATROL

				itm = CreateTDExplosive("Standard Bomb", "Base.rte")
				itm:Activate()
				act:AddInventoryItem(itm)

				MovableMan:AddActor(act)
			else
				for i = 1, math.random(3) do
					itm = CreateMOSRotating("Anti Personnel Mine Active")
					itm.Pos = self.Pos
					itm.Vel = Vector(math.random(5, 10), 0):RadRotate(RangeRand(-math.pi, math.pi))
					MovableMan:AddParticle(itm)
				end
			end
		else
			if #artActPresets == 0 then
				CF_Write({"ArtifactActorRate"}, 0)
			end
			artifactActorRate = CF_Read(self, {"ArtifactActorRate"})
			local artifactChance = artifactActorRate - (artifactActorRate / (0.5 + math.sqrt(#artActPresets)))

			local f
			local ok = false

			while not ok do
				f = factions[math.random(#factions)]
				if factionPlayable[f] then
					ok = true
				end
			end

			-- We need this fake cfg because CF["MakeList"] operates only on configs to get data
			local cfg = {}
			cfg["Player0Faction"] = f

			--print (cfg)

			local acts = CF_Call(self, {"MakeListOfMostPowerfulActors"}, {cfg, 0, actorTypes[math.random(#actorTypes)], 100000})[1]

			if math.random() < artifactChance or acts == nil then
				local r = math.random(#artActPresets)
				act = CF_Call(self, {"MakeActor"}, {artActPresets[r], artActClasses[r], artActModules[r]})[1]:Clone()
			else
				local r = #acts > 1 and math.random(#acts) or 1
				local actindex = acts[r]["Actor"]
				act = CF_Call(self, {"MakeActor"}, {actPresets[f][actindex], actClasses[f][actindex], actModules[f][actindex]})[1]:Clone()
			end
			print(act)
			if act then
				act.AngularVel = 0
				act.Vel = Vector(0, -3)
				act.Pos = self.Pos + Vector(0, -10)
				act.Team = playerTeam
				act.AIMode = Actor.AIMODE_SENTRY
				MovableMan:AddActor(act)
			end
		end
	end
	if act == nil and itm == nil then
		local sizes = { 10, 15, 24 }
		for i = 30, math.random(30, 60) do
			itm = CreateMOSRotating(sizes[math.random(#sizes)] .. "oz Gold Brick", "Base.rte")
			itm.Pos = self.Pos
			itm.Vel = Vector(0, -3) + Vector(math.random(6), 0):RadRotate(math.pi * 2 * math.random())
			itm.AngularVel = math.random(-4, 4)
			MovableMan:AddParticle(itm)
		end
	end
	self.ToDelete = true
end
