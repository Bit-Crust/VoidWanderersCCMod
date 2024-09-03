-----------------------------------------------------------------------------------------
--	Objective: 	Kill all CF["CPUTeam"] enemies
--	Set used: 	Squad
--	Events:
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["TroopCount"] = 3

	setts[2] = {}
	setts[2]["TroopCount"] = 4

	setts[3] = {}
	setts[3]["TroopCount"] = 5

	setts[4] = {}
	setts[4]["TroopCount"] = 6

	setts[5] = {}
	setts[5]["TroopCount"] = 7

	setts[6] = {}
	setts[6]["TroopCount"] = 8

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time

	CF["CreateAIUnitPresets"](
		self.GS,
		self.MissionTargetPlayer,
		CF["GetTechLevelFromDifficulty"](self.GS, self.MissionTargetPlayer, CF["MaxDifficulty"], CF["MaxDifficulty"])
	)

	local squad = {
		CF["PresetTypes"].INFANTRY1,
		CF["PresetTypes"].INFANTRY2,
		CF["PresetTypes"].SNIPER,
		CF["PresetTypes"].SNIPER,
		CF["PresetTypes"].HEAVY1,
		CF["PresetTypes"].HEAVY2,
		CF["PresetTypes"].SHOTGUN,
		CF["PresetTypes"].SHOTGUN,
	}

	-- Use generic enemy set
	local set = CF["GetRandomMissionPointsSet"](self.Pts, "Squad")
	local troops = CF["GetPointsArray"](self.Pts, "Squad", set, "Trooper")
	local brain = CF["GetPointsArray"](self.Pts, "Squad", set, "Commander")
	-- Hacky failsafe - probably doesn't even fix anything!
	if set == nil or troops == nil or brain == nil then
		set = CF["GetRandomMissionPointsSet"](self.Pts, "Enemy")
		troops = CF["GetPointsArray"](self.Pts, "Assassinate", set, "Commander")
		brain = CF["GetPointsArray"](self.Pts, "Assassinate", set, "Commander")
	end

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1 }
	self.MissionStage = self.MissionStages.ACTIVE

	-- Spawn commander
	self.MissionBrain = CF.MakeRPGBrain(self.GS, self.MissionTargetPlayer, CF.CPUTeam, brain[1], self.MissionDifficulty)
	if self.MissionBrain then
		MovableMan:AddActor(self.MissionBrain)
		self.MissionBrain:AddInventoryItem(CreateHeldDevice("Blueprint", CF.ModuleName))
	end
	self.sentryRadius = 100 + math.sqrt(FrameMan.PlayerScreenHeight ^ 2 + FrameMan.PlayerScreenWidth ^ 2) * 0.5

	local pos = 1

	-- Spawn troops
	for i = 1, self.MissionSettings["TroopCount"] do
		local nw = {}
		nw["Preset"] = squad[i]
		nw["Team"] = CF["CPUTeam"]
		nw["Player"] = self.MissionTargetPlayer
		nw["AIMode"] = Actor.AIMODE_SENTRY
		nw["Pos"] = troops[pos]
		--nw["Digger"] = true

		table.insert(self.SpawnTable, nw)

		pos = pos + 1
		if pos > #troops then
			pos = 1
		end
	end --]]--

	self.MissionSquad = {}

	self.TriggerBrainHunt = false
	self.MissionSquadFilled = false
	self.AssaultWaitTime = self.Time
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		local count = 0

		local enemydist = 100000

		for actor in MovableMan.Actors do
			if actor.Team == CF["CPUTeam"] and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				count = count + 1

				if self.Time % 4 == 1 then
					if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF["PlayerTeam"]) then
						self:AddObjectivePoint("KILL", actor.AboveHUDPos, CF["PlayerTeam"], GameActivity.ARROWDOWN)
					end
				end
			end

			if actor.Team == CF["PlayerTeam"] and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				if MovableMan:IsActor(self.MissionBrain) then
					local dist = SceneMan:ShortestDistance(self.MissionBrain.Pos, actor.Pos, SceneMan.SceneWrapsX)

					if dist:MagnitudeIsLessThan(enemydist) then
						enemydist = dist.Magnitude
					end
				end
			end
		end

		self.MissionStatus = "Enemies left: " .. tostring(count)

		-- Start checking for victory only when all units were spawned
		if self.SpawnTable == nil and count == 0 then
			self:GiveMissionRewards()
			self.MissionStage = self.MissionStages.COMPLETED

			-- Remember when we started showing misison status message
			self.MissionStatusShowStart = self.Time
		end

		-- Fill squad
		if not self.MissionSquadFilled then
			for actor in MovableMan.Actors do
				if actor.Team == CF["CPUTeam"] then
					local isinsquad = false

					for i = 1, #self.MissionSquad do
						if MovableMan:IsActor(self.MissionSquad[i]["Actor"]) then
							if self.MissionSquad[i]["Actor"].ID == actor.ID then
								isinsquad = true
								break
							end
						end
					end

					if not isinsquad then
						local nw = #self.MissionSquad + 1
						self.MissionSquad[nw] = {}
						self.MissionSquad[nw]["Actor"] = actor
						self.MissionSquad[nw]["Abandoned"] = self.Time
						if MovableMan:IsActor(self.MissionBrain) then
							self.MissionSquad[nw]["Actor"].AIMode = Actor.AIMODE_GOTO
							self.MissionSquad[nw]["Actor"]:AddAIMOWaypoint(self.MissionBrain)
						else
							self.MissionSquad[nw]["Actor"].AIMode = Actor.AIMODE_BRAINHUNT
						end
					end
				end
			end
			if self.SpawnTable == nil then
				self.MissionSquadFilled = true
			end
		end

		-- Give squad orders
		if MovableMan:IsActor(self.MissionBrain) then
			--self.MissionBrain.Health = 10

			-- If we're close to enemy send squad to fight
			if enemydist < self.sentryRadius then
				-- Brain itself will wait
				if #self.MissionSquad > 0 then
					if self.MissionBrain.AIMode ~= Actor.AIMODE_SENTRY then
						self.MissionBrain.AIMode = Actor.AIMODE_SENTRY
						--self.MissionBrain:FlashWhite(500)

						-- Start waiting for squad to assemble
						self.AssaultWaitTime = self.Time + 25
					end
				else
					if self.MissionBrain.AIMode ~= Actor.AIMODE_BRAINHUNT then
						self.MissionBrain.AIMode = Actor.AIMODE_BRAINHUNT
					end
				end

				-- Send troops to fight
				if self.Time > self.AssaultWaitTime then
					for i = 1, #self.MissionSquad do
						if MovableMan:IsActor(self.MissionSquad[i]["Actor"]) then
							if self.MissionSquad[i]["Actor"].AIMode ~= Actor.AIMODE_BRAINHUNT then
								self.MissionSquad[i]["Actor"].AIMode = Actor.AIMODE_BRAINHUNT
							end
						end
					end
				end
			else
				-- Wait for troops
				local abandoned = 0

				for i = 1, #self.MissionSquad do
					if MovableMan:IsActor(self.MissionSquad[i]["Actor"]) then
						if CF["DistUnder"](self.MissionBrain.Pos, self.MissionSquad[i]["Actor"].Pos, 200) then
							self.MissionSquad[i]["Abandoned"] = self.Time
						else
							abandoned = abandoned + 1
							--self.MissionSquad[i]["Actor"]:FlashWhite(500)
							if self.MissionSquad[i]["Actor"].AIMode ~= Actor.AIMODE_GOTO then
								self.MissionSquad[i]["Actor"].AIMode = Actor.AIMODE_GOTO
								self.MissionSquad[i]["Actor"]:ClearAIWaypoints()
								self.MissionSquad[i]["Actor"]:AddAIMOWaypoint(self.MissionBrain)
							end
						end

						-- if actor is abandoned for too long, i.e. fell somewhere then just exclude it from squad
						if self.Time > self.MissionSquad[i]["Abandoned"] + 25 then
							self.MissionSquad[i]["Actor"].AIMode = Actor.AIMODE_BRAINHUNT
							self.MissionSquad[i]["Actor"] = nil
						end
					end
				end

				if abandoned > 1 then
					-- Stop the brain to wait for units
					if self.MissionBrain.AIMode ~= Actor.AIMODE_SENTRY then
						self.MissionBrain.AIMode = Actor.AIMODE_SENTRY
						--self.MissionBrain:FlashWhite(500)
					end
				else
					if self.MissionBrain.AIMode ~= Actor.AIMODE_BRAINHUNT then
						self.MissionBrain.AIMode = Actor.AIMODE_BRAINHUNT
					end
				end
			end
		else
			local brainwasfound = false

			-- Attempt to find another commander
			for actor in MovableMan.Actors do
				if actor.Team == CF["CPUTeam"] and actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
					self.MissionBrain = actor
					brainwasfound = false
					break
				end
			end

			if not brainwasfound then
				if not self.TriggerBrainHunt then
					for actor in MovableMan.Actors do
						if actor.Team == CF["CPUTeam"] then
							actor.AIMode = Actor.AIMODE_BRAINHUNT
						end
					end
					self.TriggerBrainHunt = true
				end
			end
		end
	elseif self.MissionStage == self.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF["MusicTypes"].VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.MissionStatusShowStart + CF["MissionResultShowInterval"] then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	end --]]--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
