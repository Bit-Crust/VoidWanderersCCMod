-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitShipControlPanelUI()
	local x, y;
	x = tonumber(self.SceneConfig.ShipControlPanelX);
	y = tonumber(self.SceneConfig.ShipControlPanelY);

	if x ~= nil and y ~= nil then
		self.ShipControlPanelPos = Vector(x, y);
	else
		self.ShipControlPanelPos = nil;
	end
	
	self:LocateShipControlPanelActor();
	if self.ShipControlPanelPos ~= nil then
		if not MovableMan:IsActor(self.ShipControlPanelActor) then
			self.ShipControlPanelActor = CreateActor("Ship Control Panel");
			if self.ShipControlPanelActor ~= nil then
				self.ShipControlPanelActor.Pos = self.ShipControlPanelPos;
				self.ShipControlPanelActor.Team = CF.PlayerTeam;
				MovableMan:AddActor(self.ShipControlPanelActor);
			end
		end
	end

	-- Init variables
	self.ShipControlPanelModes = {
		REPORT = 0,
		LOCATION = 1,
		PLANET = 2,
		MISSIONS = 3,
		REPUTATION = 4,
		BRAIN = 5,
		UPGRADE = 6,
		SHIPYARD = 7,
	};

	self.ShipControlMode = self.ShipControlPanelModes.LOCATION;
	self.ShipControlDialogDefaultTime = 15000;

	self.ShipControlMessageTime = -1;
	self.ShipControlMessagePeriod = 3;
	self.ShipControlMessageText = "";

	self.ShipControlSelectedLocation = 1;
	self.ShipControlLocationsPerPage = 10;

	self.ShipControlSelectedPlanet = 1;
	self.ShipControlPlanetsPerPage = 10;

	self.ShipControlSelectedMission = 1;
	self.ShipControlMissionsPerPage = 6;

	self.ShipControlSelectedUpgrade = 1;

	self.ShipControlSelectedSkillUpgrade = 1;

	self.ShipControlSelectedShip = 1;
	
	self.ShipControlReputationPage = 1;
	self.ShipControlReputationsPerPage = 12;
