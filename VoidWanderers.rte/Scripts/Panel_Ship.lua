-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitShipControlPanelUI()
	local x, y
	x = tonumber(self.SceneConfig["ShipControlPanelX"])
	y = tonumber(self.SceneConfig["ShipControlPanelY"])

	if x ~= nil and y ~= nil then
		self.ShipControlPanelPos = Vector(x, y)
	else
		self.ShipControlPanelPos = nil
	end
	
	self:LocateShipControlPanelActor()
	if self.ShipControlPanelPos ~= nil then
		if not MovableMan:IsActor(self.ShipControlPanelActor) then
			self.ShipControlPanelActor = CreateActor("Ship Control Panel")
			if self.ShipControlPanelActor ~= nil then
				self.ShipControlPanelActor.Pos = self.ShipControlPanelPos
				self.ShipControlPanelActor.Team = CF.PlayerTeam
				MovableMan:AddActor(self.ShipControlPanelActor)
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
	}

	if self.MissionReport ~= nil then
		self.ShipControlMode = self.ShipControlPanelModes.REPORT
	else
		self.ShipControlMode = self.ShipControlPanelModes.LOCATION
	end

	self.ShipControlLastMessageTime = -1000
	self.ShipControlMessageIntrval = 3
	self.ShipControlMessageText = ""

	self.ShipControlSelectedLocation = 1
	self.ShipControlLocationList = nil
	self.ShipControlLocationListStart = 1

	self.ShipControlSelectedPlanet = 1
	self.ShipControlPlanetList = nil
	self.ShipControlPlanetListStart = 1

	self.ShipControlSelectedMission = 1
	self.ShipControlMissionList = nil
	self.ShipControlMissionListStart = 1

	self.ShipControlLocationsPerPage = 10
	self.ShipControlPlanetsPerPage = 10
	self.ShipControlMissionsPerPage = 5

	self.ShipControlSelectedUpgrade = 1
	self.ShipControlSelectedSkillUpgrade = 1
	self.ShipControlSelectedFaction = 1
	self.ShipControlSelectedShip = 1
	
	self.ShipControlReputationPage = 1

	self.vesselData["dialogOptionSelected"] = 1
	self.ShipControlDialogDefaultTime = 17000
