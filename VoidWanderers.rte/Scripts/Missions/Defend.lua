-----------------------------------------------------------------------
--	Objective: 	Survive a few waves of incoming dropships while keeping at least one actor inside
--				the base box
--	Set used: 	Enemy
--	Events: 	AI will send a few dropships with troops depending on mission difficulty. If CPU
--				will be unable to deploy forces due to MOID limit, then it will fire beam weapon until
--				there are enough MOIDs to start assault
--
-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("DEFEND CREATE")
	
	-- Mission difficulty settings
	local diff = self.missionData["difficulty"]
	
	if diff == 1 then
		self.missionData["spawnRate"] = 0.40
		self.missionData["enemyDropShips"] = 3
		self.missionData["interval"] = 28
		self.missionData["troopCount"] = 2
	elseif diff == 2 then
		self.missionData["spawnRate"] = 0.40
		self.missionData["enemyDropShips"] = 3
		self.missionData["interval"] = 26
		self.missionData["troopCount"] = 2
	elseif diff == 3 then
		self.missionData["spawnRate"] = 0.35
		self.missionData["enemyDropShips"] = 4
		self.missionData["interval"] = 24
		self.missionData["troopCount"] = 2
	elseif diff == 4 then
		self.missionData["spawnRate"] = 0.35
		self.missionData["enemyDropShips"] = 4
		self.missionData["interval"] = 22
		self.missionData["troopCount"] = 3
	elseif diff == 5 then
		self.missionData["spawnRate"] = 0.30
		self.missionData["enemyDropShips"] = 4
		self.missionData["interval"] = 21
		self.missionData["troopCount"] = 3
	elseif diff == 6 then
		self.missionData["spawnRate"] = 0.30
		self.missionData["enemyDropShips"] = 5
		self.missionData["interval"] = 20
		self.missionData["troopCount"] = 3
	end

	-- Use generic enemy set
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")
	-- Get LZs
	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Enemy", set, "LZ")

	-- Get base
	self:ObtainBaseBoxes("Enemy", set)

	-- Remove all non-player doors, because allied units will be deployed inside CPU bases
	if CF.LocationRemoveDoors[self.GS["Location"]] ~= nil and CF.LocationRemoveDoors[self.GS["Location"]] == true then
		for actor in MovableMan.Actors do
			if actor.ClassName == "ADoor" then
				actor.Team = CF.PlayerTeam
			end
		end
	end
	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.missionData["missionContractor"],
		CF.PlayerTeam,
		self.missionData["spawnRate"]
	)

	self.missionData["reinforcementsTriggered"] = false
	self.missionData["reinforcementsNext"] = self.Time + math.ceil(self.missionData["interval"] * 0.5)

	self.missionData["baseEffectTimer"] = Timer()
	self.missionData["baseEffectTimer"]:Reset()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.missionData["stage"] == CF.MissionStages.ACTIVE then
		local friends = 0
		local enemies = 0
		
		local actorList = {}
		for actor in MovableMan.Actors do
			table.insert(actorList, actor)
		end
		for actor in MovableMan.AddedActors do
			table.insert(actorList, actor)
		end
		for _, actor in ipairs(actorList) do
			if IsAHuman(actor) or IsACrab(actor) or IsACraft(actor) then
				if actor.Team == CF.PlayerTeam then
					local inside = false

					for i = 1, #self.missionData["missionBase"] do
						if self.missionData["missionBase"][i]:IsWithinBox(actor.Pos) then
							friends = friends + 1
							inside = true
							break
						end
					end

					if inside and self.Time % 5 == 0 then
						self:AddObjectivePoint("HOLD POSITION", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWDOWN)
					end
				elseif actor.Team == CF.CPUTeam then
					enemies = enemies + 1
					CF.HuntForActors(actor, CF.PlayerTeam)
				end
			end
		end

		-- As soon as there's at least one defender ready - start assault
		if friends > 0 and self.missionData["reinforcementsTriggered"] == false then
			self.missionData["reinforcementsTriggered"] = true
			self.missionData["reinforcementsNext"] = self.Time + 10
		end

		if not self.missionData["reinforcementsTriggered"] or friends < 2 then
			-- If nobody was spawned at the base then show player where to go and what to defend
			for i = 1, #self.missionData["missionBase"] do
				self:AddObjectivePoint("DEFEND BASE", self.missionData["missionBase"][i].Center, CF.PlayerTeam, GameActivity.ARROWDOWN)
			end

			if self.missionData["baseEffectTimer"]:IsPastSimMS(25) then
				-- Create particle
				for i = 1, #self.missionData["missionBase"] do
					local p = CreateMOSParticle("Tiny Static Blue Glow", self.ModuleName)
					p.Pos = self.missionData["missionBase"][i]:GetRandomPoint()
					MovableMan:AddParticle(p)
				end
				self.missionData["baseEffectTimer"]:Reset()
			end
		end --]]--

		self.missionData["missionStatus"] = "Dropships: " .. math.ceil(self.missionData["enemyDropShips"])

		-- Start checking for defeat only when all units were spawned
		if friends == 0 and self.missionData["reinforcementsTriggered"] then
			self.missionData["stage"] = CF.MissionStages.FAILED
			self.missionData["statusShowStart"] = self.Time

			-- Destroy additional functions
			-- self.MissionDefendFireSuperWeapon = nil
			-- self.MissionDefendIsTargetReachable = nil
		end

		-- Check for victory
		if enemies == 0 and self.missionData["enemyDropShips"] <= 0 then
			self:GiveMissionRewards()
			self.missionData["stage"] = CF.MissionStages.COMPLETED
			self.missionData["statusShowStart"] = self.Time

			-- Destroy additional functions
			-- self.MissionDefendFireSuperWeapon = nil
			-- self.MissionDefendIsTargetReachable = nil
		end

		-- Send reinforcements if available
		if
			self.missionData["reinforcementsTriggered"]
			and #self.missionData["landingZones"] > 0
			and self.missionData["enemyDropShips"] > 0
			and self.Time >= self.missionData["reinforcementsNext"]
		then
			if MovableMan:GetMOIDCount() < CF.MOIDLimit then
				local count = math.random(
					math.ceil(self.missionData["troopCount"] * 0.5),
					self.missionData["troopCount"]
				)
				local f = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])
				local ship = CF.MakeActor(CF.CraftClasses[f], CF.Crafts[f], CF.CraftModules[f])
				if ship then
					for i = 1, count do
						local actor = CF.MakeUnit(self.GS, self.missionData["missionTarget"]);
						if actor then
							actor.Team = CF.CPUTeam;
							actor.AIMode = Actor.AIMODE_SENTRY;
							ship:AddInventoryItem(actor);
						end
					end
					ship.Team = CF.CPUTeam
					ship.Pos = Vector(self.missionData["landingZones"][math.random(#self.missionData["landingZones"])].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
				end
				-- Remove one and a half drop ships on every spawn so that the enemy eventually runs out
				self.missionData["enemyDropShips"] = self.missionData["enemyDropShips"] - 1.5
			end
			self.missionData["reinforcementsNext"] = self.Time
				+ self.missionData["interval"]
				+ math.ceil(enemies / math.sqrt(math.max(friends, 1)))
		end

		-- Use particle cannon to destroy some allies preventing enemy to deploy
		-- This can never happen
		--[[if enemies == 0 and MovableMan:GetMOIDCount() >= CF.MOIDLimit then
			if self.Time == self.MissionParticleCannonLastShot + self.MissionParticleCannonInterval then
				self.MissionParticleCannonLastShot = self.Time
				self:MissionDefendFireSuperWeapon(true, CF.CPUTeam, CF.PlayerTeam)
			else
				self:MissionDefendFireSuperWeapon(false, CF.CPUTeam, CF.PlayerTeam)
			end
		end]]
	elseif self.missionData["stage"] == CF.MissionStages.FAILED then
		self.missionData["missionStatus"] = "MISSION FAILED"
		if not self.missionData["endMusicPlayed"] then
			self:StartMusic(CF.MusicTypes.DEFEAT)
			self.missionData["endMusicPlayed"] = true
		end

		if self.Time < self.missionData["statusShowStart"] + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				local screen = self:ScreenOfPlayer(player);
				FrameMan:ClearScreenText(screen)
				FrameMan:SetScreenText(self.missionData["missionStatus"], screen, 0, 1000, true)
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
				local screen = self:ScreenOfPlayer(player);
				FrameMan:ClearScreenText(screen)
				FrameMan:SetScreenText(self.missionData["missionStatus"], screen, 0, 1000, true)
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
--[[function VoidWanderers:MissionDefendFireSuperWeapon(active, ownerteam, enemyteam)
	-- Init superweapon variables
	if self.SuperWeaponInitialized == false then
		self.SuperWeaponTimer = Timer()
		self.SuperWeaponTimer:Reset()

		self.SuperWeaponInitialized = true

		self.MaxShotCount = 4
		self.MaxShotAttempts = 8
		self.ShotInterval = 1
		self.BeamEnabled = false
		self.LastBeamShot = 0
	end

	-- Control orbital cannon
	if active then
		self.BeamEnabled = true
		self.BeamLastShot = 0
		self.ShotCount = 0
		self.ShotAttempts = 0
	end

	if self.BeamEnabled and self.LastBeamShot + self.ShotInterval < self.Time then
		self.LastBeamShot = self.Time

		print("Particle beam!")

		local target
		local targetok

		-- Get target
		-- First try to shoot allies
		for actor in MovableMan.Actors do
			if CF.IsAlly(actor) then
				target = actor
				break
			end
		end

		-- Check if target is reachable
		targetok = self:MissionDefendIsTargetReachable(target)

		-- Finally find any target
		if not targetok then
			for actor in MovableMan.Actors do
				if
					actor.Team == enemyteam
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and not CF.IsBrain(actor)
				then
					target = actor
					targetok = self:MissionDefendIsTargetReachable(target)

					if targetok then
						break
					end
				end
			end
		end

		-- Fire beam
		if targetok then
			for i = 1, 6 do
				local expl = CreateAEmitter("Destroyer Cannon Shot")
				expl.Pos = Vector(target.Pos.X, 0 - i * 30)
				expl.Vel = Vector(0, 250)
				expl.Mass = 5000
				MovableMan:AddParticle(expl)
			end

			self.ShotCount = self.ShotCount + 1
			self.ShotAttempts = 0
			if self.ShotCount >= self.MaxShotCount then
				self.BeamEnabled = false
			end
		else
			self.ShotAttempts = self.ShotAttempts + 1
			if self.ShotAttempts >= self.MaxShotAttempts then
				self.BeamEnabled = false
			end
			print("NO TARGETS, ABORTING")
		end
	end
end]]
-----------------------------------------------------------------------
--	Returns true if target can be reached by beam on surface
-----------------------------------------------------------------------
--[[function VoidWanderers:MissionDefendIsTargetReachable(target)
	if MovableMan:IsActor(target) then
		local shotpos = SceneMan:MovePointToGround(Vector(target.Pos.X, 0), 20, 3)
		if SceneMan:ShortestDistance(target.Pos, shotpos, true):MagnitudeIsLessThan(30) then
			return true
		end
	end
	return false
end]]
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
