-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Start Scene Process
-----------------------------------------------------------------------
function VoidWanderers:StartSceneProcess(isNewGame)
	print("VoidWanderers:Tactics:StartSceneProcess");

	isNewGame = (isNewGame == nil) and true or isNewGame;
	
	CF.GS = self.GS;

	self.vesselData = {};
	self.missionData = {};
	self.ambientData = {};
	self.encounterData = {};

	self.playersWithBrains = {};
	self.HoldTimer = {};

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self.playersWithBrains[player + 1] = false;
		
		self.HoldTimer[player + 1] = Timer();
		self.HoldTimer[player + 1]:Reset();
	end
	
	self.AllowsUserSaving = true;
	self.BuyMenuEnabled = false;
	self.ShopsCreated = false;

	self.LastMusicType = -1;
	self.LastMusicTrack = -1;

	self.AlarmTimer = Timer();
	self.AlarmTimer:Reset();

	self.TickTimer = Timer();
	self.TickTimer:Reset();
	self.TickInterval = CF.TickInterval;

	self.TeleportEffectTimer = Timer();
	self.TeleportEffectTimer:Reset();

	self.SceneTimer = Timer();
	self.SceneTimer:Reset();

	self.ItemRemoveQueue = {};

	self.PlayerFaction = self.GS["PlayerFaction"];
	
	-- Load generic level data
	self.SceneConfig = CF.ReadDataFile("Mods/VoidWanderers.rte/Scenes/Data/" .. SceneMan.Scene.PresetName .. ".dat")
	local vesselArea = SceneMan.Scene:GetArea("Vessel");
	
	if vesselArea then
		if not isNewGame then
			self.vesselData = self.saveLoadHandler:ReadSavedStringAsTable("vesselData");
		else
			self.vesselData = {};
			self.vesselData["initialized"] = true;
			self.vesselData["team"] = self.GS["Mode"] == "Vessel" and 0 or 1;
			self.vesselData["artificialGravity"] = Vector(0, rte.PxTravelledPerFrame / (1 + SceneMan.Scene.GlobalAcc.Y));
			self.vesselData["ship"] = vesselArea;
			self.vesselData["spaceDeck"] = SceneMan.Scene:GetArea("Vessel Spacedeck") or Area("Vessel Spacedeck");
			self.vesselData["throttle"] = self.vesselData["team"] == 0 and 1 or 0;
			self.vesselData["lifeSupportEnabled"] = true;
			self.vesselData["beamEnabled"] = true;
			self.vesselData["itemStorageEnabled"] = true;
			self.vesselData["cloneStorageEnabled"] = true;
			self.vesselData["bridgeEnabled"] = true;
			self.vesselData["flightDisabled"] = false;
			self.vesselData["flightAimless"] = false;

			self.vesselData["dialogDefaultTimer"] = Timer();

			-- Create emitters
			self.vesselData["engines"] = {};
			for i = 1, 10 do
				local x, y;

				x = tonumber(self.SceneConfig["Engine" .. i .. "X"]);
				y = tonumber(self.SceneConfig["Engine" .. i .. "Y"]);

				if x and y then
					local em = CreateAEmitter("Vessel Main Thruster");

					if em then
						em.Pos = Vector(x, y);
						self.vesselData["engines"][i] = em;
						MovableMan:AddParticle(em);
						em:EnableEmission(not self.vesselData["flightDisabled"]);
						em.Throttle = self.vesselData["throttle"];
					else
						break;
					end
				else
					break;
				end
			end
		end
	end

	self.vesselData["spaceDeck"] = SceneMan.Scene:GetArea("Vessel Spacedeck") or Area("Vessel Spacedeck");

	-- Load pre-spawned enemy locations. These locations also used during assaults to place teleported units
	self.EnemySpawn = {};

	for i = 1, 32 do
		local x, y;
		x = tonumber(self.SceneConfig["EnemySpawn" .. i .. "X"]);
		y = tonumber(self.SceneConfig["EnemySpawn" .. i .. "Y"]);

		if x and y then
			self.EnemySpawn[i] = Vector(x, y);
		else
			break;
		end
	end
	
	-- Display gold like normal since the buy menu is disabled
	self:SetTeamFunds(CF.GetPlayerGold(self.GS), CF.PlayerTeam);
	--self.FogOfWarEnabled = self.GS["FogOfWar"] == "True";

	self:SetTeamAISkill(CF.PlayerTeam, tonumber(self.GS["AISkillPlayer"]) or 50);
	self.Difficulty = tonumber(self.GS["Difficulty"]) or 50;
	
	local cpuSkill = tonumber(self.GS["AISkillCPU"]);
	if cpuSkill then
		for team = Activity.TEAM_1 + 1, Activity.MAXTEAMCOUNT - 1 do
			self:SetTeamAISkill(team, cpuSkill);
		end
	end

	-- Read brain location data
	if self.GS["Mode"] == "Vessel" then
		print("VoidWanderers:Tactics:StartActivity:Vessel")

		--self.dialog = {message="This is a test, heed my warning!This is a test, heed my warning!This is a test, heed my warning!", options={"This is option 1.This is option 1.This is option 1.This is option 1.This is option 1." , "This is OPTIONS"}}

		if self.GS["Location"] ~= "Station Ypsilon-2" then
			local newLoc = Vector(48, 48):DegRotate(tonumber(self.GS["Time"]) * 0.01)
			newLoc = Vector(math.floor(newLoc.X), math.floor(newLoc.Y))
			CF.LocationPos["Station Ypsilon-2"] = newLoc
		end

		self:StartMusic(CF.MusicTypes.SHIP_CALM)

		self.BrainPos = {}
		for i = 1, 4 do
			local x = tonumber(self.SceneConfig["BrainSpawn" .. i .. "X"])
			local y = tonumber(self.SceneConfig["BrainSpawn" .. i .. "Y"])
			self.BrainPos[i] = Vector(x, y)
		end

		self.AwayTeamPos = {}
		for i = 1, 16 do
			local x, y

			x = tonumber(self.SceneConfig["AwayTeamSpawn" .. i .. "X"])
			y = tonumber(self.SceneConfig["AwayTeamSpawn" .. i .. "Y"])

			if x and y then
				self.AwayTeamPos[i] = Vector(x, y)
			else
				break
			end
		end

		local dest = 1

		-- Spawn previously saved actors
		if tonumber(self.GS["Onboard#"]) ~= 0 then
			for i = 1, tonumber(self.GS["Onboard#"]) or CF.MaxSavedActors do
				if self.onboardActors and self.onboardActors[i] then
					local actor = self.onboardActors[i]:Clone();
					self.onboardActors[i] = nil;

					local x = self.GS["Onboard" .. i .. "X"];
					local y = self.GS["Onboard" .. i .. "Y"];

					if x and y then
						actor.Pos = Vector(tonumber(x), tonumber(y))
					else
						actor.Pos = self.AwayTeamPos[dest];
						dest = dest + 1;

						if dest > #self.AwayTeamPos then
							dest = 1;
						end
					end

					if IsAHuman(actor) and ToAHuman(actor).Head == nil then
						actor.DeathSound = nil;
						actor.Status = Onboard.DEAD;
					end

					actor.AIMode = Onboard.AIMODE_SENTRY;
					actor:ClearMovePath();
					actor.Vel = actor.Vel * 0;
					actor.AngularVel = actor.AngularVel * 0;
					MovableMan:AddActor(actor);
				elseif self.GS["Onboard" .. i .. "Preset"] then
					local limbData = {};

					for _, limbName in ipairs(CF.LimbIDs[self.GS["Onboard" .. i .. "Class"]]) do
						limbData[limbName] = self.GS["Onboard" .. i .. limbName];
					end

					local actor = CF.MakeActor(
						self.GS["Onboard" .. i .. "Class"],
						self.GS["Onboard" .. i .. "Preset"],
						self.GS["Onboard" .. i .. "Module"],
						self.GS["Onboard" .. i .. "XP"],
						self.GS["Onboard" .. i .. "Identity"],
						self.GS["Onboard" .. i .. "Player"],
						self.GS["Onboard" .. i .. "Prestige"],
						self.GS["Onboard" .. i .. "Name"],
						limbData
					);

					if actor then
						actor.AIMode = Actor.AIMODE_SENTRY;
						actor:ClearAIWaypoints();
						actor.Team = CF.PlayerTeam;

						for j = 1, CF.MaxSavedItemsPerActor do
							if self.GS["Onboard" .. i .. "Item" .. j .. "Preset"] then
								local itm = CF.MakeItem(
									self.GS["Onboard" .. i .. "Item" .. j .. "Class"],
									self.GS["Onboard" .. i .. "Item" .. j .. "Preset"],
									self.GS["Onboard" .. i .. "Item" .. j .. "Module"]
								)
								if itm then
									actor:AddInventoryItem(itm)
								end
							end
						end
						
						local x = self.GS["Onboard" .. i .. "X"];
						local y = self.GS["Onboard" .. i .. "Y"];

						if x and y then
							actor.Pos = Vector(tonumber(x), tonumber(y));
						else
							actor.Pos = self.AwayTeamPos[dest];
							dest = dest + 1;

							if dest > #self.AwayTeamPos then
								dest = 1;
							end
						end

						if IsAHuman(actor) and ToAHuman(actor).Head == nil then
							actor.DeathSound = nil;
							actor.Status = Actor.DEAD;
						end

						MovableMan:AddActor(actor);
						self:AddPreEquippedItemsToRemovalQueue(actor);
					end
				else
					break;
				end
			end

			CF.ClearOnboard(self.GS);
		end

		-- Spawn previously deployed actors
		if tonumber(self.GS["Deployed#"]) ~= 0 then
			for i = 1, tonumber(self.GS["Deployed#"]) or CF.MaxSavedActors do
				if self.deployedActors and self.deployedActors[i] then
					local actor = self.deployedActors[i]:Clone();
					self.deployedActors[i] = nil;

					local x = self.GS["Deployed" .. i .. "X"]
					local y = self.GS["Deployed" .. i .. "Y"]

					if x and y then
						actor.Pos = Vector(tonumber(x), tonumber(y))
					else
						actor.Pos = self.AwayTeamPos[dest]
						dest = dest + 1

						if dest > #self.AwayTeamPos then
							dest = 1
						end
					end

					if IsAHuman(actor) and ToAHuman(actor).Head == nil then
						actor.DeathSound = nil
						actor.Status = Actor.DEAD
					end
					
					actor.AIMode = Actor.AIMODE_SENTRY
					actor:ClearMovePath()
					actor.Vel = actor.Vel * 0
					actor.AngularVel = actor.AngularVel * 0
					MovableMan:AddActor(actor)
				elseif self.GS["Deployed" .. i .. "Preset"] then
					local limbData = {}

					for _, limbName in ipairs(CF.LimbIDs[self.GS["Deployed" .. i .. "Class"]]) do
						limbData[limbName] = self.GS["Deployed" .. i .. limbName];
					end

					local actor = CF.MakeActor(
						self.GS["Deployed" .. i .. "Class"],
						self.GS["Deployed" .. i .. "Preset"],
						self.GS["Deployed" .. i .. "Module"],
						self.GS["Deployed" .. i .. "XP"],
						self.GS["Deployed" .. i .. "Identity"],
						self.GS["Deployed" .. i .. "Player"],
						self.GS["Deployed" .. i .. "Prestige"],
						self.GS["Deployed" .. i .. "Name"],
						limbData
					)

					if actor then
						actor.AIMode = Actor.AIMODE_SENTRY
						actor:ClearAIWaypoints()

						actor.Team = CF.PlayerTeam
						for j = 1, CF.MaxSavedItemsPerActor do
							if self.GS["Deployed" .. i .. "Item" .. j .. "Preset"] then
								local itm = CF.MakeItem(
									self.GS["Deployed" .. i .. "Item" .. j .. "Class"],
									self.GS["Deployed" .. i .. "Item" .. j .. "Preset"],
									self.GS["Deployed" .. i .. "Item" .. j .. "Module"]
								)
								if itm then
									actor:AddInventoryItem(itm)
								end
							end
						end
						local x = self.GS["Deployed" .. i .. "X"]
						local y = self.GS["Deployed" .. i .. "Y"]

						if x and y then
							actor.Pos = Vector(tonumber(x), tonumber(y))
						else
							actor.Pos = self.AwayTeamPos[dest]
							dest = dest + 1

							if dest > #self.AwayTeamPos then
								dest = 1
							end
						end

						if IsAHuman(actor) and ToAHuman(actor).Head == nil then
							actor.DeathSound = nil
							actor.Status = Actor.DEAD
						end

						if IsActor(actor) then
							MovableMan:AddActor(actor)
							self:AddPreEquippedItemsToRemovalQueue(actor)
						end
					end
				else
					break
				end
			end

			CF.ClearDeployed(self.GS);
		end

		self:InitConsoles();

		-- If we're on temp-location then cancel this location
		if isNewGame and CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TEMPLOCATION) then
			self.GS["Location"] = nil;
		end
	end

	if not isNewGame then
		self.reportData = self.saveLoadHandler:ReadSavedStringAsTable("reportData");
	else
		self.reportData = {};
	end
	
	if self.GS["Mode"] == "Mission" then
		print("VoidWanderers:Tactics:StartActivity:Mission");
		self:StartMusic(CF.MusicTypes.MISSION_CALM);

		self.Pts = CF.ReadPtsData(self.GS["Location"], self.SceneConfig);
		self.MissionDeploySet = CF.GetRandomMissionPointsSet(self.Pts, "Deploy");

		-- Init LZs
		self:InitLZControlPanelUI();

		-- Spawn player troops
		local dest = 1;
		local dsts = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerUnit");

		if tonumber(self.GS["Deployed#"]) ~= 0 then
			self.GS["MissionDeployedTroops"] = 1;

			for i = 1, tonumber(self.GS["Deployed#"]) or CF.MaxSavedActors do
				if self.deployedActors and self.deployedActors[i] then
					local actor = self.deployedActors[i]:Clone();
					self.deployedActors[i] = nil;

					local x = self.GS["Deployed" .. i .. "X"];
					local y = self.GS["Deployed" .. i .. "Y"];

					if x and y then
						actor.Pos = Vector(tonumber(x), tonumber(y));
					else
						actor.Pos = dsts[dest];
						dest = dest + 1;

						if dest > #dsts then
							dest = 1;
						end
					end

					if IsAHuman(actor) and ToAHuman(actor).Head == nil then
						actor.DeathSound = nil;
						actor.Status = Actor.DEAD;
					end

					actor.AIMode = Actor.AIMODE_SENTRY;
					actor:ClearMovePath();
					actor.Vel = actor.Vel * 0;
					actor.AngularVel = actor.AngularVel * 0;
					MovableMan:AddActor(actor);
					self.GS["MissionDeployedTroops"] = tonumber(self.GS["MissionDeployedTroops"]) + 1;
				elseif self.GS["Deployed" .. i .. "Preset"] then
					local limbData = {};

					for _, limbName in ipairs(CF.LimbIDs[self.GS["Deployed" .. i .. "Class"]]) do
						limbData[limbName] = self.GS["Deployed" .. i .. limbName];
					end

					local actor = CF.MakeActor(
						self.GS["Deployed" .. i .. "Class"],
						self.GS["Deployed" .. i .. "Preset"],
						self.GS["Deployed" .. i .. "Module"],
						self.GS["Deployed" .. i .. "XP"],
						self.GS["Deployed" .. i .. "Identity"],
						self.GS["Deployed" .. i .. "Player"],
						self.GS["Deployed" .. i .. "Prestige"],
						self.GS["Deployed" .. i .. "Name"],
						limbData
					);

					if actor then
						actor.AIMode = Actor.AIMODE_SENTRY;
						actor:ClearAIWaypoints();
						actor.Team = CF.PlayerTeam;

						for j = 1, CF.MaxSavedItemsPerActor do
							if self.GS["Deployed" .. i .. "Item" .. j .. "Preset"] then
								local itm = CF.MakeItem(
									self.GS["Deployed" .. i .. "Item" .. j .. "Class"],
									self.GS["Deployed" .. i .. "Item" .. j .. "Preset"],
									self.GS["Deployed" .. i .. "Item" .. j .. "Module"]
								);

								if itm then
									actor:AddInventoryItem(itm);
								end
							end
						end

						local x = self.GS["Deployed" .. i .. "X"];
						local y = self.GS["Deployed" .. i .. "Y"];

						if x and y then
							actor.Pos = Vector(tonumber(x), tonumber(y));
						else
							actor.Pos = dsts[dest];
							dest = dest + 1;

							if dest > #dsts then
								dest = 1;
							end
						end

						if IsAHuman(actor) and ToAHuman(actor).Head == nil then
							actor.DeathSound = nil;
							actor.Status = Actor.DEAD;
						end

						MovableMan:AddActor(actor);
						self:AddPreEquippedItemsToRemovalQueue(actor);
					end

					self.GS["MissionDeployedTroops"] = tonumber(self.GS["MissionDeployedTroops"]) + 1;
				else
					break;
				end
			end

			CF.ClearDeployed(self.GS);
		end

		-- Clear previous script functions
		self.MissionCreate = nil;
		self.MissionUpdate = nil;
		self.MissionDestroy = nil;

		self.AmbientCreate = nil;
		self.AmbientUpdate = nil;
		self.AmbientDestroy = nil;
		
		if isNewGame then
			for actor in MovableMan.Actors do
				if actor.ClassName == "ADoor" then
					actor.Team = Activity.TEAM_2;
				end
			end
		end

		-- Load ambience and mission data if possible
		if not isNewGame then
			self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData");
			self.ambientData = self.saveLoadHandler:ReadSavedStringAsTable("ambientData");

			if self.missionData["initialized"] then
				dofile(self.missionData["scriptPath"]);
			end

			if self.ambientData["initialized"] then
				dofile(self.ambientData["scriptPath"]);
			end
		else
			-- Generic mission data, some may be overwritten
			self.missionData = {};
			self.missionData["initialized"] = true;
			self.missionData["endMusicPlayed"] = false;
			self.missionData["missionStartTime"] = tonumber(self.GS["Time"]);
			self.missionData["stage"] = CF.MissionStages.ACTIVE;
			self.missionData["advanceMissions"] = true;
			self.missionData["missionStatus"] = "";
			self.missionData["difficulty"] = CF.NormalizeDifficulty(CF.GetLocationSecurity(self.GS, self.GS["Location"]) / 10);
			self.missionData["reputationReward"] = 0;
			self.missionData["goldReward"] = 0;

			-- Find available mission
			for mission = 1, CF.MaxMissions do
				if self.GS["Location"] == self.GS["Mission" .. mission .. "Location"] then
					local missionType = self.GS["Mission" .. mission .. "Type"];

					self.missionData["difficulty"] = CF.GetFullMissionDifficulty(self.GS, self.GS["Location"], mission);
					self.missionData["scriptPath"] = CF.MissionScript[missionType];

					local goldBase = CF.MissionGoldRewardPerDifficulty[missionType];
					self.missionData["goldReward"] = CF.CalculateReward(goldBase, self.missionData["difficulty"]);
					local reputationBase = CF.MissionReputationRewardPerDifficulty[missionType];
					self.missionData["reputationReward"] = CF.CalculateReward(reputationBase, self.missionData["difficulty"]);

					self.missionData["missionContractor"] = tonumber(self.GS["Mission" .. mission .. "SourcePlayer"]);
					local contractorFaction = CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"]);
					local contractorTech = CF.GetTechLevelFromDifficulty(contractorFaction, self.missionData["difficulty"]);
					CF.CreateAIUnitPresets(self.GS, self.missionData["missionContractor"], contractorTech);

					self.missionData["missionTarget"] = tonumber(self.GS["Mission" .. mission .. "TargetPlayer"]);
					local targetFaction = CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"]);
					local targetTech = CF.GetTechLevelFromDifficulty(targetFaction, self.missionData["difficulty"]);
					CF.CreateAIUnitPresets(self.GS, self.missionData["missionTarget"], targetTech);

					break;
				end
			end

			-- Increase location security every time deployment happens
			CF.ChangeLocationSecurity(self.GS, self.GS["Location"], CF.SecurityIncrementPerDeployment);

			-- Backup mission script
			if self.missionData["scriptPath"] == nil then
				local defaultScripts = CF.LocationScript[self.GS["Location"]];

				if defaultScripts then
					self.missionData["scriptPath"] = defaultScripts[math.random(#defaultScripts)];
				else
					self.missionData["scriptPath"] = "VoidWanderers.rte/Scripts/Missions/Generic.lua";
				end
			end

			-- Generic ambient bits, I don't think they're ever used
			self.ambientData = {};
			self.ambientData["scriptPath"] = CF.LocationAmbientScript[self.GS["Location"]];
			self.ambientData["initialized"] = true;
			
			if self.ambientData["scriptPath"] == nil then
				self.ambientData["scriptPath"] = "VoidWanderers.rte/Scripts/Ambience/Generic.lua";
			end

			dofile(self.missionData["scriptPath"]);
			dofile(self.ambientData["scriptPath"]);
			self:MissionCreate();
			self:AmbientCreate();
		end

		if isNewGame then
			-- Spawn crates
			local crts = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "Crates");
			local amount = math.min(math.ceil(CF.CratesRate * #crts), #crts);
			local crtspos = CF.RandomSampleOfList(crts, amount);

			for i = 1, #crtspos do
				local cachePreset = math.random() < CF.ActorCratesRate and "Crate" or "Case";
				local cacheClass = (cachePreset == "Case" and math.random() < 0.01) and "AHuman" or "Attachable";
				local cache = nil;

				if cacheClass == "AHuman" then
					cache = CreateAHuman(cachePreset, self.ModuleName);
				else
					cache = CreateAttachable(cachePreset, self.ModuleName);
				end

				if cache then
					cache.Pos = crtspos[i] + Vector(math.random(-10, 10), math.random(-3, 3));
					cache.RotAngle = math.random() * 0.6 - 0.3;

					if math.random() < CF.CrateRandomLocationsRate then
						local materialThreshold = 100;
						local airPenalty = 50;
						local surroundingStrength = 0;
						local paddingX = SceneMan.SceneWrapsX and 0 or 50;
						local paddingY = SceneMan.SceneWrapsY and 0 or 50;
						local potentialX = math.random(paddingX, SceneMan.SceneWidth - paddingX);
						local potentialY = math.random(paddingY, SceneMan.SceneHeight - paddingY);
						local terrCheck = SceneMan:GetTerrMatter(potentialX, potentialY);

						if terrCheck == rte.airID then
							potentialY = potentialY + SceneMan:FindAltitude(Vector(potentialX, potentialY), 0, 0);
							potentialY = math.random(potentialY, SceneMan.SceneHeight - 50);
							terrCheck = SceneMan:GetTerrMatter(potentialX, potentialY);
						end

						if terrCheck ~= rte.airID then
							surroundingStrength = surroundingStrength + SceneMan:GetMaterialFromID(terrCheck).StructuralIntegrity
							local radius = cache.Radius;
							local dots = 5;

							for i = 1, dots do
								local theta = (math.pi * 2) * (i / dots);
								local checkX = potentialX + radius * math.cos(theta);
								local checkY = potentialY + radius * math.sin(theta);
								terrCheck = SceneMan:GetTerrMatter(checkX, checkY);
								surroundingStrength = surroundingStrength + SceneMan:GetMaterialFromID(terrCheck).StructuralIntegrity;

								if terrCheck == rte.airID then
									surroundingStrength = surroundingStrength + airPenalty;
								end
							end

							if surroundingStrength < materialThreshold * (1 + dots) then
								cache.Pos = Vector(potentialX, potentialY);
								cache.RotAngle = math.random() * math.pi * 2;
							end
						end
					end

					cache.PinStrength = cache.GibImpulseLimit * 0.1;

					MovableMan:AddMO(cache);
				end
			end

			-- Set unseen
			if self:GetFogOfWarEnabled() then
				SceneMan:MakeAllUnseen(Vector(CF.FogOfWarResolution, CF.FogOfWarResolution), CF.CPUTeam);
				SceneMan:MakeAllUnseen(Vector(CF.FogOfWarResolution, CF.FogOfWarResolution), CF.PlayerTeam);

				if not self.vesselData["initialized"] then
					-- Reveal outside areas for everyone.
					for x = 0, SceneMan.SceneWidth - 1, CF.FogOfWarResolution do
						local altitude = Vector(0, 0);
						SceneMan:CastTerrainPenetrationRay(Vector(x, 0), Vector(0, SceneMan.Scene.Height), altitude, 50, 0);

						if altitude.Y > 1 then
							SceneMan:RevealUnseenBox(x - 10, 0, CF.FogOfWarResolution + 20, altitude.Y + 10, CF.CPUTeam);
							SceneMan:RevealUnseenBox(x - 10, 0, CF.FogOfWarResolution + 20, altitude.Y + 10, CF.PlayerTeam);

							-- ambient crabs
							if false and math.random(1, 1000) <= 4 then
								local onScreen = false;
								local platonicCrab = ToACrab(PresetMan:GetPreset("ACrab", "Crab", "Base.rte"));
								local platonicMegaCrab = ToACrab(PresetMan:GetPreset("ACrab", "Mega Crab", "Base.rte"));
								platonicCrab = math.random(1, 100) >= 100 and platonicMegaCrab or platonicCrab;

								for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
									onScreen = FrameMan.PlayerScreenWidth / 2 >= platonicCrab.Radius + SceneMan:ShortestDistance(Vector(x, 0), Vector(CameraMan:GetOffset(player).X + FrameMan.PlayerScreenWidth / 2, 0), true).Magnitude;
									
									if onScreen then
										break;
									end
								end
							
								if not onScreen then
									local crab = platonicCrab:Clone();

									if crab then
										crab.Pos = altitude + Vector(0, -128);
										MovableMan:AddActor(crab);
									end
								end
							end
						end
					end
				end

				for actor in MovableMan.AddedActors do
					if not IsADoor(actor) and actor.CanRevealUnseen then
						for angle = 0, math.pi * 2, 0.05 do
							SceneMan:CastSeeRay(actor.Team, actor.EyePos, Vector(150 + FrameMan.PlayerScreenWidth * 0.5, 0):RadRotate(angle), Vector(), 25, CF.FogOfWarResolution);
						end
					end
				end
			end

			-- Set unseen for AI (maybe some day it will matter ))))
			for team = Activity.TEAM_2, Activity.MAXTEAMCOUNT - 1 do
				SceneMan:MakeAllUnseen(Vector(CF.FogOfWarResolution, CF.FogOfWarResolution), team);
			end
		end
	end

	self.playerBrains = {};

	self:LocatePlayerBrains(isNewGame, true);

	if self.GS["Mode"] == "Vessel" then
		-- Create any necessary brains
		self.createdBrainCases = {};

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if self:PlayerActive(player) and self:PlayerHuman(player) and not self.playersWithBrains[player + 1] then
				local actor = CreateActor("Brain Case", "Base.rte");

				if actor then
					actor.Team = CF.PlayerTeam;
					actor.Pos = self.BrainPos[player + 1];
					actor:SetNumberValue("VW_BrainOfPlayer", player + 1);
					MovableMan:AddActor(actor);
					self:SetPlayerBrain(actor, player);
					self:SwitchToActor(actor, player, CF.PlayerTeam);
					self.createdBrainCases[player] = actor;
				end
			end
		end
	end

	-- Load encounter data if non-empty
	if not isNewGame then
		self.encounterData = self.saveLoadHandler:ReadSavedStringAsTable("encounterData");

		if self.encounterData["initialized"] then
			dofile(self.encounterData["scriptPath"]);
		end
	end

	if not isNewGame then
		local previouslyControlledActors = self.saveLoadHandler:ReadSavedStringAsTable("controlledActors");

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local actor = previouslyControlledActors[player + 1];

			if type(actor) == "userdata" and IsActor(actor) then
				self:SwitchToActor(actor, player, CF.PlayerTeam);
			end
		end
	end

	-- Icon display data
	self.Icon = CreateMOSRotating("Icon_Generic", self.ModuleName);
	self.IconFrame = {};
	self.IconFrame[1] = { comboOf = { 4, 5, 6 }, findByGroup = { "Tools - Breaching", "Tools - Diggers" } };
	self.IconFrame[2] = { comboOf = { 3, 7, 8 }, findByGroup = { "Weapons - Sniper", "Weapons - Explosive" } };
	self.IconFrame[3] = { comboOf = { 4, 8, 9 }, findByGroup = { "Weapons - Sniper" }, findByName = {
		"Scanner",
		"Disarmer",
	} };
	self.IconFrame[4] =
		{ comboOf = { 6, 9 }, findByGroup = { "Tools - Diggers" }, findByName = {
			"Scanner",
			"Disarmer",
		} };
	-- Normal icons
	self.IconFrame[5] =
		{ findByName = { "Remote Explosive", "Timed Explosive" }, findByGroup = {
			"Tools - Breaching",
		} };
	self.IconFrame[6] = { findByGroup = { "Tools - Diggers" } };
	self.IconFrame[7] = { findByGroup = { "Weapons - Explosive" } };
	self.IconFrame[8] = { findByGroup = { "Weapons - Sniper" } };
	self.IconFrame[9] = { findByName = { "Scanner", "Disarmer" } };
	self.IconFrame[10] = { findByName = { "Medikit", "Medical Dart Gun", "First Aid Kit", "Medical Healer Mk3" } }; --findByGroup = {"Tools - Healing"}
	--self.IconFrame[11] = {findByName = {"Grapple Gun", "Warp Grenade", "Dov Translocator", "Feather"}}

	self.xpSound = CreateSoundContainer("Geiger Click", "Base.rte");
	self.levelUpSound = CreateSoundContainer("Confirm", "Base.rte");
	-- Typing
	self.namingActor = nil;
	self.namingPlayer = nil;
	self.keyString = {
		[9] = "\n",
		[32] = " ",
		[33] = "!",
		[34] = '"',
		[35] = "#",
		[36] = "$",
		[37] = "%",
		[38] = "&",
		[39] = "'",
		[40] = "(",
		[41] = ")",
		[42] = "*",
		[43] = "+",
		[44] = ",",
		[45] = "-",
		[46] = ".",
		[47] = "/",
		[48] = "0",
		[49] = "1",
		[50] = "2",
		[51] = "3",
		[52] = "4",
		[53] = "5",
		[54] = "6",
		[55] = "7",
		[56] = "8",
		[57] = "9",
		[58] = ":",
		[59] = "",
		[60] = "<",
		[61] = "=",
		[62] = ">",
		[63] = "?",
		[64] = "@",
		[91] = "[",
		[92] = "\\",
		[93] = "]",
		[94] = "^",
		[95] = "_",
		[96] = "`",
		[97] = "a",
		[98] = "b",
		[99] = "c",
		[100] = "d",
		[101] = "e",
		[102] = "f",
		[103] = "g",
		[104] = "h",
		[105] = "i",
		[106] = "j",
		[107] = "k",
		[108] = "l",
		[109] = "m",
		[110] = "n",
		[111] = "o",
		[112] = "p",
		[113] = "q",
		[114] = "r",
		[115] = "s",
		[116] = "t",
		[117] = "u",
		[118] = "v",
		[119] = "w",
		[120] = "x",
		[121] = "y",
		[122] = "z",
	};
	self.nameString = {};
	self.actorList = {};
	self.killClaimRange = 50 + (FrameMan.PlayerScreenWidth + FrameMan.PlayerScreenHeight) * 0.3;

	if not isNewGame then
		local currentMusicType = tonumber(self.GS["CurrentMusicType"]);

		if currentMusicType then
			self:StartMusic(self.GS["CurrentMusicType"]);
		end
	end

	if not isNewGame then
		for actor in MovableMan.AddedActors do
			-- Game forgets many important things, have to reaffirm
			CF.SetBrain(actor, CF.IsBrain(actor));
			CF.SetAlly(actor, CF.IsAlly(actor));
		end
	end
