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
		) - 0.5
	)

	-- Spawn commander
	local cmndrpts = CF_GetPointsArray(self.Pts, "Assassinate", set, "Commander")
	local cpos = cmndrpts[math.random(#cmndrpts)]

	self.MissionBrain = CF_MakeBrain(self.GS, self.MissionTargetPlayer, CF_CPUTeam, cpos, true)
	local setRank = math.min(self.MissionDifficulty - 1, CF_Ranks[#CF_Ranks])
	self.MissionBrain:SetNumberValue("VW_Rank", setRank)
	CF_BuffActor(self.MissionBrain, setRank, 0)

	if self.MissionBrain then
		self.MissionBrain:AddToGroup("MissionBrain")
		--self.MissionBrain:RemoveFromGroup("Brains")
		MovableMan:AddActor(self.MissionBrain)
		if math.random(CF_MaxDifficulty) <= self.MissionDifficulty then
			self.MissionBrain:AddInventoryItem(CreateHeldDevice("Blueprint", CF_ModuleName))
		end
	else
		error("Can't create CPU brain")
	end
	self.MissionCraft = nil
	self.MissionCraftCheckTime = self.Time

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1, FAILED = 2 }
	self.MissionStage = self.MissionStages.ACTIVE

	self.MissionReinforcementsTriggered = false
	self.CounterAttackTriggered = false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		self.MissionFailed = true --??
		local count = 0

		-- Start checking for victory only when all units were spawned
		if self.SpawnTable == nil then
			if MovableMan:IsActor(self.MissionBrain) and self.MissionBrain:HasObjectInGroup("MissionBrain") then
				if MovableMan:IsActor(self.MissionCraft) then
					if self.MissionCraft:HasObjectInGroup("MissionBrain") then
						if self.MissionCraft.Status == Actor.STABLE then
							self.MissionCraft:CloseHatch()
						end
						self.MissionCraft.AIMode = Actor.AIMODE_RETURN
						self:AddObjectivePoint(
							"DESTROY!",
							self.MissionBrain.AboveHUDPos,
							CF_PlayerTeam,
							GameActivity.ARROWDOWN
						)
					else
						self:AddObjectivePoint(
							"KILL",
							self.MissionBrain.AboveHUDPos,
							CF_PlayerTeam,
							GameActivity.ARROWDOWN
						)
						if
							self.MissionCraft.HatchState == ACraft.CLOSED
							and SceneMan
								:ShortestDistance(
									self.MissionCraft.Pos + Vector(0, self.MissionCraft.Radius * 0.5),
									self.MissionBrain.Pos,
									SceneMan.SceneWrapsX
								)
								:MagnitudeIsLessThan(self.MissionCraft.Radius + self.MissionBrain.Radius)
						then
							self.MissionCraft:OpenHatch()
						end
					end
				elseif self.MissionBrain.ClassName ~= "ACDropShip" and self.MissionBrain.ClassName ~= "ACRocket" then
					if not SceneMan:IsUnseen(self.MissionBrain.Pos.X, self.MissionBrain.Pos.Y, CF_PlayerTeam) then
						self:AddObjectivePoint(
							"KILL",
							self.MissionBrain.AboveHUDPos,
							CF_PlayerTeam,
							GameActivity.ARROWDOWN
						)
					end
					if
						self.MissionReinforcementsTriggered
						and self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"]
					then
						if self.MissionSettings["Reinforcements"] == 0 then
							self.MissionSettings["Reinforcements"] = -1
							if self.MissionBrain:HasObject("Blueprint") then
								self.MissionBrain:RemoveInventoryItem("Blueprint")
								print("The enemy has destroyed the evidence!")
							end
							if self.MissionBrain.AIMode ~= Actor.AIMODE_GOTO and CF_CountActors(CF_CPUTeam) == 0 then
								print("The enemy is making a run for it!")
								self.MissionBrain.AIMode = Actor.AIMODE_GOTO
								self.MissionBrain:ClearMovePath()
								self.MissionBrain:AddAISceneWaypoint(
									SceneMan:MovePointToGround(Vector(self.MissionBrain.Pos.X, 0), 0, 10)
										- Vector(0, self.MissionBrain.Radius)
								)
								self.MissionBrain:UpdateMovePath()
							end
						end
					end
					if
						self.MissionCraft == nil
						and self.MissionSettings["Reinforcements"] < 0
						and self.MissionCraftCheckTime < self.Time
					then
						self.MissionCraftCheckTime = self.Time + 3
						if
							SceneMan:CastObstacleRay(
								self.MissionBrain.Pos,
								Vector(0, -self.MissionBrain.Pos.Y),
								Vector(),
								Vector(),
								self.MissionBrain.ID,
								self.MissionBrain.Team,
								rte.airID,
								10
							) < 0
						then
							local f = CF_GetPlayerFaction(self.GS, self.MissionTargetPlayer)
							self.MissionCraft = CF_MakeActor(CF_Crafts[f], CF_CraftClasses[f], CF_CraftModules[f])
								or CreateACDropShip("Dropship MK1", "Base.rte")
							self.MissionCraft.Pos = Vector(self.MissionBrain.Pos.X, -10)
							self.MissionCraft.Team = self.MissionBrain.Team
							self.MissionCraft.AIMode = Actor.AIMODE_STAY
							MovableMan:AddActor(self.MissionCraft)

							self.MissionBrain.AIMode = Actor.AIMODE_GOTO
							self.MissionBrain:ClearMovePath()
							self.MissionBrain:AddAIMOWaypoint(self.MissionCraft)
							self.MissionBrain:UpdateMovePath()
						end
					end
				end
			else
				for actor in MovableMan.Actors do
					if actor:HasObjectInGroup("MissionBrain") then
						self.MissionBrain = actor
						break
					end
				end
			end
			if not MovableMan:IsActor(self.MissionBrain) then
				if self.MissionSettings["Evacuated"] then
					self.MissionStage = self.MissionStages.FAILED
				else
					self.MissionStage = self.MissionStages.COMPLETED
					self:GiveMissionRewards()

					for actor in MovableMan.Actors do
						if actor.Team == CF_CPUTeam then
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
								CF_HuntForActors(actor, Activity.NOTEAM)
							end
						end
					end
				end
				-- Remember when we started showing misison status message
				self.MissionStatusShowStart = self.Time
				self.MissionEnd = self.Time
			end
		end

		-- Trigger reinforcements
		for actor in MovableMan.Actors do
			if actor.Team == CF_CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				if
					not self.MissionReinforcementsTriggered
					and actor.Status == Actor.STABLE
					and actor.Health > 0
					and actor.WoundCount > 0
					and math.random(100) > actor.Health
				then
					self.MissionReinforcementsTriggered = true
					print("The enemy has been alerted!")
					self:MakeAlertSound()

					self.MissionLastReinforcements = self.Time
				end
			end
		end

		self.MissionStatus = "COMMANDER ALIVE"

		-- Send reinforcements if available
		if self.MissionReinforcementsTriggered then
			if self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"] then
				self.MissionLastReinforcements = self.Time
				if
					self.MissionSettings["Reinforcements"] > 0
					and #self.MissionLZs > 0
					and MovableMan:GetMOIDCount() < CF_MOIDLimit
				then
					self.MissionSettings["Reinforcements"] = self.MissionSettings["Reinforcements"] - 1

					local count = math.random(2, 3)
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
			--[[
			if self.Time < self.MissionLastReinforcements + self.MissionSettings["Interval"] and self.Time % 3 == 0 then
				self:MakeAlertSound()
			end
			]]
			--
		end

		-- Trigger 'counterattack', send every second actor to attack player troops
		if
			not self.CounterAttackTriggered
			and self.MissionSettings["CounterAttackDelay"] > 0
			and self.Time >= self.MissionStart + self.MissionSettings["CounterAttackDelay"]
		then
			self.CounterAttackTriggered = true
			print("COUNTERATTACK!")
			self:StartMusic(CF_MusicTypes.MISSION_ACTIVE)

			local count = 0

			for actor in MovableMan.Actors do
				if actor.Team == CF_CPUTeam and not actor:IsInGroup("Brains") then
					count = count + 1

					if count % 2 == 0 then
						CF_HuntForActors(actor, CF_PlayerTeam)
					end
				end
			end
		end
	elseif self.MissionStage == self.MissionStages.FAILED then
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF_MusicTypes.DEFEAT)
			self.MissionEndMusicPlayed = true
		end
		if self.Time < self.MissionStatusShowStart + CF_MissionResultShowInterval then
			for p = 0, self.PlayerCount - 1 do
				FrameMan:ClearScreenText(p)
				FrameMan:SetScreenText(self.MissionStatus, p, 0, 1000, true)
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

		if self.Time < self.MissionEnd + 25 then
			for actor in MovableMan.Actors do
				if actor.Team == CF_CPUTeam and math.random() < 0.1 then
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
