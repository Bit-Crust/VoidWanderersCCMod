-----------------------------------------------------------------------
--	Objective: 	Kill all CF.CPUTeam enemies
--	Set used: 	Squad
--	Events:
--
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("SQUAD CREATE")
	
	-- Mission difficulty settings
	local diff = self.missionData["difficulty"];

	local squad = {
		CF.PresetTypes.INFANTRY1,
		CF.PresetTypes.INFANTRY2,
		CF.PresetTypes.SNIPER,
		CF.PresetTypes.SNIPER,
		CF.PresetTypes.HEAVY1,
		CF.PresetTypes.HEAVY2,
		CF.PresetTypes.SHOTGUN,
		CF.PresetTypes.SHOTGUN,
	};

	-- Use generic enemy set
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Squad")
	local troops = CF.GetPointsArray(self.Pts, "Squad", set, "Trooper")
	local brainPoints = CF.GetPointsArray(self.Pts, "Squad", set, "Commander")

	-- Spawn commander
	local faction = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"]);
	local brain = CF.MakeRPGBrain(faction, true, math.floor((diff + math.random()) * 21));

	if brain then
		brain.Team = CF.CPUTeam;
		brain.Pos = brainPoints[math.random(#brainPoints)];
		MovableMan:AddActor(brain)
		brain:AddInventoryItem(CF.CreateBluePrint(self.GS, self.missionData["missionContractor"]));
		self.missionData["brain"] = brain;
	end

	self.missionData["sentryRadius"] = 100 + math.sqrt(FrameMan.PlayerScreenHeight ^ 2 + FrameMan.PlayerScreenWidth ^ 2) * 0.5;
	self.missionData["squad"] = {};
	self.missionData["brainHuntTriggered"] = false;
	self.missionData["assaultWaitTime"] = self.Time;

	for i = 1, diff + 2 do
		local actor = self:SpawnViaTable{
			Preset = squad[math.random(#squad)],
			Team = CF.CPUTeam,
			Player = self.missionData["missionTarget"],
			AIMode = Actor.AIMODE_GOTO,
			Pos = troops[(i - 1) % #troops + 1]
		};
		actor:AddAIMOWaypoint(self.missionData["brain"]);

		table.insert(self.missionData["squad"], { Actor = actor, Abandoned = self.Time });
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
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
						if CF.Dist(self.missionData["brain"].Pos, self.missionData["squad"][i]["Actor"].Pos) < 200 then
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
				if actor.Team == CF.CPUTeam and CF.IsBrain(actor) then
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
		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.missionData["endMusicPlayed"] = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
		end
	end --]]--
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
