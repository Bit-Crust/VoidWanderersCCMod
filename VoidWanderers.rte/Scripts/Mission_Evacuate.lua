-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate(isNewGame)
	print("EVACUATE " .. (isNewGame == false and "LOAD" or "CREATE"))
	self.missionData = {}

	if isNewGame == false then
		self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
	else
		-- Mission difficulty settings
		local setts = { {}, {}, {}, {}, {}, {} }

		setts[1]["spawnRate"] = 0.25
		setts[1]["spawnUnitCount"] = 1
		setts[1]["enemyDropShips"] = 1
		setts[1]["interval"] = 24

		setts[2]["spawnRate"] = 0.30
		setts[2]["spawnUnitCount"] = 2
		setts[2]["enemyDropShips"] = 1
		setts[2]["interval"] = 22

		setts[3]["spawnRate"] = 0.35
		setts[3]["spawnUnitCount"] = 3
		setts[3]["enemyDropShips"] = 1
		setts[3]["interval"] = 20

		setts[4]["spawnRate"] = 0.40
		setts[4]["spawnUnitCount"] = 3
		setts[4]["enemyDropShips"] = 1
		setts[4]["interval"] = 18

		setts[5]["spawnRate"] = 0.45
		setts[5]["spawnUnitCount"] = 3
		setts[5]["enemyDropShips"] = 2
		setts[5]["interval"] = 17

		setts[6]["spawnRate"] = 0.50
		setts[6]["spawnUnitCount"] = 4
		setts[6]["enemyDropShips"] = 2
		setts[6]["interval"] = 16

		self.missionData = setts[self.MissionDifficulty]
		self.missionData["missionStartTime"] = self.Time

		-- We're going to alter ally presets, ally units may be tougher or weaker then enemy units
		CF.CreateAIUnitPresets(
			self.GS,
			self.MissionSourcePlayer,
			self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"] * 0.5
		)

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
			self.MissionSourcePlayer,
			CF.PlayerTeam,
			self.missionData["spawnRate"]
		)

		-- Spawn commander
		local cmndrpts = CF.GetPointsArray(self.Pts, "Assassinate", set, "Commander")
		local cpos = cmndrpts[math.random(#cmndrpts)]

		self.missionData["brain"] = CF.MakeBrain(self.GS, self.MissionSourcePlayer, CF.PlayerTeam, cpos, false)

		if self.missionData["brain"] then
			MovableMan:AddActor(self.missionData["brain"])
			self:SetAlly(self.missionData["brain"], true)
			self.missionData["brain"]:AddToGroup("MissionBrain")
			self.missionData["brain"]:RemoveFromGroup("Brains")

			local weaps = CF.MakeListOfMostPowerfulWeapons(
				self.GS,
				self.MissionSourcePlayer,
				CF.WeaponTypes.PISTOL,
				CF.ReputationPerDifficulty * self.MissionDifficulty
			)
			if weaps then
				local f = weaps[1]["Faction"]
				local weapon = CF.MakeItem(
					CF.ItmPresets[f][weaps[1]["Item"]],
					CF.ItmClasses[f][weaps[1]["Item"]],
					CF.ItmModules[f][weaps[1]["Item"]]
				)
				if weapon then
					self.missionData["brain"]:AddInventoryItem(weapon)
				end
			end

			self.missionData["brain"].AIMode = Actor.AIMODE_GOTO
			local lzs = CF.RandomSampleOfList(
				CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerLZ"),
				Activity.MAXPLAYERCOUNT
			)
			self.missionData["brain"]:AddAISceneWaypoint(lzs[math.random(#lzs)])
		else
			error("Can't create brain")
		end

		self.missionData["craftCheckTime"] = self.Time + 10
		self.missionData["reinforcementsNext"] = self.Time
		self.missionData["craft"] = nil

		self.missionData["stage"] = CF.MissionStages.ACTIVE
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
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
					if self:IsAlly(self.missionData["brain"]) and self.missionData["brain"].AIMode ~= Actor.AIMODE_GOTO then
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
				if self:IsAlly(self.missionData["brain"]) then
					for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
						if self:PlayerActive(player) and self:PlayerHuman(player) then
							local savior = self:GetControlledActor(player) -- or MovableMan:GetClosestTeamActor(self.missionData["brain"].Team, player, self.missionData["brain"].Pos, 20 + self.missionData["brain"].IndividualRadius, Vector(), self.missionData["brain"])
							if
								savior
								and CF.DistUnder(
									savior.Pos,
									self.missionData["brain"].Pos,
									1 + self.missionData["brain"].IndividualRadius + savior.IndividualRadius
								)
								and self:IsCommander(savior)
							then
								print("Sir, we must hurry! The enemy are increasing their reinforcements...")
								self.missionData["interval"] = math.ceil(self.missionData["interval"] * 0.66)
								self.missionData["reinforcementsNext"] = self.missionData["reinforcementsNext"]
									- self.missionData["interval"]
								self.missionData["brain"].AIMode = Actor.AIMODE_SENTRY
								self:SetAlly(self.missionData["brain"], false)
								self:SwitchToActor(self.missionData["brain"], player, savior.Team)
								break
							end
						end
					end
				end
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
						local f = CF.GetPlayerFaction(self.GS, self.MissionSourcePlayer)
						self.missionData["craft"] = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
							or CreateACDropShip("Dropship MK1", "Base.rte")
						self.missionData["craft"].Pos = Vector(self.missionData["brain"].Pos.X, -10)
						self.missionData["craft"].Team = self.missionData["brain"].Team
						self.missionData["craft"].AIMode = Actor.AIMODE_STAY
						MovableMan:AddActor(self.missionData["craft"])
						self:SetAlly(self.missionData["craft"], true)

						self.missionData["brain"].AIMode = Actor.AIMODE_SENTRY
						-- Stop following the brain, let it board the ship in peace
						if self:IsAlly(self.missionData["brain"]) then
							for actor in MovableMan.Actors do
								if
									self:IsAlly(actor)
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
					if self:IsAlly(actor) then
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
			self.MissionStatus = "COMMANDER ALIVE"

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
									and self:IsAlly(actor)
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
						local f = CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)

						local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
						if ship then
							for i = 1, count do
								local actor = CF.SpawnAIUnit(self.GS, self.MissionTargetPlayer, CF.CPUTeam, nil, nil)
								if actor then
									if actor.AIMode == Actor.AIMODE_BRAINHUNT then
										CF.Hunt(actor, { self.missionData["brain"] })
									end
									if i == self.missionData["spawnUnitCount"] and math.random() < 0.5 then
										actor:AddInventoryItem(CreateTDExplosive("Timed Explosive"))
									end
									actorCount[CF.CPUTeam] = actorCount[CF.CPUTeam] + 1
									ship:AddInventoryItem(actor)
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
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.DEFEAT)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	elseif self.missionData["stage"] == CF.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if self.missionData and orbitedCraft:HasObjectInGroup("MissionBrain") then
		self.missionData["evacuated"] = true
	end
end