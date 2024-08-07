function Create(self)
	local itm
	if CF["PlayerTeam"] ~= nil then
		if not self:NumberValueExists("VWOpenCrate") and math.random(50, 1000) < CF["Difficulty"] then
			for i = 1, math.random(3) do
				itm = CreateTDExplosive("Base.rte/Frag Grenade")
				itm.Pos = self.Pos
				itm.Vel = Vector(math.random(-2, 2), math.random(-5, -3))
				itm:Activate()
				MovableMan:AddItem(itm)
			end
		else
			if #CF["ArtItmPresets"] == 0 then
				CF["ArtifactItemRate"] = 0
			end
			local artifactChance = CF["ArtifactItemRate"] - (CF["ArtifactItemRate"] / (0.5 + math.sqrt(#CF["ArtItmPresets"])))

			local wtypes = { CF["WeaponTypes"].RIFLE, CF["WeaponTypes"].SHOTGUN, CF["WeaponTypes"].SNIPER, CF["WeaponTypes"].HEAVY }
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
			local weaps = CF["MakeListOfMostPowerfulWeapons"](cfg, 0, wtypes[math.random(#wtypes)], 100000)

			if math.random() < artifactChance or weaps == nil then
				local r = math.random(#CF["ArtItmPresets"])
				itm = CF["MakeItem"](CF["ArtItmPresets"][r], CF["ArtItmClasses"][r], CF["ArtItmModules"][r])
			else
				local r = #weaps > 1 and math.random(#weaps) or 1
				local itmindex = weaps[r]["Item"]
				itm = CF["MakeItem"](CF["ItmPresets"][f][itmindex], CF["ItmClasses"][f][itmindex], CF["ItmModules"][f][itmindex])
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
