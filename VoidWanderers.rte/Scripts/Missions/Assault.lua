-----------------------------------------------------------------------
--	Objective: 	Kill all CF.CPUTeam enemies inside the Enemy::Base box set
--	Set used: 	Enemy
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ASSAULT CREATE");
	
	-- Mission difficulty settings
	local diff = self.missionData["difficulty"];

	if diff == 1 then
		self.missionData["spawnRate"] = 0.20;
		self.missionData["reinforcements"] = 0; 
		self.missionData["interval"] = 45;
		self.missionData["counterAttackDelay"] = 0;
	elseif diff == 2 then
		self.missionData["spawnRate"] = 0.35;
		self.missionData["reinforcements"] = 0;
		self.missionData["interval"] = 45;
		self.missionData["counterAttackDelay"] = 300;
	elseif diff == 3 then
		self.missionData["spawnRate"] = 0.50;
		self.missionData["reinforcements"] = 1;
		self.missionData["interval"] = 45;
		self.missionData["counterAttackDelay"] = 260;
	elseif diff == 4 then
		self.missionData["spawnRate"] = 0.65;
		self.missionData["reinforcements"] = 2;
		self.missionData["interval"] = 45;
		self.missionData["counterAttackDelay"] = 190;
	elseif diff == 5 then
		self.missionData["spawnRate"] = 0.80;
		self.missionData["reinforcements"] = 3;
		self.missionData["interval"] = 40;
		self.missionData["counterAttackDelay"] = 130;
	elseif diff == 6 then
		self.missionData["spawnRate"] = 0.90;
		self.missionData["reinforcements"] = 4;
		self.missionData["interval"] = 35;
		self.missionData["counterAttackDelay"] = 90;
	end
	
	for actor in MovableMan.AddedActors do
		if actor.ClassName == "ADoor" then
			actor.Team = CF.CPUTeam;
		end
	end

	-- Use generic enemy set
	local target = self.missionData["missionTarget"];
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy");

	-- Get enemies placed
	self:DeployGenericMissionEnemies(set, "Enemy", target, CF.CPUTeam, self.missionData["spawnRate"]);

	-- Get LZs
	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Enemy", set, "LZ");

	-- Get base
	self:ObtainBaseBoxes("Enemy", set);

	-- Deploy mines
	local rate = math.min(-tonumber(self.GS["Player" .. target .. "Reputation"]) / (CF.MaxDifficulty * CF.ReputationPerDifficulty), 1) - 0.75;
	self:DeployInfantryMines(CF.CPUTeam, rate);
	
	self.missionData["craft"] = nil;
	self.missionData["craftCheckTime"] = self.Time;

	self.missionData["reinforcementsTriggered"] = false;
	self.missionData["reinforcementsLast"] = 0;
	self.missionData["reinforcementsFirst"] = 0;
	self.missionData["counterAttackTriggered"] = false;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local count = 0;
		
		for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
			if actor.Team == CF.CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				local inside = false;
				count = count + 1;

				for i = 1, #self.missionData["missionBase"] do
					if self.missionData["missionBase"][i]:IsWithinBox(actor.Pos) then
						inside = true;
						break;
					end
				end

				if not self.missionData["reinforcementsTriggered"] then
					if actor.Health > 0 and math.random(100) > actor.Health then
						self.missionData["reinforcementsTriggered"] = true;
						self.missionData["reinforcementsLast"] = self.Time;
						self.missionData["reinforcementsFirst"] = self.Time;
					end
				elseif self.missionData["counterAttackTriggered"] then
					if count % 3 == 0 then
						CF.HuntForActors(actor, CF.PlayerTeam);
					end
				end
			end
		end end

		self.missionData["missionStatus"] = "Enemies left: " .. tostring(count);

		-- Start checking for victory only when all units were spawned
		if count == 0 then
			self:GiveMissionRewards();
			self.missionData["stage"] = CF.MissionStages.COMPLETED;

			-- Remember when we started showing misison status message
			self.missionData["statusShowStart"] = self.Time;
			self.missionData["missionEndTime"] = self.Time;
		end

		-- Send reinforcements if available
		if self.missionData["reinforcementsTriggered"] and self.Time >= self.missionData["reinforcementsLast"] + self.missionData["interval"] then
			if #self.missionData["landingZones"] > 0 and self.missionData["reinforcements"] > 0 then
				local count = math.random(2);
				local faction = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"]);
				local ship = CF.MakeActor(CF.CraftClasses[faction], CF.Crafts[faction], CF.CraftModules[faction]);

				if ship then
					for i = 1, count do
						local actor = CF.MakeUnit(self.GS, self.missionData["missionTarget"]);

						if actor then
							actor.Team = CF.CPUTeam;
							actor.AIMode = math.random() < 0.5 and Actor.AIMODE_PATROL or Actor.AIMODE_BRAINHUNT;
							ship:AddInventoryItem(actor);
						end
					end

					if ship.Inventory() then
						ship.Team = CF.CPUTeam;
						ship.Pos = Vector(self.missionData["landingZones"][math.random(#self.missionData["landingZones"])].X, -20);
						ship.Vel = Vector(0, 3);
						ship.AIMode = Actor.AIMODE_DELIVER;
						MovableMan:AddActor(ship);

						if self.missionData["reinforcementsLast"] == self.missionData["reinforcementsFirst"] then
							self:StartMusic(CF.MusicTypes.MISSION_INTENSE);
						end

						self.missionData["reinforcements"] = self.missionData["reinforcements"] - 1;
					end
				end
			end

			self.missionData["reinforcementsLast"] = self.Time;
		end

		-- Trigger 'counterattack', send every third actor to attack player troops
		if
			self.missionData["reinforcementsTriggered"]
			and not self.missionData["counterAttackTriggered"]
			and self.missionData["counterAttackDelay"] > 0
			and self.Time >= self.missionData["reinforcementsFirst"] + self.missionData["counterAttackDelay"]
		then
			self.missionData["reinforcementsTriggered"] = true
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.missionData["missionStatus"] = "MISSION COMPLETED";

		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.VICTORY);
			self.missionData["endMusicPlayed"] = true;
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player);
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true);
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
