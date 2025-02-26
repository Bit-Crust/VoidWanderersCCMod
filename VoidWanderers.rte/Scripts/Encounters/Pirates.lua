-----------------------------------------------------------------------
--	Objective: 	Kill all invading troops.
--	Events: 	Depending on mission difficulty AI might send dropships with up to 2 actors and
--	 			launch one counterattack when it will try to kill player actors with
--				1/3 of it's actors. Initial spawn rate varies based on mission difficulty
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterCreate()
	print("PIRATE ENCOUNTER CREATE");

	self.vesselData["flightDisabled"] = true;
	self.vesselData["flightAimless"] = true;
	self.vesselData["lifeSupportEnabled"] = true;
	self.vesselData["beamEnabled"] = false;
	self.vesselData["itemStorageEnabled"] = true;
	self.vesselData["cloneStorageEnabled"] = true;
	self.vesselData["bridgeEnabled"] = true;

	-- Select random pirate party
	local bandEncountered = CF.PirateBands[math.random(#CF.PirateBands)];
	local feeKey = "RandomEncounter_" .. self.encounterData["encounterName"] .. "_" .. bandEncountered.Org .. "_" .. "Fee";
	self.encounterData["bandEncountered"] = bandEncountered;
	self.encounterData["feeKey"] = feeKey;
	local fee = tonumber(self.GS[feeKey]) or bandEncountered.FeeInc;

	-- If we killed selected pirate then show some info and give player some gold
	if fee == -1 then
		local gold = math.random(bandEncountered.FeeInc);
		self.reportData = {};
		self.reportData[#self.reportData + 1] = "Dead pirate vessel floats nearby. It seems to have been raided countless times, but you managed to scavenge " .. gold .. "oz of gold from it.";
		CF.SaveMissionReport(self.GS, self.reportData);
		CF.ChangePlayerGold(self.GS, gold);
		
		-- Finish encounter
		self.encounterData["encounterConcluded"] = true;
		self.vesselData["dialog"] = nil;

		self.vesselData["flightDisabled"] = false;
		self.vesselData["flightAimless"] = false;
		self.vesselData["lifeSupportEnabled"] = true;
		self.vesselData["beamEnabled"] = true;
		self.vesselData["itemStorageEnabled"] = true;
		self.vesselData["cloneStorageEnabled"] = true;
		self.vesselData["bridgeEnabled"] = true;
		self:RemoveDeployedTurrets();
	else
		self.encounterData["askingFee"] = fee;
		self.encounterData["unitsWithheld"] = bandEncountered.Units;
		local message = bandEncountered.EncounterText;

		if not message then
			message = "This is captain "
				.. bandEncountered.Captain
				.. " of "
				.. bandEncountered.Ship
				.. " speaking. You are in the vicinity of "
				.. bandEncountered.Org
				.. " and have to pay a small fee of "
				.. fee
				.. "oz of gold to pass. Comply at once and no one will get hurt.";
		end

		self:SendTransmission(message, {"I'm at your mercy, take whatever you want.", "Kid, don't threaten me. There are worse things than death and I can do all of them."});
		self:GiveFocusToBridge();
		self:StartMusic(CF.MusicTypes.SHIP_INTENSE);

		self.GS[feeKey] = fee + bandEncountered.FeeInc;
	end

	self.encounterData["attackLaunched"] = false;
	self.encounterData["attackWarningPeriod"] = math.random(5, 6);
	self.encounterData["attackSpawn"] = SceneMan.Scene:GetArea("Vessel Assault Spawn");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:EncounterUpdate()
	FrameMan:ClearScreenText(0);
	
	local concludeEncounter = false;
	local conclusionMessage = "";
	local bandEncountered = self.encounterData["bandEncountered"];

	if not self.encounterData["attackLaunched"] then
		local variant = self.vesselData["dialogOptionChosen"];
		local launchAttack = false;

		if variant == 1 then
			local gold = CF.GetPlayerGold(self.GS);

			if gold < math.random(self.encounterData["askingFee"]) then
				local message = "";

				if gold >= self.encounterData["askingFee"] * 0.5 then
					CF.SetPlayerGold(self.GS, 0);
					message = "Thank you for your payment. My troops will come by to collect the rest. " .. bandEncountered.Captain .. " out.";
				else
					message = bandEncountered.MsgBroke or "In that case, we take your ship. " .. bandEncountered.Captain .. " out.";
				end

				self:SendTransmission(message, {});
				self:GiveFocusToBridge();
				launchAttack = true;
			else
				gold = CF.GetPlayerGold(self.GS) - self.encounterData["askingFee"];

				if gold < 0 then
					gold = 0;
					conclusionMessage = bandEncountered.MsgDebt or "Consider yourself lucky, punk. Next time we take your ship. " .. bandEncountered.Captain .. " out.";
				else
					conclusionMessage = bandEncountered.MsgBribe or bandEncountered.Org .. " is always at your service. " .. bandEncountered.Captain .. " out.";
				end
				
				CF.SetPlayerGold(self.GS, gold);
				concludeEncounter = true;
			end
		end

		if variant == 2 then
			local message = bandEncountered.MsgHostile or "Prepare to be punished! " .. bandEncountered.Captain .. " out.";
			self:SendTransmission(message, {});
			self:GiveFocusToBridge();
			launchAttack = true;
		end

		if launchAttack then
			-- Indicate thet we fought this pirate and defeated him
			self.GS[self.encounterData["feeKey"]] = -1;
			self.encounterData["attackLaunched"] = true;
			self.encounterData["attackNextSpawnTime"] = self.Time + bandEncountered.Interval;
			self.encounterData["attackNextSpawnPos"] = self.encounterData["attackSpawn"]:GetRandomPoint();

			self.vesselData["lifeSupportEnabled"] = false;
			self.vesselData["beamEnabled"] = false;
			self.vesselData["itemStorageEnabled"] = false;
			self.vesselData["cloneStorageEnabled"] = false;
		end
	else
		local enemyCount = 0;

		for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
			if actor.Team == Activity.TEAM_2 then
				enemyCount = enemyCount + 1;
				actor.AIMode = Actor.AIMODE_BRAINHUNT;
			end
		end end

		if self.encounterData["unitsWithheld"] == 0 then
			if enemyCount == 0 then
				self:GiveRandomExperienceReward();
				conclusionMessage = bandEncountered.MsgDefeat or "Fine, looks like you're a tough one. You can pass for free. " .. bandEncountered.Captain .. " out.";
				concludeEncounter = true;
			end
		end

		if self.encounterData["attackNextSpawnTime"] == self.Time then
			local cnt = math.random(math.ceil(bandEncountered.Burst * 0.5), bandEncountered.Burst);

			for i = 1, cnt do
				if MovableMan:GetMOIDCount() < CF.MOIDLimit and self.encounterData["unitsWithheld"] > 0 then
					self.encounterData["unitsWithheld"] = self.encounterData["unitsWithheld"] - 1;

					local actorIndex = math.random(#bandEncountered.Act);
					local actor = CreateAHuman(bandEncountered.Act[actorIndex], bandEncountered.ActMod[actorIndex]);

					if actor then
						local weapon;

						if bandEncountered.Itm then
							local itemIndex = math.random(#bandEncountered.Itm);
							weapon = CreateHDFirearm(bandEncountered.Itm[itemIndex], bandEncountered.ItmMod[itemIndex]);

							if weapon then
								actor:AddInventoryItem(weapon);
							end
						end

						if bandEncountered.Thrown and (not weapon or math.random() < 0.5) then
							local itemIndex = math.random(#bandEncountered.Thrown);
							local thrown = CreateTDExplosive(bandEncountered.Thrown[itemIndex], bandEncountered.ThrownMod[itemIndex]);

							if thrown then
								actor:AddInventoryItem(thrown);
							end
						end

						if bandEncountered.Captain == "Apone" then
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
						elseif bandEncountered.Captain == "SHODAN" then
							if math.random() < 0.3 then
								local head = CreateHeldDevice("Replacement Head")

								if actor.Head then
									head.ParentOffset = actor.Head.ParentOffset
								end

								head:AddScript("VoidWanderers.rte/Items/Salvage.lua")
								actor.Head = head
							end
						end

						actor.HFlipped = cnt == 1 and math.random() < 0.5 or i % 2 == 0
						actor.Pos = self.encounterData["attackNextSpawnPos"] + Vector(math.random(-4, 4), math.random(-2, 2))
						actor.Team = Activity.TEAM_2
						actor.AIMode = Actor.AIMODE_BRAINHUNT
						MovableMan:AddActor(actor)

						actor:FlashWhite(math.random(200, 300))
					end
				end
			end

			local sfx = CreateAEmitter("Teleporter Effect 1", "VoidWanderers.rte");
			sfx.Pos = self.encounterData["attackNextSpawnPos"];
			MovableMan:AddParticle(sfx);

			self.encounterData["attackNextSpawnPos"] = self.EnemySpawn[math.random(#self.EnemySpawn)];
			self.encounterData["attackNextSpawnTime"] = self.Time + bandEncountered.Interval + math.random(0, 2);
		end

		if self.Time % 10 == 0 and self.encounterData["unitsWithheld"] > 0 then
			FrameMan:SetScreenText("Remaining intruders: " .. self.encounterData["unitsWithheld"], 0, 0, 1500, true);
		end

		if self.encounterData["unitsWithheld"] > 0 and self.Time > self.encounterData["attackNextSpawnTime"] - self.encounterData["attackWarningPeriod"] then
			self:AddObjectivePoint("INTRUDER\nALERT", self.encounterData["attackNextSpawnPos"], CF.PlayerTeam, GameActivity.ARROWDOWN);

			if self.TeleportEffectTimer:IsPastSimMS(50) then
				local p = CreateMOSParticle("Tiny Blue Glow", self.ModuleName);
				p.Pos = self.encounterData["attackNextSpawnPos"] + Vector(math.random(-20, 20), math.random(10, 30));
				MovableMan:AddParticle(p);
				self.TeleportEffectTimer:Reset();
			end
		end
	end

	if concludeEncounter then
		-- Report conclusion
		self.reportData = {};
		self.reportData[#self.reportData + 1] = conclusionMessage;
		CF.SaveMissionReport(self.GS, self.reportData);

		-- Finish encounter
		self.encounterData["encounterConcluded"] = true;
		self.vesselData["dialog"] = nil;

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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------