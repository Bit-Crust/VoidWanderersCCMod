-----------------------------------------------------------------------------------------
--	Objective: 	Kill all enemies to protect friendly miners, deploy mining operation
--				and protect incoming friendly miners from incoming enemy troops
--	Set used: 	Enemy
--	Events: 	After a while AI will send some dropships to replace dead miners
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("MINE " .. (isNewGame == false and "LOAD" or "CREATE"))
	self.missionData = {}

	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		-- Mission difficulty settings
		local setts

		setts = {}
		setts[1] = {}
		setts[1]["allyReinforcementsCount"] = 6
		setts[1]["enemyDropshipUnitCount"] = 2
		setts[1]["enemyDropShips"] = 1
		setts[1]["interval"] = 35
		setts[1]["initialMiners"] = 1
		setts[1]["minersNeeded"] = 2
		setts[1]["timeToHold"] = 120

		setts[2] = {}
		setts[2]["allyReinforcementsCount"] = 6
		setts[2]["enemyDropshipUnitCount"] = 2
		setts[2]["enemyDropShips"] = 1
		setts[2]["interval"] = 33
		setts[2]["initialMiners"] = 1
		setts[2]["minersNeeded"] = 3
		setts[2]["timeToHold"] = 140

		setts[3] = {}
		setts[3]["allyReinforcementsCount"] = 6
		setts[3]["enemyDropshipUnitCount"] = 2
		setts[3]["enemyDropShips"] = 1
		setts[3]["interval"] = 31
		setts[3]["initialMiners"] = 1
		setts[3]["minersNeeded"] = 3
		setts[3]["timeToHold"] = 160

		setts[4] = {}
		setts[4]["allyReinforcementsCount"] = 6
		setts[4]["enemyDropshipUnitCount"] = 2
		setts[4]["enemyDropShips"] = 2
		setts[4]["interval"] = 29
		setts[4]["initialMiners"] = 2
		setts[4]["minersNeeded"] = 4
		setts[4]["timeToHold"] = 180

		setts[5] = {}
		setts[5]["allyReinforcementsCount"] = 5
		setts[5]["enemyDropshipUnitCount"] = 3
		setts[5]["enemyDropShips"] = 2
		setts[5]["interval"] = 27
		setts[5]["initialMiners"] = 2
		setts[5]["minersNeeded"] = 4
		setts[5]["timeToHold"] = 210

		setts[6] = {}
		setts[6]["allyReinforcementsCount"] = 5
		setts[6]["enemyDropshipUnitCount"] = 3
		setts[6]["enemyDropShips"] = 2
		setts[6]["interval"] = 25
		setts[6]["initialMiners"] = 3
		setts[6]["minersNeeded"] = 5
		setts[6]["timeToHold"] = 240

		self.missionData = setts[self.MissionDifficulty]
		self.missionData["missionStartTime"] = self.Time
		self.missionData["allySpawnInterval"] = math.ceil(self.missionData["interval"] * 0.5)
		self.missionData["reinforcementsLast"] = self.Time + self.missionData["interval"]
		self.missionData["backupLast"] = self.Time - 1

		-- Use generic enemy set
		local minerSet = CF.GetRandomMissionPointsSet(self.Pts, "Mine")

		-- Git miners
		local miners = CF.GetPointsArray(self.Pts, "Mine", minerSet, "Miners")
		if #miners == 0 then
			miners = { SceneMan:MovePointToGround(Vector(math.random(SceneMan.SceneWidth), 0), 0, 5) }
		end
		miners = CF.RandomSampleOfList(miners, self.missionData["initialMiners"])

		-- Get LZs
		self.missionData["minerLandingZones"] = CF.GetPointsArray(self.Pts, "Mine", minerSet, "MinerLZ")
		if #self.missionData["minerLandingZones"] == 0 then
			self.missionData["minerLandingZones"] = { miners }
		end

		-- Spawn miners
		for i = 1, #miners do
			local nw = {}
			nw["Preset"] = CF.PresetTypes.ENGINEER
			nw["Team"] = CF.PlayerTeam
			nw["Player"] = self.MissionSourcePlayer
			nw["AIMode"] = Actor.AIMODE_GOLDDIG
			nw["Pos"] = miners[i]
			nw["Ally"] = 1 -- Allies don't need comm-points to operate and don't get transfered to ship

			table.insert(self.SpawnTable, nw)
		end

		self.missionData["stage"] = CF.MissionStages.ACTIVE
		self.missionData["enoughMiners"] = false
		self.missionData["dropshipWarningStart"] = 0

		self:SetTeamFunds(0, CF.CPUTeam)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	local friends = 0
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local enemies = 0

		for actor in MovableMan.Actors do
			if actor.Team == CF.PlayerTeam then
				if actor:HasObjectInGroup("Tools - Diggers") and self:IsAlly(actor) then
					friends = friends + 1

					self:AddObjectivePoint("PROTECT", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
					if actor.AIMode ~= Actor.AIMODE_GOLDDIG and not (actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket") then
						actor.AIMode = Actor.AIMODE_GOLDDIG
					end
				end

				-- Don't let the player take over allied crafts
				if
					(actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket") and actor:IsPlayerControlled()
				then
					local cont = actor:GetController()
					actor = ToACraft(actor)
					if actor:IsInventoryEmpty() then
						actor:CloseHatch()
						actor.Vel.Y = math.min(actor.Vel.Y, -self.gravityPerFrame.Y - 1)
					else
						actor.Vel.Y = math.max(actor.Vel.Y, self.gravityPerFrame.Y + 1)
					end
				end
			elseif actor.Team == CF.CPUTeam then
				enemies = enemies + 1
				if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
					CF.HuntForActors(actor, CF.PlayerTeam)
				end
			end
		end

		-- If we don't have enough miners then show where you can find diggers
		--[[if friends <= self.missionData["minersNeeded"] then
			for item in MovableMan.Items do
				if item:IsInGroup("Tools - Diggers") then
					self:AddObjectivePoint("GRAB", item + Vector(0,-30), CF.PlayerTeam, GameActivity.ARROWDOWN)				
				end
			end
		end--]]
		--

		self.MissionStatus = "MINERS: " .. friends .. "/" .. self.missionData["minersNeeded"]

		if
			self.Time % 2 == 0
			and self.missionData["allyReinforcementsCount"] > 0
			and friends < self.missionData["minersNeeded"]
			and self.Time < self.missionData["backupLast"] + self.missionData["allySpawnInterval"]
		then
			self.MissionStatus = "MINERS ARRIVE IN T-"
				.. self.missionData["backupLast"] + self.missionData["allySpawnInterval"] - self.Time
		end

		if friends >= self.missionData["minersNeeded"] then
			if self.missionData["enoughMiners"] == false then
				self.missionData["enoughMiners"] = true
			end

			self.MissionStatus = "HOLD FOR "
				.. self.missionData["missionStartTime"] + self.missionData["timeToHold"] - self.Time
				.. " TICKS"
		else
			self.missionData["enoughMiners"] = false
		end

		if
			self.missionData["enoughMiners"]
			and self.Time >= self.missionData["missionStartTime"] + self.missionData["timeToHold"]
		then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED

			self.missionData["interval"] = math.floor(self.missionData["interval"] * 1.5)

			for actor in MovableMan.Actors do
				if self:IsAlly(actor) and actor.GoldCarried > 0 then
					CF.SetPlayerGold(self.GS, 0, CF.GetPlayerGold(self.GS, 0) + actor.GoldCarried)
					actor.GoldCarried = 0
				end
			end
			-- Remember when we started showing misison status message
			self.MissionStatusShowStart = self.Time
		elseif
			self.missionData["allyReinforcementsCount"] == 0 and friends < self.missionData["minersNeeded"]
		then
			self.missionData["stage"] = CF.MissionStages.FAILED
			self.MissionStatusShowStart = self.Time

			for actor in MovableMan.Actors do
				if self:IsAlly(actor) then
					actor.Health = 0
				end
			end
		end

		if self.Time < self.missionData["dropshipWarningStart"] + 10 then
			if self.missionData["allyReinforcementsCount"] > 0 then
				local s = self.missionData["allyReinforcementsCount"] > 1 and "S" or ""
				for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
					FrameMan:ClearScreenText(player)
					FrameMan:SetScreenText(
						"ONLY " .. self.missionData["allyReinforcementsCount"] .. " ALLY DROP SHIP" .. s .. " LEFT!",
						player,
						0,
						1000,
						true
					)
				end
			end
		end

		if self.missionData["enoughMiners"] then
			self.missionData["backupLast"] = self.Time
		end

		-- Send player reinforcements
		if
			not self.missionData["enoughMiners"]
			and #self.missionData["minerLandingZones"] > 0
			and self.Time >= self.missionData["backupLast"] + self.missionData["allySpawnInterval"]
			and self.missionData["allyReinforcementsCount"] > 0
		then
			self.missionData["backupLast"] = self.Time

			if self.missionData["allyReinforcementsCount"] < 3 then
				self.missionData["dropshipWarningStart"] = self.Time
			end

			local f = CF.GetPlayerFaction(self.GS, self.MissionSourcePlayer)
			local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
			if ship then
				for i = 1, math.random(2) do
					local actor
					if i == 1 then
						actor = CF.SpawnAIUnitWithPreset(
							self.GS,
							self.MissionSourcePlayer,
							CF.PlayerTeam,
							nil,
							Actor.AIMODE_GOLDDIG,
							CF.PresetTypes.ENGINEER
						)
					else
						actor = CF.SpawnRandomInfantry(CF.PlayerTeam, nil, f, Actor.AIMODE_GOLDDIG)
						if actor then
							actor:AddInventoryItem(CreateHDFirearm("Heavy Digger", "Base.rte"))
						end
					end
					if actor then
						self:SetAlly(actor, true)
						ship:AddInventoryItem(actor)
					end
				end
				self:SetAlly(ship, true)
				ship.Team = CF.PlayerTeam
				ship.Pos = Vector(self.missionData["minerLandingZones"][math.random(#self.missionData["minerLandingZones"])].X, -10)
				ship:SetGoldValue(0)
				ship.AIMode = Actor.AIMODE_DELIVER
				MovableMan:AddActor(ship)
				self.missionData["allyReinforcementsCount"] = self.missionData["allyReinforcementsCount"]
					- 1
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end
		if self.Time < self.MissionStatusShowStart + CF.MissionResultShowInterval then
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

		if self.Time < self.MissionStatusShowStart + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	end

	-- Always send enemy reinforcements to prevent player from digging out the whole map with free miners
	if
		#self.missionData["minerLandingZones"] > 0
		and self.Time >= self.missionData["reinforcementsLast"]
	then
		if self.missionData["enemyDropShips"] > 0 then
			local f = CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)
			local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
			if ship then
				local count
				if self.missionData["stage"] == CF.MissionStages.ACTIVE then
					count = math.random(
						math.ceil(self.missionData["enemyDropshipUnitCount"] * 0.5),
						self.missionData["enemyDropshipUnitCount"]
					)
				else
					count = 2
					ship:SetGoldValue(0)
				end
				for i = 1, count do
					local actor = CF.SpawnAIUnitWithPreset(
						self.GS,
						self.MissionTargetPlayer,
						CF.CPUTeam,
						nil,
						Actor.AIMODE_SENTRY,
						math.random(CF.PresetTypes.HEAVY2)
					)
					if actor then
						if self.missionData["stage"] ~= CF.MissionStages.ACTIVE then
							actor:SetGoldValue(0)
						end
						ship:AddInventoryItem(actor)
					end
				end
				ship.Team = CF.CPUTeam
				ship.Pos = Vector(self.missionData["minerLandingZones"][math.random(#self.missionData["minerLandingZones"])].X, -10)
				ship.AIMode = Actor.AIMODE_DELIVER
				MovableMan:AddActor(ship)

				self.missionData["enemyDropShips"] = self.missionData["enemyDropShips"] - 1
			end
		else
			-- Don't stop at zero dropships, just delay the enemy whenever they lose one
			self.missionData["enemyDropShips"] = self.missionData["enemyDropShips"] + 1
		end
		self.missionData["reinforcementsLast"] = self.Time
			+ math.max(self.missionData["interval"] - friends, self.missionData["allySpawnInterval"])
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
