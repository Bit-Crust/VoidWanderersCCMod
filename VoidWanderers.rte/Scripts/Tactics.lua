-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Start Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:StartActivity(isNewGame)
	print("VoidWanderers:Tactics:StartActivity");
	
	CF.GS = self.GS;

	self.vesselData = {};
	self.missionData = {};
	self.ambientData = {};
	self.encounterData = {};

	if self.IsInitialized then
		return
	end

	self.PlayersWithBrains = {}
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self.PlayersWithBrains[player + 1] = false
	end
	
	self.AllowsUserSaving = true
	self.BuyMenuEnabled = false
	self.ShopsCreated = false

	self.LastMusicType = -1
	self.LastMusicTrack = -1

	self.AlarmTimer = Timer()
	self.AlarmTimer:Reset()

	self.TickTimer = Timer()
	self.TickTimer:Reset()
	self.TickInterval = CF.TickInterval

	self.TeleportEffectTimer = Timer()
	self.TeleportEffectTimer:Reset()

	self.HoldTimer = Timer()
	self.HoldTimer:Reset()

	self.SceneTimer = Timer()
	self.SceneTimer:Reset();

	-- All items in this queue will be removed
	self.ItemRemoveQueue = {}

	self.PlayerFaction = self.GS["PlayerFaction"]
	
	-- Load generic level data
	self.SceneConfig = CF.ReadSceneConfigFile(SceneMan.Scene.ModuleName, SceneMan.Scene.PresetName .. ".dat")

	if SceneMan.Scene:GetArea("Vessel") then
		if not isNewGame then
			self.vesselData = self.saveLoadHandler:ReadSavedStringAsTable("vesselData")
		else
			self.vesselData = {}
			self.vesselData["initialized"] = true
			self.vesselData["artificialGravity"] = Vector(0, rte.PxTravelledPerFrame / (1 + SceneMan.Scene.GlobalAcc.Y))
			self.vesselData["ship"] = SceneMan.Scene:GetArea("Vessel")
			self.vesselData["spaceDeck"] = SceneMan.Scene:GetArea("SpaceWalk") or self.vesselData["ship"]
			self.vesselData["flightDisabled"] = false
			self.vesselData["flightAimless"] = false
			self.vesselData["throttle"] = 1

			self.vesselData["dialogDefaultTimer"] = Timer()

			-- Create emitters
			self.vesselData["engines"] = {}
			for i = 1, 10 do
				local x, y

				x = tonumber(self.SceneConfig["Engine" .. i .. "X"])
				y = tonumber(self.SceneConfig["Engine" .. i .. "Y"])
				local em = CreateAEmitter("Vessel Main Thruster")
				if em and x and y then
					em.Pos = Vector(x, y)
					self.vesselData["engines"][i] = em
					MovableMan:AddParticle(em)
					em:EnableEmission(not self.vesselData["flightDisabled"])
					em.Throttle = self.vesselData["throttle"]
				else
					break
				end
			end
		end
	end

	-- Load pre-spawned enemy locations. These locations also used during assaults to place teleported units
	self.EnemySpawn = {}
	for i = 1, 32 do
		local x, y
		x = tonumber(self.SceneConfig["EnemySpawn" .. i .. "X"])
		y = tonumber(self.SceneConfig["EnemySpawn" .. i .. "Y"])

		if x and y then
			self.EnemySpawn[i] = Vector(x, y)
		else
			break
		end
	end
	
	-- Display gold like normal since the buy menu is disabled
	self:SetTeamFunds(CF.GetPlayerGold(self.GS), CF.PlayerTeam)

	if self.GS["AISkillPlayer"] then
		self:SetTeamAISkill(CF.PlayerTeam, tonumber(self.GS["AISkillPlayer"]))
	end

	if self.GS["AISkillCPU"] then
		self:SetTeamAISkill(CF.CPUTeam, tonumber(self.GS["AISkillCPU"]))
	end

	self.AssaultSpawn = SceneMan.Scene:GetArea("AssaultSpawn")

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
		if self.GS["DeserializeOnboard"] == "True" then
			self.GS["DeserializeOnboard"] = "False"

			for i = 1, CF.MaxSavedActors do
				if self.onboardActors and self.onboardActors[i] then
					local actor = self.onboardActors[i]:Clone();
					self.onboardActors[i] = nil;

					local x = self.GS["Actor" .. i .. "X"];
					local y = self.GS["Actor" .. i .. "Y"];

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
						actor.Status = Actor.DEAD;
					end

					actor.AIMode = Actor.AIMODE_SENTRY;
					actor:ClearMovePath();
					actor.Vel = actor.Vel * 0;
					actor.AngularVel = actor.AngularVel * 0;
					MovableMan:AddActor(actor);
				elseif self.GS["Actor" .. i .. "Preset"] then
					local limbData = {}
					for j = 1, #CF.LimbID do
						limbData[j] = self.GS["Actor" .. i .. CF.LimbID[j]]
					end
					local actor = CF.MakeActor(
						self.GS["Actor" .. i .. "Preset"],
						self.GS["Actor" .. i .. "Class"],
						self.GS["Actor" .. i .. "Module"],
						self.GS["Actor" .. i .. "XP"],
						self.GS["Actor" .. i .. "Identity"],
						self.GS["Actor" .. i .. "Player"],
						self.GS["Actor" .. i .. "Prestige"],
						self.GS["Actor" .. i .. "Name"],
						limbData
					)
					if actor then
						actor.AIMode = Actor.AIMODE_SENTRY
						actor:ClearAIWaypoints()

						actor.Team = CF.PlayerTeam
						for j = 1, CF.MaxSavedItemsPerActor do
							if self.GS["Actor" .. i .. "Item" .. j .. "Preset"] then
								local itm = CF.MakeItem(
									self.GS["Actor" .. i .. "Item" .. j .. "Preset"],
									self.GS["Actor" .. i .. "Item" .. j .. "Class"],
									self.GS["Actor" .. i .. "Item" .. j .. "Module"]
								)
								if itm then
									actor:AddInventoryItem(itm)
								end
							end
						end

						local x = self.GS["Actor" .. i .. "X"]
						local y = self.GS["Actor" .. i .. "Y"]

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
		end

		-- Spawn previously deployed actors
		if self.GS["DeserializeDeployedTeam"] == "True" then
			self.GS["DeserializeDeployedTeam"] = "False"
		
			for i = 1, CF.MaxSavedActors do
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
					for j = 1, #CF.LimbID do
						limbData[j] = self.GS["Deployed" .. i .. CF.LimbID[j]]
					end
					local actor = CF.MakeActor(
						self.GS["Deployed" .. i .. "Preset"],
						self.GS["Deployed" .. i .. "Class"],
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
									self.GS["Deployed" .. i .. "Item" .. j .. "Preset"],
									self.GS["Deployed" .. i .. "Item" .. j .. "Class"],
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
			self:ClearDeployed()
		end

		self:LocatePlayerBrains(isNewGame, true)

		-- Create any necessary brains
		self.createdBrainCases = {}
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if self:PlayerActive(player) and self:PlayerHuman(player) and not self.PlayersWithBrains[player + 1] then
				local actor = CreateActor("Brain Case", "Base.rte")
				if actor then
					actor.Team = CF.PlayerTeam
					actor.Pos = self.BrainPos[player + 1]
					actor:SetNumberValue("VW_BrainOfPlayer", player + 1)
					MovableMan:AddActor(actor)
					self:SetPlayerBrain(actor, player)
					self:SwitchToActor(actor, player, CF.PlayerTeam)
					self.createdBrainCases[player] = actor
				end
			end
		end

		self:InitConsoles()

		-- If we're on temp-location then cancel this location
		if CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TEMPLOCATION) then
			self.GS["Location"] = nil
		end
	end
	
	if self.GS["Mode"] == "Mission" then
		print("VoidWanderers:Tactics:StartActivity:Mission")
		self:StartMusic(CF.MusicTypes.MISSION_CALM)

		-- All mission related final message will be accumulated in mission report list
		local scene = SceneMan.Scene.PresetName

		self.Pts = CF.ReadPtsData(scene, self.SceneConfig)
		self.MissionDeploySet = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

		-- Init LZs
		self:InitLZControlPanelUI()

		-- Spawn player troops
		local dest = 1
		local dsts = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerUnit")

		if self.GS["DeserializeDeployedTeam"] == "True" then
			self.GS["DeserializeDeployedTeam"] = "False"
			self.GS["MissionDeployedTroops"] = 1
			for i = 1, CF.MaxSavedActors do
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
					local limbData = {}
					for j = 1, #CF.LimbID do
						limbData[j] = self.GS["Deployed" .. i .. CF.LimbID[j]]
					end
					local actor = CF.MakeActor(
						self.GS["Deployed" .. i .. "Preset"],
						self.GS["Deployed" .. i .. "Class"],
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
									self.GS["Deployed" .. i .. "Item" .. j .. "Preset"],
									self.GS["Deployed" .. i .. "Item" .. j .. "Class"],
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
							actor.Pos = dsts[dest]
							dest = dest + 1

							if dest > #dsts then
								dest = 1
							end
						end

						if IsAHuman(actor) and ToAHuman(actor).Head == nil then
							actor.DeathSound = nil
							actor.Status = Actor.DEAD
						end

						-- If it wasn't a faulty player-owned brain, then it is something we can put in the scene
						if IsActor(actor) then
							MovableMan:AddActor(actor)
							self:AddPreEquippedItemsToRemovalQueue(actor)
						end
					end

					self.GS["MissionDeployedTroops"] = tonumber(self.GS["MissionDeployedTroops"]) + 1
				else
					break
				end
			end
		end
		
		self:LocatePlayerBrains(isNewGame, true)

		self.MissionReport = {}

		-- Clear previous script functions
		self.MissionCreate = nil
		self.MissionUpdate = nil
		self.MissionDestroy = nil

		self.AmbientCreate = nil
		self.AmbientUpdate = nil
		self.AmbientDestroy = nil

		-- Load ambience and mission data if possible
		if not isNewGame then
			self.missionData = self.saveLoadHandler:ReadSavedStringAsTable("missionData")
			if self.missionData["initialized"] then
				dofile(self.missionData["scriptPath"])
			end
			self.ambientData = self.saveLoadHandler:ReadSavedStringAsTable("ambientData")
			if self.ambientData["initialized"] then
				dofile(self.ambientData["scriptPath"])
			end
		else
			-- Generic mission data, some may be overwritten
			self.missionData = {}
			self.missionData["endMusicPlayed"] = false;
			self.missionData["initialized"] = true
			self.missionData["missionStartTime"] = self.Time;
			self.missionData["stage"] = CF.MissionStages.ACTIVE;
			self.missionData["missionStatus"] = "";
			self.missionData["difficulty"] = CF.GetLocationDifficulty(self.GS, self.GS["Location"]);
			self.missionData["reputationReward"] = 0;
			self.missionData["goldReward"] = 0;

			local securityIncrement = CF.SecurityIncrementPerDeployment
			-- Find available mission
			for m = 1, CF.MaxMissions do
				if self.GS["Location"] == self.GS["Mission" .. m .. "Location"] then
					local missionType = self.GS["Mission" .. m .. "Type"]

					self.missionData["difficulty"] = CF.GetFullMissionDifficulty(self.GS, self.GS["Location"], m)
					self.missionData["missionContractor"] = tonumber(self.GS["Mission" .. m .. "SourcePlayer"])
					self.missionData["missionTarget"] = tonumber(self.GS["Mission" .. m .. "TargetPlayer"])
					self.missionData["scriptPath"] = CF.MissionScript[missionType]

					self.missionData["goldReward"] = CF.CalculateReward(
						CF.MissionGoldRewardPerDifficulty[missionType],
						self.missionData["difficulty"]
					)
					self.missionData["reputationReward"] = CF.CalculateReward(
						CF.MissionReputationRewardPerDifficulty[missionType],
						self.missionData["difficulty"]
					)

					-- Create unit presets
					CF.CreateAIUnitPresets(
						self.GS,
						self.missionData["missionContractor"],
						CF.GetTechLevelFromDifficulty(
							self.GS,
							self.missionData["missionContractor"],
							self.missionData["difficulty"],
							CF.MaxDifficulty
						)
					)
					CF.CreateAIUnitPresets(
						self.GS,
						self.missionData["missionTarget"],
						CF.GetTechLevelFromDifficulty(
							self.GS,
							self.missionData["missionTarget"],
							self.missionData["difficulty"],
							CF.MaxDifficulty
						)
					)

					securityIncrement = CF.SecurityIncrementPerMission

					break
				end -- GAMEPLAY
			end

			-- Increase location security every time deployment happens
			CF.SetLocationSecurity(self.GS, self.GS["Location"], CF.GetLocationSecurity(self.GS, self.GS["Location"]) + securityIncrement)

			-- Backup mission script
			if self.missionData["scriptPath"] == nil then
				local defaultScripts = CF.LocationScript[self.GS["Location"]]
				if defaultScripts then
					self.missionData["scriptPath"] = defaultScripts[math.random(#defaultScripts)]
				else
					self.missionData["scriptPath"] = "VoidWanderers.rte/Scripts/Missions/Generic.lua"
				end
			end

			-- Generic ambient bits, I don't think they're ever used
			self.ambientData = {}
			self.ambientData["scriptPath"] = CF.LocationAmbientScript[self.GS["Location"]]
			self.ambientData["initialized"] = true
			
			if self.ambientData["scriptPath"] == nil then
				self.ambientData["scriptPath"] = "VoidWanderers.rte/Scripts/Ambience/Generic.lua"
			end

			dofile(self.missionData["scriptPath"])
			dofile(self.ambientData["scriptPath"])
			self:MissionCreate()
			self:AmbientCreate()
		end

		-- isNewGame can only ever be undefined or false with how it currently is, so. . . this is how it is
		if isNewGame then
			-- Spawn crates
			local hiddenRate = fowEnabled and 0.25 or 0.5
			local crts = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "Crates")
			local amount = math.min(math.ceil(CF.CratesRate * #crts), #crts)
			local crtspos = CF.RandomSampleOfList(crts, amount)

			for i = 1, #crtspos do
				local crt = math.random() < CF.ActorCratesRate and CreateMOSRotating("Crate", self.ModuleName)
					or (
						math.random() < 0.01 and CreateAHuman("Case", self.ModuleName)
						or CreateAttachable("Case", self.ModuleName)
					)

				if crt then
					crt.Pos = crtspos[i]
					if math.random() < CF.CrateRandomLocationsRate then
						-- Try to spawn a crate at a totally random location
						local materialThreshold = 100 -- The average strength of the terrain surrounding the crate has to be below this
						local surroundingStrength = 0
						local potentialPos = Vector(
							(
									SceneMan.SceneWrapsX and math.random(SceneMan.SceneWidth)
									or math.random(50, SceneMan.SceneWidth - 50)
								),
							math.random(50, SceneMan.SceneHeight - 50)
						)
						local attempts = 0
						while attempts < 2 do
							local terrCheck = SceneMan:GetTerrMatter(potentialPos.X, potentialPos.Y)
							if terrCheck ~= rte.airID then
								surroundingStrength = surroundingStrength
									+ SceneMan:GetMaterialFromID(terrCheck).StructuralIntegrity
								local radius = crt.Radius
								local dots = 5
								for i = 1, dots do
									local checkPos = potentialPos + Vector(radius, 0):RadRotate((math.pi * 2) * (i / dots))
									local terrCheck2 = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
									-- Treat air as a bad surrounding material
									surroundingStrength = surroundingStrength
										+ (
											terrCheck2 ~= rte.airID
												and SceneMan:GetMaterialFromID(terrCheck2).StructuralIntegrity
											or materialThreshold
										)
								end
								if surroundingStrength < materialThreshold * (1 + dots) then
									crt.Pos = potentialPos
									ok = true
								end
							else
								potentialPos = SceneMan:MovePointToGround(Vector(math.random(SceneMan.SceneWidth), 0), 0, 1)
								potentialPos.Y = math.random(potentialPos.Y, SceneMan.SceneHeight - 50)
							end
							attempts = attempts + 1
						end
						if i > #crtspos * hiddenRate then
							crt:EraseFromTerrain()
						end
					else
						crt:EraseFromTerrain()
					end
					crt.PinStrength = crt.GibImpulseLimit * 0.8
					MovableMan:AddMO(crt)
				end
			end
			
			-- Convert non-CPU doors
			if CF.LocationRemoveDoors[self.GS["Location"]] then
				for actor in MovableMan.Actors do
					if actor.ClassName == "ADoor" then
						actor.Team = CF.CPUTeam
					end
				end
			end

			-- Set unseen
			if self.GS["FogOfWar"] then
				SceneMan:MakeAllUnseen(Vector(CF.FogOfWarResolution, CF.FogOfWarResolution), CF.CPUTeam)
				SceneMan:MakeAllUnseen(Vector(CF.FogOfWarResolution, CF.FogOfWarResolution), CF.PlayerTeam)

				-- Reveal outside areas for everyone.
				for x = 0, SceneMan.SceneWidth - 1, CF.FogOfWarResolution do
					local altitude = Vector(0, 0)
					SceneMan:CastTerrainPenetrationRay(Vector(x, 0), Vector(0, SceneMan.Scene.Height), altitude, 50, 0)
					if altitude.Y > 1 then
						SceneMan:RevealUnseenBox(x - 10, 0, CF.FogOfWarResolution + 20, altitude.Y + 10, CF.CPUTeam)
						SceneMan:RevealUnseenBox(x - 10, 0, CF.FogOfWarResolution + 20, altitude.Y + 10, CF.PlayerTeam)
					end
				end

				for Act in MovableMan.AddedActors do
					if not IsADoor(Act) then
						for angle = 0, math.pi * 2, 0.05 do
							SceneMan:CastSeeRay(Act.Team, Act.EyePos, Vector(150+FrameMan.PlayerScreenWidth * 0.5, 0):RadRotate(angle), Vector(), 25, CF.FogOfWarResolution)
						end
					end
				end
			end

			-- Set unseen for AI (maybe some day it will matter ))))
			for team = Activity.TEAM_2, Activity.MAXTEAMCOUNT - 1 do
				SceneMan:MakeAllUnseen(Vector(CF.FogOfWarResolution, CF.FogOfWarResolution), team)
			end
		end
	end

	-- Load encounter data if non-empty
	if not isNewGame then
		self.encounterData = self.saveLoadHandler:ReadSavedStringAsTable("encounterData")
		if self.encounterData["initialized"] then
			dofile(self.encounterData["scriptPath"])
		end
	end

	if not isNewGame then
		local previouslyControlledActors = self.saveLoadHandler:ReadSavedStringAsTable("controlledActors")
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local actor = previouslyControlledActors[player + 1]
			if IsActor(actor) then
				self:SwitchToActor(actor, player, CF.PlayerTeam)
			end
		end
	end

	self.encounterEnableTime = 0

	-- Icon display data
	self.Icon = CreateMOSRotating("Icon_Generic", self.ModuleName)
	self.IconFrame = {}
	self.IconFrame[1] = { comboOf = { 4, 5, 6 }, findByGroup = { "Tools - Breaching", "Tools - Diggers" } }
	self.IconFrame[2] = { comboOf = { 3, 7, 8 }, findByGroup = { "Weapons - Sniper", "Weapons - Explosive" } }
	self.IconFrame[3] = { comboOf = { 4, 8, 9 }, findByGroup = { "Weapons - Sniper" }, findByName = {
		"Scanner",
		"Disarmer",
	} }
	self.IconFrame[4] =
		{ comboOf = { 6, 9 }, findByGroup = { "Tools - Diggers" }, findByName = {
			"Scanner",
			"Disarmer",
		} }
	-- Normal icons
	self.IconFrame[5] =
		{ findByName = { "Remote Explosive", "Timed Explosive" }, findByGroup = {
			"Tools - Breaching",
		} }
	self.IconFrame[6] = { findByGroup = { "Tools - Diggers" } }
	self.IconFrame[7] = { findByGroup = { "Weapons - Explosive" } }
	self.IconFrame[8] = { findByGroup = { "Weapons - Sniper" } }
	self.IconFrame[9] = { findByName = { "Scanner", "Disarmer" } }
	self.IconFrame[10] = { findByName = { "Medikit", "Medical Dart Gun", "First Aid Kit", "Medical Healer Mk3" } } --findByGroup = {"Tools - Healing"}
	--self.IconFrame[11] = {findByName = {"Grapple Gun", "Warp Grenade", "Dov Translocator", "Feather"}}

	self.RankShadeIcon = CreateMOSRotating("Icon_Rank_Shade", self.ModuleName)
	self.RankBaseIcon = CreateMOSRotating("Icon_Rank_Base", self.ModuleName)
	self.RankRaisedIcon = CreateMOSRotating("Icon_Rank_Raised", self.ModuleName)
	self.RankEmbossedIcon = CreateMOSRotating("Icon_Rank_Embossed", self.ModuleName)
	self.xpSound = CreateSoundContainer("Geiger Click", "Base.rte")
	self.levelUpSound = CreateSoundContainer("Confirm", "Base.rte")
	-- Typing
	CF.TypingActor = nil
	CF.TypingPlayer = nil
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
	}
	self.nameString = {}
	self.actorList = {}
	self.killClaimRange = 50 + (FrameMan.PlayerScreenWidth + FrameMan.PlayerScreenHeight) * 0.3
	
	self.IsInitialized = true
	self.BrainsAtStake = true
