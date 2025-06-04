-----------------------------------------------------------------------
--	Objective: 	Kill all invading troops.
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("FACTION AMBUSH CREATE")

	self.encounterData["assaultDelay"] = 15;
	self.encounterData["assaultStartTime"] = tonumber(self.GS["Time"]) + self.encounterData["assaultDelay"];
	
	self.vesselData["flightDisabled"] = false;
	self.vesselData["flightAimless"] = true;
	self.vesselData["lifeSupportEnabled"] = true;
	self.vesselData["beamEnabled"] = false;
	self.vesselData["itemStorageEnabled"] = true;
	self.vesselData["cloneStorageEnabled"] = true;
	self.vesselData["bridgeEnabled"] = true;

	-- Select random assault CPU based on how angry they are
	local angry = {};
	local anger = {};

	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		local rep = tonumber(self.GS["Participant" .. i .. "Reputation"]);
		if rep <= CF.ReputationHuntThreshold then
			angry[#angry + 1] = i;
			anger[#anger + 1] = math.min(CF.MaxDifficulty, math.max(1, math.floor(-rep / CF.ReputationPerDifficulty)));
		end
	end

	if #angry > 0 then
		local antagonist = CF.WeightedSelection(anger);

		self.encounterData["ambushAssailant"] = angry[antagonist];
		self.encounterData["difficulty"] = anger[antagonist];
	end

	local difficulty = self.encounterData["difficulty"];

	local locations = {};

	for i = 1, #CF.Location do
		local id = CF.Location[i];

		if CF.IsLocationHasAttribute(id, CF.AssaultDifficultyVesselClass[difficulty]) then
			locations[#locations + 1] = id;
		end
	end

	self.encounterData["counterattackLocation"] = locations[math.random(#locations)];

	local message = CF.GetPlayerFaction(self.GS, self.encounterData["ambushAssailant"]) .. " "
		.. CF.AssaultDifficultyTexts[difficulty] .. " approaching."
		.. "\n" .. "BATTLE STATIONS!";
	self:SendTransmission(message, {});
	self:GiveFocusToBridge();
	self:StartMusic(CF.MusicTypes.SHIP_INTENSE);

	self.encounterData["enemiesToSpawn"] = CF.AssaultDifficultyUnitCount[difficulty];
	self.encounterData["nextSpawnTime"] = self.encounterData["assaultStartTime"];
	self.encounterData["assaultSpawn"] = SceneMan.Scene:GetArea("Vessel Assault Spawn");
	self.encounterData["nextSpawnPos"] = self.encounterData["assaultSpawn"] and self.encounterData["assaultSpawn"]:GetRandomPoint() or self.EnemySpawn[math.random(#self.EnemySpawn)];
	self.encounterData["ambushWarningPeriod"] = 6 - math.floor(difficulty * 0.5 + 0.5);

	-- Create attacker's unit presets
	local factionAttacking = CF.GetPlayerFaction(self.GS, self.encounterData["ambushAssailant"]);
	local techLevel = CF.GetTechLevelFromDifficulty(factionAttacking, difficulty);
	CF.CreateAIUnitPresets(self.GS, self.encounterData["ambushAssailant"], techLevel);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	FrameMan:ClearScreenText(0);
	
	local difficulty = self.encounterData["difficulty"];
	local timeLeft = self.encounterData["assaultStartTime"] - tonumber(self.GS["Time"]);

	if timeLeft > 0 then
		if tonumber(self.GS["Time"]) % 2 == 0 then
			self:MakeAlertSound(1 / math.max(timeLeft / 3, 1))
		end

		local message = CF.GetPlayerFaction(self.GS, self.encounterData["ambushAssailant"]) .. " "
			.. CF.AssaultDifficultyTexts[self.encounterData["difficulty"]] .. " approaching in T-" .. timeLeft .. "."
			.. "\n" .. "BATTLE STATIONS!";
		self:SendTransmission(message, {});
		FrameMan:SetScreenText(message, 0, 0, 1000, true);
	end

	if timeLeft == tonumber(self.GS["Time"]) then
		self:DestroyTurretsControlPanelUI();
		self.vesselData["lifeSupportEnabled"] = false;
		self.vesselData["itemStorageEnabled"] = false;
		self.vesselData["cloneStorageEnabled"] = true;
	end

	-- Show enemies count
	if tonumber(self.GS["Time"]) % 10 == 0 and self.encounterData["enemiesToSpawn"] > 0 then
		FrameMan:SetScreenText("Remaining assault bots: " .. self.encounterData["enemiesToSpawn"], 0, 0, 1000, true);
	end

	local unitsPresent = CF.CountActors(Activity.TEAM_2) > 0;
	local unitsRemaining = self.encounterData["enemiesToSpawn"] > 0;

	if unitsRemaining and tonumber(self.GS["Time"]) > self.encounterData["nextSpawnTime"] - self.encounterData["ambushWarningPeriod"] then
		self:AddObjectivePoint("INTRUDER\nALERT", self.encounterData["nextSpawnPos"], CF.PlayerTeam, GameActivity.ARROWDOWN);

		if self.TeleportEffectTimer:IsPastSimMS(50) then
			local p = CreateMOSParticle("Tiny Blue Glow", "VoidWanderers.rte");
			p.Pos = self.encounterData["nextSpawnPos"] + Vector(math.random(-20, 20), math.random(10, 30));
			MovableMan:AddParticle(p);
			self.TeleportEffectTimer:Reset();
		end
	end

	if self.encounterData["nextSpawnTime"] == tonumber(self.GS["Time"]) and unitsRemaining then
		self.encounterData["nextSpawnTime"] = tonumber(self.GS["Time"]) + CF.AssaultDifficultySpawnInterval[difficulty];
		local defaultCount = CF.AssaultDifficultySpawnBurst[difficulty];
		local cnt = math.random(math.ceil(defaultCount * 0.5), defaultCount);
		local engineer = false;

		for i = 1, cnt do
			if self.encounterData["enemiesToSpawn"] > 0 then
				local actor = CF.MakeUnit(self.GS, self.encounterData["ambushAssailant"]);

				if actor then
					actor.Team = CF.CPUTeam;
					actor.Pos = self.encounterData["nextSpawnPos"] + Vector(math.random(-4, 4), math.random(-2, 2));
					actor.AIMode = Actor.AIMODE_BRAINHUNT;
					actor.HFlipped = cnt == 1 and math.random() < 0.5 or i % 2 == 0;
					MovableMan:AddActor(actor);
					actor:FlashWhite(math.random(200, 300));
						
					if not engineer and math.random() < 0.1 then
						actor:AddInventoryItem(math.random() < 0.5 and CreateHDFirearm("Heavy Digger", "Base.rte") or CreateTDExplosive("Timed Explosive", "Coalition.rte"))
						engineer = true;
					end

					self.encounterData["enemiesToSpawn"] = self.encounterData["enemiesToSpawn"] - 1;
				end
			end
		end

		local sfx = CreateAEmitter("Teleporter Effect 1", "VoidWanderers.rte");
		sfx.Pos = self.encounterData["nextSpawnPos"];
		MovableMan:AddParticle(sfx);

		self.encounterData["nextSpawnPos"] = self.encounterData["assaultSpawn"]:GetRandomPoint();
	end
	
	if not (unitsPresent or unitsRemaining) then
		if not self.encounterData["counterAttackNotified"] then
			self:GiveRandomExperienceReward(difficulty);
			self.encounterData["counterattackExpiration"] = tonumber(self.GS["Time"]) + 15;
			self.encounterData["counterAttackNotified"] = true;
			self.GS["Location"] = self.encounterData["counterattackLocation"];
			self.GS["LocationInhabitants"] = self.encounterData["ambushAssailant"];
			CF.SetLocationSecurity(self.GS, self.GS["Location"], self.encounterData["difficulty"] * 10);
		end

		local timeLeft = (self.encounterData["counterattackExpiration"] - tonumber(self.GS["Time"]));
		local message = "";

		message = "Enemy will charge its FTL drive in T-" .. timeLeft .. ", we can counterattack!"
			.. "\n\n" .. "Deploy your away team to the enemy ship!";

		self:SendTransmission(message, {"Let em leave!"});
		FrameMan:SetScreenText(message, 0, 0, 1000, true);
		self.vesselData["beamEnabled"] = true;

		local variant = self.vesselData["dialogOptionChosen"];

		if tonumber(self.GS["Time"]) > self.encounterData["counterattackExpiration"] or variant == 1 then
			self.reportData = {};
			self.reportData[#self.reportData + 1] = "We survived this assault.";
			CF.SaveMissionReport(self.GS, self.reportData);

			self.encounterData["encounterConcluded"] = true;
			self.GS["Location"] = nil;
			self.GS["LocationInhabitants"] = nil;

			self.vesselData["flightDisabled"] = false;
			self.vesselData["flightAimless"] = false;
			self.vesselData["lifeSupportEnabled"] = true;
			self.vesselData["beamEnabled"] = true;
			self.vesselData["itemStorageEnabled"] = true;
			self.vesselData["cloneStorageEnabled"] = true;
			self.vesselData["bridgeEnabled"] = true;
			self:RemoveDeployedTurrets();
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------