end
-----------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------
function VoidWanderers:LocateShipControlPanelActor()
	for _, group in pairs({MovableMan.AddedActors, MovableMan.Actors}) do
		for actor in group do
			if actor.PresetName == "Ship Control Panel" then
				self.ShipControlPanelActor = actor;
				return true
			end
		end
	end
	return false
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyShipControlPanelUI()
	if self.ShipControlPanelActor ~= nil then
		self.ShipControlPanelActor.ToDelete = true;
		self.ShipControlPanelActor = nil;
		return true
	end
	return false
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SetRandomOrbitLocation()
	local planetPanelWidth = 60;
	local randPos = Vector(planetPanelWidth * math.random(), 0):RadRotate(RangeRand(-math.pi, math.pi));

	self.GS["ShipX"] = math.floor(randPos.X);
	self.GS["ShipY"] = math.floor(randPos.Y);
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessShipControlPanelUI()
	local resetLists = true;
	local showIdle = true;

	if self.ShipControlPanelActor then
		local pos = self.ShipControlPanelPos;

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local act = self:GetControlledActor(player);

			if act and act.PresetName == self.ShipControlPanelActor.PresetName then
				resetLists = false;
				showIdle = false;

				local cont = act:GetController();
				local up = false;
				local down = false;

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer[player + 1]:Reset();
					up = true;
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer[player + 1]:Reset();
					down = true;
				end

				if self.HoldTimer[player + 1]:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer[player + 1]:Reset();

					if cont:IsState(Controller.HOLD_UP) then
						up = true;
					end

					if cont:IsState(Controller.HOLD_DOWN) then
						down = true;
					end
				end
				
				if
					self.ShipControlMode == self.ShipControlPanelModes.REPORT
					or self.ShipControlMode == self.ShipControlPanelModes.REPUTATION
					or (self.ShipControlMode == self.ShipControlPanelModes.BRAIN and self.GS["Brain" .. player .. "Detached"] == "True")
				then
					CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 70, pos.X + 140, pos.Y + 70, CF.MenuNormalIdle);
				else
					CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 70, pos.X - 1, pos.Y + 70, CF.MenuNormalIdle);
					if self.ShipControlMode == self.ShipControlPanelModes.PLANET then
						local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_GalaxyBackA.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(70, 0), path, 0, false, false);
					else
						if self.ShipControlMode == self.ShipControlPanelModes.LOCATION then
							local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_GalaxyBackB.png";
							PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(70, 0), path, 0, false, false);
							local path = CF.PlanetGlow[self.GS["Planet"]];
							PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(70, 0), path, 0, false, false);
						else
							CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X + 0, pos.Y - 70, pos.X + 140, pos.Y + 70, CF.MenuNormalIdle);
						end
					end
				end

				local highBarLeftText = "";
				local highBarCenterText = "";
				local highBarRightText = "";
				local highBarPalette = CF.MenuNormalIdle;

				local lowBarCenterText = "";
				local lowBarPalette = CF.MenuNormalIdle;
				
				local linesPerPage = 12;
				local topOfPage = -68;

				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.REPORT then
					if not self.vesselData.dialog then
						highBarCenterText = "REPORT";
						lowBarCenterText = "Press DOWN to save game";

						local lineOffset = topOfPage;

						CF.DrawString("AVAILABLE GOLD: " .. CF.GetPlayerGold(self.GS, 0), pos + Vector(0, lineOffset), 276, 11, nil, nil, 1);
						lineOffset = lineOffset + 11;
						CF.DrawString("-----------------------------------------------------------------------", pos + Vector(0, lineOffset), 276, 11, nil, nil, 1);
						lineOffset = lineOffset + 11;

						local fullReport = "";
						
						for i = 1, CF.MaxMissionReportLines do
							local reportLine = self.GS["MissionReport" .. i] or "";
							fullReport = fullReport .. CF.SplitStringToFitWidth(reportLine, 276, false);
							fullReport = fullReport .. "\n";
						end
					
						CF.DrawString(fullReport, pos + Vector(0, lineOffset), 276, 110, nil, nil, 1, 0);

						if cont:IsState(Controller.PRESS_DOWN) then
							-- Save all items
							for item in MovableMan.Items do
								if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
									local count = CF.CountUsedStorageInArray(self.StorageItems);

									if count < tonumber(self.GS["PlayerVesselStorageCapacity"]) then
										CF.PutItemToStorageArray(
											self.StorageItems,
											item.PresetName,
											item.ClassName,
											item.ModuleName
										);
									else
										break;
									end
								end
							end

							self.GS["DeserializeOnboard"] = "True";
							CF.SetStorageArray(self.GS, self.StorageItems);
							self:SaveActors(false);
							self:SaveCurrentGameState();
							self:DestroyConsoles();
							FORM_TO_LOAD = BASE_PATH .. "FormSave.lua";
							self:LaunchScript("Void Wanderers", "StrategyScreenMain.lua");
							return;
						end
					else
						local lineOffset = topOfPage;
						local offset = CF.DrawString(CF.SplitStringToFitWidth(self.vesselData.dialog.message, 276, false), pos + Vector(-138, lineOffset), 276, 135);

						if self.vesselData.dialog.options and self.vesselData.dialogDefaultTimer:IsPastSimMS(1000) then
							if up then
								self.vesselData.dialogOptionSelected = self.vesselData.dialogOptionSelected - 1

								if self.vesselData.dialogOptionSelected < 1 then
									self.vesselData.dialogOptionSelected = #self.vesselData.dialog.options
								end
							end

							if down then
								self.vesselData.dialogOptionSelected = self.vesselData.dialogOptionSelected + 1

								if self.vesselData.dialogOptionSelected > #self.vesselData.dialog.options then
									self.vesselData.dialogOptionSelected = 1
								end
							end

							if self.vesselData.dialogDefaultTimer:IsPastSimMS(self.ShipControlDialogDefaultTime) then
								self.vesselData.dialogOptionChosen = #self.vesselData.dialog.options
							end

							if cont:IsState(Controller.WEAPON_FIRE) then
								if not self.FirePressed[player] then
									self.FirePressed[player] = true;
									self.vesselData.dialogOptionChosen = self.vesselData.dialogOptionSelected;
								end
							else
								self.FirePressed[player] = false;
							end

							for i = 1, #self.vesselData.dialog.options do
								if self.vesselData.dialogOptionSelected == i then
									offset = offset + CF.DrawString(
										"> " .. self.vesselData.dialog.options[i],
										pos + Vector(-137, -55) + offset,
										252,
										141
									)
								else
									offset = offset + CF.DrawString(
										self.vesselData.dialog.options[i],
										pos + Vector(-137, -55) + offset,
										262,
										141
									)
								end
							end
						end

						highBarCenterText = "INCOMING TRANSMISSION";
						lowBarCenterText = "U/D - Select, FIRE - Accept";
					end
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.LOCATION then
					-- Fill location list
					locations = {}

					for i = 1, #CF.Location do
						if CF.LocationPlanet[CF.Location[i]] == self.GS["Planet"] then
							locations[#locations + 1] = CF.Location[i]
						end
					end

					-- Sort location list
					for i = 1, #locations do
						for j = 1, #locations - 1 do
							if
								CF.LocationName[locations[j]]
								> CF.LocationName[locations[j + 1]]
							then
								local s = locations[j]
								locations[j] = locations[j + 1]
								locations[j + 1] = s
							end
						end
					end

					if up then
						self.ShipControlSelectedLocation = self.ShipControlSelectedLocation - 1;
						if self.ShipControlSelectedLocation < 1 then
							self.ShipControlSelectedLocation = #locations;
						end
					end

					if down then
						self.ShipControlSelectedLocation = self.ShipControlSelectedLocation + 1;
						if self.ShipControlSelectedLocation > #locations then
							self.ShipControlSelectedLocation = 1;
						end
					end

					local selectedLocation = locations[self.ShipControlSelectedLocation];

					if cont:IsState(Controller.WEAPON_FIRE) then
						if not self.FirePressed[player] then
							self.FirePressed[player] = true;

							if not self.encounterData.initialized then
								if self.GS["Location"] == nil then
									if self.GS["ShipX"] == nil or self.GS["ShipY"] == nil then
										self:SetRandomOrbitLocation();
									end
								end

								self.GS["Location"] = nil;
								self.GS["Destination"] = selectedLocation;
								local destpos = CF.LocationPos[self.GS["Destination"]] or Vector();
								self.GS["DestX"] = tonumber(math.floor(destpos.X));
								self.GS["DestY"] = tonumber(math.floor(destpos.Y));

								self.GS["Distance"] = CF.Dist(Vector(tonumber(self.GS["ShipX"]), tonumber(self.GS["ShipY"])), destpos);
							end
						end
					else
						self.FirePressed[player] = false;
					end

					local locationListStart = self.ShipControlSelectedLocation - (self.ShipControlSelectedLocation - 1) % self.ShipControlLocationsPerPage;

					if self.GS["Destination"] ~= nil then
						local scale = CF.PlanetScale[self.GS["Planet"]] or 1;
						local dst = tostring(math.ceil(tonumber(self.GS["Distance"]) * CF.KmPerPixel * scale));
						local destinationName = CF.LocationName[self.GS["Destination"]];
						highBarLeftText = "EN ROUTE TO: " .. (destinationName or "Unknown");
						highBarRightText = (dst and (dst .. " km") or "");
					else
						local locationName = CF.LocationName[self.GS["Location"]];
						highBarLeftText = "CURRENT LOCATION: " .. (locationName or "Distant orbit");
					end
					
					lowBarCenterText = "U/D - Select location, L/R - Mode, FIRE - Fly";

					-- Select green current location preset if we're on mission location
					local msn = false

					-- If we have mission in that location then draw red dot
					for m = 1, CF.MaxMissions do
						if self.GS["Location"] == self.GS["Mission" .. m .. "Location"] then
							msn = true
							break
						end
					end

					local shippreset = "ControlPanel_Ship_CurrentLocation"

					if msn then
						shippreset = "ControlPanel_Ship_CurrentMissionLocation"
					end

					local sx = tonumber(self.GS["ShipX"])
					local sy = tonumber(self.GS["ShipY"])

					local dx = tonumber(self.GS["DestX"])
					local dy = tonumber(self.GS["DestY"])

					local cx = pos.X + 70
					local cy = pos.Y
				
					path = "Mods/VoidWanderers.rte/UI/ControlPanels/" .. shippreset .. ".png";
					PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(sx, sy) + Vector(70, 0), path, 0, false, false);

					if dx ~= nil and dy ~= nil then
						self:DrawDottedLine(cx + dx, cy + dy, cx + sx, cy + sy, Activity.PLAYER_NONE, 5)
					end

					local shippos = Vector(sx, sy)

					local msn = false
					local msntype
					local msndiff
					local msntgt
					local msncon

					-- If we have mission in that location then draw red dot
					for m = 1, CF.MaxMissions do
						if
							selectedLocation
							== self.GS["Mission" .. m .. "Location"]
						then
							msn = true
							msntype = self.GS["Mission" .. m .. "Type"]
							msndiff = CF.GetFullMissionDifficulty(self.GS, self.GS["Mission" .. m .. "Location"], m) --tonumber(self.GS["Mission"..m.."Difficulty"])
							msntgt = tonumber(self.GS["Mission" .. m .. "TargetPlayer"])
							msncon = tonumber(self.GS["Mission" .. m .. "SourcePlayer"])
							break
						end
					end

					-- Show selected location dot
					local locpos = CF.LocationPos[selectedLocation]
					if locpos ~= nil then
						if msn then
							path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_MissionDot.png";
							PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + locpos + Vector(70, 0), path, 0, false, false);
						else
							path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_LocationDot.png";
							PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + locpos + Vector(70, 0), path, 0, false, false);
						end

						--[[ Draw line to location
						local sx, sy = shippos.X, shippos.Y;
						local dx, dy = locpos.X, locpos.Y;
						local cx, cy = pos.X + 70, pos.Y;
						self:DrawDottedLine(cx + sx, cy + sy, cx + dx, cy + dy, "ControlPanel_Ship_RouteDot", 3);]]
					end

					-- Write security level
					local diff;

					if msn then
						local text;
						local offset = Vector(3, -topOfPage);
						text = "TARGET: " .. CF.FactionNames[CF.GetPlayerFaction(self.GS, msntgt)];
						offset = offset - CF.DrawString(text, pos + offset, 136, 33, nil, nil, nil, 2, nil);
						text = "CONTRACTOR: " .. CF.FactionNames[CF.GetPlayerFaction(self.GS, msncon)];
						offset = offset - CF.DrawString(text, pos + offset, 136, 33, nil, nil, nil, 2, nil);
						text = "MISSION: " .. CF.MissionName[msntype];
						offset = offset - CF.DrawString(text, pos + offset, 136, 33, nil, nil, nil, 2, nil);

						diff = msndiff;
					else
						diff = CF.GetLocationDifficulty(self.GS, selectedLocation);
					end

					-- As long as it isn't marked NOT playable, assume we can go.
					playable = CF.LocationPlayable[selectedLocation] ~= false;

					if playable then
						local text = "SECURITY: " .. string.upper(CF.LocationDifficultyTexts[diff]);
						CF.DrawString(text, pos + Vector(70, topOfPage), 136, 11, nil, nil, 1, nil, nil);
					else
						if CF.IsLocationHasAttribute(selectedLocation, CF.LocationAttributeTypes.TRADESTAR) then
							CF.DrawString("TRADE STAR", pos + Vector(70, -71), 136, 11, nil, nil, 1, nil, nil);
						elseif CF.IsLocationHasAttribute(selectedLocation, CF.LocationAttributeTypes.BLACKMARKET) then
							CF.DrawString("BLACK MARKET", pos + Vector(70, -71), 136, 11, nil, nil, 1, nil, nil);
						elseif CF.IsLocationHasAttribute(selectedLocation, CF.LocationAttributeTypes.SHIPYARD) then
							CF.DrawString("SHIPYARD", pos + Vector(70, -71), 136, 11, nil, nil, 1, nil, nil);
						end
					end
					
					local lineOffset = topOfPage;
					CF.DrawString("FLY TO LOCATION: ", pos + Vector(-138, lineOffset), 135, 40, nil, nil, nil, nil, nil);
					lineOffset = lineOffset + 22;

					if #locations > 0 then
						for i = locationListStart, locationListStart + self.ShipControlLocationsPerPage - 1 do
							local pname = CF.LocationName[locations[i]];
							if pname ~= nil then
								local prefix = (i == self.ShipControlSelectedLocation and "> " or "");
								CF.DrawString(prefix .. pname, pos + Vector(-138, lineOffset), 135, 11, nil, nil, nil, nil, nil);
								lineOffset = lineOffset + 11;
							end
						end
					else
						CF.DrawString("--NO OTHER LOCATIONS--", pos + Vector(-138, (lineOffset - topOfPage) / 2), 135, 11, nil, nil, 1, 1);
					end
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.PLANET then
					local planets = {};
					local planetSelected = self.ShipControlSelectedPlanet;

					for i = 1, #CF.Planet do
						planets[#planets + 1] = CF.Planet[i];
					end

					for i = 1, #planets do
						for j = 1, #planets - 1 do
							if CF.PlanetName[planets[j]] > CF.PlanetName[planets[j + 1]] then
								local s = planets[j];
								planets[j] = planets[j + 1];
								planets[j + 1] = s;
							end
						end
					end

					if up then
						planetSelected = planetSelected - 1;

						if planetSelected < 1 then
							planetSelected = #planets;
						end
					end

					if down then
						planetSelected = planetSelected + 1;

						if planetSelected > #planets then
							planetSelected = 1;
						end
					end

					if cont:IsState(Controller.WEAPON_FIRE) then
						if not self.FirePressed[player] then
							self.FirePressed[player] = true;

							if not self.encounterData.initialized then
								-- Travel to another planet
								self.GS["Planet"] = planets[planetSelected];
								self.GS["Location"] = nil;
								self.GS["Destination"] = nil;

								self.GS["DestX"] = nil;
								self.GS["DestY"] = nil;

								self:SetRandomOrbitLocation();
								self.ShipControlSelectedLocation = 1;
							end
						end
					else
						self.FirePressed[player] = false;
					end

					local planetListStart = planetSelected - (planetSelected - 1) % self.ShipControlPlanetsPerPage;

					-- Show current planet
					local locname = CF.PlanetName[self.GS["Planet"]];
					highBarLeftText = "NOW ORBITING: " .. (locname or "");
					lowBarCenterText = "U/D - Select planet, L/R - Mode, FIRE - Fly";

					-- Show current planet dot
					local locpos = CF.PlanetPos[self.GS["Planet"]]
					if locpos ~= nil then
						path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_CurrentLocation.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + locpos + Vector(70, 0), path, 0, false, false);
					end

					-- Show selected planet dot
					local shppos = CF.PlanetPos[planets[planetSelected]]
					if shppos ~= nil then
						path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship_LocationDot.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + shppos + Vector(70, 0), path, 0, false, false);
					end

					if locpos ~= nil and shppos ~= nil then
						-- Draw line to location
						local sx, sy = locpos.X, locpos.Y;
						local dx, dy = shppos.X, shppos.Y;
						local cx, cy = pos.X + 70, pos.Y;
						local gap = 3;
						self:DrawWanderingDottedLine(cx + sx, cy + sy, cx + dx, cy + dy, Activity.PLAYER_NONE, gap, math.fmod(sx - dx, 6) - 3, math.fmod(sy - dy, 2 * math.pi), 10)
					end
					
					local lineOffset = topOfPage;
					CF.DrawString("WARP TO ANOTHER PLANET:", pos + Vector(-138, lineOffset), 135, 11);
					lineOffset = lineOffset + 22;
					-- Show planet list
					if #planets > 0 then
						for i = planetListStart, planetListStart + self.ShipControlPlanetsPerPage - 1 do
							local pname = CF.PlanetName[planets[i]]
							if pname ~= nil then
								if i == planetSelected then
									CF.DrawString("> " .. pname, pos + Vector(-138, lineOffset), 135, 11, nil, nil, nil, nil, nil)
								else
									CF.DrawString(pname, pos + Vector(-138, lineOffset), 135, 11, nil, nil, nil, nil, nil)
								end
								lineOffset = lineOffset + 11
							end
						end
					else
						CF.DrawString("NO OTHER LOCATIONS", pos + Vector(-138, -49), 130, 12, nil, nil, nil, nil, nil);
					end

					self.ShipControlSelectedPlanet = planetSelected;
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.MISSIONS then
					-- Create CPU list
					local cpus = tonumber(self.GS["ActiveCPUs"])

					local missions = {};
					local missionSelected = self.ShipControlSelectedMission;

					for i = 1, CF.MaxMissions do
						mission = {}
						mission.SourcePlayer = tonumber(self.GS["Mission" .. i .. "SourcePlayer"])
						mission.TargetPlayer = tonumber(self.GS["Mission" .. i .. "TargetPlayer"])
						mission.Difficulty = CF.GetFullMissionDifficulty(self.GS, self.GS["Mission" .. i .. "Location"], i)
						mission.Location = self.GS["Mission" .. i .. "Location"]
						mission.Type = self.GS["Mission" .. i .. "Type"]

						local rep = tonumber(self.GS["Player" .. mission.SourcePlayer .. "Reputation"])
						local srep = (rep > 0 and "+" or "") .. tostring(rep)
						mission.SourceFactionReputation = srep
						mission.SourceFaction = CF.FactionNames[CF.GetPlayerFaction(self.GS, mission.SourcePlayer)]

						local rep = tonumber(self.GS["Player" .. mission.TargetPlayer .. "Reputation"])
						local srep = (rep > 0 and "+" or "") .. tostring(rep)
						mission.TargetFactionRaputation = srep
						mission.TargetFaction = CF.FactionNames[CF.GetPlayerFaction(self.GS, mission.TargetPlayer)]

						mission.Description = CF.MissionBriefingText[mission.Type]
						mission.GoldReward = CF.CalculateReward(CF.MissionGoldRewardPerDifficulty[mission.Type], mission.Difficulty)
						mission.RepReward = CF.CalculateReward(CF.MissionReputationRewardPerDifficulty[mission.Type], mission.Difficulty)
						table.insert(missions, mission);
					end

					if up then
						-- Select planet
						missionSelected = missionSelected - 1
						if missionSelected < 1 then
							missionSelected = #missions
						end
					end

					if down then
						-- Select planet
						missionSelected = missionSelected + 1
						if missionSelected > #missions then
							missionSelected = 1
						end
					end

					if cont:IsState(Controller.WEAPON_FIRE) then
						if not self.FirePressed[player] then
							self.FirePressed[player] = true

							-- Find planet where mission is
							local planet =
								CF.LocationPlanet[missions[missionSelected].Location]

							if self.GS["Planet"] ~= planet then
								-- Move to planet if we're not there
								self.GS["Planet"] = planet
								self.GS["Location"] = nil
								self.GS["Destination"] = nil

								self:SetRandomOrbitLocation()
								-- Recreate all lists
								resetLists = true
							end

							if self.GS["Location"] ~= nil then
								local locpos = CF.LocationPos[self.GS["Location"]] or Vector()

								self.GS["ShipX"] = math.floor(locpos.X)
								self.GS["ShipY"] = math.floor(locpos.Y)
							else
								if self.GS["ShipX"] == nil or self.GS["ShipY"] == nil then
									self:SetRandomOrbitLocation()
								end
							end

							-- Fly to location
							self.GS["Location"] = nil
							self.GS["Destination"] = missions[missionSelected].Location

							local destpos = CF.LocationPos[self.GS["Destination"]] or Vector()

							self.GS["DestX"] = math.floor(destpos.X)
							self.GS["DestY"] = math.floor(destpos.Y)

							self.GS["Distance"] = CF.Dist(
								Vector(tonumber(self.GS["ShipX"]), tonumber(self.GS["ShipY"])),
								Vector(tonumber(self.GS["DestX"]), tonumber(self.GS["DestY"]))
							)

							self.ShipControlMode = self.ShipControlPanelModes.LOCATION
							self.SetDestination = self.GS["Destination"]
						end
					else
						self.FirePressed[player] = false
					end

					local listStart = missionSelected - (missionSelected - 1) % self.ShipControlMissionsPerPage;

					-- Show faction list
					local lineOffset = topOfPage;
					for i = listStart, listStart + self.ShipControlMissionsPerPage - 1 do
						local mission = missions[i];
						if mission then
							local factionName = mission.SourceFaction;
							if factionName ~= nil then
								if i == missionSelected then
									CF.DrawString("> " .. mission.SourceFaction, pos + Vector(-137, lineOffset), 135, 11)
									CF.DrawString("    VS " .. mission.TargetFaction, pos + Vector(-137, lineOffset + 11), 135, 11)
								else
									CF.DrawString(mission.SourceFaction, pos + Vector(-137, lineOffset), 135, 11)
									CF.DrawString("    VS " .. mission.TargetFaction, pos + Vector(-137, lineOffset + 11), 135, 11)
								end
								lineOffset = lineOffset + 22;
							end
						end
					end

					-- Show selected mission info
					local lineOffset = topOfPage;
					CF.DrawString("TARGET: " .. missions[missionSelected].TargetFaction, pos + Vector(3, lineOffset), 135, 11)
					lineOffset = lineOffset + 11;
					CF.DrawString("AT: " .. missions[missionSelected].Location, pos + Vector(3, lineOffset), 135, 11)
					lineOffset = lineOffset + 11;
					CF.DrawString("SECURITY: " .. CF.LocationDifficultyTexts[missions[missionSelected].Difficulty], pos + Vector(3, lineOffset), 135, 11)
					lineOffset = lineOffset + 11;

					CF.DrawString("GOLD: " .. missions[missionSelected].GoldReward .. " oz", pos + Vector(3, lineOffset), 135, 11)
					lineOffset = lineOffset + 11;
					CF.DrawString("REPUTATION: " .. missions[missionSelected].RepReward, pos + Vector(3, lineOffset), 135, 11)
					lineOffset = lineOffset + 11;

					local text = missions[missionSelected].Description;
					text = CF.SplitStringToFitWidth(text, 115, false);
					CF.DrawString(text, pos + Vector(70, (lineOffset + 68) / 2), 115, 66, nil, nil, 1, 1)
					lineOffset = lineOffset + 11;
					
					local page = math.ceil(missionSelected / self.ShipControlMissionsPerPage);
					local maxPages = math.ceil(CF.MaxMissions / self.ShipControlMissionsPerPage);
					highBarLeftText = "AVAILABLE MISSIONS: ";
					highBarRightText = page .. "/" .. maxPages;
					lowBarCenterText = "U/D - Select mission, L/R - Mode, FIRE - Fly";

					self.ShipControlSelectedMission = missionSelected;
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.REPUTATION then
					local factions = {};

					for i = 1, tonumber(self.GS["ActiveCPUs"]) do
						local faction = {};
						faction.Faction = CF.FactionNames[CF.GetPlayerFaction(self.GS, i)];
						faction.Reputation = tonumber(self.GS["Player" .. i .. "Reputation"]);
						table.insert(factions, faction);
					end

					local pageIndex = linesPerPage * (self.ShipControlReputationPage - 1);
					local lineOffset = topOfPage;
					local maxPage = math.max(1, math.ceil(#factions / linesPerPage));

					if up then
						self.ShipControlReputationPage = self.ShipControlReputationPage - 1;
						if self.ShipControlReputationPage < 1 then
							self.ShipControlReputationPage = maxPage;
						end
					end

					if down then
						self.ShipControlReputationPage = self.ShipControlReputationPage + 1;
						if self.ShipControlReputationPage > maxPage then
							self.ShipControlReputationPage = 1;
						end
					end

					for i = 1, math.min(linesPerPage, #factions - pageIndex) do
						faction = factions[pageIndex + i];

						local text
						text = faction.Faction;
						CF.DrawString(text, pos + Vector(-138, lineOffset), 270, 11, nil, nil, 0);
						text = (faction.Reputation > 0 and "+" or "") .. faction.Reputation;
						CF.DrawString(text, pos + Vector(138, lineOffset), 270, 11, nil, nil, 2);

						if faction.Reputation < CF.ReputationHuntThreshold then
							local diff = math.floor(math.abs(faction.Reputation / CF.ReputationPerDifficulty));
							diff = math.max(1, math.min(CF.MaxDifficulty, diff));

							local text = "Sent " .. CF.AssaultDifficultyTexts[diff] .. "s!";
							CF.DrawString(text, pos + Vector(33, lineOffset + 6), 270, 11, true, nil, 0, 1);
						end

						lineOffset = lineOffset + 11;
					end

					highBarLeftText = "INTELLIGENCE REPORT";
					highBarRightText = maxPage > 1 and (self.ShipControlReputationPage .. "/" .. maxPage) or "";
					lowBarCenterText = "U/D - Next/Prev Page, L/R - Mode";
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.BRAIN then
					if self.GS["Brain" .. player .. "Detached"] == "True" then
						if self.Time % 2 == 0 then
							local text;
							text = "PLAYER " .. player + 1 .. " BRAIN DETACHED, ROBOT IN USE!"
							.. "\n" .. self.GS["Brain" .. player .. "SkillPoints"] .. " POINTS AVAILABLE";
							CF.DrawString(text, pos + Vector(0, 0), 270, 40, nil, nil, 1, 1);
						end
						lowBarCenterText = "L/R - Mode";
					else
						local skills = {};
						local selectedSkill = self.ShipControlSelectedSkillUpgrade;

						do
							local skill;

							skill = {};
							skill.Name = "Toughness";
							skill.Variable = "Brain" .. player .. "Toughness";
							skill.Description = "How much punishment your brain robot can take.";
							skill.Price = (tonumber(self.GS[skill.Variable]) + 1) * 2;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Force field";
							skill.Variable = "Brain" .. player .. "Field";
							skill.Description = "Regeneration speed of force field.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Telekinesis";
							skill.Variable = "Brain" .. player .. "Telekinesis";
							skill.Description = "Telekinesis abilities and their power.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Scanning";
							skill.Variable = "Brain" .. player .. "Scanner";
							skill.Description = "Built-in scanner range.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Healing";
							skill.Variable = "Brain" .. player .. "Heal";
							skill.Description = "The strength of automatic healing of nearby allies.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Self-Healing";
							skill.Variable = "Brain" .. player .. "SelfHeal";
							skill.Description = "How many times brain-robot can fully heal itself.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Engineering";
							skill.Variable = "Brain" .. player .. "Fix";
							skill.Description = "How many times brain-robot can fix a weapon. Every level adds 3 charges.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);

							skill = {};
							skill.Name = "Quantum Splitter";
							skill.Variable = "Brain" .. player .. "Splitter";
							skill.Description = "Effectiveness of built-in quantum splitter matter processing.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);
						end

						if tonumber(self.GS["Brain" .. player .. "Splitter"]) > 0 then
							skill = {};
							skill.Name = "Quantum Storage";
							skill.Variable = "Brain" .. player .. "QuantumCapacity";
							skill.Description = "Capacity of built-in quantum storage.";
							skill.Price = tonumber(self.GS[skill.Variable]) + 1;
							table.insert(skills, skill);
						end

						if up then
							selectedSkill = selectedSkill - 1;
							if selectedSkill < 1 then
								selectedSkill = #skills;
							end
						end

						if down then
							selectedSkill = selectedSkill + 1;
							if selectedSkill > #skills then
								selectedSkill = 1;
							end
						end

						local current = tonumber(self.GS[skills[selectedSkill].Variable]);
						local maximum = 5;
						local price = skills[selectedSkill].Price;
						local sklpts = tonumber(self.GS["Brain" .. player .. "SkillPoints"]);

						if cont:IsState(Controller.WEAPON_FIRE) then
							if not self.FirePressed[player] then
								self.FirePressed[player] = true;

								if current < maximum and price <= sklpts then
									self.GS[skills[selectedSkill].Variable] = current + 1;
									self.GS["Brain" .. player .. "SkillPoints"] = sklpts - price;
								end
							end
						else
							self.FirePressed[player] = false;
						end

						lineOffset = topOfPage;
						CF.DrawString("LEVEL: " .. self.GS["Brain" .. player .. "Level"], pos + Vector(-138, lineOffset), 270, 11);
						CF.DrawString(self.GS["Brain" .. player .. "Exp"] .. " / 250 EXP", pos + Vector(-3, lineOffset), 270, 11, nil, nil, 2);
						lineOffset = lineOffset + 16;

						if price > sklpts then
							if self.Time % 2 == 0 then
								CF.DrawString("POINTS: " .. sklpts, pos + Vector(-70, lineOffset), 270, 11, nil, nil, 1);
							end
						else
							CF.DrawString("POINTS: " .. sklpts, pos + Vector(-70, lineOffset), 270, 11, nil, nil, 1);
						end
						lineOffset = lineOffset + 17;

						for i = 1, #skills do
							if i == selectedSkill then
								CF.DrawString("> " .. skills[i].Name, pos + Vector(-138, lineOffset), 130, 11);
							else
								CF.DrawString(skills[i].Name, pos + Vector(-138, lineOffset), 130, 11);
							end
							lineOffset = lineOffset + 11;
						end
						
						lineOffset = topOfPage;
						CF.DrawString("Current level: ", pos + Vector(3, lineOffset), 270, 11);
						CF.DrawString(current .. " / " .. maximum, pos + Vector(138, lineOffset), 270, 11, nil, nil, 2);
						lineOffset = lineOffset + 16;

						if current < maximum then
							CF.DrawString("Skill price: " .. skills[selectedSkill].Price .. " pts", pos + Vector(70, lineOffset), 135, 11, nil, nil, 1);
						else
							CF.DrawString("Skill already maxxed", pos + Vector(70, lineOffset), 135, 11, nil, nil, 1);
						end
						lineOffset = lineOffset + 17;
						
						local text = skills[selectedSkill].Description;
						text = CF.SplitStringToFitWidth(text, 115, false);
						CF.DrawString(text, pos + Vector(70, lineOffset), 115, 110, nil, nil, 1);
						lineOffset = lineOffset + 11;

						self.ShipControlSelectedSkillUpgrade = selectedSkill;

						lowBarCenterText = "U/D - Select, L/R - Mode, FIRE - Upgrade";
					end

					highBarRightText = "P" .. player + 1;
					highBarLeftText = "BRAIN SKILLS";
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.UPGRADE then
					-- Create upgrades list
					local upgrades = {};
					local selectedUpgrade = self.ShipControlSelectedUpgrade;

					do
						local upgrade;

						upgrade = {};
						upgrade.Name = "Cryo-chambers";
						upgrade.Variable = "PlayerVesselClonesCapacity";
						upgrade.Max = CF.VesselMaxClonesCapacity[self.GS["PlayerVessel"]];
						upgrade.Description = "How many bodies you can store.";
						upgrade.Price = CF.ClonePrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Storage";
						upgrade.Variable = "PlayerVesselStorageCapacity";
						upgrade.Max = CF.VesselMaxStorageCapacity[self.GS["PlayerVessel"]];
						upgrade.Description = "How many items you can store.";
						upgrade.Price = CF.StoragePrice;
						upgrade.Bundle = 5;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Life support";
						upgrade.Variable = "PlayerVesselLifeSupport";
						upgrade.Max = CF.VesselMaxLifeSupport[self.GS["PlayerVessel"]];
						upgrade.Description = "How many bodies can be active on ship simultaneously.";
						upgrade.Price = CF.LifeSupportPrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Communication";
						upgrade.Variable = "PlayerVesselCommunication";
						upgrade.Max = CF.VesselMaxCommunication[self.GS["PlayerVessel"]];
						upgrade.Description = "How many bodies you can control on planet surface.";
						upgrade.Price = CF.CommunicationPrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Engine";
						upgrade.Variable = "PlayerVesselSpeed";
						upgrade.Max = CF.VesselMaxSpeed[self.GS["PlayerVessel"]];
						upgrade.Description = "Speed of the vessel. Faster ships are harder to intercept.";
						upgrade.Price = CF.EnginePrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Turret systems";
						upgrade.Variable = "PlayerVesselTurrets";
						upgrade.Max = CF.VesselMaxTurrets[self.GS["PlayerVessel"]];
						upgrade.Description = "How many turrets can be deployed inside the ship.";
						upgrade.Price = CF.TurretPrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Turret storage";
						upgrade.Variable = "PlayerVesselTurretStorage";
						upgrade.Max = CF.VesselMaxTurretStorage[self.GS["PlayerVessel"]];
						upgrade.Description = "How many turrets can be stored in the ship.";
						upgrade.Price = CF.TurretStoragePrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Bomb bays";
						upgrade.Variable = "PlayerVesselBombBays";
						upgrade.Max = CF.VesselMaxBombBays[self.GS["PlayerVessel"]];
						upgrade.Description = "How many bombs can be launched simultaneously.";
						upgrade.Price = CF.BombBayPrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);

						upgrade = {};
						upgrade.Name = "Bomb storage";
						upgrade.Variable = "PlayerVesselBombStorage";
						upgrade.Max = CF.VesselMaxBombStorage[self.GS["PlayerVessel"]];
						upgrade.Description = "How many bombs can be stored in the ship.";
						upgrade.Price = CF.BombStoragePrice;
						upgrade.Bundle = 1;
						table.insert(upgrades, upgrade);
					end

					if up then
						selectedUpgrade = selectedUpgrade - 1;
						if selectedUpgrade < 1 then
							selectedUpgrade = #upgrades;
						end
					end

					if down then
						selectedUpgrade = selectedUpgrade + 1;
						if selectedUpgrade > #upgrades then
							selectedUpgrade = 1;
						end
					end

					local current = tonumber(self.GS[upgrades[selectedUpgrade].Variable]);
					local maximum = upgrades[selectedUpgrade].Max;
					local bundle = upgrades[selectedUpgrade].Bundle;
					local amount = math.min(maximum - current, bundle);
					local price = upgrades[selectedUpgrade].Price * amount;

					if cont:IsState(Controller.WEAPON_FIRE) then
						if not self.FirePressed[player] then
							self.FirePressed[player] = true;

							if current < maximum and price <= CF.GetPlayerGold(self.GS, 0) then
								self.GS[upgrades[selectedUpgrade].Variable] = current + amount;
								self:SetTeamFunds(CF.ChangeGold(self.GS, -price), CF.PlayerTeam);

								-- Re-init turrets panels to add new turrets to ship
								if selectedUpgrade == 6 then
									self:InitTurretsControlPanelUI();
								end
							end
						end
					else
						self.FirePressed[player] = false;
					end

					lineOffset = topOfPage;
					CF.DrawString("SELECT UPGRADE: ", pos + Vector(-138, lineOffset), 270, 11);
					lineOffset = lineOffset + 16;

					if price > CF.GetPlayerGold(self.GS, 0) then
						if self.Time % 2 == 0 then
							CF.DrawString("FUNDS: " .. CF.GetPlayerGold(self.GS, 0) .. " oz", pos + Vector(-70, lineOffset), 135, 11, nil, nil, 1)
						end
					else
						CF.DrawString("FUNDS: " .. CF.GetPlayerGold(self.GS, 0) .. " oz", pos + Vector(-70, lineOffset), 135, 11, nil, nil, 1)
					end
					lineOffset = lineOffset + 17;

					for i = 1, #upgrades do
						if i == selectedUpgrade then
							CF.DrawString("> " .. upgrades[i].Name, pos + Vector(-138, lineOffset), 135, 11);
						else
							CF.DrawString(upgrades[i].Name, pos + Vector(-138, lineOffset), 135, 11);
						end
						lineOffset = lineOffset + 11;
					end

					lineOffset = topOfPage;
					CF.DrawString("Current: ", pos + Vector(3, lineOffset), 135, 11);
					CF.DrawString(current .. " / " .. maximum, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 16;

					if current < maximum then
						CF.DrawString("Upgrade price: " .. price .. " oz", pos + Vector(70, lineOffset), 125, 11, nil, nil, 1)
					else
						CF.DrawString("Upgrade already maxxed", pos + Vector(70, lineOffset), 125, 11, nil, nil, 1)
					end
					lineOffset = lineOffset + 17;

					local text = upgrades[selectedUpgrade].Description .. (amount > 1 and " ( x" .. amount .. " )" or "");
					text = CF.SplitStringToFitWidth(text, 115, false);
					CF.DrawString(text, pos + Vector(70, lineOffset), 115, 88, nil, nil, 1);
					lineOffset = lineOffset + 11;

					self.ShipControlSelectedUpgrade = selectedUpgrade;

					highBarLeftText = "UPGRADE SHIP";
					highBarRightText = CF.VesselName[self.GS["PlayerVessel"]];
					lowBarCenterText = "U/D - Select, L/R - Mode, FIRE - Upgrade";
				end
				-----------------------------------------------------------------------
				if self.ShipControlMode == self.ShipControlPanelModes.SHIPYARD then
					local vessels = {};
					local vesselSelected = self.ShipControlSelectedShip;
					for i = 1, #CF.Vessel do
						table.insert(vessels, CF.Vessel[i]);
					end

					if up then
						vesselSelected = vesselSelected - 1;
						if vesselSelected < 1 then
							vesselSelected = #vessels;
						end
					end

					if down then
						vesselSelected = vesselSelected + 1;
						if vesselSelected > #vessels then
							vesselSelected = 1;
						end
					end

					local id = vessels[vesselSelected];
					local price = CF.VesselPrice[id];
					local tradeInDeduction = CF.VesselPrice[self.GS["PlayerVessel"]] * CF.ShipSellCoeff;
					local installFee = 0;
					local specLines = {};

					-- Procedurally index all of these values, which will look less ugly when a Vessel is an instantiated type.
					local maximumPrefix = "VesselMax";
					local referencePrefix = "VesselStart";
					local playerPrefix = "PlayerVessel";
					local upgradePostfixes = {
						"ClonesCapacity", "StorageCapacity", "LifeSupport",
						"Communication", "Speed", "Turrets",
						"TurretStorage", "BombBays", "BombStorage"
					};
					local priceKeys = {
						"ClonePrice", "StoragePrice", "LifeSupportPrice",
						"CommunicationPrice", "EnginePrice", "TurretPrice",
						"TurretStoragePrice", "BombBayPrice", "BombStoragePrice"
					};
					local upgradeLabels = {
						"Cryo", "Storage", "Life support",
						"Communication", "Engine", "Turrets",
						"Turret storage", "Bomb bays", "Bomb Storage"
					};

					for i = 1, #upgradePostfixes do
						local packageUnits = CF[referencePrefix .. upgradePostfixes[i]][id];
						local currentUnits = tonumber(self.GS[playerPrefix .. upgradePostfixes[i]]);
						local maximumUnits = CF[maximumPrefix .. upgradePostfixes[i]][id];
						local actualUnits = packageUnits + currentUnits;
						local extraUnits = 0;

						if actualUnits > maximumUnits then
							extraUnits = actualUnits - maximumUnits;
							actualUnits = maximumUnits;
						end

						local purchaseUnits = actualUnits - packageUnits;

						if purchaseUnits < 0 then
							purchaseUnits = 0;
						end

						tradeInDeduction = tradeInDeduction + extraUnits * CF[priceKeys[i]] * CF.ShipSellCoeff;
						installFee = installFee + purchaseUnits * CF[priceKeys[i]] * CF.ShipDevInstallCoeff;

						table.insert(specLines, actualUnits .. " / " .. maximumUnits);
					end

					total = price + installFee - tradeInDeduction;

					if cont:IsState(Controller.WEAPON_FIRE) then
						if not self.FirePressed[player] then
							self.FirePressed[player] = true

							local ok = true

							if CF.CountUsedClonesInArray(self.Clones) > actcryo then
								self.ShipControlMessageTime = self.Time
								self.ShipControlMessageText = "Not enough storage to transfer clones"
								ok = false
							end

							if CF.CountUsedStorageInArray(self.StorageItems) > actstor then
								self.ShipControlMessageTime = self.Time
								self.ShipControlMessageText = "Not enough storage to transfer items"
								ok = false
							end

							if CF.GetPlayerGold(self.GS, 0) < total then
								self.ShipControlMessageTime = self.Time
								self.ShipControlMessageText = "Not enough gold"
								ok = false
							end

							if ok then
								-- Pay
								self:SetTeamFunds(CF.ChangeGold(self.GS, -total), CF.PlayerTeam)

								-- Clear turrets pos
								local count = tonumber(self.GS["PlayerVesselTurrets"])
								for i = 1, count do
									self.GS["Actors - Turret" .. i .. "X"] = nil
									self.GS["Actors - Turret" .. i .. "Y"] = nil
								end

								-- Assign new ship
								self.GS["PlayerVessel"] = id

								self.GS["PlayerVesselStorageCapacity"] = actstor
								self.GS["PlayerVesselClonesCapacity"] = actcryo
								self.GS["PlayerVesselLifeSupport"] = actlife
								self.GS["PlayerVesselCommunication"] = actcomm
								self.GS["PlayerVesselSpeed"] = actengn
								self.GS["PlayerVesselTurrets"] = actturr
								self.GS["PlayerVesselTurretStorage"] = actturs
								self.GS["PlayerVesselBombBays"] = actbmbb
								self.GS["PlayerVesselBombStorage"] = actbmbs

								self.GS["Scene"] = CF.VesselScene[self.GS["PlayerVessel"]]

								-- Save everything and restart script
								self:SaveActors(true);
								self.GS["DeserializeOnboard"] = "True";

								self:SaveCurrentGameState()
								self.EnableBrainSelection = false
								self:DestroyConsoles()

								self:LoadCurrentGameState()
								self:LaunchScript(self.GS["Scene"], "Tactics.lua")
								return
							end
						end
					else
						self.FirePressed[player] = false
					end

					lineOffset = topOfPage;
					CF.DrawString("SELECT SHIP:", pos + Vector(-138, lineOffset), 135, 11);
					lineOffset = lineOffset + 11;

					for i = 1, #vessels do
						local id = vessels[i]

						if i == vesselSelected then
							CF.DrawString("> " .. CF.VesselName[id], pos + Vector(-138, lineOffset), 135, 11)
						else
							CF.DrawString(CF.VesselName[id], pos + Vector(-138, lineOffset), 135, 11)
						end
						lineOffset = lineOffset + 11;
					end
					
					lineOffset = -topOfPage;
					CF.DrawString("BASE PRICE: ", pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0, 2)
					CF.DrawString(tostring(price) .. " oz", pos + Vector(-3, lineOffset), 135, 11, nil, nil, 2, 2)
					lineOffset = lineOffset - 11;

					CF.DrawString("YOUR PRICE: ", pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0, 2)
					CF.DrawString(tostring(total) .. " oz", pos + Vector(-3, lineOffset), 135, 11, nil, nil, 2, 2)
					lineOffset = lineOffset - 11;

					CF.DrawString("FUNDS: ", pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0, 2)
					CF.DrawString(CF.GetPlayerGold(self.GS, 0) .. " oz", pos + Vector(-3, lineOffset), 135, 11, nil, nil, 2, 2)
					lineOffset = lineOffset - 11;
					
					lineOffset = topOfPage;
					CF.DrawString("SPECIFICATIONS:", pos + Vector(70, lineOffset), 135, 11, nil, nil, 1)
					lineOffset = lineOffset + 17;
					for i = 1, #specLines do
						CF.DrawString(upgradeLabels[i] .. ": ", pos + Vector(9, lineOffset), 123, 11, nil, nil, 0)
						CF.DrawString(specLines[i], pos + Vector(132, lineOffset), 123, 11, nil, nil, 2)
						lineOffset = lineOffset + 11;
					end

					self.ShipControlSelectedShip = vesselSelected;
					
					highBarLeftText = "PURCHASE SHIP";
					lowBarCenterText = "U/D - Select ship, L/R - Mode, FIRE - Buy ship";
				end
				-----------------------------------------------------------------------

				if not self.encounterData.initialized then
					if cont:IsState(Controller.PRESS_LEFT) then
						self.ShipControlMode = self.ShipControlMode - 1
						self.ShipSelectedItem = 1
						self.LastShipSelectedItem = 0

						if self.ShipControlMode == -1 then
							self.ShipControlMode = self.ShipControlPanelModes.REPORT
						end
					end

					if cont:IsState(Controller.PRESS_RIGHT) then
						self.ShipControlMode = self.ShipControlMode + 1
						self.ShipSelectedItem = 1
						self.LastShipSelectedItem = 0

						if CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.SHIPYARD) then
							if self.ShipControlMode == 8 then
								self.ShipControlMode = self.ShipControlPanelModes.SHIPYARD
							end
						else
							if self.ShipControlMode == 6 then
								self.ShipControlMode = self.ShipControlPanelModes.BRAIN
							end
						end
					end
				else
					self.ShipControlMode = self.ShipControlPanelModes.REPORT
				end

				if self.ShipControlMessageText then
					if self.Time <= self.ShipControlMessageTime + self.ShipControlMessagePeriod then
						lowBarPalette = CF.MenuDeniedIdle;
						lowBarCenterText = self.ShipControlMessageText;
					end
				end

				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 84, pos.X + 140, pos.Y - 71, highBarPalette);
				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y + 71, pos.X + 140, pos.Y + 84, lowBarPalette);

				CF.DrawString(highBarLeftText, pos + Vector(-138, -77), 276, 11, nil, nil, 0, 1);
				CF.DrawString(highBarCenterText, pos + Vector(0, -77), 276, 11, nil, nil, 1, 1);
				CF.DrawString(highBarRightText, pos + Vector(138, -77), 276, 11, nil, nil, 2, 1);

				CF.DrawString(lowBarCenterText, pos + Vector(0, 78), 276, 11, nil, nil, 1, 1);
			end
		end
	end

	if resetLists then
		self.ShipControlSelectedLocation = 1;
		self.ShipControlSelectedPlanet = 1;
		self.ShipControlSelectedMission = 1;
		self.ShipControlReputationPage = 1;
		self.ShipControlSelectedSkillUpgrade = 1;
		self.ShipControlSelectedUpgrade = 1;
		self.ShipControlSelectedShip = 1;
	end
	
	if showIdle and MovableMan:ValidMO(self.ShipControlPanelActor) and self.ShipControlPanelActor.Team == Activity.TEAM_1 then
		local player = Activity.PLAYER_NONE;
		local pos = self.ShipControlPanelActor.Pos;
		local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Ship.png";
		local rotation = 0;
		local hflip = false;
		local vflip = false;
		PrimitiveMan:DrawBitmapPrimitive(player, pos, path, rotation, hflip, vflip);
	end

	if MovableMan:IsActor(self.ShipControlPanelActor) then
		self.ShipControlPanelActor.Health = 100;
	end
end
