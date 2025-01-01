-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("EVACUATE CREATE")
	
	-- Mission difficulty settings
	local diff = self.missionData["difficulty"]
	
	if diff == 1 then
		self.missionData["spawnRate"] = 0.25
		self.missionData["spawnUnitCount"] = 1
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 24
	elseif diff == 2 then
		self.missionData["spawnRate"] = 0.30
		self.missionData["spawnUnitCount"] = 2
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 22
	elseif diff == 3 then
		self.missionData["spawnRate"] = 0.35
		self.missionData["spawnUnitCount"] = 3
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 20
	elseif diff == 4 then
		self.missionData["spawnRate"] = 0.40
		self.missionData["spawnUnitCount"] = 3
		self.missionData["enemyDropShips"] = 1
		self.missionData["interval"] = 18
	elseif diff == 5 then
		self.missionData["spawnRate"] = 0.45
		self.missionData["spawnUnitCount"] = 3
		self.missionData["enemyDropShips"] = 2
		self.missionData["interval"] = 17
	elseif diff == 6 then
		self.missionData["spawnRate"] = 0.50
		self.missionData["spawnUnitCount"] = 4
		self.missionData["enemyDropShips"] = 2
		self.missionData["interval"] = 16
	end

	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = CF.PlayerTeam
		end
	end

	-- Use generic enemy set
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")
		
	-- Get LZs
	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Enemy", set, "LZ")

	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.missionData["missionContractor"],
		CF.PlayerTeam,
		self.missionData["spawnRate"]
	)

	-- Spawn commander
	local cmndrpts = CF.GetPointsArray(self.Pts, "Assassinate", set, "Commander")
	local cpos = cmndrpts[math.random(#cmndrpts)]

	local faction = CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"]);
	local brain = CF.MakeBrain(faction, false);

	if brain then
		brain.Pos = cpos;
		brain.Team = CF.PlayerTeam;
		MovableMan:AddActor(brain);
		CF.SetAlly(brain, true);
		brain:AddToGroup("MissionBrain")
		brain:RemoveFromGroup("Brains")

		local weaps = CF.MakeListOfMostPowerfulWeapons(
			faction,
			CF.WeaponTypes.PISTOL,
			CF.ReputationPerDifficulty * self.missionData["difficulty"]
		)
		if weaps then
			local f = weaps[1]["Faction"]
			local weapon = CF.MakeItem(
				CF.ItmClasses[f][weaps[1]["Item"]],
				CF.ItmPresets[f][weaps[1]["Item"]],
				CF.ItmModules[f][weaps[1]["Item"]]
			)
			if weapon then
				brain:AddInventoryItem(weapon)
			end
		end

		brain.AIMode = Actor.AIMODE_GOTO
		local lzs = CF.RandomSampleOfList(
			CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerLZ"),
			Activity.MAXPLAYERCOUNT
		)
		brain:AddAISceneWaypoint(lzs[math.random(#lzs)])
		self.missionData["brain"] = brain;
	else
		error("Can't create brain")
	end

	self.missionData["craftCheckTime"] = self.Time + 10
	self.missionData["reinforcementsNext"] = self.Time
	self.missionData["craft"] = nil
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local count = 0

		if MovableMan:IsActor(self.missionData["brain"]) and self.missionData["brain"]:HasObjectInGroup("MissionBrain") then
			if MovableMan:IsActor(self.missionData["craft"]) then
				if self.missionData["craft"]:HasObjectInGroup("MissionBrain") then
					self.missionData["craft"].AIMode = Actor.AIMODE_RETURN
					self:AddObjectivePoint(
						"EVACUATE",
						self.missionData["brain"].AboveHUDPos,
						CF.PlayerTeam,
						GameActivity.ARROWUP
					)
					if
						self.missionData["craft"].InventorySize > 1
						and not self.missionData["craft"]:Inventory():HasObjectInGroup("MissionBrain")
					then
						self.missionData["craft"]:OpenHatch()
					elseif self.missionData["craft"].Status == Actor.STABLE then
						self.missionData["craft"]:CloseHatch()
					end
				else
					self:AddObjectivePoint(
						"BOARD SHIP",
						self.missionData["brain"].AboveHUDPos,
						CF.PlayerTeam,
						GameActivity.ARROWUP
					)
					if CF.IsAlly(self.missionData["brain"]) and self.missionData["brain"].AIMode ~= Actor.AIMODE_GOTO then
						self.missionData["brain"].AIMode = Actor.AIMODE_GOTO
						self.missionData["brain"]:ClearMovePath()
						self.missionData["brain"]:AddAIMOWaypoint(self.missionData["craft"])
						self.missionData["brain"]:UpdateMovePath()
					end
					if
						self.missionData["craft"].HatchState == ACraft.CLOSED
						and SceneMan
							:ShortestDistance(
								self.missionData["craft"].Pos + Vector(0, self.missionData["craft"].Radius * 0.5),
								self.missionData["brain"].Pos,
								SceneMan.SceneWrapsX
							)
							:MagnitudeIsLessThan(self.missionData["craft"].Radius + self.missionData["brain"].Radius)
					then
						self.missionData["craft"]:OpenHatch()
					end
				end
			elseif self.missionData["brain"].ClassName ~= "ACDropShip" and self.missionData["brain"].ClassName ~= "ACRocket" then -- Maybe this check isn't needed?
				self:AddObjectivePoint("EVACUATE", self.missionData["brain"].AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
				if self.missionData["craft"] then
					-- Craft is defined but not an actor - that means it has been destroyed, so delay the next one
					self.missionData["craftCheckTime"] = self.Time + 10
				end
				self.missionData["craft"] = nil
				if self.missionData["craftCheckTime"] < self.Time then
					self.missionData["craftCheckTime"] = self.Time + 2
					if
						SceneMan:CastObstacleRay(
							self.missionData["brain"].Pos,
							Vector(0, -self.missionData["brain"].Pos.Y),
							Vector(),
							Vector(),
							self.missionData["brain"].ID,
							self.missionData["brain"].Team,
							rte.airID,
							10
						) < 0
					then
						local f = CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"])
						self.missionData["craft"] = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])
							or CreateACDropShip("Dropship MK1", "Base.rte")
						self.missionData["craft"].Pos = Vector(self.missionData["brain"].Pos.X, -10)
						self.missionData["craft"].Team = self.missionData["brain"].Team
						self.missionData["craft"].AIMode = Actor.AIMODE_STAY
						MovableMan:AddActor(self.missionData["craft"])
						CF.SetAlly(self.missionData["craft"], true)

						self.missionData["brain"].AIMode = Actor.AIMODE_SENTRY
						-- Stop following the brain, let it board the ship in peace
						if CF.IsAlly(self.missionData["brain"]) then
							for actor in MovableMan.Actors do
								if
									CF.IsAlly(actor)
									and actor.MOMoveTarget
									and actor.MOMoveTarget.ID == self.missionData["brain"].ID
								then
									actor.AIMode = Actor.AIMODE_SENTRY
								end
							end
						end
					end
				end
			end
			if CF.IsAlly(self.missionData["brain"]) then
				for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
					if self:PlayerActive(player) and self:PlayerHuman(player) then
						local savior = self:GetControlledActor(player) -- or MovableMan:GetClosestTeamActor(self.missionData["brain"].Team, player, self.missionData["brain"].Pos, 20 + self.missionData["brain"].IndividualRadius, Vector(), self.missionData["brain"])
						if
							savior
							and CF.Dist(savior.Pos, self.missionData["brain"].Pos) < 1 + self.missionData["brain"].IndividualRadius + savior.IndividualRadius
							and CF.IsCommander(savior)
						then
							print("Sir, we must hurry! The enemy are increasing their reinforcements...")
							self.missionData["interval"] = math.ceil(self.missionData["interval"] * 0.66)
							self.missionData["reinforcementsNext"] = self.missionData["reinforcementsNext"]
								- self.missionData["interval"]
							self.missionData["brain"].AIMode = Actor.AIMODE_SENTRY
							CF.SetAlly(self.missionData["brain"], false)
							self:SwitchToActor(self.missionData["brain"], player, savior.Team)
							break
						end
					end
				end
			end
		else
			for actor in MovableMan.Actors do
				if actor:HasObjectInGroup("MissionBrain") then
					self.missionData["brain"] = actor
					break
				end
			end
		end
		if not MovableMan:IsActor(self.missionData["brain"]) then
			if self.missionData["evacuated"] then
				self:GiveMissionRewards()
				self.missionData["stage"] = CF.MissionStages.COMPLETED
			else
				for actor in MovableMan.Actors do
					if CF.IsAlly(actor) then
						if actor.ClassName == "ACDropShip" then
							actor.Health = 0
						elseif math.random() * actor.MaxHealth * 1.5 > actor.Health then
							if math.random() < 0.5 then
								if math.random() < 0.5 and IsAHuman(actor) and ToAHuman(actor).Head then
									ToAHuman(actor).Head:GibThis()
								else
									actor:GibThis()
								end
							else
								actor.Health = 0
							end
						else
							-- The rest will scatter
							CF.HuntForActors(actor, Activity.NOTEAM)
						end
					end
				end
				self.missionData["stage"] = CF.MissionStages.FAILED
			end
			self.missionData["brain"] = nil
			-- Remember when we started showing misison status message
			self.missionData["statusShowStart"] = self.Time
			self.missionData["missionEndTime"] = self.Time
		else
			self.missionData["missionStatus"] = "COMMANDER ALIVE"

			if self.Time >= self.missionData["reinforcementsNext"] then
				local actorCount = { [CF.PlayerTeam] = 0, [CF.CPUTeam] = 0 }
				for actor in MovableMan.Actors do
					if actor.ID ~= self.missionData["brain"].ID then
						if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
							if actor.Team == CF.CPUTeam then
								actorCount[CF.CPUTeam] = actorCount[CF.CPUTeam] + 1
								if actor.AIMode ~= Actor.AIMODE_GOTO then
									CF.Hunt(actor, { self.missionData["brain"] })
								end
							elseif actor.Team == CF.PlayerTeam then
								actorCount[CF.PlayerTeam] = actorCount[CF.PlayerTeam] + 1
								if
									self.missionData["craft"] == nil
									and CF.IsAlly(actor)
									and actor.AIMode ~= Actor.AIMODE_GOTO
									and SceneMan
										:ShortestDistance(actor.Pos, self.missionData["brain"].Pos, SceneMan.SceneWrapsX)
										:MagnitudeIsLessThan(50)
								then
									CF.Hunt(actor, { self.missionData["brain"] })
								end
							end
						elseif actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket" then
							if actor.Team == CF.CPUTeam then
								actorCount[CF.CPUTeam] = actorCount[CF.CPUTeam] + actor.InventorySize
							elseif actor.Team == CF.PlayerTeam then
								actorCount[CF.PlayerTeam] = actorCount[CF.PlayerTeam] + actor.InventorySize
							end
						end
					end
				end
				if #self.missionData["landingZones"] > 0 then
					if self.missionData["enemyDropShips"] > 0 then
						local count = math.ceil(
							RangeRand(
								self.missionData["spawnUnitCount"] / 2,
								self.missionData["spawnUnitCount"]
							)
						)
						local f = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])

						local ship = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])
						if ship then
							for i = 1, count do
								local actor = CF.MakeUnit(self.GS, self.missionData["missionTarget"]);

								if actor then
									actor.Team = CF.CPUTeam;

									if actor.AIMode == Actor.AIMODE_BRAINHUNT then
										CF.Hunt(actor, { self.missionData["brain"] });
									end

									if i == self.missionData["spawnUnitCount"] and math.random() < 0.5 then
										actor:AddInventoryItem(CreateTDExplosive("Timed Explosive"));
									end

									actorCount[CF.CPUTeam] = actorCount[CF.CPUTeam] + 1;
									ship:AddInventoryItem(actor);
								end
							end
							ship.Team = CF.CPUTeam
							ship.Pos = Vector(self.missionData["landingZones"][math.random(#self.missionData["landingZones"])].X, -10)
							ship.AIMode = Actor.AIMODE_DELIVER
							MovableMan:AddActor(ship)

							self.missionData["enemyDropShips"] = self.missionData["enemyDropShips"] - 1
						end
					else
						-- Don't stop at zero dropships, just delay the enemy whenever they lose one
						self.missionData["enemyDropShips"] = self.missionData["enemyDropShips"] + 1
					end
				end
				self.missionData["reinforcementsNext"] = self.Time
					+ self.missionData["interval"]
					+ math.ceil(actorCount[CF.CPUTeam] / math.sqrt(math.max(actorCount[CF.PlayerTeam], 1)))
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.FAILED then
		self.missionData["missionStatus"] = "MISSION FAILED"
		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.DEFEAT)
			self.missionData["endMusicPlayed"] = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.missionData["missionStatus"], player, 0, 1000, true)
			end
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
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if self.missionData and orbitedCraft:HasObjectInGroup("MissionBrain") then
		self.missionData["evacuated"] = true
	end
end