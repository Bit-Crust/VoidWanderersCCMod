-----------------------------------------------------------------------
--	Generic mission script which is executed when no mission assigned and when no other
--	default script is specified for location
-----------------------------------------------------------------------
--	Generic events:
--
--	Periodically script will spawn a dropship with 1-3 units based on scene difficulty level.
-- 	Units will try to protect their own miners or if there's no any will try to find and kill
--	enemy miners.
--
--	Difficulty 2+:
--
--	Rarely script will spawn a dropship with 3 units of the mest agressive CPU player which
--	will switch to brain hunt mode. If custom AI is enabled the will search and destroy any
--	enemy actors, if not they will probably move to player LZ's since they are brain units
--
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("GENERIC CREATE");

	-- Enumerated constant
	self.missionData["defaultHostilities"] = { Activity.TEAM_1, Activity.TEAM_4, Activity.TEAM_3 };

	-- Load some positional data
	local pointSetIndex = CF.GetRandomMissionPointsSet(self.Pts, "Deploy");
	local ambientEnemyLocations = CF.GetPointsArray(self.Pts, "Deploy", pointSetIndex, "AmbientEnemy");
	self.missionData["enemyLandingZones"] = CF.GetPointsArray(self.Pts, "Deploy", pointSetIndex, "EnemyLZ");
	local ambientEnemyQuantity = math.ceil(CF.AmbientEnemyRate * #ambientEnemyLocations);
	local ambientEnemyPositions = CF.RandomSampleOfList(ambientEnemyLocations, ambientEnemyQuantity);

	local team1Player = 1;
		
	-- Find player's enemies
	local activeCPUs = tonumber(self.GS["ActiveCPUs"]);
	local team2Player = CF.GetAngriestPlayer(self.GS);
	local team3Player = math.random(2, activeCPUs);
	local team4Player = math.random(2, activeCPUs - 1);
	
	if team4Player >= team3Player then
		team4Player = team4Player + 1;
	end

	self.missionData["teamParticipants"] = { team2Player, team3Player, team4Player };
	
	for i = Activity.TEAM_2, Activity.MAXTEAMCOUNT - 1 do
		local teamParticipant = self.missionData["teamParticipants"][i];
		local faction = CF.GetPlayerFaction(self.GS, teamParticipant);
		local techLevel = CF.GetTechLevelFromDifficulty(faction, self.missionData["difficulty"]);
		CF.CreateAIUnitPresets(self.GS, teamParticipant, techLevel);
	end

	-- Place some ambient randos
	for i = 1, #ambientEnemyPositions do
		local preset = math.random(CF.PresetTypes.ENGINEER)
		local team = (i % 2 == 0) and Activity.TEAM_3 or Activity.TEAM_4
		local player = (i % 2 == 0) and team3Player or team4Player
		local aimode = Actor.AIMODE_GOLDDIG
		local pos = ambientEnemyPositions[i]

		if preset ~= CF.PresetTypes.ENGINEER then
			aimode = math.random() < 0.7 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
		end

		self:SpawnViaTable{ Preset=preset, Team=team, Player=player, AIMode=aimode, Pos=pos }

		if math.random() < CF.AmbientEnemyDoubleSpawn then
			self:SpawnViaTable{ Preset=CF.PresetTypes.ENGINEER, Team=team, Player=player, AIMode=Actor.AIMODE_GOLDDIG, Pos=pos }
		end
	end

	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = Activity.NOTEAM;

			if math.random() < 0.50 then
				for attachable in actor.Attachables do
					actor:RemoveAttachable(attachable, false, false);
				end
				
				actor.BodyHitSound = nil;
				actor.AlarmSound = nil;
				actor.PainSound = nil;
				actor.DeathSound = nil;
				actor.GibSound = nil;
				actor:GibThis();
			end
		end
	end

	-- Data
	self.missionData["dropShipCount"] = 0
	self.missionData["missionNextDropShip"] = self.Time + CF.AmbientReinforcementsInterval
	self.missionData["missionNextIntervention"] = self.Time + CF.AmbientReinforcementsInterval * 2.5

	-- Read some out
	print("TEAM 1: " .. CF.GetPlayerFaction(self.GS, team1Player))
	print("TEAM 2: " .. CF.GetPlayerFaction(self.GS, team2Player))
	print("TEAM 3: " .. CF.GetPlayerFaction(self.GS, team3Player))
	print("TEAM 4: " .. CF.GetPlayerFaction(self.GS, team4Player))
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()

	-- Count actors
	local totalUnits = {}
	local activeUnits = {}
	local sentryUnits = {}
	local miningUnits = {}

	for team = Activity.NOTEAM, Activity.MAXTEAMCOUNT - 1 do
		totalUnits[team] = 0
		activeUnits[team] = {}
		sentryUnits[team] = {}
		miningUnits[team] = {}
	end

	for actor in MovableMan.Actors do
		if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
			totalUnits[actor.Team] = totalUnits[actor.Team] + 1

			if actor:HasObjectInGroup("Tools - Diggers") then
				if actor.Team ~= Activity.TEAM_1 then
					actor.AIMode = Actor.AIMODE_GOLDDIG
				end

				table.insert(miningUnits[actor.Team], actor)
			elseif actor.AIMode == Actor.AIMODE_SENTRY then
				table.insert(sentryUnits[actor.Team], actor)
			else
				table.insert(activeUnits[actor.Team], actor)
			end
		end
		
		if actor.Team ~= CF.PlayerTeam and actor.ClassName == "ACDropShip" then
			self:AddObjectivePoint(
				"INCOMING\nDROP SHIP",
				actor.Pos + Vector(0, -50),
				CF.PlayerTeam,
				GameActivity.ARROWDOWN
			)
		end
	end

	if self.Time > self.missionData["missionNextDropShip"]
		and #self.missionData["enemyLandingZones"] > 0 
	then
		local team = math.random() < 0.5 and Activity.TEAM_3 or Activity.TEAM_4

		if #activeUnits[team] < 5 then
			self.missionData["missionNextDropShip"] = self.Time + CF.AmbientReinforcementsInterval + math.random(15)
			self.missionData["dropShipCount"] = self.missionData["dropShipCount"] + 1
			local count = math.random(math.ceil(math.max(1, math.min(CF.MaxDifficulty, self.missionData["difficulty"] / 2))))
			local f = CF.GetPlayerFaction(self.GS, self.missionData["teamParticipants"][team])
			local ship = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])

			if ship then
				for i = 1, count do
					local actor = CF.MakeUnit(self.GS, self.missionData["teamParticipants"][team]);

					if actor then
						actor.Team = team;
						actor.AIMode = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL;
						ship:AddInventoryItem(actor)
					end
				end

				ship.Team = team
				ship.Pos = Vector(self.missionData["enemyLandingZones"][math.random(#self.missionData["enemyLandingZones"])].X, -10)
				ship.AIMode = Actor.AIMODE_DELIVER
				MovableMan:AddActor(ship)
			end
		end
	end

	-- Spawn green team dropship
	if
		self.missionData["difficulty"] >= 2
		and self.missionData["teamParticipants"][Activity.TEAM_2] ~= nil
		and self.Time > self.missionData["missionNextIntervention"]
		and #self.missionData["enemyLandingZones"] > 0
	then
		self.missionData["missionNextIntervention"] = self.Time + CF.AmbientReinforcementsInterval + math.random(30)
		local team = Activity.TEAM_2
		local count = 3
		local f = CF.GetPlayerFaction(self.GS, self.missionData["teamParticipants"][team])
		local ship = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])

		if ship then
			for i = 1, count do
				local actor = CF.MakeUnit(self.GS, self.missionData["teamParticipants"][team]);

				if actor then
					actor.Team = team;
					
					if math.random(100) <= self.missionData["difficulty"] then
						actor:AddInventoryItem(
							CreateHeldDevice((math.random() < 0.25 and "Black" or "Blue") .. "print", CF.ModuleName)
						)
					end

					ship:AddInventoryItem(actor)
				end
			end

			ship.Team = team
			ship.Pos = Vector(self.missionData["enemyLandingZones"][math.random(#self.missionData["enemyLandingZones"])].X, -10)
			ship.AIMode = Actor.AIMODE_DELIVER
			MovableMan:AddActor(ship)
		end
	end

	-- Have patrollers go out to fight instead, after some time
	if self.Time > self.missionData["missionStartTime"] + 90 then
		-- Teams will go after their default enemies if there are any left, and otherwise will find someone to kill, or default to the rogue team
		local targets = {}

		for team = Activity.TEAM_2, Activity.MAXTEAMCOUNT - 1 do
			targets[team] = self.missionData["defaultHostilities"][team]

			while targets[team] >= Activity.TEAM_1 and (team == targets[team] or totalUnits[targets[team]] <= 0) do 
				targets[team] = targets[team] - 1
			end
		end

		-- Assign non-sentry non-diggers on other teams to go attack nearby target units
		for team = Activity.NOTEAM, Activity.MAXTEAMCOUNT - 1 do
			if team > Activity.TEAM_1 and #activeUnits[team] > 0 and totalUnits[targets[team]] > 0 then
				-- Target assailants first, then miners, then sentries
				local targetGroup = (#activeUnits[targets[team]] > 0 and activeUnits[targets[team]]
					or (#miningUnits[targets[team]] > 0 and miningUnits[targets[team]] or sentryUnits[targets[team]]))

				for _, actor in ipairs(activeUnits[team]) do
					local assignable = true
					local unassignables = CF.UnassignableUnits[CF.GetPlayerFaction(self.GS, self.missionData["teamParticipants"][team])]

					if unassignables then
						for i = 1, #unassignables do
							if actor.PresetName == unassignables[i] then
								assignable = false
							end
						end
					end

					if assignable then
						local distance = 1750
						local target

						for i = 1, #targetGroup do
							local d = SceneMan:ShortestDistance(actor.Pos, targetGroup[i].Pos, SceneMan.SceneWrapsX).Magnitude
							if d < distance then
								distance = d
								target = targetGroup[i]
							end
						end

						if distance > 150 and target ~= nil then
							actor.AIMode = Actor.AIMODE_GOTO
							actor:ClearAIWaypoints()
							actor:AddAISceneWaypoint(target.Pos)
						end
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
