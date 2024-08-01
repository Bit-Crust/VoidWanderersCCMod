function Create(self)
	local act, itm
	if CF["PlayerTeam"] ~= nil then
		if not self:NumberValueExists("VWOpenCrate") and math.random(50, 1000) < CF["Difficulty"] then
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
			if #CF["ArtActPresets"] == 0 then
				CF["ArtifactActorRate"] = 0
			end
			local artifactChance = CF["ArtifactActorRate"] - (CF["ArtifactActorRate"] / (0.5 + math.sqrt(#CF["ArtActPresets"])))

			local atypes = { CF["ActorTypes"].LIGHT, CF["ActorTypes"].HEAVY, CF["ActorTypes"].HEAVY, CF["ActorTypes"].ARMOR }
			local f
			local ok = false

			while not ok do
				f = CF["Factions"][math.random(#CF["Factions"])]
				if CF["FactionPlayable"][f] then
					ok = true
				end
			end

			-- We need this fake cfg because CF["MakeList"] operates only on configs to get data
			local cfg = {}
			cfg["Player0Faction"] = f

			--print (cfg)

			local acts = CF["MakeListOfMostPowerfulActors"](cfg, 0, atypes[math.random(#atypes)], 100000)

			if math.random() < artifactChance or acts == nil then
				local r = math.random(#CF["ArtActPresets"])
				act = CF["MakeActor"](CF["ArtActPresets"][r], CF["ArtActClasses"][r], CF["ArtActModules"][r])
			else
				local r = #acts > 1 and math.random(#acts) or 1
				local actindex = acts[r]["Actor"]
				act = CF["MakeActor"](CF["ActPresets"][f][actindex], CF["ActClasses"][f][actindex], CF["ActModules"][f][actindex])
			end
			if act then
				act.AngularVel = 0
				act.Vel = Vector(0, -3)
				act.Pos = self.Pos + Vector(0, -10)
				act.Team = CF["PlayerTeam"]
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
