-----------------------------------------------------------------------------------------
--	Objective: 	Survive a few waves of incoming dropships while keeping at least one actor inside
--				the base box
--	Set used: 	Enemy
--	Events: 	AI will send a few dropships with troops depending on mission difficulty. If CPU
--				will be unable to deploy forces due to MOID limit, then it will fire beam weapon until
--				there are enough MOIDs to start assault
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	-- Mission difficulty settings
	local setts

	setts = {}
	setts[1] = {}
	setts[1]["SpawnRate"] = 0.40
	setts[1]["EnemyDropShips"] = 3
	setts[1]["Interval"] = 28
	setts[1]["TroopCount"] = 2

	setts[2] = {}
	setts[2]["SpawnRate"] = 0.40
	setts[2]["EnemyDropShips"] = 3
	setts[2]["Interval"] = 26
	setts[2]["TroopCount"] = 2

	setts[3] = {}
	setts[3]["SpawnRate"] = 0.35
	setts[3]["EnemyDropShips"] = 4
	setts[3]["Interval"] = 24
	setts[3]["TroopCount"] = 2

	setts[4] = {}
	setts[4]["SpawnRate"] = 0.35
	setts[4]["EnemyDropShips"] = 4
	setts[4]["Interval"] = 22
	setts[4]["TroopCount"] = 3

	setts[5] = {}
	setts[5]["SpawnRate"] = 0.30
	setts[5]["EnemyDropShips"] = 4
	setts[5]["Interval"] = 21
	setts[5]["TroopCount"] = 3

	setts[6] = {}
	setts[6]["SpawnRate"] = 0.30
	setts[6]["EnemyDropShips"] = 5
	setts[6]["Interval"] = 20
	setts[6]["TroopCount"] = 3

	self.MissionSettings = setts[self.MissionDifficulty]
	self.MissionStart = self.Time

	-- We're going to alter ally presets, ally units may be tougher or weaker then enemy units
	CF.CreateAIUnitPresets(
		self.GS,
		self.MissionSourcePlayer,
		self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"] * 0.5
	)

	-- Remove all non-player doors, because allied units will be deployed inside CPU bases
	if CF.LocationRemoveDoors[self.GS["Location"]] ~= nil and CF.LocationRemoveDoors[self.GS["Location"]] == true then
		for actor in MovableMan.Actors do
			if actor.ClassName == "ADoor" then
				actor.Team = CF.PlayerTeam
			end
		end
	end

	-- Use generic enemy set
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Enemy")
	self:DeployGenericMissionEnemies(
		set,
		"Enemy",
		self.MissionSourcePlayer,
		CF.PlayerTeam,
		self.MissionSettings["SpawnRate"]
	)

	-- DEBUG Clear deployment table to disable ally spawn
	--self.SpawnTable = nil

	self.MissionStage = CF.MissionStages.ACTIVE

	self.MissionReinforcementsTriggered = false
	self.MissionNextReinforcements = self.Time + math.ceil(self.MissionSettings["Interval"] * 0.5)
	self.MissionShootParticleCannon = false
	self.MissionParticleCannonLastShot = self.Time
	self.MissionParticleCannonInterval = 6
	self.SuperWeaponInitialized = false

	self.BaseEffectTimer = Timer()
	self.BaseEffectTimer:Reset()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	if self.MissionStage == CF.MissionStages.ACTIVE then
		local friends = 0
		local enemies = 0

		for actor in MovableMan.Actors do
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
		if friends > 0 and self.MissionReinforcementsTriggered == false then
			self.MissionReinforcementsTriggered = true
			self.MissionNextReinforcements = self.Time + 10
		end

		if not self.MissionReinforcementsTriggered or friends < 2 then
			-- If nobody was spawned at the base then show player where to go and what to defend
			for i = 1, #self.missionData["missionBase"] do
				self:AddObjectivePoint("DEFEND BASE", self.missionData["missionBase"][i].Center, CF.PlayerTeam, GameActivity.ARROWDOWN)
			end

			if self.BaseEffectTimer:IsPastSimMS(25) then
				-- Create particle
				for i = 1, #self.missionData["missionBase"] do
					local p = CreateMOSParticle("Tiny Static Blue Glow", self.ModuleName)
					p.Pos = self.missionData["missionBase"][i]:GetRandomPoint()
					MovableMan:AddParticle(p)
				end
				self.BaseEffectTimer:Reset()
			end
		end --]]--

		self.MissionStatus = "Dropships: " .. math.ceil(self.MissionSettings["EnemyDropShips"])

		-- Start checking for defeat only when all units were spawned
		if self.SpawnTable == nil and friends == 0 and self.MissionReinforcementsTriggered then
			self.MissionStage = CF.MissionStages.FAILED
			self.MissionStatusShowStart = self.Time

			-- Destroy additional functions
			self.MissionDefendFireSuperWeapon = nil
			self.MissionDefendIsTargetReachable = nil
		end

		-- Check for victory
		if enemies == 0 and self.MissionSettings["EnemyDropShips"] <= 0 then
			self:GiveMissionRewards()
			self.MissionStage = CF.MissionStages.COMPLETED
			self.MissionStatusShowStart = self.Time

			-- Destroy additional functions
			self.MissionDefendFireSuperWeapon = nil
			self.MissionDefendIsTargetReachable = nil
		end

		-- Send reinforcements if available
		if
			self.MissionReinforcementsTriggered
			and #self.MissionLZs > 0
			and self.MissionSettings["EnemyDropShips"] > 0
			and self.Time >= self.MissionNextReinforcements
		then
			if MovableMan:GetMOIDCount() < CF.MOIDLimit then
				local count = math.random(
					math.ceil(self.MissionSettings["TroopCount"] * 0.5),
					self.MissionSettings["TroopCount"]
				)
				local f = CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)
				local ship = CF.MakeActor(CF.Crafts[f], CF.CraftClasses[f], CF.CraftModules[f])
				if ship then
					for i = 1, count do
						local actor = CF.SpawnAIUnit(
							self.GS,
							self.MissionTargetPlayer,
							CF.CPUTeam,
							nil,
							Actor.AIMODE_SENTRY
						)
						if actor then
							ship:AddInventoryItem(actor)
						end
					end
					ship.Team = CF.CPUTeam
					ship.Pos = Vector(self.MissionLZs[math.random(#self.MissionLZs)].X, -10)
					ship.AIMode = Actor.AIMODE_DELIVER
					MovableMan:AddActor(ship)
				end
				-- Remove one and a half drop ships on every spawn so that the enemy eventually runs out
				self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] - 1.5
			end
			self.MissionNextReinforcements = self.Time
				+ self.MissionSettings["Interval"]
				+ math.ceil(enemies / math.sqrt(math.max(friends, 1)))
		end

		-- Use particle cannon to destroy some allies preventing enemy to deploy
		-- This can never happen
		if enemies == 0 and MovableMan:GetMOIDCount() >= CF.MOIDLimit then
			if self.Time == self.MissionParticleCannonLastShot + self.MissionParticleCannonInterval then
				self.MissionParticleCannonLastShot = self.Time
				self:MissionDefendFireSuperWeapon(true, CF.CPUTeam, CF.PlayerTeam)
			else
				self:MissionDefendFireSuperWeapon(false, CF.CPUTeam, CF.PlayerTeam)
			end
		end
	elseif self.MissionStage == CF.MissionStages.FAILED then
		self.MissionStatus = "MISSION FAILED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.DEFEAT)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.MissionStatusShowStart + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				local screen = self:ScreenOfPlayer(player);
				FrameMan:ClearScreenText(screen)
				FrameMan:SetScreenText(self.MissionStatus, screen, 0, 1000, true)
			end
		end
	elseif self.MissionStage == CF.MissionStages.COMPLETED then
		self.MissionStatus = "MISSION COMPLETED"
		if not self.MissionEndMusicPlayed then
			self:StartMusic(CF.MusicTypes.VICTORY)
			self.MissionEndMusicPlayed = true
		end

		if self.Time < self.MissionStatusShowStart + CF.MissionResultShowInterval then
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				local screen = self:ScreenOfPlayer(player);
				FrameMan:ClearScreenText(screen)
				FrameMan:SetScreenText(self.MissionStatus, screen, 0, 1000, true)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionDefendFireSuperWeapon(active, ownerteam, enemyteam)
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
			if self:IsAlly(actor) then
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
					and not actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua")
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
end
-----------------------------------------------------------------------------------------
--	Returns true if target can be reached by beam on surface
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionDefendIsTargetReachable(target)
	if MovableMan:IsActor(target) then
		local shotpos = SceneMan:MovePointToGround(Vector(target.Pos.X, 0), 20, 3)
		if SceneMan:ShortestDistance(target.Pos, shotpos, true):MagnitudeIsLessThan(30) then
			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
