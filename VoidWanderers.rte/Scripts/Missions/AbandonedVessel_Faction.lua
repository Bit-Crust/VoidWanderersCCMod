-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL FACTION CREATE");

	self.missionData["advanceMissions"] = false;

	-- Spawn random wandering enemies
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

	local enm = CF.GetPointsArray(self.Pts, "Deploy", set, "AmbientEnemy")
	local amount = math.ceil(CF.AmbientEnemyRate * #enm)
	local enmpos = CF.RandomSampleOfList(enm, amount)

	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Deploy", set, "EnemyLZ")

	self.missionData["selectedFaction"] = CF.GetPlayerFaction(self.GS, math.random(tonumber(self.GS["ActiveCPUs"])));
	
	difficulty = self.missionData["difficulty"];

	-- Create fake player for this random faction
	self.missionData["fakePlayer"] = CF.MaxCPUPlayers + 1
	self.GS["Participant" .. self.missionData["fakePlayer"] .. "Faction"] = self.missionData["selectedFaction"]
	CF.CreateAIUnitPresets(
		self.GS,
		self.missionData["fakePlayer"],
		CF.GetTechLevelFromDifficulty(CF.GetPlayerFaction(self.GS, self.missionData["fakePlayer"]), difficulty)
	)

	for i = 1, #enmpos do
		local plr, tm

		local pre = math.random(CF.PresetTypes.ENGINEER)
		local nw = {}
		nw.Preset = pre

		if math.random() < 1/7 then
			tm = Activity.TEAM_1
			nw.Ally = 1
		elseif math.random() < 3/7 then
			tm = Activity.TEAM_4
		elseif math.random() < 5/7 then
			tm = Activity.TEAM_3
		else
			tm = Activity.TEAM_2
		end

		nw.Team = tm
		nw.Player = self.missionData["fakePlayer"]
		local rand = math.random()
		if tm == Activity.TEAM_2 and rand < 0.5 then
			if rand < 0.1 then
				nw.AIMode = Actor.AIMODE_BRAINHUNT
			else
				nw.AIMode = Actor.AIMODE_PATROL
			end
		else
			nw.AIMode = Actor.AIMODE_SENTRY
		end
		nw.Pos = enmpos[i]

		self:SpawnViaTable(nw);
		
		-- Spawn another engineer
		if math.random() < CF.AmbientEnemyDoubleSpawn then
			local pre = CF.PresetTypes.HEAVY2

			local nw = {}
			nw.Preset = pre
			nw.Team = tm
			nw.Ally = tm == Activity.TEAM_1;
			nw.Player = self.missionData["fakePlayer"]
			nw.AIMode = Actor.AIMODE_SENTRY
			nw.Pos = enmpos[i]

			self:SpawnViaTable(nw);
		end
	end

	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = Activity.NOTEAM;

			if math.random() < 0.33 then
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

	self:InitExplorationPoints()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
