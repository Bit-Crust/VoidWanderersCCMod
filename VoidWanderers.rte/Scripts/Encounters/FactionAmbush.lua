-----------------------------------------------------------------------
--	Objective: 	Kill all invading troops.
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("FACTION AMBUSH CREATE")

	self.encounterData["assaultDelay"] = 30
	self.vesselData["flightDisabled"] = true

	-- Select random assault CPU based on how angry they are
	local angry = {}
	local anger = {}

	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		local rep = tonumber(self.GS["Player" .. i .. "Reputation"])
		if rep <= CF.ReputationHuntThreshold then
			angry[#angry + 1] = i
			anger[#anger + 1] = math.min(CF.MaxDifficulty, math.max(1, math.floor(-rep / CF.ReputationPerDifficulty)))
		end
	end

	if #angry > 0 then
		local antagonist = CF.WeightedSelection(anger)

		self.encounterData["ambushAssailant"] = angry[antagonist]
		self.encounterData["ambushDifficulty"] = anger[antagonist]
	end

	self:SendTransmission("Help, it's the " .. self.GS["Player" .. self.encounterData["ambushAssailant"] .. "Faction"], {"Ack!", "Ulp!"})
	self:StartMusic(CF.MusicTypes.SHIP_INTENSE)

	self.encounterData["enemiesToSpawn"] = CF.AssaultDifficultyUnitCount[self.encounterData["ambushDifficulty"]]
	self.encounterData["nextSpawnTime"] = self.encounterData["encounterStartTime"] + CF.AssaultDifficultySpawnInterval[self.encounterData["ambushDifficulty"]] + 1
	self.encounterData["nextSpawnPos"] = self.AssaultSpawn and self.AssaultSpawn:GetRandomPoint()
		or (self.EnemySpawn and self.EnemySpawn[math.random(#self.EnemySpawn)] or nil);
	self.encounterData["ambushWarningTime"] = 6 - math.floor(self.encounterData["ambushDifficulty"] * 0.5 + 0.5)

	-- Create attacker's unit presets
	CF.CreateAIUnitPresets(
		self.GS,
		self.encounterData["ambushAssailant"],
		CF.GetTechLevelFromDifficulty(
			self.GS, 
			self.encounterData["ambushAssailant"], 
			self.encounterData["ambushDifficulty"], 
			CF.MaxDifficulty
		)
	)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	if self.vesselData["dialogOptionChosen"] ~= 0 then
		self.encounterData["encounterConcluded"] = true
		self.vesselData["flightDisabled"] = false
		self.vesselData["dialog"] = nil
		self:RemoveDeployedTurrets()
	end

	if self.encounterData["encounterStartTime"] > self.Time then
		if self.Time % 2 == 0 then
			self:MakeAlertSound(1 / math.max(self.encounterData["encounterStartTime"] - self.Time / 30, 1))
		end
	end
	--[[
	if self.Time < self.AssaultTime then
		FrameMan:ClearScreenText(0)
		FrameMan:SetScreenText(
			CF.GetPlayerFaction(self.GS, tonumber(self.AssaultEnemyPlayer))
				.. " "
				.. CF.AssaultDifficultyTexts[self.AssaultDifficulty]
				.. " approaching in T-"
				.. self.AssaultTime - self.Time
				.. "\nBATTLE STATIONS!",
			0,
			0,
			1000,
			true
		)
	end

	-- Launch defense activity
	if self.AssaultTime == self.Time then
		self:DeployTurrets()

		-- Remove control actors
		self:DestroyBeamControlPanelUI()

		self:DestroyItemShopControlPanelUI()
		self:DestroyCloneShopControlPanelUI()

		self:DestroyTurretsControlPanelUI()

		self:StartMusic(CF.MusicTypes.SHIP_INTENSE)
	end
	self:ProcessClonesControlPanelUI()
	-- Show enemies count
	if self.Time % 10 == 0 and self.AssaultEnemiesToSpawn > 0 then
		FrameMan:SetScreenText("Remaining assault bots: " .. self.AssaultEnemiesToSpawn, 0, 0, 1500, true)
	end

	if self.AssaultEnemiesToSpawn > 0 and self.AssaultNextSpawnTime - self.Time < self.AssaultWarningTime then
		self:AddObjectivePoint("INTRUDER\nALERT", self.AssaultNextSpawnPos, CF.PlayerTeam, GameActivity.ARROWDOWN)

		if self.TeleportEffectTimer:IsPastSimMS(50) then
			local p = CreateMOSParticle("Tiny Blue Glow", self.ModuleName)
			p.Pos = self.AssaultNextSpawnPos + Vector(math.random(-20, 20), math.random(10, 30))
			MovableMan:AddParticle(p)
			self.TeleportEffectTimer:Reset()
		end
	end
	if self.Time % 2 == 0 then
		self:MakeAlertSound(1 / 4 + 3 / 4 / math.max((self.Time - self.AssaultTime) / 3, 1))
	end

	-- Spawn enemies
	if self.AssaultNextSpawnTime == self.Time then
		-- Check end of assault conditions
		if CF.CountActors(CF.CPUTeam) == 0 and self.AssaultEnemiesToSpawn == 0 then
			-- End of assault
			self.GS["Mode"] = "Vessel"

			-- Give some exp
			if self.MissionReport == nil then
				self.MissionReport = {}
			end
			self.MissionReport[#self.MissionReport + 1] = "We survived this assault."
			self:GiveRandomExperienceReward(self.AssaultDifficulty)

			-- Remove turrets
			self:RemoveDeployedTurrets()

			-- Re-init consoles
			self:InitConsoles()

			-- Launch ship assault encounter
			local id = "COUNTERATTACK"
			self.RandomEncounterID = id

			self.vesselData["dialogDefaultTimer"] = Timer()
			self.RandomEncounterText = ""
			self.RandomEncounterVariants = { "Blood for Ba'al!!", "Let them leave." }
			self.RandomEncounterVariantsInterval = 12
			self.vesselData["dialogOptionChosen"] = 0
			self.RandomEncounterIsInitialized = false
			self.vesselData["dialogOptionSelected"] = 1

			-- Set the availability of the next assault so that they don't happen back-to-back
			self.encounterEnableTime = self.Time + CF.ShipAssaultCooldown

			-- Switch to ship panel
			local bridgeempty = true
			local plrtoswitch = -1

			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				local act = self:GetControlledActor(player)

				if act and MovableMan:IsActor(act) then
					if act.PresetName ~= "Ship Control Panel" and plrtoswitch == -1 then
						plrtoswitch = player
					end

					if act.PresetName == "Ship Control Panel" then
						bridgeempty = false
					end
				end
			end

			if plrtoswitch > -1 and bridgeempty and MovableMan:IsActor(self.ShipControlPanelActor) then
				self:SwitchToActor(self.ShipControlPanelActor, plrtoswitch, CF.PlayerTeam)
			end
			self.ShipControlMode = self.ShipControlPanelModes.REPORT
		end

		--print ("Spawn")
		self.AssaultNextSpawnTime = self.Time + CF.AssaultDifficultySpawnInterval[self.AssaultDifficulty]

		local cnt = math.random(
			math.ceil(CF.AssaultDifficultySpawnBurst[self.AssaultDifficulty] * 0.5),
			CF.AssaultDifficultySpawnBurst[self.AssaultDifficulty]
		)
		local engineer = false
		for j = 1, cnt do
			if self.AssaultEnemiesToSpawn > 0 then
				local act = CF.SpawnAIUnitWithPreset(
					self.GS,
					self.AssaultEnemyPlayer,
					CF.CPUTeam,
					self.AssaultNextSpawnPos + Vector(math.random(-4, 4), math.random(-2, 2)),
					Actor.AIMODE_BRAINHUNT,
					math.random(self.AssaultDifficulty)
				)

				if act then
					self.AssaultEnemiesToSpawn = self.AssaultEnemiesToSpawn - 1
					if not engineer and math.random() < self.AssaultDifficulty / CF.MaxDifficulty then
						act:AddInventoryItem(
							(
									math.random() < 0.5 and CreateHDFirearm("Heavy Digger", "Base.rte")
									or CreateTDExplosive("Timed Explosive", "Coalition.rte")
								)
						)
						engineer = true
					end
					act.HFlipped = cnt == 1 and math.random() < 0.5 or j % 2 == 0
					MovableMan:AddActor(act)

					act:FlashWhite(math.random(200, 300))
				end
			end
		end
		local sfx = CreateAEmitter("Teleporter Effect A")
		sfx.Pos = self.AssaultNextSpawnPos
		MovableMan:AddParticle(sfx)

		self.AssaultWarningTime = 6 - math.floor(self.AssaultDifficulty * 0.5 + 0.5)
		self.AssaultNextSpawnPos = self.AssaultSpawn and self.AssaultSpawn:GetRandomPoint()
			or self.EnemySpawn[math.random(#self.EnemySpawn)]
	end
	--]]
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------