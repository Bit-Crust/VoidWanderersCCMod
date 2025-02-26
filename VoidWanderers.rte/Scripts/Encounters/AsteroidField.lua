-----------------------------------------------------------------------
--	Objective: 	Survive the impending meteors.
--	Events: 	
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("ASTEROID FIELD CREATE");

	self.encounterData["asteroidTriggered"] = false;
	self.encounterData["asteroidCount"] = math.random(100, 200);
	self.encounterData["asteroidInterval"] = 1;
	self.encounterData["asteroidVelocity"] = 5;
	self.encounterData["asteroidNextTime"] = 0;

	local message = "We are intersecting a dense asteroid field! Advancing at current pace may damage the ship.";
	local options = { "Let's slow down.", "Full speed ahead!" };
	self:SendTransmission(message, options);
	self:GiveFocusToBridge();

	self.vesselData["flightDisabled"] = true;
	self.vesselData["flightAimless"] = true;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	if self.encounterData["encounterStartTime"] > self.Time then
		if self.Time % 2 == 0 then
			self:MakeAlertSound(1 / math.max(self.encounterData["encounterStartTime"] - self.Time / 3, 1));
		end
	end
	
	local variant = self.vesselData["dialogOptionChosen"];

	if variant == 1 then
		local reaction = {"Easy does it...", "Steady as she goes..."};
		self:SendTransmission(reaction[math.random(#reaction)], {});
		
		self.encounterData["asteroidInterval"] = 1;
		self.encounterData["asteroidSpawn"] = 5;
		self.encounterData["asteroidVelocity"] = 10;
		self.encounterData["asteroidTriggered"] = true;
		self.encounterData["asteroidNextTime"] = self.Time + 8;
		self.vesselData["flightDisabled"] = false;
		self.vesselData["flightAimless"] = false;

		if self.vesselData["engines"] ~= nil then
			self.vesselData["throttle"] = 0.2;
		end
	end

	if variant == 2 then
		local reaction = {"OOO KURWAAAAA!!", "DAVAI BLYAT!!", "OH MAN, OH GOD, OH MAN!!", "LEEROOOY JENKINNSSS!!", "GAME OVER MAN, GAME OVER!!"};
		local shipSpeed = tonumber(self.GS["PlayerVesselSpeed"]);
		reaction = math.random(100) < shipSpeed and reaction[math.random(#reaction)] or "BRACE FOR IMPACT!!";
		self:SendTransmission(reaction, {});
		
		self.encounterData["asteroidInterval"] = 0;
		self.encounterData["asteroidSpawn"] = 1;
		self.encounterData["asteroidVelocity"] = 40 + shipSpeed;
		self.encounterData["asteroidTriggered"] = true;
		self.encounterData["asteroidNextTime"] = self.Time + 4;
		self.vesselData["flightDisabled"] = false;
		self.vesselData["flightAimless"] = false;
	end
	
	if self.encounterData["asteroidTriggered"] then
		local asteroidsRemaining = self.encounterData["asteroidCount"] > 0;
		if self.Time >= self.encounterData["asteroidNextTime"] then
			if asteroidsRemaining then
				self.vesselData["dialogDefaultTimer"]:Reset();

				for i = 1, self.encounterData["asteroidSpawn"] do
					local asteroid;

					if math.random() < 0.01 then
						asteroid = CreateMOSRotating("Golden Asteroid " .. math.random(3), self.ModuleName)
					else
						asteroid = CreateMOSRotating("Asteroid " .. math.random(36), self.ModuleName)
					end

					if asteroid then
						asteroid.Pos = Vector(-25, SceneMan.SceneHeight * math.random());
						asteroid.Vel = Vector(self.encounterData["asteroidVelocity"], 0);
						asteroid.AngularVel = math.random(-0.1, 0.1);
						MovableMan:AddParticle(asteroid);
					end

					self.encounterData["asteroidCount"] = self.encounterData["asteroidCount"] - 1;
					self.encounterData["asteroidNextTime"] = self.Time + self.encounterData["asteroidInterval"]
				end
			end
		end

		if self.GS["Destination"] ~= nil or not asteroidsRemaining then
			self.reportData = {};
			self.reportData[#self.reportData + 1] = "Looks like we've made it through.";
			CF.SaveMissionReport(self.GS, self.reportData);

			self.encounterData["encounterConcluded"] = true;
			self.vesselData["flightDisabled"] = false;
			self.vesselData["flightAimless"] = false;
			self.vesselData["beamEnabled"] = true;
			self.vesselData["throttle"] = 1;
			self.vesselData["dialog"] = nil;
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------