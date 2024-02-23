function Create(self)
	local itm
	if CF_PlayerTeam ~= nil then
		if not self:NumberValueExists("VWOpenCrate") and math.random(50, 1000) < CF_Difficulty then
			for i = 1, math.random(3) do
				itm = CreateTDExplosive("Base.rte/Frag Grenade")
				itm.Pos = self.Pos
				itm.Vel = Vector(math.random(-2, 2), math.random(-5, -3))
				itm:Activate()
				MovableMan:AddItem(itm)
			end
		else
			if #CF_ArtItmPresets == 0 then
				CF_ArtifactItemRate = 0
			end
			local artifactChance = CF_ArtifactItemRate - (CF_ArtifactItemRate / (0.5 + math.sqrt(#CF_ArtItmPresets)))

			local wtypes = { CF_WeaponTypes.RIFLE, CF_WeaponTypes.SHOTGUN, CF_WeaponTypes.SNIPER, CF_WeaponTypes.HEAVY }
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
			local weaps = CF_MakeListOfMostPowerfulWeapons(cfg, 0, wtypes[math.random(#wtypes)], 100000)

			if math.random() < artifactChance or weaps == nil then
				local r = math.random(#CF_ArtItmPresets)
				itm = CF_MakeItem(CF_ArtItmPresets[r], CF_ArtItmClasses[r], CF_ArtItmModules[r])
			else
				local r = #weaps > 1 and math.random(#weaps) or 1
				local itmindex = weaps[r]["Item"]
				itm = CF_MakeItem(CF_ItmPresets[f][itmindex], CF_ItmClasses[f][itmindex], CF_ItmModules[f][itmindex])
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
