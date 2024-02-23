-----------------------------------------------------------------------------------------
--	Objective: 	Kill all CF_CPUTeam enemies inside the Enemy::Base box set
--	Set used: 	Enemy
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["SpawnRate"] = 0.20
	setts[1]["Reinforcements"] = 0
	setts[1]["Interval"] = 10
	setts[1]["CounterAttackDelay"] = 0

	setts[2] = {}
	setts[2]["SpawnRate"] = 0.35
	setts[2]["Reinforcements"] = 0
	setts[2]["Interval"] = 10
	setts[2]["CounterAttackDelay"] = 0

	setts[3] = {}
	setts[3]["SpawnRate"] = 0.50
	setts[3]["Reinforcements"] = 1
	setts[3]["Interval"] = 20
	setts[3]["CounterAttackDelay"] = 300

	setts[4] = {}
	setts[4]["SpawnRate"] = 0.65
	setts[4]["Reinforcements"] = 2
	setts[4]["Interval"] = 26
	setts[4]["CounterAttackDelay"] = 260

	setts[5] = {}
	setts[5]["SpawnRate"] = 0.80
	setts[5]["Reinforcements"] = 3
	setts[5]["Interval"] = 24
	setts[5]["CounterAttackDelay"] = 220

	setts[6] = {}
	setts[6]["SpawnRate"] = 0.90
	setts[6]["Reinforcements"] = 4
	setts[6]["Interval"] = 22
	setts[6]["CounterAttackDelay"] = 180

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time

	-- Use generic enemy set
	local set = CF_GetRandomMissionPointsSet(self.Pts, "Enemy")

	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.MissionTargetPlayer,
		CF_CPUTeam,
		self.MissionSettings["SpawnRate"]
	)
	self:DeployInfantryMines(
		CF_CPUTeam,
		math.min(
			-tonumber(self.GS["Player" .. self.MissionTargetPlayer .. "Reputation"])
				/ (CF_MaxDifficulty * CF_ReputationPerDifficulty),
			1
		) - 0.75
	)

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1 }
	self.MissionStage = self.MissionStages.ACTIVE

	self.MissionReinforcementsTriggered = false
	self.CounterAttackTriggered = false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		self.MissionFailed = true
		local count = 0

		for actor in MovableMan.Actors do
			if actor.Team == CF_CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				local inside = false

				for i = 1, #self.MissionBase do
					if self.MissionBase[i]:IsWithinBox(actor.Pos) then
						--actor:FlashWhite(250)
						count = count + 1
						inside = true
						break
					end
				end

				if inside and SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF_PlayerTeam) and self.Time % 4 == 1 then
					self:AddObjectivePoint("KILL", actor.AboveHUDPos, CF_PlayerTeam, GameActivity.ARROWDOWN)
				end

				if self.MissionReinforcementsTriggered then
					if self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"] then
						--	actor:RemoveInventoryItem("Blueprint")
					end
				else
					if actor.Health > 0 and math.random(100) > actor.Health then
						self.MissionReinforcementsTriggered = true

						self.MissionLastReinforcements = self.Time
					end
				end
			end
		end

		self.MissionStatus = "Enemies left: " .. tostring(count)

		-- Start checking for victory only when all units were spawned
		if self.SpawnTable == nil and count == 0 then
			self:GiveMissionRewards()
			self.MissionStage = self.MissionStages.COMPLETED

			-- Remember when we started showing misison status message
			self.MissionStatusShowStart = self.Time
		end

		-- Send reinforcements if available
		if
			self.MissionReinforcementsTriggered
			and self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"]
		then
			self.MissionLastReinforcements = self.Time
			if
				#self.MissionLZs > 0
				and self.MissionSettings["Reinforcements"] > 0
				and MovableMan:GetMOIDCount() < CF_MOIDLimit
			then
				self.MissionSettings["Reinforcements"] = self.MissionSettings["Reinforcements"] - 1

				local count = math.random(2)
				local f = CF_GetPlayerFaction(self.GS, self.MissionTargetPlayer)
				local ship = CF_MakeActor(CF_Crafts[f], CF_CraftClasses[f], CF_CraftModules[f])
				if ship then
					for i = 1, count do
						local actor = CF_SpawnAIUnit(self.GS, self.MissionTargetPlayer, CF_CPUTeam, nil, nil)
						if actor then
							ship:AddInventoryItem(actor)
						end
					end
					ship.Team = CF_CPUTeam
					ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
				end
			end
		end

		-- Trigger 'counterattack', send every second actor to attack player troops
		if
			not self.CounterAttackTriggered
			and self.MissionSettings["CounterAttackDelay"] > 0
			and self.Time >= self.MissionStart + self.MissionSettings["CounterAttackDelay"]
		then
			self.CounterAttackTriggered = true
			print("COUNTERATTACK!")
			self:StartMusic(CF_MusicTypes.MISSION_INTENSE)

			local count = 0

			for actor in MovableMan.Actors do
				if actor.Team == CF_CPUTeam then
					count = count + 1

					if count % 3 == 0 then
						CF_HuntForActors(actor, CF_PlayerTeam)
					end
				end
			end
		end
	elseif self.MissionStage == self.MissionStages.COMPLETED then
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF_MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end
		self.MissionStatus = "MISSION COMPLETED"

		if self.Time < self.MissionStatusShowStart + CF_MissionResultShowInterval then
			for p = 0, self.PlayerCount - 1 do
				FrameMan:ClearScreenText(p)
				FrameMan:SetScreenText(self.MissionStatus, p, 0, 1000, true)
			end
		end
	end --]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
