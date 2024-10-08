-----------------------------------------------------------------------------------------
--	Objective: 	Kill all CF.CPUTeam enemies
--	Set used: 	Squad
--	Events:
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("SQUAD CREATE")
	
	-- Mission difficulty settings
	local diff = self.missionData["difficulty"]
	
	if diff == 1 then
		self.missionData["troopCount"] = 3
	elseif diff == 2 then
		self.missionData["troopCount"] = 4
	elseif diff == 3 then
		self.missionData["troopCount"] = 5
	elseif diff == 4 then
		self.missionData["troopCount"] = 6
	elseif diff == 5 then
		self.missionData["troopCount"] = 7
	elseif diff == 6 then
		self.missionData["troopCount"] = 8
	end

	CF.CreateAIUnitPresets(
		self.GS,
		self.missionData["missionTarget"],
		CF.GetTechLevelFromDifficulty(self.GS, self.missionData["missionTarget"], CF.MaxDifficulty, CF.MaxDifficulty)
	)

	local squad = {
		CF.PresetTypes.INFANTRY1,
		CF.PresetTypes.INFANTRY2,
		CF.PresetTypes.SNIPER,
		CF.PresetTypes.SNIPER,
		CF.PresetTypes.HEAVY1,
		CF.PresetTypes.HEAVY2,
		CF.PresetTypes.SHOTGUN,
		CF.PresetTypes.SHOTGUN,
	}

	-- Use generic enemy set
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Squad")
	local troops = CF.GetPointsArray(self.Pts, "Squad", set, "Trooper")
	local brain = CF.GetPointsArray(self.Pts, "Squad", set, "Commander")
	-- Hacky failsafe - probably doesn't even fix anything!
	if set == nil or troops == nil or brain == nil then
		set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")
		troops = CF.GetPointsArray(self.Pts, "Assassinate", set, "Commander")
		brain = CF.GetPointsArray(self.Pts, "Assassinate", set, "Commander")
	end

	-- Spawn commander
	self.missionData["brain"] = CF.MakeRPGBrain(self.GS, self.missionData["missionTarget"], CF.CPUTeam, brain[1], self.missionData["difficulty"])
	if self.missionData["brain"] then
		MovableMan:AddActor(self.missionData["brain"])
		self.missionData["brain"]:AddInventoryItem(CreateHeldDevice("Blueprint", CF.ModuleName))
	end
	self.missionData["sentryRadius"] = 100 + math.sqrt(FrameMan.PlayerScreenHeight ^ 2 + FrameMan.PlayerScreenWidth ^ 2) * 0.5

	local pos = 1

	-- Spawn troops
	for i = 1, self.missionData["troopCount"] do
		local nw = {}
		nw["Preset"] = squad[i]
		nw["Team"] = CF.CPUTeam
		nw["Player"] = self.missionData["missionTarget"]
		nw["AIMode"] = Actor.AIMODE_SENTRY
		nw["Pos"] = troops[pos]
		--nw["Digger"] = true

		table.insert(self.SpawnTable, nw)

		pos = pos + 1
		if pos > #troops then
			pos = 1
		end
	end --]]--

	self.missionData["squad"] = {}

	self.missionData["brainHuntTriggered"] = false
	self.missionData["squadFilled"] = false
	self.missionData["assaultWaitTime"] = self.Time
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local count = 0

		local enemydist = 100000

		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				count = count + 1

				if self.Time % 4 == 1 then
					if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam) then
						self:AddObjectivePoint("KILL", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
					end
				end
			end

			if actor.Team == CF.PlayerTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				if MovableMan:IsActor(self.missionData["brain"]) then
					local dist = SceneMan:ShortestDistance(self.missionData["brain"].Pos, actor.Pos, SceneMan.SceneWrapsX)

					if dist:MagnitudeIsLessThan(enemydist) then
						enemydist = dist.Magnitude
					end
				end
			end
		end

		self.missionData["missionStatus"] = "Enemies left: " .. tostring(count)

		-- Fill squad
		if not self.missionData["squadFilled"] then
			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam then
					local isinsquad = false

					for i = 1, #self.missionData["squad"] do
						if MovableMan:IsActor(self.missionData["squad"][i]["Actor"]) then
							if self.missionData["squad"][i]["Actor"].ID == actor.ID then
								isinsquad = true
								break
							end
						end
					end

					if not isinsquad then
						local nw = #self.missionData["squad"] + 1
						self.missionData["squad"][nw] = {}
						self.missionData["squad"][nw]["Actor"] = actor
						self.missionData["squad"][nw]["Abandoned"] = self.Time
						if MovableMan:IsActor(self.missionData["brain"]) then
							self.missionData["squad"][nw]["Actor"].AIMode = Actor.AIMODE_GOTO
							self.missionData["squad"][nw]["Actor"]:AddAIMOWaypoint(self.missionData["brain"])
						else
							self.missionData["squad"][nw]["Actor"].AIMode = Actor.AIMODE_BRAINHUNT
						end
					end
				end
			end
			if self.SpawnTable == nil then
				self.missionData["squadFilled"] = true
			end
		end

		-- Give squad orders
		if MovableMan:IsActor(self.missionData["brain"]) then
			--self.missionData["brain"].Health = 10

			-- If we're close to enemy send squad to fight
			if enemydist < self.missionData["sentryRadius"] then
				-- Brain itself will wait
				if #self.missionData["squad"] > 0 then
					if self.missionData["brain"].AIMode ~= Actor.AIMODE_SENTRY then
						self.missionData["brain"].AIMode = Actor.AIMODE_SENTRY
						--self.missionData["brain"]:FlashWhite(500)

						-- Start waiting for squad to assemble
						self.missionData["assaultWaitTime"] = self.Time + 25
					end
				else
					if self.missionData["brain"].AIMode ~= Actor.AIMODE_BRAINHUNT then
						self.missionData["brain"].AIMode = Actor.AIMODE_BRAINHUNT
					end
				end

				-- Send troops to fight
				if self.Time > self.missionData["assaultWaitTime"] then
					for i = 1, #self.missionData["squad"] do
						if MovableMan:IsActor(self.missionData["squad"][i]["Actor"]) then
							if self.missionData["squad"][i]["Actor"].AIMode ~= Actor.AIMODE_BRAINHUNT then
								self.missionData["squad"][i]["Actor"].AIMode = Actor.AIMODE_BRAINHUNT
							end
						end
					end
				end
			else
				-- Wait for troops
				local abandoned = 0

				for i = 1, #self.missionData["squad"] do
					if MovableMan:IsActor(self.missionData["squad"][i]["Actor"]) then
						if CF.DistUnder(self.missionData["brain"].Pos, self.missionData["squad"][i]["Actor"].Pos, 200) then
							self.missionData["squad"][i]["Abandoned"] = self.Time
						else
							abandoned = abandoned + 1
							--self.missionData["squad"][i]["Actor"]:FlashWhite(500)
							if self.missionData["squad"][i]["Actor"].AIMode ~= Actor.AIMODE_GOTO then
								self.missionData["squad"][i]["Actor"].AIMode = Actor.AIMODE_GOTO
								self.missionData["squad"][i]["Actor"]:ClearAIWaypoints()
								self.missionData["squad"][i]["Actor"]:AddAIMOWaypoint(self.missionData["brain"])
							end
						end

						-- if actor is abandoned for too long, i.e. fell somewhere then just exclude it from squad
						if self.Time > self.missionData["squad"][i]["Abandoned"] + 25 then
							self.missionData["squad"][i]["Actor"].AIMode = Actor.AIMODE_BRAINHUNT
							self.missionData["squad"][i]["Actor"] = nil
						end
					end
				end

				if abandoned > 1 then
					-- Stop the brain to wait for units
					if self.missionData["brain"].AIMode ~= Actor.AIMODE_SENTRY then
						self.missionData["brain"].AIMode = Actor.AIMODE_SENTRY
						--self.missionData["brain"]:FlashWhite(500)
					end
				else
					if self.missionData["brain"].AIMode ~= Actor.AIMODE_BRAINHUNT then
						self.missionData["brain"].AIMode = Actor.AIMODE_BRAINHUNT
					end
				end
			end
		else
			local brainwasfound = false

			-- Attempt to find another commander
			for actor in MovableMan.Actors do
				if actor.Team == CF.CPUTeam and actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
					self.missionData["brain"] = actor
					brainwasfound = false
					break
				end
			end

			if not brainwasfound then
				if not self.missionData["brainHuntTriggered"] then
					for actor in MovableMan.Actors do
						if actor.Team == CF.CPUTeam then
							actor.AIMode = Actor.AIMODE_BRAINHUNT
						end
					end
					self.missionData["brainHuntTriggered"] = true
				end
			end
		end

		-- Start checking for victory only when all units were spawned
		if not IsActor(self.missionData["brain"]) or ToActor(self.missionData["brain"]):IsStatus(Actor.DEAD) then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED

			-- Remember when we started showing misison status message
			self.missionData["statusShowStart"] = self.Time
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.missionData["missionStatus"] = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end
	end --]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
