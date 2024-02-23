-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL ZOMBIES CREATE")

	-- Spawn random wandering enemies
	local set = CF_GetRandomMissionPointsSet(self.Pts, "Deploy")

	local enm = CF_GetPointsArray(self.Pts, "Deploy", set, "AmbientEnemy")
	local amount = math.ceil(CF_AmbientEnemyRate / 2 * #enm)
	local enmpos = CF_SelectRandomPoints(enm, amount)

	self.MissionLZs = CF_GetPointsArray(self.Pts, "Deploy", set, "EnemyLZ")

	-- Select faction
	local ok = false

	while not ok do
		self.MissionSelectedFaction = CF_Factions[math.random(#CF_Factions)]
		if CF_FactionPlayable[self.MissionSelectedFaction] then
			ok = true
		end
	end

	self.MissionFakePlayer = CF_MaxCPUPlayers + 1
	self.GS["Player" .. self.MissionFakePlayer .. "Faction"] = self.MissionSelectedFaction

	local diff = CF_GetLocationDifficulty(self.GS, self.GS["Location"])
	self.MissionDifficulty = diff

	self.MissionZombieRespawnInterval = 14 - self.MissionDifficulty
	self.MissionZombieRespawnTime = self.Time
	self.MissionZombieCount = math.random(15, 20) + self.MissionDifficulty
	self.MissionArtifactSpawned = false --math.random(CF_MaxDifficulty) > self.MissionDifficulty

	local rifles, snipers, pistols, grenades
	if PresetMan:GetModuleID("4Z.rte") ~= -1 then
		if self.MissionDifficulty < CF_MaxDifficulty * 0.5 then
			self.Zombies = { "4Zombie", "4Zombie", "4Zombie", "4Zombie Spitter", "4Zombie Bloater" }
		else
			self.Zombies = { "4Zombie", "4Zombie Spitter", "4Zombie Bloater", "4Zombie Mantis" }
		end
	else
		self.Zombies = { "Culled Clone", "Thin Culled Clone", "Fat Culled Clone" }
		-- Build random weapon lists
		rifles = CF_MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionFakePlayer,
			CF_WeaponTypes.RIFLE,
			CF_GetTechLevelFromDifficulty(self.GS, self.MissionFakePlayer, self.MissionDifficulty, CF_MaxDifficulty)
		)
		snipers = CF_MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionFakePlayer,
			CF_WeaponTypes.SNIPER,
			CF_GetTechLevelFromDifficulty(self.GS, self.MissionFakePlayer, self.MissionDifficulty, CF_MaxDifficulty)
		)
		pistols = CF_MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionFakePlayer,
			CF_WeaponTypes.PISTOL,
			CF_GetTechLevelFromDifficulty(self.GS, self.MissionFakePlayer, self.MissionDifficulty, CF_MaxDifficulty)
		)
		grenades = CF_MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionFakePlayer,
			CF_WeaponTypes.GRENADE,
			CF_GetTechLevelFromDifficulty(self.GS, self.MissionFakePlayer, self.MissionDifficulty, CF_MaxDifficulty)
		)
	end
	self.MissionWeapons = {}

	if rifles ~= nil and #rifles > 0 then
		self.MissionWeapons[#self.MissionWeapons + 1] = rifles
	end

	if snipers ~= nil and #snipers > 0 then
		self.MissionWeapons[#self.MissionWeapons + 1] = sniper
	end

	if pistols ~= nil and #pistols > 0 then
		self.MissionWeapons[#self.MissionWeapons + 1] = pistols
	end

	if grenades ~= nil and #grenades > 0 then
		self.MissionWeapons[#self.MissionWeapons + 1] = grenades
	end

	if math.random() < 0.5 then
		self.AGS = nil
		self.MissionArtifactSpawned = false
	end

	-- Spawn some random zombies
	for i = 1, #enmpos do
		if MovableMan:GetMOIDCount() < CF_MOIDLimit and #self.MissionLZs > 0 then
			local a = CreateAHuman(self.Zombies[math.random(#self.Zombies)])
			if a then
				a.Pos = enmpos[i]
				a.Team = Activity.TEAM_2

				if #self.MissionWeapons ~= 0 then
					local r1 = math.random(#self.MissionWeapons)
					local r2 = math.random(#self.MissionWeapons[r1])

					local i = self.MissionWeapons[r1][r2]["Item"]
					local f = self.MissionWeapons[r1][r2]["Faction"]

					local w = CF_MakeItem(CF_ItmPresets[f][i], CF_ItmClasses[f][i], CF_ItmModules[f][i])
					if w ~= nil then
						a:AddInventoryItem(w)
					end
				end
				if
					not self.MissionArtifactSpawned
					and math.random() < (self.AGS == nil and 0.02 or 0.01) * self.MissionDifficulty
				then
					a:AddInventoryItem(CreateHeldDevice("Blackprint", CF_ModuleName))
					self.MissionArtifactSpawned = true
				end
				MovableMan:AddActor(a)
				CF_HuntForActors(a, Activity.NOTEAM)
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

	self.MissionStart = self.Time
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()

	if self.MissionZombieCount > 0 and self.Time >= self.MissionZombieRespawnTime then
		self.MissionZombieRespawnTime = self.Time + self.MissionZombieRespawnInterval + math.random(4)
		if MovableMan:GetMOIDCount() < CF_MOIDLimit and #self.MissionLZs > 0 then
			local a = CreateAHuman(self.Zombies[math.random(#self.Zombies)])
			if a then
				a.Pos = self.MissionLZs[math.random(#self.MissionLZs)]
				a.Team = Activity.TEAM_2

				if #self.MissionWeapons ~= 0 then
					local r1 = math.random(#self.MissionWeapons)
					local r2 = math.random(#self.MissionWeapons[r1])

					local i = self.MissionWeapons[r1][r2]["Item"]
					local f = self.MissionWeapons[r1][r2]["Faction"]

					local w = CF_MakeItem(CF_ItmPresets[f][i], CF_ItmClasses[f][i], CF_ItmModules[f][i])
					if w ~= nil then
						a:AddInventoryItem(w)
					end
				end
				if
					not self.MissionArtifactSpawned
					and math.random() < (self.AGS == nil and 0.01 or 0.005) * self.MissionDifficulty
				then
					a:AddInventoryItem(CreateHeldDevice("Blackprint", CF_ModuleName))
					self.MissionArtifactSpawned = true
				end
				MovableMan:AddActor(a)
				CF_HuntForActors(a, CF_PlayerTeam)
				self.MissionZombieCount = self.MissionZombieCount - 1
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
