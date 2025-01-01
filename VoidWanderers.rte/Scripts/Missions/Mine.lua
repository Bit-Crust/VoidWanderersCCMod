-----------------------------------------------------------------------
--	Objective: 	Kill all enemies to protect friendly miners, deploy mining operation
--				and protect incoming friendly miners from incoming enemy troops
--	Set used: 	Enemy
--	Events: 	After a while AI will send some dropships to replace dead miners
--
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("MINE CREATE")

	-- Mission difficulty settings
	local diff = self.missionData["difficulty"]

	if diff == 1 then
		self.missionData["allyReinforcementsCount"] = 6
		self.missionData["enemyDropshipUnitCount"] = 2
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 35
		self.missionData["initialMiners"] = 1
		self.missionData["minersNeeded"] = 2
		self.missionData["timeToHold"] = 120
	elseif diff == 2 then
		self.missionData["allyReinforcementsCount"] = 6
		self.missionData["enemyDropshipUnitCount"] = 2
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 33
		self.missionData["initialMiners"] = 1
		self.missionData["minersNeeded"] = 3
		self.missionData["timeToHold"] = 140
	elseif diff == 3 then
		self.missionData["allyReinforcementsCount"] = 6
		self.missionData["enemyDropshipUnitCount"] = 2
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 31
		self.missionData["initialMiners"] = 1
		self.missionData["minersNeeded"] = 3
		self.missionData["timeToHold"] = 160
	elseif diff == 4 then
		self.missionData["allyReinforcementsCount"] = 6
		self.missionData["enemyDropshipUnitCount"] = 2
		self.missionData["enemyDropShips"] = 2
		self.missionData["interval"] = 29
		self.missionData["initialMiners"] = 2
		self.missionData["minersNeeded"] = 4
		self.missionData["timeToHold"] = 180
	elseif diff == 5 then
		self.missionData["allyReinforcementsCount"] = 5
		self.missionData["enemyDropshipUnitCount"] = 3
		self.missionData["enemyDropShips"] = 2
		self.missionData["interval"] = 27
		self.missionData["initialMiners"] = 2
		self.missionData["minersNeeded"] = 4
		self.missionData["timeToHold"] = 210
	elseif diff == 6 then
		self.missionData["allyReinforcementsCount"] = 5
		self.missionData["enemyDropshipUnitCount"] = 3
		self.missionData["enemyDropShips"] = 2
		self.missionData["interval"] = 25
		self.missionData["initialMiners"] = 3
		self.missionData["minersNeeded"] = 5
		self.missionData["timeToHold"] = 240
	end

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
		nw["Player"] = self.missionData["missionContractor"]
		nw["AIMode"] = Actor.AIMODE_GOLDDIG
		nw["Pos"] = miners[i]
		nw["Ally"] = 1 -- Allies don't need comm-points to operate and don't get transfered to ship
		
		self:SpawnViaTable(nw)
	end

	self.missionData["enoughMiners"] = false
	self.missionData["dropshipWarningStart"] = 0

	self:SetTeamFunds(0, CF.CPUTeam)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	local friends = 0
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local enemies = 0

		for actor in MovableMan.Actors do
			if actor.Team == CF.PlayerTeam then
				if actor:HasObjectInGroup("Tools - Diggers") and CF.IsAlly(actor) then
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

		self.missionData["missionStatus"] = "MINERS: " .. friends .. "/" .. self.missionData["minersNeeded"]

		if
			self.Time % 2 == 0
			and self.missionData["allyReinforcementsCount"] > 0
			and friends < self.missionData["minersNeeded"]
			and self.Time < self.missionData["backupLast"] + self.missionData["allySpawnInterval"]
		then
			self.missionData["missionStatus"] = "MINERS ARRIVE IN T-"
				.. self.missionData["backupLast"] + self.missionData["allySpawnInterval"] - self.Time
		end

		if friends >= self.missionData["minersNeeded"] then
			if self.missionData["enoughMiners"] == false then
				self.missionData["enoughMiners"] = true
			end

			self.missionData["missionStatus"] = "HOLD FOR "
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
			self.missionData["statusShowStart"] = self.Time

			self.missionData["interval"] = math.floor(self.missionData["interval"] * 1.5)

			for actor in MovableMan.Actors do
				if CF.IsAlly(actor) and actor.GoldCarried > 0 then
					CF.ChangePlayerGold(self.GS, actor.GoldCarried)
					actor.GoldCarried = 0
				end
			end
		elseif
			self.missionData["allyReinforcementsCount"] == 0 and friends < self.missionData["minersNeeded"]
		then
			self.missionData["stage"] = CF.MissionStages.FAILED
			self.missionData["statusShowStart"] = self.Time

			for actor in MovableMan.Actors do
				if CF.IsAlly(actor) then
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

			local f = CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"])
			local ship = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])
			if ship then
				for i = 1, math.random(2) do
					local actor
					if i == 1 then
						actor = CF.MakeUnitWithPreset(self.GS, self.missionData["missionContractor"], CF.PresetTypes.ENGINEER)
						actor.Team = CF.PlayerTeam;
						actor.AIMode = Actor.AIMODE_GOLDDIG;
					else
						actor = CF.SpawnRandomInfantry(CF.PlayerTeam, nil, f, Actor.AIMODE_GOLDDIG)
						if actor then
							actor:AddInventoryItem(CreateHDFirearm("Heavy Digger", "Base.rte"))
						end
					end
					if actor then
						CF.SetAlly(actor, true)
						ship:AddInventoryItem(actor)
					end
				end
				CF.SetAlly(ship, true)
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
		self.missionData["missionStatus"] = "MISSION COMPLETED"
		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.missionData["endMusicPlayed"] = true
		end
		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.FAILED then
		self.missionData["missionStatus"] = "MISSION FAILED"
		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.DEFEAT)
			self.missionData["endMusicPlayed"] = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end
	end

	-- Always send enemy reinforcements to prevent player from digging out the whole map with free miners
	if
		#self.missionData["minerLandingZones"] > 0
		and self.Time >= self.missionData["reinforcementsLast"]
	then
		if self.missionData["enemyDropShips"] > 0 then
			local f = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])
			local ship = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])
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
					local actor = CF.MakeUnitWithPreset(self.GS, self.missionData["missionTarget"], math.random(CF.PresetTypes.HEAVY2));

					if actor then
						actor.Team = CF.CPUTeam;
						actor.AIMode = Actor.AIMODE_SENTRY;

						if self.missionData["stage"] ~= CF.MissionStages.ACTIVE then
							actor:SetGoldValue(0);
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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
