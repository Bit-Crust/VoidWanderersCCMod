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
function VoidWanderers:MissionCreate()
	self.missionData = {}

	self.missionData["pointSetIndex"] = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

	self.missionData["ambientEnemyLocations"] = CF.GetPointsArray(self.Pts, "Deploy", self.missionData["pointSetIndex"], "AmbientEnemy")
	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Deploy", self.missionData["pointSetIndex"], "EnemyLZ")

	self.missionData["ambientEnemyQuantity"] = math.ceil(CF.AmbientEnemyRate * #self.missionData["ambientEnemyLocations"])
	self.missionData["ambientEnemyPositions"] = CF.RandomSampleOfList(self.missionData["ambientEnemyLocations"], self.missionData["ambientEnemyQuantity"])

	local selection = {}
	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		table.insert(selection, i)
	end

	-- Find player's enemy
	local team2Player, rep = CF.GetAngriestPlayer(self.GS)
	self.AngriestDifficulty = math.min(CF.MaxDifficulty, math.max(1, math.floor(math.abs(rep) / 1000)))
	CF.CreateAIUnitPresets(self.GS, self.AngriestPlayer, CF.GetTechLevelFromDifficulty(self.GS, self.AngriestPlayer, self.AngriestDifficulty, CF.MaxDifficulty))

	local team3Player = selection[math.random(#selection)]
	CF.CreateAIUnitPresets(self.GS, team3Player, CF.GetTechLevelFromDifficulty(self.GS, team3Player, self.MissionDifficulty, CF.MaxDifficulty))

	local team4Player = selection[math.random(#selection)]
	CF.CreateAIUnitPresets(self.GS, team4Player, CF.GetTechLevelFromDifficulty(self.GS, team4Player, self.MissionDifficulty, CF.MaxDifficulty))

	self.missionData["CPUPlayers"] = { team2Player, team3Player, team4Player }

	for i = 1, #self.missionData["ambientEnemyPositions"] do
		local preset = math.random(CF.PresetTypes.ENGINEER)
		local team = (i % 2 == 0) and team3Player or team4Player
		local player = (i % 2 == 0) and Activity.TEAM_3 or Activity.TEAM_4
		local aIMode = Actor.AIMODE_GOLDDIG
		local pos = self.missionData["ambientEnemyPositions"][i]

		if preset ~= CF.PresetTypes.ENGINEER then
			aIMode = math.random() < 0.7 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
		end

		table.insert(self.SpawnTable, { Preset=preset, Team=team, Player=player, AIMode=aIMode, Pos=pos })

		if math.random() < CF.AmbientEnemyDoubleSpawn then
			table.insert(self.SpawnTable, { Preset=CF.PresetTypes.ENGINEER, Team=team, Player=player, AIMode=Actor.AIMODE_GOLDDIG, Pos=pos })
		end
	end

	self.missionData["dropShipCount"] = 0
	self.missionData["missionStart"] = self.Time
	self.missionData["missionNextDropShip"] = self.Time + CF.AmbientReinforcementsInterval
	self.missionData["missionNextDropShip2"] = self.Time + CF.AmbientReinforcementsInterval * 2.5

	print("TEAM 1: " .. CF.GetPlayerFaction(self.GS, 0))
	print("TEAM 2: " .. CF.GetPlayerFaction(self.GS, self.AngriestPlayer))
	print("TEAM 3: " .. CF.GetPlayerFaction(self.GS, team3Player))
	print("TEAM 4: " .. CF.GetPlayerFaction(self.GS, team4Player))

	-- Save mission data once it's determined, but mostly just so we can read how it did
	self.saveLoadHandler:SaveTableAsString("missionData", self.MissionData)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	local teamcount = {}
	teamcount[-1] = 0
	teamcount[0] = 0
	teamcount[1] = 0
	teamcount[2] = 0
	teamcount[3] = 0

	-- Count actors
	for actor in MovableMan.Actors do
		if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
			teamcount[actor.Team] = teamcount[actor.Team] + 1
		end
	end

	--print (self.MissionNextDropShip - self.Time)
	if self.Time > self.MissionNextDropShip and #self.MissionLZs > 0 then
		self.MissionNextDropShip = self.Time + CF["AmbientReinforcementsInterval"] + math.random(13)

		self.DropShipCount = self.DropShipCount + 1

		if MovableMan:GetMOIDCount() < CF["MOIDLimit"] then
			local sel

			if math.random() < 0.5 then
				sel = 1
			else
				sel = 2
			end

			-- Do nothin if there are too many actors of this team
			if teamcount[self.MissionCPUTeams[sel]] < 5 then
				local count = math.ceil(self.MissionDifficulty / 2)
				if count <= 0 then
					count = 1
				end
				if count > 3 then
					count = 3
				end

				count = math.random(count)

				local f = CF["GetPlayerFaction"](self.GS, self.MissionCPUPlayers[sel])
				local ship = CF["MakeActor"](CF["Crafts"][f], CF["CraftClasses"][f], CF["CraftModules"][f])
				if ship then
					for i = 1, count do
						local actor = CF["SpawnAIUnit"](
							self.GS,
							self.MissionCPUPlayers[sel],
							self.MissionCPUTeams[sel],
							nil,
							math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
						)
						if actor then
							ship:AddInventoryItem(actor)
						end
					end
					ship.Team = self.MissionCPUTeams[sel]
					ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
				end
			end
		end
	end

	-- Spawn green team dropship
	if
		self.MissionDifficulty >= 2
		and self.AngriestPlayer ~= nil
		and self.Time > self.MissionNextDropShip2
		and #self.MissionLZs > 0
	then
		self.MissionNextDropShip2 = self.Time + (CF["AmbientReinforcementsInterval"] + math.random(13)) * 2.75

		if MovableMan:GetMOIDCount() < CF["MOIDLimit"] then
			local count = 3

			local f = CF["GetPlayerFaction"](self.GS, self.AngriestPlayer)
			local ship = CF["MakeActor"](CF["Crafts"][f], CF["CraftClasses"][f], CF["CraftModules"][f])
			if ship then
				for i = 1, count do
					local actor = CF["SpawnAIUnit"](self.GS, self.AngriestPlayer, 1, nil, nil)
					if actor then
						if math.random(100) <= self.MissionDifficulty then
							actor:AddInventoryItem(
								CreateHeldDevice((math.random() < 0.25 and "Black" or "Blue") .. "print", CF["ModuleName"])
							)
						end
						ship:AddInventoryItem(actor)
					end
				end
				ship.Team = CF["CPUTeam"]
				ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
				ship.AIMode = Actor.AIMODE_DELIVER
				MovableMan:AddActor(ship)
			end
		end
	end

	-- Assemble guards near miners from time to time
	local acts = {}
	local miners = {}
	local enemyminers = {}

	local sel = (self.Time % 2 == 0) and 1 or 2

	-- Enumerate actors and select potential actors and miners
	for actor in MovableMan.Actors do
		if actor.Team ~= CF["PlayerTeam"] and actor.ClassName == "ACDropShip" then
			self:AddObjectivePoint(
				"INCOMING\nDROP SHIP",
				actor.Pos + Vector(0, -50),
				CF["PlayerTeam"],
				GameActivity.ARROWDOWN
			)
		end

		if actor.Team == self.MissionCPUTeams[sel] then
			if actor:HasObjectInGroup("Tools - Diggers") then
				if actor.AIMode == Actor.AIMODE_SENTRY then
					actor.AIMode = Actor.AIMODE_GOLDDIG
					--print (actor)
					--print ("GOLDDIG 1")
				end
				miners[#miners + 1] = actor
			else
				if actor.AIMode == Actor.AIMODE_SENTRY then
					acts[#acts + 1] = actor
				end
			end
		end
	end

	--print (#acts)
	--print (#miners)

	-- If we have spare actors and some miners then send some random actor to nearest miner to protect
	-- unless this actor is already close enough
	-- If we don't have any friendly miners then go to kill enemy miners
	-- Give orders only after some time to let player fortify
	if self.DropShipCount > 0 and #acts > 0 then
		local dest

		if #miners > 0 then
			dest = miners
		else
			if #enemyminers > 0 then
				dest = enemyminers
			end
		end

		if dest ~= nil then
			local rndact = acts[math.random(#acts)]

			local assignable = true
			local f = CF["GetPlayerFaction"](self.GS, self.MissionCPUPlayers[sel])

			-- Check if unit is playable
			if CF["UnassignableUnits"][f] ~= nil then
				for i = 1, #CF["UnassignableUnits"][f] do
					if rndact.PresetName == CF["UnassignableUnits"][f][i] then
						assignable = false
					end
				end
			end

			if assignable then
				local mindist = 1750
				local nearest

				for i = 1, #dest do
					local d = CF["Dist"](rndact.Pos, dest[i].Pos)
					if d < mindist then
						mindist = d
						nearest = dest[i].Pos
					end
				end

				if mindist > 150 and nearest ~= nil then
					--rndact:FlashWhite(1500)
					rndact.AIMode = Actor.AIMODE_GOTO
					rndact:ClearAIWaypoints()
					rndact:AddAISceneWaypoint(nearest)
					--print (rndact)
					--print("GOTO 4")
					--print (rndact)
					--print (nearest)
				end
			end
		end
	end --]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
