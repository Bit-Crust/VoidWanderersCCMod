-----------------------------------------------------------------------------------------
--	Objective: 	Destroy all clone vats
--	Set used: 	Zombies
--	Events:
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ZOMBIES CREATE")
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["VatsCount"] = 3
	setts[1]["MaxZombiesPerVat"] = 5

	setts[2] = {}
	setts[2]["VatsCount"] = 4
	setts[2]["MaxZombiesPerVat"] = 5

	setts[3] = {}
	setts[3]["VatsCount"] = 5
	setts[3]["MaxZombiesPerVat"] = 4

	setts[4] = {}
	setts[4]["VatsCount"] = 6
	setts[4]["MaxZombiesPerVat"] = 4

	setts[5] = {}
	setts[5]["VatsCount"] = 7
	setts[5]["MaxZombiesPerVat"] = 3

	setts[6] = {}
	setts[6]["VatsCount"] = 8
	setts[6]["MaxZombiesPerVat"] = 3

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time

	-- Select set
	local set = CF_GetRandomMissionPointsSet(self.Pts, "Zombies")

	-- Get LZs
	self.MissionVatsPos = CF_GetPointsArray(self.Pts, "Zombies", set, "Vat")
	if self.MissionSettings["VatsCount"] < 8 then
		self.MissionVatsPos = CF_SelectRandomPoints(self.MissionVatsPos, self.MissionSettings["VatsCount"])
	end

	self.MissionVats = {}

	-- Spawn vats
	for i = 1, self.MissionSettings["VatsCount"] do
		self.MissionVats[i] = CreateAEmitter("Zombie Generator")
		self.MissionVats[i].Pos = self.MissionVatsPos[i] + Vector(0, 46)
		self.MissionVats[i].Team = -1
		self.MissionVats[i]:EnableEmission(true)
		MovableMan:AddParticle(self.MissionVats[i])
	end

	-- Build random weapon lists
	local rifles = CF_MakeListOfMostPowerfulWeapons(
		self.GS,
		self.MissionSourcePlayer,
		CF_WeaponTypes.RIFLE,
		CF_GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF_MaxDifficulty)
	)
	local snipers = CF_MakeListOfMostPowerfulWeapons(
		self.GS,
		self.MissionSourcePlayer,
		CF_WeaponTypes.SNIPER,
		CF_GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF_MaxDifficulty)
	)
	local pistols = CF_MakeListOfMostPowerfulWeapons(
		self.GS,
		self.MissionSourcePlayer,
		CF_WeaponTypes.PISTOL,
		CF_GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF_MaxDifficulty)
	)
	local grenades = CF_MakeListOfMostPowerfulWeapons(
		self.GS,
		self.MissionSourcePlayer,
		CF_WeaponTypes.GRENADE,
		CF_GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF_MaxDifficulty)
	)
	--local heavies = CF_MakeListOfMostPowerfulWeapons(self.GS, self.MissionSourcePlayer, CF_WeaponTypes.HEAVY , CF_GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF_MaxDifficulty))

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

	--if #heavies > 0 then
	--	self.MissionWeapons[#self.MissionWeapons + 1] = heavies
	--end

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1 }
	self.MissionStage = self.MissionStages.ACTIVE
	self.MissionCompleteCountdownStart = 0
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		local vats = 0

		-- Count vats
		for i = 1, self.MissionSettings["VatsCount"] do
			if MovableMan:IsParticle(self.MissionVats[i]) then
				vats = vats + 1

				self:AddObjectivePoint(
					"DESTROY",
					self.MissionVatsPos[i] + Vector(0, -10),
					CF_PlayerTeam,
					GameActivity.ARROWDOWN
				)
			else
				self.MissionVats[i] = nil
			end
		end

		self.MissionStatus = "VATS: " .. vats

		-- Check wining conditions
		if vats == 0 then
			self:GiveMissionRewards()
			self.MissionStage = self.MissionStages.COMPLETED

			-- Remember when we started showing mission status message
			self.MissionStatusShowStart = self.Time
		end

		-- Control zombie population
		local zcount = 0
		for actor in MovableMan.Actors do
			if actor.Team == -1 and actor.ClassName == "AHuman" then
				zcount = zcount + 1

				-- Arm clones
				if
					actor.Age < TimerMan.DeltaTimeMS * 1.5
					and actor.EquippedItem == nil
					and actor:IsInventoryEmpty()
				then
					local r1 = math.random(#self.MissionWeapons)
					local r2 = math.random(#self.MissionWeapons[r1])

					local i = self.MissionWeapons[r1][r2]["Item"]
					local f = self.MissionWeapons[r1][r2]["Faction"]

					local w = CF_MakeItem(CF_ItmPresets[f][i], CF_ItmClasses[f][i], CF_ItmModules[f][i])
					if w ~= nil then
						actor:AddInventoryItem(w)
					end
				end
			end
		end

		if zcount < self.MissionSettings["MaxZombiesPerVat"] * vats and MovableMan:GetMOIDCount() < CF_MOIDLimit then
			for i = 1, self.MissionSettings["VatsCount"] do
				if MovableMan:IsParticle(self.MissionVats[i]) then
					if not self.MissionVats[i]:IsEmitting() then
						self.MissionVats[i]:EnableEmission(true)
					end
				end
			end
		else
			for i = 1, self.MissionSettings["VatsCount"] do
				if MovableMan:IsParticle(self.MissionVats[i]) then
					if self.MissionVats[i]:IsEmitting() then
						self.MissionVats[i]:EnableEmission(false)
					end
				end
			end
		end
	elseif self.MissionStage == self.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF_MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.MissionStatusShowStart + CF_MissionResultShowInterval then
			for p = 0, self.PlayerCount - 1 do
				FrameMan:ClearScreenText(p)
				FrameMan:SetScreenText(self.MissionStatus, p, 0, 1000, true)
			end
		end
	end
	--]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
