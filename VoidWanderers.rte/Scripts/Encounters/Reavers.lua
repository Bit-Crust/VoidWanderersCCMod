-----------------------------------------------------------------------
--	Objective: 	Kill all invading reavers.
--	Events: 	
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("REAVERS CREATE");

	local encounterData = self.encounterData;

	encounterData["reaversAct"] = { "Reaver", "Bone Reaver" };
	encounterData["reaversActMod"] = { "MirandaZoneReavers.rte", "MirandaZoneReavers.rte" };
	encounterData["reaversLight"] = { "JPL 10 Auto", "K-LDP 7.7mm" };
	encounterData["reaversLightMod"] = { "MirandaZoneReavers.rte", "MirandaZoneReavers.rte" };
	encounterData["reaversHeavy"] = { "K-HAR 10mm", "Shrike Mdl.G", "PBL Maw" };
	encounterData["reaversHeavyMod"] = { "MirandaZoneReavers.rte", "MirandaZoneReavers.rte", "MirandaZoneReavers.rte" };
	encounterData["reaversThrown"] = { "M67 Grenade", "M24 Potato Masher", "Molotov Cocktail", "Scrambler" };
	encounterData["reaversThrownMod"] = { "Ronin.rte", "Ronin.rte", "Ronin.rte", "Ronin.rte" };
	encounterData["reaversInterval"] = 8;

	-- Pick one vessel that will contain at least one unit.
	local validVessels = {};
	for id = 1, #CF.Vessel do
		local name = CF.Vessel[id];
		local startUnits = math.ceil(CF.VesselStartClonesCapacity[name] * 0.5 + CF.VesselStartLifeSupport[name] * 0.5);
		local maxUnits = math.ceil(CF.VesselMaxClonesCapacity[name] * 0.5 + CF.VesselMaxLifeSupport[name] * 0.5);

		local startSpeed = CF.VesselStartSpeed[name];
		local maxSpeed = CF.VesselMaxSpeed[name];

		if maxUnits > 0 then
			table.insert(validVessels, {
				name = name,
				onboard = math.random(startUnits, maxUnits),
				speed = math.random(startSpeed, maxSpeed)
			});
		end
	end
	local vessel = validVessels[math.random(#validVessels)];

	-- Eat the rich! Boost difficulty based on player gold.
	encounterData["playerGoldScalar"] = math.sqrt(1 + CF.GetPlayerGold(self.GS, 0) * 0.001);

	encounterData["distance"] = math.random(300, 400);
	encounterData["triggerDistance"] = math.random(400, 500);
	encounterData["difficulty"] = math.min(CF.MaxDifficulty, math.max(0, math.floor(vessel.onboard * 0.2)));
	
	local message = "";
	if encounterData["playerGoldScalar"] > 25 then
		message = "The Reavers can smell your money! An incoming "
			.. vessel.name
			.. " class ship has been detected, hiding will not be easy...";
	elseif encounterData["playerGoldScalar"] > 10 then
		message = "The Reavers are after our gold! An incoming "
			.. vessel.name
			.. " class ship has been detected, what should we do?";
	else
		message = "An unknown "
			.. vessel.name
			.. " class ship detected, it must be Reavers!! If we hide everything, they might think it's a dead ship.";
	end

	encounterData["scanTimeMax"] = math.ceil(25 / math.sqrt(vessel.onboard));
	encounterData["scanTime"] = math.random(math.min(CF.CountActors(CF.PlayerTeam) * 5 + 10, encounterData["scanTimeMax"] - 1), encounterData["scanTimeMax"]);

	local scene = SceneMan.Scene;

	-- Try generating if we don't have a reasonable right gate
	if not scene:HasArea("Vessel Right Gates") then
		local screenRight = Vector(SceneMan.SceneWidth, SceneMan.SceneHeight / 2);
		local path = Vector(-10000, 0);

		local strike = Vector(0, 0);
		SceneMan:CastStrengthRay(screenRight, path, 100, strike, 4, 0);

		gates = Area("Vessel Right Gates");
		gates:AddBox(Box(strike - Vector(50, 50), 100, 100));

		scene:SetArea(gates);
	end

	local gates = scene:GetArea("Vessel Right Gates");

	local centerGates = gates:GetCenterPoint();

	encounterData["shotCount"] = 0;
	for actor in MovableMan.Actors do
		if IsADoor(actor) and SceneMan:ShortestDistance(actor.Pos, centerGates, false):MagnitudeIsLessThan(actor.Radius) then
			encounterData["shotCount"] = encounterData["shotCount"] + 1;
		end
	end

	local screenRight = Vector(SceneMan.SceneWidth, centerGates.Y);
	encounterData["gateDistance"] = SceneMan:ShortestDistance(centerGates, screenRight, false).Magnitude;

	encounterData["attackLaunched"] = false;
	encounterData["scanLaunched"] = false;
	encounterData["runLaunched"] = false;
	encounterData["fightSelected"] = false;
	encounterData["abortChase"] = false;
	encounterData["isInitialized"] = true;
	encounterData["vessel"] = vessel;
	encounterData["gates"] = gates;

	self.vesselData["flightDisabled"] = true;
	self.vesselData["flightAimless"] = true;

	local options = { "Fight the bastards!", "Stay low", "RUN!!!" };
	self:SendTransmission(message, options);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	local encounterData = self.encounterData;
	local vessel = encounterData["vessel"];

	if encounterData["encounterStartTime"] > self.Time then
		if self.Time % 2 == 0 then
			self:MakeAlertSound(1 / math.max((encounterData["encounterStartTime"] - self.Time) / 3, 1))
		end
	end

	local variant = self.vesselData["dialogOptionChosen"];
	if variant == 1 then
		self:SendTransmission("BATTLE STATIONS!!!", {});
		encounterData["fightSelected"] = true
		encounterData["runLaunched"] = true
		encounterData["runStarted"] = self.Time
		encounterData["chaseTimer"] = Timer()
		
		self.vesselData["flightDisabled"] = false
	end

	if variant == 2 then
		self:SendTransmission("They are scanning us...", {});
		encounterData["scanLaunched"] = true
		encounterData["ScanStarted"] = self.Time
	end

	if variant == 3 then
		self:SendTransmission("Let's pray we're faster...", {});
		encounterData["boostTriggered"] = false
		encounterData["runLaunched"] = true
		encounterData["runStarted"] = self.Time
		encounterData["chaseTimer"] = Timer()
		
		self.vesselData["flightDisabled"] = false
	end

	if encounterData["scanLaunched"] == true then
		local prob = math.min(
			math.floor(
				encounterData["playerGoldScalar"]
					+ CF.CountActors(CF.PlayerTeam) * math.max(encounterData["playerGoldScalar"], 5)
			),
			99
		)

		local progress = self.Time - encounterData["ScanStarted"]

		FrameMan:SetScreenText(
			"Scan progress "
				.. math.floor(progress / encounterData["scanTimeMax"] * 100)
				.. "%\nProbability of being detected: "
				.. prob
				.. "%",
			0,
			0,
			1500,
			true
		)

		if self.Time >= encounterData["ScanStarted"] + encounterData["scanTime"] then
			if math.random(100) < prob then
				self:SendTransmission("BATTLE STATIONS!!!", {});
				encounterData["Text"] = "BATTLE STATIONS!!!"
				encounterData["Variants"] = {}
				self.vesselData["dialogOptionChosen"] = 0
				encounterData["runLaunched"] = true
				encounterData["scanLaunched"] = false
				encounterData["runStarted"] = self.Time
				encounterData["fightSelected"] = true
				encounterData["chaseTimer"] = Timer()
			else
				self.MissionReport = {}
				self.MissionReport[#self.MissionReport + 1] = prob > 90 and "They must be blind..."
					or "We tricked them. Lucky we are."
				CF.SaveMissionReport(self.GS, self.MissionReport)

				encounterData["encounterConcluded"] = true
				self.vesselData["flightDisabled"] = false
				self.vesselData["flightAimless"] = false
				self.vesselData["dialog"] = nil
				self:RemoveDeployedTurrets()
			end
		end
	end

	if encounterData["runLaunched"] == true then
		FrameMan:SetScreenText("\nDistance: " .. math.floor(encounterData["distance"]) .. "km", 0, 0, 1500, true)

		if encounterData["chaseTimer"]:IsPastSimMS(350) then
			if encounterData["fightSelected"] then
				encounterData["distance"] = encounterData["distance"] - vessel.speed
			else
				encounterData["distance"] = encounterData["distance"]
					- vessel.speed
					+ tonumber(self.GS["PlayerVesselSpeed"])
			end
			encounterData["chaseTimer"]:Reset()

			-- Boost reavers if they're too far
			if not encounterData["boostTriggered"] then
				if
					encounterData["distance"] > encounterData["triggerDistance"]
					or vessel.speed == tonumber(self.GS["PlayerVesselSpeed"])
				then
					encounterData["boostTriggered"] = true
					vessel.speed = vessel.speed + math.floor(math.random(4) * encounterData["playerGoldScalar"])
					encounterData["Text"] = (math.random() < 0.5 and "Oh crap" or "O kurwa")
						.. ", they overloaded their reactor to boost the engines!!!"

					if vessel.speed <= tonumber(self.GS["PlayerVesselSpeed"]) then
						encounterData["abortChase"] = true
					end
				end
			end

			-- Stop chasing if it's too long
			if not encounterData["fightSelected"] then
				if
					(self.Time > encounterData["runStarted"] + 40 and encounterData["distance"] > 150)
					or encounterData["distance"] > encounterData["triggerDistance"] + 100
					or encounterData["abortChase"]
				then
					self.MissionReport = {}
					self.MissionReport[#self.MissionReport + 1] = "They stopped chasing us. Lucky we are."
					CF.SaveMissionReport(self.GS, self.MissionReport)

					encounterData["encounterConcluded"] = true
					self.vesselData["flightDisabled"] = false
					self.vesselData["flightAimless"] = false
					self.vesselData["dialog"] = nil
					self:RemoveDeployedTurrets()
				end
			end

			if encounterData["distance"] <= 0 then
				encounterData["attackLaunched"] = true
				encounterData["runLaunched"] = false
				encounterData["NextAttackTime"] = self.Time

				--Deploy turrets
				self:DeployTurrets()

				-- Disable consoles
				self:DestroyStorageControlPanelUI()
				self:DestroyBeamControlPanelUI()
				self:DestroyTurretsControlPanelUI()
			end
		end
	end

	if encounterData["attackLaunched"] then
		if self.Time % 10 == 0 and vessel.onboard > 0 then
			FrameMan:SetScreenText("Remaining Reavers: " .. vessel.onboard, 0, 0, 1500, true)
		end
		local centerGates = encounterData["gates"]:GetCenterPoint()
		if self.Time >= encounterData["NextAttackTime"] then
			encounterData["NextAttackTime"] = self.Time + encounterData["reaversInterval"]

			-- Create assault bot
			if MovableMan:GetMOIDCount() < CF.MOIDLimit and vessel.onboard > 0 then
				local rocket = CreateACRocket("Reaver Rocklet")
				if rocket then
					rocket.HFlipped = rocket.RandomEncounterDir == 1
					rocket.Pos = Vector(
						SceneMan.SceneWidth + 1,
						centerGates.Y + math.random(rocket.Radius * RangeRand(-1, 1))
					)
					rocket.Vel = Vector(-math.random(8, 16), 0)
					rocket.RotAngle = math.pi * 0.49

					rocket.Team = CF.CPUTeam
					rocket.AIMode = Actor.AIMODE_DELIVER
					rocket.Health = math.random(33, 66)

					for i = 1, 2 do
						if vessel.onboard > 0 then
							local r1 = math.random(#encounterData["reaversAct"])
							local r2 = math.random(#encounterData["reaversLight"])
							local r3 = math.random(#encounterData["reaversHeavy"])
							local r4 = math.random(#encounterData["reaversThrown"])

							local actor = CreateAHuman(
								encounterData["reaversAct"][r1],
								encounterData["reaversActMod"][r1]
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
										encounterData["reaversHeavy"][r3],
										encounterData["reaversHeavyMod"][r3]
									)
								end
								if itm then
									actor:AddInventoryItem(itm)
								end

								itm = CreateHDFirearm(
									encounterData["reaversLight"][r2],
									encounterData["reaversLightMod"][r2]
								)
								if itm then
									actor:AddInventoryItem(itm)
								end
								itm = math.random() < 0.1 and CreateTDExplosive("Timed Explosive", "Coalition.rte")
									or CreateTDExplosive(
										encounterData["reaversThrown"][r4],
										encounterData["reaversThrownMod"][r4]
									)
								if itm then
									actor:AddInventoryItem(itm)
								end

								rocket:AddInventoryItem(actor)
								vessel.onboard = vessel.onboard - 1
							end
						end
					end

					MovableMan:AddActor(rocket)

					-- Shoot rockets at doors
					if encounterData["shotCount"] > 0 then
						local startPos = rocket.Pos + Vector(0, rocket.Radius * (math.random() < 0.5 and -1 or 1))
						local findMO = MovableMan:GetMOFromID(
							SceneMan:CastMORay(
								startPos,
								Vector(-(50 + encounterData["gateDistance"]), 0),
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
							expl.LifeTime = encounterData["gateDistance"]
							expl.Vel.X = -math.random(40, 45)
							expl.RotAngle = expl.Vel.AbsRadAngle
							MovableMan:AddParticle(expl)
							encounterData["shotCount"] = encounterData["shotCount"] - 1
						end
					end

					encounterData["Rocket"] = rocket
				end
			end
		end

		if encounterData["Rocket"] then
			if MovableMan:IsActor(encounterData["Rocket"]) then
				local rocket = ToACRocket(encounterData["Rocket"])
				local empty = rocket:IsInventoryEmpty()
				local boundsDist = encounterData["gateDistance"] * 0.8 - 150
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

				cont:SetState(Controller.MOVE_DOWN, empty or rocket.Vel.X * -1 > 20)
				cont:SetState(Controller.MOVE_UP, not empty and rocket.Vel.X * -1 < 10)
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
				if encounterData["gates"] and encounterData["gates"]:IsInside(rocket.Pos) then
					rocket.Health = rocket.Health - 1
				elseif not SceneMan:IsWithinBounds(futurePos.X, futurePos.Y, 100) and math.random() > healthFactor then
					-- The rocket made it to safety, add an extra Reaver
					vessel.onboard = vessel.onboard + 1
					rocket.ToDelete = true
				end
			else
				encounterData["Rocket"] = nil
			end
		end

		-- Check winning conditions
		if
			vessel.onboard <= 0
			and encounterData["Rocket"] == nil
			and CF.CountActors(CF.CPUTeam) == 0
		then
			self.MissionReport = {}
			self.MissionReport[#self.MissionReport + 1] = "Those were the last of them."

			self:GiveRandomExperienceReward(encounterData["difficulty"])
			

			-- Finish encounter
			encounterData["encounterConcluded"] = true
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
				local boundsDist = encounterData["gateDistance"] - actor.IndividualRadius
				--Reavers in danger of flying out of bounds
				if actor.Team == CF.CPUTeam and IsAHuman(actor) and not self.vesselData["ship"]:IsInside(actor.Pos) then --(actor.Pos.X > SceneMan.SceneWidth - boundsDist or actor.Pos.X < boundsDist) then
					local active = actor.Status < Actor.INACTIVE
					if active then
						actor.Status = Actor.UNSTABLE
					end
					if active and actor.Age < 6000 then
						actor.Status = Actor.UNSTABLE
						actor.HFlipped = true
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
							actor.HFlipped = true
							actor.AIMode = Actor.AIMODE_GOTO
							actor:AddAIMOWaypoint(
								self:GetPlayerBrain(Activity.PLAYER_1) or self:GetPlayerBrain(Activity.PLAYER_2)
							)
						end
					else
						actor.AngularVel = actor.AngularVel
							- 1 / (1 + math.abs(actor.AngularVel) / (1 + actor.Vel.Magnitude))
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------