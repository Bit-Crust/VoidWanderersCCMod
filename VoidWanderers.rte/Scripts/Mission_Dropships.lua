-----------------------------------------------------------------------------------------
--	Objective: 	Kill all enemy miners and shoot down all incoming dropships
--	Set used: 	Enemy
--	Events: 	After a while AI will send some dropships to replace dead miners
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	self.missionData = {}
	
	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		-- Mission difficulty settings
		local setts

		setts = {}
		setts[1] = {}
		setts[1]["spawnRate"] = 0.20
		setts[1]["enemyDropShips"] = 2
		setts[1]["interval"] = 26
		setts[1]["enemyBudget"] = 1000
		setts[1]["targetGold"] = 5000

		setts[2] = {}
		setts[2]["spawnRate"] = 0.40
		setts[2]["enemyDropShips"] = 3
		setts[2]["interval"] = 26
		setts[2]["enemyBudget"] = 1500
		setts[2]["targetGold"] = 5500

		setts[3] = {}
		setts[3]["spawnRate"] = 0.60
		setts[3]["enemyDropShips"] = 4
		setts[3]["interval"] = 26
		setts[3]["enemyBudget"] = 2000
		setts[3]["targetGold"] = 6000

		setts[4] = {}
		setts[4]["spawnRate"] = 0.80
		setts[4]["enemyDropShips"] = 5
		setts[4]["interval"] = 24
		setts[4]["enemyBudget"] = 2500
		setts[4]["targetGold"] = 6500

		setts[5] = {}
		setts[5]["spawnRate"] = 1
		setts[5]["enemyDropShips"] = 5
		setts[5]["interval"] = 24
		setts[5]["enemyBudget"] = 3000
		setts[5]["targetGold"] = 7000

		setts[6] = {}
		setts[6]["spawnRate"] = 1
		setts[6]["enemyDropShips"] = 6
		setts[6]["interval"] = 22
		setts[6]["enemyBudget"] = 3500
		setts[6]["targetGold"] = 7500

		self.missionData = setts[self.MissionDifficulty]
		self.missionData["missionStartTime"] = self.Time

		self.missionData["reinforcementsLast"] = self.Time + self.missionData["interval"] * 3
		self.missionData["nextGoldWarning"] = self.missionData["enemyBudget"]
			+ (self.missionData["targetGold"] - self.missionData["enemyBudget"]) * 0.20
		self.missionData["lastFailWarning"] = 0

		self:SetTeamFunds(self.missionData["enemyBudget"], CF.CPUTeam)

		-- Use random sets
		local minerSet = CF.GetRandomMissionPointsSet(self.Pts, "Mine")
		local enemySet = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")

		-- Get LZs
		self.missionData["minerLandingZones"] = CF.GetPointsArray(self.Pts, "Mine", minerSet, "MinerLZ")

		local count

		-- Get miner locations
		local miners = CF.GetPointsArray(self.Pts, "Mine", minerSet, "Miners")
		count = math.ceil(#miners * self.missionData["spawnRate"] * 2)
		if count <= 0 then
			count = 1
		end
		miners = CF.RandomSampleOfList(miners, count)

		-- Get security locations
		local security = CF.GetPointsArray(self.Pts, "Mine", minerSet, "MinerSentries")
		count = math.ceil(#security * self.missionData["spawnRate"])
		if count <= 0 then
			count = 1
		end
		security = CF.RandomSampleOfList(security, count)

		-- Get sniper locations
		local snipers = CF.GetPointsArray(self.Pts, "Enemy", enemySet, "Sniper")
		count = math.ceil(#snipers * self.missionData["spawnRate"] / 2)
		if count <= 0 then
			count = 1
		end
		snipers = CF.RandomSampleOfList(snipers, count)

		-- Spawn miners
		for i = 1, #miners do
			local nw = {}
			nw["Preset"] = CF.PresetTypes.ENGINEER
			nw["Team"] = CF.CPUTeam
			nw["Player"] = self.MissionTargetPlayer
			nw["AIMode"] = Actor.AIMODE_GOLDDIG
			nw["Pos"] = miners[i]

			table.insert(self.SpawnTable, nw)
		end

		-- Spawn security
		for i = 1, #security do
			local nw = {}
			nw["Preset"] = math.random(CF.PresetTypes.HEAVY2)
			nw["Team"] = CF.CPUTeam
			nw["Player"] = self.MissionTargetPlayer
			nw["AIMode"] = Actor.AIMODE_SENTRY
			nw["Pos"] = security[i]

			table.insert(self.SpawnTable, nw)
		end
		
		-- Spawn snipers
		for i = 1, #snipers do
			local nw = {}
			nw["Preset"] = CF.PresetTypes.SNIPER
			nw["Team"] = CF.CPUTeam
			nw["Player"] = self.MissionTargetPlayer
			nw["AIMode"] = Actor.AIMODE_SENTRY
			nw["Pos"] = snipers[i]

			table.insert(self.SpawnTable, nw)
		end

		self.missionData["stage"] = CF.MissionStages.ACTIVE
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function qAssert(value)
	print(value)
	return value
end

function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local minerCount = 0
		local shipCount = 0
		local enemyFunds = self:GetTeamFunds(CF.CPUTeam)

		if enemyFunds > 0 then
			-- Show gold warnings from time to time
			if enemyFunds > self.missionData["nextGoldWarning"] then
				self.missionData["nextGoldWarning"] = self.missionData["nextGoldWarning"] + self.missionData["targetGold"] * 0.20
				self.missionData["lastFailWarning"] = self.Time + 5
			end

			-- Always show last warning
			if enemyFunds > self.missionData["targetGold"] * 0.95 then
				self.missionData["lastFailWarning"] = self.Time + 5
			end

			if self.Time < self.missionData["lastFailWarning"] then
				for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
					FrameMan:ClearScreenText(player)
					FrameMan:SetScreenText(
						"STOP ENEMY MINING OPERATION\n"
							.. self.missionData["targetGold"] - math.ceil(enemyFunds)
							.. "oz OF GOLD LEFT TO MINE",
						player,
						0,
						1000,
						true
					)
				end
			end

			-- Mission failed
			if enemyFunds >= self.missionData["targetGold"] then
				self.missionData["stage"] = CF.MissionStages.FAILED
				self.missionData["statusShowStart"] = self.Time
			end
		end

		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam then
				if actor:HasObjectInGroup("Tools - Diggers") then
					minerCount = minerCount + 1

					if actor.AIMode ~= Actor.AIMODE_GOLDDIG then
						actor.AIMode = Actor.AIMODE_GOLDDIG
					end

					if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam) then
						self:AddObjectivePoint("KILL", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
					end
				end

				if actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket" then
					if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam) then
						self:AddObjectivePoint(
							"TAKE DOWN\nDROP SHIP",
							actor.AboveHUDPos,
							CF.PlayerTeam,
							GameActivity.ARROWDOWN
						)
					end
					shipCount = shipCount + 1
				end
			end
		end

		if self.missionData["enemyDropShips"] > 0 then
			self.MissionStatus = "DROP SHIPS: " .. self.missionData["enemyDropShips"]
		else
			self.MissionStatus = "MINERS REMAINING: " .. minerCount
		end

		if (self.missionData["enemyDropShips"] == 0 or enemyFunds < 0) and minerCount + shipCount == 0 then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED

			-- Remember when we started showing misison status message
			self.missionData["statusShowStart"] = self.Time
		end

		-- Send reinforcements if available
		if
			#self.missionData["minerLandingZones"] > 0
			and self.missionData["enemyDropShips"] > 0
			and minerCount < 3
			and self.Time >= self.missionData["reinforcementsLast"] + self.missionData["interval"]
		then
			self.missionData["reinforcementsLast"] = self.Time
			self.missionData["enemyDropShips"] = self.missionData["enemyDropShips"] - 1

			local presets = {}
			presets[1] = CF.PresetTypes.ENGINEER
			presets[2] = math.random(CF.PresetTypes.SHOTGUN)
			presets[3] = math.random(CF.PresetTypes.HEAVY2)

			local modes = {}
			modes[1] = Actor.AIMODE_GOLDDIG
			modes[2] = Actor.AIMODE_SENTRY
			modes[3] = Actor.AIMODE_PATROL

			local f = CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)
			local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
			if ship then
				local unitCount = enemyFunds
							> (self.missionData["enemyBudget"] + self.missionData["enemyBudget"]) * 0.5
						and 2
					or 1
				for i = 1, unitCount do
					local pre = math.random(#presets)
					local actor = CF.SpawnAIUnitWithPreset(
						self.GS,
						self.MissionTargetPlayer,
						CF.CPUTeam,
						nil,
						modes[pre],
						presets[pre]
					)
					if actor then
						ship:AddInventoryItem(actor)
					end
				end
				ship.Team = CF.CPUTeam
				ship.Pos = Vector(self.missionData["minerLandingZones"][math.random(#self.missionData["minerLandingZones"])].X, -10)
				ship.AIMode = Actor.AIMODE_DELIVER
				self:SetTeamFunds(enemyFunds - ship:GetTotalValue(0, 1), CF.CPUTeam)
				MovableMan:AddActor(ship)
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
	elseif self.missionData["stage"] == CF.MissionStages.FAILED then
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.DEFEAT)
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
--[[
-----------------------------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if orbitedCraft.Team == CF.CPUTeam then
		self.missionData["EnemyDropShips"] = self.missionData["EnemyDropShips"] + 1
	end
end
-----------------------------------------------------------------------------------------
]]
--
-----------------------------------------------------------------------------------------
