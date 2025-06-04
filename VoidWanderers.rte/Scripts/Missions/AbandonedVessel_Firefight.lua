-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- To-do: try to diminish the amount of allies this missino spawns cus god damn does it bloat the ship when you rescue them
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL FIREFIGHT CREATE");

	self.missionData["advanceMissions"] = false;

	local set = CF.GetRandomMissionPointsSet(self.Pts, "Firefight");
	
	self.missionData["difficulty"] = CF.NormalizeDifficulty(math.random(1, 3) + 3);

	participant1 = math.random(tonumber(self.GS["ActiveCPUs"]));
	participant2 = math.random(tonumber(self.GS["ActiveCPUs"]) - 1);
	
	if participant1 <= participant2 then
		participant2 = participant2 + 1;
	end

	self.missionData["groupFactions"] = {};
	self.missionData["groupFactions"][1] = CF.GetPlayerFaction(self.GS, participant1);
	self.missionData["groupFactions"][2] = CF.GetPlayerFaction(self.GS, participant2);

	CF.CreateAIUnitPresets(self.GS, participant1, CF.GetTechLevelFromDifficulty(self.missionData["groupFactions"][1], self.missionData["difficulty"]));
	CF.CreateAIUnitPresets(self.GS, participant2, CF.GetTechLevelFromDifficulty(self.missionData["groupFactions"][2], self.missionData["difficulty"]));

	self.missionData["groupParticipants"] = {};
	self.missionData["groupParticipants"][1] = participant1;
	self.missionData["groupParticipants"][2] = participant2;
	
	self.missionData["allyPlayer"] = {};
	self.missionData["allyPlayer"][1] = false;
	self.missionData["allyPlayer"][2] = false;

	local p1Rep = tonumber(self.GS["Participant" .. participant1 .. "Reputation"]);
	local p2Rep = tonumber(self.GS["Participant" .. participant2 .. "Reputation"]);

	if p1Rep >=	 p2Rep then
		if p1Rep >= 500 then
			self.missionData["allyPlayer"][1] = true;
		end
	elseif p2Rep >= 500 then
		self.missionData["allyPlayer"][2] = true;
	end

	self.missionData["groupUnitSpawns"] = {};
	self.missionData["groupWaypoints"] = {};
	self.missionData["groupTeams"] = {};
	self.missionData["groupBrains"] = {};
	self.missionData["groupUnits"] = {};

	for group = 1, 2 do
		local groupHasBrain = math.random() <= self.missionData["difficulty"] / CF.MaxDifficulty / 2;
		self.missionData["groupUnits"][group] = {};
		self.missionData["groupTeams"][group] = self.missionData["allyPlayer"][group] and CF.PlayerTeam or group;

		local groupUnitSpawns = CF.GetPointsArray(self.Pts, "Firefight", set, "Team " .. group);
		self.missionData["groupUnitSpawns"][group] = groupUnitSpawns;
		groupUnitSpawns = CF.RandomSampleOfList(groupUnitSpawns, #groupUnitSpawns * self.missionData["difficulty"] / CF.MaxDifficulty);

		self.missionData["groupWaypoints"][group] = CF.GetPointsArray(self.Pts, "Firefight", set, "Waypoint " .. group);

		for i = 1, #groupUnitSpawns do
			local participant = self.missionData["groupParticipants"][group];
			local team = self.missionData["groupTeams"][group];

			if not self.missionData["groupBrains"][group] and groupHasBrain then
				local brain = CF.MakeBrain(self.missionData["groupFactions"][group], true);
				brain.Team = team;
				brain.AIMode = Actor.AIMODE_SENTRY;
				brain.Pos = groupUnitSpawns[i];
				brain:SetStringValue("VW_Name", CF.GenerateRandomName());

				if self.missionData["allyPlayer"][group] then
					CF.SetAlly(brain, true);
				end

				MovableMan:AddActor(brain);
				self.missionData["groupBrains"][group] = brain;
			else
				local actor = CF.MakeUnitWithPreset(self.GS, self.missionData["groupParticipants"][group], math.random(CF.PresetTypes.HEAVY2));
				actor.Team = team;
				actor.AIMode = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL;
				actor.Pos = groupUnitSpawns[i];

				if self.missionData["allyPlayer"][group] then
					CF.SetAlly(actor, true);
				end
				
				MovableMan:AddActor(actor);
				table.insert(self.missionData["groupUnits"][group], actor);
			end
		end
	end

	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.ClassName == "ADoor" then
			actor.Team = Activity.NOTEAM;

			if math.random() < 0.25 then
				for attachable in actor.Attachables do
					actor:RemoveAttachable(attachable, false, false);
				end
				
				actor.BodyHitSound = nil;
				actor.AlarmSound = nil;
				actor.PainSound = nil;
				actor.DeathSound = nil;
				actor.GibSound = nil;
				-- Ensures no EXP is mistakenly given
				MovableMan:AddParticle(MovableMan:RemoveActor(actor));
				actor:GibThis();
			end
		end
	end end

	self.missionData["firefightEnded"] = false;
	self.missionData["showObjectiveTime"] = -100;

	if self.missionData["allyPlayer"][1] or self.missionData["allyPlayer"][2] then
		self.missionData["showObjectiveTime"] = tonumber(self.GS["Time"]) + 10;
	end

	self:InitExplorationPoints();
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints();
	local missionData = self.missionData;
	local groupTeams = missionData["groupTeams"];

	for group = 1, 2 do
		local units = missionData["groupUnits"][group];
		local team = groupTeams[group];
		local waypoints = missionData["groupWaypoints"][group];

		local removals = {};

		for i, actor in ipairs(units) do
			if (not actor) or (not MovableMan:IsActor(actor)) then
				table.insert(removals, 1, i);
			end
		end

		for i, removal in ipairs(removals) do
			table.remove(units, i);
		end
	
		for i, actor in ipairs(units) do
			if actor.Team == team and (team ~= Activity.TEAM_1 or CF.IsAlly(actor)) then
				if waypoints and i % 2 == 0 then
					actor.AIMode = Actor.AIMODE_GOTO;
					actor:ClearAIWaypoints();

					for i = 1, #waypoints do
						actor:AddAISceneWaypoint(waypoints[i]);
					end
				else
					--CF.HuntForActors(actor, groupTeams[#groupTeams + 1 - group]);
				end
			end
		end
	end

	--[[
	for t = 1, 2 do
		local l = #missionData["groupWaypoints"][t];

		for j = 1, l do
			CF.DrawString(tostring(t), missionData["groupWaypoints"][t][j], 100, 100);
		end
	end
	--]]

	if tonumber(self.GS["Time"]) < missionData["showObjectiveTime"] then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			FrameMan:ClearScreenText(player);
			FrameMan:SetScreenText("TRY TO SAVE AS MANY ALLIED UNITS AS POSSIBLE!", player, 0, 1000, true);
		end
	end

	-- Count units and switch modes accordingly
	if false and not missionData["firefightEnded"] then
		local count = {};

		for t = 1, 2 do
			count[t] = 0;
		end

		for actor in MovableMan.Actors do
			for t = 1, 2 do
				if actor.Team == missionData["groupTeams"][t] and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
					count[t] = count[t] + 1;
				end
			end
		end

		-- Check if we need to stop firefight due to one team termination
		for t = 1, 2 do
			if count[t] == 0 then
				missionData["firefightEnded"] = true;
				
				for actor in MovableMan.Actors do
					if CF.IsAlly(actor) then
						actor.AIMode = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL;
					elseif actor.Team ~= CF.PlayerTeam then
						actor.AIMode = math.random() < 0.5 and Actor.AIMODE_BRAINHUNT or Actor.AIMODE_PATROL;
					end
				end

				break;
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
