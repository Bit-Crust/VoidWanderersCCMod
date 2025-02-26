-----------------------------------------------------------------------
--	Objective: 	Do not die, optionally investigate.
--	Events: 	This is gonna mess you up.
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("HOSTILE DRONE ENCOUNTER CREATE");

	local encounterData = self.encounterData;
	encounterData["droneAlerted"] = false;
	encounterData["droneCharges"] = math.max(10 - math.floor(tonumber(self.GS["PlayerVesselSpeed"]) * 0.1 + 0.5), 1);
	encounterData["droneShotsFired"] = 0;
	encounterData["droneShotInterval"] = 0;
	encounterData["droneChargeInterval"] = 3;
	encounterData["droneNoTarget"] = true;
	encounterData["droneSourcePos"] = Vector(SceneMan.SceneWidth / 2 + math.random(-200, 200), SceneMan.SceneHeight / 2 + 1000 * (1 - 2 * math.random(0, 1)));
	encounterData["droneInitialVelocity"] = Vector(1 / 3, math.random() * 1 / 2 / 3);
	encounterData["droneTargetPos"] = nil;
	encounterData["droneTargetAngle"] = nil;
	encounterData["droneTargetImpactZone"] = nil;
	encounterData["droneNextShot"] = 0;
	encounterData["encounterStage"] = 0;

	local message = "We have detected a pre-historic assault drone is floating nearby. We don't know if it is dead or not.";
	local options = {"Initiate evasive maneuvers!", "Just ignore the damn thing.", "Get closer. Why not?"};
	self:SendTransmission(message, options);
	self:GiveFocusToBridge();
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	local encounterData = self.encounterData;
	local concludeEncounter = false;
	local conclusionMessage = "";

	if encounterData["encounterStage"] == 0 then
		local variant = self.vesselData["dialogOptionChosen"];

		if variant == 1 then
			if math.random(50) < tonumber(self.GS["PlayerVesselSpeed"]) then
				concludeEncounter = true;
				conclusionMessage = "Got away safely!";
			elseif math.random(2) == 1 then
				local message = "The drone is charging its weapons, move units deeper inside the ship!";
				self:SendTransmission(message, {});
				encounterData["droneAlerted"] = true;
				encounterData["droneNextShot"] = self.Time + 18;
			else
				concludeEncounter = true;
				conclusionMessage = "Looks like it was dead after all.";
			end
		end
	
		if variant == 2 then
			if math.random(2) == 1 then
				local message = "Shit, its readying its weapons! Move deeper inside the ship! INCOMING!";
				self:SendTransmission(message, {});
			
				encounterData["droneAlerted"] = true;
				encounterData["droneNextShot"] = self.Time + 6;
				encounterData["droneCharges"] = encounterData["droneCharges"] + 1;
			else
				concludeEncounter = true;
				conclusionMessage = "Looks like it could not detect us. Phew...";
			end
		end
	
		if variant == 3 then
			local message = "Really done it now! Its readying its weapons! Move deeper inside the ship!";
			self:SendTransmission(message, {});
			
			encounterData["droneAlerted"] = true;
			encounterData["droneNextShot"] = self.Time + 4;
			encounterData["droneCharges"] = encounterData["droneCharges"] + 4;
		end
	end
	
	if encounterData["droneNoTarget"] then
		local actorTable = {};
		
		for actor in MovableMan.Actors do
			if CF.IsCommonUnit(actor) and actor.Team == CF.PlayerTeam then
				table.insert(actorTable, actor);
			end
		end
		
		local t;
		if #actorTable > 0 and math.random() > 0.7 then 
			local r = math.random(#actorTable);
			t = actorTable[r].Pos;
		else
			t = self.vesselData["ship"]:GetRandomPoint();
		end
		
		encounterData["droneTargetPos"] = Vector(t.X, t.Y)
		encounterData["droneTargetAngle"] = (t - encounterData["droneSourcePos"]).AbsRadAngle
		encounterData["droneTargetImpactZone"] = Vector()
		
		local lastgood = Vector()
		local pos = Vector()
		
		for rds = 1, 5000, 50 do
			pos = encounterData["droneTargetPos"] + Vector(-math.cos(encounterData["droneTargetAngle"]) * rds, -math.sin(encounterData["droneTargetAngle"]) * rds)
			if pos.X < 10 or pos.Y < 10 or pos.X > SceneMan.Scene.Width - 10 or pos.Y > SceneMan.Scene.Height - 10 then
				break
			else
				encounterData["fireOrigin"] = pos
			end
		end
		
		SceneMan:CastStrengthRay(encounterData["fireOrigin"], encounterData["droneTargetPos"] - encounterData["fireOrigin"], 10, encounterData["droneTargetImpactZone"], 6, -1, true);
		encounterData["droneNoTarget"] = false;
	end
	
	if encounterData["droneAlerted"] then
		encounterData["droneSourcePos"] = encounterData["droneSourcePos"] + encounterData["droneInitialVelocity"]	
		encounterData["droneTargetAngle"] = (encounterData["droneTargetPos"] - encounterData["droneSourcePos"]).AbsRadAngle

		if self.Time > encounterData["droneNextShot"] - encounterData["droneChargeInterval"] then
			for i = encounterData["droneShotsFired"] , 2 do
				local a = encounterData["droneTargetAngle"]
				self:AddObjectivePoint("DANGER!!!", encounterData["droneTargetImpactZone"] + Vector(-math.cos(a + math.pi) * (i * 50), -math.sin(a + math.pi) * (i * 50)) , CF.PlayerTeam, GameActivity.ARROWDOWN)
			end
		end
		
		if self.Time >= encounterData["droneNextShot"] then
			local a = encounterData["droneTargetAngle"]
	
			for i = 1, 25 do
				local expl = CreateAEmitter("Destroyer Cannon Shot")
				expl.Pos = encounterData["fireOrigin"] + Vector(-math.cos(a + math.pi) * (i * 10), -math.sin(a + math.pi) * (i * 10))
				
				expl.Vel = Vector(-math.cos(a + math.pi) * 150, -math.sin(a + math.pi) * 150)
				expl.Mass = 1000000
				MovableMan:AddParticle(expl)
			end
			
			encounterData["droneShotsFired"] = encounterData["droneShotsFired"] + 1
			
			if encounterData["droneShotsFired"] == 1 then
				encounterData["droneShotsFired"] = 0
				encounterData["droneNoTarget"] = true
				encounterData["droneCharges"] = encounterData["droneCharges"] - 1
				
				if encounterData["droneCharges"] == 0 then
					self.reportData = {}
					self.reportData[#self.reportData + 1] = "The drone overloaded its' reactorTable and exploded."
					self:GiveRandomExperienceReward()
					CF.SaveMissionReport(self.GS, self.reportData)
				
					-- Finish encounter
					self.RandomEncounterID = nil
				end
				
				encounterData["droneNextShot"] = self.Time + encounterData["droneChargeInterval"]
			else
				encounterData["droneNextShot"] = self.Time
			end
		end
	end

	if concludeEncounter then
		-- Report conclusion
		self.reportData = {};
		self.reportData[#self.reportData + 1] = conclusionMessage;
		CF.SaveMissionReport(self.GS, self.reportData);

		-- Finish encounter
		encounterData["encounterConcluded"] = true;
		self.vesselData["flightDisabled"] = false;
		self.vesselData["flightAimless"] = false;
		self.vesselData["lifeSupportEnabled"] = true;
		self.vesselData["dialog"] = nil;
		self.vesselData["beamEnabled"] = true;
		self:RemoveDeployedTurrets();
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------