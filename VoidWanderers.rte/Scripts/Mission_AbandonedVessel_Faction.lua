-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL FACTION CREATE")

	-- Spawn random wandering enemies
	local set = CF["GetRandomMissionPointsSet"](self.Pts, "Deploy")

	local enm = CF["GetPointsArray"](self.Pts, "Deploy", set, "AmbientEnemy")
	local amount = math.ceil(CF["AmbientEnemyRate"] * #enm)
	local enmpos = CF["SelectRandomPoints"](enm, amount)

	self.MissionLZs = CF["GetPointsArray"](self.Pts, "Deploy", set, "EnemyLZ")

	-- Select faction
	local ok = false

	while not ok do
		self.MissionSelectedFaction = CF["Factions"][math.random(#CF["Factions"])]
		if CF["FactionPlayable"][self.MissionSelectedFaction] then
			ok = true
		end
	end

	local diff = CF["GetLocationDifficulty"](self.GS, self.GS["Location"])
	self.MissionDifficulty = diff

	-- Create fake player for this random faction
	self.MissionFakePlayer = CF["MaxCPUPlayers"] + 1
	self.GS["Player" .. self.MissionFakePlayer .. "Faction"] = self.MissionSelectedFaction
	CF["CreateAIUnitPresets"](
		self.GS,
		self.MissionFakePlayer,
		CF["GetTechLevelFromDifficulty"](self.GS, self.MissionFakePlayer, diff, CF["MaxDifficulty"])
	)

	--print ("DIFF: "..self.MissionDifficulty)

	for i = 1, #enmpos do
		local plr, tm

		local pre = math.random(CF["PresetTypes"].ENGINEER)
		local nw = {}
		nw["Preset"] = pre

		if math.random() < 0.175 then
			tm = CF["PlayerTeam"]
			if self.GS["BrainsOnMission"] ~= "True" then
				nw["Ally"] = 1
			end
		elseif math.random() < 0.275 then
			tm = Activity.TEAM_3
		else
			tm = CF["CPUTeam"]
		end

		nw["Team"] = tm
		nw["Player"] = self.MissionFakePlayer
		local rand = math.random()
		if tm == CF["CPUTeam"] and rand < 0.5 then
			if rand < 0.1 then
				nw["AIMode"] = Actor.AIMODE_BRAINHUNT
			else
				nw["AIMode"] = Actor.AIMODE_PATROL
			end
		else
			nw["AIMode"] = Actor.AIMODE_SENTRY
		end
		nw["Pos"] = enmpos[i]

		table.insert(self.SpawnTable, nw)

		-- Spawn another engineer
		if math.random() < CF["AmbientEnemyDoubleSpawn"] then
			local pre = CF["PresetTypes"].HEAVY2
			local nw = {}
			nw["Preset"] = pre
			nw["Team"] = tm
			nw["Player"] = self.MissionFakePlayer
			nw["AIMode"] = Actor.AIMODE_SENTRY
			nw["Pos"] = enmpos[i]

			table.insert(self.SpawnTable, nw)
		end
	end
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" and math.random() < 0.33 then
			actor.GibSound = nil
			actor:GibThis()
		end
	end

	self:InitExplorationPoints()

	self.MissionStart = self.Time
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
