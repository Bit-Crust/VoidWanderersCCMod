-----------------------------------------------------------------------------------------
--	Objective: 	Kill all enemies to protect friendly miners, deploy mining operation
--				and protect incoming friendly miners from incoming enemy troops
--	Set used: 	Enemy
--	Events: 	After a while AI will send some dropships to replace dead miners
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("MINE CREATE")
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["AllyReinforcementsCount"] = 6
	setts[1]["EnemyDropshipUnitCount"] = 2
	setts[1]["EnemyDropShips"] = 1
	setts[1]["Interval"] = 35
	setts[1]["InitialMiners"] = 1
	setts[1]["MinersNeeded"] = 2
	setts[1]["TimeToHold"] = 120

	setts[2] = {}
	setts[2]["AllyReinforcementsCount"] = 6
	setts[2]["EnemyDropshipUnitCount"] = 2
	setts[2]["EnemyDropShips"] = 1
	setts[2]["Interval"] = 33
	setts[2]["InitialMiners"] = 1
	setts[2]["MinersNeeded"] = 3
	setts[2]["TimeToHold"] = 130

	setts[3] = {}
	setts[3]["AllyReinforcementsCount"] = 6
	setts[3]["EnemyDropshipUnitCount"] = 2
	setts[3]["EnemyDropShips"] = 1
	setts[3]["Interval"] = 31
	setts[3]["InitialMiners"] = 1
	setts[3]["MinersNeeded"] = 3
	setts[3]["TimeToHold"] = 140

	setts[4] = {}
	setts[4]["AllyReinforcementsCount"] = 6
	setts[4]["EnemyDropshipUnitCount"] = 2
	setts[4]["EnemyDropShips"] = 2
	setts[4]["Interval"] = 29
	setts[4]["InitialMiners"] = 2
	setts[4]["MinersNeeded"] = 4
	setts[4]["TimeToHold"] = 150

	setts[5] = {}
	setts[5]["AllyReinforcementsCount"] = 5
	setts[5]["EnemyDropshipUnitCount"] = 3
	setts[5]["EnemyDropShips"] = 2
	setts[5]["Interval"] = 27
	setts[5]["InitialMiners"] = 2
	setts[5]["MinersNeeded"] = 4
	setts[5]["TimeToHold"] = 170

	setts[6] = {}
	setts[6]["AllyReinforcementsCount"] = 5
	setts[6]["EnemyDropshipUnitCount"] = 3
	setts[6]["EnemyDropShips"] = 2
	setts[6]["Interval"] = 25
	setts[6]["InitialMiners"] = 3
	setts[6]["MinersNeeded"] = 5
	setts[6]["TimeToHold"] = 200

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time
	self.MissionAllySpawnInterval = math.ceil(self.MissionSettings["Interval"] * 0.5)
	self.MissionNextReinforcements = self.Time + self.MissionSettings["Interval"]
	self.MissionLastAllyReinforcements = self.Time - 1

	-- Use generic enemy set
	local set = CF["GetRandomMissionPointsSet"](self.Pts, "Mine")

	-- Git miners
	local miners = CF["GetPointsArray"](self.Pts, "Mine", set, "Miners")
	if #miners == 0 then
		miners = { SceneMan:MovePointToGround(Vector(math.random(SceneMan.SceneWidth), 0), 0, 5) }
	end
	miners = CF["SelectRandomPoints"](miners, self.MissionSettings["InitialMiners"])

	-- Get LZs
	self.MissionLZs = CF["GetPointsArray"](self.Pts, "Mine", set, "MinerLZ")
	if #self.MissionLZs == 0 then
		self.MissionLZs = { miners }
	end

	-- Spawn miners
	for i = 1, #miners do
		local nw = {}
		nw["Preset"] = CF["PresetTypes"].ENGINEER
		nw["Team"] = CF["PlayerTeam"]
		nw["Player"] = self.MissionSourcePlayer
		nw["AIMode"] = Actor.AIMODE_GOLDDIG
		nw["Pos"] = miners[i]
		nw["Ally"] = 1 -- Allies don't need comm-points to operate and don't get transfered to ship

		table.insert(self.SpawnTable, nw)
	end

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1, FAILED = 2 }
	self.MissionStage = self.MissionStages.ACTIVE
	self.MissionEnoughMiners = false
	self.MissionCompleteCountdownStart = 0
	self.MissionShowDropshipWarningStart = 0

	self:SetTeamFunds(0, CF["CPUTeam"])
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	local friends = 0
	if self.MissionStage == self.MissionStages.ACTIVE then
		self.MissionCompleted = false
		local enemies = 0

		for actor in MovableMan.Actors do
			if actor.Team == CF["PlayerTeam"] then
				if actor:HasObjectInGroup("Tools - Diggers") and self:IsAlly(actor) then
					friends = friends + 1

					self:AddObjectivePoint("PROTECT", actor.AboveHUDPos, CF["PlayerTeam"], GameActivity.ARROWDOWN)
					if actor.AIMode ~= Actor.AIMODE_GOLDDIG then
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
			elseif actor.Team == CF["CPUTeam"] then
				enemies = enemies + 1
				if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
					CF["HuntForActors"](actor, CF["PlayerTeam"])
				end
			end
		end

		-- If we don't have enough miners then show where you can find diggers
		--[[if friends <= self.MissionSettings["MinersNeeded"] then
			for item in MovableMan.Items do
				if item:IsInGroup("Tools - Diggers") then
					self:AddObjectivePoint("GRAB", item + Vector(0,-30), CF["PlayerTeam"], GameActivity.ARROWDOWN)				
				end
			end
		end--]]
		--

		self.MissionStatus = "MINERS: " .. friends .. "/" .. self.MissionSettings["MinersNeeded"]

		if
			self.Time % 2 == 0
			and self.MissionSettings["AllyReinforcementsCount"] > 0
			and friends < self.MissionSettings["MinersNeeded"]
			and self.Time < self.MissionLastAllyReinforcements + self.MissionAllySpawnInterval
		then
			self.MissionStatus = "MINERS ARRIVE IN T-"
				.. self.MissionLastAllyReinforcements + self.MissionAllySpawnInterval - self.Time
		end

		if friends >= self.MissionSettings["MinersNeeded"] then
			if self.MissionEnoughMiners == false then
				self.MissionEnoughMiners = true
				self.MissionCompleteCountdownStart = self.Time
			end

			self.MissionStatus = "HOLD FOR "
				.. self.MissionCompleteCountdownStart + self.MissionSettings["TimeToHold"] - self.Time
				.. " TICKS"
		else
			self.MissionEnoughMiners = false
		end

		if
			self.MissionEnoughMiners
			and self.Time >= self.MissionCompleteCountdownStart + self.MissionSettings["TimeToHold"]
		then
			self:GiveMissionRewards()
			self.MissionStage = self.MissionStages.COMPLETED

			self.MissionSettings["Interval"] = math.floor(self.MissionSettings["Interval"] * 1.5)

			for actor in MovableMan.Actors do
				if self:IsAlly(actor) and actor.GoldCarried > 0 then
					CF["SetPlayerGold"](self.GS, 0, CF["GetPlayerGold"](self.GS, 0) + actor.GoldCarried)
					actor.GoldCarried = 0
				end
			end
			-- Remember when we started showing misison status message
			self.MissionStatusShowStart = self.Time
		elseif
			self.MissionSettings["AllyReinforcementsCount"] == 0 and friends < self.MissionSettings["MinersNeeded"]
		then
			self.MissionStage = self.MissionStages.FAILED
			self.MissionStatusShowStart = self.Time

			for actor in MovableMan.Actors do
				if self:IsAlly(actor) then
					actor.Health = 0
				end
			end
		end

		if self.Time < self.MissionShowDropshipWarningStart + 10 then
			if self.MissionSettings["AllyReinforcementsCount"] > 0 then
				local s = self.MissionSettings["AllyReinforcementsCount"] > 1 and "S" or ""
				for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
					FrameMan:ClearScreenText(player)
					FrameMan:SetScreenText(
						"ONLY " .. self.MissionSettings["AllyReinforcementsCount"] .. " ALLY DROP SHIP" .. s .. " LEFT!",
						player,
						0,
						1000,
						true
					)
				end
			end
		end

		if self.MissionEnoughMiners then
			self.MissionLastAllyReinforcements = self.Time
		end

		-- Send player reinforcements
		if
			not self.MissionEnoughMiners
			and #self.MissionLZs > 0
			and self.Time >= self.MissionLastAllyReinforcements + self.MissionAllySpawnInterval
			and self.MissionSettings["AllyReinforcementsCount"] > 0
		then
			if MovableMan:GetMOIDCount() < CF["MOIDLimit"] then
				--print ("Spawn ally")
				self.MissionLastAllyReinforcements = self.Time

				if self.MissionSettings["AllyReinforcementsCount"] < 3 then
					self.MissionShowDropshipWarningStart = self.Time
				end

				local f = CF["GetPlayerFaction"](self.GS, self.MissionSourcePlayer)
				local ship = CF["MakeActor"](CF["Crafts"][f], CF["CraftClasses"][f], CF["CraftModules"][f])
				if ship then
					for i = 1, math.random(2) do
						local actor
						if i == 1 then
							actor = CF["SpawnAIUnitWithPreset"](
								self.GS,
								self.MissionSourcePlayer,
								CF["PlayerTeam"],
								nil,
								Actor.AIMODE_GOLDDIG,
								CF["PresetTypes"].ENGINEER
							)
						else
							actor = CF["SpawnRandomInfantry"](CF["PlayerTeam"], nil, f, Actor.AIMODE_GOLDDIG)
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
					ship.Team = CF["PlayerTeam"]
					ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
					ship:SetGoldValue(0)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
					self.MissionSettings["AllyReinforcementsCount"] = self.MissionSettings["AllyReinforcementsCount"]
						- 1
				end
			end
		end
	elseif self.MissionStage == self.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF["MusicTypes"].VICTORY)
			self.MissionEndMusicPlayed = true
		end
		if self.Time < self.MissionStatusShowStart + CF["MissionResultShowInterval"] then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	elseif self.MissionStage == self.MissionStages.FAILED then
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF["MusicTypes"].DEFEAT)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.MissionStatusShowStart + CF["MissionResultShowInterval"] then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	end

	-- Always send enemy reinforcements to prevent player from digging out the whole map with free miners
	if
		MovableMan:GetMOIDCount() < CF["MOIDLimit"]
		and #self.MissionLZs > 0
		and self.Time >= self.MissionNextReinforcements
	then
		if self.MissionSettings["EnemyDropShips"] > 0 then
			local f = CF["GetPlayerFaction"](self.GS, self.MissionTargetPlayer)
			local ship = CF["MakeActor"](CF["Crafts"][f], CF["CraftClasses"][f], CF["CraftModules"][f])
			if ship then
				local count
				if self.MissionStage == self.MissionStages.ACTIVE then
					count = math.random(
						math.ceil(self.MissionSettings["EnemyDropshipUnitCount"] * 0.5),
						self.MissionSettings["EnemyDropshipUnitCount"]
					)
				else
					count = 2
					ship:SetGoldValue(0)
				end
				for i = 1, count do
					local actor = CF["SpawnAIUnitWithPreset"](
						self.GS,
						self.MissionTargetPlayer,
						CF["CPUTeam"],
						nil,
						Actor.AIMODE_SENTRY,
						math.random(CF["PresetTypes"].HEAVY2)
					)
					if actor then
						if self.MissionStage ~= self.MissionStages.ACTIVE then
							actor:SetGoldValue(0)
						end
						ship:AddInventoryItem(actor)
					end
				end
				ship.Team = CF["CPUTeam"]
				ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
				ship.AIMode = Actor.AIMODE_DELIVER
				MovableMan:AddActor(ship)

				self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] - 1
			end
		else
			-- Don't stop at zero dropships, just delay the enemy whenever they lose one
			self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] + 1
		end
		self.MissionNextReinforcements = self.Time
			+ math.max(self.MissionSettings["Interval"] - friends, self.MissionAllySpawnInterval)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
