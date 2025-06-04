-----------------------------------------------------------------------
--	Objective: 	Kill enemy brain unit
--	Set used: 	Enemy, Assassinate
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				half of it's actors. Initial spawn rate varies based on mission difficulty.
--				After commander's death units go nuts for a few moments
--
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("COUNTERATTACK CREATE")

	-- Mission difficulty settings
	self.missionData["advanceMissions"] = false;
	self.missionData["missionContractor"] = self.GS["LocationInhabitants"];
	local diff = self.missionData["difficulty"];
	
	if diff == 1 then
		self.missionData["spawnRate"] = 0.60;
		self.missionData["reinforcements"] = 3;
		self.missionData["interval"] = 20;
		self.missionData["counterAttackDelay"] = 30;
	elseif diff == 2 then
		self.missionData["spawnRate"] = 0.60;
		self.missionData["reinforcements"] = 5;
		self.missionData["interval"] = 20;
		self.missionData["counterAttackDelay"] = 25;
	elseif diff == 3 then
		self.missionData["spawnRate"] = 0.70;
		self.missionData["reinforcements"] = 7;
		self.missionData["interval"] = 20;
		self.missionData["counterAttackDelay"] = 20;
	elseif diff == 4 then
		self.missionData["spawnRate"] = 0.80;
		self.missionData["reinforcements"] = 10;
		self.missionData["interval"] = 20;
		self.missionData["counterAttackDelay"] = 16;
	elseif diff == 5 then
		self.missionData["spawnRate"] = 0.90;
		self.missionData["reinforcements"] = 13;
		self.missionData["interval"] = 20;
		self.missionData["counterAttackDelay"] = 12;
	elseif diff == 6 then
		self.missionData["spawnRate"] = 1;
		self.missionData["reinforcements"] = 16;
		self.missionData["interval"] = 20;
		self.missionData["counterAttackDelay"] = 10;
	end

	-- Use generic enemy set
	self.missionData["cloneSpawn"] = Vector(0, 0);
	local x = tonumber(self.SceneConfig["ClonesInputX"]);
	local y = tonumber(self.SceneConfig["ClonesInputY"]);
	if x and y then
		self.missionData["cloneSpawn"] = Vector(x, y);
	end

	local set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy");

	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.missionData["missionContractor"],
		CF.CPUTeam,
		self.missionData["spawnRate"]
	);

	-- Spawn commander
	local cmndrpts = CF.GetPointsArray(self.Pts, "Assassinate", set, "Commander")
	local cpos = cmndrpts[math.random(#cmndrpts)]

	local faction = CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"]);
	local brain = CF.MakeRPGBrain(faction, true, math.floor((diff + math.random()) * 10));

	if brain then
		brain.Team = Activity.TEAM_2;
		brain.Pos = cpos;
		brain.AIMode = Actor.AIMODE_SENTRY;
		MovableMan:AddActor(brain);
		if math.random(CF.MaxDifficulty) <= self.missionData["difficulty"] then
			brain:AddInventoryItem(CF.CreateBluePrint(self.GS, faction));
		end
		self.missionData["brain"] = brain;
	end
	
	for actor in MovableMan.AddedActors do
		if actor.ClassName == "ADoor" then
			actor.Team = CF.CPUTeam;
		end
	end

	self.missionData["reinforcementsTriggered"] = true
	self.missionData["reinforcementsLast"] = tonumber(self.GS["Time"])
	self.missionData["counterAttackTriggered"] = false
	
	self.encounterData = {};
	self.EncounterUpdate = nil;
	self.EncounterCreate = nil;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local count = 0

		-- Start checking for victory only when all units were spawned
		if MovableMan:IsActor(self.missionData["brain"]) then
			if not SceneMan:IsUnseen(self.missionData["brain"].Pos.X, self.missionData["brain"].Pos.Y, CF.PlayerTeam) then
				self:AddObjectivePoint("KILL", self.missionData["brain"].AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
			end
			if
				self.missionData["reinforcementsTriggered"]
				and self.missionData["reinforcements"] == 0
				and tonumber(self.GS["Time"]) >= self.missionData["reinforcementsLast"] + self.missionData["interval"]
			then
				self.missionData["reinforcements"] = -1
				if self.missionData["brain"]:HasObject("Blueprint") then
					self.missionData["brain"]:RemoveInventoryItem("Blueprint")
					print("The enemy has destroyed the evidence!")
				end
			end
		else
			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam then
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
						CF.HuntForActors(actor, Activity.NOTEAM)
					end
				end
			end

			self.missionData["reputationReward"] = CF.CalculateReward(
				CF.ReputationPerDifficulty * 0.5,
				self.missionData["difficulty"]
			) * (0.9 + 0.2 * math.random());

			self.missionData["goldReward"] = 0;
			self:GiveMissionRewards(true);
			self.missionData["stage"] = CF.MissionStages.COMPLETED;

			self.missionData["statusShowStart"] = tonumber(self.GS["Time"]);
			self.missionData["missionEndTime"] = tonumber(self.GS["Time"]);
		end

		-- Trigger reinforcements
		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				if
					not self.missionData["reinforcementsTriggered"]
					and (
						self.missionData["counterAttackTriggered"]
						or (
							actor.Status == Actor.STABLE
							and actor.WoundCount > 0
							and actor.Health > 0
							and math.random(100) > actor.Health
						)
					)
				then
					self.missionData["reinforcementsTriggered"] = true
					print("The enemy has been alerted!")
					self:MakeAlertSound(1)

					self.missionData["reinforcementsLast"] = tonumber(self.GS["Time"])
				end
			end
		end

		self.missionData["missionStatus"] = "COMMANDER ALIVE"

		-- Send reinforcements if available
		if
			self.missionData["reinforcementsTriggered"]
			and self.missionData["cloneSpawn"]
			and self.missionData["reinforcements"] > 0
			and tonumber(self.GS["Time"]) >= self.missionData["reinforcementsLast"] + self.missionData["interval"]
		then
			if MovableMan:GetMOIDCount() < CF.MOIDLimit then
				self.missionData["reinforcementsLast"] = tonumber(self.GS["Time"])

				local count = math.min(math.random(2), self.missionData["reinforcements"])
				for i = 1, count do
					self.missionData["reinforcements"] = self.missionData["reinforcements"] - 1
					local actor = CF.MakeUnit(self.GS, self.missionData["missionContractor"])
					
					if actor then
						actor.Team = CF.CPUTeam;
						actor.Pos = self.missionData["cloneSpawn"];
						actor.AIMode = Actor.AIMODE_BRAINHUNT;
						MovableMan:AddActor(actor);
					end
				end
			end
		end

		-- Trigger 'counterattack' and send every actor to attack player troops!
		if
			not self.missionData["counterAttackTriggered"]
			and self.missionData["counterAttackDelay"] > 0
			and tonumber(self.GS["Time"]) >= self.missionData["missionStartTime"] + self.missionData["counterAttackDelay"]
		then
			self.missionData["counterAttackTriggered"] = true

			local count = 0

			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam and not CF.IsBrain(actor) then
					CF.HuntForActors(actor, CF.PlayerTeam)
				end
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.missionData["missionStatus"] = "MISSION COMPLETED"

		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.missionData["endMusicPlayed"] = true
		end

		if tonumber(self.GS["Time"]) < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end

		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam then
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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
