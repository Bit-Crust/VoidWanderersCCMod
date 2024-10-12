-----------------------------------------------------------------------------------------
--	Objective: 	Kill all invading reavers.
--	Events: 	
--
-----------------------------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("REAVERS CREATE")

	self.encounterData["reaversAct"] = { "Reaver", "Bone Reaver" }
	self.encounterData["reaversActMod"] = { "VoidWanderers.rte", "VoidWanderers.rte" }

	self.encounterData["reaversLight"] = { "JPL 10 Auto", "K-LDP 7.7mm" }
	self.encounterData["reaversLightMod"] = { "VoidWanderers.rte", "VoidWanderers.rte" }

	self.encounterData["reaversHeavy"] = { "K-HAR 10mm", "Shrike Mdl.G", "PBL Maw" }
	self.encounterData["reaversHeavyMod"] = { "VoidWanderers.rte", "VoidWanderers.rte", "VoidWanderers.rte" }

	self.encounterData["reaversThrown"] = { "M67 Grenade", "M24 Potato Masher", "Molotov Cocktail", "Scrambler" }
	self.encounterData["reaversThrownMod"] = { "Ronin.rte", "Ronin.rte", "Ronin.rte", "Ronin.rte" }

	self.encounterData["reaversInterval"] = 8

	local id = CF.Vessel[math.random(#CF.Vessel)]

	id = (id == "Mule") and "Titan" or id

	self.encounterData["speed"] = math.random(
		CF.VesselStartSpeed[id],
		math.max(math.ceil(CF.VesselMaxSpeed[id] * 0.5), CF.VesselStartSpeed[id])
	) + 1

	self.encounterData["distance"] = math.random(300, 400) - self.encounterData["speed"]
	self.encounterData["maxDistance"] = math.random(400, 500)
	-- Eat the rich!
	self.encounterData["playerGoldScalar"] = math.sqrt(1 + CF.GetPlayerGold(self.GS, 0) * 0.001)
	local maxCapacity = math.ceil(CF.VesselMaxClonesCapacity[id] * 0.5)
	local minCapacity = math.ceil(math.max(maxCapacity * 0.5, CF.VesselStartClonesCapacity[id] * 0.5))
	self.encounterData["reaversUnitCount"] = math.random(minCapacity, maxCapacity)
	self.encounterData["difficulty"] = math.min(
		math.max(math.floor(self.encounterData["reaversUnitCount"] * 0.2), 0),
		CF.MaxDifficulty
	)
	
	local message = "";
	if self.encounterData["playerGoldScalar"] > 25 then
		message = "The Reavers can smell your money! An incoming "
			.. CF.VesselName[id]
			.. " class ship has been detected, hiding will not be easy..."
	elseif self.encounterData["playerGoldScalar"] > 10 then
		message = "The Reavers are after our gold! An incoming "
			.. CF.VesselName[id]
			.. " class ship has been detected, what should we do?"
	else
		message = "An unknown "
			.. CF.VesselName[id]
			.. " class ship detected, it must be Reavers!! If we hide everything, they might think it's a dead ship."
	end
	local options = { "Fight the bastards!", "Stay low", "RUN!!!" };
	self:SendTransmission(message, options);

	self.encounterData["scanTimeMax"] = math.ceil(math.random(20, 25) / math.sqrt(self.encounterData["difficulty"]))
	self.encounterData["scanTime"] = math.random(
		math.min(CF.CountActors(CF.PlayerTeam) * 5 + 10, self.encounterData["scanTimeMax"] - 1),
		self.encounterData["scanTimeMax"]
	)

	self.encounterData["dir"] = -1
	if SceneMan.Scene:HasArea("LeftGates") then
		if SceneMan.Scene:HasArea("RightGates") and math.random() < 0.5 then
			self.encounterData["gates"] = SceneMan.Scene:GetArea("RightGates")
			self.encounterData["dir"] = 1
		else
			self.encounterData["gates"] = SceneMan.Scene:GetArea("LeftGates")
		end
	elseif SceneMan.Scene:HasArea("RightGates") then
		self.encounterData["gates"] = SceneMan.Scene:GetArea("RightGates")
		self.encounterData["dir"] = 1
	end
	self.encounterData["shotCount"] = 0
	local centerGates = self.encounterData["gates"]:GetCenterPoint()
	if self.encounterData["gates"] then
		for actor in MovableMan.Actors do
			if
				actor.ClassName == "ADoor"
				and SceneMan:ShortestDistance(actor.Pos, centerGates, false):MagnitudeIsLessThan(actor.Radius)
			then
				self.encounterData["shotCount"] = self.encounterData["shotCount"] + 1
			end
		end
	end
	self.encounterData["gatesDistance"] = SceneMan:ShortestDistance(
		centerGates,
		Vector(self.encounterData["dir"] == 1 and SceneMan.SceneWidth or 0, centerGates.Y),
		false
	).Magnitude

	self.encounterData["attackLaunched"] = false
	self.encounterData["scanLaunched"] = false
	self.encounterData["runLaunched"] = false
	self.encounterData["fightSelected"] = false
	self.encounterData["abortChase"] = false
	self.encounterData["isInitialized"] = true

	self.vesselData["flightDisabled"] = true
	self.vesselData["flightAimless"] = true
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()

	if self.encounterData["encounterStartTime"] > self.Time then
		if self.Time % 2 == 0 then
			self:MakeAlertSound(1 / math.max(self.encounterData["encounterStartTime"] - self.Time / 30, 1))
		end
	end

	local variant = self.vesselData["dialogOptionChosen"];
	if variant == 1 then
		self:SendTransmission("BATTLE STATIONS!!!", {});
		self.encounterData["fightSelected"] = true
		self.encounterData["runLaunched"] = true
		self.encounterData["runStarted"] = self.Time
		self.encounterData["chaseTimer"] = Timer()
		
		self.vesselData["flightDisabled"] = false
	end

	if variant == 2 then
		self:SendTransmission("They are scanning us...", {});
		self.encounterData["scanLaunched"] = true
		self.encounterData["ScanStarted"] = self.Time
	end

	if variant == 3 then
		self:SendTransmission("Let's pray we're faster...", {});
		self.encounterData["BoostTriggered"] = false
		self.encounterData["runLaunched"] = true
		self.encounterData["runStarted"] = self.Time
		self.encounterData["chaseTimer"] = Timer()
		
		self.vesselData["flightDisabled"] = false
	end

	if self.encounterData["scanLaunched"] == true then
		local prob = math.min(
			math.floor(
				self.encounterData["playerGoldScalar"]
					+ CF.CountActors(CF.PlayerTeam) * math.max(self.encounterData["playerGoldScalar"], 5)
			),
			99
		)

		local progress = self.Time - self.encounterData["ScanStarted"]

		FrameMan:SetScreenText(
			"Scan progress "
				.. math.floor(progress / self.encounterData["scanTimeMax"] * 100)
				.. "%\nProbability of being detected: "
				.. prob
				.. "%",
			0,
			0,
			1500,
			true
		)

		if self.Time >= self.encounterData["ScanStarted"] + self.encounterData["scanTime"] then
			if math.random(100) < prob then
				self:SendTransmission("BATTLE STATIONS!!!", {});
				self.encounterData["Text"] = "BATTLE STATIONS!!!"
				self.encounterData["Variants"] = {}
				self.vesselData["dialogOptionChosen"] = 0
				self.encounterData["runLaunched"] = true
				self.encounterData["scanLaunched"] = false
				self.encounterData["runStarted"] = self.Time
				self.encounterData["fightSelected"] = true
				self.encounterData["chaseTimer"] = Timer()
			else
				self.MissionReport = {}
				self.MissionReport[#self.MissionReport + 1] = prob > 90 and "They must be blind..."
					or "We tricked them. Lucky we are."
				CF.SaveMissionReport(self.GS, self.MissionReport)

				self.encounterData["encounterConcluded"] = true
				self.vesselData["flightDisabled"] = false
				self.vesselData["flightAimless"] = false
				self.vesselData["dialog"] = nil
				self:RemoveDeployedTurrets()
			end
		end
	end

	if self.encounterData["runLaunched"] == true then
		FrameMan:SetScreenText("\nDistance: " .. self.encounterData["distance"] .. "km", 0, 0, 1500, true)

		if self.encounterData["chaseTimer"]:IsPastSimMS(350) then
			if self.encounterData["fightSelected"] then
				self.encounterData["distance"] = self.encounterData["distance"] - self.encounterData["speed"]
			else
				self.encounterData["distance"] = self.encounterData["distance"]
					- self.encounterData["speed"]
					+ tonumber(self.GS["PlayerVesselSpeed"])
			end
			self.encounterData["chaseTimer"]:Reset()

			-- Boost reavers if they're too far
			if not self.encounterData["BoostTriggered"] then
				if
					self.encounterData["distance"] > self.encounterData["maxDistance"]
					or self.encounterData["speed"] == tonumber(self.GS["PlayerVesselSpeed"])
				then
					self.encounterData["BoostTriggered"] = true
					self.encounterData["speed"] = self.encounterData["speed"]
						+ math.floor(math.random(4) * self.encounterData["playerGoldScalar"])
					self.encounterData["Text"] = (math.random() < 0.5 and "Oh crap" or "O kurwa")
						.. ", they overloaded their reactor to boost the engines!!!"

					if self.encounterData["speed"] <= tonumber(self.GS["PlayerVesselSpeed"]) then
						self.encounterData["abortChase"] = true
					end
				end
			end

			-- Stop chasing if it's too long
			if not self.encounterData["fightSelected"] then
				if
					(self.Time > self.encounterData["runStarted"] + 40 and self.encounterData["distance"] > 150)
					or self.encounterData["distance"] > self.encounterData["maxDistance"] + 100
					or self.encounterData["abortChase"]
				then
					self.MissionReport = {}
					self.MissionReport[#self.MissionReport + 1] = "They stopped chasing us. Lucky we are."
					CF.SaveMissionReport(self.GS, self.MissionReport)

					self.encounterData["encounterConcluded"] = true
					self.vesselData["flightDisabled"] = false
					self.vesselData["flightAimless"] = false
					self.vesselData["dialog"] = nil
					self:RemoveDeployedTurrets()
				end
			end

			if self.encounterData["distance"] <= 0 then
				self.encounterData["attackLaunched"] = true
				self.encounterData["runLaunched"] = false
				self.encounterData["NextAttackTime"] = self.Time

				--Deploy turrets
				self:DeployTurrets()

				-- Disable consoles
				self:DestroyStorageControlPanelUI()
				self:DestroyBeamControlPanelUI()
				self:DestroyTurretsControlPanelUI()
			end
		end
	end

	if self.encounterData["attackLaunched"] then
		if self.Time % 10 == 0 and self.encounterData["reaversUnitCount"] > 0 then
			FrameMan:SetScreenText("Remaining Reavers: " .. self.encounterData["reaversUnitCount"], 0, 0, 1500, true)
		end
		local centerGates = self.encounterData["gates"]:GetCenterPoint()
		if self.Time >= self.encounterData["NextAttackTime"] then
			self.encounterData["NextAttackTime"] = self.Time + self.encounterData["reaversInterval"]

			-- Create assault bot
			if MovableMan:GetMOIDCount() < CF.MOIDLimit and self.encounterData["reaversUnitCount"] > 0 then
				local rocket = CreateACRocket("Reaver Rocklet")
				if rocket then
					rocket.HFlipped = rocket.RandomEncounterDir == 1
					rocket.Pos = Vector(
						(self.encounterData["dir"] == 1 and SceneMan.SceneWidth + 1 or -1),
						centerGates.Y + math.random(rocket.Radius * RangeRand(-1, 1))
					)
					rocket.Vel = Vector(-math.random(8, 16) * self.encounterData["dir"], 0)
					rocket.RotAngle = math.pi * 0.49 * self.encounterData["dir"]

					rocket.Team = CF.CPUTeam
					rocket.AIMode = Actor.AIMODE_DELIVER
					rocket.Health = math.random(33, 66)

					for i = 1, 2 do
						if self.encounterData["reaversUnitCount"] > 0 then
							local r1 = math.random(#self.encounterData["reaversAct"])
							local r2 = math.random(#self.encounterData["reaversLight"])
							local r3 = math.random(#self.encounterData["reaversHeavy"])
							local r4 = math.random(#self.encounterData["reaversThrown"])

							local actor = CreateAHuman(
								self.encounterData["reaversAct"][r1],
								self.encounterData["reaversActMod"][r1]
							)
							if actor then
								actor.Team = CF.CPUTeam
								actor.RotAngle = rocket.RotAngle
								actor.HFlipped = rocket.HFlipped
								actor.Jetpack.JetTimeTotal = actor.Jetpack.JetTimeTotal * 3

								if math.random() < 0.3 then
									if math.random() < 0.5 then
										local arm = CreateArm("Prosthetic Arm FG")
										if actor.FGArm then
											arm.ParentOffset = actor.FGArm.ParentOffset
										end
										arm:AddScript("VoidWanderers.rte/Items/Salvage.lua")
										actor.FGArm = arm
									else
										local arm = CreateArm("Prosthetic Arm BG")
										if actor.BGArm then
											arm.ParentOffset = actor.BGArm.ParentOffset
										end
										arm:AddScript("VoidWanderers.rte/Items/Salvage.lua")
										actor.BGArm = arm
									end
								end
								if math.random() < 0.3 then
									if math.random() < 0.5 then
										local leg = CreateLeg("Prosthetic Leg FG")
										if actor.FGLeg then
											leg.ParentOffset = actor.FGLeg.ParentOffset
										end
										leg:AddScript("VoidWanderers.rte/Items/Salvage.lua")
										actor.FGLeg = leg
									else
										local leg = CreateLeg("Prosthetic Leg BG")
										if actor.BGLeg then
											leg.ParentOffset = actor.BGLeg.ParentOffset
										end
										leg:AddScript("VoidWanderers.rte/Items/Salvage.lua")
										actor.BGLeg = leg
									end
								end

								local itm

								if math.random() < 0.01 then
									itm = CreateHDFirearm(
										math.random() < 0.3 and "Lazor Rifle" or "YAK-4700",
										self.ModuleName
									)
								else
									itm = CreateHDFirearm(
										self.encounterData["reaversHeavy"][r3],
										self.encounterData["reaversHeavyMod"][r3]
									)
								end
								if itm then
									actor:AddInventoryItem(itm)
								end

								itm = CreateHDFirearm(
									self.encounterData["reaversLight"][r2],
									self.encounterData["reaversLightMod"][r2]
								)
								if itm then
									actor:AddInventoryItem(itm)
								end
								itm = math.random() < 0.1 and CreateTDExplosive("Timed Explosive", "Coalition.rte")
									or CreateTDExplosive(
										self.encounterData["reaversThrown"][r4],
										self.encounterData["reaversThrownMod"][r4]
									)
								if itm then
									actor:AddInventoryItem(itm)
								end

								rocket:AddInventoryItem(actor)
								self.encounterData["reaversUnitCount"] = self.encounterData["reaversUnitCount"] - 1
							end
						end
					end

					MovableMan:AddActor(rocket)
					-- Shoot rockets at doors
					if self.encounterData["shotCount"] > 0 then
						local startPos = rocket.Pos + Vector(0, rocket.Radius * (math.random() < 0.5 and -1 or 1))
						local findMO = MovableMan:GetMOFromID(
							SceneMan:CastMORay(
								startPos,
								Vector(-(50 + self.encounterData["gatesDistance"]), 0),
								rocket.ID,
								CF.CPUTeam,
								rte.grassID,
								true,
								5
							)
						)
						if findMO and findMO:GetRootParent().ClassName == "ADoor" then
							local expl = CreateAEmitter("Reaver RPG")
							expl.Team = CF.CPUTeam
							expl.IgnoresTeamHits = true
							expl.Pos = startPos
							expl.LifeTime = self.encounterData["gatesDistance"]
							expl.Vel.X = -math.random(40, 45) * self.encounterData["dir"]
							expl.RotAngle = expl.Vel.AbsRadAngle
							MovableMan:AddParticle(expl)
							self.encounterData["shotCount"] = self.encounterData["shotCount"] - 1
						end
					end

					self.encounterData["Rocket"] = rocket
				end
			end
		end

		if self.encounterData["Rocket"] then
			if MovableMan:IsActor(self.encounterData["Rocket"]) then
				local rocket = ToACRocket(self.encounterData["Rocket"])
				local empty = rocket:IsInventoryEmpty()
				local boundsDist = self.encounterData["gatesDistance"] * 0.8 - 150
				if
					(
						self.vesselData["ship"]:IsInside(rocket.Pos)
						or not (rocket.Pos.X > SceneMan.SceneWidth - boundsDist or rocket.Pos.X < boundsDist)
					) and not empty
				then
					rocket:OpenHatch()
				end
				--if rocket.MainEngine then rocket.MainEngine:EnableEmission(true) end
				local cont = rocket:GetController()

				cont:SetState(Controller.MOVE_DOWN, empty or rocket.Vel.X * -self.encounterData["dir"] > 20)
				cont:SetState(Controller.MOVE_UP, not empty and rocket.Vel.X * -self.encounterData["dir"] < 10)
				cont:SetState(Controller.MOVE_RIGHT, false)

				local healthFactor = 1 - math.max(rocket.Health / rocket.MaxHealth, 0) * 0.5
				if empty then
					cont:SetState(Controller.MOVE_LEFT, true)
				else
					rocket.Vel = Vector(rocket.Vel.X, rocket.Vel.Y * healthFactor)
					rocket.AngularVel = rocket.AngularVel * healthFactor

					cont:SetState(Controller.MOVE_LEFT, false)
				end

				local futurePos = rocket.Pos + rocket.Vel * rte.PxTravelledPerFrame
				if self.encounterData["gates"] and self.encounterData["gates"]:IsInside(rocket.Pos) then
					rocket.Health = rocket.Health - 1
				elseif not SceneMan:IsWithinBounds(futurePos.X, futurePos.Y, 100) and math.random() > healthFactor then
					-- The rocket made it to safety, add an extra Reaver
					self.encounterData["reaversUnitCount"] = self.encounterData["reaversUnitCount"] + 1
					rocket.ToDelete = true
				end
			else
				self.encounterData["Rocket"] = nil
			end
		end

		-- Check winning conditions
		if
			self.encounterData["reaversUnitCount"] <= 0
			and self.encounterData["Rocket"] == nil
			and CF.CountActors(CF.CPUTeam) == 0
		then
			self.MissionReport = {}
			self.MissionReport[#self.MissionReport + 1] = "Those were the last of them."

			self:GiveRandomExperienceReward(self.encounterData["difficulty"])
			

			-- Finish encounter
			self.encounterData["encounterConcluded"] = true
			self.vesselData["flightDisabled"] = false
			self.vesselData["flightAimless"] = false
			self.vesselData["dialog"] = nil
			self:RemoveDeployedTurrets()
			CF.SaveMissionReport(self.GS, self.MissionReport)
			-- Rebuild destroyed consoles
			self:InitStorageControlPanelUI()
			--self:InitClonesControlPanelUI()
			self:InitBeamControlPanelUI()
			self:InitTurretsControlPanelUI()
		else
			for actor in MovableMan.Actors do
				local boundsDist = self.encounterData["gatesDistance"] - actor.IndividualRadius
				--Reavers in danger of flying out of bounds
				if actor.Team == CF.CPUTeam and IsAHuman(actor) and not self.vesselData["ship"]:IsInside(actor.Pos) then --(actor.Pos.X > SceneMan.SceneWidth - boundsDist or actor.Pos.X < boundsDist) then
					local active = actor.Status < Actor.INACTIVE
					if active then
						actor.Status = Actor.UNSTABLE
					end
					if active and actor.Age < 6000 then
						actor.Status = Actor.UNSTABLE
						actor.HFlipped = self.encounterData["dir"] == 1
						actor.AngularVel = actor.AngularVel
							+ math.sin(actor.RotAngle - math.pi * 0.5 * actor.FlipFactor)
								/ (1 + math.abs(actor.AngularVel))
						if (actor.Vel.X + actor.PrevVel.X) * actor.FlipFactor < 5 then
							actor:GetController():SetState(Controller.BODY_JUMP, true)
							actor.Vel.Y = actor.Vel.Y + (centerGates.Y - actor.Pos.Y) / (250 + actor.Vel.Magnitude * 25)
						end
						boundsDist = boundsDist * 0.5
						if
							(
								actor.Pos.X > SceneMan.SceneWidth - boundsDist
								or actor.Pos.X < boundsDist
								or actor.Age > 1500
							) and not actor:NumberValueExists("GrapplingReaver")
						then
							local grapple = CreateMOSRotating("Reaver Grapple Hook")
							grapple.Pos = actor.Pos
							grapple.Sharpness = actor.ID
							grapple.Team = actor.Team
							grapple.Vel = actor.Vel * 0.5
								+ SceneMan
									:ShortestDistance(actor.Pos, centerGates, SceneMan.SceneWrapsX)
									:RadRotate(RangeRand(-0.2, 0.2))
									:SetMagnitude(30)
							grapple.RotAngle = grapple.Vel.AbsRadAngle
							MovableMan:AddParticle(grapple)
							actor:SetNumberValue("GrapplingReaver", 1)

							actor.Vel.Y = actor.Vel.Y * 0.5
							actor.AngularVel = actor.AngularVel * 0.5
							actor.HFlipped = self.encounterData["dir"] == 1
							actor.AIMode = Actor.AIMODE_GOTO
							actor:AddAIMOWaypoint(
								self:GetPlayerBrain(Activity.PLAYER_1) or self:GetPlayerBrain(Activity.PLAYER_2)
							)
						end
					else
						actor.AngularVel = actor.AngularVel
							- self.encounterData["dir"] / (1 + math.abs(actor.AngularVel) / (1 + actor.Vel.Magnitude))
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------