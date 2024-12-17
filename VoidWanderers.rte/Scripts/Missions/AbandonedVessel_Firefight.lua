-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- To-do: try to diminish the amount of allies this missino spawns cus god damn does it bloat the ship when you rescue them
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL FIREFIGHT CREATE")

	-- Spawn random wandering enemies
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Firefight")

	local diff = CF.GetLocationDifficulty(self.GS, self.GS["Location"])
	self.missionData["difficulty"] = diff
	--print ("DIFF: "..self.missionData["difficulty"])

	-- Remove doors
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = math.random() < 0.5 and CF.CPUTeam or Activity.NOTEAM
		end
	end

	-- Select random player
	p1 = math.random(tonumber(self.GS["ActiveCPUs"]))

	-- Next we should select not p1
	local selection = {}
	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		if i ~= p1 then
			selection[#selection + 1] = i
		end
	end

	p2 = selection[math.random(#selection)]

	CF.CreateAIUnitPresets(self.GS, p1, CF.GetTechLevelFromDifficulty(self.GS, p1, diff, CF.MaxDifficulty))
	CF.CreateAIUnitPresets(self.GS, p2, CF.GetTechLevelFromDifficulty(self.GS, p2, diff, CF.MaxDifficulty))

	self.missionData["CPUPlayers"] = {}
	self.missionData["CPUTeams"] = {}
	self.missionData["allyPlayer"] = {}

	self.missionData["allyPlayer"][1] = false
	self.missionData["allyPlayer"][2] = false

	if self.GS["BrainsOnMission"] == "True" then
		if
			tonumber(self.GS["Player" .. p1 .. "Reputation"]) > 1500
			and tonumber(self.GS["Player" .. p1 .. "Reputation"]) > tonumber(self.GS["Player" .. p2 .. "Reputation"])
		then
			self.missionData["allyPlayer"][1] = true
		end

		if
			self.missionData["allyPlayer"][1] == false
			and tonumber(self.GS["Player" .. p2 .. "Reputation"]) > 1500
			and tonumber(self.GS["Player" .. p2 .. "Reputation"]) > tonumber(self.GS["Player" .. p1 .. "Reputation"])
		then
			self.missionData["allyPlayer"][2] = true
		end
	end

	self.missionData["CPUPlayers"][1] = p1
	self.missionData["CPUPlayers"][2] = p2

	--print (CF.GetPlayerFaction(self.GS, p1))
	--print (CF.GetPlayerFaction(self.GS, p2))

	local enmpos = {}
	self.missionData["firefightWaypoint"] = {}

	local leaderReady = false

	for t = 1, 2 do
		enmpos[t] = CF.GetPointsArray(self.Pts, "Firefight", set, "Team " .. t)
		self.missionData["firefightWaypoint"][t] = CF.GetPointsArray(self.Pts, "Firefight", set, "Waypoint " .. t)

		local double = 0.25

		if self.missionData["allyPlayer"][t] then
			self.missionData["CPUTeams"][t] = CF.PlayerTeam
			double = 0
		else
			self.missionData["CPUTeams"][t] = t
		end

		for i = 1, #enmpos[t] do
			local plr = self.missionData["CPUPlayers"][t]
			local tm = self.missionData["CPUTeams"][t]
			local count = math.random() < double and 2 or 1

			for c = 1, count do
				local pre = math.random(CF.PresetTypes.HEAVY2)
				local nw = {}
				nw["Preset"] = pre
				nw["Team"] = tm
				nw["Player"] = plr
				nw["AIMode"] = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
				nw["Pos"] = enmpos[t][i]

				if self.missionData["allyPlayer"][t] then
					nw["Ally"] = 1
					if not leaderReady and math.random() < 0.3 then
						nw["Name"] = CF.GenerateRandomName()
						leaderReady = true
					end
				end

				self:SpawnViaTable(nw)
			end
		end
	end
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" and math.random() < 0.25 then
			actor.GibSound = nil
			actor:GibThis()
		end	
	end

	self.missionData["firefightEnded"] = false

	self.missionData["showObjectiveTime"] = -100

	if self.missionData["allyPlayer"][1] or self.missionData["allyPlayer"][2] then
		self.missionData["showObjectiveTime"] = self.Time + 10
	end

	self:InitExplorationPoints()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()

	for actor in MovableMan.AddedActors do
		for t = 1, #self.missionData["CPUTeams"] do
			if actor.Team == self.missionData["CPUTeams"][t] and (actor.Team ~= CF.PlayerTeam or CF.IsAlly(actor)) then
				if self.missionData["firefightWaypoint"][t] and math.random() < 0.5 then
					actor.AIMode = Actor.AIMODE_GOTO
					actor:ClearAIWaypoints()
					for i = 1, #self.missionData["firefightWaypoint"][t] do
						actor:AddAISceneWaypoint(self.missionData["firefightWaypoint"][t][i])
					end
				else
					CF.HuntForActors(actor, self.missionData["CPUTeams"][math.random(#self.missionData["CPUTeams"])])
				end
				break
			end
		end
	end

	--[[for t = 1, 2 do
		local l = #self.missionData["firefightWaypoint"][t]
		for j = 1, l do
			CF.DrawString(tostring(t),self.missionData["firefightWaypoint"][t][j], 100, 100)
		end
	end--]]
	--

	if self.Time < self.missionData["showObjectiveTime"] then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			FrameMan:ClearScreenText(player)
			FrameMan:SetScreenText("TRY TO SAVE AS MANY ALLIED UNITS AS POSSIBLE!", player, 0, 1000, true)
		end
	end

	-- Count units and switch modes accordingly
	if not self.missionData["firefightEnded"] then
		local count = {}

		for t = 1, 2 do
			count[t] = 0
		end

		for actor in MovableMan.Actors do
			for t = 1, 2 do
				if
					actor.Team == self.missionData["CPUTeams"][t]
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
				then
					count[t] = count[t] + 1
				end
			end
		end

		-- Check if we need to stop firefight due to one team termination
		for t = 1, 2 do
			if count[t] == 0 then
				self.missionData["firefightEnded"] = true

				for actor in MovableMan.Actors do
					if CF.IsAlly(actor) then
						if self.GS["BrainsOnMission"] == "True" then
							CF.SetAlly(actor, false)
						else
							actor.AIMode = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
						end
					elseif actor.Team ~= CF.PlayerTeam then
						actor.AIMode = math.random() < 0.5 and Actor.AIMODE_BRAINHUNT or Actor.AIMODE_PATROL
					end
				end
				break
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