end
-----------------------------------------------------------------------
-- Update Scene Process
-----------------------------------------------------------------------
function VoidWanderers:UpdateSceneProcess()
	self:ClearObjectivePoints();

	CF.ChangePlayerGold(self.GS, 0);
	
	for i = 1, #self.actorList do
		local hit = self.actorList[i];
		
		if hit and not MovableMan:IsActor(hit.Victim) then
			local killerCandidates = {};
			local killerDistances = {};

			for actor in MovableMan.Actors do
				if actor.Team == CF.PlayerTeam and (IsAHuman(actor) or IsACrab(actor)) and not CF.IsAlly(actor) then
					local dist = SceneMan:ShortestDistance(actor.ViewPoint, hit.ViewPoint, true);

					if dist:MagnitudeIsLessThan(self.killClaimRange) then
						local obstructionTotal = 0;

						if dist:MagnitudeIsGreaterThan(actor.Radius) then
							local checkPos = { actor.ViewPoint + dist * 0.2, hit.ViewPoint - dist * 0.2 };

							for i = 1, #checkPos do
								local materialStruck = SceneMan:GetMaterialFromID(SceneMan:GetTerrMatter(checkPos[i].X, checkPos[i].Y));
								obstructionTotal = obstructionTotal + math.floor(materialStruck.StructuralIntegrity ^ 0.5);
							end
						end

						table.insert(killerCandidates, actor);
						table.insert(killerDistances, dist.Magnitude + obstructionTotal);
					end
				end
			end

			for i, killer in ipairs(killerCandidates) do
				local distanceProportion = killerDistances[i] / self.killClaimRange;
				local healthProportion = killer.Health / killer.MaxHealth;
				local riskFactor = 3 - math.min(healthProportion + distanceProportion, 2);
				local powerDampingFactor = 10 + math.abs(killer:GetGoldValue(0, 0.2, 0.2));
				local sharedGain = math.ceil(hit.Value / #killerCandidates / powerDampingFactor * riskFactor);
				
				if sharedGain > 0 then
					if killer:GetNumberValue("VW_BrainOfPlayer") - 1 > Activity.PLAYER_NONE then
						local levelUp = CF.AwardBrainExperience(self.GS, sharedGain, killer:GetNumberValue("VW_BrainOfPlayer") - 1);
						local effect = CF.CreateTextEffect("+" .. sharedGain .. " exp" .. (levelUp and "\nLEVEL UP!" or ""));

						if effect then
							effect.Pos = killer.AboveHUDPos + Vector(math.random(-5, 5), -math.random(5));
							MovableMan:AddParticle(effect);
						end
					else
						self:GiveXP(killer, sharedGain);
					end
				end
			end
		end

		self.actorList[i] = nil;
	end
	
	for actor in MovableMan.Actors do
		local actorTeam = actor.Team;
		local isFriendly = actorTeam == CF.PlayerTeam;

		if not isFriendly then
			if actor.Pos.Y > 0 then
				local fragValue = 0;
				
				if not actor:NumberValueExists("VW_FragValue") then
					local rank = actor:GetNumberValue("VW_Rank");
					local prestige = actor:GetNumberValue("VW_Prestige");
					fragValue = math.abs(actor:GetGoldValue(0, 1, 1)) * (1 + rank / #CF.Ranks) * math.sqrt(1 + prestige) / 2;

					actor:SetNumberValue("VW_FragValue", fragValue);
				else
					fragValue = actor:GetNumberValue("VW_FragValue");
				end

				self.actorList[#self.actorList + 1] = {
					Victim = actor,
					Team = actorTeam,
					Value = fragValue,
					ViewPoint = actor.ViewPoint,
				};
			end
		elseif
			actor:IsPlayerControlled()
			and CF.IsCommander(actor)
			and actor:GetController():IsState(Controller.PRESS_PRIMARY)
			and IsAHuman(actor)
			and ToAHuman(actor).EquippedItem
			and not ToAHuman(actor).EquippedItem.ToDelete
			and ToAHuman(actor).EquippedItem.ModuleName == CF.ModuleName
		then
			human = ToAHuman(actor);
			
			local object = human.EquippedItem;
			local kind = object.PresetName;
			local delete = false;

			if kind == "Blueprint" or kind == "Blackprint" then
				local print = object;
				local text = print:GetStringValue("VW_Text");
				local class = print:GetStringValue("VW_ClassUnlock");
				local preset = print:GetStringValue("VW_PresetUnlock");
				local module = print:GetStringValue("VW_ModuleUnlock");
				local alreadyUnlocked = CF.IsEntityUnlocked(self.GS, kind, class, preset, module);

				if text == "" or alreadyUnlocked then
					text = "Nothing of value was found." .. (alreadyUnlocked and ("\\n" .. preset .. " already unlocked.") or "");
				else
					self.GS["Unlocked" .. kind .. "_" .. class .. "_" .. preset .. "_" .. module] = 1;
					human:FlashWhite(50);
				end

				local effect = CF.CreateTextEffect(text);
				effect.Pos = actor.AboveHUDPos + Vector(0, -8);
				MovableMan:AddParticle(effect);
			end

			if delete then
				object.ToDelete = true;
			end
		end

		local isVisible = not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam);
		actor.HUDVisible = ToActor(PresetMan:GetPreset(actor.ClassName, actor.PresetName, actor.ModuleName)).HUDVisible and isVisible;

		-- Display icons
		if CF.EnableIcons then
			if
				actor.HUDVisible
				and (isFriendly or SettingsMan.ShowEnemyHUD)
				and isVisible
			then
				local cont = actor:GetController();
				local pieMenuOpen = cont:IsState(Controller.PIE_MENU_ACTIVE);
				local prestige = actor:GetNumberValue("VW_Prestige");
				local rank = actor:GetNumberValue("VW_Rank");
				local name = actor:GetStringValue("VW_Name");
				local velOffset = actor.Vel * rte.PxTravelledPerFrame;
				local offsetY = (actor:IsPlayerControlled() and actor.ItemInReach) and -8 or -1;
				local nameToDisplay = (name and name ~= "") or (self.namingActor and self.namingActor.ID == actor.ID);
				local rankToDisplay = not CF.IsBrain(actor) and (actor.Team == CF.PlayerTeam or rank > 0 or prestige > 0);

				if (not nameToDisplay) and isFriendly then
					local icons = {}
					if CF.IsAlly(actor) then
						if not pieMenuOpen then
							self:DrawIcon(0, actor.Pos + velOffset + Vector(-8, -math.ceil(actor.Height * 0.5) + 8))
						end
					else
						local skip = {}
						for i = 1, #self.IconFrame do
							local skipThis = false
							for s = 1, #skip do
								if skip[s] == i then
									skipThis = true
									break
								end
							end
							if skipThis == false then
								if self.IconFrame[i].comboOf then
									while true do
										local iconFound = true
										if self.IconFrame[i].findByGroup then
											for _, group in pairs(self.IconFrame[i].findByGroup) do
												if not actor:HasObjectInGroup(group) then
													iconFound = false
												end
											end
											if iconFound == false then
												break
											end
										end
										if self.IconFrame[i].findByName then
											for _, name in pairs(self.IconFrame[i].findByName) do
												if actor:HasObject(name) then
													iconFound = true
													break
												else
													iconFound = false
												end
											end
										end
										if iconFound then
											icons[#icons + 1] = i
											for _, omit in pairs(self.IconFrame[i].comboOf) do
												table.insert(skip, omit)
											end
										end
										break
									end
								elseif self.IconFrame[i].findByGroup then
									for _, group in pairs(self.IconFrame[i].findByGroup) do
										if actor:HasObjectInGroup(group) then
											icons[#icons + 1] = i
											break
										end
									end
								elseif self.IconFrame[i].findByName then
									for _, name in pairs(self.IconFrame[i].findByName) do
										if actor:HasObject(name) then
											icons[#icons + 1] = i
											break
										end
									end
								end
							end
						end
						if #icons > 0 then
							if #icons > 3 then
								-- Only if you are very special
								self:DrawIcon(
									self.Icon.FrameCount - 1,
									actor.AboveHUDPos + velOffset + Vector(0, offsetY)
								)
							else
								local pos = actor.AboveHUDPos
									+ velOffset
									+ Vector(-(13 * #icons * 0.5) + 7, offsetY)
								for _, frame in pairs(icons) do
									self:DrawIcon(frame, pos)
									pos = pos + Vector(13, 0)
								end
							end
						end
					end
				end

				-- If not a brain, and if enemy, then at least one rank,
				if nameToDisplay or rankToDisplay then
					-- Get a reasonable position for the overhead, and the whose player it is,
					local aboveHeadPos = actor.Pos + velOffset + Vector(-20, 8 - actor.Height * 0.5);
					local actorPlayer = actor:GetController().Player;

					-- Then if we're not user controlled, all players have the same regular view,
					if actorPlayer == Activity.PLAYER_NONE then
						PrimitiveMan:DrawTextPrimitive(actorPlayer, actor.AboveHUDPos + velOffset + Vector(1, offsetY - 7), name, false, 1);

						if rankToDisplay then
							CF.DrawRankIcon(actorPlayer, aboveHeadPos, rank, prestige);
						end
					else
						-- Otherwise, display in the top left for the controlling player, and regularly otherwise.
						for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
							if actorPlayer == player then
								local camOff = CameraMan:GetOffset(player);
								local postfix = prestige > 0 and ("+" .. prestige) or "";
								local pos;

								pos = camOff + Vector(27, 24);
								PrimitiveMan:DrawTextPrimitive(player, pos, name, false, 0);

								if rankToDisplay then
									pos = camOff + Vector(27, 12) + Vector(56, 0);
									PrimitiveMan:DrawTextPrimitive(player, pos, postfix, false, 0);

									local capped = CF.Ranks[rank + 1] == nil;
									local player = player;
									local topLeft = camOff + Vector(27, 16);
									local bottomRight = camOff + Vector(28, 17) + Vector(50, 6);
									local progress = capped and 1 or (actor:GetNumberValue("VW_XP") - (CF.Ranks[rank] or 0)) / (CF.Ranks[rank + 1] - (CF.Ranks[rank] or 0));
									local palette = { 118, 71, 80 };

									CF.DrawRankIcon(player, camOff + Vector(19, 20), rank, prestige);
									CF.DrawProgressBar(player, topLeft.X, topLeft.Y, bottomRight.X, bottomRight.Y, progress, palette);
								end
							else
								PrimitiveMan:DrawTextPrimitive(player, actor.AboveHUDPos + velOffset + Vector(1, offsetY - 7), name, false, 1);

								if rankToDisplay then
									CF.DrawRankIcon(player, aboveHeadPos, rank, prestige);
								end
							end
						end
					end
				end
			end
		end

		self:LevelUp(actor);

		-- Enable prestige where needed
		local actorMaxxed = actor:GetNumberValue("VW_Rank") >= #CF.Ranks;
		local pie = actor.PieMenu:GetFirstPieSliceByPresetName(CF.PrestigeSlice.PresetName);

		if actorMaxxed and not pie then
			pie = CF.PrestigeSlice:Clone();

			if not actor.PieMenu:AddPieSliceIfPresetNameIsUnique(pie, self) then
				pie = nil;
			end
		end

		if pie then
			pie.Enabled = actorMaxxed;
			
			if not actorMaxxed then
				actor.PieMenu:RemovePieSlice(pie);
			end
		end

		-- Process prestige request
		if actorMaxxed and actor:NumberValueExists("VW_AttemptPrestige") then
			actor:RemoveNumberValue("VW_AttemptPrestige");
			actor:RemoveWounds(actor.WoundCount);
			actor.Health = actor.MaxHealth;

			local prestige = actor:GetNumberValue("VW_Prestige");
			local oldRank = actor:GetNumberValue("VW_Rank");
			CF.BuffActor(actor, 1 / (1 + (oldRank + math.sqrt(prestige)) * 0.1 * math.sqrt(prestige * 0.1 + 1)));

			local prestige = prestige + 1;
			actor:SetNumberValue("VW_XP", 0);
			actor:SetNumberValue("VW_Rank", 0);
			actor:SetNumberValue("VW_Prestige", prestige);
			CF.BuffActor(actor, 1 + math.sqrt(prestige) * 0.1 * math.sqrt(prestige * 0.1 + 1));

			local cont = actor:GetController();

			if cont:IsMouseControlled() or cont:IsKeyboardOnlyControlled() then
				self.namingActor = actor
				self.namingPlayer = cont.Player;
			end
		end
	end

	tracy.ZoneBeginN("Encounter");
	if self.encounterData["initialized"] then
		if self.EncounterUpdate ~= nil then
			self:EncounterUpdate();
		end

		if self.encounterData["encounterConcluded"] == true then
			self.encounterData = {};
			self.EncounterUpdate = nil;
			self.EncounterCreate = nil;
		end
	end
	tracy.ZoneEnd();

	tracy.ZoneBeginN("Ambience");
	if self.ambientData["initialized"] then
		if self.AmbientUpdate ~= nil then
			self:AmbientUpdate();
		end
	end
	tracy.ZoneEnd();

	if self.missionData["initialized"] then
		self:ProcessLZControlPanelUI();

		tracy.ZoneBeginN("Mission");
		if self.MissionUpdate ~= nil then
			self:MissionUpdate();
		end
		tracy.ZoneEnd();
	end

	-- Make actors glitch if there are too many of them
	tracy.ZoneBeginN("Connection Glitches");
	if self.GS["Mode"] ~= "Vessel" then
		local count = 0;
		local brainCount = 0;

		for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
			if actor.Team == CF.PlayerTeam and not CF.IsAlly(actor) then
				if actor:GetNumberValue("VW_BrainOfPlayer") ~= 0 then
					brainCount = brainCount + 1;
				end

				if CF.IsCommonUnit(actor) then
					count = count + 1;

					if self.GS["BrainsOnMission"] ~= "True" and actor:GetNumberValue("VW_Prestige") == 0 and count > tonumber(self.GS["PlayerVesselCommunication"]) and tonumber(self.GS["Time"]) % 4 == 0 then
						local cont = actor:GetController();

						if cont:IsState(Controller.BODY_JUMP) then
							cont:SetState(Controller.BODY_JUMP, false);
							cont:SetState(Controller.BODY_JUMPSTART, false);
							cont:SetState(Controller.BODY_CROUCH, true);
						elseif cont:IsState(Controller.BODY_CROUCH) then
							cont:SetState(Controller.BODY_JUMP, true);
							cont:SetState(Controller.BODY_CROUCH, false);
						end

						if cont:IsState(Controller.MOVE_LEFT) then
							cont:SetState(Controller.MOVE_LEFT, false)
							cont:SetState(Controller.MOVE_RIGHT, true);
						elseif cont:IsState(Controller.MOVE_RIGHT) then
							cont:SetState(Controller.MOVE_RIGHT, false);
							cont:SetState(Controller.MOVE_LEFT, true);
						end

						if cont:IsState(Controller.WEAPON_PICKUP) then
							cont:SetState(Controller.WEAPON_PICKUP, false);
							cont:SetState(Controller.WEAPON_DROP, true);
						elseif cont:IsState(Controller.WEAPON_DROP) then
							cont:SetState(Controller.WEAPON_DROP, false);
							cont:SetState(Controller.WEAPON_PICKUP, true);
						end

						self:AddObjectivePoint("CONNECTION LOST", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWUP);
					end
				end
			end
		end end

		if self.ActivityState ~= Activity.OVER then
			if self.GS["BrainsOnMission"] == "True" then
				if brainCount < self.PlayerCount then
					self.WinnerTeam = CF.CPUTeam;
					ActivityMan:EndActivity();
					self:StartMusic(CF.MusicTypes.DEFEAT);
				end
			end
		end
	end
	tracy.ZoneEnd();

	-- Clear the banner if there are brains
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT do
		if self:GetPlayerBrain(player) then
			self:GetBanner(GUIBanner.RED, player):ClearText()
		end
	end
	
	-- Generate artificial gravity inside the ship
	if self.vesselData["initialized"] then
		if self.vesselData["team"] == 0 then
			self:ProcessBrainControlPanelUI();

			if self.vesselData["bridgeEnabled"] then
				if not self.ShipControlPanelActor then
					self:InitShipControlPanelUI();
				end

				self:ProcessShipControlPanelUI();
			else
				if self.ShipControlPanelActor then
					self:DestroyShipControlPanelUI();
				end
			end

			if self.vesselData["itemStorageEnabled"] then
				if not self.StorageControlPanelActor then
					self:InitStorageControlPanelUI();
				end

				self:ProcessStorageControlPanelUI();
			else
				if self.StorageControlPanelActor then
					self:DestroyStorageControlPanelUI();
				end
			end

			if self.vesselData["cloneStorageEnabled"] then
				if not self.ClonesControlPanelActor then
					self:InitClonesControlPanelUI();
				end

				self:ProcessClonesControlPanelUI();
			else
				if self.ClonesControlPanelActor then
					self:DestroyClonesControlPanelUI();
				end
			end

			if self.vesselData["beamEnabled"] then
				if not self.BeamControlPanelActor then
					self:InitBeamControlPanelUI();
				end

				self:ProcessBeamControlPanelUI();
			else
				if self.BeamControlPanelActor then
					self:DestroyBeamControlPanelUI();
				end
			end
		end

		local isTradeStar = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR);
		local isBlackMarket = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET);
		local isShopLocation = isTradeStar or isBlackMarket;

		if isShopLocation then
			if not self.CloneShopControlPanelActor then
				self:InitItemShopControlPanelUI();
				self:InitCloneShopControlPanelUI();
				self:StartMusic(CF.MusicTypes.COMMERCE);
			end

			self:ProcessItemShopControlPanelUI();
			self:ProcessCloneShopControlPanelUI();
		else
			if self.CloneShopControlPanelActor then
				self:DestroyItemShopControlPanelUI();
				self:DestroyCloneShopControlPanelUI();
				self:StartMusic(CF.MusicTypes.SHIP_CALM);
			end
		end

		local flightSpeed = tonumber(self.GS["PlayerVesselSpeed"])
		local engineBurst = false
		local engineBoost = 0
		local isUserVessel = self.vesselData["team"] == 0;

		-- Fly to new location
		if isUserVessel and self.GS["Destination"] ~= nil and not self.vesselData["flightDisabled"] then
			local dx = tonumber(self.GS["DestX"])
			local dy = tonumber(self.GS["DestY"])

			local sx = tonumber(self.GS["ShipX"])
			local sy = tonumber(self.GS["ShipY"])

			local i = CF.Dist(Vector(sx, sy), Vector(dx, dy))
			self.GS["Distance"] = i

			if i <= 0.5 then
				self.GS["Location"] = self.GS["Destination"]
				self.GS["Destination"] = nil

				local locpos = CF.LocationPos[self.GS["Location"]] or Vector()

				self.GS["ShipX"] = locpos.X
				self.GS["ShipY"] = locpos.Y
			else
				engineBurst = true;
				engineBoost = flightSpeed;

				if not self.vesselData["flightAimless"] then
					if not self.encounterData["initiated"] then
						self:AttemptRandomEncounter();
					end

					self.GS["ShipX"] = sx + (dx - sx) / i * (flightSpeed / CF.KmPerPixel);
					self.GS["ShipY"] = sy + (dy - sy) / i * (flightSpeed / CF.KmPerPixel);
				end
			end
		end

		-- Enable emitters
		for i, engine in ipairs(self.vesselData["engines"]) do
			if engine and IsAEmitter(engine) then
				engine = ToAEmitter(engine)
				engine:EnableEmission(engineBurst)
				engine.Throttle = self.vesselData["throttle"]
			end
		end

		local acceleration = 0.1
		local targetVel = -math.ceil(engineBoost/5) + 0.2
		for background in SceneMan.Scene.BackgroundLayers do
			local scroll = background.AutoScrollStepX * (isUserVessel and 1 or 0)
			background.AutoScrollStepX = scroll + math.min(acceleration, math.max(-acceleration, targetVel - scroll))
		end

		-- Auto heal all actors when not in combat or random encounter
		local overCrowd = CF.CountActors(CF.PlayerTeam) - tonumber(self.GS["PlayerVesselLifeSupport"]);

		if isUserVessel and overCrowd > 0 then
			local text = "LIFE SUPPORT OVERLOADED\nSTORE OR DUMP " .. overCrowd .. (overCrowd == 1 and " BODY" or " BODIES");

			FrameMan:ClearScreenText(0);
			FrameMan:SetScreenText(text, 0, 0, 1000, true);

			self:MakeAlertSound(0.25);
		end

		for actor in MovableMan.Actors do
			local sentient = actor.ClassName == "AHuman" or actor.ClassName == "ACrab";
			
			if sentient then
				local ourTeam = actor.Team == self.vesselData["team"];
				local spaceWalking = not self.vesselData["ship"]:IsInside(actor.Pos) and not self.vesselData["spaceDeck"]:IsInside(actor.Pos);

				if (isUserVessel and overCrowd > 0) or spaceWalking then
					actor.Health = actor.Health - 1 / math.sqrt(1 + math.abs(actor.Mass + actor.Material.StructuralIntegrity));

					if spaceWalking and ourTeam and isUserVessel then
						if not self.flyPhase then
							self.flyPhase = {};
						end

						self.flyPhase[#self.flyPhase] = { actor };
					end
				else
					if actor.Health > 0 and actor.Health < actor.MaxHealth and ourTeam and isUserVessel and self.vesselData["lifeSupportEnabled"] then
						actor.Health = math.min(actor.Health + 0.1, actor.MaxHealth);
					end
				end
			end
		end

		local coll = { MovableMan.Actors, MovableMan.Items }
		for i = 1, #coll do
			for mo in coll[i] do
				if mo.PinStrength == 0 then
					local inShip = self.vesselData["ship"]:IsInside(mo.Pos);
					local onDeck = self.vesselData["spaceDeck"]:IsInside(mo.Pos);
					local artGrav = self.vesselData["artificialGravity"] * mo.GlobalAccScalar;

					if artGrav then
						if inShip then
							mo.Vel = mo.Vel + artGrav
						elseif onDeck then
							mo.Vel = mo.Vel + artGrav / 2
						end
					end

					if engineBoost > 0 then
						--[[if not artGrav then
							mo.Vel = mo.Vel + Vector(engineBoost / 400, 0)
						else
							if not inShip then
								if onDeck then
									mo.Vel = mo.Vel + Vector(engineBoost / 800, 0)
								else
									mo.Vel = mo.Vel + Vector(engineBoost / 400, 0)
								end
							end
						end
						for _, engine in pairs(self.vesselData["engines"]) do
							if mo.Pos.X - engine.Pos.X + 48 - 4 * math.abs(mo.Pos.Y - engine.Pos.Y) > 0 then
								mo.AngularVel = mo.AngularVel * 0.9 + math.random(-0.5, 0.5) * engineBoost / 10
							end
						end--]]
						if false and IsAHuman(mo) then
							local actor = ToAHuman(mo)
							local stillness = 1 / (1 + (actor.Vel.Magnitude + math.abs(actor.AngularVel) * 0.1) * 0.1)
							if actor.Team ~= CF.PlayerTeam then
								if actor.Status == Actor.STABLE then
									actor.Vel = actor.Vel + Vector(0, 0.1 * stillness)
								end
							elseif actor.Status < Actor.INACTIVE and actor.Radius < 1000 and actor.Mass > 0 then
								local controller = actor:GetController()
								local aimAngle = actor:GetAimAngle(false)
								local playerControlled = actor:IsPlayerControlled()
								actor.Status = Actor.UNSTABLE

								local targetAngle = 0
								local moveSpeed = 0.001

								if playerControlled then
									if actor.FGArm then
										local moID = SceneMan:CastMORay(
											actor.FGArm.Pos,
											Vector(
												(1 + actor.IndividualRadius * 0.5 + actor.FGArm.MaxLength)
													* actor.FlipFactor
													* math.random(),
												0
											):RadRotate(aimAngle + RangeRand(-0.5, 0.5)),
											actor.ID,
											Activity.NOTEAM,
											rte.grassID,
											true,
											3
										)
										if moID == rte.NoMOID then
											moID = actor.HitWhatMOID
										end
										if moID ~= rte.NoMOID then
											local item = MovableMan:GetMOFromID(moID)
											if item and IsMOSRotating(item) then
												item = ToMOSRotating(item):GetRootParent()
												if IsHeldDevice(item) then
													actor.ItemInReach = ToHeldDevice(item)
												end
											end
										end
									end
									local limbs = { actor.FGArm, actor.BGArm, actor.FGFoot, actor.BGFoot }
									for _, limb in pairs(limbs) do
										if limb then
											local checkPos = limb.HandPos or limb.Pos
											if checkPos then
												checkPos = checkPos
													+ Vector(0, 1)
													+ SceneMan
														:ShortestDistance(actor.Pos, checkPos, true)
														:SetMagnitude(1)
												local terrCheck = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
												if terrCheck ~= rte.airID then
													moveSpeed = math.min(
														SceneMan:GetMaterialFromID(terrCheck).Friction * 0.1,
														1
													)
													break
												end
											end
										end
									end
									moveSpeed = moveSpeed * stillness

									if actor.Status == Actor.UNSTABLE then
										targetAngle = math.pi * 0.5 -- + (actor.Jetpack and (actor.Jetpack.EmitAngle - math.pi * 1.5) or 0)
									end
									--actor.Status = math.abs(aimAngle) > 1 and Actor.UNSTABLE or actor.Status

									if controller:IsState(Controller.BODY_JUMP) then
										--controller:SetState(Controller.BODY_JUMP, false)
										actor.Vel = actor.Vel
											+ Vector(0, -moveSpeed * 0.5)
											+ Vector(moveSpeed * 0.5, 0):RadRotate(actor:GetAimAngle(true))
									elseif controller:IsState(Controller.BODY_CROUCH) then
										--controller:SetState(Controller.BODY_CROUCH, false)
										actor.Vel = actor.Vel
											+ Vector(0, moveSpeed * 0.5)
											- Vector(moveSpeed * 0.5, 0):RadRotate(actor:GetAimAngle(true))
									elseif
										controller:IsState(Controller.AIM_UP) or controller:IsState(Controller.AIM_DOWN)
									then
										actor.Vel = actor.Vel + Vector(0, -moveSpeed * math.sin(aimAngle))
									else
										if controller:IsState(Controller.MOVE_RIGHT) then
											actor.Vel = actor.Vel
												+ Vector(moveSpeed * 0.5, 0)
												+ Vector(moveSpeed * 0.5, 0):RadRotate(actor:GetAimAngle(true))
										end
										if controller:IsState(Controller.MOVE_LEFT) then
											actor.Vel = actor.Vel
												+ Vector(-moveSpeed * 0.5, 0)
												+ Vector(moveSpeed * 0.5, 0):RadRotate(actor:GetAimAngle(true))
										end
									end
								end
								--actor.Status = stillness < 0.66 and Actor.UNSTABLE or actor.Status
								actor.AngularVel = actor.AngularVel * (1 - stillness)
									- (actor.RotAngle - (aimAngle - targetAngle) * actor.FlipFactor)
										/ (1 + actor.TravelImpulse.Magnitude / actor.Mass)
										* 4
										* stillness
							end
						end
					end
				end
			end
		end
	end

	if self.flyPhase then
		for i, phase in ipairs(self.flyPhase) do
			if IsActor(phase[1]) then
				local dir = Vector(
					phase[1].Pos.X - SceneMan.SceneWidth * 0.5,
					phase[1].Pos.Y - SceneMan.SceneHeight * 0.5
				)
				if self.vesselData["ship"]:IsInside(phase[1].Pos) then
					if #phase == 5 and dir.X * phase[2] > 0 then
						if phase[1]:NumberValueExists("VW_Rank") then
							phase[1].GoldCarried = phase[1].GoldCarried + math.floor(phase[1].Health)
						else
							self:GiveXP(phase[1], CF.Ranks[1])
						end
						phase = nil
					else
						phase = nil
					end
				elseif #phase < 5 then
					if #phase == 4 then
						if dir.X * phase[2] > 0 and dir.Y * phase[3] < 0 then
							phase[#phase + 1] = true
						end
					elseif #phase > 1 then
						if dir.X * phase[2] < 0 then
							if #phase == 2 then
								phase[#phase + 1] = dir.Y > 0 and 1 or -1
							elseif dir.Y * phase[3] < 0 then
								phase[#phase + 1] = dir.Y > 0 and 1 or -1
							end
						end
					else
						phase[#phase + 1] = dir.X > 0 and 1 or -1
					end
				end
			else
				self.flyPhase[i] = nil
			end
		end
	end

	-- Tick timer
	if self.TickTimer:IsPastRealMS(self.TickInterval) then
		self.GS["Time"] = tostring(tonumber(self.GS["Time"]) + 1);
		self.TickTimer:Reset();

		-- Give passive experience points for non-brain actors
		for actor in MovableMan.Actors do
			if CF.IsCommonUnit(actor) and actor.Team == CF.PlayerTeam then
				local damage = (actor.PrevHealth - actor.Health) / actor.MaxHealth
				local gains = damage * math.sqrt(25 + (actor.Vel + actor.PrevVel).Magnitude)

				if gains >= 1 then
					self:GiveXP(actor, gains);
				end
			end
		end
	end
	
	-- Remove pre-eqipped items from inventories
	if #self.ItemRemoveQueue > 0 then
		for i = 1, #self.ItemRemoveQueue do
			if MovableMan:IsActor(self.ItemRemoveQueue[i]["Actor"]) then
				self:RemoveInventoryItem(self.ItemRemoveQueue[i]["Actor"], self.ItemRemoveQueue[i]["Preset"], 1)
				table.remove(self.ItemRemoveQueue, i)
				--print ("Removed")
				break
			else
				table.remove(self.ItemRemoveQueue, i)
				break
			end
		end
	end --]]
	
	local namingActor = self.namingActor;
	local namingPlayer = self.namingPlayer;
	if namingActor and MovableMan:IsActor(namingActor) and namingPlayer then
		local screen = self:ScreenOfPlayer(namingPlayer);
		CameraMan:SetScrollTarget(
			namingActor.AboveHUDPos + namingActor.Vel * rte.PxTravelledPerFrame + Vector(1, 22),
			1,
			screen
		);
		local controlledActor = self:GetControlledActor(namingPlayer);
		local controller = controlledActor:GetController();

		for i = 0, Controller.CONTROLSTATECOUNT - 1 do -- Go through and disable the gameplay-related controller states
			controller:SetState(i, false);
		end

		if controlledActor.UniqueID ~= namingActor.UniqueID then
			self:SwitchToActor(namingActor, controller.Player, controlledActor.Team);
		else
			if UInputMan:AnyPress() then
				for i = 1, #self.keyString do
					if (i == Key.DELETE) and UInputMan:KeyPressed(i) then
						self.nameString = {};
					elseif (i == Key.BACKSPACE) and UInputMan:KeyPressed(i) then
						self.nameString[#self.nameString] = nil;
					elseif (i == Key.RETURN) and UInputMan:KeyPressed(i) then
						if
							self.nameString == nil
							or #self.nameString == 0
							or self.nameString[#self.nameString] == ""
						then
							namingActor:RemoveStringValue("VW_Name");
						else
							namingActor:SetStringValue("VW_Name", self.nameString[#self.nameString]);
						end

						namingActor:FlashWhite(100);
						self.namingActor = nil;
						self.nameString = {};
					elseif self.keyString[i] and UInputMan:KeyPressed(i) then
						self.nameString[#self.nameString + 1] = (self.nameString[#self.nameString] or "")
							.. (UInputMan.FlagShiftState and string.upper(self.keyString[i]) or self.keyString[i]);
					end
				end
			end
		end

		local nameString = #self.nameString ~= 0 and self.nameString[#self.nameString] or "";
		FrameMan:SetScreenText("> NAME YOUR UNIT <\n" .. nameString, screen, 0, 1, true);
	else
		self.nameString = {};
	end

	self:YSortObjectivePoints();

	tracy.ZoneBeginN("Per set set up");
	for _, set in pairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if _ == 1 and actor:NumberValueExists("VW_Passable") then 
			actor.IgnoresActorHits = actor:GetNumberValue("VW_Passable") == 1;
			actor:RemoveNumberValue("VW_Passable");

			-- Had this fun idea that if you revive an actor, you may conscript them for a hefty fee
			-- However, this goes poorly if your team is not the one to revive them, as they start shooting their own
			--[[if false and actor.Team > Activity.TEAM_1 then
				actor.Team = Activity.TEAM_1;
				actor:SetNumberValue("VW_ConscriptPrice", math.ceil(actor:GetTotalValue(0, 1, 1) * (8 + 2 * math.random())));
				CF.SetAlly(actor, true);
			end]]
		end

		-- No dead unit settles immediately and all can carry others, though most can't use it
		if IsAHuman(actor) or IsACrab(actor) then
			actor.RestThreshold = -1;

			if IsAHuman(actor) then
				if actor:HasScript("VoidWanderers.rte/Actors/Shared/Carry.lua") then
					actor:EnableScript("VoidWanderers.rte/Actors/Shared/Carry.lua");
				else
					actor:AddScript("VoidWanderers.rte/Actors/Shared/Carry.lua");
				end
			end
		end

		-- Active units of standing have the ability to fix their wounds
		if CF.IsCommonUnit(actor) and actor.Team == CF.PlayerTeam then
			if actor:GetNumberValue("VW_Prestige") ~= 0 then
				if actor:HasScript("Base.rte/Actors/Shared/Scripts/SelfHeal.lua") then
					actor:EnableScript("Base.rte/Actors/Shared/Scripts/SelfHeal.lua")
				else
					actor:AddScript("Base.rte/Actors/Shared/Scripts/SelfHeal.lua")
				end
			end
		end
	end end

	for particle in MovableMan.Particles do
		if IsActor(particle) and not particle:NumberValueExists("VW_Passable") then
			actor = ToActor(particle);

			if actor:IsDead() then 
				actor:SetNumberValue("VW_Passable", actor.IgnoresActorHits and 1 or 0);
				actor.IgnoresActorHits = true;
			end
		end
	end

	for actor in MovableMan.AddedActors do
		-- Space out spawned-in craft
		if actor.Pos.Y <= 0 then
			local dir = 0;

			for i = 1, 10 do
				local dist = Vector();
				local otherActor = MovableMan:GetClosestActor(actor.Pos, actor.Diameter, dist, actor);

				if otherActor then
					if dir == 0 then
						dir = dist.X < 0 and 1 or -1;
					end

					actor.Pos.X = actor.Pos.X + actor.Radius * dir;
				else
					break;
				end
			end
		end
	end
	tracy.ZoneEnd();
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function VoidWanderers:CloseSceneProcess()

end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitConsoles()
	self:InitShipControlPanelUI();
	self:InitStorageControlPanelUI();
	self:InitClonesControlPanelUI();
	self:InitBeamControlPanelUI();

	self:InitTurretsControlPanelUI();
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyConsoles()
	self:DestroyShipControlPanelUI()
	self:DestroyStorageControlPanelUI()
	self:DestroyClonesControlPanelUI()
	self:DestroyBeamControlPanelUI()

	self:DestroyItemShopControlPanelUI()
	self:DestroyCloneShopControlPanelUI()

	self:DestroyTurretsControlPanelUI()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DrawIcon(preset, pos)
	if preset then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			PrimitiveMan:DrawBitmapPrimitive(self:ScreenOfPlayer(player), pos, self.Icon, 0, preset);
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GiveXP(actor, xp)
	if actor then
		xp = math.floor(xp / math.sqrt(1 + actor:GetNumberValue("VW_Prestige")) + 0.5);

		if xp > 0 then
			self.xpSound:Play(actor.Pos);
			local newXP = actor:GetNumberValue("VW_XP") + xp;
			actor:SetNumberValue("VW_XP", newXP);

			local levelUp = self:LevelUp(actor);

			if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam) then
				local effect = CF.CreateTextEffect("+" .. xp .. " xp" .. (levelUp and "\nLEVEL UP!" or ""));
				
				if
					actor:IsPlayerControlled()
					and SceneMan
						:ShortestDistance(actor.EyePos, actor.ViewPoint, true)
						:MagnitudeIsGreaterThan(
							math.min(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight) * 0.5 - 25
						)
				then
					effect.Pos = actor.ViewPoint + Vector(0, -math.random(5))
				else
					effect.Pos = actor.AboveHUDPos + Vector(math.random(-5, 5), -math.random(5))
				end

				MovableMan:AddParticle(effect);
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:LevelUp(actor)
	if actor then
		local experience = actor:GetNumberValue("VW_XP");
		local rank = actor:GetNumberValue("VW_Rank");
		local levelUp = 0;
		local nextRank = CF.Ranks[rank + 1];

		while nextRank and experience >= nextRank do
			levelUp = levelUp + 1;
			rank = rank + 1;
			nextRank = CF.Ranks[rank + 1];
		end

		if levelUp > 0 then
			if not self.levelUpSound:IsBeingPlayed() then
				self.levelUpSound:Play(actor.Pos);
			end
			
			local prestige = actor:GetNumberValue("VW_Prestige");
			local oldRank = actor:GetNumberValue("VW_Rank");
			CF.BuffActor(actor, 1 / (1 + (oldRank + math.sqrt(prestige)) * 0.1 * math.sqrt(prestige * 0.1 + 1)));
			actor:SetNumberValue("VW_Rank", rank);
			CF.BuffActor(actor, 1 + (rank + math.sqrt(prestige)) * 0.1 * math.sqrt(prestige * 0.1 + 1));
			actor:FlashWhite(50);
			actor.Health = math.min(actor.Health * 1.5, actor.MaxHealth);
			return true;
		end
	end

	return false;
end
-----------------------------------------------------------------------
-- Removes specified item from actor's inventory, returns number of removed items
-----------------------------------------------------------------------
function VoidWanderers:RemoveInventoryItem(actor, itempreset, maxcount)
	local count = 0
	local toabort = 0

	--print ("Remove "..itempreset)

	if MovableMan:IsActor(actor) and actor.ClassName == "AHuman" then
		if actor:HasObject(itempreset) then
			local human = ToAHuman(actor)

			if human.EquippedItem then
				if human.EquippedItem.PresetName == itempreset then
					human.EquippedItem.ToDelete = true
					count = 1
				end
			end

			human:UnequipBGArm()

			if not actor:IsInventoryEmpty() then
				actor:AddInventoryItem(CreateTDExplosive("VoidWanderersInventoryMarker", self.ModuleName))

				local enough = false
				while not enough do
					local weap = actor:Inventory()

					--print (weap.PresetName)

					if weap.PresetName == itempreset then
						if count < maxcount then
							weap = actor:SwapNextInventory(nil, true)
							count = count + 1
						else
							weap = actor:SwapNextInventory(weap, true)
						end
					else
						if weap.PresetName == "VoidWanderersInventoryMarker" then
							enough = true
							actor:SwapNextInventory(nil, true)
						else
							weap = actor:SwapNextInventory(weap, true)
						end
					end

					toabort = toabort + 1
					if toabort == 20 then
						enough = true
					end
				end
			end
		end
	end
	-- print (tostring(count).." items removed")
	return count
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:AttemptRandomEncounter()
	if not CF.RandomEncountersEnabled then
		return;
	end

	local potentialEncounters = {};

	for i, name in ipairs(CF.RandomEncounters) do
		local eligibilityTest = CF.RandomEncounterEligibilityTests[name];

		if eligibilityTest then
			if eligibilityTest(self) == true then
				table.insert(potentialEncounters, name);
			end
		end
	end

	-- Trigger random encounter if there are any eligible to occur
	if next(potentialEncounters) and math.random() < CF.RandomEncounterProbability then
		local encounter = potentialEncounters[math.random(#potentialEncounters)];

		-- Launch encounter
		if encounter ~= nil then
			-- Generic encounter data, some may be overwritten
			self.encounterData = {};
			self.encounterData["initialized"] = true;
			self.encounterData["encounterName"] = encounter;
			self.encounterData["encounterStartTime"] = tonumber(self.GS["Time"]);
			self.encounterData["scriptPath"] = CF.RandomEncounterScripts[encounter];

			self.encounterData["encounterConcluded"] = false;

			dofile(self.encounterData["scriptPath"]);

			if self.EncounterCreate then
				self:EncounterCreate();
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GiveFocusToBridge()
	local bridgeEmpty = true;
	local playerCandidate = Activity.PLAYER_NONE;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local actor = self:GetControlledActor(player);

		if actor and MovableMan:IsActor(actor) then
			if actor.PresetName ~= "Ship Control Panel" and playerCandidate == Activity.PLAYER_NONE then
				playerCandidate = player;
			end

			if actor.PresetName == "Ship Control Panel" then
				bridgeEmpty = false;
			end
		end
	end

	if playerCandidate ~= Activity.PLAYER_NONE and bridgeEmpty and MovableMan:IsActor(self.ShipControlPanelActor) then
		self:SwitchToActor(self.ShipControlPanelActor, playerCandidate, CF.PlayerTeam);
	end

	self.ShipControlMode = self.ShipControlPanelModes.REPORT;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SendTransmission(message, options)
	self.vesselData["dialog"] = { message=message, options=options };
	self.vesselData["dialogDefaultTimer"]:Reset();
	self.vesselData["dialogOptionSelected"] = 1;
	self.vesselData["dialogOptionChosen"] = 0;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SpawnViaTable(nm)
	local actor = CF.MakeUnitWithPreset(self.GS, nm.Player, nm.Preset)

	if actor then
		if nm.Team then
			actor.Team = nm.Team;
		end

		if nm.Pos then
			actor.Pos = nm.Pos;
		end

		if nm.AIMode then
			actor.AIMode = nm.AIMode;
		end

		if nm.Name then
			actor:SetStringValue("VW_Name", nm.Name);
		end

		if nm.Ally then
			CF.SetAlly(actor, true);
		end

		actor.HFlipped = math.random() < 0.5;
		MovableMan:AddActor(actor);
	end

	return actor;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if orbitedCraft.Team == CF.PlayerTeam then
		-- Bring back actors
		for actor in orbitedCraft.Inventory do
			if actor.Team == CF.PlayerTeam and IsActor(actor) then
				actor = ToActor(actor)
				local i = tonumber(self.GS["MissionReturningTroops"])
				local assignable = true
				local f = CF.GetPlayerFaction(self.GS, 1)

				-- Check if unit is playable
				if CF.UnassignableUnits[f] ~= nil then
					for i = 1, #CF.UnassignableUnits[f] do
						if actor.PresetName == CF.UnassignableUnits[f][i] then
							assignable = false
						end
					end
				end

				-- Don't bring back allied units
				if CF.IsAlly(actor) then
					assignable = false
				end

				CF.ClearDeployed(self.GS)
				if
					assignable and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
				then
					self.GS["Deployed" .. i .. "Preset"] = actor.PresetName
					self.GS["Deployed" .. i .. "Class"] = actor.ClassName
					self.GS["Deployed" .. i .. "Module"] = actor.ModuleName
					self.GS["Deployed" .. i .. "XP"] = actor:GetNumberValue("VW_XP")
					self.GS["Deployed" .. i .. "Identity"] = actor:GetNumberValue("Identity")
					self.GS["Deployed" .. i .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
					self.GS["Deployed" .. i .. "Prestige"] = actor:GetNumberValue("VW_Prestige")
					self.GS["Deployed" .. i .. "Name"] = actor:GetStringValue("VW_Name")
					
					for _, limbName in ipairs(CF.LimbIDs[actor.ClassName]) do
						self.GS["Deployed" .. savedactor .. limbName] = CF.GetLimbData(actor, limbName);
					end

					for j = 1, #pre do
						self.GS["Deployed" .. i .. "Item" .. j .. "Preset"] = pre[j]
						self.GS["Deployed" .. i .. "Item" .. j .. "Class"] = cls[j]
						self.GS["Deployed" .. i .. "Item" .. j .. "Module"] = mdl[j]
					end
							
					self.GS["MissionReturningTroops"] = tonumber(self.GS["MissionReturningTroops"]) + 1
				end
			end
		end
		--Nullify the funds we just gained from the orbited craft
		self:SetTeamFunds(CF.GetPlayerGold(self.GS), CF.PlayerTeam)
		FrameMan:ClearScreenText(0)
	end
end
-----------------------------------------------------------------------
--	Find and assign player brains, for loaded games.
-----------------------------------------------------------------------
function VoidWanderers:LocatePlayerBrains(swapToBrains, initPieMenu)
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			for actor in MovableMan.AddedActors do
				if actor:GetNumberValue("VW_BrainOfPlayer") - 1 == player then
					self:SetPlayerBrain(actor, player);
					self.playersWithBrains[player + 1] = true;
					self.playerBrains[player + 1] = actor;

					if swapToBrains then
						self:SwitchToActor(actor, player, CF.PlayerTeam);
					end

					CF.SetBrain(actor, true);
					self:GetBanner(GUIBanner.RED, player):ClearText();
				end
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DrawDottedLine(x1, y1, x2, y2, player, interval)
	local i = CF.Dist(Vector(x1, y1), Vector(x2, y2))

	local ax = (x2 - x1) / i * interval
	local ay = (y2 - y1) / i * interval

	local x = x1
	local y = y1

	i = math.floor(i)

	for i = 1, i, interval do
		path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_RouteDot.png";
		PrimitiveMan:DrawBitmapPrimitive(player, Vector(x, y), path, 0, false, false);

		x = x + ax
		y = y + ay
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DrawWanderingDottedLine(x1, y1, x2, y2, player, interval, w, p, scale)
	local i = CF.Dist(Vector(x1, y1), Vector(x2, y2))
	local t = 0

	local startOffsetX, startOffsetY = -math.cos(p) * scale, -math.sin(p) * scale
	local endOffsetX, endOffsetY = -math.cos(p + w) * scale, -math.sin(p + w) * scale

	while t < 1 do
		local pos = Vector(
			x1 + (x2 - x1) * t + startOffsetX + (endOffsetX - startOffsetX) * t + math.cos(p + w * t) * scale,
			y1 + (y2 - y1) * t + startOffsetY + (endOffsetY - startOffsetY) * t + math.sin(p + w * t) * scale
		)
		
		path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_RouteDot.png";
		PrimitiveMan:DrawBitmapPrimitive(player, pos, path, 0, false, false);

		t = t + interval / math.min(math.abs(math.sqrt(
			((x2 - x1) + (endOffsetX - startOffsetX) - math.sin(p + w * t) * w * scale) ^ 2 +
			((y2 - y1) + (endOffsetY - startOffsetY) + math.cos(p + w * t) * w * scale) ^ 2
		)), i)
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DeployGenericMissionEnemies(setnumber, setname, plr, team, spawnrate)
	local deployments = {};
	
	table.insert(deployments, { PointName = "Defender", Presets = { CF.PresetTypes.DEFENDER } });
	table.insert(deployments, { PointName = "Sniper", Presets = { CF.PresetTypes.SNIPER } });
	table.insert(deployments, { PointName = "Heavy", Presets = { CF.PresetTypes.HEAVY1, CF.PresetTypes.HEAVY2 } });
	table.insert(deployments, { PointName = "Shotgun", Presets = { CF.PresetTypes.SHOTGUN } });
	table.insert(deployments, { PointName = "Armor", Presets = { CF.PresetTypes.ARMOR1, CF.PresetTypes.ARMOR2 } });
	table.insert(deployments, { PointName = "Rifle", Presets = { CF.PresetTypes.INFANTRY1, CF.PresetTypes.INFANTRY2 } });
	table.insert(deployments, { PointName = "Any", Presets = nil });

	for i = 1, #deployments do
		local deployment = deployments[i];

		local usablePositions = CF.GetPointsArray(self.Pts, setname, setnumber, deployment.PointName);
		local count = math.max(math.floor(spawnrate * #usablePositions), 1);
		local positions = CF.RandomSampleOfList(usablePositions, count);

		for j = 1, #positions do
			local newUnit = {};

			newUnit.Preset = deployment.Presets and deployment.Presets[math.random(#deployment.Presets)] or math.random(CF.PresetTypes.ARMOR2);
			newUnit.Team = team;
			newUnit.Player = plr;
			newUnit.Pos = positions[j];
			newUnit.Ally = team == CF.PlayerTeam;
			newUnit.AIMode = (not SceneMan:CastStrengthRay(positions[j] + Vector(-50, 0), Vector(100, 0), 40, Vector(), 10, rte.grassID, true)) and Actor.AIMODE_PATROL or Actor.AIMODE_SENTRY;

			self:SpawnViaTable(newUnit);
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ObtainBaseBoxes(setname, setnumber)
	if self.missionData["initialized"] then
		local boxes = {};
		local corners = CF.GetPointsArray(self.Pts, setname, setnumber, "Base");

		for i = 1, #corners, 2 do
			local c1, c2 = corners[i], corners[i + 1];

			if c1.X > c2.X then
				if c1.Y > c2.Y then
					table.insert(boxes, Box(c1.X, c1.Y, SceneMan.Scene.Width, SceneMan.Scene.Height));
					table.insert(boxes, Box(0, c1.Y, c2.X, SceneMan.Scene.Height));
					table.insert(boxes, Box(c1.X, 0, SceneMan.Scene.Width, c2.Y));
					table.insert(boxes, Box(0, 0, c2.X, c2.Y));
				else
					table.insert(boxes, Box(c1.X, c1.Y, SceneMan.Scene.Width, c2.Y));
					table.insert(boxes, Box(0, c1.Y, c2.X, c2.Y));
				end
			else
				if c1.Y > c2.Y then
					table.insert(boxes, Box(c1.X, c1.Y, c2.X, SceneMan.Scene.Height));
					table.insert(boxes, Box(c1.X, 0, c2.X, c2.Y));
				else
					table.insert(boxes, Box(c1.X, c1.Y, c2.X, c2.Y));
				end
			end
		end

		self.missionData["missionBase"] = boxes;
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DeployInfantryMines(team, rate)
	local points = {};

	for actor in MovableMan.AddedActors do
		if actor.Team == team and IsAHuman(actor) then
			table.insert(points, actor.Pos);
		end
	end

	local randomPoints = CF.RandomSampleOfList(points, math.floor(#points * rate));

	for _, pos in pairs(randomPoints) do
		local mine = CreateMOSRotating("Anti Personnel Mine Active", "Base.rte");
		mine.Pos = pos;
		mine.Team = team;
		mine.Sharpness = team;
		mine.IgnoresTeamHits = true;
		mine.Vel = Vector(0, 10):RadRotate(RangeRand(-2, 2));
		MovableMan:AddParticle(mine);
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GiveMissionRewards(disablepenalties)
	print("MISSION COMPLETED")
	self.GS["Participant" .. self.missionData["missionContractor"] .. "Reputation"] = tonumber(
		self.GS["Participant" .. self.missionData["missionContractor"] .. "Reputation"]
	) + self.missionData["reputationReward"]
	if not disablepenalties then
		self.GS["Participant" .. self.missionData["missionTarget"] .. "Reputation"] = tonumber(
			self.GS["Participant" .. self.missionData["missionTarget"] .. "Reputation"]
		) - math.ceil(self.missionData["reputationReward"] * CF.ReputationPenaltyRatio)
	end

	CF.ChangePlayerGold(self.GS, self.missionData["goldReward"])

	-- Refresh Black Market listing after every completed mission
	self.GS["BlackMarket" .. "Station Ypsilon-2" .. "LastRefresh"] = nil

	if self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"] ~= nil then
		local last = tonumber(self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"])
		if (last + CF.BlackMarketRefreshInterval) * RangeRand(0.5, 0.75) < tonumber(self.GS["Time"]) then
			self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"] = nil
		end
	end

	self.reportData[#self.reportData + 1] = "MISSION COMPLETED"
	if self.missionData["goldReward"] > 0 then
		self.reportData[#self.reportData + 1] = tostring(self.missionData["goldReward"]) .. "oz of gold received"
	end

	local exppts = math.floor((self.missionData["reputationReward"] + self.missionData["goldReward"]) / 8)

	local levelUp = false

	if self.GS["BrainsOnMission"] == "True" then
		levelUp = CF.AwardBrainExperience(self.GS, exppts);

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if self.playerBrains[player] then
				local effect = CF.CreateTextEffect("+" .. exppts .. " exp" .. (levelUp and "\nLEVEL UP!" or ""));

				if effect then
					effect.Pos = self.playerBrains[player].AboveHUDPos + Vector(math.random(-5, 5), -math.random(5));
					MovableMan:AddParticle(effect);
				end
			end
		end

		self.reportData[#self.reportData + 1] = tostring(exppts) .. " exp received"

		if levelUp then
			local s = ""

			if self.PlayerCount > 1 then
				s = "s"
			end

			self.reportData[#self.reportData + 1] = "Brain" .. s .. " leveled up!"
		end
	end

	local actors = {};

	for actor in MovableMan.Actors do
		if CF.IsCommonUnit(actor) and actor.Team == CF.PlayerTeam then
			table.insert(actors, actor);
		end
	end

	CF.MissionCombo = CF.MissionCombo and CF.MissionCombo + 1 or 1;
	local comboMult = math.sqrt(CF.MissionCombo);

	if #actors > 0 then
		local gains = (1 + exppts * 0.1) * comboMult;

		for _, actor in pairs(actors) do
			self:GiveXP(actor, gains);
		end
	end

	if self.missionData["reputationReward"] > 0 then
		self.reportData[#self.reportData + 1] = "+"
			.. self.missionData["reputationReward"]
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"])]
			.. " reputation"
		if not disablepenalties then
			self.reportData[#self.reportData + 1] = "-"
				.. math.ceil(self.missionData["reputationReward"] * CF.ReputationPenaltyRatio)
				.. " "
				.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])]
				.. " reputation"
		end
		if CF.MissionCombo > 1 then
			self.reportData[#self.reportData + 1] = "Completion streak: "
				.. CF.MissionCombo
				.. " / XP multiplier: "
				.. math.floor(comboMult * 10 + 0.5) * 0.1
				.. "x"
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GiveMissionPenalties()
	print("MISSION FAILED")
	if self.missionData["missionContractor"] then
		self.GS["Participant" .. self.missionData["missionContractor"] .. "Reputation"] = tonumber(
			self.GS["Participant" .. self.missionData["missionContractor"] .. "Reputation"]
		) - math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
	end
	if self.missionData["missionTarget"] then
		self.GS["Participant" .. self.missionData["missionTarget"] .. "Reputation"] = tonumber(
			self.GS["Participant" .. self.missionData["missionTarget"] .. "Reputation"]
		) - math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
	end

	self.reportData[#self.reportData + 1] = "MISSION FAILED"

	CF.MissionCombo = 0
	local loss = math.floor((self.missionData["reputationReward"] + self.missionData["goldReward"]) * 0.005)
	for actor in MovableMan.Actors do
		if CF.IsCommonUnit(actor) and actor.Team == CF.PlayerTeam then
			self:GiveXP(actor, -(loss + actor:GetNumberValue("VW_XP") * 0.1))
		end
	end
	if self.missionData["reputationReward"] > 0 then
		self.reportData[#self.reportData + 1] = "-"
			.. math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"])]
			.. " reputation"
		self.reportData[#self.reportData + 1] = "-"
			.. math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])]
			.. " reputation"
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:AddPreEquippedItemsToRemovalQueue(a)
	-- Mark actors' pre-equipped items for deletion
	if CF.ItemsToRemove[a.PresetName] then
		for i = 1, #CF.ItemsToRemove[a.PresetName] do
			local nw = #self.ItemRemoveQueue + 1
			self.ItemRemoveQueue[nw] = {}
			self.ItemRemoveQueue[nw]["Preset"] = CF.ItemsToRemove[a.PresetName][i]
			self.ItemRemoveQueue[nw]["Actor"] = a
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitExplorationPoints()
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Exploration");
	local pts = CF.GetPointsArray(self.Pts, "Exploration", set, "Explore");
	self.missionData["explorationPoint"] = pts[math.random(#pts)];

	self.missionData["explorationRecovered"] = false;

	local hologram = ToMOSRotating(PresetMan:GetPreset("MOSRotating", "Hologram", "VoidWanderers.rte")):Clone();
	hologram.Frame = math.random(hologram.FrameCount - 1);
	hologram.Pos = self.missionData["explorationPoint"] * 1;
	MovableMan:AddParticle(hologram);
	self.missionData["explorationHologram"] = hologram;

	self.missionData["explorationText"] = {};
	self.missionData["explorationTextStart"] = -100;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessExplorationPoints()
	local pos = self.missionData["explorationPoint"];

	if pos ~= nil then
		if not self.missionData["explorationRecovered"] then
			for actor in MovableMan.Actors do
				if actor.Team == CF.PlayerTeam and CF.Dist(actor.Pos, pos) < 25 then
					if CF.IsCommander(actor) then
						self.missionData["explorationText"] = self:GiveRandomExplorationReward();
						self.missionData["explorationRecovered"] = true;
						MovableMan:RemoveParticle(self.missionData["explorationHologram"]);
						self.missionData["explorationTextStart"] = tonumber(self.GS["Time"]);
						self.missionData["stage"] = CF.MissionStages.COMPLETED;

						break;
					else
						local text = "Only a commander can decrypt this holorecord";
						self:AddObjectivePoint(text, pos + Vector(0, -30), CF.PlayerTeam, GameActivity.ARROWDOWN);
					end
				end
			end
		end
	end

	if tonumber(self.GS["Time"]) > self.missionData["explorationTextStart"] and tonumber(self.GS["Time"]) < self.missionData["explorationTextStart"] + 10 then
		local text = "";

		for i = 1, #self.missionData["explorationText"] do
			text = text .. self.missionData["explorationText"][i] .. "\n";
		end
		
		self:AddObjectivePoint(text, pos + Vector(0, -30), CF.PlayerTeam, GameActivity.ARROWDOWN);
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GiveRandomExplorationReward()
	local rewards = { gold = 1, experience = 2, reputation = 3, blueprints = 4, nothing = 5 };
	local text = { "Nothing of value was found." };

	local r = math.random(rewards.gold, rewards.nothing);

	if r == rewards.gold then
		local amount = math.floor(math.random(self.missionData["difficulty"] * 200, self.missionData["difficulty"] * 400));
		CF.ChangePlayerGold(self.GS, amount);

		text = {
			"Bank account access codes found.",
			tostring(amount) .. "oz of gold received."
		};
	elseif r == rewards.experience then
		local exppts = math.floor(math.random(self.missionData["difficulty"] * 25, self.missionData["difficulty"] * 50));local levelUp = CF.AwardBrainExperience(self.GS, gain, killer:GetNumberValue("VW_BrainOfPlayer") - 1);
		local levelUp = CF.AwardBrainExperience(self.GS, exppts);

		text = {
			"Captain's log found.",
			"+" .. exppts .. " exp",
			levelUp and "LEVEL UP!" or ""
		};
	elseif r == rewards.reputation then
		local amount = math.floor(math.random(self.missionData["difficulty"] * 50, self.missionData["difficulty"] * 100));
		local plr = math.random(tonumber(self.GS["ActiveCPUs"]));
		local rep = tonumber(self.GS["Participant" .. plr .. "Reputation"]);
		self.GS["Participant" .. plr .. "Reputation"] = rep + amount;

		text = {
			"Intelligence data found.",
			"+" .. amount .. " " .. CF.GetPlayerFaction(self.GS, plr) .. " reputation."
		};
	elseif r == rewards.blueprints then
		local id = CF.UnlockRandomQuantumItems(self.GS);

		text = {
			"Quantum schematic found.",
			CF.QuantumItmPresets[id] .. " unlocked. "
		};
	end

	if self.reportData == nil then
		self.reportData = {};
	end

	for i = 1, #text do
		self.reportData[#self.reportData + 1] = text[i];
	end

	CF.SaveMissionReport(self.GS, self.reportData);

	return text;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GiveRandomExperienceReward(diff)
	local exppts = 150 + math.random(350)

	if diff ~= nil then
		exppts = CF.CalculateReward(diff, 250)
	end

	levelUp = CF.AwardBrainExperience(self.GS, exppts)

	text = {}
	text[1] = tostring(exppts) .. " exp gained."

	if levelUp then
		local s = ""
		if self.PlayerCount > 1 then
			s = "s"
		end

		text[2] = "Brain" .. s .. " leveled up!"
	end

	CF.SaveMissionReport(self.GS, self.reportData)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MakeAlertSound(volume)
	if self.AlarmTimer:IsPastRealMS(2000) then
		self.AlarmTimer:Reset();
		local pos = Vector(SceneMan.SceneWidth * 0.5, SceneMan.SceneHeight * 0.5)

		if self.GS["Mode"] == "Vessel" then
			local brain = self:GetPlayerBrain(Activity.PLAYER_1) or self:GetControlledActor(Activity.PLAYER_1)
			if brain then
				pos = brain.Pos
			end
		end

		if self.GS["Mode"] == "Mission" then
			local brain = MovableMan:GetFirstBrainActor(CF.CPUTeam)
			if brain then
				pos = brain.Pos
			end
		end

		local alarm = CreateAEmitter("Alarm Effect", CF.ModuleName)
		alarm.Pos = pos
		alarm.BurstSound.Volume = volume
		MovableMan:AddParticle(alarm)
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:StartMusic(musictype)
	print("VoidWanderers:StartMusic")
	local track = -1

	MusicMan:ResetMusicState()
	MusicMan:PlayDynamicSong(CF.Music[musictype], "Default", true, false, false)
	self.GS["CurrentMusicType"] = musictype;

	self.LastMusicType = musictype
	self.LastMusicTrack = track
end
-----------------------------------------------------------------------
-- Message handling.
-----------------------------------------------------------------------
function VoidWanderers:OnMessage(message, context)
	if message == "request_immediate_return" then
		if self.GS["Mode"] == "Mission" then
			local safeUnits = {};
			local unsafeUnits = {};
			local enemyPos = {};
			local brainUnsafe = 0;
			local isSafe = false;

			for actor in MovableMan.Actors do
				if (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") and actor.Team ~= Activity.NOTEAM then
					if actor.Team ~= CF.PlayerTeam then
						enemyPos[#enemyPos + 1] = actor.Pos;
					elseif not CF.IsAlly(actor) and actor.PresetName ~= "LZ Control Panel" then
						if self:IsInLZPanelProximity(actor.Pos) then
							safeUnits[#safeUnits + 1] = actor;
						else
							unsafeUnits[#unsafeUnits + 1] = actor;

							if CF.IsBrain(actor) then
								brainUnsafe = brainUnsafe + 1;
							end
						end
					end
				end
			end

			for actor in MovableMan:GetMOsInBox(self.lzBox, Activity.NOTEAM, true) do
				if
					(actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and actor.Team == CF.PlayerTeam
					and ToActor(actor):IsDead()
					and not CF.IsAlly(ToActor(actor))
					and self:IsInLZPanelProximity(actor.Pos)
				then
					safeUnits[#safeUnits + 1] = ToActor(actor);
				end
			end

			local friends = #safeUnits + #unsafeUnits;

			if #enemyPos == 0 or friends / 4 > #enemyPos then
				isSafe = true;
			end

			if brainUnsafe <= 0 or isSafe then
				self.deserializeDeployedTeam = true;
			end
		end
	elseif message == "read_from_CF" then
		local temp = CF;
		local flag = false;
		
		-- Run down the path, flag for failure and break if something before the last step is nil or we run into a function
		for i = 1, #context[2] do
			temp = temp[context[2][i]];

			if (not temp and i ~= #context[2]) then
				flag = -1;
				break;
			elseif type(temp) == "function" then
				flag = -2;
				break;
			end
		end

		if flag then
			local message = "Default CF read error, this shouldn't be possible to encounter.";

			if flag == -1 then
				message = "Malformed path on CF read.";
			end

			if flag == -2 then
				message = "Trying to read function value on CF read, try call_in_CF instead.";
			end

			error(message);
			return;
		end
		
		ToMOSRotating(context[1]):SendMessage("return_from_activity", temp);
	elseif message == "write_to_CF" then
		local temp = CF;
		local flag = false;
		
		for i = 1, #context[1] - 1 do
			temp = temp[context[1][i]];

			if (not temp) then
				flag = -1
				break
			elseif type(temp) == "function" then
				flag = -2
				break
			end
		end

		if flag then
			local message = "Default CF write error, this shouldn't be possible to encounter.";

			if flag == -1 then
				message = "Malformed path on CF write.";
			end

			if flag == -2 then
				message = "Trying to overwrite function with value on CF write.";
			end

			error(message);
			return;
		end
		
		temp[context[1][#context[1]]] = context[2];
	elseif message == "read_from_GS" then
		ToMOSRotating(context[1]):SendMessage("return_from_activity", self.GS[context[2]]);
	elseif message == "write_to_GS" then
		local flag = false;
		local keyType = type(context[1]);
		local valueType = type(context[2]);

		if keyType ~= "string" then
			flag = -1;
		elseif type == "function" then
			flag = -2;
		elseif type == "table" or type == "userdata" then
			flag = -3;
		end

		if flag then
			local message = "Default GS write error, this shouldn't be possible to encounter.";

			if flag == -1 then
				message = "A key to the GS must be a string, as it is a key-value registry for save game data.";
			elseif flag == -2 then
				message = "Do not try to transfer functions, which you have evidently attempted to do.";
			elseif flag == -3 then
				message = "Do not try to write tables or userdata to the GS. The GS is a registry for stringifiable values.";
			end

			error(message);
			return;
		end
		
		self.GS[context[1]] = context[2];
	elseif message == "call_in_CF" then
		local temp = CF;
		local flag = false;
		
		for i = 1, #context[2] do
			temp = temp[context[2][i]];

			if (not temp) then
				flag = -1;
				break;
			elseif type(temp) ~= "function" then
				flag = -2;
				break;
			end
		end

		if flag then
			local message = "Default CF call error, this shouldn't be possible to encounter.";

			if flag == -1 then
				message = "Malformed path on CF remote call.";
			end

			if flag == -2 then
				message = "Trying to execute non-function value on CF remote call.";
			end

			error(message);
			return;
		end
		
		local target = context[1];
		local result = { temp(unpack(context[3])) };

		if target and target.ClassName and IsMovableObject(target) then
			ToMovableObject(target):SendMessage("return_from_activity", result);
		end
	end
end
-----------------------------------------------------------------------
-- That's all folks!!!
-----------------------------------------------------------------------
