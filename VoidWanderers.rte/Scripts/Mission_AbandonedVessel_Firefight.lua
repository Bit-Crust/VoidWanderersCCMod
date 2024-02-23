-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- To-do: try to diminish the amount of allies this missino spawns cus god damn does it bloat the ship when you rescue them
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL FIREFIGHT CREATE")

	-- Spawn random wandering enemies
	local set = CF_GetRandomMissionPointsSet(self.Pts, "Firefight")

	local diff = CF_GetLocationDifficulty(self.GS, self.GS["Location"])
	self.MissionDifficulty = diff
	--print ("DIFF: "..self.MissionDifficulty)

	-- Remove doors
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = math.random() < 0.5 and CF_CPUTeam or Activity.NOTEAM
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

	CF_CreateAIUnitPresets(self.GS, p1, CF_GetTechLevelFromDifficulty(self.GS, p1, diff, CF_MaxDifficulty))
	CF_CreateAIUnitPresets(self.GS, p2, CF_GetTechLevelFromDifficulty(self.GS, p2, diff, CF_MaxDifficulty))

	self.MissionCPUPlayers = {}
	self.MissionCPUTeams = {}
	self.MissionAllyPlayers = {}

	self.MissionAllyPlayers[1] = false
	self.MissionAllyPlayers[2] = false

	if self.GS["BrainsOnMission"] == "True" then
		if
			tonumber(self.GS["Player" .. p1 .. "Reputation"]) > 1500
			and tonumber(self.GS["Player" .. p1 .. "Reputation"]) > tonumber(self.GS["Player" .. p2 .. "Reputation"])
		then
			self.MissionAllyPlayers[1] = true
		end

		if
			self.MissionAllyPlayers[1] == false
			and tonumber(self.GS["Player" .. p2 .. "Reputation"]) > 1500
			and tonumber(self.GS["Player" .. p2 .. "Reputation"]) > tonumber(self.GS["Player" .. p1 .. "Reputation"])
		then
			self.MissionAllyPlayers[2] = true
		end
	end

	self.MissionCPUPlayers[1] = p1
	self.MissionCPUPlayers[2] = p2

	--print (CF_GetPlayerFaction(self.GS, p1))
	--print (CF_GetPlayerFaction(self.GS, p2))

	local enmpos = {}
	self.MissionFirefightWaypoint = {}

	local leaderReady = false

	for t = 1, 2 do
		enmpos[t] = CF_GetPointsArray(self.Pts, "Firefight", set, "Team " .. t)
		self.MissionFirefightWaypoint[t] = CF_GetPointsArray(self.Pts, "Firefight", set, "Waypoint " .. t)

		local double = 0.25

		if self.MissionAllyPlayers[t] then
			self.MissionCPUTeams[t] = CF_PlayerTeam
			double = 0
		else
			self.MissionCPUTeams[t] = t
		end

		for i = 1, #enmpos[t] do
			local plr = self.MissionCPUPlayers[t]
			local tm = self.MissionCPUTeams[t]
			local count = math.random() < double and 2 or 1

			for c = 1, count do
				local pre = math.random(CF_PresetTypes.HEAVY2)
				local nw = {}
				nw["Preset"] = pre
				nw["Team"] = tm
				nw["Player"] = plr
				nw["AIMode"] = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
				nw["Pos"] = enmpos[t][i]

				if self.MissionAllyPlayers[t] then
					nw["Ally"] = 1
					if not leaderReady and math.random() < 0.3 then
						nw["Name"] = CF_GenerateRandomName()
						leaderReady = true
					end
				end

				table.insert(self.SpawnTable, nw)
			end
		end
	end
	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" and math.random() < 0.25 then
			actor.GibSound = nil
			actor:GibThis()
		end
	end

	self.FirefightEnded = false

	self.MissionShowObjectiveTime = -100

	if self.MissionAllyPlayers[1] or self.MissionAllyPlayers[2] then
		self.MissionShowObjectiveTime = self.Time + 10
	end
	self:InitExplorationPoints()

	self.MissionStart = self.Time
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()

	for actor in MovableMan.AddedActors do
		for t = 1, #self.MissionCPUTeams do
			if actor.Team == self.MissionCPUTeams[t] and (actor.Team ~= CF_PlayerTeam or self:IsAlly(actor)) then
				if self.MissionFirefightWaypoint[t] and math.random() < 0.5 then
					actor.AIMode = Actor.AIMODE_GOTO
					actor:ClearAIWaypoints()
					for i = 1, #self.MissionFirefightWaypoint[t] do
						actor:AddAISceneWaypoint(self.MissionFirefightWaypoint[t][i])
					end
				else
					CF_HuntForActors(actor, self.MissionCPUTeams[math.random(#self.MissionCPUTeams)])
				end
				break
			end
		end
	end

	--[[for t = 1, 2 do
		local l = #self.MissionFirefightWaypoint[t]
		for j = 1, l do
			CF_DrawString(tostring(t),self.MissionFirefightWaypoint[t][j], 100, 100)
		end
	end--]]
	--

	if self.Time < self.MissionShowObjectiveTime then
		for p = 0, self.PlayerCount - 1 do
			FrameMan:ClearScreenText(p)
			FrameMan:SetScreenText("TRY TO SAVE AS MANY ALLIED UNITS AS POSSIBLE!", p, 0, 1000, true)
		end
	end

	-- Count units and switch modes accordingly
	if self.SpawnTable == nil and not self.FirefightEnded then
		local count = {}

		for t = 1, 2 do
			count[t] = 0
		end

		for actor in MovableMan.Actors do
			for t = 1, 2 do
				if
					actor.Team == self.MissionCPUTeams[t]
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
				then
					count[t] = count[t] + 1
				end
			end
		end

		-- Check if we need to stop firefight due to one team termination
		for t = 1, 2 do
			if count[t] == 0 then
				self.FirefightEnded = true

				for actor in MovableMan.Actors do
					if self:IsAlly(actor) then
						if self.GS["BrainsOnMission"] == "True" then
							self:SetAlly(actor, false)
						else
							actor.AIMode = math.random() < 0.5 and Actor.AIMODE_SENTRY or Actor.AIMODE_PATROL
						end
					elseif actor.Team ~= CF_PlayerTeam then
						actor.AIMode = math.random() < 0.5 and Actor.AIMODE_BRAINHUNT or Actor.AIMODE_PATROL
					end
				end
				break
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
