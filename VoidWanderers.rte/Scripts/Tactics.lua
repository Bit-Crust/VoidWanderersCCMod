-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Start Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:StartActivity(isNewGame)
	print("VoidWanderers:Tactics:StartActivity")

	-- Disable string rendering optimizations because letters start to fall down
	CF.FrameCounter = 0
	CF.GS = self.GS

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

	self.TickTimer = Timer()
	self.TickTimer:Reset()
	self.TickInterval = CF.TickInterval

	self.TeleportEffectTimer = Timer()
	self.TeleportEffectTimer:Reset()

	self.HoldTimer = Timer()
	self.HoldTimer:Reset()

	self.RandomEncounterDelayTimer = nil

	self.FlightTimer = Timer()
	self.FlightTimer:Reset()
	self.LastTrigger = 0

	self.SceneTimer = Timer()
	self.SceneTimer:Reset()

	-- All items in this queue will be removed
	self.ItemRemoveQueue = {}

	self.RandomEncounterID = nil
	self.Ship = nil
	self.EngineEmitters = nil

	self.PlayerFaction = self.GS["Player0Faction"]

	-- Artificial Gravity System
	self.AGS = Vector(0, rte.PxTravelledPerFrame / (1 + SceneMan.Scene.GlobalAcc.Y))

	self.distanceToAttemptEvent = 100 - CF.Difficulty * 0.5
	
	-- Load generic level data
	self.SceneConfig = CF.ReadSceneConfigFile(SceneMan.Scene.ModuleName, SceneMan.Scene.PresetName .. ".dat")

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
	self:SetTeamFunds(CF.GetPlayerGold(self.GS, CF.PlayerTeam), CF.PlayerTeam)

	if self.GS["AISkillPlayer"] then
		self:SetTeamAISkill(CF.PlayerTeam, tonumber(self.GS["AISkillPlayer"]))
	end

	if self.GS["AISkillCPU"] then
		self:SetTeamAISkill(CF.CPUTeam, tonumber(self.GS["AISkillCPU"]))
	end

	-- Read brain location data
	if self.GS["Mode"] == "Vessel" then
		print("VoidWanderers:Tactics:StartActivity:Vessel")
		self:InitConsoles()

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

		self.EnginePos = {}
		for i = 1, 10 do
			local x, y

			x = tonumber(self.SceneConfig["Engine" .. i .. "X"])
			y = tonumber(self.SceneConfig["Engine" .. i .. "Y"])
			if x and y then
				self.EnginePos[i] = Vector(x, y)
			else
				break
			end
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

		self.Ship = SceneMan.Scene:GetArea("Vessel")
		self.AssaultSpawn = SceneMan.Scene:GetOptionalArea("AssaultSpawn")

		local dest = 1

		-- Spawn previously saved actors
		if self.GS["DeserializeOnboard"] == "True" then
			self.GS["DeserializeOnboard"] = "False"

			for i = 1, CF.MaxSavedActors do
				if self.GS["Actor" .. i .. "Preset"] then
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
							else
								break
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
				if self.GS["Deployed" .. i .. "Preset"] then
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
							else
								break
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
		end

		self:LocatePlayerBrains()

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

		-- If we're on temp-location then cancel this location
		if CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TEMPLOCATION) then
			self.GS["Location"] = nil
		end
	elseif self.GS["Mode"] == "Mission" then
		print("VoidWanderers:Tactics:StartActivity:Mission")
		self:StartMusic(CF.MusicTypes.MISSION_CALM)

		-- All mission related final message will be accumulated in mission report list
		local scene = SceneMan.Scene.PresetName

		self.Pts = CF.ReadPtsData(scene, self.SceneConfig)
		self.MissionDeploySet = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")

		-- Find suitable LZs
		local lzs = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerLZ")
		self.LZControlPanelPos = CF.RandomSampleOfList(lzs, Activity.MAXPLAYERCOUNT)

		-- Init LZs
		self:InitLZControlPanelUI()

		local dest = 1
		local dsts = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerUnit")

		-- Spawn player troops
		if self.GS["DeserializeDeployedTeam"] == "True" then
			self.GS["DeserializeDeployedTeam"] = "False"
			self.GS["MissionDeployedTroops"] = 1
			for i = 1, CF.MaxSavedActors do
				if self.GS["Deployed" .. i .. "Preset"] then
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
							else
								break
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
		
		self:LocatePlayerBrains()

		local fowEnabled = self.GS["FogOfWar"] == "true"

		-- Prepare for mission, load scripts
		self.MissionAvailable = false
		self.MissionStatus = nil

		-- Set generic mission difficulty based on location security
		local diff = CF.GetLocationDifficulty(self.GS, self.GS["Location"])
		self.MissionDifficulty = diff

		-- Find available mission
		for m = 1, CF.MaxMissions do
			if self.GS["Location"] == self.GS["Mission" .. m .. "Location"] then -- GAMEPLAY
				self.MissionAvailable = true

				self.MissionNumber = m
				self.MissionType = self.GS["Mission" .. m .. "Type"]
				self.MissionDifficulty = CF.GetFullMissionDifficulty(self.GS, self.GS["Location"], m) --tonumber(self.GS["Mission"..m.."Difficulty"])
				self.MissionSourcePlayer = tonumber(self.GS["Mission" .. m .. "SourcePlayer"])
				self.MissionTargetPlayer = tonumber(self.GS["Mission" .. m .. "TargetPlayer"])

				-- DEBUG
				--self.MissionDifficulty = CF.MaxDifficulty
				--self.MissionType = "Assault"	--"Assassinate"	--"Dropships"	--"Mine"	--"Zombies"	--"Defend"	--"Destroy"	--"Squad"

				self.MissionScript = CF.MissionScript[self.MissionType]
				self.MissionGoldReward = CF.CalculateReward(
					CF.MissionGoldRewardPerDifficulty[self.MissionType],
					self.MissionDifficulty
				)
				self.MissionReputationReward = CF.CalculateReward(
					CF.MissionReputationRewardPerDifficulty[self.MissionType],
					self.MissionDifficulty
				)

				self.MissionStatus = "" -- Will be updated by mission script

				-- Create unit presets
				CF.CreateAIUnitPresets(
					self.GS,
					self.MissionSourcePlayer,
					CF.GetTechLevelFromDifficulty(
						self.GS,
						self.MissionSourcePlayer,
						self.MissionDifficulty,
						CF.MaxDifficulty
					)
				)
				CF.CreateAIUnitPresets(
					self.GS,
					self.MissionTargetPlayer,
					CF.GetTechLevelFromDifficulty(
						self.GS,
						self.MissionTargetPlayer,
						self.MissionDifficulty,
						CF.MaxDifficulty
					)
				)

				break
			end -- GAMEPLAY
		end

		-- Set up mission behaviors
		local missionscript
		local ambientscript
		if self.MissionAvailable then
			-- Increase location security every time mission started
			local sec = CF.GetLocationSecurity(self.GS, self.GS["Location"])
			sec = sec + CF.SecurityIncrementPerMission
			CF.SetLocationSecurity(self.GS, self.GS["Location"], sec)

			missionscript = self.MissionScript
			ambientscript = CF.LocationAmbientScript[self.GS["Location"]]
		else
			-- Slightly increase location security every time deplyment happens
			local sec = CF.GetLocationSecurity(self.GS, self.GS["Location"])
			sec = sec + CF.SecurityIncrementPerDeployment
			CF.SetLocationSecurity(self.GS, self.GS["Location"], sec)

			if CF.LocationScript[self.GS["Location"]] then
				local r = math.random(#CF.LocationScript[self.GS["Location"]])
				missionscript = CF.LocationScript[self.GS["Location"]][r]
			end

			ambientscript = CF.LocationAmbientScript[self.GS["Location"]]
		end

		self.MissionReport = {}

		if missionscript == nil then
			missionscript = "VoidWanderers.rte/Scripts/Mission_Generic.lua"
		end

		if ambientscript == nil then
			ambientscript = "VoidWanderers.rte/Scripts/Ambient_Generic.lua"
		end
		
		self.MissionStartTime = tonumber(self.Time)
		self.MissionEndMusicPlayed = false

		self.SpawnTable = {}

		-- Clear previous script functions
		self.MissionCreate = nil
		self.MissionUpdate = nil
		self.MissionDestroy = nil

		self.AmbientCreate = nil
		self.AmbientUpdate = nil
		self.AmbientDestroy = nil

		dofile(missionscript)
		dofile(ambientscript)
		
		self:MissionCreate(isNewGame)
		self:AmbientCreate(isNewGame)

		-- isNewGame can only ever be undefined or false with how it currently is, so. . . this is how it is
		if isNewGame == nil then
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
			if fowEnabled then
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

				-- Reveal previously saved fog of war, if applicable
				if false and not CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.ALWAYSUNSEEN) then
					local wx = math.ceil(SceneMan.Scene.Width / CF.FogOfWarResolution)
					local wy = math.ceil(SceneMan.Scene.Height / CF.FogOfWarResolution)

					local digitsYTotal = math.max(math.floor(math.log10(wy)), 0)

					for y = 0, wy do
						local numString = tostring(y)
						local digits = digitsYTotal - math.max(math.floor(math.log10(y)), 0)
						for i = 0, digits do
							numString = "0" .. numString
						end
						local str = self.GS[self.GS["Location"] .. "-Fog" .. numString]
						if str then
							for x = 0, wx do
								if string.sub(str, x + 1, x + 1) == "1" then --and SceneMan:GetTerrMatter(x * CF.FogOfWarResolution, y * CF.FogOfWarResolution) ~= rte.airID then
									SceneMan:RevealUnseen(
										x * CF.FogOfWarResolution,
										y * CF.FogOfWarResolution,
										CF.PlayerTeam
									)
								end
							end
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

	self.gravityPerFrame = SceneMan.Scene.GlobalAcc * TimerMan.DeltaTimeSecs

	self.AssaultTime = -1
	self.AttemptAssaultTime = 0

	-- Icon display data
	self.Icon = CreateMOSRotating("Icon_Generic", self.ModuleName)
	self.IconFrame = {}

	-- Combination icons
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
	--self.IconFrame[agile] = {findByName = {"Grapple Gun", "Warp Grenade", "Dov Translocator", "Feather"}}

	self.RankIcon = CreateMOSRotating("Icon_Rank", self.ModuleName)
	self.PrestigeIcon = CreateMOSRotating("Icon_Prestige", self.ModuleName)
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

	print("VoidWanderers:Tactics:StartActivity - End")
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
--
-----------------------------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	if self.MissionSettings and orbitedCraft:HasObjectInGroup("MissionBrain") then
		self.MissionSettings["Evacuated"] = true
	end
	if orbitedCraft.Team == CF.CPUTeam and self.MissionSettings and self.MissionSettings["EnemyDropShips"] then
		self.MissionSettings["EnemyDropShips"] = self.MissionSettings["EnemyDropShips"] + 1
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawRankIcon(preset, pos, prestige)
	if preset then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local screen = self:ScreenOfPlayer(player)
			PrimitiveMan:DrawBitmapPrimitive(
				player,
				pos,
				(prestige ~= 0 and self.PrestigeIcon or self.RankIcon),
				0,
				preset
			)
			if prestige > 1 then
				PrimitiveMan:DrawTextPrimitive(player, pos, "x" .. prestige, true, 0)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GiveXP(actor, xp)
	if actor then
		xp = math.floor(xp / math.sqrt(1 + actor:GetNumberValue("VW_Prestige")) + 0.5)
		local levelUp, nextRank
		if xp > 0 then
			self.xpSound:Play(actor.Pos)
			local newXP = actor:GetNumberValue("VW_XP") + xp
			actor:SetNumberValue("VW_XP", newXP)

			nextRank = CF.Ranks[actor:GetNumberValue("VW_Rank") + 1]
			levelUp = nextRank and newXP >= nextRank

			if not SceneMan:IsUnseen(actor.Pos.X, actor.Pos.Y, CF.PlayerTeam) then
				local effect = CreateMOPixel("Text Effect", self.ModuleName)
				if
					actor:IsPlayerControlled()
					and SceneMan
						:ShortestDistance(actor.EyePos, actor.ViewPoint, SceneMan.SceneWrapsX)
						:MagnitudeIsGreaterThan(
							math.min(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight) * 0.5 - 25
						)
				then
					effect.Pos = actor.ViewPoint + Vector(0, -math.random(5))
				else
					effect.Pos = actor.AboveHUDPos + Vector(math.random(-5, 5), -math.random(5))
				end
				effect.Sharpness = xp
				if levelUp then
					effect.Mass = nextRank + 1
				end
				MovableMan:AddParticle(effect)
			end

			if levelUp then
				actor:SetNumberValue("VW_Rank", actor:GetNumberValue("VW_Rank") + 1)
				actor:FlashWhite(50)
				if not self.levelUpSound:IsBeingPlayed() then
					self.levelUpSound:Play(actor.Pos)
				end
				actor.Health = math.min(actor.Health + actor.Health * 0.5, actor.MaxHealth)
			end
		end
		--print(actor.PresetName .. (xp < 0 and " lost " or " gained ") .. xp .. " XP!")
	end
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
-- Save fog of war
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveFogOfWarState(config)
	local tiles = 0
	local revealed = 0

	if config["FogOfWar"] and config["FogOfWar"] == "true" then
		local wx = SceneMan.Scene.Width / CF.FogOfWarResolution
		local wy = SceneMan.Scene.Height / CF.FogOfWarResolution

		local digitsYTotal = math.max(math.floor(math.log10(wy)), 0)

		for y = 0, wy do
			str = ""
			for x = 0, wx do
				tiles = tiles + 1
				if SceneMan:IsUnseen(x * CF.FogOfWarResolution, y * CF.FogOfWarResolution, CF.PlayerTeam) then
					str = str .. "0"
				else
					str = str .. "1"
					revealed = revealed + 1
				end
			end
			local digits = digitsYTotal - math.max(math.floor(math.log10(y)), 0)
			local numString = tostring(y)
			for i = 0, digits do
				numString = "0" .. numString
			end
			--config[self.GS["Location"] .. "-Fog" .. numString] = str
		end
		config[self.GS["Location"] .. "-FogRevealPercentage"] = math.floor(revealed / tiles * 100)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:TriggerShipAssault()
	if not CF.EnableAssaults then
		return
	end

	local toassault = false

	if self.AttemptAssaultTime < self.Time then
		-- Select random assault CPU based on how angry they are
		local angry = {}

		for i = 1, tonumber(self.GS["ActiveCPUs"]) do
			local rep = tonumber(self.GS["Player" .. i .. "Reputation"])
			if rep <= CF.ReputationHuntThreshold then
				angry[#angry + 1] = i
			end
		end

		if #angry > 0 then
			local rangedangry = {}
			for i = 1, #angry do
				local anger = math.min(
					math.max(
						math.floor(
							math.abs(
								tonumber(self.GS["Player" .. angry[i] .. "Reputation"]) / CF.ReputationPerDifficulty
							)
						),
						1
					),
					CF.MaxDifficulty
				)

				for j = 1, anger do
					rangedangry[#rangedangry + 1] = angry[i]
				end
			end

			angry = rangedangry

			self.AssaultEnemyPlayer = angry[math.random(#angry)]

			local rep = tonumber(self.GS["Player" .. self.AssaultEnemyPlayer .. "Reputation"])

			self.AssaultDifficulty = math.min(
				math.max(math.floor(math.abs(rep / CF.ReputationPerDifficulty)), 1),
				CF.MaxDifficulty
			)

			if math.random(100) < 5 then
				toassault = true
			end
		end
	end

	if toassault then
		self.AssaultTime = self.Time + CF.ShipAssaultDelay
		self.AssaultEnemiesToSpawn = CF.AssaultDifficultyUnitCount[self.AssaultDifficulty]
		self.AssaultNextSpawnTime = self.AssaultTime + CF.AssaultDifficultySpawnInterval[self.AssaultDifficulty] + 1
		self.AssaultNextSpawnPos = self.AssaultSpawn and self.AssaultSpawn:GetRandomPoint()
			or self.EnemySpawn[math.random(#self.EnemySpawn)]
		self.AssaultWarningTime = 6 - math.floor(self.AssaultDifficulty * 0.5 + 0.5)

		-- Create attacker's unit presets
		CF.CreateAIUnitPresets(
			self.GS,
			self.AssaultEnemyPlayer,
			CF.GetTechLevelFromDifficulty(self.GS, self.AssaultEnemyPlayer, self.AssaultDifficulty, CF.MaxDifficulty)
		)
	else
		-- Trigger random encounter
		if math.random() < CF.RandomEncounterProbability and #CF.RandomEncounters > 0 then
			-- Find suitable random event
			local r
			local id
			local found = false
			local brk = 1

			while not found do
				r = math.random(#CF.RandomEncounters)
				id = CF.RandomEncounters[r]

				if CF.RandomEncountersOneTime[id] == true then
					if self.GS["Encounter" .. id .. "Happened"] == nil then
						found = true
					end
				else
					found = true
				end

				brk = brk + 1
				if brk > 30 then
					--error("Endless loop in random encounter selector")
					break
				end
			end
			-- DEBUG
			--id = "PIRATE_GENERIC"
			--id = "ABANDONED_VESSEL_GENERIC"
			--id = "HOSTILE_DRONE"
			--id = "REAVERS"

			-- Launch encounter
			if found and id ~= nil then
				-- Reavers are after your gold
				if CF.RandomEncounters["REAVERS"] and id ~= "REAVERS" then
					local goldThreshold = 25000
					if
						math.random()
						< math.min(CF.GetPlayerGold(self.GS, CF.PlayerTeam), goldThreshold) / (goldThreshold * 2)
					then
						id = "REAVERS"
					end
				end

				self.RandomEncounterID = id
				self.RandomEncounterVariant = 0

				self.RandomEncounterDelayTimer = Timer()

				self.RandomEncounterText = CF.RandomEncountersInitialTexts[id]
				self.RandomEncounterVariants = CF.RandomEncountersInitialVariants[id]
				self.RandomEncounterVariantsInterval = CF.RandomEncountersVariantsInterval[id]
				self.RandomEncounterChosenVariant = 0
				self.RandomEncounterIsInitialized = false
				self.ShipControlSelectedEncounterVariant = 1

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

				self:StartMusic(CF.MusicTypes.SHIP_INTENSE)
				--]]--
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SpawnFromTable()
	if #self.SpawnTable > 0 then
		if MovableMan:GetMOIDCount() < CF.MOIDLimit then
			local nm = self.SpawnTable[1]

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
			table.remove(self.SpawnTable, 1)
		else
			print("MOID LIMIT REACHED!!!")
			self.SpawnTable = nil
		end
	else
		self.SpawnTable = nil
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ClearActors()
	for i = 1, CF.MaxSavedActors do
		self.GS["Actor" .. i .. "Preset"] = nil
		self.GS["Actor" .. i .. "Class"] = nil
		self.GS["Actor" .. i .. "Module"] = nil
		self.GS["Actor" .. i .. "X"] = nil
		self.GS["Actor" .. i .. "Y"] = nil
		self.GS["Actor" .. i .. "XP"] = nil
		self.GS["Actor" .. i .. "Identity"] = nil
		self.GS["Actor" .. i .. "Player"] = nil
		self.GS["Actor" .. i .. "Prestige"] = nil
		self.GS["Actor" .. i .. "Name"] = nil
		for j = 1, #CF.LimbID do
			self.GS["Actor" .. i .. CF.LimbID[j]] = nil
		end
		for j = 1, CF.MaxSavedItemsPerActor do
			self.GS["Actor" .. i .. "Item" .. j .. "Preset"] = nil
			self.GS["Actor" .. i .. "Item" .. j .. "Class"] = nil
			self.GS["Actor" .. i .. "Item" .. j .. "Module"] = nil
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveActors(clearpos)
	self:ClearActors()

	local savedactor = 0

	for actor in MovableMan.Actors do
		if actor.PresetName ~= "Brain Case" and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
			local pre, cls, mdl = CF.GetInventory(actor)

			savedactor = savedactor + 1

			-- Save actors to config
			self.GS["Actor" .. savedactor .. "Preset"] = actor.PresetName
			self.GS["Actor" .. savedactor .. "Class"] = actor.ClassName
			self.GS["Actor" .. savedactor .. "Module"] = actor.ModuleName
			self.GS["Actor" .. savedactor .. "XP"] = actor:GetNumberValue("VW_XP")
			self.GS["Actor" .. savedactor .. "Identity"] = actor:GetNumberValue("Identity")
			self.GS["Actor" .. savedactor .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
			self.GS["Actor" .. savedactor .. "Prestige"] = actor:GetNumberValue("VW_Prestige")
			self.GS["Actor" .. savedactor .. "Name"] = actor:GetStringValue("VW_Name")
			for j = 1, #CF.LimbID do
				self.GS["Actor" .. savedactor .. CF.LimbID[j]] = CF.GetLimbData(actor, j)
			end

			if clearpos then
				self.GS["Actor" .. savedactor .. "X"] = nil
				self.GS["Actor" .. savedactor .. "Y"] = nil
			else
				self.GS["Actor" .. savedactor .. "X"] = math.floor(actor.Pos.X)
				self.GS["Actor" .. savedactor .. "Y"] = math.floor(actor.Pos.Y)
			end

			for j = 1, #pre do
				self.GS["Actor" .. savedactor .. "Item" .. j .. "Preset"] = pre[j]
				self.GS["Actor" .. savedactor .. "Item" .. j .. "Class"] = cls[j]
				self.GS["Actor" .. savedactor .. "Item" .. j .. "Module"] = mdl[j]
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ClearDeployed()
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
-- Update Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	if not self.IsInitialized then
		--Init mission if we're still not
		self:StartActivity()
	end

	self:ClearObjectivePoints()

	-- Add any gold gained in-game
	local realGold = self:GetTeamFunds(CF.PlayerTeam)
	if realGold ~= CF.GetPlayerGold(self.GS, CF.PlayerTeam) then
		CF.SetPlayerGold(self.GS, CF.PlayerTeam, realGold)
	end

	if self.SceneTimer:IsPastSimMS(25) then
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
				and (actor:GetController():IsState(Controller.WEAPON_FIRE) or actor
					:GetController()
					:IsState(Controller.WEAPON_RELOAD))
				and IsAHuman(actor)
				and ToAHuman(actor).EquippedItem
				and not ToAHuman(actor).EquippedItem.ToDelete
				and ToAHuman(actor).EquippedItem.ModuleName == CF.ModuleName
			then
				actor = ToAHuman(actor)
				if actor.EquippedItem.PresetName == "Blueprint" then
					local itm
					local player = self.MissionTargetPlayer or math.random(tonumber(self.GS["ActiveCPUs"]))
					local faction = self.GS["Player" .. player .. "Faction"]
					if faction then
						if math.random() < 0.25 then
							local actorList = CF.MakeListOfMostPowerfulActors(
								self.GS,
								player,
								CF.ActorTypes.ANY,
								math.abs(tonumber(self.GS["Player" .. player .. "Reputation"]))
							)
							if actorList then
								for _, potentialActor in pairs(actorList) do
									local actorName = CF.ActPresets[faction][potentialActor["Actor"]]
									if
										actorName
										and CF.ActModules[faction][potentialActor["Actor"]] ~= "Base.rte"
										and not self.GS["UnlockedActBlueprint_" .. actorName]
									then
										itm = actorName
										break
									end
								end
							end
							if itm == nil then
								itm = CF.ActPresets[faction][math.random(#CF.ActPresets[faction])]
								if itm and self.GS["UnlockedActBlueprint_" .. itm] then
									itm = nil
								end
							end
							if itm then
								self.GS["UnlockedActBlueprint_" .. itm] = 1
							end
						end
						if itm == nil then
							local weaponList = CF.MakeListOfMostPowerfulWeapons(
								self.GS,
								player,
								CF.WeaponTypes.ANY,
								math.abs(tonumber(self.GS["Player" .. player .. "Reputation"]))
							)
							if weaponList then
								for _, potentialWeapon in pairs(weaponList) do
									local weaponName = CF.ItmPresets[faction][potentialWeapon["Item"]]
									if
										weaponName
										and CF.ItmModules[faction][potentialWeapon["Item"]] ~= "Base.rte"
										and not self.GS["UnlockedItmBlueprint_" .. weaponName]
									then
										itm = weaponName
										break
									end
								end
							end
							if itm == nil then
								itm = CF.ItmPresets[faction][math.random(#CF.ItmPresets[faction])]
								if itm and self.GS["UnlockedItmBlueprint_" .. itm] then
									itm = nil
								end
							end
							if itm then
								self.GS["UnlockedItmBlueprint_" .. itm] = 1
							end
						end
					end
					local effect = CreateMOPixel("Text Effect", self.ModuleName)
					effect.PresetName = itm == nil and "Nothing of value was found."
						or itm .. " blueprint unlocked!\nThe Trade Star will update their catalog shortly."
					effect.Pos = actor.AboveHUDPos + Vector(0, -8)
					MovableMan:AddParticle(effect)

					actor.EquippedItem.ToDelete = true
					actor:FlashWhite(50)
				elseif actor.EquippedItem.PresetName == "Blackprint" then
					local itm
					if math.random() < 0.25 then
						itm = CF.ArtActPresets[math.random(#CF.ArtActPresets)]
						if itm and not self.GS["UnlockedActBlackprint_" .. itm] then
							self.GS["UnlockedActBlackprint_" .. itm] = 1
						else
							itm = nil
						end
					end
					if itm == nil then
						itm = CF.ArtItmPresets[math.random(#CF.ArtItmPresets)]
						if itm and not self.GS["UnlockedItmBlackprint_" .. itm] then
							self.GS["UnlockedItmBlackprint_" .. itm] = 1
						else
							itm = nil
						end
					end
					local effect = CreateMOPixel("Text Effect", self.ModuleName)
					effect.PresetName = itm == nil and "Nothing of value was found."
						or itm .. " blackprint unlocked!\nThe Black Market will update their catalog shortly."
					effect.Pos = actor.AboveHUDPos + Vector(0, -8)
					MovableMan:AddParticle(effect)

					actor.EquippedItem.ToDelete = true
					actor:FlashWhite(50)
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
					local velOffset = actor.Vel * rte.PxTravelledPerFrame

					local offsetY = (actor:IsPlayerControlled() and actor.ItemInReach) and -8 or -1
					local name = actor:GetStringValue("VW_Name")
					if (name and name ~= "") or (CF.TypingActor and CF.TypingActor.ID == actor.ID) then
						PrimitiveMan:DrawTextPrimitive(
							actor.AboveHUDPos + velOffset + Vector(1, offsetY - 7),
							name,
							false,
							1
						)
					elseif isFriendly then
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
					local rank = actor:GetNumberValue("VW_Rank")
					if rank > 0 or prestige ~= 0 then
						local pos = actor.Pos + velOffset + Vector(-20, 8 - actor.Height * 0.5)

						self:DrawRankIcon(rank, pos, prestige)
						if pieMenuOpen then
							local progress = CF.Ranks[rank + 1]
									and actor:GetNumberValue("VW_XP") .. "/" .. CF.Ranks[rank + 1]
								or CF.Ranks[rank] .. "/" .. CF.Ranks[rank]
							PrimitiveMan:DrawTextPrimitive(
								self:ScreenOfPlayer(cont.Player),
								pos + Vector(0, 5),
								progress,
								true,
								1
							)
						end
					end
				end
			end
		end
	end

	-- Process UI's and other vessel mode features
	if self.GS["Mode"] == "Vessel" then
		if self:GetPlayerBrain(Activity.PLAYER_1) then
			self:GetBanner(GUIBanner.RED, Activity.PLAYER_1):ClearText()
		end

		self:ProcessClonesControlPanelUI()
		self:ProcessStorageControlPanelUI()
		self:ProcessBrainControlPanelUI()
		self:ProcessTurretsControlPanelUI()

		-- Auto heal all actors when not in combat or random encounter
		if not self.OverCrowded then
			if self.RandomEncounterID == nil then
				for actor in MovableMan.Actors do
					if
						actor.Health > 0
						and actor.Health < actor.MaxHealth
						and actor.Team == CF.PlayerTeam
						and self.Ship:IsInside(actor.Pos)
					then
						actor.Health = math.min(actor.Health + 1, actor.MaxHealth)
					end
				end
			end
		else
			local count = CF.CountActors(CF.PlayerTeam) - tonumber(self.GS["Player0VesselLifeSupport"])
			local s = count == 1 and "BODY" or "BODIES"

			FrameMan:ClearScreenText(0)
			FrameMan:SetScreenText(
				"LIFE SUPPORT OVERLOADED\nSTORE OR DUMP "
					.. CF.CountActors(CF.PlayerTeam) - tonumber(self.GS["Player0VesselLifeSupport"])
					.. " "
					.. s,
				0,
				0,
				1000,
				true
			)
		end

		-- Show assault warning
		if self.AssaultTime > self.Time then
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
		else
			-- Process some control panels only when ship is not boarded
			self:ProcessShipControlPanelUI()
			if self:ProcessBeamControlPanelUI() then return end
			self:ProcessItemShopControlPanelUI()
			self:ProcessCloneShopControlPanelUI()
		end

		-- Launch defense activity
		if self.AssaultTime == self.Time then
			self.GS["Mode"] = "Assault"

			self:DeployTurrets()

			-- Remove control actors
			self:DestroyStorageControlPanelUI()
			self:DestroyShipControlPanelUI()
			self:DestroyBeamControlPanelUI()
			--self:DestroyClonesControlPanelUI()
			self:DestroyBeamControlPanelUI()
			self:DestroyItemShopControlPanelUI()
			self:DestroyCloneShopControlPanelUI()
			self:DestroyTurretsControlPanelUI()

			self:StartMusic(CF.MusicTypes.SHIP_INTENSE)
		end

		-- Process random encounter function
		if self.RandomEncounterID ~= nil then
			CF.RandomEncountersFunctions[self.RandomEncounterID](self, self.RandomEncounterChosenVariant)
			-- If incounter was finished then remove turrets
			if self.RandomEncounterID == nil then
				self.RandomEncounterDelayTimer = nil
				self:RemoveDeployedTurrets()
			end
		end
	end

	local flightSpeed = tonumber(self.GS["Player0VesselSpeed"])
	local engineBurst = false
	local engineBoost = self.EngineEmitters and flightSpeed * 0.005 or nil

	if self.GS["Mode"] == "Vessel" and self.FlightTimer:IsPastSimMS(CF.FlightTickInterval) then
		self.FlightTimer:Reset()
		-- Fly to new location
		if
			self.GS["Destination"] ~= nil
			and self.GS["Location"] == nil
			and self.Time > self.AssaultTime
			and self.RandomEncounterID == nil
		then
			-- Move ship
			local dx = tonumber(self.GS["DestX"])
			local dy = tonumber(self.GS["DestY"])

			local sx = tonumber(self.GS["ShipX"])
			local sy = tonumber(self.GS["ShipY"])

			local d = CF.Dist(Vector(sx, sy), Vector(dx, dy))

			if d < 0.5 then
				self.GS["Location"] = self.GS["Destination"]
				self.GS["Destination"] = nil

				local locpos = CF.LocationPos[self.GS["Location"]] or Vector()

				self.GS["ShipX"] = locpos.X
				self.GS["ShipY"] = locpos.Y

				-- Delete emitters
				if self.EngineEmitters then
					for i = 1, #self.EngineEmitters do
						self.EngineEmitters[i].ToDelete = true
					end
					self.EngineEmitters = nil
					engineBoost = engineBoost * -2
					for background in SceneMan.Scene.BackgroundLayers do
						background.AutoScrollStepX = -0.5
					end
				end
			else
				self.GS["Distance"] = d

				local ax = (dx - sx) / d * (tonumber(self.GS["Player0VesselSpeed"]) / CF.KmPerPixel)
				local ay = (dy - sy) / d * (tonumber(self.GS["Player0VesselSpeed"]) / CF.KmPerPixel)

				sx = sx + ax
				sy = sy + ay

				self.GS["ShipX"] = sx
				self.GS["ShipY"] = sy

				self.LastTrigger = self.GS["DistanceTraveled"]

				if self.LastTrigger == nil then
					self.LastTrigger = 0
				else
					self.LastTrigger = tonumber(self.LastTrigger)
				end

				self.LastTrigger = self.LastTrigger + 1

				if self.LastTrigger > self.distanceToAttemptEvent then
					self.LastTrigger = 0
					self:TriggerShipAssault()
				end

				self.GS["DistanceTraveled"] = self.LastTrigger

				-- Create emitters if nessesary
				if self.EngineEmitters == nil then
					self.EngineEmitters = {}
					for background in SceneMan.Scene.BackgroundLayers do
						background.AutoScrollStepX = -math.floor(math.sqrt(tonumber(self.GS["Player0VesselSpeed"])))
					end

					for i = 1, #self.EnginePos do
						local em = CreateAEmitter("Vessel Main Thruster")
						if em then
							em.Pos = self.EnginePos[i] + Vector(2, 0)
							self.EngineEmitters[i] = em
							MovableMan:AddParticle(em)
							em:EnableEmission(true)
						end
					end
					engineBurst = true
					engineBoost = tonumber(self.GS["Player0VesselSpeed"]) * 0.5
				end
			end
		end

		-- Create or delete shops if we arrived/departed to/from Star base
		if
			CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR)
			or CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET)
		then
			if not self.ShopsCreated then
				-- Destroy any previously created item shops and create a new one
				self:DestroyItemShopControlPanelUI()
				self:InitItemShopControlPanelUI()
				self:DestroyCloneShopControlPanelUI()
				self:InitCloneShopControlPanelUI()
				self.ShopsCreated = true
			end
		else
			if self.ShopsCreated then
				self:DestroyItemShopControlPanelUI()
				self:DestroyCloneShopControlPanelUI()
				self.ShopsCreated = false
			end
		end
	end --]]--

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
	end --]]--
	
	-- Generate artificial gravity inside the ship
	if self.Ship then
		-- God forbid you exit the ship when the engines are on
		if engineBoost then
			for id = 1, MovableMan:GetMOIDCount() - 1 do
				local mo = MovableMan:GetMOFromID(id)
				if mo and IsMOSRotating(mo) and mo.PinStrength == 0 and mo.ID == mo.RootID then
					if not self.AGS and engineBurst then
						mo.Vel = mo.Vel + Vector(engineBoost, 0)
						ToMOSRotating(mo).AngularVel = ToMOSRotating(mo).AngularVel
							+ math.random(-0.5, 0.5) * engineBoost
					elseif not self.Ship:IsInside(mo.Pos) then
						mo.Vel = mo.Vel + Vector(engineBoost, 0)
					end
				end
			end
		end

		local coll = { MovableMan.Actors, MovableMan.Items }
		for i = 1, #coll do
			for mo in coll[i] do
				if mo.PinStrength == 0 then
					mo.Vel = mo.Vel - self.gravityPerFrame
					if engineBoost and mo.ID == rte.NoMOID then -- Apply the same as above for items with no MOID
						if not self.AGS and engineBurst then
							mo.Vel = mo.Vel + Vector(engineBoost, 0)
							if IsMOSRotating(mo) then
								ToMOSRotating(mo).AngularVel = ToMOSRotating(mo).AngularVel
									+ math.random(-0.5, 0.5) * engineBoost
							end
						elseif not self.Ship:IsInside(mo.Pos) then
							mo.Vel = mo.Vel + Vector(engineBoost, 0)
						end
					end
					if self.AGS and self.Ship:IsInside(mo.Pos) then
						mo.Vel = mo.Vel + self.AGS
					else
						if IsAHuman(mo) then
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
	if self.flyPhase and IsActor(self.flyPhase[1]) then
		local dir = Vector(
			self.flyPhase[1].Pos.X - SceneMan.SceneWidth * 0.5,
			self.flyPhase[1].Pos.Y - SceneMan.SceneHeight * 0.5
		)
		if self.Ship:IsInside(self.flyPhase[1].Pos) then
			if #self.flyPhase == 5 and dir.X * self.flyPhase[2] > 0 then
				if self.flyPhase[1]:NumberValueExists("VW_Rank") then
					self.flyPhase[1].GoldCarried = self.flyPhase[1].GoldCarried + math.floor(self.flyPhase[1].Health)
				else
					self:GiveXP(self.flyPhase[1], CF.Ranks[1])
				end
				AudioMan:PlaySound(
					self.ModuleName .. "/UI/Generic/" .. "Ta" .. "da" .. ".b" .. "mp",
					self.flyPhase[1].Pos
				)
				self.flyPhase = nil
			else
				self.flyPhase = nil
			end
		elseif #self.flyPhase < 5 then
			if #self.flyPhase == 4 then
				if dir.X * self.flyPhase[2] > 0 and dir.Y * self.flyPhase[3] < 0 then
					self.flyPhase[#self.flyPhase + 1] = true
				end
			elseif #self.flyPhase > 1 then
				if dir.X * self.flyPhase[2] < 0 then
					if #self.flyPhase == 2 then
						self.flyPhase[#self.flyPhase + 1] = dir.Y > 0 and 1 or -1
					elseif dir.Y * self.flyPhase[3] < 0 then
						self.flyPhase[#self.flyPhase + 1] = dir.Y > 0 and 1 or -1
					end
				end
			else
				self.flyPhase[#self.flyPhase + 1] = dir.X > 0 and 1 or -1
			end
		end
	else
		self.flyPhase = nil
	end
	-- Tick timer
	--if self.TickTimer:IsPastSimMS(self.TickInterval) then
	if self.TickTimer:IsPastRealMS(self.TickInterval) then
		self.Time = self.Time + 1
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

		if self.AssaultTime > self.Time then
			if self.Time % 2 == 0 then
				self:MakeAlertSound(1 / math.max(self.AssaultTime - self.Time / 30, 1))
			end
		end

		if self.GS["Mode"] == "Vessel" then
			if CF.CountActors(CF.PlayerTeam) > tonumber(self.GS["Player0VesselLifeSupport"]) then
				self.OverCrowded = true

				if self.Time % 3 == 0 then
					for actor in MovableMan.Actors do
						if
							(actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
						then
							actor.Health = actor.Health
								- math.ceil(
									50 / math.sqrt(1 + math.abs(actor.Mass + actor.Material.StructuralIntegrity))
								)
						end
					end
				end

				if self.Time % 2 == 0 then
					self:MakeAlertSound(0.25)
				end
			else
				self.OverCrowded = false
			end

			if self.RandomEncounterID ~= nil then
				if self.Time % 2 == 0 then
					self:MakeAlertSound(0.25)
				end
			end

			-- When on vessel always
		end

		-- Kill all actors outside the ship
		if self.Ship then
			for actor in MovableMan.Actors do
				if
					(actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and not self.Ship:IsInside(actor.Pos)
				then
					actor.Health = actor.Health
						- math.ceil(50 / math.sqrt(1 + math.abs(actor.Mass + actor.Material.StructuralIntegrity)))
					self.flyPhase = self.flyPhase or { actor }
				end
			end
		end

		-- Process enemy spawn during assaults
		if self.GS["Mode"] == "Assault" then
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
					self.RandomEncounterVariant = 0

					self.RandomEncounterDelayTimer = Timer()
					self.RandomEncounterText = ""
					self.RandomEncounterVariants = { "Blood for Ba'al!!", "Let them leave." }
					self.RandomEncounterVariantsInterval = 12
					self.RandomEncounterChosenVariant = 0
					self.RandomEncounterIsInitialized = false
					self.ShipControlSelectedEncounterVariant = 1

					-- Set the availability of the next assault so that they don't happen back-to-back
					self.AttemptAssaultTime = self.Time + CF.ShipAssaultCooldown

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
		end
	end

	if self.GS["Mode"] == "Assault" then
		self:ProcessClonesControlPanelUI()
		-- Show enemies count
		if self.Time % 10 == 0 and self.AssaultEnemiesToSpawn > 0 then
			FrameMan:SetScreenText("Remaining assault bots: " .. self.AssaultEnemiesToSpawn, 0, 0, 1500, true)
		end

		--print ("-")
		--print (AssaultEnemiesToSpawn)
		--print (self.AssaultNextSpawnTime)

		if self.AssaultEnemiesToSpawn > 0 and self.AssaultNextSpawnTime - self.Time < self.AssaultWarningTime then
			self:AddObjectivePoint("INTRUDER\nALERT", self.AssaultNextSpawnPos, CF.PlayerTeam, GameActivity.ARROWDOWN)

			if self.TeleportEffectTimer:IsPastSimMS(50) then
				local p = CreateMOSParticle("Tiny Blue Glow", self.ModuleName)
				p.Pos = self.AssaultNextSpawnPos + Vector(math.random(-20, 20), math.random(10, 30))
				MovableMan:AddParticle(p)
				self.TeleportEffectTimer:Reset()
			end
		end
	end

	-- Debug-print unit orders
	--[[
	local arr = {}
	arr[Actor.AIMODE_BRAINHUNT] = "Brainhunt"
	arr[Actor.AIMODE_SENTRY] = "Sentry"
	arr[Actor.AIMODE_GOLDDIG] = "Gold dig"
	arr[Actor.AIMODE_GOTO] = "Goto"
	
	for actor in MovableMan.Actors do
		if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
			local s = arr[actor.AIMode]
			
			if s ~= nil then
				CF.DrawString(s, actor.Pos + Vector(-20,30), 100, 100)
			end
		end
	end

	 Deploy turrets when key pressed
	if UInputMan:KeyPressed(75) then
		if self.TurretsDeployedActors == nil then
			self:DeployTurrets()
		else
			self:RemoveDeployedTurrets()
		end
	end
	]]
	--
	if self.GS["Mode"] == "Mission" then
		if self:ProcessLZControlPanelUI() == true then
			return
		end

		-- Spawn units from table while it have some left
		while self.SpawnTable ~= nil do
			self:SpawnFromTable()
		end

		if self.AmbientUpdate ~= nil then
			self:AmbientUpdate()
		end

		if self.MissionUpdate ~= nil then
			self:MissionUpdate()
		end

		-- Make actors glitch if there are too many of them
		local count = 0
		local braincount = 0
		for actor in MovableMan.Actors do
			if
				actor.Team == CF.PlayerTeam
				and actor.ClassName ~= "Actor"
				and actor.ClassName ~= "ADoor"
				and not self:IsAlly(actor)
			then
				count = count + 1

				if
					self.Time % 4 == 0
					and count > tonumber(self.GS["Player0VesselCommunication"])
					and self.GS["BrainsOnMission"] ~= "True"
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
				and self.Time > self.MissionStartTime + 1
			then
				self.WinnerTeam = CF.CPUTeam
				ActivityMan:EndActivity()
				self:StartMusic(CF.MusicTypes.DEFEAT)
			end
		end
	end
	
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

	for actor in MovableMan.AddedActors do
		-- No dead unit settles immediately and all can carry others, though most can't use it
		if IsAHuman(actor) or IsACrab(actor) then
			actor.RestThreshold = -1
			if actor:HasScript("VoidWanderers.rte/Scripts/Carry.lua") then
				actor:EnableScript("VoidWanderers.rte/Scripts/Carry.lua")
			else
				actor:AddScript("VoidWanderers.rte/Scripts/Carry.lua")
			end
		end
		-- Space out spawned-in craft
		if actor.Pos.Y <= 0 then
			local dir = 0
			for i = 1, 10 do
				local dist = Vector()
				local otherActor = MovableMan:GetClosestActor(actor.Pos, actor.Diameter, dist, actor)
				if otherActor then
					if dir == 0 then
						dir = dist.X < 0 and 1 or -1
					end
					actor.Pos.X = actor.Pos.X + actor.Radius * dir
				else
					break
				end
			end
		end
		if self:IsPlayerUnit(actor) then
			if actor:GetNumberValue("VW_Prestige") ~= 0 then
				if actor:HasScript("Base.rte/Actors/Shared/Scripts/SelfHeal.lua") then
					actor:EnableScript("Base.rte/Actors/Shared/Scripts/SelfHeal.lua")
				else
					actor:AddScript("Base.rte/Actors/Shared/Scripts/SelfHeal.lua")
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------
-- Find and assign player brains, for loaded games.
-----------------------------------------------------------------------------------------
function VoidWanderers:LocatePlayerBrains()
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			for actor in MovableMan.AddedActors do
				if actor:GetNumberValue("VW_BrainOfPlayer") - 1 == player then
					self:SetPlayerBrain(actor, player)
					self:SwitchToActor(actor, player, CF.PlayerTeam)
					self.PlayersWithBrains[player + 1] = true
					actor.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil)
					if actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
						actor:EnableScript("VoidWanderers.rte/Scripts/Brain.lua")
					else
						actor:AddScript("VoidWanderers.rte/Scripts/Brain.lua")
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

			table.insert(self.SpawnTable, nw)
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ObtainBaseBoxes(setname, setnumber)
	-- Get base box
	if self.missionData then
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
	if #points == 0 then
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
	self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"] = tonumber(
		self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"]
	) + self.MissionReputationReward
	if not disablepenalties then
		self.GS["Player" .. self.MissionTargetPlayer .. "Reputation"] = tonumber(
			self.GS["Player" .. self.MissionTargetPlayer .. "Reputation"]
		) - math.ceil(self.MissionReputationReward * CF.ReputationPenaltyRatio)
	end
	CF.SetPlayerGold(self.GS, 0, CF.GetPlayerGold(self.GS, 0) + self.MissionGoldReward)

	-- Refresh Black Market listing after every completed mission
	self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ItemsLastRefresh"] = nil

	if self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"] ~= nil then
		local last = tonumber(self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"])
		if (last + CF.BlackMarketRefreshInterval) * RangeRand(0.5, 0.75) < tonumber(self.GS["Time"]) then
			self.GS["BlackMarket" .. "Station Ypsilon-2" .. "ActorsLastRefresh"] = nil
		end
	end

	self.MissionReport[#self.MissionReport + 1] = "MISSION COMPLETED"
	if self.MissionGoldReward > 0 then
		self.MissionReport[#self.MissionReport + 1] = tostring(self.MissionGoldReward) .. "oz of gold received"
	end

	local exppts = math.floor((self.MissionReputationReward + self.MissionGoldReward) / 8)

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
	if self.MissionReputationReward > 0 then
		self.MissionReport[#self.MissionReport + 1] = "+"
			.. self.MissionReputationReward
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.MissionSourcePlayer)]
			.. " reputation"
		if not disablepenalties then
			self.MissionReport[#self.MissionReport + 1] = "-"
				.. math.ceil(self.MissionReputationReward * CF.ReputationPenaltyRatio)
				.. " "
				.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)]
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
	self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"] = tonumber(
		self.GS["Player" .. self.MissionSourcePlayer .. "Reputation"]
	) - math.ceil(self.MissionReputationReward * CF.MissionFailedReputationPenaltyRatio)
	self.GS["Player" .. self.MissionTargetPlayer .. "Reputation"] = tonumber(
		self.GS["Player" .. self.MissionTargetPlayer .. "Reputation"]
	) - math.ceil(self.MissionReputationReward * CF.MissionFailedReputationPenaltyRatio)

	self.MissionReport[#self.MissionReport + 1] = "MISSION FAILED"

	CF.MissionCombo = 0
	local loss = math.floor((self.MissionReputationReward + self.MissionGoldReward) * 0.005)
	for actor in MovableMan.Actors do
		if self:IsPlayerUnit(actor) then
			self:GiveXP(actor, -(loss + actor:GetNumberValue("VW_XP") * 0.1))
		end
	end
	if self.MissionReputationReward > 0 then
		self.MissionReport[#self.MissionReport + 1] = "-"
			.. math.ceil(self.MissionReputationReward * CF.MissionFailedReputationPenaltyRatio)
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.MissionSourcePlayer)]
			.. " reputation"
		self.MissionReport[#self.MissionReport + 1] = "-"
			.. math.ceil(self.MissionReputationReward * CF.MissionFailedReputationPenaltyRatio)
			.. " "
			.. CF.FactionNames[CF.GetPlayerFaction(self.GS, self.MissionTargetPlayer)]
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
	self.MissionExplorationPoint = pts[math.random(#pts)]
	self.MissionExplorationRecovered = false

	self.MissionExplorationHologram = "Holo" .. math.random(CF.MaxHolograms)

	self.MissionExplorationText = {}
	self.MissionExplorationTextStart = -100

	--print (self.MissionExplorationPoint)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessExplorationPoints()
	if self.MissionExplorationPoint ~= nil then
		if not self.MissionExplorationRecovered then
			if math.random(10) < 7 then
				self:PutGlow(self.MissionExplorationHologram, self.MissionExplorationPoint)
			end

			-- Send all units to brainhunt
			for actor in MovableMan.Actors do
				if actor.Team == CF.PlayerTeam and CF.DistUnder(actor.Pos, self.MissionExplorationPoint, 25) then
					if self:IsCommander(actor) then
						self.MissionExplorationText = self:GiveRandomExplorationReward()
						self.MissionExplorationRecovered = true

						self.MissionExplorationTextStart = self.Time

						for a in MovableMan.Actors do
							if a.Team ~= CF.PlayerTeam then
								CF.HuntForActors(a, CF.PlayerTeam)
							end
						end

						break
					else
						self:AddObjectivePoint(
							"Only a commander can decrypt this holorecord",
							self.MissionExplorationPoint + Vector(0, -30),
							CF.PlayerTeam,
							GameActivity.ARROWDOWN
						)
					end
				end
			end
		end
	end

	if self.Time > self.MissionExplorationTextStart and self.Time < self.MissionExplorationTextStart + 10 then
		local txt = ""
		for i = 1, #self.MissionExplorationText do
			txt = self.MissionExplorationText[i] .. "\n"
		end

		self:AddObjectivePoint(
			txt,
			self.MissionExplorationPoint + Vector(0, -30),
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
		local amount = math.floor(math.random(self.MissionDifficulty * 250, self.MissionDifficulty * 500))

		CF.SetPlayerGold(self.GS, 0, CF.GetPlayerGold(self.GS, 0) + amount)
		text = {}
		text[1] = "Bank account access codes found.\n" .. tostring(amount) .. "oz of gold received."
	elseif r == rewards.experience then
		local exppts = math.floor(math.random(self.MissionDifficulty * 75, self.MissionDifficulty * 150))
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
		local amount = math.floor(math.random(self.MissionDifficulty * 75, self.MissionDifficulty * 150))
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
	local pos = Vector(SceneMan.SceneWidth * 0.5, SceneMan.SceneHeight * 0.5)
	if self.GS["Mode"] == "Vessel" then
		local brain = self:GetPlayerBrain(Activity.PLAYER_1) or self:GetControlledActor(Activity.PLAYER_1)
		if brain then
			pos = brain.Pos
		end
	elseif self.GS["Mode"] == "Mission" then
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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:StartMusic(musictype)
	print("VoidWanderers:StartMusic")
	local ok = false
	local counter = 0
	local track = -1
	local queue = false

	-- Queue defeat or victory loops
	if musictype == CF.MusicTypes.VICTORY then
		AudioMan:PlayMusic("Base.rte/Music/dBSoundworks/uwinfinal.ogg", 1, -1)
		queue = true
		print("MUSIC: Play victory")
	elseif musictype == CF.MusicTypes.DEFEAT then
		AudioMan:PlayMusic("Base.rte/Music/dBSoundworks/udiedfinal.ogg", 1, -1)
		queue = true
		print("MUSIC: Play defeat")
	elseif musictype == -1 then
		return self:PlayMusicFile(
			"VoidWanderers.rte/UI/ControlPanels/Control" .. "Panel_" .. "Shop" .. ".png",
			false,
			-1
		)
	end

	-- Select calm music to queue after victory or defeat
	if self.LastMusicType ~= -1 and queue then
		if self.LastMusicType == CF.MusicTypes.SHIP_CALM or self.LastMusicType == CF.MusicTypes.SHIP_INTENSE then
			musictype = CF.MusicTypes.SHIP_CALM
		end

		if self.LastMusicType == CF.MusicTypes.MISSION_CALM or self.LastMusicType == CF.MusicTypes.MISSION_INTENSE then
			musictype = CF.MusicTypes.MISSION_CALM
		end
	end

	while not ok do
		ok = true
		if CF.Music and CF.Music[musictype] then
			track = math.random(1, #CF.Music[musictype])

			if musictype ~= self.LastMusicType and #CF.Music[musictype] > 1 then
				if track == self.LastMusicTrack then
					ok = false
				end
			end
			--print (track)
			--print (CF.Music[musictype][track])
		end

		counter = counter + 1
		if counter > 5 then
			print("BREAK")
			break
		end
	end

	-- If we're playing intense music, then just queue it once and play ambient all the other times
	if ok and CF.Music[musictype] then
		if musictype == CF.MusicTypes.SHIP_INTENSE or musictype == CF.MusicTypes.MISSION_INTENSE then
			self:PlayMusicFile(CF.Music[musictype][track], false, 1)
			print("MUSIC: Queue intense")
		else
			self:PlayMusicFile(CF.Music[musictype][track], queue, -1)
			if queue then
				print("MUSIC: Queue calm")
			else
				print("MUSIC: Play calm")
			end
		end
	end

	-- Then add a calm music after an intense
	if musictype == CF.MusicTypes.SHIP_INTENSE or musictype == CF.MusicTypes.MISSION_INTENSE then
		if musictype == CF.MusicTypes.SHIP_INTENSE then
			musictype = CF.MusicTypes.SHIP_CALM
		end

		if musictype == CF.MusicTypes.MISSION_INTENSE then
			musictype = CF.MusicTypes.MISSION_CALM
		end

		local ok = false
		local counter = 0

		while not ok do
			ok = true

			track = math.random(#CF.Music[musictype])

			if musictype ~= self.LastMusicType and #CF.Music[musictype] > 1 then
				if track == self.LastMusicTrack then
					ok = false
				end
			end

			counter = counter + 1
			if counter > 5 then
				print("BREAK")
				break
			end
		end
		if ok then
			self:PlayMusicFile(CF.Music[musictype][track], true, -1)
			print("MUSIC: Queue calm")
		end
	end

	self.LastMusicType = musictype
	self.LastMusicTrack = track
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:PlayMusicFile(path, queue, count)
	if CF.IsFilePathExists(path) then
		if queue then
			AudioMan:QueueMusicStream(path)
		else
			AudioMan:ClearMusicQueue()
			AudioMan:PlayMusic(path, count, -1)
		end
		return true
	else
		print("ERR: Can't find music: " .. path)
		return false
	end
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
