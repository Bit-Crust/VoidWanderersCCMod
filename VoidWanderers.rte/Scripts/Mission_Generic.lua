-----------------------------------------------------------------------------------------
--	Generic mission script which is executed when no mission assigned and when no other
--	default script is specified for location
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	self.missionData = {}

	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		-- Load some positional data
		self.missionData["pointSetIndex"] = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

		self.missionData["ambientEnemyLocations"] = CF.GetPointsArray(self.Pts, "Deploy", self.missionData["pointSetIndex"], "AmbientEnemy")

		local ambientEnemyQuantity = math.ceil(CF.AmbientEnemyRate * #self.missionData["ambientEnemyLocations"])
		local ambientEnemyPositions = CF.RandomSampleOfList(self.missionData["ambientEnemyLocations"], ambientEnemyQuantity)
		
		-- Find player's enemies
		local selection = {}
		for i = 1, tonumber(self.GS["ActiveCPUs"]) do
			table.insert(selection, i)
		end

		local team2Player = CF.GetAngriestPlayer(self.GS)
		local team3Player = selection[math.random(#selection)]
		local team4Player = selection[math.random(#selection)]
		self.missionData["CPUPlayers"] = { team2Player, team3Player, team4Player }
		CF.CreateAIUnitPresets(self.GS, team2Player, CF.GetTechLevelFromDifficulty(self.GS, team2Player, self.MissionDifficulty, CF.MaxDifficulty))
		CF.CreateAIUnitPresets(self.GS, team3Player, CF.GetTechLevelFromDifficulty(self.GS, team3Player, self.MissionDifficulty, CF.MaxDifficulty))
		CF.CreateAIUnitPresets(self.GS, team4Player, CF.GetTechLevelFromDifficulty(self.GS, team4Player, self.MissionDifficulty, CF.MaxDifficulty))

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

			table.insert(self.SpawnTable, { Preset=preset, Team=team, Player=player, AIMode=aimode, Pos=pos })

			if math.random() < CF.AmbientEnemyDoubleSpawn then
				table.insert(self.SpawnTable, { Preset=CF.PresetTypes.ENGINEER, Team=team, Player=player, AIMode=Actor.AIMODE_GOLDDIG, Pos=pos })
			end
		end

		-- Data
		self.missionData["dropShipCount"] = 0
		self.missionData["missionStart"] = self.Time
		self.missionData["missionNextDropShip"] = self.Time + CF.AmbientReinforcementsInterval
		self.missionData["missionNextIntervention"] = self.Time + CF.AmbientReinforcementsInterval * 2.5

		-- Read some out
		print("TEAM 1: " .. CF.GetPlayerFaction(self.GS, 0))
		print("TEAM 2: " .. CF.GetPlayerFaction(self.GS, team2Player))
		print("TEAM 3: " .. CF.GetPlayerFaction(self.GS, team3Player))
		print("TEAM 4: " .. CF.GetPlayerFaction(self.GS, team4Player))
	end

	-- Default targets for ai on other teams
	self.defaultHostilities = { Activity.TEAM_1, Activity.TEAM_4, Activity.TEAM_3 }
	self.enemyLandingZones = CF.GetPointsArray(self.Pts, "Deploy", self.missionData["pointSetIndex"], "EnemyLZ")
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
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
		and #self.enemyLandingZones > 0 
	then
		local team = math.random() < 0.5 and Activity.TEAM_3 or Activity.TEAM_4

		if #activeUnits[team] < 5 then
			self.missionData["missionNextDropShip"] = self.Time + CF.AmbientReinforcementsInterval + math.random(15)
			self.missionData["dropShipCount"] = self.missionData["dropShipCount"] + 1
			local count = math.random(math.ceil(math.max(1, math.min(CF.MaxDifficulty, self.MissionDifficulty / 2))))
			local f = CF.GetPlayerFaction(self.GS, self.missionData["CPUPlayers"][team])
			local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])

			if ship then
				for i = 1, count do
					local actor = CF.SpawnAIUnit(
						self.GS,
						self.missionData["CPUPlayers"][team],
						team,
						nil,
						math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
					)

					if actor then
						ship:AddInventoryItem(actor)
					end
				end

				ship.Team = team
				ship.Pos = Vector(self.enemyLandingZones[math.random(#self.enemyLandingZones)].X, -10)
				ship.AIMode = Actor.AIMODE_DELIVER
				MovableMan:AddActor(ship)
			end
		end
	end

	-- Spawn green team dropship
	if
		self.MissionDifficulty >= 2
		and self.missionData["CPUPlayers"][Activity.TEAM_2] ~= nil
		and self.Time > self.missionData["missionNextIntervention"]
		and #self.enemyLandingZones > 0
	then
		self.missionData["missionNextIntervention"] = self.Time + CF.AmbientReinforcementsInterval + math.random(30)
		local team = Activity.TEAM_2
		local count = 3
		local f = CF.GetPlayerFaction(self.GS, self.missionData["CPUPlayers"][team])
		local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])

		if ship then
			for i = 1, count do
				local actor = CF.SpawnAIUnit(self.GS, self.missionData["CPUPlayers"][team], team, nil, nil)

				if actor then
					if math.random(100) <= self.MissionDifficulty then
						actor:AddInventoryItem(
							CreateHeldDevice((math.random() < 0.25 and "Black" or "Blue") .. "print", CF.ModuleName)
						)
					end

					ship:AddInventoryItem(actor)
				end
			end

			ship.Team = team
			ship.Pos = Vector(self.enemyLandingZones[math.random(#self.enemyLandingZones)].X, -10)
			ship.AIMode = Actor.AIMODE_DELIVER
			MovableMan:AddActor(ship)
		end
	end

	-- Have patrollers go out to fight instead, after some time
	if self.Time > self.missionData["missionStart"] + 90 then
		-- Teams will go after their default enemies if there are any left, and otherwise will find someone to kill, or default to the rogue team
		local targets = {}

		for team = Activity.TEAM_2, Activity.MAXTEAMCOUNT - 1 do
			targets[team] = self.defaultHostilities[team]

			while targets[team] >= Activity.TEAM_1 and (team == targets[team] or totalUnits[targets[team]] <= 0) do 
				targets[team] = targets[team] - 1
			end
		end

		-- Assign non-sentry non-diggers on other teams to go attack nearby target units
		for team = Activity.NOTEAM, Activity.MAXTEAMCOUNT - 1 do
			if team ~= Activity.TEAM_1 and #activeUnits[team] > 0 and totalUnits[targets[team]] > 0 then
				-- Target assailants first, then miners, then sentries
				local targetGroup = (#activeUnits[targets[team]] > 0 and activeUnits[targets[team]]
					or (#miningUnits[targets[team]] > 0 and miningUnits[targets[team]] or sentryUnits[targets[team]]))

				for _, actor in ipairs(activeUnits[team]) do
					local assignable = true
					local unassignables = CF.UnassignableUnits[CF.GetPlayerFaction(self.GS, self.missionData["CPUPlayers"][team])]

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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
