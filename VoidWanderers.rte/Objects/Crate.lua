function Create(self)
	local act, itm
	if CF_PlayerTeam ~= nil then
		if not self:NumberValueExists("VWOpenCrate") and math.random(50, 1000) < CF_Difficulty then
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
			if #CF_ArtActPresets == 0 then
				CF_ArtifactActorRate = 0
			end
			local artifactChance = CF_ArtifactActorRate - (CF_ArtifactActorRate / (0.5 + math.sqrt(#CF_ArtActPresets)))

			local atypes = { CF_ActorTypes.LIGHT, CF_ActorTypes.HEAVY, CF_ActorTypes.HEAVY, CF_ActorTypes.ARMOR }
			local f
			local ok = false

			while not ok do
				f = CF_Factions[math.random(#CF_Factions)]
				if CF_FactionPlayable[f] then
					ok = true
				end
			end

			-- We need this fake cfg because CF_MakeList operates only on configs to get data
			local cfg = {}
			cfg["Player0Faction"] = f

			--print (cfg)

			local acts = CF_MakeListOfMostPowerfulActors(cfg, 0, atypes[math.random(#atypes)], 100000)

			if math.random() < artifactChance or acts == nil then
				local r = math.random(#CF_ArtActPresets)
				act = CF_MakeActor(CF_ArtActPresets[r], CF_ArtActClasses[r], CF_ArtActModules[r])
			else
				local r = #acts > 1 and math.random(#acts) or 1
				local actindex = acts[r]["Actor"]
				act = CF_MakeActor(CF_ActPresets[f][actindex], CF_ActClasses[f][actindex], CF_ActModules[f][actindex])
			end
			if act then
				act.AngularVel = 0
				act.Vel = Vector(0, -3)
				act.Pos = self.Pos + Vector(0, -10)
				act.Team = CF_PlayerTeam
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
