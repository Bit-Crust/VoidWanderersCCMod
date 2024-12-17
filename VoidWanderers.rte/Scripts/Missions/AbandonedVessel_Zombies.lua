-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL ZOMBIES CREATE")

	-- Spawn random wandering enemies
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

	local enm = CF.GetPointsArray(self.Pts, "Deploy", set, "AmbientEnemy")
	local amount = math.ceil(CF.AmbientEnemyRate / 2 * #enm)
	local enmpos = CF.RandomSampleOfList(enm, amount)

	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Deploy", set, "EnemyLZ")

	-- Select faction
	local ok = false

	while not ok do
		self.missionData["selectedFaction"] = CF.Factions[math.random(#CF.Factions)]
		if CF.FactionPlayable[self.missionData["selectedFaction"]] then
			ok = true
		end
	end

	self.missionData["fakePlayer"] = CF.MaxCPUPlayers + 1
	self.GS["Player" .. self.missionData["fakePlayer"] .. "Faction"] = self.missionData["selectedFaction"]

	local diff = CF.GetLocationDifficulty(self.GS, self.GS["Location"])
	self.missionData["difficulty"] = diff

	self.missionData["zombieRespawnInterval"] = 14 - self.missionData["difficulty"]
	self.missionData["zombieRespawnTime"] = self.Time
	self.missionData["zombieCount"] = math.random(15, 20) + self.missionData["difficulty"]
	self.missionData["artifactSpawned"] = false

	local rifles, snipers, pistols, grenades
	if PresetMan:GetModuleID("4Z.rte") ~= -1 then
		if self.missionData["difficulty"] < CF.MaxDifficulty * 0.5 then
			self.missionData["zombiePresetNames"] = { "4Zombie", "4Zombie", "4Zombie", "4Zombie Spitter", "4Zombie Bloater" }
		else
			self.missionData["zombiePresetNames"] = { "4Zombie", "4Zombie Spitter", "4Zombie Bloater", "4Zombie Mantis" }
		end
	else
		self.missionData["zombiePresetNames"] = { "Culled Clone", "Thin Culled Clone", "Fat Culled Clone" }
		-- Build random weapon lists
		rifles = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.missionData["fakePlayer"],
			CF.WeaponTypes.RIFLE,
			CF.GetTechLevelFromDifficulty(self.GS, self.missionData["fakePlayer"], self.missionData["difficulty"], CF.MaxDifficulty)
		)
		snipers = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.missionData["fakePlayer"],
			CF.WeaponTypes.SNIPER,
			CF.GetTechLevelFromDifficulty(self.GS, self.missionData["fakePlayer"], self.missionData["difficulty"], CF.MaxDifficulty)
		)
		pistols = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.missionData["fakePlayer"],
			CF.WeaponTypes.PISTOL,
			CF.GetTechLevelFromDifficulty(self.GS, self.missionData["fakePlayer"], self.missionData["difficulty"], CF.MaxDifficulty)
		)
		grenades = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.missionData["fakePlayer"],
			CF.WeaponTypes.GRENADE,
			CF.GetTechLevelFromDifficulty(self.GS, self.missionData["fakePlayer"], self.missionData["difficulty"], CF.MaxDifficulty)
		)
	end
	self.missionData["weaponPresetNames"] = {}

	if rifles ~= nil and #rifles > 0 then
		self.missionData["weaponPresetNames"][#self.missionData["weaponPresetNames"] + 1] = rifles
	end

	if snipers ~= nil and #snipers > 0 then
		self.missionData["weaponPresetNames"][#self.missionData["weaponPresetNames"] + 1] = sniper
	end

	if pistols ~= nil and #pistols > 0 then
		self.missionData["weaponPresetNames"][#self.missionData["weaponPresetNames"] + 1] = pistols
	end

	if grenades ~= nil and #grenades > 0 then
		self.missionData["weaponPresetNames"][#self.missionData["weaponPresetNames"] + 1] = grenades
	end

	-- Spawn some random zombies
	for i = 1, #enmpos do
		if #self.missionData["landingZones"] > 0 then
			local a = CreateAHuman(self.missionData["zombiePresetNames"][math.random(#self.missionData["zombiePresetNames"])])
			if a then
				a.Pos = enmpos[i]
				a.Team = Activity.TEAM_2

				if #self.missionData["weaponPresetNames"] ~= 0 then
					local r1 = math.random(#self.missionData["weaponPresetNames"])
					local r2 = math.random(#self.missionData["weaponPresetNames"][r1])

					local i = self.missionData["weaponPresetNames"][r1][r2]["Item"]
					local f = self.missionData["weaponPresetNames"][r1][r2]["Faction"]

					local w = CF.MakeItem(CF.ItmPresets[f][i], CF.ItmClasses[f][i], CF.ItmModules[f][i])
					if w ~= nil then
						a:AddInventoryItem(w)
					end
				end
				if
					not self.missionData["artifactSpawned"]
					and math.random() < self.missionData["difficulty"] / 100
				then
					a:AddInventoryItem(CF.CreateBlackPrint(self.GS))
					self.missionData["artifactSpawned"] = true
				end
				MovableMan:AddActor(a)
				CF.HuntForActors(a, Activity.NOTEAM)
			end
		end
	end
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" and math.random() < 0.50 then
			actor.GibSound = nil
			actor:GibThis()
		end
	end

	self:InitExplorationPoints()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()

	if self.missionData["zombieCount"] > 0
	and self.Time >= self.missionData["zombieRespawnTime"] then
		self.missionData["zombieRespawnTime"] = self.Time + self.missionData["zombieRespawnInterval"] + math.random(4)
		if #self.missionData["landingZones"] > 0 then
			local a = CreateAHuman(self.missionData["zombiePresetNames"][math.random(#self.missionData["zombiePresetNames"])])
			if a then
				a.Pos = self.missionData["landingZones"][math.random(#self.missionData["landingZones"])]
				a.Team = Activity.TEAM_2

				if #self.missionData["weaponPresetNames"] ~= 0 then
					local r1 = math.random(#self.missionData["weaponPresetNames"])
					local r2 = math.random(#self.missionData["weaponPresetNames"][r1])

					local i = self.missionData["weaponPresetNames"][r1][r2]["Item"]
					local f = self.missionData["weaponPresetNames"][r1][r2]["Faction"]

					local w = CF.MakeItem(CF.ItmPresets[f][i], CF.ItmClasses[f][i], CF.ItmModules[f][i])
					if w ~= nil then
						a:AddInventoryItem(w)
					end
				end
				if
					not self.missionData["artifactSpawned"]
					and math.random() < self.missionData["difficulty"] / 200
				then
					a:AddInventoryItem(CF.CreateBlackPrint(self.GS))
					self.missionData["artifactSpawned"] = true
				end
				MovableMan:AddActor(a)
				CF.HuntForActors(a, CF.PlayerTeam)
				self.missionData["zombieCount"] = self.missionData["zombieCount"] - 1
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
