-----------------------------------------------------------------------------------------
--	Objective: 	Kill enemy brain unit
--	Set used: 	Enemy, Assassinate
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				half of it's actors. Initial spawn rate varies based on mission difficulty.
--				After commander's death units go nuts for a few moments
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("ASSASSINATE CREATE")
	-- Wipe data
	self.missionData = {}

	-- Mission constants and enums
	self.MissionStages = { ACTIVE = 0, COMPLETED = 1, FAILED = 2 }
	local setts = {}
	setts[1] = {}
	setts[1]["SpawnRate"] = 0.30
	setts[1]["Reinforcements"] = 0
	setts[1]["Interval"] = 10
	setts[1]["CounterAttackDelay"] = 0

	setts[2] = {}
	setts[2]["SpawnRate"] = 0.40
	setts[2]["Reinforcements"] = 1
	setts[2]["Interval"] = 30
	setts[2]["CounterAttackDelay"] = 340

	setts[3] = {}
	setts[3]["SpawnRate"] = 0.50
	setts[3]["Reinforcements"] = 2
	setts[3]["Interval"] = 28
	setts[3]["CounterAttackDelay"] = 300

	setts[4] = {}
	setts[4]["SpawnRate"] = 0.60
	setts[4]["Reinforcements"] = 3
	setts[4]["Interval"] = 26
	setts[4]["CounterAttackDelay"] = 260

	setts[5] = {}
	setts[5]["SpawnRate"] = 0.70
	setts[5]["Reinforcements"] = 4
	setts[5]["Interval"] = 24
	setts[5]["CounterAttackDelay"] = 220

	setts[6] = {}
	setts[6]["SpawnRate"] = 0.80
	setts[6]["Reinforcements"] = 5
	setts[6]["Interval"] = 22
	setts[6]["CounterAttackDelay"] = 180

	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		self.missionData["missionStart"] = self.Time
		self.missionData["settings"] = setts[self.MissionDifficulty]

		self.missionData["pointSetIndex"] = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")

		-- Use generic enemy set
		self:DeployGenericMissionEnemies(
			self.missionData["pointSetIndex"],
			"Enemy",
			self.MissionTargetPlayer,
			CF.CPUTeam,
			self.missionData["settings"]["SpawnRate"]
		)
		self:DeployInfantryMines(
			CF.CPUTeam,
			math.min(
				-tonumber(self.GS["Player" .. self.MissionTargetPlayer .. "Reputation"])
					/ (CF.MaxDifficulty * CF.ReputationPerDifficulty),
				1
			) - 0.5
		)

		-- Spawn commander
		local cmndrpts = CF.GetPointsArray(self.Pts, "Assassinate", self.missionData["pointSetIndex"], "Commander")
		local cpos = cmndrpts[math.random(#cmndrpts)]

		self.missionData["brain"] = CF.MakeRPGBrain(self.GS, self.MissionTargetPlayer, CF.CPUTeam, cpos, math.floor(self.MissionDifficulty / 3), true)

		if self.missionData["brain"] then
			self.missionData["brain"]:AddToGroup("MissionBrain")
			MovableMan:AddActor(self.missionData["brain"])
			if math.random(CF.MaxDifficulty) <= self.MissionDifficulty then
				self.missionData["brain"]:AddInventoryItem(CreateHeldDevice("Blueprint", CF.ModuleName))
			end
		end

		self.missionData["craft"] = nil
		self.missionData["craftCheckTime"] = self.Time

		self.missionData["stage"] = self.MissionStages.ACTIVE

		self.missionData["reinforcementsTriggered"] = false
		self.missionData["reinforcementsLast"] = 0
		self.missionData["counterAttackTriggered"] = false
	end	
	print("ASSASSINATE CREATED")
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == self.MissionStages.ACTIVE then
		self.MissionCompleted = false
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
					and self.Time >= self.missionData["reinforcementsLast"] + self.missionData["settings"]["Interval"]
				then
					if self.missionData["settings"]["Reinforcements"] == 0 then
						self.missionData["settings"]["Reinforcements"] = -1
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
					and self.missionData["settings"]["Reinforcements"] < 0
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
						local f = CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)
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
			if self.missionData["settings"]["Evacuated"] then
				self.missionData["stage"] = self.MissionStages.FAILED
			else
				self.missionData["stage"] = self.MissionStages.COMPLETED
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
			self.MissionStatusShowStart = self.Time
			self.MissionEnd = self.Time
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

		self.MissionStatus = "COMMANDER ALIVE"

		-- Send reinforcements if available
		if self.missionData["reinforcementsTriggered"] then
			if self.Time >= self.missionData["reinforcementsLast"] + self.missionData["settings"]["Interval"] then
				self.missionData["reinforcementsLast"] = self.Time
				if
					self.missionData["settings"]["Reinforcements"] > 0
					and #self.MissionLZs > 0
				then
					self.missionData["settings"]["Reinforcements"] = self.missionData["settings"]["Reinforcements"] - 1

					local count = math.random(2, 3)
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
						ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
						ship.AIMode = Actor.AIMODE_DELIVER
						MovableMan:AddActor(ship)
					end
				end
			end
			--[[
			if self.Time < self.missionData["reinforcementsLast"] + self.missionData["settings"]["Interval"] and self.Time % 3 == 0 then
				self:MakeAlertSound()
			end
			]]
			--
		end

		-- Trigger 'counterattack', send every second actor to attack player troops
		if
			not self.missionData["counterAttackTriggered"]
			and self.missionData["settings"]["CounterAttackDelay"] > 0
			and self.Time >= self.missionData["missionStart"] + self.missionData["settings"]["CounterAttackDelay"]
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
	elseif self.missionData["stage"] == self.MissionStages.FAILED then
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
	elseif self.missionData["stage"] == self.MissionStages.COMPLETED then
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end
		self.MissionStatus = "MISSION COMPLETED"

		if self.Time < self.MissionStatusShowStart + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end

		if self.Time < self.MissionEnd + 25 then
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
