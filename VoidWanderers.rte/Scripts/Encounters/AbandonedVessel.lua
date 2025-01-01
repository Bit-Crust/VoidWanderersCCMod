-----------------------------------------------------------------------
--	Objective: 	Investigate, or do not investigate, the abandoned vessel.
--	Events: 	
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("ABANDONED VESSEL CREATE");

	local encounterData = self.encounterData;

	local locations = {};

	-- Find usable scene
	for i = 1, #CF.Location do
		local id = CF.Location[i];

		if CF.IsLocationHasAttribute(id, CF.LocationAttributeTypes.ABANDONEDVESSEL) then
			locations[#locations + 1] = id;
		end
	end

	encounterData["location"] = locations[math.random(#locations)];

	self.vesselData["flightDisabled"] = true;
	self.vesselData["flightAimless"] = true;

	local message = "A dead vessel floats in an asteroid field. It might have been abandoned for years, although that does not mean that it is empty.\n\nYou may deploy at will.";
	local options = {
		"Just cut off everything valuable from the hull.",
		"Leave it alone... we're going elsewhere.",
	};

	self:SendTransmission(message, options);
	self:GiveFocusToBridge();
	self.GS["Location"] = encounterData["location"];
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	local encounterData = self.encounterData;
	local variant = self.vesselData["dialogOptionChosen"];

	if variant == 1 then
		local devices = {
			"a zrbite reactor",
			"an elerium reactor",
			"a solar panel",
			"a warp projector",
			"an observation lens",
			"a hangar door",
			"a dust filter",
			"a neutrino collector",
			"a Higgs boson detector",
			"a microwave heater",
			"a coffee bean roaster",
		};

		if math.random() < 0.125 then
			local losstext;
			local r = math.random(5);

			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				FrameMan:FlashScreen(self:ScreenOfPlayer(player), 13, 1000);
			end

			local charge = CreateMOSRotating("Explosion Sound " .. math.random(10));
			charge.Pos = self.ShipControlPanelPos;
			MovableMan:AddParticle(charge);
			charge:GibThis();

			if r == 1 then
				-- Destroy stored clone if any
				if #self.Clones > 0 then
					local rclone = math.random(tonumber(self.GS["PlayerVesselClonesCapacity"]))
					-- If damaged cell hit the clone then remove actor from array
					local newarr = {}
					local ii = 1

					for i = 1, #self.Clones do
						if i ~= rclone then
							newarr[ii] = self.Clones[i]
							ii = ii + 1
						end
					end

					self.Clones = newarr
				end
				CF.SetClonesArray(self.GS, self.Clones)

				self.GS["PlayerVesselClonesCapacity"] = tonumber(self.GS["PlayerVesselClonesCapacity"]) - 1

				if self.GS["PlayerVesselClonesCapacity"] <= 0 then
					self.GS["PlayerVesselClonesCapacity"] = 1
				end

				losstext = "and destroyed one of our cryo-chambers."
			elseif r == 2 then
				-- Destroy storage cells
				local damage = math.random(3, 9)
				for i = 1, damage do
					local rweap = math.random(#self.StorageItems)

					if rweap <= #self.StorageItems then
						if self.StorageItems[rweap].Count > 0 then
							self.StorageItems[rweap].Count = self.StorageItems[rweap].Count - 1;
						end
					end
				end

				self.GS["PlayerVesselStorageCapacity"] = tonumber(self.GS["PlayerVesselStorageCapacity"]) - damage

				if self.GS["PlayerVesselStorageCapacity"] < 1 then
					self.GS["PlayerVesselStorageCapacity"] = 1
				end

				-- If we have some items left in nonexisting cell then throw them around
				while CF.CountUsedStorageInArray(self.StorageItems) > self.GS["PlayerVesselStorageCapacity"] do
					local rweap = math.random(#self.StorageItems)
					if self.StorageItems[rweap]["Count"] > 0 then
						self.StorageItems[rweap]["Count"] = self.StorageItems[rweap]["Count"] - 1

						if self.StorageInputPos ~= nil then
							local itm = CF.MakeItem(
								self.StorageItems[rweap]["Class"],
								self.StorageItems[rweap]["Preset"],
								self.StorageItems[rweap]["Module"]
							)
							if itm then
								itm.Pos = self.StorageInputPos
								local a = math.random(360)
								local r = 10 + math.random(40)
								itm.Vel = Vector(math.cos(a / (180 / 3.14)) * r, math.sin(a / (180 / 3.14) * r))
								MovableMan:AddItem(itm)
							end
						end
					end
				end

				CF.SetStorageArray(self.GS, self.StorageItems)
				self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true)

				losstext = "and destroyed some of our storage cells."
			elseif r == 3 then
				-- Destroy life support
				self.GS["PlayerVesselLifeSupport"] = tonumber(self.GS["PlayerVesselLifeSupport"]) - 1

				if self.GS["PlayerVesselLifeSupport"] <= 0 then
					self.GS["PlayerVesselLifeSupport"] = 1
				end

				losstext = "and destroyed our oxygen regeneration tank. Our life support system degraded."
			elseif r == 4 then
				-- Destroy life support
				self.GS["PlayerVesselCommunication"] = tonumber(self.GS["PlayerVesselCommunication"]) - 1

				if self.GS["PlayerVesselCommunication"] <= 0 then
					self.GS["PlayerVesselCommunication"] = 1
				end

				losstext = "and destroyed one of our antennas. Communications to ground will suffer."
			elseif r == 5 then
				-- Destroy engine
				self.GS["PlayerVesselSpeed"] = math.floor(tonumber(self.GS["PlayerVesselSpeed"]) * 0.9 + 0.5)
					- math.random(5)

				if self.GS["PlayerVesselSpeed"] <= 5 then
					self.GS["PlayerVesselSpeed"] = 5
				end

				losstext = "and damaged our engine. We've lost some speed."
			end

			self.reportData = {}
			self.reportData[#self.reportData + 1] = "We tried to cut off "
				.. devices[math.random(#devices)]
				.. ", but it exploded "
				.. losstext
			CF.SaveMissionReport(self.GS, self.reportData)
		else
			local gold = math.random(1000 - self.GS["Difficulty"] * 5)
			CF.ChangePlayerGold(self.GS, gold);

			self.reportData = {}
			self.reportData[#self.reportData + 1] = "We managed to find some intact parts of "
				.. devices[math.random(#devices)]
				.. " worth "
				.. gold
				.. " oz of gold.";

			CF.SaveMissionReport(self.GS, self.reportData);
		end

		-- Finish encounter
		encounterData["encounterConcluded"] = true
		self.vesselData["flightDisabled"] = false
		self.vesselData["flightAimless"] = false
		self.vesselData["dialog"] = nil
		self:RemoveDeployedTurrets()
	end

	if variant == 2 then
		self.reportData = {}
		self.reportData[#self.reportData + 1] = "Farewell, silent wanderer of the void." --"Adios, lone nomad of the unknown."
		CF.SaveMissionReport(self.GS, self.reportData)

		-- Finish encounter
		encounterData["encounterConcluded"] = true
		self.vesselData["flightDisabled"] = false
		self.vesselData["flightAimless"] = false
		self.vesselData["dialog"] = nil
		self:RemoveDeployedTurrets()
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------