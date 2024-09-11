-----------------------------------------------------------------------------------------
--	Objective: 	Kill all CF.CPUTeam enemies inside the Enemy::Base box set
--	Set used: 	Enemy
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("ASSAULT CREATE")
	
	-- Mission difficulty settings
	local diff = self.missionData["difficulty"]

	if diff == 1 then
		self.missionData["spawnRate"] = 0.20
		self.missionData["reinforcements"] = 0
		self.missionData["interval"] = 10
		self.missionData["counterAttackDelay"] = 0
	elseif diff == 2 then
		self.missionData["spawnRate"] = 0.35
		self.missionData["reinforcements"] = 0
		self.missionData["interval"] = 10
		self.missionData["counterAttackDelay"] = 0
	elseif diff == 3 then
		self.missionData["spawnRate"] = 0.50
		self.missionData["reinforcements"] = 1
		self.missionData["interval"] = 20
		self.missionData["counterAttackDelay"] = 300
	elseif diff == 4 then
		self.missionData["spawnRate"] = 0.65
		self.missionData["reinforcements"] = 2
		self.missionData["interval"] = 26
		self.missionData["counterAttackDelay"] = 260
	elseif diff == 5 then
		self.missionData["spawnRate"] = 0.80
		self.missionData["reinforcements"] = 3
		self.missionData["interval"] = 24
		self.missionData["counterAttackDelay"] = 220
	elseif diff == 6 then
		self.missionData["spawnRate"] = 0.90
		self.missionData["reinforcements"] = 4
		self.missionData["interval"] = 22
		self.missionData["counterAttackDelay"] = 180
	end

	-- Use generic enemy set
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")
	
	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.missionData["missionTarget"],
		CF.CPUTeam,
		self.missionData["spawnRate"]
	)
	-- Get LZs
	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Enemy", set, "LZ")
	-- Get base
	self:ObtainBaseBoxes("Enemy", set)
	-- Deploy mines
	self:DeployInfantryMines(
		CF.CPUTeam,
		math.min(
			-tonumber(self.GS["Player" .. self.missionData["missionTarget"] .. "Reputation"])
				/ (CF.MaxDifficulty * CF.ReputationPerDifficulty),
			1
		) - 0.75
	)
	
	self.missionData["craft"] = nil
	self.missionData["craftCheckTime"] = self.Time

	self.missionData["reinforcementsTriggered"] = false
	self.missionData["reinforcementsLast"] = 0
	self.missionData["counterAttackTriggered"] = false
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
