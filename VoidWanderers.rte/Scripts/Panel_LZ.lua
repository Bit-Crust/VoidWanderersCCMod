-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitLZControlPanelUI()
	-- Find suitable LZs
	local lzs = CF.GetPointsArray(self.Pts, "Deploy", self.MissionDeploySet, "PlayerLZ");
	self.LZControlPanelPos = CF.RandomSampleOfList(lzs, Activity.MAXPLAYERCOUNT);

	self.LZControlPanelActor = {};
	self.ControlPanelLZPressTimes = {};

	self.BombsControlPanelInBombMode = false;

	self.BombsControlPanelItemsPerPage = 3;
	self.LastKnownBombingPosition = nil;

	self.BombsControlPanelModes = { RETURN = 0, BOMB = 1 };
	self.BombsControlPanelSelectedModes = {};
	self.BombsControlPanelSelectedItem = 1;

	-- Reset bombing state
	self.BombingTarget = nil;
	self.BombingStart = nil;
	self.BombingLoadTime = nil;
	self.BombingRange = nil;

	self.BombPayload = {};

	local panelPos = Vector();

	local brainsAbsent = self.GS["BrainsOnMission"] == "False";
	
	self:LocateLZControlPanelActors();
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if not MovableMan:IsActor(self.LZControlPanelActor[player + 1]) then
			if (brainsAbsent and self:PlayerActive(player) and self:PlayerHuman(player)) or (not self.BrainsAbsent and player == Activity.PLAYER_1) then
				self.LZControlPanelActor[player + 1] = CreateActor("LZ Control Panel")
				if self.LZControlPanelActor[player + 1] ~= nil then
					self.LZControlPanelActor[player + 1].Pos = self.LZControlPanelPos[player + 1]
					self.LZControlPanelActor[player + 1].Team = CF.PlayerTeam
					MovableMan:AddActor(self.LZControlPanelActor[player + 1])
					self.LZControlPanelActor[player + 1]:SetNumberValue("VW_PanelNumber", player + 1)
					if brainsAbsent then
						self:SetPlayerBrain(self.LZControlPanelActor[player + 1], player)
						self:SwitchToActor(self.LZControlPanelActor[player + 1], player, CF.PlayerTeam)
					end
				end
			end
		end
		self.BombsControlPanelSelectedModes[player + 1] = self.BombsControlPanelModes.RETURN
	end
	
	local zoneLeft = Vector(math.min(self.LZControlPanelPos[1].X, self.LZControlPanelPos[4].X), math.min(self.LZControlPanelPos[1].Y, self.LZControlPanelPos[4].Y))
	local zoneRight = Vector(math.max(self.LZControlPanelPos[1].X, self.LZControlPanelPos[4].X), math.max(self.LZControlPanelPos[1].Y, self.LZControlPanelPos[4].Y))
	local screenDim = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight)
	self.lzBox = Box(zoneLeft + screenDim * -0.5, zoneRight + screenDim * 0.5)