end
-----------------------------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	if not self.IsInitialized then
		--Init mission
		print("Void Wanderers: Start activity via update.")
		self:StartActivity(true)
	end

	self:ClearObjectivePoints()

	-- Add any gold gained in-game
	local realGold = self:GetTeamFunds(CF.PlayerTeam)
	if realGold ~= CF.GetPlayerGold(self.GS) then
		CF.SetPlayerGold(self.GS, realGold)
	end

	for i = 1, #self.actorList do
		local victim = self.actorList[i]
		if victim and not MovableMan:IsActor(victim.Pointer) then
			--print(victim.Value .. " of value dead at (" .. math.floor(victim.ViewPoint.X + 0.5) .. ", " .. math.floor(victim.ViewPoint.Y + 0.5) .. ")!")
			local dist = Vector()
			local gain = victim.Team == -1 and 0 or 1
			-- Give automatic reward to the first actor up-close to the enemy
			local killer = MovableMan:GetClosestEnemyActor(victim.Team, victim.ViewPoint, 50, dist)
			if killer and self:IsPlayerUnit(killer) then
				gain = gain
					+ victim.Value
						/ (10 + math.abs(killer:GetGoldValue(0, 0.2, 0.2)))
						* (3 - math.min(
							killer.Health / killer.MaxHealth + dist.Magnitude / self.killClaimRange,
							2
						))
				self:GiveXP(killer, gain)
			elseif killer == nil or killer.Team == CF.PlayerTeam or killer.Team == Activity.NOTEAM then
				-- Share XP between nearby actors
				local killerCandidates = {}
				for actor in MovableMan.Actors do
					if self:IsPlayerUnit(actor) then
						dist = SceneMan:ShortestDistance(actor.ViewPoint, victim.ViewPoint, SceneMan.SceneWrapsX)
						if dist:MagnitudeIsLessThan(self.killClaimRange) then
							-- Check for some possible terrain obstructances that will diminish the probability of claiming a kill
							local obstructionTotal = 0
							if dist:MagnitudeIsGreaterThan(actor.Radius) then
								local checkPos = { actor.ViewPoint + dist * 0.2, victim.ViewPoint - dist * 0.2 }
								for i = 1, #checkPos do
									obstructionTotal = obstructionTotal
										+ math.floor(
											SceneMan:GetMaterialFromID(
												SceneMan:GetTerrMatter(checkPos[i].X, checkPos[i].Y)
											).StructuralIntegrity ^ 0.5
										)
								end
							end
							table.insert(
								killerCandidates,
								{ killer = actor, dist = dist.Magnitude + obstructionTotal }
							)
						end
					end
				end
				for _, actor in pairs(killerCandidates) do
					local sharedGain = gain
						+ (
								victim.Value
								/ (10 + math.abs(actor.killer:GetGoldValue(0, 0.2, 0.2)))
								* (
									3
									- math.min(
										actor.killer.Health / actor.killer.MaxHealth
											+ actor.dist / self.killClaimRange,
										2
									)
								)
							)
							/ #killerCandidates
					self:GiveXP(actor.killer, sharedGain)
				end
			end
		end
		self.actorList[i] = nil
	end
	for actor in MovableMan.Actors do
		local isFriendly = actor.Team == CF.PlayerTeam
		if not isFriendly then
			if actor.Pos.Y > 0 then
				-- Save enemy actors in an external table to track their disappearance
				if not actor:NumberValueExists("VW_FragValue") then
					local fragValue = math.abs(actor:GetGoldValue(0, 1, 1))
					if fragValue > 0 then
						--[[
						if IsAHuman(actor) and ToAHuman(actor).EquippedItem then
							fragValue = fragValue + ToAHuman(actor).EquippedItem:GetGoldValue(0, 0.5, 0.5)
						end
						]]
						--
						local rank = actor:GetNumberValue("VW_Rank")
						actor:SetNumberValue("VW_FragValue", rank + fragValue * (1 + rank / #CF.Ranks))
					end
				end
				self.actorList[#self.actorList + 1] = {
					Pointer = actor,
					Team = actor.Team,
					Value = actor:GetNumberValue("VW_FragValue"),
					ViewPoint = Vector(actor.ViewPoint.X, actor.ViewPoint.Y),
				}
			end
		elseif
			actor:IsPlayerControlled()
			and self:IsCommander(actor)
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
		-- Display icons
		if CF.EnableIcons then
			if
				actor.HUDVisible
				and (isFriendly or SettingsMan.ShowEnemyHUD)
				and not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam)
			then
				local cont = actor:GetController()
				local pieMenuOpen = cont:IsState(Controller.PIE_MENU_ACTIVE)
				local prestige = actor:GetNumberValue("VW_Prestige")
				local rank = actor:GetNumberValue("VW_Rank")
				local name = actor:GetStringValue("VW_Name")
				local velOffset = actor.Vel * rte.PxTravelledPerFrame
				local offsetY = (actor:IsPlayerControlled() and actor.ItemInReach) and -8 or -1
				local nameToDisplay = (name and name ~= "") or (CF.TypingActor and CF.TypingActor.ID == actor.ID);

				if (not nameToDisplay) and isFriendly then
					local icons = {}
					if self:IsAlly(actor) then
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
				if not actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") and (rank > 0 or actor.Team == CF.PlayerTeam) then
					-- Get a reasonable position for the overhead, and the whose player it is,
					local aboveHeadPos = actor.Pos + velOffset + Vector(-20, 8 - actor.Height * 0.5);
					local actorPlayer = actor:GetController().Player;

					-- Then if we're not user controlled, all players have the same regular view,
					if actorPlayer == Activity.PLAYER_NONE then
						self:DrawRankIcon(actorPlayer, aboveHeadPos, rank, prestige);
						PrimitiveMan:DrawTextPrimitive(
							actorPlayer,
							actor.AboveHUDPos + velOffset + Vector(1, offsetY - 7),
							name,
							false,
							1
						);
					else
						-- Otherwise, display in the top left for the controlling player, and regularly otherwise.
						for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
							if actorPlayer == player then
								camOff = CameraMan:GetOffset(player);

								local progress = prestige > 0 and ("+" .. prestige) or "";
								local pos = camOff + Vector(27, 12) + Vector(56, 0);
								PrimitiveMan:DrawTextPrimitive(player, pos, progress, false, 0);
								pos = camOff + Vector(27, 24);
								PrimitiveMan:DrawTextPrimitive(player, pos, name, false, 0);

								local start, stop = camOff + Vector(28, 17), camOff + Vector(28, 17) + Vector(50, 6);
								PrimitiveMan:DrawBoxFillPrimitive(player, start, stop, 80);
								start, stop = camOff + Vector(27, 16), camOff + Vector(27, 16) + Vector(50, 6);
								PrimitiveMan:DrawBoxFillPrimitive(player, start, stop, 118);
								start, stop = camOff + Vector(28, 17), camOff + Vector(28, 17) + Vector(48, 4);
								PrimitiveMan:DrawBoxFillPrimitive(player, start, stop, 80);

								local capped = CF.Ranks[rank + 1] == nil;
								local progress = capped and 1 or (actor:GetNumberValue("VW_XP") - (CF.Ranks[rank] or 0)) / (CF.Ranks[rank + 1] - (CF.Ranks[rank] or 0));
								
								for i = 1, math.floor(progress * 24) do
									local display = (not capped) or ((self.SceneTimer.ElapsedSimTimeMS + i / 24 * 1500) % 1500 < 750);
									if display then
										PrimitiveMan:DrawBoxFillPrimitive(
											player,
											camOff + Vector(27 + 2*i, 18),
											camOff + Vector(27 + 2*i, 18) + Vector(0, 2),
											71
										);
										PrimitiveMan:DrawBoxFillPrimitive(
											player,
											camOff + Vector(27 + 2*i, 19),
											camOff + Vector(27 + 2*i, 19),
											118
										);
									end
								end
								self:DrawRankIcon(
									player,
									camOff + Vector(19, 20),
									rank,
									prestige
								);
							else
								self:DrawRankIcon(player, aboveHeadPos, rank, prestige);
								PrimitiveMan:DrawTextPrimitive(
									player,
									actor.AboveHUDPos + velOffset + Vector(1, offsetY - 7),
									name,
									false,
									1
								);
							end
						end
					end
				end
			end
		end

		-- Enable prestige where needed
		local actorMaxxed = actor:GetNumberValue("VW_XP") >= CF.Ranks[#CF.Ranks];
		if actorMaxxed or actor:GetNumberValue("VW_Prestige") >= 1 then
			local pie = actor.PieMenu:GetFirstPieSliceByPresetName(CF.PrestigeSlice.PresetName);
			if not pie then
				actor.PieMenu:AddPieSliceIfPresetNameIsUnique(CF.PrestigeSlice:Clone(), self);
				pie = actor.PieMenu:GetFirstPieSliceByPresetName(CF.PrestigeSlice.PresetName);
			end
			if pie then
				pie.Enabled = actorMaxxed;
			end
		end

		-- Process prestige request
		if actorMaxxed and actor:NumberValueExists("VW_AttemptPrestige") then
			actor:RemoveNumberValue("VW_AttemptPrestige");
			actor:RemoveWounds(actor.WoundCount);
			actor.Health = actor.MaxHealth;

			CF.UnBuffActor(actor, actor:GetNumberValue("VW_Rank"), actor:GetNumberValue("VW_Prestige"));
			actor:SetNumberValue("VW_XP", 0);
			actor:SetNumberValue("VW_Rank", 0);
			actor:SetNumberValue("VW_Prestige", actor:GetNumberValue("VW_Prestige") + 1);
			CF.BuffActor(actor, actor:GetNumberValue("VW_Rank"), actor:GetNumberValue("VW_Prestige"));
			local cont = actor:GetController();
			if cont:IsMouseControlled() or cont:IsKeyboardOnlyControlled() then
				CF.SetNamingActor(actor, cont.Player);
			end
		end

		self:LevelUp(actor);
	end

	if self.encounterData["initialized"] then
		self:EncounterUpdate()
		-- If encounter was finished then remove turrets
		if self.encounterData["encounterConcluded"] == true then
			self.encounterData = {}
			self.EncounterUpdate = nil
			self.EncounterCreate = nil
		end
	end

	if self.missionData["initialized"] then
		self:ProcessLZControlPanelUI()

		if self.AmbientUpdate ~= nil then
			self:AmbientUpdate()
		end

		if self.MissionUpdate ~= nil then
			self:MissionUpdate()
		end

		-- Make actors glitch if there are too many of them
		local count = 0
		local braincount = 0
		local actorList = {}
		for actor in MovableMan.Actors do
			table.insert(actorList, actor)
		end
		for actor in MovableMan.AddedActors do
			table.insert(actorList, actor)
		end
		for _, actor in ipairs(actorList) do
			if
				actor.Team == CF.PlayerTeam
				and actor.ClassName ~= "Actor"
				and actor.ClassName ~= "ADoor"
				and not self:IsAlly(actor)
			then
				count = count + 1

				if
					self.GS["BrainsOnMission"] ~= "True"
					and self.Time % 4 == 0
					and count > tonumber(self.GS["PlayerVesselCommunication"])
					and actor:GetNumberValue("VW_Prestige") == 0
				then
					local cont = actor:GetController()
					--[[
					if math.random() < 0.1 then
						if cont:IsState(Controller.WEAPON_FIRE) then
							cont:SetState(Controller.WEAPON_FIRE, false)
						else
							cont:SetState(Controller.WEAPON_FIRE, true)
						end
					end
					]]
					--
					if cont:IsState(Controller.BODY_JUMP) then
						cont:SetState(Controller.BODY_JUMP, false)
						cont:SetState(Controller.BODY_JUMPSTART, false)
						cont:SetState(Controller.BODY_CROUCH, true)
					elseif cont:IsState(Controller.BODY_CROUCH) then
						cont:SetState(Controller.BODY_JUMP, true)
						cont:SetState(Controller.BODY_CROUCH, false)
					end
					if cont:IsState(Controller.MOVE_LEFT) then
						cont:SetState(Controller.MOVE_LEFT, false)
						cont:SetState(Controller.MOVE_RIGHT, true)
					elseif cont:IsState(Controller.MOVE_RIGHT) then
						cont:SetState(Controller.MOVE_RIGHT, false)
						cont:SetState(Controller.MOVE_LEFT, true)
					end
					if cont:IsState(Controller.WEAPON_PICKUP) then
						cont:SetState(Controller.WEAPON_PICKUP, false)
						cont:SetState(Controller.WEAPON_DROP, true)
					elseif cont:IsState(Controller.WEAPON_DROP) then
						cont:SetState(Controller.WEAPON_DROP, false)
						cont:SetState(Controller.WEAPON_PICKUP, true)
					end

					self:AddObjectivePoint("CONNECTION LOST", actor.AboveHUDPos, CF.PlayerTeam, GameActivity.ARROWUP)
				end
				if (actor:GetNumberValue("VW_BrainOfPlayer") - 1) ~= Activity.PLAYER_NONE then
					braincount = braincount + 1
				end
			end
		end

		-- Check losing conditions
		if self.GS["BrainsOnMission"] == "True" and self.BrainsAtStake and self.ActivityState ~= Activity.OVER then
			if
				braincount < self.PlayerCount
				and self.Time > self.missionData["missionStartTime"] + 1
			then
				self.WinnerTeam = CF.CPUTeam
				ActivityMan:EndActivity()
				self:StartMusic(CF.MusicTypes.DEFEAT)
			end
		end
	end

	-- Clear the banner if there are brains
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT do
		if self:GetPlayerBrain(player) then
			self:GetBanner(GUIBanner.RED, player):ClearText()
		end
	end
	
	-- Generate artificial gravity inside the ship
	if self.vesselData["initialized"] then
		self:ProcessClonesControlPanelUI()
		self:ProcessStorageControlPanelUI()
		self:ProcessBrainControlPanelUI()
		self:ProcessTurretsControlPanelUI()
		self:ProcessShipControlPanelUI()
		self:ProcessBeamControlPanelUI()
		self:ProcessItemShopControlPanelUI()
		self:ProcessCloneShopControlPanelUI()

		local flightSpeed = tonumber(self.GS["PlayerVesselSpeed"])
		local engineBurst = false
		local engineBoost = 0

		-- Fly to new location
		if self.GS["Destination"] ~= nil and not self.vesselData["flightDisabled"] then
			local dx = tonumber(self.GS["DestX"])
			local dy = tonumber(self.GS["DestY"])

			local sx = tonumber(self.GS["ShipX"])
			local sy = tonumber(self.GS["ShipY"])

			local d = CF.Dist(Vector(sx, sy), Vector(dx, dy))
			self.GS["Distance"] = d

			if d <= 0.5 then
				self.GS["Location"] = self.GS["Destination"]
				self.GS["Destination"] = nil

				local locpos = CF.LocationPos[self.GS["Location"]] or Vector()

				self.GS["ShipX"] = locpos.X
				self.GS["ShipY"] = locpos.Y
			else
				engineBurst = true
				engineBoost = flightSpeed

				if not self.vesselData["flightAimless"] then
					self:AttemptRandomEncounter()

					self.GS["ShipX"] = sx + (dx - sx) / d * (flightSpeed / CF.KmPerPixel)
					self.GS["ShipY"] = sy + (dy - sy) / d * (flightSpeed / CF.KmPerPixel)
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
			local scroll = background.AutoScrollStepX
			background.AutoScrollStepX = scroll + math.min(acceleration, math.max(-acceleration, targetVel - scroll))
		end

		-- Create or delete shops if we arrived/departed to/from Star base
		if
			CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR)
			or CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET)
		then
			if not self.ShopsCreated then
				-- Destroy any previously created item shops and create a new one
				self:DestroyItemShopControlPanelUI()
				self:DestroyCloneShopControlPanelUI()
				self:InitItemShopControlPanelUI()
				self:InitCloneShopControlPanelUI()
				self.ShopsCreated = true
				self:StartMusic(CF.MusicTypes.COMMERCE)
			end
		else
			if self.ShopsCreated then
				self:DestroyItemShopControlPanelUI()
				self:DestroyCloneShopControlPanelUI()
				self.ShopsCreated = false
				self:StartMusic(CF.MusicTypes.SHIP_CALM)
			end
		end

		-- Auto heal all actors when not in combat or random encounter
		local overCrowded = CF.CountActors(CF.PlayerTeam) > tonumber(self.GS["PlayerVesselLifeSupport"]);
		if overCrowded then
			local count = CF.CountActors(CF.PlayerTeam) - tonumber(self.GS["PlayerVesselLifeSupport"])
			local s = count == 1 and "BODY" or "BODIES"

			FrameMan:ClearScreenText(0)
			FrameMan:SetScreenText(
				"LIFE SUPPORT OVERLOADED\nSTORE OR DUMP "
					.. count
					.. " "
					.. s,
				0,
				0,
				1000,
				true
			)

			self:MakeAlertSound(0.25)
		end

		for actor in MovableMan.Actors do
			local sentient = actor.ClassName == "AHuman" or actor.ClassName == "ACrab"
			
			if sentient then
				local ourTeam = actor.Team == CF.PlayerTeam;
				local spaceWalking = not self.vesselData["ship"]:IsInside(actor.Pos) and not self.vesselData["spaceDeck"]:IsInside(actor.Pos)

				if overCrowded or spaceWalking then
					actor.Health = actor.Health - 1 / math.sqrt(1 + math.abs(actor.Mass + actor.Material.StructuralIntegrity))
					-- Kill all actors outside the ship
					if spaceWalking and ourTeam then
						if not self.flyPhase then
							self.flyPhase = {}
						end
						self.flyPhase[#self.flyPhase] = { actor }
					end
				else
					if actor.Health > 0 and actor.Health < actor.MaxHealth and ourTeam then
						actor.Health = math.min(actor.Health + 0.1, actor.MaxHealth)
					end
				end
			end
		end

		local coll = { MovableMan.Actors, MovableMan.Items, MovableMan.Particles }
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
														:ShortestDistance(actor.Pos, checkPos, SceneMan.SceneWrapsX)
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
		self.Time = self.Time + 1
		self.GS["Time"] = tostring(self.Time)
		self.TickTimer:Reset()

		-- Give passive experience points for non-brain actors
		for actor in MovableMan.Actors do
			if self:IsPlayerUnit(actor) then
				local damage = (actor.PrevHealth - actor.Health) / actor.MaxHealth

				local gains = damage * math.sqrt(25 + (actor.Vel + actor.PrevVel).Magnitude)
				if gains >= 1 then
					self:GiveXP(actor, gains)
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
	
	if CF.TypingActor and MovableMan:IsActor(CF.TypingActor) and CF.TypingPlayer then
		local screen = self:ScreenOfPlayer(CF.TypingPlayer)
		CameraMan:SetScrollTarget(
			CF.TypingActor.AboveHUDPos + CF.TypingActor.Vel * rte.PxTravelledPerFrame + Vector(1, 22),
			1,
			screen
		)
		local controlledActor = self:GetControlledActor(CF.TypingPlayer)
		local controller = controlledActor:GetController()
		for i = 0, Controller.CONTROLSTATECOUNT - 1 do -- Go through and disable the gameplay-related controller states
			controller:SetState(i, false)
		end
		if controlledActor.UniqueID ~= CF.TypingActor.UniqueID then
			self:SwitchToActor(CF.TypingActor, controller.Player, controlledActor.Team)
		else
			if UInputMan:AnyPress() then
				for i = 1, #self.keyString do
					if (i == Key.DELETE) and UInputMan:KeyPressed(i) then
						self.nameString = {}
					elseif (i == Key.BACKSPACE) and UInputMan:KeyPressed(i) then
						self.nameString[#self.nameString] = nil
					elseif (i == Key.RETURN) and UInputMan:KeyPressed(i) then
						if
							self.nameString == nil
							or #self.nameString == 0
							or self.nameString[#self.nameString] == ""
						then
							CF.TypingActor:RemoveStringValue("VW_Name")
						else
							CF.TypingActor:SetStringValue("VW_Name", self.nameString[#self.nameString])
						end
						CF.TypingActor:FlashWhite(100)
						CF.TypingActor = nil
						self.nameString = {}
					elseif self.keyString[i] and UInputMan:KeyPressed(i) then
						self.nameString[#self.nameString + 1] = (self.nameString[#self.nameString] or "")
							.. (UInputMan.FlagShiftState and string.upper(self.keyString[i]) or self.keyString[i])
					end
				end
			end
		end
		local nameString = #self.nameString ~= 0 and self.nameString[#self.nameString] or ""
		FrameMan:SetScreenText("> NAME YOUR UNIT <\n" .. nameString, screen, 0, 1, true)
	else
		self.nameString = {}
	end

	self:YSortObjectivePoints()

	for _, set in pairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		-- No dead unit settles immediately and all can carry others, though most can't use it
		if IsAHuman(actor) or IsACrab(actor) then
			actor.RestThreshold = -1;
			if actor:HasScript("VoidWanderers.rte/Scripts/Carry.lua") then
				actor:EnableScript("VoidWanderers.rte/Scripts/Carry.lua");
			else
				actor:AddScript("VoidWanderers.rte/Scripts/Carry.lua");
			end
		end
		-- Activate any added brains
		if actor:NumberValueExists("VW_PreassignedSkills") then
			if actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
				actor:AddScript("VoidWanderers.rte/Scripts/Brain.lua");
				actor.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil);
			else
				actor:EnableScript("VoidWanderers.rte/Scripts/Brain.lua");
			end
		end
		-- Active units of standing have the ability to fix their wounds, I think, forget how that script goes
		if self:IsPlayerUnit(actor) then
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
		if IsActor(particle) then
			actor = ToActor(particle);
			if actor:IsDead() and not actor:NumberValueExists("VW_Passable") then 
				actor:SetNumberValue("VW_Passable", actor.IgnoresActorHits and 1 or 0);
				actor.IgnoresActorHits = true;
			end
		end
	end

	for actor in MovableMan.AddedActors do
		if actor:NumberValueExists("VW_Passable") then 
			actor.IgnoresActorHits = actor:GetNumberValue("VW_Passable") == 1;
			actor:RemoveNumberValue("VW_Passable");
		end
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
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitConsoles()
	self:InitShipControlPanelUI()
	self:InitStorageControlPanelUI()
	self:InitClonesControlPanelUI()
	self:InitBeamControlPanelUI()

	self:InitTurretsControlPanelUI()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyConsoles()
	self:DestroyShipControlPanelUI()
	self:DestroyStorageControlPanelUI()
	self:DestroyClonesControlPanelUI()
	self:DestroyBeamControlPanelUI()

	self:DestroyItemShopControlPanelUI()
	self:DestroyCloneShopControlPanelUI()

	self:DestroyTurretsControlPanelUI()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawIcon(preset, pos)
	if preset then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			PrimitiveMan:DrawBitmapPrimitive(self:ScreenOfPlayer(player), pos, self.Icon, 0, preset)
		end
	end
end
-----------------------------------------------------------------------------------------
-- Draw rank icon via blending primitives with palettes.
-- Palettes are introduced as common RGB byte values that are processed by the loop below.
-----------------------------------------------------------------------------------------
do
	local rankBaseColor = {
		{72,40,8},
		{56,8,8},
		{24,44,8},
		{8,8,40},
		{56,40,56},
		{8,24,40},
		{80,20,40},
		{56,8,8}
	}
	local rankRaisedColor = {
		{250,234,121},
		{230,24,8},
		{121,178,68},
		{125,190,246},
		{218,218,226},
		{76,238,255},
		{218,218,226},
		{234,153,28}
	}
	local rankEmbossColor = {
		{198,133,64},
		{170,24,8},
		{109,121,20},
		{52,113,198},
		{165,170,170},
		{52,113,198},
		{170,93,101},
		{170,24,8}
	}

	for _, part in pairs{ rankBaseColor, rankRaisedColor, rankEmbossColor } do
		for _, palette in pairs(part) do
			for channel = 1, #palette do
				palette[channel] = (1 - palette[channel] / 255) * 100
			end
		end
	end

	function VoidWanderers:DrawRankIcon(player, pos, rank, prestige)
		player = player or Activity.PLAYER_NONE;
		if rank then
			local p = math.min(prestige + 1, 8)
			local primitive = BitmapPrimitive(player, pos, self.RankShadeIcon, 0, rank, false, false)
			PrimitiveMan:DrawPrimitives(DrawBlendMode.NoBlend, 000, 000, 000, 0, { primitive })

			local pal = rankBaseColor
			primitive = BitmapPrimitive(player, pos, self.RankBaseIcon, 0, rank, false, false)
			PrimitiveMan:DrawPrimitives(DrawBlendMode.Transparency, pal[p][1], pal[p][2], pal[p][3], 0, { primitive })
		
			pal = rankRaisedColor
			primitive = BitmapPrimitive(player, pos, self.RankRaisedIcon, 0, rank, false, false)
			PrimitiveMan:DrawPrimitives(DrawBlendMode.Transparency, pal[p][1], pal[p][2], pal[p][3], 0, { primitive })
		
			pal = rankEmbossColor
			primitive = BitmapPrimitive(player, pos, self.RankEmbossedIcon, 0, rank, false, false)
			PrimitiveMan:DrawPrimitives(DrawBlendMode.Transparency, pal[p][1], pal[p][2], pal[p][3], 0, { primitive })
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveXP(actor, xp)
	if actor then
		xp = math.floor(xp / math.sqrt(1 + actor:GetNumberValue("VW_Prestige")) + 0.5);

		if xp > 0 then
			self.xpSound:Play(actor.Pos);
			local newXP = actor:GetNumberValue("VW_XP") + xp;
			actor:SetNumberValue("VW_XP", newXP);

			local levelup = self:LevelUp(actor);

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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:LevelUp(actor)
	if actor then
		local experience = actor:GetNumberValue("VW_XP");
		local rank = actor:GetNumberValue("VW_Rank");
		local levelup = false;
		local nextRank = CF.Ranks[rank + 1];

		while nextRank and experience >= nextRank do
			levelup = true;
			rank = rank + 1;
			nextRank = CF.Ranks[rank + 1];
		end

		if levelup then
			if not self.levelUpSound:IsBeingPlayed() then
				self.levelUpSound:Play(actor.Pos);
			end

			actor:SetNumberValue("VW_Rank", rank);
			actor:FlashWhite(50);
			actor.Health = math.min(actor.Health * 1.5, actor.MaxHealth);
			return true;
		end
	end

	return false;
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:PutGlow(preset, pos)
	local glow = CreateMOPixel(preset, self.ModuleName)
	if glow then
		glow.Pos = pos
		MovableMan:AddParticle(glow)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:PutGlowWithModule(preset, pos, module)
	local glow = CreateMOPixel(preset, module)
	if glow then
		glow.Pos = pos
		MovableMan:AddParticle(glow)
	end
end
-----------------------------------------------------------------------------------------
-- Removes specified item from actor's inventory, returns number of removed items
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AttemptRandomEncounter()
	if not CF.RandomEncountersEnabled then
		return
	end

	local potentialEncounters = {}

	if self.encounterEnableTime < self.Time then
		for i, name in ipairs(CF.RandomEncounters) do
			local eligibilityTest = CF.RandomEncounterEligibilityTests[name]
			if eligibilityTest then
				if eligibilityTest(self) == true then
					table.insert(potentialEncounters, name)
				end
			end
		end
	end

	-- Trigger random encounter if there are any eligible to occur
	if next(potentialEncounters) and math.random() < CF.RandomEncounterProbability then
		local encounter = potentialEncounters[math.random(#potentialEncounters)]

		-- Launch encounter
		if encounter ~= nil then
			-- Generic encounter data, some may be overwritten
			self.encounterData = {}
			self.encounterData["initialized"] = true
			self.encounterData["encounterName"] = encounter
			self.encounterData["encounterStartTime"] = self.Time
			self.encounterData["scriptPath"] = CF.RandomEncounterScripts[encounter]
			self.encounterData["encounterConcluded"] = false

			dofile(self.encounterData["scriptPath"])
			self:EncounterCreate()
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveFocusToBridge()
	local bridgeempty = true
	local plrtoswitch = Activity.PLAYER_NONE

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

	if plrtoswitch ~= Activity.PLAYER_NONE and bridgeempty and MovableMan:IsActor(self.ShipControlPanelActor) then
		self:SwitchToActor(self.ShipControlPanelActor, plrtoswitch, CF.PlayerTeam)
	end
	self.ShipControlMode = self.ShipControlPanelModes.REPORT
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SendTransmission(message, options)
	self.vesselData["dialog"] = { message=message, options=options }
	self.vesselData["dialogDefaultTimer"]:Reset()
	self.vesselData["dialogOptionSelected"] = 1
	self.vesselData["dialogOptionChosen"] = 0
	
	self:GiveFocusToBridge()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SpawnViaTable(nm)
	local actor = CF.SpawnAIUnitWithPreset(
		self.GS,
		nm["Player"],
		nm["Team"],
		nm["Pos"],
		nm["AIMode"],
		nm["Preset"]
	)

	if actor then
		if nm["Name"] and not actor:StringValueExists("VW_Name") then
			actor:SetStringValue("VW_Name", nm["Name"])
		end

		-- Give diggers of required
		if nm["Digger"] then
			local diggers = CF.MakeListOfMostPowerfulWeapons(
				self.GS,
				nm["Player"],
				CF.WeaponTypes.DIGGER,
				10000
			)

			if diggers ~= nil then
				local r = math.random(#diggers)
				local itm = diggers[r]["Item"]
				local fct = diggers[r]["Faction"]

				local pre = CF.ItmPresets[fct][itm]
				local cls = CF.ItmClasses[fct][itm]
				local mdl = CF.ItmModules[fct][itm]

				local newitem = CF.MakeItem(pre, cls, mdl)

				if newitem then
					actor:AddInventoryItem(newitem)
				end
			end
		end

		if nm["Ally"] then
			self:SetAlly(actor, true)
		end

		actor.HFlipped = math.random() < 0.5
		MovableMan:AddActor(actor)
	end

	return actor
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ClearActors()
	self.onboardActors = {};

	for i = 1, CF.MaxSavedActors do
		self.GS["Actor" .. i .. "Preset"] = nil;
		self.GS["Actor" .. i .. "Class"] = nil;
		self.GS["Actor" .. i .. "Module"] = nil;
		self.GS["Actor" .. i .. "X"] = nil;
		self.GS["Actor" .. i .. "Y"] = nil;
		self.GS["Actor" .. i .. "XP"] = nil;
		self.GS["Actor" .. i .. "Identity"] = nil;
		self.GS["Actor" .. i .. "Player"] = nil;
		self.GS["Actor" .. i .. "Prestige"] = nil;
		self.GS["Actor" .. i .. "Name"] = nil;

		for j = 1, #CF.LimbID do
			self.GS["Actor" .. i .. CF.LimbID[j]] = nil;
		end

		for j = 1, CF.MaxSavedItemsPerActor do
			self.GS["Actor" .. i .. "Item" .. j .. "Preset"] = nil;
			self.GS["Actor" .. i .. "Item" .. j .. "Class"] = nil;
			self.GS["Actor" .. i .. "Item" .. j .. "Module"] = nil;
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveActors(clearpos)
	self:ClearActors();

	local savedactor = 1;

	for actor in MovableMan.Actors do
		if actor.PresetName ~= "Brain Case" and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
			local pre, cls, mdl = CF.GetInventory(actor);

			-- Save actors to config
			self.GS["Actor" .. savedactor .. "Preset"] = actor.PresetName;
			self.GS["Actor" .. savedactor .. "Class"] = actor.ClassName;
			self.GS["Actor" .. savedactor .. "Module"] = actor.ModuleName;
			self.GS["Actor" .. savedactor .. "XP"] = actor:GetNumberValue("VW_XP");
			self.GS["Actor" .. savedactor .. "Identity"] = actor:GetNumberValue("Identity");
			self.GS["Actor" .. savedactor .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer");
			self.GS["Actor" .. savedactor .. "Prestige"] = actor:GetNumberValue("VW_Prestige");
			self.GS["Actor" .. savedactor .. "Name"] = actor:GetStringValue("VW_Name");
			for j = 1, #CF.LimbID do
				self.GS["Actor" .. savedactor .. CF.LimbID[j]] = CF.GetLimbData(actor, j);
			end

			if not clearpos then
				self.GS["Actor" .. savedactor .. "X"] = math.floor(actor.Pos.X);
				self.GS["Actor" .. savedactor .. "Y"] = math.floor(actor.Pos.Y);
			end

			for j = 1, #pre do
				self.GS["Actor" .. savedactor .. "Item" .. j .. "Preset"] = pre[j];
				self.GS["Actor" .. savedactor .. "Item" .. j .. "Class"] = cls[j];
				self.GS["Actor" .. savedactor .. "Item" .. j .. "Module"] = mdl[j];
			end

			self.onboardActors[savedactor] = actor;
			savedactor = savedactor + 1;
		end
	end

	for _, actor in pairs(self.onboardActors) do
		self.onboardActors[_] = MovableMan:RemoveActor(actor);
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ClearDeployed()
	self.deployedActors = {};
	for i = 1, CF.MaxSavedActors do
		self.GS["Deployed" .. i .. "Preset"] = nil
		self.GS["Deployed" .. i .. "Class"] = nil
		self.GS["Deployed" .. i .. "Module"] = nil
		self.GS["Deployed" .. i .. "X"] = nil
		self.GS["Deployed" .. i .. "Y"] = nil
		self.GS["Deployed" .. i .. "XP"] = nil
		self.GS["Deployed" .. i .. "Identity"] = nil
		self.GS["Deployed" .. i .. "Player"] = nil
		self.GS["Deployed" .. i .. "Prestige"] = nil
		self.GS["Deployed" .. i .. "Name"] = nil

		for j = 1, #CF.LimbID do
			self.GS["Deployed" .. i .. CF.LimbID[j]] = nil
		end

		for j = 1, CF.MaxSavedItemsPerActor do
			self.GS["Deployed" .. i .. "Item" .. j .. "Preset"] = nil
			self.GS["Deployed" .. i .. "Item" .. j .. "Class"] = nil
			self.GS["Deployed" .. i .. "Item" .. j .. "Module"] = nil
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
--[[function VoidWanderers:SaveDeployed(clearpos)
	self:ClearDeployed()

	local saveddeployed = 0

	for actor in MovableMan.Actors do
		if actor.PresetName ~= "Brain Case" and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
			local pre, cls, mdl = CF.GetInventory(actor)

			saveddeployed = saveddeployed + 1

			-- Save actors to config
			self.GS["Deployed" .. saveddeployed .. "Preset"] = actor.PresetName
			self.GS["Deployed" .. saveddeployed .. "Class"] = actor.ClassName
			self.GS["Deployed" .. saveddeployed .. "Module"] = actor.ModuleName
			self.GS["Deployed" .. saveddeployed .. "XP"] = actor:GetNumberValue("VW_XP")
			self.GS["Deployed" .. saveddeployed .. "Identity"] = actor:GetNumberValue("Identity")
			self.GS["Deployed" .. saveddeployed .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
			self.GS["Deployed" .. saveddeployed .. "Prestige"] = actor:GetNumberValue("VW_Prestige")
			self.GS["Deployed" .. saveddeployed .. "Name"] = actor:GetStringValue("VW_Name")
			for j = 1, #CF.LimbID do
				self.GS["Deployed" .. saveddeployed .. CF.LimbID[j] ] = CF.GetLimbData(actor, j)
			end

			if clearpos then
				self.GS["Deployed" .. saveddeployed .. "X"] = nil
				self.GS["Deployed" .. saveddeployed .. "Y"] = nil
			else
				self.GS["Deployed" .. saveddeployed .. "X"] = math.floor(actor.Pos.X)
				self.GS["Deployed" .. saveddeployed .. "Y"] = math.floor(actor.Pos.Y)
			end

			for j = 1, #pre do
				self.GS["Deployed" .. saveddeployed .. "Item" .. j .. "Preset"] = pre[j]
				self.GS["Deployed" .. saveddeployed .. "Item" .. j .. "Class"] = cls[j]
				self.GS["Deployed" .. saveddeployed .. "Item" .. j .. "Module"] = mdl[j]
			end
		end
	end
end]]--
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if orbitedCraft.Team == CF.PlayerTeam and orbitedCraft:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
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
				if self:IsAlly(actor) then
					assignable = false
				end

				self:ClearDeployed()
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
					
					for j = 1, #CF.LimbID do
						self.GS["Deployed" .. i .. CF.LimbID[j]] = CF.GetLimbData(actor, j)
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
-----------------------------------------------------------------------------------------
-- Find and assign player brains, for loaded games.
-----------------------------------------------------------------------------------------
function VoidWanderers:LocatePlayerBrains(swapToBrains, initPieMenu)
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			for actor in MovableMan.AddedActors do
				if actor:GetNumberValue("VW_BrainOfPlayer") - 1 == player then
					self:SetPlayerBrain(actor, player)
					if swapToBrains then
						self:SwitchToActor(actor, player, CF.PlayerTeam)
					end
					self.PlayersWithBrains[player + 1] = true
					if initPieMenu then
						actor.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil)
						if actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
							actor:EnableScript("VoidWanderers.rte/Scripts/Brain.lua")
						else
							actor:AddScript("VoidWanderers.rte/Scripts/Brain.lua")
						end
					end
					self:GetBanner(GUIBanner.RED, player):ClearText()
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GetItemPrice(itmpreset, itmclass)
	local price = 0

	for f = 1, #CF.Factions do
		local ff = CF.Factions[f]
		for i = 1, #CF.ItmNames[ff] do
			local class = CF.ItmClasses[ff][i]
			if class == nil then
				class = "HDFirearm"
			end

			if itmclass == class and itmpreset == CF.ItmPresets[ff][i] then
				return CF.ItmPrices[ff][i]
			end
		end
	end

	return price
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawDottedLine(x1, y1, x2, y2, dot, interval)
	local d = CF.Dist(Vector(x1, y1), Vector(x2, y2))

	local ax = (x2 - x1) / d * interval
	local ay = (y2 - y1) / d * interval

	local x = x1
	local y = y1

	d = math.floor(d)

	for i = 1, d, interval do
		self:PutGlowWithModule(dot, Vector(x, y), self.ModuleName)

		x = x + ax
		y = y + ay
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawWanderingDottedLine(x1, y1, x2, y2, dot, interval, w, p, scale)
	local d = CF.Dist(Vector(x1, y1), Vector(x2, y2))
	local t = 0

	local startOffsetX, startOffsetY = -math.cos(p) * scale, -math.sin(p) * scale
	local endOffsetX, endOffsetY = -math.cos(p + w) * scale, -math.sin(p + w) * scale

	while t < 1 do
		local pos = Vector(
			x1 + (x2 - x1) * t + startOffsetX + (endOffsetX - startOffsetX) * t + math.cos(p + w * t) * scale,
			y1 + (y2 - y1) * t + startOffsetY + (endOffsetY - startOffsetY) * t + math.sin(p + w * t) * scale
		)

		self:PutGlowWithModule(dot, pos, self.ModuleName)

		t = t + interval / math.min(math.abs(math.sqrt(
			((x2 - x1) + (endOffsetX - startOffsetX) - math.sin(p + w * t) * w * scale) ^ 2 +
			((y2 - y1) + (endOffsetY - startOffsetY) + math.cos(p + w * t) * w * scale) ^ 2
		)), d)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DeployGenericMissionEnemies(setnumber, setname, plr, team, spawnrate)
	-- Define spawn queue
	local dq = {}
	-- Defenders aka turrets if any
	dq[1] = {}
	dq[1]["Preset"] = CF.PresetTypes.DEFENDER
	dq[1]["PointName"] = "Defender"

	-- Snipers
	dq[2] = {}
	dq[2]["Preset"] = CF.PresetTypes.SNIPER
	dq[2]["PointName"] = "Sniper"

	-- Heavies
	dq[3] = {}
	dq[3]["Preset"] = math.random() < 0.5 and CF.PresetTypes.HEAVY1 or CF.PresetTypes.HEAVY2
	dq[3]["PointName"] = "Heavy"

	-- Shotguns
	dq[4] = {}
	dq[4]["Preset"] = CF.PresetTypes.SHOTGUN
	dq[4]["PointName"] = "Shotgun"

	-- Armored
	dq[5] = {}
	dq[5]["Preset"] = math.random() < 0.5 and CF.PresetTypes.ARMOR1 or CF.PresetTypes.ARMOR2
	dq[5]["PointName"] = "Armor"

	-- Riflemen
	dq[6] = {}
	dq[6]["Preset"] = math.random() < 0.5 and CF.PresetTypes.INFANTRY1 or CF.PresetTypes.INFANTRY2
	dq[6]["PointName"] = "Rifle"

	-- Random
	dq[7] = {}
	dq[7]["Preset"] = nil
	dq[7]["PointName"] = "Any"

	-- Spawn everything
	for d = 1, #dq do
		local fullenmpos = CF.GetPointsArray(self.Pts, setname, setnumber, dq[d]["PointName"])
		local count = math.max(math.floor(spawnrate * #fullenmpos), 1)

		local enmpos = CF.RandomSampleOfList(fullenmpos, count)

		--print (dq[d]["PointName"].." - "..#enmpos.." / ".. #fullenmpos .." - "..spawnrate)

		for i = 1, #enmpos do
			local nw = {}
			if dq[d]["Preset"] == nil then
				nw["Preset"] = math.random(CF.PresetTypes.ARMOR2)
			else
				nw["Preset"] = dq[d]["Preset"]
			end
			nw["Team"] = team
			nw["Player"] = plr
			nw["Pos"] = enmpos[i]
			nw["AIMode"] = Actor.AIMODE_SENTRY
			-- If spawning as player's team then they are allies
			if team == CF.PlayerTeam then
				nw["Ally"] = 1
				-- Set to patrol if there's enough room
			elseif
				SceneMan:CastStrengthRay(
						enmpos[i],
						Vector(50, 0),
						10,
						Vector(),
						10,
						rte.grassID,
						SceneMan.SceneWrapsX
					)
					== false
				and SceneMan:CastStrengthRay(
						enmpos[i],
						Vector(-50, 0),
						10,
						Vector(),
						10,
						rte.grassID,
						SceneMan.SceneWrapsX
					)
					== false
			then
				nw["AIMode"] = Actor.AIMODE_PATROL
			end

			self:SpawnViaTable(nw)
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ObtainBaseBoxes(setname, setnumber)
	-- Get base box
	if self.missionData["initialized"] then
		local bp = CF.GetPointsArray(self.Pts, setname, setnumber, "Base")
		self.missionData["missionBase"] = {}

		for i = 1, #bp, 2 do
			if bp[i + 1] == nil then
				print("OUT OF BOUNDS WHEN BUILDING BASE BOX")
				break
			end

			-- Split the box if we're crossing the seam
			if bp[i].X > bp[i + 1].X then
				local nxt = #self.missionData["missionBase"] + 1
				self.missionData["missionBase"][nxt] = Box(bp[i].X, bp[i].Y, SceneMan.Scene.Width, bp[i + 1].Y)

				local nxt = #self.missionData["missionBase"] + 1
				self.missionData["missionBase"][nxt] = Box(0, bp[i].Y, bp[i + 1].X, bp[i + 1].Y)
			else
				local nxt = #self.missionData["missionBase"] + 1
				self.missionData["missionBase"][nxt] = Box(bp[i].X, bp[i].Y, bp[i + 1].X, bp[i + 1].Y)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DeployInfantryMines(team, rate)
	local points = {}
	for actor in MovableMan.AddedActors do
		if actor.Team == team and IsAHuman(actor) then
			table.insert(points, actor.Pos)
		end
	end
	if false and #points == 0 then
		for _, spawn in pairs(self.SpawnTable) do
			if spawn["Team"] and spawn["Team"] == team and spawn["Pos"] then
				table.insert(points, spawn["Pos"])
			end
		end
	end
	local randomPoints = CF.RandomSampleOfList(points, math.floor(#points * rate + 0.5))
	for _, pos in pairs(randomPoints) do
		local mine = CreateMOSRotating("Anti Personnel Mine Active", "Base.rte")
		mine:AddScript(CF.ModuleName .. "/Objects/MineSet.lua")
		mine.Pos = pos
		mine.Team = team
		mine.Sharpness = team
		mine.IgnoresTeamHits = true
		mine.Vel = Vector(0, 10):RadRotate(RangeRand(-2, 2))
		MovableMan:AddParticle(mine)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveMissionRewards(disablepenalties)
	print("MISSION COMPLETED")
	self.GS["Player" .. self.missionData["missionContractor"] .. "Reputation"] = tonumber(
		self.GS["Player" .. self.missionData["missionContractor"] .. "Reputation"]
	) + self.missionData["reputationReward"]
	if not disablepenalties then
		self.GS["Player" .. self.missionData["missionTarget"] .. "Reputation"] = tonumber(
			self.GS["Player" .. self.missionData["missionTarget"] .. "Reputation"]
		) - math.ceil(self.missionData["reputationReward"] * CF.ReputationPenaltyRatio)
	end
	self:SetTeamFunds(CF.ChangeGold(self.GS, self.missionData["goldReward"]), CF.PlayerTeam)

	-- Refresh Black Market listing after every completed mission
	self.GS["BlackMarket" .. "Station Ypsilon-2" .. "LastRefresh"] = nil

	if self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"] ~= nil then
		local last = tonumber(self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"])
		if (last + CF.BlackMarketRefreshInterval) * RangeRand(0.5, 0.75) < tonumber(self.GS["Time"]) then
			self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"] = nil
		end
	end

	self.MissionReport[#self.MissionReport + 1] = "MISSION COMPLETED"
	if self.missionData["goldReward"] > 0 then
		self.MissionReport[#self.MissionReport + 1] = tostring(self.missionData["goldReward"]) .. "oz of gold received"
	end

	local exppts = math.floor((self.missionData["reputationReward"] + self.missionData["goldReward"]) / 8)

	local levelup = false

	if self.GS["BrainsOnMission"] == "True" then
		levelup = CF.GiveExp(self.GS, exppts)

		self.MissionReport[#self.MissionReport + 1] = tostring(exppts) .. " exp received"
		if levelup then
			local s = ""
			if self.PlayerCount > 1 then
				s = "s"
			end

			self.MissionReport[#self.MissionReport + 1] = "Brain" .. s .. " leveled up!"
		end
	end

	local actors = {}
	for actor in MovableMan.Actors do
		if self:IsPlayerUnit(actor) then
			table.insert(actors, actor)
		end
	end
	CF.MissionCombo = CF.MissionCombo and CF.MissionCombo + 1 or 1
	local comboMult = math.sqrt(CF.MissionCombo)
	if #actors > 0 then
		local gains = (1 + (exppts * 0.1) / #actors) * comboMult
		for _, actor in pairs(actors) do
			self:GiveXP(actor, gains)
		end
	end
	if self.missionData["reputationReward"] > 0 then
		self.MissionReport[#self.MissionReport + 1] = "+"
			.. self.missionData["reputationReward"]
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"])]
			.. " reputation"
		if not disablepenalties then
			self.MissionReport[#self.MissionReport + 1] = "-"
				.. math.ceil(self.missionData["reputationReward"] * CF.ReputationPenaltyRatio)
				.. " "
				.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])]
				.. " reputation"
		end
		if CF.MissionCombo > 1 then
			self.MissionReport[#self.MissionReport + 1] = "Completion streak: "
				.. CF.MissionCombo
				.. " / XP multiplier: "
				.. math.floor(comboMult * 10 + 0.5) * 0.1
				.. "x"
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveMissionPenalties()
	print("MISSION FAILED")
	if self.missionData["missionContractor"] then
		self.GS["Player" .. self.missionData["missionContractor"] .. "Reputation"] = tonumber(
			self.GS["Player" .. self.missionData["missionContractor"] .. "Reputation"]
		) - math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
	end
	if self.missionData["missionTarget"] then
		self.GS["Player" .. self.missionData["missionTarget"] .. "Reputation"] = tonumber(
			self.GS["Player" .. self.missionData["missionTarget"] .. "Reputation"]
		) - math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
	end

	self.MissionReport[#self.MissionReport + 1] = "MISSION FAILED"

	CF.MissionCombo = 0
	local loss = math.floor((self.missionData["reputationReward"] + self.missionData["goldReward"]) * 0.005)
	for actor in MovableMan.Actors do
		if self:IsPlayerUnit(actor) then
			self:GiveXP(actor, -(loss + actor:GetNumberValue("VW_XP") * 0.1))
		end
	end
	if self.missionData["reputationReward"] > 0 then
		self.MissionReport[#self.MissionReport + 1] = "-"
			.. math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionContractor"])]
			.. " reputation"
		self.MissionReport[#self.MissionReport + 1] = "-"
			.. math.ceil(self.missionData["reputationReward"] * CF.MissionFailedReputationPenaltyRatio)
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.missionData["missionTarget"])]
			.. " reputation"
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SetAlly(actor, yes)
	if yes then
		actor:SetNumberValue("VW_Ally", 1)
		actor.PlayerControllable = false
	else
		actor:RemoveNumberValue("VW_Ally")
		actor.PlayerControllable = true
		actor:FlashWhite(50)
	end
end
-----------------------------------------------------------------------------------------
-- Whether an actor is an NPC on the player's team
-----------------------------------------------------------------------------------------
function VoidWanderers:IsAlly(actor)
	return (actor.Team == CF.PlayerTeam and actor:NumberValueExists("VW_Ally"))
end
-----------------------------------------------------------------------------------------
-- Whether an actor is the brain or otherwise prestigious
-----------------------------------------------------------------------------------------
function VoidWanderers:IsCommander(actor)
	return (actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") or actor:GetNumberValue("VW_Prestige") ~= 0)
end
-----------------------------------------------------------------------------------------
-- Whether an actor is a player-controllable, non-brain unit
-----------------------------------------------------------------------------------------
function VoidWanderers:IsPlayerUnit(actor)
	return (IsAHuman(actor) or IsACrab(actor))
		and actor.Team == CF.PlayerTeam
		and not (actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") or self:IsAlly(actor))
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitExplorationPoints()
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Exploration")

	local pts = CF.GetPointsArray(self.Pts, "Exploration", set, "Explore")
	self.missionData["explorationPoint"] = pts[math.random(#pts)]
	self.missionData["explorationRecovered"] = false

	self.missionData["explorationHologram"] = "Holo" .. math.random(CF.MaxHolograms)

	self.missionData["explorationText"] = {}
	self.missionData["explorationTextStart"] = -100

	--print (self.missionData["explorationPoint"])
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessExplorationPoints()
	if self.missionData["explorationPoint"] ~= nil then
		if not self.missionData["explorationRecovered"] then
			if math.random(10) < 7 then
				self:PutGlow(self.missionData["explorationHologram"], self.missionData["explorationPoint"])
			end

			-- Send all units to brainhunt
			for actor in MovableMan.Actors do
				if actor.Team == CF.PlayerTeam and CF.DistUnder(actor.Pos, self.missionData["explorationPoint"], 25) then
					if self:IsCommander(actor) then
						self.missionData["explorationText"] = self:GiveRandomExplorationReward()
						self.missionData["explorationRecovered"] = true

						self.missionData["explorationTextStart"] = self.Time

						for a in MovableMan.Actors do
							if a.Team ~= CF.PlayerTeam then
								CF.HuntForActors(a, CF.PlayerTeam)
							end
						end

						break
					else
						self:AddObjectivePoint(
							"Only a commander can decrypt this holorecord",
							self.missionData["explorationPoint"] + Vector(0, -30),
							CF.PlayerTeam,
							GameActivity.ARROWDOWN
						)
					end
				end
			end
		end
	end

	if self.Time > self.missionData["explorationTextStart"] and self.Time < self.missionData["explorationTextStart"] + 10 then
		local txt = ""
		for i = 1, #self.missionData["explorationText"] do
			txt = self.missionData["explorationText"][i] .. "\n"
		end

		self:AddObjectivePoint(
			txt,
			self.missionData["explorationPoint"] + Vector(0, -30),
			CF.PlayerTeam,
			GameActivity.ARROWDOWN
		)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveRandomExplorationReward()
	local rewards = { gold = 1, experience = 2, reputation = 3, blueprints = 4, nothing = 5 }
	local text = { "Nothing of value was found." }

	local r = math.random(#rewards)

	if r == rewards.gold then
		local amount = math.floor(math.random(self.missionData["difficulty"] * 250, self.missionData["difficulty"] * 500))

		self:SetTeamFunds(CF.ChangeGold(self.GS, amount), CF.PlayerTeam)
		text = {}
		text[1] = "Bank account access codes found.\n" .. tostring(amount) .. "oz of gold received."
	elseif r == rewards.experience then
		local exppts = math.floor(math.random(self.missionData["difficulty"] * 75, self.missionData["difficulty"] * 150))
		levelup = CF.GiveExp(self.GS, exppts)

		text = {}
		text[1] = "Captain's log found. " .. exppts .. " exp gained."

		if levelup then
			local s = ""
			if self.PlayerCount > 1 then
				s = "s"
			end

			text[1] = text[1] .. "\nBrain" .. s .. " leveled up!"
		end
	elseif r == rewards.reputation then
		local amount = math.floor(math.random(self.missionData["difficulty"] * 75, self.missionData["difficulty"] * 150))
		local plr = math.random(tonumber(self.GS["ActiveCPUs"]))

		local rep = tonumber(self.GS["Player" .. plr .. "Reputation"])
		self.GS["Player" .. plr .. "Reputation"] = rep + amount

		text = {}
		text[1] = "Intelligence data found.\n+" .. amount .. " " .. CF.GetPlayerFaction(self.GS, plr) .. " reputation."
	elseif r == rewards.blueprints then
		local id = CF.UnlockRandomQuantumItem(self.GS)

		text = { CF.QuantumItmPresets[id] .. " quantum scheme found." }
	end

	if self.MissionReport == nil then
		self.MissionReport = {}
	end
	for i = 1, #text do
		self.MissionReport[#self.MissionReport + 1] = text[i]
	end
	CF.SaveMissionReport(self.GS, self.MissionReport)

	return text
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveRandomExperienceReward(diff)
	local exppts = 150 + math.random(350)

	if diff ~= nil then
		exppts = CF.CalculateReward(diff, 250)
	end

	levelup = CF.GiveExp(self.GS, exppts)

	text = {}
	text[1] = tostring(exppts) .. " exp gained."

	if levelup then
		local s = ""
		if self.PlayerCount > 1 then
			s = "s"
		end

		text[2] = "Brain" .. s .. " leveled up!"
	end

	if self.MissionReport == nil then
		self.MissionReport = {}
	end
	for i = 1, #text do
		self.MissionReport[#self.MissionReport + 1] = text[i]
	end
	CF.SaveMissionReport(self.GS, self.MissionReport)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:StartMusic(musictype)
	print("VoidWanderers:StartMusic")
	local track = -1

	MusicMan:ResetMusicState()
	MusicMan:EndDynamicMusic(false)
	
	MusicMan:PlayDynamicSong(CF.Music[musictype], "Default", true, false, false)

	self.LastMusicType = musictype
	self.LastMusicTrack = track
end
-----------------------------------------------------------------------------------------
-- Message handling.
-----------------------------------------------------------------------------------------
function VoidWanderers:OnMessage(message, context)
	VWHandleMessage(message, context)
end
-----------------------------------------------------------------------------------------
-- That's all folks!!!
-----------------------------------------------------------------------------------------
