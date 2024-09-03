-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("EVACUATE CREATE")
	-- Mission difficulty settings
	local setts = { {}, {}, {}, {}, {}, {} }

	setts[1]["SpawnRate"] = 0.25
	setts[1]["SpawnUnitCount"] = 1
	setts[1]["EnemyDropShips"] = 1
	setts[1]["Interval"] = 24

	setts[2]["SpawnRate"] = 0.30
	setts[2]["SpawnUnitCount"] = 2
	setts[2]["EnemyDropShips"] = 1
	setts[2]["Interval"] = 22

	setts[3]["SpawnRate"] = 0.35
	setts[3]["SpawnUnitCount"] = 3
	setts[3]["EnemyDropShips"] = 1
	setts[3]["Interval"] = 20

	setts[4]["SpawnRate"] = 0.40
	setts[4]["SpawnUnitCount"] = 3
	setts[4]["EnemyDropShips"] = 1
	setts[4]["Interval"] = 18

	setts[5]["SpawnRate"] = 0.45
	setts[5]["SpawnUnitCount"] = 3
	setts[5]["EnemyDropShips"] = 2
	setts[5]["Interval"] = 17

	setts[6]["SpawnRate"] = 0.50
	setts[6]["SpawnUnitCount"] = 4
	setts[6]["EnemyDropShips"] = 2
	setts[6]["Interval"] = 16

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time

	-- We're going to alter ally presets, ally units may be tougher or weaker then enemy units
	CF["CreateAIUnitPresets"](
		self.GS,
		self.MissionSourcePlayer,
		self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"] * 0.5
	)

	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" then
			actor.Team = CF["PlayerTeam"]
		end
	end

	-- Use generic enemy set
	local set = CF["GetRandomMissionPointsSet"](self.Pts, "Enemy")

	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.MissionSourcePlayer,
		CF["PlayerTeam"],
		self.MissionSettings["SpawnRate"]
	)

	-- Spawn commander
	local cmndrpts = CF["GetPointsArray"](self.Pts, "Assassinate", set, "Commander")
	local cpos = cmndrpts[math.random(#cmndrpts)]

	self.MissionBrain = CF["MakeBrain"](self.GS, self.MissionSourcePlayer, CF["PlayerTeam"], cpos, false)

	if self.MissionBrain then
		MovableMan:AddActor(self.MissionBrain)
		self:SetAlly(self.MissionBrain, true)
		self.MissionBrain:AddToGroup("MissionBrain")
		self.MissionBrain:RemoveFromGroup("Brains")

		local weaps = CF["MakeListOfMostPowerfulWeapons"](
			self.GS,
			self.MissionSourcePlayer,
			CF["WeaponTypes"].PISTOL,
			CF["ReputationPerDifficulty"] * self.MissionDifficulty
		)
		if weaps then
			local f = weaps[1]["Faction"]
			local weapon = CF["MakeItem"](
				CF["ItmPresets"][f][weaps[1]["Item"]],
				CF["ItmClasses"][f][weaps[1]["Item"]],
				CF["ItmModules"][f][weaps[1]["Item"]]
			)
			if weapon then
				self.MissionBrain:AddInventoryItem(weapon)
			end
		end

		self.MissionBrain.AIMode = Actor.AIMODE_GOTO
		local lzs = CF["RandomSampleOfList"](
			CF["GetPointsArray"](self.Pts, "Deploy", self.MissionDeploySet, "PlayerLZ"),
			Activity.MAXPLAYERCOUNT
		)
		self.MissionBrain:AddAISceneWaypoint(lzs[math.random(#lzs)])
	else
		error("Can't create brain")
	end
	self.MissionCraftCheckTime = self.Time + 10
	self.MissionNextReinforcements = self.Time
	self.MissionCraft = nil

	self.MissionStages = { ACTIVE = 0, COMPLETED = 1, FAILED = 2 }
	self.MissionStage = self.MissionStages.ACTIVE
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == self.MissionStages.ACTIVE then
		local count = 0

		if MovableMan:IsActor(self.MissionBrain) and self.MissionBrain:HasObjectInGroup("MissionBrain") then
			if MovableMan:IsActor(self.MissionCraft) then
				if self.MissionCraft:HasObjectInGroup("MissionBrain") then
					self.MissionCraft.AIMode = Actor.AIMODE_RETURN
					self:AddObjectivePoint(
						"EVACUATE",
						self.MissionBrain.AboveHUDPos,
						CF["PlayerTeam"],
						GameActivity.ARROWUP
					)
					if
						self.MissionCraft.InventorySize > 1
						and not self.MissionCraft:Inventory():HasObjectInGroup("MissionBrain")
					then
						self.MissionCraft:OpenHatch()
					elseif self.MissionCraft.Status == Actor.STABLE then
						self.MissionCraft:CloseHatch()
					end
				else
					self:AddObjectivePoint(
						"BOARD SHIP",
						self.MissionBrain.AboveHUDPos,
						CF["PlayerTeam"],
						GameActivity.ARROWUP
					)
					if self:IsAlly(self.MissionBrain) and self.MissionBrain.AIMode ~= Actor.AIMODE_GOTO then
						self.MissionBrain.AIMode = Actor.AIMODE_GOTO
						self.MissionBrain:ClearMovePath()
						self.MissionBrain:AddAIMOWaypoint(self.MissionCraft)
						self.MissionBrain:UpdateMovePath()
					end
					if
						self.MissionCraft.HatchState == ACraft.CLOSED
						and SceneMan
							:ShortestDistance(
								self.MissionCraft.Pos + Vector(0, self.MissionCraft.Radius * 0.5),
								self.MissionBrain.Pos,
								SceneMan.SceneWrapsX
							)
							:MagnitudeIsLessThan(self.MissionCraft.Radius + self.MissionBrain.Radius)
					then
						self.MissionCraft:OpenHatch()
					end
				end
			elseif self.MissionBrain.ClassName ~= "ACDropShip" and self.MissionBrain.ClassName ~= "ACRocket" then -- Maybe this check isn't needed?
				self:AddObjectivePoint("EVACUATE", self.MissionBrain.AboveHUDPos, CF["PlayerTeam"], GameActivity.ARROWDOWN)
				if self.MissionCraft then
					-- Craft is defined but not an actor - that means it has been destroyed, so delay the next one
					self.MissionCraftCheckTime = self.Time + 10
				end
				self.MissionCraft = nil
				if self:IsAlly(self.MissionBrain) then
					for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
						if self:PlayerActive(player) and self:PlayerHuman(player) then
							local savior = self:GetControlledActor(player) -- or MovableMan:GetClosestTeamActor(self.MissionBrain.Team, player, self.MissionBrain.Pos, 20 + self.MissionBrain.IndividualRadius, Vector(), self.MissionBrain)
							if
								savior
								and CF["DistUnder"](
									savior.Pos,
									self.MissionBrain.Pos,
									1 + self.MissionBrain.IndividualRadius + savior.IndividualRadius
								)
								and self:IsCommander(savior)
							then
								print("Sir, we must hurry! The enemy are increasing their reinforcements...")
								self.MissionSettings["Interval"] = math.ceil(self.MissionSettings["Interval"] * 0.66)
								self.MissionNextReinforcements = self.MissionNextReinforcements
									- self.MissionSettings["Interval"]
								self.MissionBrain.AIMode = Actor.AIMODE_SENTRY
								self:SetAlly(self.MissionBrain, false)
								self:SwitchToActor(self.MissionBrain, player, savior.Team)
								break
							end
						end
					end
				end
				if self.MissionCraftCheckTime < self.Time then
					self.MissionCraftCheckTime = self.Time + 2
					if
						SceneMan:CastObstacleRay(
							self.MissionBrain.Pos,
							Vector(0, -self.MissionBrain.Pos.Y),
							Vector(),
							Vector(),
							self.MissionBrain.ID,
							self.MissionBrain.Team,
							rte.airID,
							10
						) < 0
					then
						local f = CF["GetPlayerFaction"](self.GS, self.MissionSourcePlayer)
						self.MissionCraft = CF["MakeActor"](CF["Crafts"][f], CF["CraftClasses"][f], CF["CraftModules"][f])
							or CreateACDropShip("Dropship MK1", "Base.rte")
						self.MissionCraft.Pos = Vector(self.MissionBrain.Pos.X, -10)
						self.MissionCraft.Team = self.MissionBrain.Team
						self.MissionCraft.AIMode = Actor.AIMODE_STAY
						MovableMan:AddActor(self.MissionCraft)
						self:SetAlly(self.MissionCraft, true)

						self.MissionBrain.AIMode = Actor.AIMODE_SENTRY
						-- Stop following the brain, let it board the ship in peace
						if self:IsAlly(self.MissionBrain) then
							for actor in MovableMan.Actors do
								if
									self:IsAlly(actor)
									and actor.MOMoveTarget
									and actor.MOMoveTarget.ID == self.MissionBrain.ID
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
					self.MissionBrain = actor
					break
				end
			end
		end
		if not MovableMan:IsActor(self.MissionBrain) then
			if self.MissionSettings["Evacuated"] then
				self:GiveMissionRewards()
				self.MissionStage = self.MissionStages.COMPLETED
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
							CF["HuntForActors"](actor, Activity.NOTEAM)
						end
					end
				end
				self.MissionStage = self.MissionStages.FAILED
			end
			self.MissionBrain = nil
			-- Remember when we started showing misison status message
			self.MissionStatusShowStart = self.Time
			self.MissionEnd = self.Time
		else
			self.MissionStatus = "COMMANDER ALIVE"

			if self.Time >= self.MissionNextReinforcements then
				local actorCount = { [CF["PlayerTeam"]] = 0, [CF["CPUTeam"]] = 0 }
				for actor in MovableMan.Actors do
					if actor.ID ~= self.MissionBrain.ID then
						if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
							if actor.Team == CF["CPUTeam"] then
								actorCount[CF["CPUTeam"]] = actorCount[CF["CPUTeam"]] + 1
								if actor.AIMode ~= Actor.AIMODE_GOTO then
									CF["Hunt"](actor, { self.MissionBrain })
								end
							elseif actor.Team == CF["PlayerTeam"] then
								actorCount[CF["PlayerTeam"]] = actorCount[CF["PlayerTeam"]] + 1
								if
									self.MissionCraft == nil
									and self:IsAlly(actor)
									and actor.AIMode ~= Actor.AIMODE_GOTO
									and SceneMan
										:ShortestDistance(actor.Pos, self.MissionBrain.Pos, SceneMan.SceneWrapsX)
										:MagnitudeIsLessThan(50)
								then
									CF["Hunt"](actor, { self.MissionBrain })
								end
							end
						elseif actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket" then
							if actor.Team == CF["CPUTeam"] then
								actorCount[CF["CPUTeam"]] = actorCount[CF["CPUTeam"]] + actor.InventorySize
							elseif actor.Team == CF["PlayerTeam"] then
								actorCount[CF["PlayerTeam"]] = actorCount[CF["PlayerTeam"]] + actor.InventorySize
							end
						end
					end
				end
				if #self.MissionLZs > 0 and MovableMan:GetMOIDCount() < CF["MOIDLimit"] then
					if self.MissionSettings["EnemyDropShips"] > 0 then
						local count = math.ceil(
							RangeRand(
								self.MissionSettings["SpawnUnitCount"] / 2,
								self.MissionSettings["SpawnUnitCount"]
							)
						)
						local f = CF["GetPlayerFaction"](self.GS, self.MissionTargetPlayer)

						local ship = CF["MakeActor"](CF["Crafts"][f], CF["CraftClasses"][f], CF["CraftModules"][f])
						if ship then
							for i = 1, count do
								local actor = CF["SpawnAIUnit"](self.GS, self.MissionTargetPlayer, CF["CPUTeam"], nil, nil)
								if actor then
									if actor.AIMode == Actor.AIMODE_BRAINHUNT then
										CF["Hunt"](actor, { self.MissionBrain })
									end
									if i == self.MissionSettings["SpawnUnitCount"] and math.random() < 0.5 then
										actor:AddInventoryItem(CreateTDExplosive("Timed Explosive"))
									end
									actorCount[CF["CPUTeam"]] = actorCount[CF["CPUTeam"]] + 1
									ship:AddInventoryItem(actor)
								end
							end
							ship.Team = CF["CPUTeam"]
							ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
							ship.AIMode = Actor.AIMODE_DELIVER
							MovableMan:AddActor(ship)

							self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] - 1
						end
					else
						-- Don't stop at zero dropships, just delay the enemy whenever they lose one
						self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] + 1
					end
				end
				self.MissionNextReinforcements = self.Time
					+ self.MissionSettings["Interval"]
					+ math.ceil(actorCount[CF["CPUTeam"]] / math.sqrt(math.max(actorCount[CF["PlayerTeam"]], 1)))
			end
		end
	elseif self.MissionStage == self.MissionStages.FAILED then
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF["MusicTypes"].DEFEAT)
			self.MissionEndMusicPlayed = true
		end
		if self.Time < self.MissionStatusShowStart + CF["MissionResultShowInterval"] then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:ClearScreenText(player)
				FrameMan:SetScreenText(self.MissionStatus, player, 0, 1000, true)
			end
		end
	elseif self.MissionStage == self.MissionStages.COMPLETED then
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF["MusicTypes"].VICTORY)
			self.MissionEndMusicPlayed = true
		end
		self.MissionStatus = "MISSION COMPLETED"

		if self.Time < self.MissionStatusShowStart + CF["MissionResultShowInterval"] then
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
