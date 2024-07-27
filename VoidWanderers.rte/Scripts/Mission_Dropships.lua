-----------------------------------------------------------------------------------------
--	Objective: 	Kill all enemy miners and shoot down all incoming dropships
--	Set used: 	Enemy
--	Events: 	After a while AI will send some dropships to replace dead miners
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("DROPSHIPS CREATE")
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["SpawnRate"] = 0.20
	setts[1]["EnemyDropShips"] = 2
	setts[1]["Interval"] = 26
	setts[1]["EnemyBudget"] = 1000
	setts[1]["TargetGold"] = 5000

	setts[2] = {}
	setts[2]["SpawnRate"] = 0.40
	setts[2]["EnemyDropShips"] = 3
	setts[2]["Interval"] = 26
	setts[2]["EnemyBudget"] = 1500
	setts[2]["TargetGold"] = 5500

	setts[3] = {}
	setts[3]["SpawnRate"] = 0.60
	setts[3]["EnemyDropShips"] = 4
	setts[3]["Interval"] = 26
	setts[3]["EnemyBudget"] = 2000
	setts[3]["TargetGold"] = 6000

	setts[4] = {}
	setts[4]["SpawnRate"] = 0.80
	setts[4]["EnemyDropShips"] = 5
	setts[4]["Interval"] = 24
	setts[4]["EnemyBudget"] = 2500
	setts[4]["TargetGold"] = 6500

	setts[5] = {}
	setts[5]["SpawnRate"] = 1
	setts[5]["EnemyDropShips"] = 5
	setts[5]["Interval"] = 24
	setts[5]["EnemyBudget"] = 3000
	setts[5]["TargetGold"] = 7000

	setts[6] = {}
	setts[6]["SpawnRate"] = 1
	setts[6]["EnemyDropShips"] = 6
	setts[6]["Interval"] = 22
	setts[6]["EnemyBudget"] = 3500
	setts[6]["TargetGold"] = 7500

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time
	self.MissionLastReinforcements = self.Time + self.MissionSettings["Interval"] * 3
	self.MissionNextWarningGold = self.MissionSettings["EnemyBudget"]
		+ (self.MissionSettings["TargetGold"] - self.MissionSettings["EnemyBudget"]) * 0.20
	self.MissionLastFailWarning = 0

	self:SetTeamFunds(self.MissionSettings["EnemyBudget"], CF_CPUTeam)

	-- Use generic enemy set
	local set = CF_GetRandomMissionPointsSet(self.Pts, "Mine")

	-- Get LZs
	self.MissionLZs = CF_GetPointsArray(self.Pts, "Mine", set, "MinerLZ")

	--print (#self.MissionLZs)

	local count

	-- Get miner locations
	local miners = CF_GetPointsArray(self.Pts, "Mine", set, "Miners")
	count = math.ceil(#miners * self.MissionSettings["SpawnRate"])
	if count < 0 then
		count = 1
	end
	miners = CF_SelectRandomPoints(miners, count)

	-- Get security locations
	local security = CF_GetPointsArray(self.Pts, "Mine", set, "MinerSentries")
	count = math.ceil(#security * self.MissionSettings["SpawnRate"])
	if count < 0 then
		count = 1
	end
	security = CF_SelectRandomPoints(security, count)

	-- Spawn miners with double rate
	for i = 1, #miners do
		local nw = {}
		nw["Preset"] = CF_PresetTypes.ENGINEER
		nw["Team"] = CF_CPUTeam
		nw["Player"] = self.MissionTargetPlayer
		nw["AIMode"] = Actor.AIMODE_GOLDDIG
		nw["Pos"] = miners[i]

		table.insert(self.SpawnTable, nw)
	end

	-- Spawn security
	for i = 1, #security do
		local nw = {}
		nw["Preset"] = math.random(CF_PresetTypes.HEAVY2)
		nw["Team"] = CF_CPUTeam
		nw["Player"] = self.MissionTargetPlayer
		nw["AIMode"] = Actor.AIMODE_SENTRY
		nw["Pos"] = security[i]

		table.insert(self.SpawnTable, nw)
	end

	-- Spawn a few snipers finally
	local snipers = CF_GetPointsArray(self.Pts, "Enemy", set, "Sniper")
	for i = 1, #snipers do
		if math.random() < self.MissionSettings["SpawnRate"] / 3 then
			local nw = {}
			nw["Preset"] = CF_PresetTypes.SNIPER
			nw["Team"] = CF_CPUTeam
			nw["Player"] = self.MissionTargetPlayer
			nw["AIMode"] = Actor.AIMODE_SENTRY
			nw["Pos"] = snipers[i]

			table.insert(self.SpawnTable, nw)
		end
	end

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1, FAILED = 2 }
	self.MissionStage = self.MissionStages.ACTIVE
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		self.MissionFailed = true
		local minerCount = 0
		local shipCount = 0
		local enemyFunds = self:GetTeamFunds(CF_CPUTeam)

		if enemyFunds > 0 then
			-- Show gold warnings from time to time
			if enemyFunds > self.MissionNextWarningGold then
				self.MissionNextWarningGold = self.MissionNextWarningGold + self.MissionSettings["TargetGold"] * 0.20
				self.MissionLastFailWarning = self.Time + 5
			end

			-- Always show last warning
			if enemyFunds > self.MissionSettings["TargetGold"] * 0.95 then
				self.MissionLastFailWarning = self.Time + 5
			end

			if self.Time < self.MissionLastFailWarning then
				for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
					FrameMan:ClearScreenText(player)
					FrameMan:SetScreenText(
						"STOP ENEMY MINING OPERATION\n"
							.. self.MissionSettings["TargetGold"] - math.ceil(enemyFunds)
							.. "oz OF GOLD LEFT TO MINE",
						player,
						0,
						1000,
						true
					)
				end
			end

			-- Mission failed
			if enemyFunds >= self.MissionSettings["TargetGold"] then
				self.MissionStage = self.MissionStages.FAILED
				self.MissionStatusShowStart = self.Time
			end
		end

		for actor in MovableMan.Actors do
			if actor.Team == CF_CPUTeam then
				if actor:HasObjectInGroup("Tools - Diggers") then
					minerCount = minerCount + 1

					if actor.AIMode ~= Actor.AIMODE_GOLDDIG then
						actor.AIMode = Actor.AIMODE_GOLDDIG
					end

					if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF_PlayerTeam) then
						self:AddObjectivePoint("KILL", actor.AboveHUDPos, CF_PlayerTeam, GameActivity.ARROWDOWN)
					end
				end

				if actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket" then
					if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF_PlayerTeam) then
						self:AddObjectivePoint(
							"TAKE DOWN\nDROP SHIP",
							actor.AboveHUDPos,
							CF_PlayerTeam,
							GameActivity.ARROWDOWN
						)
					end
					shipCount = shipCount + 1
				end
			end
		end

		if self.MissionSettings["EnemyDropShips"] > 0 then
			self.MissionStatus = "DROP SHIPS: " .. self.MissionSettings["EnemyDropShips"]
		else
			self.MissionStatus = "MINERS REMAINING: " .. minerCount
		end

		if (self.MissionSettings["EnemyDropShips"] == 0 or enemyFunds < 0) and minerCount + shipCount == 0 then
			self:GiveMissionRewards()
			self.MissionStage = self.MissionStages.COMPLETED

			-- Remember when we started showing misison status message
			self.MissionStatusShowStart = self.Time
		end

		-- Send reinforcements if available
		if
			#self.MissionLZs > 0
			and self.MissionSettings["EnemyDropShips"] > 0
			and minerCount < 3
			and self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"]
		then
			if MovableMan:GetMOIDCount() < CF_MOIDLimit then
				self.MissionLastReinforcements = self.Time
				self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] - 1

				local presets = {}
				presets[1] = CF_PresetTypes.ENGINEER
				presets[2] = math.random(CF_PresetTypes.SHOTGUN)
				presets[3] = math.random(CF_PresetTypes.HEAVY2)

				local modes = {}
				modes[1] = Actor.AIMODE_GOLDDIG
				modes[2] = Actor.AIMODE_SENTRY
				modes[3] = Actor.AIMODE_PATROL

				local f = CF_GetPlayerFaction(self.GS, self.MissionTargetPlayer)
				local ship = CF_MakeActor(CF_Crafts[f], CF_CraftClasses[f], CF_CraftModules[f])
				if ship then
					local unitCount = enemyFunds
								> (self.MissionSettings["EnemyBudget"] + self.MissionSettings["EnemyBudget"]) * 0.5
							and 2
						or 1
					for i = 1, unitCount do
						local pre = math.random(#presets)
						local actor = CF_SpawnAIUnitWithPreset(
							self.GS,
							self.MissionTargetPlayer,
							CF_CPUTeam,
							nil,
							modes[pre],
							presets[pre]
						)
						if actor then
							ship:AddInventoryItem(actor)
						end
					end
					ship.Team = CF_CPUTeam
					ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					self:SetTeamFunds(enemyFunds - ship:GetTotalValue(0, 1), CF_CPUTeam)
					MovableMan:AddActor(ship)
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
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	elseif self.MissionStage == self.MissionStages.FAILED then
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF_MusicTypes.DEFEAT)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.MissionStatusShowStart + CF_MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--[[
-----------------------------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if orbitedCraft.Team == CF_CPUTeam then
		self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] + 1
	end
end
-----------------------------------------------------------------------------------------
]]
--
-----------------------------------------------------------------------------------------
