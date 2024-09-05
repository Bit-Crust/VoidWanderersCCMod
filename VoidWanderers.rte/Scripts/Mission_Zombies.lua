-----------------------------------------------------------------------------------------
--	Objective: 	Destroy all clone vats
--	Set used: 	Zombies
--	Events:
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("ZOMBIES " .. (isNewGame == false and "LOAD" or "CREATE"))
	self.missionData = {}

	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		-- Mission difficulty settings
		local setts

		setts = {}
		setts[1] = {}
		setts[1]["vatsCount"] = 3
		setts[1]["maxZombiesPerVat"] = 5

		setts[2] = {}
		setts[2]["vatsCount"] = 4
		setts[2]["maxZombiesPerVat"] = 5

		setts[3] = {}
		setts[3]["vatsCount"] = 5
		setts[3]["maxZombiesPerVat"] = 4

		setts[4] = {}
		setts[4]["vatsCount"] = 6
		setts[4]["maxZombiesPerVat"] = 4

		setts[5] = {}
		setts[5]["vatsCount"] = 7
		setts[5]["maxZombiesPerVat"] = 3

		setts[6] = {}
		setts[6]["vatsCount"] = 8
		setts[6]["maxZombiesPerVat"] = 3

		self.missionData = setts[self.MissionDifficulty]
		self.missionData["missionStartTime"] = self.Time

		-- Select set
		local set = CF.GetRandomMissionPointsSet(self.Pts, "Zombies")

		-- Get LZs
		local missionVatsPos = CF.GetPointsArray(self.Pts, "Zombies", set, "Vat")
		missionVatsPos = CF.RandomSampleOfList(missionVatsPos, self.missionData["vatsCount"])

		self.missionData["vats"] = {}

		-- Spawn vats
		for i = 1, self.missionData["vatsCount"] do
			self.missionData["vats"][i] = CreateAEmitter("Zombie Generator")
			self.missionData["vats"][i].Pos = missionVatsPos[i] + Vector(0, 46)
			self.missionData["vats"][i].Team = -1
			self.missionData["vats"][i]:EnableEmission(true)
			MovableMan:AddParticle(self.missionData["vats"][i])
		end

		-- Build random weapon lists
		local rifles = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionSourcePlayer,
			CF.WeaponTypes.RIFLE,
			CF.GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF.MaxDifficulty)
		)
		local snipers = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionSourcePlayer,
			CF.WeaponTypes.SNIPER,
			CF.GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF.MaxDifficulty)
		)
		local pistols = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionSourcePlayer,
			CF.WeaponTypes.PISTOL,
			CF.GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF.MaxDifficulty)
		)
		local grenades = CF.MakeListOfMostPowerfulWeapons(
			self.GS,
			self.MissionSourcePlayer,
			CF.WeaponTypes.GRENADE,
			CF.GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF.MaxDifficulty)
		)
		--local heavies = CF.MakeListOfMostPowerfulWeapons(self.GS, self.MissionSourcePlayer, CF.WeaponTypes.HEAVY , CF.GetTechLevelFromDifficulty(self.GS, self.MissionSourcePlayer, self.MissionDifficulty, CF.MaxDifficulty))

		self.missionData["weapons"] = {}

		if rifles ~= nil and #rifles > 0 then
			self.missionData["weapons"][#self.missionData["weapons"] + 1] = rifles
		end

		if snipers ~= nil and #snipers > 0 then
			self.missionData["weapons"][#self.missionData["weapons"] + 1] = sniper
		end

		if pistols ~= nil and #pistols > 0 then
			self.missionData["weapons"][#self.missionData["weapons"] + 1] = pistols
		end

		if grenades ~= nil and #grenades > 0 then
			self.missionData["weapons"][#self.missionData["weapons"] + 1] = grenades
		end

		--if #heavies > 0 then
		--	self.missionData["weapons"][#self.missionData["weapons"] + 1] = heavies
		--end

		self.missionData["stage"] = CF.MissionStages.ACTIVE
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local vats = 0

		-- Count vats
		for i = 1, self.missionData["vatsCount"] do
			if MovableMan:IsParticle(self.missionData["vats"][i]) then
				vats = vats + 1

				self:AddObjectivePoint(
					"DESTROY",
					self.missionData["vats"][i].Pos + Vector(0, -10),
					CF.PlayerTeam,
					GameActivity.ARROWDOWN
				)
			else
				self.missionData["vats"][i] = nil
			end
		end

		self.MissionStatus = "VATS: " .. vats

		-- Check wining conditions
		if vats == 0 then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED

			-- Remember when we started showing mission status message
			self.missionData["statusShowStart"] = self.Time
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
					local r1 = math.random(#self.missionData["weapons"])
					local r2 = math.random(#self.missionData["weapons"][r1])

					local i = self.missionData["weapons"][r1][r2]["Item"]
					local f = self.missionData["weapons"][r1][r2]["Faction"]

					local w = CF.MakeItem(CF.ItmPresets[f][i], CF.ItmClasses[f][i], CF.ItmModules[f][i])
					if w ~= nil then
						actor:AddInventoryItem(w)
					end
				end
			end
		end

		if zcount < self.missionData["maxZombiesPerVat"] * vats then
			for i = 1, self.missionData["vatsCount"] do
				if IsAEmitter(self.missionData["vats"][i]) then
					local vat = ToAEmitter(self.missionData["vats"][i])
					if not vat:IsEmitting() then
						vat:EnableEmission(true)
					end
				end
			end
		else
			for i = 1, self.missionData["vatsCount"] do
				if IsAEmitter(self.missionData["vats"][i]) then
					local vat = ToAEmitter(self.missionData["vats"][i])
					if vat:IsEmitting() then
						vat:EnableEmission(false)
					end
				end
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