end
-----------------------------------------------------------------------
-- Find and assign appropriate landing zone actors
-----------------------------------------------------------------------
function VoidWanderers:LocateLZControlPanelActors()
	local tick = 0;
	for actor in MovableMan.AddedActors do
		if actor.PresetName == "LZ Control Panel" then
			if brainsAbsent then
				self.LZControlPanelActor[tick + 1] = actor
				self.LZControlPanelPos[tick + 1] = actor.Pos
				self:SetPlayerBrain(self.LZControlPanelActor[tick + 1], tick)
				tick = tick + 1
			else
				self.LZControlPanelActor[1] = actor
				self.LZControlPanelPos[1] = actor.Pos
				break
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:IsInLZPanelProximity(pos)
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self.LZControlPanelPos[player + 1] then
			local dist = SceneMan:ShortestDistance(self.LZControlPanelPos[player + 1], pos, SceneMan.SceneWrapsX)
			if
				math.abs(dist.X) < FrameMan.PlayerScreenWidth * 0.5
				and math.abs(dist.Y) < FrameMan.PlayerScreenHeight * 0.5
				and SceneMan:CastStrengthSumRay(self.LZControlPanelPos[player + 1], pos, 10, rte.grassID) < 500
			then
				return true
			end
		end
	end
	return false
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyLZControlPanelUI()
	if self.LZControlPanelActor then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			-- Destroy actor
			if MovableMan:IsActor(self.LZControlPanelActor[player + 1]) then
				self.LZControlPanelActor[player + 1].ToDelete = true
			end
		end
	end
	
	--self.LZControlPanelActor.ToDelete = true
	self.LZControlPanelActor = nil
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessLZControlPanelUI()
	if self.LZControlPanelActor == nil or self.ActivityState == Activity.OVER then
		return
	end

	self:ProcessBombsControlPanelUI()

	if self.BombingTarget ~= nil then
		if self.Time > self.BombingStart + self.BombingLoadTime + CF.BombFlightInterval then
			if self.Time > self.BombingLastBombShot + CF.BombInterval then
				self.BombingLastBombShot = self.Time
				self.BombsControlPanelInBombMode = true

				for i = 1, tonumber(self.GS["PlayerVesselBombBays"]) do
					local bombpos = Vector(
						self.BombingTarget - self.BombingRange / 2 + math.random(self.BombingRange),
						-40
					)

					local bomb = CF.MakeItem(
						self.BombPayload[self.BombingCount].Class,
						self.BombPayload[self.BombingCount].Preset,
						self.BombPayload[self.BombingCount].Module
					)
					if bomb then
						bomb.Pos = bombpos
						MovableMan:AddItem(bomb)
					end

					self.BombingCount = self.BombingCount + 1
					if self.BombingCount > #self.BombPayload then
						break
					end
				end

				-- Alert all enemy units in target area when bombs fall
				if self.BombingCount == 2 and #self.BombPayload > 1 then
					for actor in MovableMan.Actors do
						if
							actor.Team ~= CF.PlayerTeam
							and actor.AIMode == Actor.AIMODE_SENTRY
							and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
						then
							if CF.Dist(actor.Pos, self.LastKnownBombingPosition) < self.BombingRange * 1.5 then
								actor.AIMode = Actor.AIMODE_PATROL
							end
						end
					end
				end

				-- Bombing over, clean everything
				if self.BombingCount > #self.BombPayload then
					self:DestroyBombsControlPanelUI()

					self.BombingTarget = nil
					self.BombingStart = nil
					self.BombingLoadTime = nil
					self.BombingRange = nil
					self.BombingCount = nil
					self.BombsControlPanelInBombMode = false
				end
			end
		end
	end
	
	local controlled = { false, false, false, false };

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player);
		
		if act and MovableMan:IsActor(act) and act.PresetName == "LZ Control Panel" then
			controlled[act:GetNumberValue("VW_PanelNumber")] = true;
		end
	end
	
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if (not controlled[player + 1]) and self.LZControlPanelActor[player + 1] then
			PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, self.LZControlPanelActor[player + 1].Pos, "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_LZ.png", 0, false, false);
		end
	end
	
	local anypanelselected = false
	local isSafe = false
	local totalGoldCarried = 0

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player);

		if act and MovableMan:IsActor(act) and act.PresetName == "LZ Control Panel" then
			local cont = act:GetController()
			local pos = act.Pos
			local selectedpanel = 1
			anypanelselected = true

			if self.BombsControlPanelSelectedModes[selectedpanel] == self.BombsControlPanelModes.RETURN then
				local safeUnits = {}
				local unsafeUnits = {}
				local enemyPos = {}
				local brainUnsafe = 0

				for actor in MovableMan.Actors do
					if
						(actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
						and actor.Team ~= Activity.NOTEAM
					then
						if actor.Team ~= CF.PlayerTeam then
							enemyPos[#enemyPos + 1] = actor.Pos
						elseif not CF.IsAlly(actor) and actor.PresetName ~= "LZ Control Panel" then
							if self:IsInLZPanelProximity(actor.Pos) then
								safeUnits[#safeUnits + 1] = actor
							else
								unsafeUnits[#unsafeUnits + 1] = actor
								if CF.IsBrain(actor) then
									brainUnsafe = brainUnsafe + 1
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
						safeUnits[#safeUnits + 1] = ToActor(actor)
					end
				end

				local items = {}

				for item in MovableMan.Items do
					if
						self:IsInLZPanelProximity(item.Pos)
						and IsHeldDevice(item)
						and not ToHeldDevice(item).UnPickupable
					then
						items[#items + 1] = item
					end
				end

				local friends = #safeUnits + #unsafeUnits

				if #enemyPos == 0 or friends / 4 > #enemyPos then
					isSafe = true
				end

				for i = 1, #safeUnits do
					local part = CreateMOSParticle("Tiny Blue Glow", self.ModuleName)
					part.Pos = safeUnits[i].Pos
						+ Vector(0, safeUnits[i].IndividualRadius * 0.5)
						+ Vector(safeUnits[i].IndividualRadius * RangeRand(0, 1.25), 0):RadRotate(
							RangeRand(-math.pi, math.pi)
						)
					MovableMan:AddParticle(part)
					if math.floor(safeUnits[i].Age / TimerMan.DeltaTimeMS) % 60 == 0 then
						safeUnits[i]:FlashWhite(50)
					end
				end

				if isSafe then
					CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 80, pos.Y - 24, pos.X + 80, pos.Y + 24, CF.MenuNormalIdle);
					local storageCapacity = tonumber(self.GS["PlayerVesselStorageCapacity"])
						- CF.CountUsedStorageInArray(CF.GetStorageArray(self.GS, false))

					for i = 1, #items do
						if i <= storageCapacity then
							local part = CreateMOSParticle("Tiny Blue Glow", self.ModuleName)
							part.Pos = items[i].Pos
								+ Vector(items[i].Radius * math.random(), 0):RadRotate(RangeRand(-math.pi, math.pi))
							MovableMan:AddParticle(part)
						else
							break
						end
					end

					for i = 1, #unsafeUnits do
						local part = CreateMOSParticle("Tiny Blue Glow", self.ModuleName)
						part.Pos = unsafeUnits[i].Pos
							+ Vector(0, unsafeUnits[i].IndividualRadius)
							+ Vector(unsafeUnits[i].IndividualRadius * RangeRand(0, 1.25), 0):RadRotate(
								RangeRand(-math.pi, math.pi)
							)
						MovableMan:AddParticle(part)
						if math.floor(unsafeUnits[i].Age / TimerMan.DeltaTimeMS) % 60 == 0 then
							unsafeUnits[i]:FlashWhite(50)
						end
					end
				else
					CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 80, pos.Y - 24, pos.X + 80, pos.Y + 24, CF.MenuDeniedIdle);
					if self.Time % 2 == 0 then
						-- Show hostiles to indicate that they prevent from returning safely
						for i = 1, #enemyPos do
							self:AddObjectivePoint(
								"HOSTILE",
								enemyPos[i] + Vector(0, -30),
								CF.PlayerTeam,
								GameActivity.ARROWDOWN
							)
						end
					else
						-- Show hostiles to indicate that they prevent from returning safely
						for i = 1, #unsafeUnits do
							self:AddObjectivePoint(
								"ABANDONED",
								unsafeUnits[i].Pos + Vector(0, -40),
								CF.PlayerTeam,
								GameActivity.ARROWDOWN
							)
						end
					end
				end

				if cont:IsState(Controller.PRESS_LEFT) then
					self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelSelectedModes[selectedpanel]
						- 1

					if self.BombsControlPanelSelectedModes[selectedpanel] < self.BombsControlPanelModes.RETURN then
						self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelModes.BOMB
					end

					if self.BombsControlPanelSelectedModes[selectedpanel] == self.BombsControlPanelModes.BOMB then
						if
							self.BombsControlPanelInBombMode
							or CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.NOBOMBS)
						then
							self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelSelectedModes[selectedpanel]
								- 1
						end
					end
				end

				if cont:IsState(Controller.PRESS_RIGHT) then
					self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelSelectedModes[selectedpanel]
						+ 1

					if self.BombsControlPanelSelectedModes[selectedpanel] == self.BombsControlPanelModes.BOMB then
						if
							self.BombsControlPanelInBombMode
							or CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.NOBOMBS)
						then
							self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelSelectedModes[selectedpanel]
								+ 1
						end
					end

					if self.BombsControlPanelSelectedModes[selectedpanel] > self.BombsControlPanelModes.BOMB then
						self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelModes.RETURN
					end
				end

				local text = "";

				if brainUnsafe <= 0 or isSafe then
					if cont:IsState(Controller.WEAPON_FIRE) then
						if self.ControlPanelLZPressTimes[player + 1] == nil then
							self.ControlPanelLZPressTimes[player + 1] = self.Time
						end

						if self.ControlPanelLZPressTimes[player + 1] + CF.TeamReturnDelay <= self.Time then
							self.ControlPanelLZPressTimes[player + 1] = self.Time - CF.TeamReturnDelay
						end

						text = text .. "RETURN IN T-" .. tostring(self.ControlPanelLZPressTimes[player + 1] + CF.TeamReturnDelay - self.Time);

						if self.ControlPanelLZPressTimes[player + 1] + CF.TeamReturnDelay <= self.Time and (brainUnsafe <= 0 or isSafe) then

							local actors = {}
							for actor in MovableMan.Actors do
								if
									actor.Team == CF.PlayerTeam
									and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
									and actor.PresetName ~= "LZ Control Panel"
									and not CF.IsAlly(actor)
									and (isSafe or self:IsInLZPanelProximity(actor.Pos))
								then
									table.insert(actors, actor)
								end
							end
							for actor in MovableMan:GetMOsInBox(self.lzBox, Activity.NOTEAM, true) do
								if
									actor.Team == CF.PlayerTeam
									and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
									and ToActor(actor):IsDead()
									and not CF.IsAlly(ToActor(actor))
									and self:IsInLZPanelProximity(actor.Pos)
								then
									table.insert(actors, ToActor(actor))
								end
							end

							self:ClearDeployed()
							self.GS["MissionReturningTroops"] = 1
							self.deployedActors = {}

							for _, actor in pairs(actors) do
								local assignable = true
								local i = tonumber(self.GS["MissionReturningTroops"])

								-- Check if unit is playable
								local f = self.GS["PlayerFaction"]
								if CF.UnassignableUnits[f] ~= nil then
									for i = 1, #CF.UnassignableUnits[f] do
										if actor.PresetName == CF.UnassignableUnits[f][i] then
											assignable = false
										end
									end
								end

								if assignable then
									local pre, cls, mdl = CF.GetInventory(actor)

									if actor.Team == CF.PlayerTeam and IsActor(actor) then
										actor = ToActor(actor)

										if assignable and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
											self.GS["Deployed" .. i .. "Preset"] = actor.PresetName;
											self.GS["Deployed" .. i .. "Class"] = actor.ClassName;
											self.GS["Deployed" .. i .. "Module"] = actor.ModuleName;
											self.GS["Deployed" .. i .. "XP"] = actor:GetNumberValue("VW_XP");
											self.GS["Deployed" .. i .. "Identity"] = actor:GetNumberValue("Identity");
											self.GS["Deployed" .. i .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer");
											self.GS["Deployed" .. i .. "Prestige"] = actor:GetNumberValue("VW_Prestige");
											self.GS["Deployed" .. i .. "Name"] = actor:GetStringValue("VW_Name");
										
											for _, limbName in ipairs(CF.LimbIDs[actor.ClassName]) do
												self.GS["Deployed" .. i .. limbName] = CF.GetLimbData(actor, limbName);
											end

											for j = 1, #pre do
												self.GS["Deployed" .. i .. "Item" .. j .. "Preset"] = pre[j]
												self.GS["Deployed" .. i .. "Item" .. j .. "Class"] = cls[j]
												self.GS["Deployed" .. i .. "Item" .. j .. "Module"] = mdl[j]
											end
								
											self.deployedActors[i] = actor
											self.GS["MissionReturningTroops"] = tonumber(self.GS["MissionReturningTroops"]) + 1
										end
									end

									if actor.GoldCarried then
										totalGoldCarried = totalGoldCarried + actor.GoldCarried;
										actor.GoldCarried = 0;
									end
									--print (#pre)
								end
							end
						
							for _, actor in pairs(self.deployedActors) do
								self.deployedActors[_] = MovableMan:RemoveActor(actor)
							end

							self.GS["DeserializeDeployedTeam"] = "True"
						end
					else
						text = text .. "HOLD FIRE TO RETURN";
						self.ControlPanelLZPressTimes[player + 1] = nil;
					end

					text = text .. "\n";
				end

				if #unsafeUnits > 0 and not isSafe then
					if brainUnsafe > 0 then
						text = text .. "CAN'T ABANDON BRAIN";
					else
						text = text .. "AND ABANDON " .. #unsafeUnits .. " UNIT" .. (#unsafeUnits > 1 and "S" or "");
					end
					text = text .. "\n";
				end

				if self.missionData["missionStatus"] ~= nil then
					local l = CF.GetStringPixelWidth(self.missionData["missionStatus"])
					text = text .. self.missionData["missionStatus"];
				end
				
				CF.DrawString(text, pos, 155, 44, nil, nil, 1, 1);
			elseif self.BombsControlPanelSelectedModes[selectedpanel] == self.BombsControlPanelModes.BOMB then
				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 80, pos.Y - 24, pos.X + 80, pos.Y + 24, CF.MenuNormalIdle);

				selectedItem = self.BombsControlPanelSelectedItem;

				local bombs = CF.GetBombsArray(self.GS);
				bomb = {};
				bomb.Class = "";
				bomb.Preset = "Request orbital strike";
				bomb.Count = 0;
				table.insert(bombs, bomb);

				self.BombsControlPanelInBombMode = true

				if cont:IsState(Controller.PRESS_UP) then
					if selectedItem > 1 then
						selectedItem = selectedItem - 1
					end
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					if selectedItem < #bombs then
						selectedItem = selectedItem + 1
					end
				end

				if cont:IsState(Controller.PRESS_LEFT) then
					self.BombsControlPanelInBombMode = false
					self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelSelectedModes[selectedpanel]
						- 1

					if self.BombsControlPanelSelectedModes[selectedpanel] < self.BombsControlPanelModes.RETURN then
						self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelModes.BOMB
					end
				end

				if cont:IsState(Controller.PRESS_RIGHT) then
					self.BombsControlPanelInBombMode = false
					self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelSelectedModes[selectedpanel]
						+ 1

					if self.BombsControlPanelSelectedModes[selectedpanel] > self.BombsControlPanelModes.BOMB then
						self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelModes.RETURN
					end
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true
						local selectedBomb = bombs[selectedItem];

						if selectedBomb ~= nil then
							if selectedBomb.Preset == "Request orbital strike" and #self.BombPayload > 0 then
								self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelModes.RETURN;
								self:InitBombsControlPanelUI();
								if MovableMan:IsActor(self.BombsControlPanelActor) then
									bombs[#bombs] = nil;

									if self.LastKnownBombingPosition == nil then
										self.BombsControlPanelActor.Pos = Vector(pos.X, 0);
									else
										self.BombsControlPanelActor.Pos = self.LastKnownBombingPosition;
									end

									self:SwitchToActor(self.BombsControlPanelActor, player, CF.PlayerTeam);
									return;
								end
							else
								if selectedBomb.Count > 0 and #self.BombPayload < tonumber(self.GS["PlayerVesselBombBays"]) * CF.BombsPerBay then
									bombs[selectedItem].Count = bombs[selectedItem].Count - 1

									local payload = {};
									payload.Preset = selectedBomb.Preset;
									payload.Class = selectedBomb.Class;
									payload.Module = selectedBomb.Module;
									table.insert(self.BombPayload, payload);
								end
							end
						end
					end
				else
					self.FirePressed[player] = false
				end

				local itemsPerPage = self.BombsControlPanelItemsPerPage;
				local listStart = selectedItem - (selectedItem - 1) % itemsPerPage;
				local text = "PAYLOAD: " .. #self.BombPayload .. " / " .. self.GS["PlayerVesselBombBays"] * CF.BombsPerBay;
				local lineOffset = -25;
				CF.DrawString(text, pos + Vector(0, lineOffset), 155, 44, nil, nil, 1, 0);
				lineOffset = lineOffset + 11;

				for i = listStart, listStart + itemsPerPage - 1 do
					local bomb = bombs[i];

					if bomb then
						text = (i == selectedItem and "> " or "") .. bomb.Preset;
						CF.DrawString(text, pos + Vector(-70, lineOffset), 155, 11, nil, nil, 0);
						text = (i == #bombs and "" or tostring(bomb.Count));
						CF.DrawString(text, pos + Vector(70, lineOffset), 155, 11, nil, nil, 2);
						lineOffset = lineOffset + 11;
					end
				end

				self.BombsControlPanelSelectedItem = selectedItem;
				table.remove(bombs, #bombs);
				CF.SetBombsArray(self.GS, bombs);
			end

			PrimitiveMan:DrawTriangleFillPrimitive(Activity.PLAYER_NONE, pos + Vector(-77, 0), pos + Vector(-73, 4), pos + Vector(-73, -4), 118);
			PrimitiveMan:DrawTriangleFillPrimitive(Activity.PLAYER_NONE, pos + Vector(77, 0), pos + Vector(73, 4), pos + Vector(73, -4), 118);
		end
	end

	-- Reset panel states when they are not selected
	if not anypanelselected and self.BombsControlPanelActor == nil then
		self.BombsControlPanelInBombMode = false;

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			self.BombsControlPanelSelectedModes[player + 1] = self.BombsControlPanelModes.RETURN
		end

		self.BombsControlPanelSelectedItem = 1;
		local bombs = CF.GetBombsArray(self.GS);

		for i, payload in pairs(self.BombPayload) do
			local found = false;

			for j, bomb in pairs(bombs) do
				if payload.Preset == bomb.Preset and payload.Class == bomb.Class and payload.Module == bomb.Module then
					bombs[j].Count = bombs[j].Count + 1;
					found = true;
					break;
				end
			end

			if not found then
				payload.Count = 1;
				table.insert(bombs, payload);
			end
		end

		self.BombPayload = {};
		CF.SetBombsArray(self.GS, bombs);
	end

	if self.GS["DeserializeDeployedTeam"] == "True" then
		if self.missionData["stage"] and self.missionData["stage"] ~= CF.MissionStages.COMPLETED then
			self:GiveMissionPenalties()
		end

		-- Generate new missions
		if self.missionData["advanceMissions"] and self.missionData["advanceMissions"] == true then
			CF.GenerateRandomMissions(self.GS);
		end

		-- Update casualties report
		if tonumber(self.GS["MissionDeployedTroops"]) > tonumber(self.GS["MissionReturningTroops"]) then
			local s = ""
			local lost = tonumber(self.GS["MissionDeployedTroops"]) - tonumber(self.GS["MissionReturningTroops"])

			if tonumber(self.GS["MissionReturningTroops"]) == 0 then
				self.reportData[#self.reportData + 1] = "ALL UNITS LOST"
			elseif lost > 1 then
				self.reportData[#self.reportData + 1] = lost .. " UNITS LOST"
			else
				self.reportData[#self.reportData + 1] = "1 UNIT LOST"
			end
		elseif tonumber(self.GS["MissionDeployedTroops"]) < tonumber(self.GS["MissionReturningTroops"]) then
			local s = ""
			local recruited = tonumber(self.GS["MissionReturningTroops"]) - tonumber(self.GS["MissionDeployedTroops"])

			if recruited > 1 then
				self.reportData[#self.reportData + 1] = recruited .. " UNITS GAINED"
			else
				self.reportData[#self.reportData + 1] = "1 UNIT GAINED"
			end
		else
			self.reportData[#self.reportData + 1] = "NO CASUALTIES"
		end

		-- Collect items
		if isSafe then
			local storage = CF.GetStorageArray(self.GS, false)
			local items = {}
			for item in MovableMan.Items do
				if
					self:IsInLZPanelProximity(item.Pos)
					and IsHeldDevice(item)
					and not ToHeldDevice(item).UnPickupable
				then
					items[#items + 1] = item
				end
			end
			for _, item in pairs(items) do
				if CF.CountUsedStorageInArray(storage) < tonumber(self.GS["PlayerVesselStorageCapacity"]) then
					CF.PutItemToStorageArray(storage, item.PresetName, item.ClassName, item.ModuleName)
				else
					break
				end
			end

			CF.SetStorageArray(self.GS, storage)

			if #items > 0 then
				self.reportData[#self.reportData + 1] = tostring(#items)
					.. " item"
					.. (#items > 1 and "s" or "")
					.. " collected"
			end
		end

		if totalGoldCarried > 0 then
			self.reportData[#self.reportData + 1] = totalGoldCarried .. " oz of gold collected.";
			CF.ChangePlayerGold(self.GS, totalGoldCarried);
		end

		-- Dump mission report to config to be saved
		CF.SaveMissionReport(self.GS, self.reportData);

		local scene = CF.VesselScene[self.GS["PlayerVessel"]];
		-- Set new operating mode
		self.GS["Mode"] = "Vessel";
		self.GS["Scene"] = scene;
		self.GS["DeserializeDeployedTeam"] = "True";
		self.GS["DeserializeOnboard"] = "True";
		self.GS["MissionInitiated"] = "False";
		
		self:SaveCurrentGameState();
		
		self.sceneToLaunch = self.GS["Scene"];
		self.scriptToLaunch = "Tactics.lua";

		-- Wrap it up
		if self.AmbientDestroy ~= nil then
			self:AmbientDestroy();
		end

		if self.MissionDestroy ~= nil then
			self:MissionDestroy();
		end

		-- Clean everything
		self.MissionCreate = nil;
		self.MissionUpdate = nil;
		self.MissionDestroy = nil;
		self.missionData = {};

		self.AmbientCreate = nil;
		self.AmbientUpdate = nil;
		self.AmbientDestroy = nil;
		self.ambientData = {};
		
		self.BrainsAtStake = false;

		--print(collectgarbage('count'));
		collectgarbage("collect");
		--print(collectgarbage('count'));
	end
end
