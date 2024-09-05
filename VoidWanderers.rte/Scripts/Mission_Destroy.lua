-----------------------------------------------------------------------------------------
--	Objective: 	Destroy all clone vats
--	Set used: 	Deploy, Zombies
--	Events: 	AI might call in reinforcemtnes. If AI device is damaged then all nearby units are switched in
--				brainhunt mode
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("DESTROY " .. (isNewGame == false and "LOAD" or "CREATE"))
	self.missionData = {}

	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		-- Mission difficulty settings
		local setts

		setts = {}
		setts[1] = {}
		setts[1]["deviceCount"] = 3
		setts[1]["spawnRate"] = 0.50
		setts[1]["reinforcements"] = 0
		setts[1]["interval"] = 0

		setts[2] = {}
		setts[2]["deviceCount"] = 4
		setts[2]["spawnRate"] = 0.60
		setts[2]["reinforcements"] = 0
		setts[2]["interval"] = 0

		setts[3] = {}
		setts[3]["deviceCount"] = 5
		setts[3]["spawnRate"] = 0.70
		setts[3]["reinforcements"] = 0
		setts[3]["interval"] = 0

		setts[4] = {}
		setts[4]["deviceCount"] = 6
		setts[4]["spawnRate"] = 0.80
		setts[4]["reinforcements"] = 1
		setts[4]["interval"] = 30

		setts[5] = {}
		setts[5]["deviceCount"] = 7
		setts[5]["spawnRate"] = 0.90
		setts[5]["reinforcements"] = 2
		setts[5]["interval"] = 30

		setts[6] = {}
		setts[6]["deviceCount"] = 8
		setts[6]["spawnRate"] = 1
		setts[6]["reinforcements"] = 3
		setts[6]["interval"] = 30

		self.missionData = setts[self.MissionDifficulty]
		self.missionData["missionStartTime"] = self.Time

		-- Spawn enemies
		local enmset = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")
		local enm = CF.GetPointsArray(self.Pts, "Deploy", enmset, "AmbientEnemy")
		local enmpos = CF.RandomSampleOfList(enm, math.floor(self.missionData["spawnRate"] * #enm))
		self.missionData["enemyLandingZones"] = CF.GetPointsArray(self.Pts, "Deploy", enmset, "EnemyLZ")

		for i = 1, #enmpos do
			local pre = math.random(CF.PresetTypes.ENGINEER)
			local nw = {}
			nw["Preset"] = pre
			nw["Team"] = CF.CPUTeam
			nw["Player"] = self.MissionTargetPlayer
			nw["AIMode"] = Actor.AIMODE_SENTRY
			nw["Pos"] = enmpos[i]

			table.insert(self.SpawnTable, nw)
		end

		local amount = math.ceil(CF.AmbientEnemyRate * #enm)
		--print ("Crates: "..amount)
		local enmpos = CF.RandomSampleOfList(enm, amount)

		-- Select set
		local set = CF.GetRandomMissionPointsSet(self.Pts, "Zombies")

		-- Get LZs
		local missionDevicePos = CF.GetPointsArray(self.Pts, "Zombies", set, "Vat")
		if self.missionData["deviceCount"] < 8 then
			missionDevicePos = CF.RandomSampleOfList(missionDevicePos, self.missionData["deviceCount"])
		end

		self.missionData["devices"] = {}
		self.missionData["alertsTrigged"] = {}

		-- Spawn vats
		for i = 1, self.missionData["deviceCount"] do
			--self.missionData["devices"][i] = CreateActor("Factory Actor", self.ModuleName)
			--self.missionData["devices"][i].Pos = missionDevicePos[i] + Vector(0,42)
			self.missionData["devices"][i] = CreateActor("Computer Actor", self.ModuleName)
			self.missionData["devices"][i].Pos = missionDevicePos[i] + Vector(0, 30)
			self.missionData["devices"][i].Team = CF.CPUTeam
			MovableMan:AddActor(self.missionData["devices"][i])
			self.missionData["alertsTrigged"][i] = false
		end

		self.missionData["stage"] = CF.MissionStages.ACTIVE
		self.missionData["reinforcementsTriggered"] = false
		self.missionData["reinforcementsLast"] = 0

		self.missionData["alertRange"] = 450
		self.missionData["alertTriggered"] = false
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local vats = 0

		-- Count vats
		for i = 1, self.missionData["deviceCount"] do
			if MovableMan:IsActor(self.missionData["devices"][i]) then
				vats = vats + 1

				if not SceneMan:IsUnseen(self.missionData["devices"][i].Pos.X, self.missionData["devices"][i].Pos.Y, CF.PlayerTeam) then
					self:AddObjectivePoint(
						"DESTROY",
						self.missionData["devices"][i].Pos + Vector(0, -10),
						CF.PlayerTeam,
						GameActivity.ARROWDOWN
					)
				end

				if self.missionData["devices"][i].Health < 100 and self.missionData["alertsTrigged"][i] == false then
					self.missionData["alertsTrigged"][i] = true
					if not self.missionData["reinforcementsTriggered"] then
						self.missionData["reinforcementsTriggered"] = true
						self.missionData["reinforcementsLast"] = self.Time
					end

					for actor in MovableMan.Actors do
						if
							actor.Team == CF.CPUTeam
							and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
							and CF.DistUnder(self.missionData["devices"][i].Pos, actor.Pos, self.missionData["alertRange"])
						then
							CF.HuntForActors(actor, CF.PlayerTeam)
						end
					end
				end
			else
				self.missionData["devices"][i] = nil
			end
		end

		if self.missionData["alertTriggered"] == false and vats == 1 then
			self.missionData["alertTriggered"] = true

			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
					CF.HuntForActors(actor)
				end
			end
		end

		self.MissionStatus = "DEVICES: " .. vats

		if
			self.missionData["reinforcementsTriggered"]
			and #self.missionData["enemyLandingZones"] > 0
			and self.missionData["reinforcements"] > 0
			and self.Time >= self.missionData["reinforcementsLast"] + self.missionData["interval"]
		then
			if MovableMan:GetMOIDCount() < CF.MOIDLimit then
				self.missionData["reinforcementsLast"] = self.Time
				self.missionData["reinforcements"] = self.missionData["reinforcements"] - 1

				local count = 3
				local f = CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)
				local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
				if ship then
					for i = 1, count do
						local actor = CF.SpawnAIUnit(self.GS, self.MissionTargetPlayer, CF.CPUTeam, nil, nil)
						if actor then
							ship:AddInventoryItem(actor)
						end
					end
					ship.Team = CF.CPUTeam
					ship.Pos = Vector(self.missionData["enemyLandingZones"][math.random(#self.missionData["enemyLandingZones"])].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
				end
			end
		end

		-- Check wining conditions
		if vats == 0 then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED

			-- Remember when we started showing misison status messageaaa
			self.missionData["statusShowStart"] = self.Time
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
	--]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
