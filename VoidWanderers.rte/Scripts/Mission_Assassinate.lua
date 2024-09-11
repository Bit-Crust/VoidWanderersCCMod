-----------------------------------------------------------------------------------------
--	Objective: 	Kill enemy brain unit
--	Set used: 	Enemy, Assassinate
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				half of it's actors. Initial spawn rate varies based on mission difficulty.
--				After commander's death units go nuts for a few moments
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ASSASSINATE CREATE")

	-- Mission difficulty settings
	local diff = self.missionData["difficulty"]

	if diff == 1 then
		self.missionData["spawnRate"] = 0.30
		self.missionData["reinforcements"] = 0
		self.missionData["interval"] = 10
		self.missionData["counterAttackDelay"] = 0
	elseif diff == 2 then
		self.missionData["spawnRate"] = 0.40
		self.missionData["reinforcements"] = 1
		self.missionData["interval"] = 30
		self.missionData["counterAttackDelay"] = 340
	elseif diff == 3 then
		self.missionData["spawnRate"] = 0.50
		self.missionData["reinforcements"] = 2
		self.missionData["interval"] = 28
		self.missionData["counterAttackDelay"] = 300
	elseif diff == 4 then
		self.missionData["spawnRate"] = 0.60
		self.missionData["reinforcements"] = 3
		self.missionData["interval"] = 26
		self.missionData["counterAttackDelay"] = 260
	elseif diff == 5 then
		self.missionData["spawnRate"] = 0.70
		self.missionData["reinforcements"] = 4
		self.missionData["interval"] = 24
		self.missionData["counterAttackDelay"] = 220
	elseif diff == 6 then
		self.missionData["spawnRate"] = 0.80
		self.missionData["reinforcements"] = 5
		self.missionData["interval"] = 22
		self.missionData["counterAttackDelay"] = 180
	end

	local pointSetIndex = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")

	-- Use generic enemy set
	self:DeployGenericMissionEnemies(
		pointSetIndex,
		"Enemy",
		self.missionData["missionTarget"],
		CF.CPUTeam,
		self.missionData["spawnRate"]
	)
	-- Get LZs
	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Enemy", pointSetIndex, "LZ")
	-- Get base
	self:ObtainBaseBoxes("Enemy", pointSetIndex)
	-- Deploy mines
	self:DeployInfantryMines(
		CF.CPUTeam,
		math.min(
			-tonumber(self.GS["Player" .. self.missionData["missionTarget"] .. "Reputation"])
				/ (CF.MaxDifficulty * CF.ReputationPerDifficulty),
			1
		) - 0.5
	)

	-- Spawn commander
	local cmndrpts = CF.GetPointsArray(self.Pts, "Assassinate", pointSetIndex, "Commander")
	local cpos = cmndrpts[math.random(#cmndrpts)]

	self.missionData["brain"] = CF.MakeRPGBrain(self.GS, self.missionData["missionTarget"], CF.CPUTeam, cpos, math.floor(diff / 3), true)

	if self.missionData["brain"] then
		self.missionData["brain"]:AddToGroup("MissionBrain")
		MovableMan:AddActor(self.missionData["brain"])
		if math.random(CF.MaxDifficulty) <= diff then
			self.missionData["brain"]:AddInventoryItem(CreateHeldDevice("Blueprint", CF.ModuleName))
		end
	end

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

		-- Start checking for victory only when all units were spawned
		if MovableMan:IsActor(self.missionData["brain"]) and self.missionData["brain"]:HasObjectInGroup("MissionBrain") then
			if MovableMan:IsActor(self.missionData["craft"]) then
				if self.missionData["craft"]:HasObjectInGroup("MissionBrain") then
					if self.missionData["craft"].Status == Actor.STABLE then
						self.missionData["craft"]:CloseHatch()
					end
					self.missionData["craft"].AIMode = Actor.AIMODE_RETURN
					self:AddObjectivePoint(
						"DESTROY!",
						self.missionData["brain"].AboveHUDPos,
						CF.PlayerTeam,
						GameActivity.ARROWDOWN
					)
				else
					self:AddObjectivePoint(
						"KILL",
						self.missionData["brain"].AboveHUDPos,
						CF.PlayerTeam,
						GameActivity.ARROWDOWN
					)
					if
						self.missionData["craft"].HatchState == ACraft.CLOSED
						and SceneMan
							:ShortestDistance(
								self.missionData["craft"].Pos + Vector(0, self.missionData["craft"].Radius * 0.5),
								self.missionData["brain"].Pos,
								SceneMan.SceneWrapsX
							)
							:MagnitudeIsLessThan(self.missionData["craft"].Radius + self.missionData["brain"].Radius)
					then
						self.missionData["craft"]:OpenHatch()
					end
				end
			elseif self.missionData["brain"].ClassName ~= "ACDropShip" and self.missionData["brain"].ClassName ~= "ACRocket" then
				if not SceneMan:IsUnseen(self.missionData["brain"].Pos.X, self.missionData["brain"].Pos.Y, CF.PlayerTeam) then
					self:AddObjectivePoint(
						"KILL",
						self.missionData["brain"].AboveHUDPos,
						CF.PlayerTeam,
						GameActivity.ARROWDOWN
					)
				end
				if
					self.missionData["reinforcementsTriggered"]
					and self.Time >= self.missionData["reinforcementsLast"] + self.missionData["interval"]
				then
					if self.missionData["reinforcements"] == 0 then
						self.missionData["reinforcements"] = -1
						if self.missionData["brain"]:HasObject("Blueprint") then
							self.missionData["brain"]:RemoveInventoryItem("Blueprint")
							print("The enemy has destroyed the evidence!")
						end
						if self.missionData["brain"].AIMode ~= Actor.AIMODE_GOTO and CF.CountActors(CF.CPUTeam) == 0 then
							print("The enemy is making a run for it!")
							self.missionData["brain"].AIMode = Actor.AIMODE_GOTO
							self.missionData["brain"]:ClearMovePath()
							self.missionData["brain"]:AddAISceneWaypoint(
								SceneMan:MovePointToGround(Vector(self.missionData["brain"].Pos.X, 0), 0, 10)
									- Vector(0, self.missionData["brain"].Radius)
							)
							self.missionData["brain"]:UpdateMovePath()
						end
					end
				end
				if
					self.missionData["craft"] == nil
					and self.missionData["reinforcements"] < 0
					and self.missionData["craftCheckTime"] < self.Time
				then
					self.missionData["craftCheckTime"] = self.Time + 3
					if
						SceneMan:CastObstacleRay(
							self.missionData["brain"].Pos,
							Vector(0, -self.missionData["brain"].Pos.Y),
							Vector(),
							Vector(),
							self.missionData["brain"].ID,
							self.missionData["brain"].Team,
							rte.airID,
							10
						) < 0
					then
						local f = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])
						self.missionData["craft"] = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
							or CreateACDropShip("Dropship MK1", "Base.rte")
						self.missionData["craft"].Pos = Vector(self.missionData["brain"].Pos.X, -10)
						self.missionData["craft"].Team = self.missionData["brain"].Team
						self.missionData["craft"].AIMode = Actor.AIMODE_STAY
						MovableMan:AddActor(self.missionData["craft"])

						self.missionData["brain"].AIMode = Actor.AIMODE_GOTO
						self.missionData["brain"]:ClearMovePath()
						self.missionData["brain"]:AddAIMOWaypoint(self.missionData["craft"])
						self.missionData["brain"]:UpdateMovePath()
					end
				end
			end
		else
			for actor in MovableMan.Actors do
				if actor:HasObjectInGroup("MissionBrain") then
					self.missionData["brain"] = actor
					break
				end
			end
		end
		if not MovableMan:IsActor(self.missionData["brain"]) then
			if self.missionData["evacuated"] then
				self.missionData["stage"] = CF.MissionStages.FAILED
			else
				self.missionData["stage"] = CF.MissionStages.COMPLETED
				self:GiveMissionRewards()

				for actor in MovableMan.Actors do
					if actor.Team == CF.CPUTeam then
						-- Kill some of the actors
						if math.random(actor.MaxHealth * 1.5) > actor.Health then
							if math.random() < 0.5 then
								if math.random() < 0.5 and IsAHuman(actor) and ToAHuman(actor).Head then
									ToAHuman(actor).Head:GibThis()
								else
									actor:GibThis()
								end
							else
								actor.Health = 0
							end
						else
							-- The rest will scatter
							CF.HuntForActors(actor, Activity.NOTEAM)
						end
					end
				end
			end
			-- Remember when we started showing misison status message
			self.missionData["statusShowStart"] = self.Time
			self.missionData["missionEndTime"] = self.Time
		end

		-- Trigger reinforcements
		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				if
					not self.missionData["reinforcementsTriggered"]
					and actor.Status == Actor.STABLE
					and actor.Health > 0
					and actor.WoundCount > 0
					and math.random(100) > actor.Health
				then
					self.missionData["reinforcementsTriggered"] = true
					print("The enemy has been alerted!")
					self:MakeAlertSound(1)

					self.missionData["reinforcementsLast"] = self.Time
				end
			end
		end

		self.missionData["missionStatus"] = "COMMANDER ALIVE"

		-- Send reinforcements if available
		if self.missionData["reinforcementsTriggered"] then
			if self.Time >= self.missionData["reinforcementsLast"] + self.missionData["interval"] then
				self.missionData["reinforcementsLast"] = self.Time
				if
					self.missionData["reinforcements"] > 0
					and #self.missionData["landingZones"] > 0
				then
					self.missionData["reinforcements"] = self.missionData["reinforcements"] - 1

					local count = math.random(2, 3)
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
			--[[
			if self.Time < self.missionData["reinforcementsLast"] + self.missionData["interval"] and self.Time % 3 == 0 then
				self:MakeAlertSound()
			end
			]]
			--
		end

		-- Trigger 'counterattack', send every second actor to attack player troops
		if
			not self.missionData["counterAttackTriggered"]
			and self.missionData["counterAttackDelay"] > 0
			and self.Time >= self.missionData["missionStartTime"] + self.missionData["counterAttackDelay"]
		then
			self.missionData["counterAttackTriggered"] = true
			print("COUNTERATTACK!")
			self:StartMusic(CF.MusicTypes.MISSION_ACTIVE)

			local count = 0

			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam and not actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
					count = count + 1

					if count % 2 == 0 then
						CF.HuntForActors(actor, CF.PlayerTeam)
					end
				end
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.FAILED then
		self.missionData["missionStatus"] = "MISSION FAILED"

		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.DEFEAT)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.missionData["missionStatus"] = "MISSION COMPLETED"

		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end

		if self.Time < self.missionData["missionEndTime"] + 25 then
			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam and math.random() < 0.1 then
					actor:GetController():SetState(Controller.WEAPON_FIRE, true)
					if actor.AIMode == Actor.AIMODE_SENTRY then
						actor.AIMode = Actor.AIMODE_PATROL
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