end
-----------------------------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyShipControlPanelUI()
	if self.ShipControlPanelActor ~= nil then
		self.ShipControlPanelActor.ToDelete = true;
		self.ShipControlPanelActor = nil;
		return true
	end
	return false
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SetRandomOrbitLocation()
	local planetPanelWidth = 60
	local randPos = Vector(planetPanelWidth * math.random(), 0):RadRotate(RangeRand(-math.pi, math.pi))

	self.GS["ShipX"] = math.floor(randPos.X)
	self.GS["ShipY"] = math.floor(randPos.Y)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessShipControlPanelUI()
	local showidle = true
	local resetlists = false

	if self.MissionReport ~= nil then
		--[[ Force-show report if we have some report array left from previous mission?
		self:SwitchToActor(self.ShipControlPanelActor, 0, CF.PlayerTeam)
		]]
		--
		self.MissionReport = nil
	end

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player)

		if act and MovableMan:IsActor(act) and act.PresetName == "Ship Control Panel" then
			showidle = false

			-- Fill planet list
			self.ShipControlPlanetList = {}
			for i = 1, #CF.Planet do
				if CF.Planet[i] ~= self.GS["Planet"] then
					self.ShipControlPlanetList[#self.ShipControlPlanetList + 1] = CF.Planet[i]
				end
			end

			-- Sort planet list
			for i = 1, #self.ShipControlPlanetList do
				for j = 1, #self.ShipControlPlanetList - 1 do
					if
						CF.PlanetName[self.ShipControlPlanetList[j]]
						> CF.PlanetName[self.ShipControlPlanetList[j + 1]]
					then
						local s = self.ShipControlPlanetList[j]
						self.ShipControlPlanetList[j] = self.ShipControlPlanetList[j + 1]
						self.ShipControlPlanetList[j + 1] = s
					end
				end
			end

			-- Fill location list
			self.ShipControlLocationList = {}
			for i = 1, #CF.Location do
				if CF.LocationPlanet[CF.Location[i]] == self.GS["Planet"] then
					self.ShipControlLocationList[#self.ShipControlLocationList + 1] = CF.Location[i]
				end
			end

			-- Sort location list
			for i = 1, #self.ShipControlLocationList do
				for j = 1, #self.ShipControlLocationList - 1 do
					if
						CF.LocationName[self.ShipControlLocationList[j]]
						> CF.LocationName[self.ShipControlLocationList[j + 1]]
					then
						local s = self.ShipControlLocationList[j]
						self.ShipControlLocationList[j] = self.ShipControlLocationList[j + 1]
						self.ShipControlLocationList[j + 1] = s
					end
				end
			end

			local cont = act:GetController()
			local pos = act.Pos

			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.LOCATION then
				local up = false
				local down = false

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer:Reset()
					up = true
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer:Reset()
					down = true
				end

				if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer:Reset()

					if cont:IsState(Controller.HOLD_UP) then
						up = true
					end

					if cont:IsState(Controller.HOLD_DOWN) then
						down = true
					end
				end

				if up then
					-- Select location
					self.ShipControlSelectedLocation = self.ShipControlSelectedLocation - 1
					if self.ShipControlSelectedLocation < 1 then
						self.ShipControlSelectedLocation = #self.ShipControlLocationList
					end
				end

				if down then
					-- Select location
					self.ShipControlSelectedLocation = self.ShipControlSelectedLocation + 1
					if self.ShipControlSelectedLocation > #self.ShipControlLocationList then
						self.ShipControlSelectedLocation = 1
					end
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						if not self.encounterData["initialized"] then
							if self.GS["Location"] == nil then
								if self.GS["ShipX"] == nil or self.GS["ShipY"] == nil then
									self:SetRandomOrbitLocation()
								end
							end

							self.GS["Location"] = nil
							self.GS["Destination"] = self.ShipControlLocationList[self.ShipControlSelectedLocation]

							local destpos = CF.LocationPos[self.GS["Destination"]] or Vector()

							self.GS["DestX"] = math.floor(destpos.X)
							self.GS["DestY"] = math.floor(destpos.Y)

							self.GS["Distance"] = CF.Dist(
								Vector(tonumber(self.GS["ShipX"]), tonumber(self.GS["ShipY"])),
								Vector(tonumber(self.GS["DestX"]), tonumber(self.GS["DestX"]))
							)
						end
					end
				else
					self.FirePressed[player] = false
				end

				self.ShipControlLocationListStart = self.ShipControlSelectedLocation
					- (self.ShipControlSelectedLocation - 1) % self.ShipControlLocationsPerPage

				-- Draw mode specific elements
				-- Write current location
				if self.GS["Destination"] ~= nil then
					local scale = CF.PlanetScale[self.GS["Planet"]] or 1

					local dst = math.ceil(tonumber(self.GS["Distance"]) * CF.KmPerPixel * scale)

					CF.DrawString("EN ROUTE TO: ", pos + Vector(-62 - 71, -78), 270, 40)
					local locname = CF.LocationName[self.GS["Destination"]]
					if locname ~= nil then
						CF.DrawString(locname .. " - " .. dst .. " km", pos + Vector(-64, -78), 180, 40)
					end
				else
					CF.DrawString("CURRENT LOCATION:", pos + Vector(-62 - 71, -78), 270, 40)
					local locname = CF.LocationName[self.GS["Location"]]
					if locname ~= nil then
						CF.DrawString(locname, pos + Vector(-34, -78), 130, 40)
					else
						CF.DrawString("Distant orbit", pos + Vector(-34, -78), 130, 40)
					end
				end

				CF.DrawString("FLY TO LOCATION:", pos + Vector(-62 - 71, -60), 270, 40)

				CF.DrawString("U/D - Select location, L/R - Mode, FIRE - Fly", pos + Vector(-62 - 71, 78), 270, 40)

				--local shippos = Vector(0,0)

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

				self:PutGlow(shippreset, pos + Vector(sx, sy) + Vector(70, 0))

				if dx ~= nil and dy ~= nil then
					self:DrawDottedLine(cx + sx, cy + sy, cx + dx, cy + dy, "ControlPanel_Ship_DestDot", 5)
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
						self.ShipControlLocationList[self.ShipControlSelectedLocation]
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
				local locpos = CF.LocationPos[self.ShipControlLocationList[self.ShipControlSelectedLocation]]
				if locpos ~= nil then
					if msn then
						self:PutGlow("ControlPanel_Ship_MissionDot", pos + locpos + Vector(70, 0))
					else
						self:PutGlow("ControlPanel_Ship_LocationDot", pos + locpos + Vector(70, 0))
					end

					-- Draw line to location
					local sx = shippos.X
					local sy = shippos.Y

					local dx = locpos.X
					local dy = locpos.Y

					local cx = pos.X + 70
					local cy = pos.Y

					self:DrawDottedLine(cx + sx, cy + sy, cx + dx, cy + dy, "ControlPanel_Ship_RouteDot", 3)
				end

				-- Write security level
				local diff

				if msn then
					CF.DrawString("MISSION: " .. CF.MissionName[msntype], pos + Vector(8, 38), 140, 10)
					CF.DrawString(
						"CONTRACTOR: " .. CF.FactionNames[CF.GetPlayerFaction(self.GS, msncon)],
						pos + Vector(8, 50),
						130,
						10
					)
					CF.DrawString(
						"TARGET: " .. CF.FactionNames[CF.GetPlayerFaction(self.GS, msntgt)],
						pos + Vector(8, 62),
						130,
						10
					)
					diff = msndiff
				else
					diff = CF.GetLocationDifficulty(
						self.GS,
						self.ShipControlLocationList[self.ShipControlSelectedLocation]
					)
				end

				local playable = true

				if CF.LocationPlayable[self.ShipControlLocationList[self.ShipControlSelectedLocation]] ~= nil then
					playable = CF.LocationPlayable[self.ShipControlLocationList[self.ShipControlSelectedLocation]]
				end

				if playable then
					CF.DrawString(
						"SECURITY: " .. string.upper(CF.LocationDifficultyTexts[diff]),
						pos + Vector(8, -60),
						136,
						10
					)

					-- Write gold status
					local gold = CF.LocationGoldPresent[self.ShipControlLocationList[self.ShipControlSelectedLocation]]
					if gold ~= nil then
						CF.DrawString(
							"GOLD: " .. (gold == true and "PRESENT" or "ABSENT"),
							pos + Vector(8, -48),
							136,
							182 - 34
						)
					else
						CF.DrawString("GOLD: UNKNOWN", pos + Vector(8, -48), 136, 182 - 34)
					end
				else
					if
						CF.IsLocationHasAttribute(
							self.ShipControlLocationList[self.ShipControlSelectedLocation],
							CF.LocationAttributeTypes.TRADESTAR
						)
					then
						CF.DrawString("TRADE STAR", pos + Vector(8, -60), 136, 10)
					end

					if
						CF.IsLocationHasAttribute(
							self.ShipControlLocationList[self.ShipControlSelectedLocation],
							CF.LocationAttributeTypes.BLACKMARKET
						)
					then
						CF.DrawString("BLACK MARKET", pos + Vector(8, -60), 136, 10)
					end

					if
						CF.IsLocationHasAttribute(
							self.ShipControlLocationList[self.ShipControlSelectedLocation],
							CF.LocationAttributeTypes.SHIPYARD
						)
					then
						CF.DrawString("SHIPYARD", pos + Vector(8, -60), 136, 10)
					end
				end

				-- Show location list
				if #self.ShipControlLocationList > 0 then
					for i = self.ShipControlLocationListStart, self.ShipControlLocationListStart + self.ShipControlLocationsPerPage - 1 do
						local pname = CF.LocationName[self.ShipControlLocationList[i]]
						if pname ~= nil then
							if i == self.ShipControlSelectedLocation then
								CF.DrawString(
									"> " .. pname,
									pos + Vector(-62 - 71, -40 + (i - self.ShipControlLocationListStart) * 11),
									130,
									10
								)
							else
								CF.DrawString(
									pname,
									pos + Vector(-62 - 71, -40 + (i - self.ShipControlLocationListStart) * 11),
									130,
									10
								)
							end
						end
					end
				else
					CF.DrawString("NO OTHER LOCATIONS", pos + Vector(-62, 77), 130, 12)
				end

				local plntpreset = CF.PlanetGlow[self.GS["Planet"]]
				local plntmodeule = CF.PlanetGlowModule[self.GS["Planet"]]
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(70, 0))
				self:PutGlow(plntpreset, pos + Vector(70, 0), plntmodeule)

				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
			end
			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.PLANET then
				local up = false
				local down = false

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer:Reset()
					up = true
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer:Reset()
					down = true
				end

				if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer:Reset()

					if cont:IsState(Controller.HOLD_UP) then
						up = true
					end

					if cont:IsState(Controller.HOLD_DOWN) then
						down = true
					end
				end

				if up then
					-- Select planet
					self.ShipControlSelectedPlanet = self.ShipControlSelectedPlanet - 1
					if self.ShipControlSelectedPlanet < 1 then
						self.ShipControlSelectedPlanet = #self.ShipControlPlanetList
					end
				end

				if down then
					-- Select planet
					self.ShipControlSelectedPlanet = self.ShipControlSelectedPlanet + 1
					if self.ShipControlSelectedPlanet > #self.ShipControlPlanetList then
						self.ShipControlSelectedPlanet = 1
					end
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						if not self.encounterData["initialized"] then
							-- Travel to another planet
							self.GS["Planet"] = self.ShipControlPlanetList[self.ShipControlSelectedPlanet]
							self.GS["Location"] = nil
							self.GS["Destination"] = nil

							self.GS["DestX"] = nil
							self.GS["DestY"] = nil

							self:SetRandomOrbitLocation()
							-- Recreate all lists
							resetlists = true
						end
					end
				else
					self.FirePressed[player] = false
				end

				self.ShipControlPlanetListStart = self.ShipControlSelectedPlanet
					- (self.ShipControlSelectedPlanet - 1) % self.ShipControlPlanetsPerPage

				-- Show current planet
				local locname = CF.PlanetName[self.GS["Planet"]]
				if locname ~= nil then
					CF.DrawString(locname, pos + Vector(-54, -78), 130, 40)
				end
				CF.DrawString("NOW ORBITING:", pos + Vector(-62 - 71, -78), 130, 40)

				CF.DrawString("WARP TO ANOTHER PLANET:", pos + Vector(-62 - 71, -60), 270, 40)

				CF.DrawString("U/D - Select location, L/R - Mode, FIRE - Fly", pos + Vector(-62 - 71, 78), 270, 40)

				-- Show current planet dot
				local locpos = CF.PlanetPos[self.GS["Planet"]]
				if locpos ~= nil then
					self:PutGlow("ControlPanel_Ship_CurrentLocation", pos + locpos + Vector(70, 0))
				end

				-- Show selected planet dot
				local shppos = CF.PlanetPos[self.ShipControlPlanetList[self.ShipControlSelectedPlanet]]
				if shppos ~= nil then
					self:PutGlow("ControlPanel_Ship_LocationDot", pos + shppos + Vector(70, 0))
				end

				if locpos ~= nil and shppos ~= nil then
					-- Draw line to location
					local sx = locpos.X
					local sy = locpos.Y

					local dx = shppos.X
					local dy = shppos.Y

					local cx = pos.X + 70
					local cy = pos.Y
					
					local gap = 3

					self:DrawWanderingDottedLine(cx + sx, cy + sy, cx + dx, cy + dy, "ControlPanel_Ship_RouteDot", gap, math.fmod(sx - dx, 6) - 3, math.fmod(sy - dy, 2 * math.pi), 10)
				end

				-- Show planet list
				for i = self.ShipControlPlanetListStart, self.ShipControlPlanetListStart + self.ShipControlPlanetsPerPage - 1 do
					local pname = CF.PlanetName[self.ShipControlPlanetList[i]]
					if pname ~= nil then
						if i == self.ShipControlSelectedPlanet then
							CF.DrawString(
								"> " .. pname,
								pos + Vector(-62 - 71, -40 + (i - self.ShipControlPlanetListStart) * 11),
								130,
								12
							)
						else
							CF.DrawString(
								pname,
								pos + Vector(-62 - 71, -40 + (i - self.ShipControlPlanetListStart) * 11),
								130,
								12
							)
						end
					end
				end

				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Ship_GalaxyBack", pos + Vector(70, 0))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
			end
			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.REPORT then
				-- Show current planet
				self:PutGlow("ControlPanel_Ship_Report", pos)
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))

				if not self.vesselData["dialog"] then
					CF.DrawString("REPORT", pos + Vector(-10, -77), 262, 141)
					CF.DrawString("AVAILABLE GOLD: " .. CF.GetPlayerGold(self.GS, 0), pos + Vector(-130, -60), 262, 141)

					CF.DrawString("Press DOWN to save game", pos + Vector(-60, 77), 262, 141)

					for i = 1, CF.MaxMissionReportLines do
						--CF.DrawString("LINE"..i, pos + Vector(-130,-70 + i * 10), 262, 141) -- Debug
						if self.GS["MissionReport" .. i] ~= nil then
							CF.DrawString(self.GS["MissionReport" .. i], pos + Vector(-130, -56 + i * 10), 262, 141)
						else
							break
						end
					end

					if cont:IsState(Controller.PRESS_DOWN) then
						-- Save all items
						for item in MovableMan.Items do
							if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
								local count = CF.CountUsedStorageInArray(self.StorageItems)

								if count < tonumber(self.GS["PlayerVesselStorageCapacity"]) then
									CF.PutItemToStorageArray(
										self.StorageItems,
										item.PresetName,
										item.ClassName,
										item.ModuleName
									)
								else
									break
								end
							end
						end

						CF.SetStorageArray(self.GS, self.StorageItems)
						self.GS["DeserializeOnboard"] = "True"

						self:SaveActors(false)
						self:SaveCurrentGameState()

						print(self.GS["PlayerGold"])

						self:LaunchScript("Void Wanderers", "StrategyScreenMain.lua")
						FORM_TO_LOAD = BASE_PATH .. "FormSave.lua"
						self:DestroyConsoles()
						return
					end
				else
					local offset = 0
					CF.DrawString("INCOMING TRANSMISSION", pos + Vector(-56, -77), 262, 141)
					offset = offset + 12 + CF.DrawString(self.vesselData["dialog"].message, pos + Vector(-130, -56), 262, 141)

					if self.vesselData["dialog"].options and self.vesselData["dialogDefaultTimer"]:IsPastSimMS(750) then
						local up = false
						local down = false

						if cont:IsState(Controller.PRESS_UP) then
							self.HoldTimer:Reset()
							up = true
						end

						if cont:IsState(Controller.PRESS_DOWN) then
							self.HoldTimer:Reset()
							down = true
						end

						if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
							self.HoldTimer:Reset()

							if cont:IsState(Controller.HOLD_UP) then
								up = true
							end

							if cont:IsState(Controller.HOLD_DOWN) then
								down = true
							end
						end

						if up then
							-- Select planet
							self.vesselData["dialogOptionSelected"] = self.vesselData["dialogOptionSelected"] - 1
							if self.vesselData["dialogOptionSelected"] < 1 then
								self.vesselData["dialogOptionSelected"] = #self.vesselData["dialog"].options
							end
						end

						if down then
							-- Select planet
							self.vesselData["dialogOptionSelected"] = self.vesselData["dialogOptionSelected"] + 1
							if self.vesselData["dialogOptionSelected"] > #self.vesselData["dialog"].options then
								self.vesselData["dialogOptionSelected"] = 1
							end
						end

						-- Force the last variant if the player taking too long
						if self.vesselData["dialogDefaultTimer"]:IsPastSimMS(self.ShipControlDialogDefaultTime) then
							self.vesselData["dialogOptionChosen"] = #self.vesselData["dialog"].options
						end

						if cont:IsState(Controller.WEAPON_FIRE) then
							if not self.FirePressed[player] then
								self.FirePressed[player] = true

								self.vesselData["dialogOptionChosen"] = self.vesselData["dialogOptionSelected"]
							end
						else
							self.FirePressed[player] = false
						end

						CF.DrawString("U/D - Select, L/R - Mode, FIRE - Accept", pos + Vector(-62 - 71, 78), 270, 40)

						for i = 1, #self.vesselData["dialog"].options do
							if self.vesselData["dialogOptionSelected"] == i then
								CF.DrawString(
									">",
									pos + Vector(-130, -56 + offset),
									262,
									141
								)
								offset = offset + CF.DrawString(
									self.vesselData["dialog"].options[i],
									pos + Vector(-120, -56 + offset),
									252,
									141
								)
							else
								offset = offset + CF.DrawString(
									self.vesselData["dialog"].options[i],
									pos + Vector(-130, -56 + offset),
									262,
									141
								)
							end
						end
					end
				end
			end
			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.MISSIONS then
				-- Create CPU list
				local cpus = tonumber(self.GS["ActiveCPUs"])

				self.ShipControlMissions = {}
				for i = 1, CF.MaxMissions do
					self.ShipControlMissions[i] = {}
					self.ShipControlMissions[i]["SourcePlayer"] = tonumber(self.GS["Mission" .. i .. "SourcePlayer"])
					self.ShipControlMissions[i]["TargetPlayer"] = tonumber(self.GS["Mission" .. i .. "TargetPlayer"])
					self.ShipControlMissions[i]["Difficulty"] = CF.GetFullMissionDifficulty(
						self.GS,
						self.GS["Mission" .. i .. "Location"],
						i
					) --tonumber(self.GS["Mission"..i.."Difficulty"])
					self.ShipControlMissions[i]["Location"] = self.GS["Mission" .. i .. "Location"]
					self.ShipControlMissions[i]["Type"] = self.GS["Mission" .. i .. "Type"]

					local rep = tonumber(
						self.GS["Player" .. self.ShipControlMissions[i]["SourcePlayer"] .. "Reputation"]
					)
					local srep = ""
					if rep > 0 then
						srep = "+" .. tostring(rep)
					else
						srep = tostring(rep)
					end
					self.ShipControlMissions[i]["SourceFactionReputation"] = srep
					self.ShipControlMissions[i]["SourceFaction"] = CF.FactionNames[CF.GetPlayerFaction(
						self.GS,
						self.ShipControlMissions[i]["SourcePlayer"]
					)]

					local rep = tonumber(
						self.GS["Player" .. self.ShipControlMissions[i]["TargetPlayer"] .. "Reputation"]
					)
					local srep = ""
					if rep > 0 then
						srep = "+" .. tostring(rep)
					else
						srep = tostring(rep)
					end
					self.ShipControlMissions[i]["TargetFactionRaputation"] = srep
					self.ShipControlMissions[i]["TargetFaction"] = CF.FactionNames[CF.GetPlayerFaction(
						self.GS,
						self.ShipControlMissions[i]["TargetPlayer"]
					)]

					self.ShipControlMissions[i]["Description"] =
						CF.MissionBriefingText[self.ShipControlMissions[i]["Type"]]

					self.ShipControlMissions[i]["GoldReward"] = CF.CalculateReward(
						CF.MissionGoldRewardPerDifficulty[self.ShipControlMissions[i]["Type"]],
						self.ShipControlMissions[i]["Difficulty"]
					)
					self.ShipControlMissions[i]["RepReward"] = CF.CalculateReward(
						CF.MissionReputationRewardPerDifficulty[self.ShipControlMissions[i]["Type"]],
						self.ShipControlMissions[i]["Difficulty"]
					)
				end

				local up = false
				local down = false

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer:Reset()
					up = true
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer:Reset()
					down = true
				end

				if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer:Reset()

					if cont:IsState(Controller.HOLD_UP) then
						up = true
					end

					if cont:IsState(Controller.HOLD_DOWN) then
						down = true
					end
				end

				if up then
					-- Select planet
					self.ShipControlSelectedMission = self.ShipControlSelectedMission - 1
					if self.ShipControlSelectedMission < 1 then
						self.ShipControlSelectedMission = #self.ShipControlMissions
					end
				end

				if down then
					-- Select planet
					self.ShipControlSelectedMission = self.ShipControlSelectedMission + 1
					if self.ShipControlSelectedMission > #self.ShipControlMissions then
						self.ShipControlSelectedMission = 1
					end
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						-- Find planet where mission is
						local planet =
							CF.LocationPlanet[self.ShipControlMissions[self.ShipControlSelectedMission]["Location"]]

						if self.GS["Planet"] ~= planet then
							-- Move to planet if we're not there
							self.GS["Planet"] = planet
							self.GS["Location"] = nil
							self.GS["Destination"] = nil

							self:SetRandomOrbitLocation()
							-- Recreate all lists
							resetlists = true
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
						self.GS["Destination"] = self.ShipControlMissions[self.ShipControlSelectedMission]["Location"]

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

				self.ShipControlMissionListStart = self.ShipControlSelectedMission
					- (self.ShipControlSelectedMission - 1) % self.ShipControlMissionsPerPage

				-- Show faction list
				for i = self.ShipControlMissionListStart, self.ShipControlMissionListStart + self.ShipControlMissionsPerPage - 1 do
					if self.ShipControlMissions[i] then
						local factionName = self.ShipControlMissions[i]["SourceFaction"]
						if factionName ~= nil then
							if i == self.ShipControlSelectedMission then
								CF.DrawString(
									"> " .. self.ShipControlMissions[i]["SourceFaction"],
									pos + Vector(-62 - 71, -86 + (i - self.ShipControlMissionListStart + 1) * 25),
									120,
									8
								)
								CF.DrawString(
									">   VS " .. self.ShipControlMissions[i]["TargetFaction"],
									pos + Vector(-62 - 71, -86 + (i - self.ShipControlMissionListStart + 1) * 25 + 10),
									150,
									8
								)
							else
								CF.DrawString(
									self.ShipControlMissions[i]["SourceFaction"],
									pos + Vector(-62 - 71, -86 + (i - self.ShipControlMissionListStart + 1) * 25),
									120,
									8
								)
								CF.DrawString(
									"VS " .. self.ShipControlMissions[i]["TargetFaction"],
									pos
										+ Vector(
											-62 - 71 + 14,
											-86 + (i - self.ShipControlMissionListStart + 1) * 25 + 10
										),
									120,
									8
								)
							end
						end
					end
				end

				-- Show selected mission info
				CF.DrawString(
					"TARGET: " .. self.ShipControlMissions[self.ShipControlSelectedMission]["TargetFaction"],
					pos + Vector(10, -61),
					150,
					8
				)
				CF.DrawString(
					"AT: " .. self.ShipControlMissions[self.ShipControlSelectedMission]["Location"],
					pos + Vector(10, -51),
					150,
					8
				)
				CF.DrawString(
					"SECURITY: "
						.. CF.LocationDifficultyTexts[self.ShipControlMissions[self.ShipControlSelectedMission]["Difficulty"]],
					pos + Vector(10, -41),
					270,
					40
				)

				CF.DrawString(
					"GOLD: " .. self.ShipControlMissions[self.ShipControlSelectedMission]["GoldReward"] .. " oz",
					pos + Vector(10, -31),
					270,
					40
				)
				CF.DrawString(
					"REPUTATION: " .. self.ShipControlMissions[self.ShipControlSelectedMission]["RepReward"],
					pos + Vector(10, -21),
					270,
					40
				)

				CF.DrawString(
					self.ShipControlMissions[self.ShipControlSelectedMission]["Description"],
					pos + Vector(10, -5),
					125,
					80
				)

				CF.DrawString(
					"Available missions: page "
						.. math.ceil(self.ShipControlSelectedMission / self.ShipControlMissionsPerPage)
						.. "/"
						.. math.ceil(CF.MaxMissions / self.ShipControlMissionsPerPage),
					pos + Vector(-62 - 71, -78),
					270,
					40
				)
				CF.DrawString("U/D - Select mission, L/R - Mode, FIRE - Fly", pos + Vector(-62 - 71, 78), 270, 40)
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(70, 0))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
			end
			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.REPUTATION then
				-- Create reputation listing
				local cpus = tonumber(self.GS["ActiveCPUs"])
				local maxPerPage = 9
				self.ShipControlFactions = {}
				for i = 1, cpus do
					self.ShipControlFactions[i] = {}
					self.ShipControlFactions[i]["Faction"] = CF.FactionNames[CF.GetPlayerFaction(self.GS, i)]
					self.ShipControlFactions[i]["Reputation"] = tonumber(self.GS["Player" .. i .. "Reputation"])

					if self.ShipControlFactions[i]["Reputation"] > 0 then
						self.ShipControlFactions[i]["ReputationStr"] = "+"
							.. tostring(self.ShipControlFactions[i]["Reputation"])
					else
						self.ShipControlFactions[i]["ReputationStr"] = tostring(
							self.ShipControlFactions[i]["Reputation"]
						)
					end
				end

				local up = false
				local down = false

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer:Reset()
					up = true
				end
				
				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer:Reset()
					down = true
				end
				
				if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer:Reset()
					
					if cont:IsState(Controller.HOLD_UP) then
						up = true
					end
					
					if cont:IsState(Controller.HOLD_DOWN) then
						down = true
					end
				end

				local maxPage = math.max(1, math.ceil(#self.ShipControlFactions / maxPerPage))
				-- print("maxPage: " .. maxPage)
				if up then
					-- Select faction
					self.ShipControlSelectedFaction = self.ShipControlSelectedFaction - 1
					if self.ShipControlSelectedFaction < 1 then
						self.ShipControlSelectedFaction = #self.ShipControlFactions
					end

					if self.ShipControlReputationPage > 1 then
						self.ShipControlReputationPage = self.ShipControlReputationPage - 1
					end
				end

				if down then
					-- Select faction
					self.ShipControlSelectedFaction = self.ShipControlSelectedFaction + 1
					if self.ShipControlSelectedFaction > #self.ShipControlFactions then
						self.ShipControlSelectedFaction = 1
					end

					if self.ShipControlReputationPage < maxPage then
						self.ShipControlReputationPage = self.ShipControlReputationPage + 1
					end

				end

				-- Show faction list
				local curInd = maxPerPage * (self.ShipControlReputationPage - 1)
				for i = 1, math.min(9, #self.ShipControlFactions - curInd) do
					local str = self.ShipControlFactions[curInd+i]["Faction"]
					if (self.ShipControlFactions[curInd+i]["Faction"] == self.PlayerFaction) then 
						str = str .. " ( YOU )"
					end
					CF.DrawString(str, pos + Vector(-62 - 71, -76 + i * 15), 180, 10)
					CF.DrawString(
						self.ShipControlFactions[curInd+i]["ReputationStr"],
						pos + Vector(-62 - 71 + 200, -76 + i * 15),
						130,
						10
					)

					if self.ShipControlFactions[curInd+i]["Reputation"] < CF.ReputationHuntThreshold then
						local diff = math.floor(
							math.abs(self.ShipControlFactions[curInd+i]["Reputation"] / CF.ReputationPerDifficulty)
						)

						if diff <= 0 then
							diff = 1
						end

						if diff > CF.MaxDifficulty then
							diff = CF.MaxDifficulty
						end

						--diff = 6 -- Debug!!!

						local s = "Sent " .. CF.AssaultDifficultyTexts[diff] .. "s after you!"
						CF.DrawString(s, pos + Vector(-62 - 71 + 120, -76 + i * 15), 160, 12)
					end
				end

				local titleString = "Reputation intelligence report - PAGE "  .. self.ShipControlReputationPage .. " OF " .. maxPage
				CF.DrawString(titleString, pos + Vector(-62 - 71, -78), 270, 40)
				CF.DrawString("U/D - Next/Prev Page, L/R - Mode", pos + Vector(-62 - 71, 78), 270, 40)
				self:PutGlow("ControlPanel_Ship_Report", pos)
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
			end
			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.BRAIN then
				if self.GS["Brain" .. player .. "Detached"] == "True" then
					if self.Time % 2 == 0 then
						CF.DrawString(
							"PLAYER " .. player + 1 .. " BRAIN DETACHED, ROBOT IN USE!",
							pos + Vector(-106, -6),
							270,
							40
						)
						CF.DrawString(
							self.GS["Brain" .. player .. "SkillPoints"] .. " POINTS AVAILABLE",
							pos + Vector(-46, 6),
							270,
							40
						)
					end
					CF.DrawString("L/R - Mode", pos + Vector(-62 - 71, 78), 270, 40)
					self:PutGlow("ControlPanel_Ship_Report", pos)
				else
					self.ShipControlSkillUpgrades = {}
					-- Toughness
					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Toughness"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Toughness"
					self.ShipControlSkillUpgrades[nm]["Description"] = "How much punishment your brain robot can take."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = (val + 1) * 2

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Force field"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Field"
					self.ShipControlSkillUpgrades[nm]["Description"] = "Regeneration speed of force field."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Telekinesis"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Telekinesis"
					self.ShipControlSkillUpgrades[nm]["Description"] = "Telekinesis abilities and their power."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Scanning"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Scanner"
					self.ShipControlSkillUpgrades[nm]["Description"] = "Built-in scanner range."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Healing"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Heal"
					self.ShipControlSkillUpgrades[nm]["Description"] =
						"The strength of automatic healing of nearby allies."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Self-Healing"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "SelfHeal"
					self.ShipControlSkillUpgrades[nm]["Description"] =
						"How many times brain-robot can fully heal itself."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Engineering"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Fix"
					self.ShipControlSkillUpgrades[nm]["Description"] =
						"How many times brain-robot can fix a weapon. Every level adds 3 charges."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					local nm = #self.ShipControlSkillUpgrades + 1
					self.ShipControlSkillUpgrades[nm] = {}
					self.ShipControlSkillUpgrades[nm]["Name"] = "Quantum Splitter"
					self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "Splitter"
					self.ShipControlSkillUpgrades[nm]["Description"] =
						"Effectiveness of built-in quantum splitter matter processing."
					local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
					self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
					self.ShipControlSkillUpgrades[nm]["Price"] = val + 1

					if tonumber(self.GS["Brain" .. player .. "Splitter"]) > 0 then
						local nm = #self.ShipControlSkillUpgrades + 1
						self.ShipControlSkillUpgrades[nm] = {}
						self.ShipControlSkillUpgrades[nm]["Name"] = "Quantum Storage"
						self.ShipControlSkillUpgrades[nm]["Variable"] = "Brain" .. player .. "QuantumCapacity"
						self.ShipControlSkillUpgrades[nm]["Description"] = "Capacity of built-in quantum storage."
						local val = tonumber(self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]])
						self.GS[self.ShipControlSkillUpgrades[nm]["Variable"]] = val
						self.ShipControlSkillUpgrades[nm]["Price"] = val + 1
					end

					local up = false
					local down = false

					if cont:IsState(Controller.PRESS_UP) then
						self.HoldTimer:Reset()
						up = true
					end

					if cont:IsState(Controller.PRESS_DOWN) then
						self.HoldTimer:Reset()
						down = true
					end

					if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
						self.HoldTimer:Reset()

						if cont:IsState(Controller.HOLD_UP) then
							up = true
						end

						if cont:IsState(Controller.HOLD_DOWN) then
							down = true
						end
					end

					if up then
						self.ShipControlSelectedSkillUpgrade = self.ShipControlSelectedSkillUpgrade - 1
						if self.ShipControlSelectedSkillUpgrade < 1 then
							self.ShipControlSelectedSkillUpgrade = #self.ShipControlSkillUpgrades
						end
					end

					if down then
						self.ShipControlSelectedSkillUpgrade = self.ShipControlSelectedSkillUpgrade + 1
						if self.ShipControlSelectedSkillUpgrade > #self.ShipControlSkillUpgrades then
							self.ShipControlSelectedSkillUpgrade = 1
						end
					end

					local current = tonumber(
						self.GS[self.ShipControlSkillUpgrades[self.ShipControlSelectedSkillUpgrade]["Variable"]]
					)
					local maximum = 5
					local price = self.ShipControlSkillUpgrades[self.ShipControlSelectedSkillUpgrade]["Price"]
					local sklpts = tonumber(self.GS["Brain" .. player .. "SkillPoints"])

					CF.DrawString("LEVEL: " .. self.GS["Brain" .. player .. "Level"], pos + Vector(-62 - 71, -60), 270, 40)
					CF.DrawString("EXP: " .. self.GS["Brain" .. player .. "Exp"], pos + Vector(-62, -60), 270, 40)

					if price > sklpts then
						if self.Time % 2 == 0 then
							CF.DrawString("POINTS: " .. sklpts, pos + Vector(-62 - 71, -46), 270, 40)
						end
					else
						CF.DrawString("POINTS: " .. sklpts, pos + Vector(-62 - 71, -46), 270, 40)
					end

					CF.DrawString("Current level: " .. current, pos + Vector(10, -30), 270, 40)
					CF.DrawString("Maximum level: " .. maximum, pos + Vector(10, -20), 270, 40)
					if current < maximum then
						CF.DrawString(
							"Points needed: "
								.. self.ShipControlSkillUpgrades[self.ShipControlSelectedSkillUpgrade]["Price"],
							pos + Vector(10, -10),
							270,
							40
						)
					end

					CF.DrawString(
						self.ShipControlSkillUpgrades[self.ShipControlSelectedSkillUpgrade]["Description"],
						pos + Vector(10, 10),
						130,
						80
					)

					if cont:IsState(Controller.WEAPON_FIRE) then
						if not self.FirePressed[player] then
							self.FirePressed[player] = true

							if current < maximum and price <= sklpts then
								self.GS[self.ShipControlSkillUpgrades[self.ShipControlSelectedSkillUpgrade]["Variable"]] = current
									+ 1
								sklpts = sklpts - price
								self.GS["Brain" .. player .. "SkillPoints"] = sklpts
							end
						end
					else
						self.FirePressed[player] = false
					end

					-- Show list
					for i = 1, #self.ShipControlSkillUpgrades do
						if i == self.ShipControlSelectedSkillUpgrade then
							CF.DrawString(
								"> " .. self.ShipControlSkillUpgrades[i]["Name"],
								pos + Vector(-62 - 71, -40 + i * 11),
								130,
								12
							)
						else
							CF.DrawString(
								self.ShipControlSkillUpgrades[i]["Name"],
								pos + Vector(-62 - 71, -40 + i * 11),
								130,
								12
							)
						end
					end

					CF.DrawString("U/D - Select, L/R - Mode, FIRE - Upgrade", pos + Vector(-62 - 71, 78), 270, 40)
					self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(-71, 0))
					self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(70, 0))
				end

				CF.DrawString("Player " .. player + 1 .. " brain robot maintenance", pos + Vector(-62 - 71, -78), 270, 40)

				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
			end
			-------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.UPGRADE then
				-- Create upgrades list
				self.ShipControlUpgrades = {}
				self.ShipControlUpgrades[1] = {}
				self.ShipControlUpgrades[1]["Name"] = "Cryo-chambers"
				self.ShipControlUpgrades[1]["Variable"] = "Player0VesselClonesCapacity"
				self.ShipControlUpgrades[1]["Max"] = CF.VesselMaxClonesCapacity[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[1]["Description"] = "How many bodies you can store"
				self.ShipControlUpgrades[1]["Price"] = CF.ClonePrice
				self.ShipControlUpgrades[1]["Bundle"] = 1

				self.ShipControlUpgrades[2] = {}
				self.ShipControlUpgrades[2]["Name"] = "Storage"
				self.ShipControlUpgrades[2]["Variable"] = "Player0VesselStorageCapacity"
				self.ShipControlUpgrades[2]["Max"] = CF.VesselMaxStorageCapacity[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[2]["Description"] = "How many items you can store"
				self.ShipControlUpgrades[2]["Price"] = CF.StoragePrice
				self.ShipControlUpgrades[2]["Bundle"] = 5

				self.ShipControlUpgrades[3] = {}
				self.ShipControlUpgrades[3]["Name"] = "Life support"
				self.ShipControlUpgrades[3]["Variable"] = "Player0VesselLifeSupport"
				self.ShipControlUpgrades[3]["Max"] = CF.VesselMaxLifeSupport[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[3]["Description"] = "How many bodies can be active on ship simultaneously"
				self.ShipControlUpgrades[3]["Price"] = CF.LifeSupportPrice
				self.ShipControlUpgrades[3]["Bundle"] = 1

				self.ShipControlUpgrades[4] = {}
				self.ShipControlUpgrades[4]["Name"] = "Communication"
				self.ShipControlUpgrades[4]["Variable"] = "Player0VesselCommunication"
				self.ShipControlUpgrades[4]["Max"] = CF.VesselMaxCommunication[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[4]["Description"] = "How many bodies you can control on planet surface"
				self.ShipControlUpgrades[4]["Price"] = CF.CommunicationPrice
				self.ShipControlUpgrades[4]["Bundle"] = 1

				self.ShipControlUpgrades[5] = {}
				self.ShipControlUpgrades[5]["Name"] = "Engine"
				self.ShipControlUpgrades[5]["Variable"] = "Player0VesselSpeed"
				self.ShipControlUpgrades[5]["Max"] = CF.VesselMaxSpeed[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[5]["Description"] =
					"Speed of the vessel. Faster ships are harder to intercept."
				self.ShipControlUpgrades[5]["Price"] = CF.EnginePrice
				self.ShipControlUpgrades[5]["Bundle"] = 1

				self.ShipControlUpgrades[6] = {}
				self.ShipControlUpgrades[6]["Name"] = "Turret systems"
				self.ShipControlUpgrades[6]["Variable"] = "Player0VesselTurrets"
				self.ShipControlUpgrades[6]["Max"] = CF.VesselMaxTurrets[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[6]["Description"] = "How many turrets can be deployed inside the ship"
				self.ShipControlUpgrades[6]["Price"] = CF.TurretPrice
				self.ShipControlUpgrades[6]["Bundle"] = 1

				self.ShipControlUpgrades[7] = {}
				self.ShipControlUpgrades[7]["Name"] = "Turret storage"
				self.ShipControlUpgrades[7]["Variable"] = "Player0VesselTurretStorage"
				self.ShipControlUpgrades[7]["Max"] = CF.VesselMaxTurretStorage[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[7]["Description"] = "How many turrets can be stored in the ship"
				self.ShipControlUpgrades[7]["Price"] = CF.TurretStoragePrice
				self.ShipControlUpgrades[7]["Bundle"] = 1

				self.ShipControlUpgrades[8] = {}
				self.ShipControlUpgrades[8]["Name"] = "Bomb bays"
				self.ShipControlUpgrades[8]["Variable"] = "Player0VesselBombBays"
				self.ShipControlUpgrades[8]["Max"] = CF.VesselMaxBombBays[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[8]["Description"] = "How many bombs can be launched simultaneously"
				self.ShipControlUpgrades[8]["Price"] = CF.BombBayPrice
				self.ShipControlUpgrades[8]["Bundle"] = 1

				self.ShipControlUpgrades[9] = {}
				self.ShipControlUpgrades[9]["Name"] = "Bomb storage"
				self.ShipControlUpgrades[9]["Variable"] = "Player0VesselBombStorage"
				self.ShipControlUpgrades[9]["Max"] = CF.VesselMaxBombStorage[self.GS["PlayerVessel"]]
				self.ShipControlUpgrades[9]["Description"] = "How many bombs can be stored in the ship"
				self.ShipControlUpgrades[9]["Price"] = CF.BombStoragePrice
				self.ShipControlUpgrades[9]["Bundle"] = 1

				local up = false
				local down = false

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer:Reset()
					up = true
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer:Reset()
					down = true
				end

				if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer:Reset()

					if cont:IsState(Controller.HOLD_UP) then
						up = true
					end

					if cont:IsState(Controller.HOLD_DOWN) then
						down = true
					end
				end

				if up then
					-- Select planet
					self.ShipControlSelectedUpgrade = self.ShipControlSelectedUpgrade - 1
					if self.ShipControlSelectedUpgrade < 1 then
						self.ShipControlSelectedUpgrade = #self.ShipControlUpgrades
					end
				end

				if down then
					-- Select planet
					self.ShipControlSelectedUpgrade = self.ShipControlSelectedUpgrade + 1
					if self.ShipControlSelectedUpgrade > #self.ShipControlUpgrades then
						self.ShipControlSelectedUpgrade = 1
					end
				end

				-- Show planet list
				for i = 1, #self.ShipControlUpgrades do
					if i == self.ShipControlSelectedUpgrade then
						CF.DrawString(
							"> " .. self.ShipControlUpgrades[i]["Name"],
							pos + Vector(-62 - 71, -40 + i * 11),
							130,
							12
						)
					else
						CF.DrawString(
							self.ShipControlUpgrades[i]["Name"],
							pos + Vector(-62 - 71, -40 + i * 11),
							130,
							12
						)
					end
				end

				CF.DrawString("SELECT UPGRADE:", pos + Vector(-62 - 71, -60), 270, 40)

				local current = tonumber(self.GS[self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Variable"]])
				local maximum = self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Max"]
				local bundle = self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Bundle"]
				amount = math.min(maximum - current, bundle)


				local price = self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Price"] * amount

				if price > CF.GetPlayerGold(self.GS, 0) then
					if self.Time % 2 == 0 then
						CF.DrawString(
							"FUNDS: " .. CF.GetPlayerGold(self.GS, 0) .. " oz",
							pos + Vector(-62 - 71, -46),
							270,
							40
						)
					end
				else
					CF.DrawString(
						"FUNDS: " .. CF.GetPlayerGold(self.GS, 0) .. " oz",
						pos + Vector(-62 - 71, -46),
						270,
						40
					)
				end

				CF.DrawString("Current: " .. current, pos + Vector(10, -30), 270, 40)
				CF.DrawString("Maximum: " .. maximum, pos + Vector(10, -20), 270, 40)
				if current < maximum then
					CF.DrawString("Upgrade price: " .. price .. " oz", pos + Vector(10, -10), 270, 40)
				end

				if amount == 1 then
					CF.DrawString(
						self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Description"],
						pos + Vector(10, 10),
						130,
						80
					)
				else
					CF.DrawString(
						self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Description"]
							.. " ( x"
							.. amount
							.. " )",
						pos + Vector(10, 10),
						130,
						80
					)
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						if current < maximum and price <= CF.GetPlayerGold(self.GS, 0) then
							self.GS[self.ShipControlUpgrades[self.ShipControlSelectedUpgrade]["Variable"]] = current
								+ amount
							self:SetTeamFunds(CF.ChangeGold(self.GS, -price), CF.PlayerTeam)

							-- Re-init turrets panels to add new turrets to ship
							if self.ShipControlSelectedUpgrade == 6 then
								self:InitTurretsControlPanelUI()
							end
						end
					end
				else
					self.FirePressed[player] = false
				end

				CF.DrawString("Upgrade ship", pos + Vector(-62 - 71, -78), 270, 40)
				CF.DrawString("U/D - Select, L/R - Mode, FIRE - Upgrade", pos + Vector(-62 - 71, 78), 270, 40)
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(70, 0))

				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
			end
			---------------------------------------------------------------------------------------------------
			if self.ShipControlMode == self.ShipControlPanelModes.SHIPYARD then
				-- Create ship list
				self.ShipControlShips = {}
				for i = 1, #CF.Vessel do
					local id = CF.Vessel[i]

					if self.GS["PlayerVessel"] ~= id then
						local nv = #self.ShipControlShips + 1

						self.ShipControlShips[nv] = id
					end
				end

				local up = false
				local down = false

				if cont:IsState(Controller.PRESS_UP) then
					self.HoldTimer:Reset()
					up = true
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					self.HoldTimer:Reset()
					down = true
				end

				if self.HoldTimer:IsPastSimMS(CF.KeyRepeatDelay) then
					self.HoldTimer:Reset()

					up = cont:IsState(Controller.HOLD_UP)
					down = cont:IsState(Controller.HOLD_DOWN)
				end

				if up then
					-- Select planet
					self.ShipControlSelectedShip = self.ShipControlSelectedShip - 1
					if self.ShipControlSelectedShip < 1 then
						self.ShipControlSelectedShip = #self.ShipControlShips
					end
				end

				if down then
					-- Select planet
					self.ShipControlSelectedShip = self.ShipControlSelectedShip + 1
					if self.ShipControlSelectedShip > #self.ShipControlShips then
						self.ShipControlSelectedShip = 1
					end
				end

				-- Show ship list
				for i = 1, #self.ShipControlShips do
					local id = self.ShipControlShips[i]

					if i == self.ShipControlSelectedShip then
						CF.DrawString("> " .. CF.VesselName[id], pos + Vector(-62 - 71, -40 + i * 11), 130, 12)
					else
						CF.DrawString(CF.VesselName[id], pos + Vector(-62 - 71, -40 + i * 11), 130, 12)
					end
				end

				CF.DrawString("SELECT SHIP:", pos + Vector(-62 - 71, -60), 140, 40)
				CF.DrawString("SPECIFICATIONS:", pos + Vector(8, -60), 140, 40)

				-- Show specs
				local id = self.ShipControlShips[self.ShipControlSelectedShip]
				local price = CF.VesselPrice[id]
				local bonus = CF.VesselPrice[self.GS["PlayerVessel"]] * CF.ShipSellCoeff
				local instl = 0

				-- Cryo chambers
				local newcryo = CF.VesselStartClonesCapacity[id]
				local oldcryo = tonumber(self.GS["PlayerVesselClonesCapacity"])
				local maxcryo = CF.VesselMaxClonesCapacity[id]
				local actcryo = newcryo + oldcryo
				local exccryo = 0
				if actcryo > maxcryo then
					exccryo = newcryo + oldcryo - maxcryo
					actcryo = maxcryo
				end

				local inscryo = actcryo - newcryo
				if inscryo < 0 then
					inscryo = 0
				end

				bonus = bonus + exccryo * CF.ClonePrice * CF.ShipSellCoeff
				instl = instl + inscryo * CF.ClonePrice * CF.ShipDevInstallCoeff

				--print (inscryo)
				--print (instl)

				CF.DrawString("Cryo:", pos + Vector(8, -48), 140, 40)
				CF.DrawString("" .. actcryo .. "/" .. maxcryo, pos + Vector(8 + 90, -48), 140, 40)

				-- Storage
				local newstor = CF.VesselStartStorageCapacity[id]
				local oldstor = tonumber(self.GS["PlayerVesselStorageCapacity"])
				local maxstor = CF.VesselMaxStorageCapacity[id]
				local actstor = newstor + oldstor
				local excstor = 0
				if actstor > maxstor then
					excstor = newstor + oldstor - maxstor
					actstor = maxstor
				end

				local insstor = actstor - newstor
				if insstor < 0 then
					insstor = 0
				end

				bonus = bonus + excstor * CF.StoragePrice * CF.ShipSellCoeff
				instl = instl + insstor * CF.StoragePrice * CF.ShipDevInstallCoeff

				--print (insstor)
				--print (instl)

				CF.DrawString("Storage:", pos + Vector(8, -36), 140, 40)
				CF.DrawString("" .. actstor .. "/" .. maxstor, pos + Vector(8 + 90, -36), 140, 40)

				-- Life support
				local newlife = CF.VesselStartLifeSupport[id]
				local oldlife = tonumber(self.GS["PlayerVesselLifeSupport"])
				local maxlife = CF.VesselMaxLifeSupport[id]
				local actlife = newlife + oldlife
				local exclife = 0
				if actlife > maxlife then
					exclife = newlife + oldlife - maxlife
					actlife = maxlife
				end

				local inslife = actlife - newlife
				if inslife < 0 then
					inslife = 0
				end

				bonus = bonus + exclife * CF.LifeSupportPrice * CF.ShipSellCoeff
				instl = instl + inslife * CF.LifeSupportPrice * CF.ShipDevInstallCoeff

				--print (inslife)
				--print (instl)

				CF.DrawString("Life support:", pos + Vector(8, -24), 140, 40)
				CF.DrawString("" .. actlife .. "/" .. maxlife, pos + Vector(8 + 90, -24), 140, 40)

				-- Communcation
				local newcomm = CF.VesselStartCommunication[id]
				local oldcomm = tonumber(self.GS["PlayerVesselCommunication"])
				local maxcomm = CF.VesselMaxCommunication[id]
				local actcomm = newcomm + oldcomm
				local exccomm = 0
				if actcomm > maxcomm then
					exccomm = newcomm + oldcomm - maxcomm
					actcomm = maxcomm
				end

				local inscomm = actcomm - newcomm
				if inscomm < 0 then
					inscomm = 0
				end
				
				bonus = bonus + exccomm * CF.CommunicationPrice * CF.ShipSellCoeff
				instl = instl + inscomm * CF.CommunicationPrice * CF.ShipDevInstallCoeff

				--print (inscomm)
				--print (instl)

				CF.DrawString("Communication:", pos + Vector(8, -12), 140, 40)
				CF.DrawString("" .. actcomm .. "/" .. maxcomm, pos + Vector(8 + 90, -12), 140, 40)

				-- Engine
				local actengn = CF.VesselStartSpeed[id]
				local maxengn = CF.VesselMaxSpeed[id]
				local excengn = tonumber(self.GS["PlayerVesselEngine"])

				CF.DrawString("Engine:", pos + Vector(8, 0), 140, 40)
				CF.DrawString("" .. actengn .. "/" .. maxengn, pos + Vector(8 + 90, 0), 140, 40)

				-- Turrets
				local newturr = CF.VesselStartTurrets[id]
				local oldturr = tonumber(self.GS["PlayerVesselTurrets"])
				local maxturr = CF.VesselMaxTurrets[id]
				local actturr = newturr + oldturr
				local excturr = 0
				if actturr > maxturr then
					excturr = newturr + oldturr - maxturr
					actturr = maxturr
				end

				local insturr = actturr - newturr
				if insturr < 0 then
					insturr = 0
				end

				bonus = bonus + excturr * CF.TurretPrice * CF.ShipSellCoeff
				instl = instl + insturr * CF.TurretPrice * CF.ShipDevInstallCoeff

				--print (insturr)
				--print (instl)

				CF.DrawString("Turrets:", pos + Vector(8, 12), 140, 40)
				CF.DrawString("" .. actturr .. "/" .. maxturr, pos + Vector(8 + 90, 12), 140, 40)

				-- Turrets storage
				local newturs = CF.VesselStartTurretStorage[id]
				local oldturs = tonumber(self.GS["PlayerVesselTurretStorage"])
				local maxturs = CF.VesselMaxTurretStorage[id]
				local actturs = newturs + oldturs
				local excturs = 0
				if actturs > maxturs then
					excturs = newturs + oldturs - maxturs
					actturs = maxturs
				end

				local insturs = actturs - newturs
				if insturs < 0 then
					insturs = 0
				end

				bonus = bonus + excturs * CF.TurretStoragePrice * CF.ShipSellCoeff
				instl = instl + insturs * CF.TurretStoragePrice * CF.ShipDevInstallCoeff

				--print (insturs)
				--print (instl)

				CF.DrawString("Turret storage:", pos + Vector(8, 24), 140, 40)
				CF.DrawString("" .. actturs .. "/" .. maxturs, pos + Vector(8 + 90, 24), 140, 40)

				-- Bomb bays
				local newbmbb = CF.VesselStartBombBays[id]
				local oldbmbb = tonumber(self.GS["PlayerVesselBombBays"])
				local maxbmbb = CF.VesselMaxBombBays[id]
				local actbmbb = newbmbb + oldbmbb
				local excbmbb = 0
				if actbmbb > maxbmbb then
					excbmbb = newbmbb + oldbmbb - maxbmbb
					actbmbb = maxbmbb
				end

				local insbmbb = actbmbb - newbmbb
				if insbmbb < 0 then
					insbmbb = 0
				end

				bonus = bonus + excbmbb * CF.BombBayPrice * CF.ShipSellCoeff
				instl = instl + insbmbb * CF.BombBayPrice * CF.ShipDevInstallCoeff

				--print (insbmbb)
				--print (instl)

				CF.DrawString("Bomb bays:", pos + Vector(8, 36), 140, 40)
				CF.DrawString("" .. actbmbb .. "/" .. maxbmbb, pos + Vector(8 + 90, 36), 140, 40)

				-- Bombs storage
				local newbmbs = CF.VesselStartBombStorage[id]
				local oldbmbs = tonumber(self.GS["PlayerVesselBombStorage"])
				local maxbmbs = CF.VesselMaxBombStorage[id]
				local actbmbs = newbmbs + oldbmbs
				local excbmbs = 0
				if actbmbs > maxbmbs then
					excbmbs = newbmbs + oldbmbs - maxbmbs
					actbmbs = maxbmbs
				end

				local insbmbs = actbmbs - newbmbs
				if insbmbs < 0 then
					insbmbs = 0
				end

				bonus = bonus + excbmbs * CF.BombStoragePrice * CF.ShipSellCoeff
				instl = instl + insbmbs * CF.BombStoragePrice * CF.ShipDevInstallCoeff

				--print (insbmbs)
				--print (instl)

				CF.DrawString("Bomb storage:", pos + Vector(8, 48), 140, 40)
				CF.DrawString("" .. actbmbs .. "/" .. maxbmbs, pos + Vector(8 + 90, 48), 140, 40)

				bonus = math.floor(bonus)
				instl = math.floor(instl)

				total = price + instl - bonus

				CF.DrawString("BASE PRICE:", pos + Vector(8, 48) + Vector(-140, 0), 140, 40)
				CF.DrawString(tostring(price) .. "oz", pos + Vector(76, 48) + Vector(-140, 0), 140, 40)

				--CF.DrawString("INSTALL:", pos + Vector(8, 36), 140, 40)
				--CF.DrawString(tostring(instl).."oz", pos + Vector(70, 36), 140, 40)

				--CF.DrawString("TRADE-IN:", pos + Vector(8, 48), 140, 40)
				--CF.DrawString(tostring(bonus).."oz", pos + Vector(70, 48), 140, 40)

				CF.DrawString("YOUR PRICE:", pos + Vector(8, 60) + Vector(-140, 0), 140, 40)
				CF.DrawString(tostring(total) .. "oz", pos + Vector(76, 60) + Vector(-140, 0), 140, 40)

				if total > CF.GetPlayerGold(self.GS, 0) then
					if self.Time % 2 == 0 then
						CF.DrawString(
							"FUNDS: " .. CF.GetPlayerGold(self.GS, 0) .. " oz",
							pos + Vector(-62 - 71, -46),
							270,
							40
						)
					end
				else
					CF.DrawString(
						"FUNDS: " .. CF.GetPlayerGold(self.GS, 0) .. " oz",
						pos + Vector(-62 - 71, -46),
						270,
						40
					)
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						local ok = true

						if CF.CountUsedClonesInArray(self.Clones) > actcryo then
							self.ShipControlLastMessageTime = self.Time
							self.ShipControlMessageText = "Not enough storage to transfer clones"
							ok = false
						end

						if CF.CountUsedStorageInArray(self.StorageItems) > actstor then
							self.ShipControlLastMessageTime = self.Time
							self.ShipControlMessageText = "Not enough storage to transfer items"
							ok = false
						end

						if CF.GetPlayerGold(self.GS, 0) < total then
							self.ShipControlLastMessageTime = self.Time
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
							self:SaveActors(true)

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

				CF.DrawString("Buy new ship", pos + Vector(-62 - 71, -78), 270, 40)
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Ship_PlanetBack", pos + Vector(70, 0))

				if self.Time < self.ShipControlLastMessageTime + self.ShipControlMessageIntrval then
					self:PutGlow("ControlPanel_Ship_HorizontalPanelRed", pos + Vector(0, 78))
					CF.DrawString(self.ShipControlMessageText, pos + Vector(-130, 78), 300, 10)
				else
					CF.DrawString("U/D - Select ship, L/R - Mode, FIRE - Buy ship", pos + Vector(-62 - 71, 78), 270, 40)
					self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, 78))
				end

				self:PutGlow("ControlPanel_Ship_HorizontalPanel", pos + Vector(0, -77))
			end
			---------------------------------------------------------------------------------------------------

			if not self.encounterData["initialized"] then
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
		end
	end

	if showidle and self.ShipControlPanelPos ~= nil and self.ShipControlPanelActor ~= nil then
		self:PutGlow("ControlPanel_Ship", self.ShipControlPanelPos)
		--CF.DrawString("BRIDGE",self.ShipControlPanelPos + Vector(-15,0),120,20 )
		resetlists = true
	end

	if resetlists then
		self.ShipControlMode = self.ShipControlPanelModes.LOCATION

		self.ShipControlSelectedLocation = 1
		self.ShipControlLocationList = nil
		self.ShipControlLocationListStart = 1

		self.ShipControlSelectedPlanet = 1
		self.ShipControlPlanetListStart = 1
		self.ShipControlPlanetList = nil
	end

	if MovableMan:IsActor(self.ShipControlPanelActor) then
		self.ShipControlPanelActor.Health = 100
	end
end
