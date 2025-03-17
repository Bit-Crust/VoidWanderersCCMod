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
	print("COUNTERATTACK CREATE")
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["SpawnRate"] = 0.60
	setts[1]["Reinforcements"] = 3
	setts[1]["Interval"] = 20
	setts[1]["CounterAttackDelay"] = 30

	setts[2] = {}
	setts[2]["SpawnRate"] = 0.60
	setts[2]["Reinforcements"] = 5
	setts[2]["Interval"] = 20
	setts[2]["CounterAttackDelay"] = 25

	setts[3] = {}
	setts[3]["SpawnRate"] = 0.70
	setts[3]["Reinforcements"] = 7
	setts[3]["Interval"] = 20
	setts[3]["CounterAttackDelay"] = 20

	setts[4] = {}
	setts[4]["SpawnRate"] = 0.80
	setts[4]["Reinforcements"] = 10
	setts[4]["Interval"] = 20
	setts[4]["CounterAttackDelay"] = 16

	setts[5] = {}
	setts[5]["SpawnRate"] = 0.90
	setts[5]["Reinforcements"] = 13
	setts[5]["Interval"] = 20
	setts[5]["CounterAttackDelay"] = 12

	setts[6] = {}
	setts[6]["SpawnRate"] = 1
	setts[6]["Reinforcements"] = 16
	setts[6]["Interval"] = 20
	setts[6]["CounterAttackDelay"] = 10

	--print ("DIFF: "..self.MissionDifficulty )

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time

	self.MissionSourcePlayer = self.AssaultEnemyPlayer

	-- Use generic enemy set
	local set = CF["GetRandomMissionPointsSet"](self.Pts, "Enemy")

	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.MissionSourcePlayer,
		CF["CPUTeam"],
		self.MissionSettings["SpawnRate"]
	)

	-- Spawn commander
	local cmndrpts = CF["GetPointsArray"](self.Pts, "Assassinate", set, "Commander")
	local cpos = cmndrpts[math.random(#cmndrpts)]

	self.MissionBrain = CF["MakeBrain"](self.GS, self.MissionSourcePlayer, CF["CPUTeam"], cpos, true)
	if self.MissionBrain then
		MovableMan:AddActor(self.MissionBrain)
		if math.random(CF["MaxDifficulty"]) <= self.MissionDifficulty then
			self.MissionBrain:AddInventoryItem(CreateHeldDevice("Blueprint", CF["ModuleName"]))
		end
	else
		error("Can't create CPU brain")
	end

	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = CF["CPUTeam"]
		end
	end

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1 }
	self.MissionStage = self.MissionStages.ACTIVE

	self.MissionReinforcementsTriggered = true
	self.MissionLastReinforcements = self.Time
	self.CounterAttackTriggered = false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		self.MissionCompleted = false
		local count = 0

		-- Start checking for victory only when all units were spawned
		if self.SpawnTable == nil then
			if MovableMan:IsActor(self.MissionBrain) then
				if not SceneMan:IsUnseen(self.MissionBrain.Pos.X, self.MissionBrain.Pos.Y, CF["PlayerTeam"]) then
					self:AddObjectivePoint("KILL", self.MissionBrain.AboveHUDPos, CF["PlayerTeam"], GameActivity.ARROWDOWN)
				end
				if
					self.MissionReinforcementsTriggered
					and self.MissionSettings["Reinforcements"] == 0
					and self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"]
				then
					self.MissionSettings["Reinforcements"] = -1
					if self.MissionBrain:HasObject("Blueprint") then
						self.MissionBrain:RemoveInventoryItem("Blueprint")
						print("The enemy has destroyed the evidence!")
					end
				end
			else
				for actor in MovableMan.Actors do
					if actor.Team == CF["CPUTeam"] then
						-- Kill some of the actors
						if math.random() * actor.MaxHealth * 1.5 > actor.Health then
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
							CF["HuntForActors"](actor, Activity.NOTEAM)
						end
					end
				end

				self.MissionReputationReward = CF["CalculateReward"](
					CF["ReputationPerDifficulty"] * 0.5,
					self.MissionDifficulty
				)
				self.MissionGoldReward = 0
				self:GiveMissionRewards(true)
				self.MissionStage = self.MissionStages.COMPLETED

				-- Remember when we started showing misison status message
				self.MissionStatusShowStart = self.Time
				self.MissionEnd = self.Time
			end
		end

		-- Trigger reinforcements
		for actor in MovableMan.Actors do
			if actor.Team == CF["CPUTeam"] and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				if
					not self.MissionReinforcementsTriggered
					and (
						self.CounterAttackTriggered
						or (
							actor.Status == Actor.STABLE
							and actor.WoundCount > 0
							and actor.Health > 0
							and math.random(100) > actor.Health
						)
					)
				then
					self.MissionReinforcementsTriggered = true
					print("The enemy has been alerted!")
					self:MakeAlertSound(1)

					self.MissionLastReinforcements = self.Time
				end
			end
		end

		self.MissionStatus = "COMMANDER ALIVE"

		-- Send reinforcements if available
		if
			self.MissionReinforcementsTriggered
			and #self.MissionLZs > 0
			and self.MissionSettings["Reinforcements"] > 0
			and self.Time >= self.MissionLastReinforcements + self.MissionSettings["Interval"]
		then
			if MovableMan:GetMOIDCount() < CF["MOIDLimit"] then
				self.MissionLastReinforcements = self.Time

				local count = math.min(math.random(2), self.MissionSettings["Reinforcements"])
				for i = 1, count do
					self.MissionSettings["Reinforcements"] = self.MissionSettings["Reinforcements"] - 1
					local actor = CF["SpawnAIUnit"](
						self.GS,
						self.AssaultEnemyPlayer,
						CF["CPUTeam"],
						self.MissionLZs[math.random(#self.MissionLZs)],
						Actor.AIMODE_BRAINHUNT
					)
					if actor then
						MovableMan:AddActor(actor)
					end
				end
			end
		end

		-- Trigger 'counterattack' and send every actor to attack player troops!
		if
			not self.CounterAttackTriggered
			and self.MissionSettings["CounterAttackDelay"] > 0
			and self.Time >= self.MissionStart + self.MissionSettings["CounterAttackDelay"]
		then
			self.CounterAttackTriggered = true

			local count = 0

			for actor in MovableMan.Actors do
				if actor.Team == CF["CPUTeam"] and not actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
					CF["HuntForActors"](actor, CF["PlayerTeam"])
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

		for actor in MovableMan.Actors do
			if actor.Team == CF["CPUTeam"] then
				if actor.AIMode == Actor.AIMODE_SENTRY then
					actor.AIMode = Actor.AIMODE_PATROL
				end
				actor.Health = actor.Health - 0.1
				local cont = actor:GetController()
				if cont then
					cont:SetState(Controller.WEAPON_FIRE, not cont:IsState(Controller.WEAPON_FIRE))
				end
			end
		end
	end --]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
