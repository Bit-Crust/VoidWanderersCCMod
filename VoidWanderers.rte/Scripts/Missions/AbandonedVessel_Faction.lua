-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL FACTION CREATE")

	-- Spawn random wandering enemies
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

	local enm = CF.GetPointsArray(self.Pts, "Deploy", set, "AmbientEnemy")
	local amount = math.ceil(CF.AmbientEnemyRate * #enm)
	local enmpos = CF.RandomSampleOfList(enm, amount)

	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Deploy", set, "EnemyLZ")

	-- Select faction
	local ok = false

	while not ok do
		self.missionData["selectedFaction"] = CF.Factions[math.random(#CF.Factions)]
		if CF.FactionPlayable[self.missionData["selectedFaction"]] then
			ok = true
		end
	end

	local diff = CF.GetLocationDifficulty(self.GS, self.GS["Location"])
	self.missionData["difficulty"] = diff

	-- Create fake player for this random faction
	self.missionData["fakePlayer"] = CF.MaxCPUPlayers + 1
	self.GS["Player" .. self.missionData["fakePlayer"] .. "Faction"] = self.missionData["selectedFaction"]
	CF.CreateAIUnitPresets(
		self.GS,
		self.missionData["fakePlayer"],
		CF.GetTechLevelFromDifficulty(self.GS, self.missionData["fakePlayer"], diff, CF.MaxDifficulty)
	)

	--print ("DIFF: "..self.missionData["difficulty"])

	for i = 1, #enmpos do
		local plr, tm

		local pre = math.random(CF.PresetTypes.ENGINEER)
		local nw = {}
		nw["Preset"] = pre

		if math.random() < 0.175 then
			tm = CF.PlayerTeam
			if self.GS["BrainsOnMission"] ~= "True" then
				nw["Ally"] = 1
			end
		elseif math.random() < 0.275 then
			tm = Activity.TEAM_3
		else
			tm = CF.CPUTeam
		end

		nw["Team"] = tm
		nw["Player"] = self.missionData["fakePlayer"]
		local rand = math.random()
		if tm == CF.CPUTeam and rand < 0.5 then
			if rand < 0.1 then
				nw["AIMode"] = Actor.AIMODE_BRAINHUNT
			else
				nw["AIMode"] = Actor.AIMODE_PATROL
			end
		else
			nw["AIMode"] = Actor.AIMODE_SENTRY
		end
		nw["Pos"] = enmpos[i]

		self:SpawnViaTable(nw)
		
		-- Spawn another engineer
		if math.random() < CF.AmbientEnemyDoubleSpawn then
			local pre = CF.PresetTypes.HEAVY2
			local nw = {}
			nw["Preset"] = pre
			nw["Team"] = tm
			nw["Player"] = self.missionData["fakePlayer"]
			nw["AIMode"] = Actor.AIMODE_SENTRY
			nw["Pos"] = enmpos[i]

			self:SpawnViaTable(nw)
		end
	end
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" and math.random() < 0.33 then
			actor.GibSound = nil
			actor:GibThis()
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
