-----------------------------------------------------------------------------------------
--	Objective: 	Kill all invading troops.
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("FACTION AMBUSH CREATE")

	-- Select random assault CPU based on how angry they are
	local angry = {}
	local anger = {}

	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		local rep = tonumber(self.GS["Player" .. i .. "Reputation"])
		if rep <= CF.ReputationHuntThreshold then
			angry[#angry + 1] = i
			anger[#anger + 1] = math.min(CF.MaxDifficulty, math.max(1, math.floor(-rep / CF.ReputationPerDifficulty)))
		end
	end

	if #angry > 0 then
		local antagonist = CF.WeightedSelection(anger)

		self.encounterData["ambushAssailant"] = angry[antagonist]
		self.encounterData["ambushDifficulty"] = anger[antagonist]
	end
	
	self.AssaultTime = self.Time + CF.ShipAssaultDelay
	self.AssaultEnemiesToSpawn = CF.AssaultDifficultyUnitCount[self.AssaultDifficulty]
	self.AssaultNextSpawnTime = self.AssaultTime + CF.AssaultDifficultySpawnInterval[self.AssaultDifficulty] + 1
	self.AssaultNextSpawnPos = self.AssaultSpawn and self.AssaultSpawn:GetRandomPoint()
		or self.EnemySpawn[math.random(#self.EnemySpawn)]
	self.AssaultWarningTime = 6 - math.floor(self.AssaultDifficulty * 0.5 + 0.5)

	-- Create attacker's unit presets
	CF.CreateAIUnitPresets(
		self.GS,
		self.AssaultEnemyPlayer,
		CF.GetTechLevelFromDifficulty(self.GS, self.AssaultEnemyPlayer, self.AssaultDifficulty, CF.MaxDifficulty)
	)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local count = 0
		
		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				local inside = false

				for i = 1, #self.missionData["missionBase"] do
					if self.missionData["missionBase"][i]:IsWithinBox(actor.Pos) then
						--actor:FlashWhite(250)
						count = count + 1
						inside = true
						break
					end
				end
				
				if inside and SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam) and self.Time % 4 == 0 then
					self:AddObjectivePoint("KILL", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
				end

				if not self.missionData["reinforcementsTriggered"] then
					if actor.Health > 0 and math.random(100) > actor.Health then
						self.missionData["reinforcementsTriggered"] = true

						self.missionData["reinforcementsLast"] = self.Time
					end
				end
			end
		end

		self.missionData["missionStatus"] = "Enemies left: " .. tostring(count)

		-- Start checking for victory only when all units were spawned
		if self.SpawnTable == nil and count == 0 and not MovableMan.AddedActors() then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED

			-- Remember when we started showing misison status message
			self.missionData["statusShowStart"] = self.Time
			self.missionData["missionEndTime"] = self.Time
		end

		-- Send reinforcements if available
		if
			self.missionData["reinforcementsTriggered"]
			and self.Time >= self.missionData["reinforcementsLast"] + self.missionData["interval"]
		then
			self.missionData["reinforcementsLast"] = self.Time
			if
				#self.missionData["landingZones"] > 0
				and self.missionData["reinforcements"] > 0
				and MovableMan:GetMOIDCount() < CF.MOIDLimit
			then
				self.missionData["reinforcements"] = self.missionData["reinforcements"] - 1

				local count = math.random(2)
				local f = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])
				local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
				if ship then
					for i = 1, count do
						local actor = CF.SpawnAIUnit(self.GS, self.missionData["missionTarget"], CF.CPUTeam, nil, nil)
						if actor then
							ship:AddInventoryItem(actor)
						end
					end
					ship.Team = CF.CPUTeam
					ship.Pos = Vector(self.missionData["landingZones"][math.random(#self.missionData["landingZones"])].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
				end
			end
		end

		-- Trigger 'counterattack', send every third actor to attack player troops
		if
			not self.missionData["counterAttackTriggered"]
			and self.missionData["counterAttackDelay"] > 0
			and self.Time >= self.missionData["missionStartTime"] + self.missionData["counterAttackDelay"]
		then
			self.missionData["counterAttackTriggered"] = true
			self:StartMusic(CF.MusicTypes.MISSION_INTENSE)

			local count = 0

			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam then
					count = count + 1

					if count % 3 == 0 then
						CF.HuntForActors(actor, CF.PlayerTeam)
					end
				end
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end
		self.missionData["missionStatus"] = "MISSION COMPLETED"

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end
	end --]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------