-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitLZControlPanelUI()
	self.LZControlPanelActor = {}
	self.ControlPanelLZPressTimes = {}

	self.BombsControlPanelInBombMode = false

	self.BombsControlPanelItemsPerPage = 3
	self.LastKnownBombingPosition = nil

	self.BombsControlPanelModes = { RETURN = 0, BOMB = 1 }
	self.BombsControlPanelSelectedModes = {}

	-- Reset bombing state
	self.BombingTarget = nil
	self.BombingStart = nil
	self.BombingLoadTime = nil
	self.BombingRange = nil

	local panelPos = Vector()

	local brainsAbsent = self.GS["BrainsOnMission"] == "False"
	
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		--print("PLAYER #" .. player .. ": " .. tostring(brainsAbsent and self:PlayerActive(player) and self:PlayerHuman(player)) .. " " .. tostring(not brainsAbsent and player == Activity.PLAYER_1))
		if (brainsAbsent and self:PlayerActive(player) and self:PlayerHuman(player)) or (not brainsAbsent and player == Activity.PLAYER_1) then
			-- Create actor
			if not MovableMan:IsActor(self.LZControlPanelActor[player + 1]) then
				self.LZControlPanelActor[player + 1] = CreateActor("LZ Control Panel")
				if self.LZControlPanelActor[player + 1] ~= nil then
					self.LZControlPanelActor[player + 1].Pos = self.LZControlPanelPos[player + 1]
					self.LZControlPanelActor[player + 1].Team = CF.PlayerTeam
					MovableMan:AddActor(self.LZControlPanelActor[player + 1])
					if brainsAbsent then
						self:SetPlayerBrain(self.LZControlPanelActor[player + 1], player)
						self:SwitchToActor(self.LZControlPanelActor[player + 1], player, CF.PlayerTeam)
					end
				end
				self.BombsControlPanelSelectedModes[player + 1] = self.BombsControlPanelModes.RETURN
			end
		end
	end
	
	local zoneLeft = Vector(math.min(self.LZControlPanelPos[1].X, self.LZControlPanelPos[4].X), math.min(self.LZControlPanelPos[1].Y, self.LZControlPanelPos[4].Y))
	local zoneRight = Vector(math.max(self.LZControlPanelPos[1].X, self.LZControlPanelPos[4].X), math.max(self.LZControlPanelPos[1].Y, self.LZControlPanelPos[4].Y))
	local screenDim = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight)
	self.lzBox = Box(zoneLeft + screenDim * -0.5, zoneRight + screenDim * 0.5)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:CraftEnteredOrbit(orbitedCraft)
	print("Halp")
	if orbitedCraft.PresetName ~= "Fake Drop Ship MK1" and self.GS["Mode"] ~= "Vessel" then
		if orbitedCraft.Team == CF.PlayerTeam and orbitedCraft:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
			-- Bring back actors
			for actor in orbitedCraft.Inventory do
				if actor.Team == CF.PlayerTeam and IsActor(actor) and ToActor(actor).Health > 0 then
					actor = ToActor(actor)
					local assignable = true
					local f = CF.GetPlayerFaction(self.GS, 0)

					-- Check if unit is playable
					if CF.UnassignableUnits[f] ~= nil then
						for i = 1, #CF.UnassignableUnits[f] do
							if actor.PresetName == CF.UnassignableUnits[f][i] then
								assignable = false
							end
						end
					end

					-- Don't bring back allied units
					if self:IsAlly(actor) then
						assignable = false
					end

					deployedactor = 1

					if
						assignable and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					then
						self.GS["Deployed" .. deployedactor .. "Preset"] = actor.PresetName
						self.GS["Deployed" .. deployedactor .. "Class"] = actor.ClassName
						self.GS["Deployed" .. deployedactor .. "Module"] = actor.ModuleName
						self.GS["Deployed" .. deployedactor .. "XP"] = actor:GetNumberValue("VW_XP")
						self.GS["Deployed" .. deployedactor .. "Identity"] = actor:GetNumberValue("Identity")
						self.GS["Deployed" .. deployedactor .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
						self.GS["Deployed" .. deployedactor .. "Prestige"] = actor:GetNumberValue("VW_Prestige")
						self.GS["Deployed" .. deployedactor .. "Name"] = actor:GetStringValue("VW_Name")
						self.GS["Deployed" .. deployedactor .. "InventoryPresets"] = pre
						self.GS["Deployed" .. deployedactor .. "InventoryClasses"] = cls
						self.GS["Deployed" .. deployedactor .. "InventoryModules"] = mdl
						for j = 1, #CF.LimbID do
							self.GS["Deployed" .. deployedactor .. CF.LimbID[j]] = CF.GetLimbData(actor, j)
						end

						for j = 1, #pre do
							self.GS["Deployed" .. deployedactor .. "Item" .. j .. "Preset"] = pre[j]
							self.GS["Deployed" .. deployedactor .. "Item" .. j .. "Class"] = cls[j]
							self.GS["Deployed" .. deployedactor .. "Item" .. j .. "Module"] = mdl[j]
						end
								
						deployedactor = deployedactor + 1
					end
				end
			end
			--Nullify the funds we just gained from the orbited craft
			self:SetTeamFunds(CF.GetPlayerGold(self.GS, CF.PlayerTeam), CF.PlayerTeam)
			FrameMan:ClearScreenText(0)
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyLZControlPanelUI()
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		-- Destroy actor
		if MovableMan:IsActor(self.LZControlPanelActor[player + 1]) then
			self.LZControlPanelActor[player + 1].ToDelete = true
		end
	end
	
	--self.LZControlPanelActor.ToDelete = true
	self.LZControlPanelActor = nil
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessLZControlPanelUI()
	if self.LZControlPanelActor == nil or self.ActivityState == Activity.OVER then
		return
	end

	-- Process bombing UI
	self:ProcessBombsControlPanelUI()

	-- And process bombing itself
	if self.BombingTarget ~= nil then
		if self.Time > self.BombingStart + self.BombingLoadTime + CF.BombFlightInterval then
			if self.Time > self.BombingLastBombShot + CF.BombInterval then
				self.BombingLastBombShot = self.Time

				self.BombsControlPanelInBombMode = true

				-- Launch bombs
				for i = 1, tonumber(self.GS["Player0VesselBombBays"]) do
					--print (self.BombPayload[self.BombingCount]["Preset"])
					--print (self.BombPayload[self.BombingCount]["Class"])

					local bombpos = Vector(
						self.BombingTarget - self.BombingRange / 2 + math.random(self.BombingRange),
						-40
					)

					local bomb = CF.MakeItem(
						self.BombPayload[self.BombingCount]["Preset"],
						self.BombPayload[self.BombingCount]["Class"],
						self.BombPayload[self.BombingCount]["Module"]
					)
					if bomb then
						bomb.Pos = bombpos
						MovableMan:AddItem(bomb)
					end

					-- Place special actor so the bombs can detect the fake dropship that drops them launches
					-- Fake dropship will delete itself after 250 ms
					local dropship = CreateACDropShip("Fake Drop Ship MK1", self.ModuleName)
					if dropship then
						dropship.Team = CF.PlayerTeam
						dropship.Pos = bombpos + Vector(0, -20)
						MovableMan:AddActor(dropship)
					else
						print("ERR: Dropship not created")
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
							if CF.DistUnder(actor.Pos, self.LastKnownBombingPosition, self.BombingRange * 1.5) then
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

	-- Re-create dead LZs
	local brainsAbsent = self.GS["BrainsOnMission"] == "False"
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		--print("PLAYER #" .. player .. ": " .. tostring(brainsAbsent and self:PlayerActive(player) and self:PlayerHuman(player)) .. " " .. tostring(not brainsAbsent and player == Activity.PLAYER_1))
		if (brainsAbsent and self:PlayerActive(player) and self:PlayerHuman(player)) or (not brainsAbsent and player == Activity.PLAYER_1) then
			if not MovableMan:IsActor(self.LZControlPanelActor[player + 1]) then
				self.LZControlPanelActor[player + 1] = CreateActor("LZ Control Panel")
				if self.LZControlPanelActor[player + 1] ~= nil then
					self.LZControlPanelActor[player + 1].Pos = self.LZControlPanelPos[player + 1]
					self.LZControlPanelActor[player + 1].Team = CF.PlayerTeam
					MovableMan:AddActor(self.LZControlPanelActor[player + 1])
					if brainsAbsent then
						self:SetPlayerBrain(self.LZControlPanelActor[player + 1], player)
						self:SwitchToActor(self.LZControlPanelActor[player + 1], player, CF.PlayerTeam)
					end
				end
			end
		end
	end

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self.LZControlPanelActor[player + 1] then
			if not self.LZControlPanelActor[player + 1]:GetController():IsPlayerControlled(Activity.PLAYER_NONE) then
				self:PutGlow("ControlPanel_LZ", self.LZControlPanelPos[player + 1])
			end
		end
	end
	
	local anypanelselected = false
	local safe = false
	local totalGoldCarried = 0

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player)

		if act and MovableMan:IsActor(act) and act.PresetName == "LZ Control Panel" then
			local cont = act:GetController()
			local pos = act.Pos
			local selectedpanel = 1
			anypanelselected = true

			if self.LZControlPanelActor[player + 1] and act.ID == self.LZControlPanelActor[player + 1].ID then
				selectedpanel = player + 1
			end

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
						elseif not self:IsAlly(actor) and actor.PresetName ~= "LZ Control Panel" then
							if self:IsInLZPanelProximity(actor.Pos) then
								safeUnits[#safeUnits + 1] = actor
							else
								unsafeUnits[#unsafeUnits + 1] = actor
								if actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
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
						and not self:IsAlly(ToActor(actor))
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
					safe = true
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
				if safe then
					self:PutGlow("ControlPanel_LZ_Button", pos)
					local storageCapacity = tonumber(self.GS["Player0VesselStorageCapacity"])
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
					self:PutGlow("ControlPanel_LZ_ButtonRed", pos)
					if #unsafeUnits > 0 then
						if brainUnsafe > 0 then
							CF.DrawString("CAN'T ABANDON BRAIN", pos + Vector(-54, 4), 130, 20)
						else
							CF.DrawString(
								"AND ABANDON " .. #unsafeUnits .. " UNIT" .. (#unsafeUnits > 1 and "S" or ""),
								pos + Vector(-54, 4),
								130,
								20
							)
						end
					end

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

				if cont:IsState(Controller.WEAPON_FIRE) then
					if self.ControlPanelLZPressTimes[player + 1] == nil then
						self.ControlPanelLZPressTimes[player + 1] = self.Time
					end
					if self.ControlPanelLZPressTimes[player + 1] + CF.TeamReturnDelay <= self.Time then
						self.ControlPanelLZPressTimes[player + 1] = self.Time - CF.TeamReturnDelay
					end
					CF.DrawString(
						"RETURN IN T-" .. tostring(self.ControlPanelLZPressTimes[player + 1] + CF.TeamReturnDelay - self.Time),
						pos + Vector(-30, -10),
						130,
						20
					)

					-- Return to ship
					if self.ControlPanelLZPressTimes[player + 1] + CF.TeamReturnDelay == self.Time and (brainUnsafe <= 0 or safe) then
						self.DeployedActors = {}

						local actors = {}
						-- Bring back actors
						for actor in MovableMan.Actors do
							if
								actor.Team == CF.PlayerTeam
								and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
								and actor.PresetName ~= "LZ Control Panel"
								and not self:IsAlly(actor)
								and (safe or self:IsInLZPanelProximity(actor.Pos))
							then
								table.insert(actors, actor)
							end
						end
						for actor in MovableMan:GetMOsInBox(self.lzBox, Activity.NOTEAM, true) do
							if
								actor.Team == CF.PlayerTeam
								and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
								and ToActor(actor):IsDead()
								and not self:IsAlly(ToActor(actor))
								and self:IsInLZPanelProximity(actor.Pos)
							then
								table.insert(actors, ToActor(actor))
							end
						end
						for _, actor in pairs(actors) do
							local assignable = true

							-- Check if unit is playable
							local f = CF.GetPlayerFaction(self.GS, 0)
							if CF.UnassignableUnits[f] ~= nil then
								for i = 1, #CF.UnassignableUnits[f] do
									if actor.PresetName == CF.UnassignableUnits[f][i] then
										assignable = false
									end
								end
							end

							if assignable then
								local pre, cls, mdl = CF.GetInventory(actor)
								-- These actors must be deployed
								local n = #self.DeployedActors + 1
								self.DeployedActors[n] = {}
								self.DeployedActors[n]["Preset"] = actor.PresetName
								self.DeployedActors[n]["Class"] = actor.ClassName
								self.DeployedActors[n]["Module"] = actor.ModuleName
								self.DeployedActors[n]["XP"] = actor:GetNumberValue("VW_XP")
								self.DeployedActors[n]["Identity"] = actor:GetNumberValue("Identity")
								self.DeployedActors[n]["Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
								self.DeployedActors[n]["Prestige"] = actor:GetNumberValue("VW_Prestige")
								self.DeployedActors[n]["Name"] = actor:GetStringValue("VW_Name")
								self.DeployedActors[n]["InventoryPresets"] = pre
								self.DeployedActors[n]["InventoryClasses"] = cls
								self.DeployedActors[n]["InventoryModules"] = mdl
								for j = 1, #CF.LimbID do
									self.DeployedActors[n][CF.LimbID[j]] = CF.GetLimbData(actor, j)
								end
								if actor.GoldCarried then
									totalGoldCarried = totalGoldCarried + actor.GoldCarried
								end
								--print (#pre)
							end
						end
					end
				else
					CF.DrawString("HOLD FIRE TO RETURN", pos + Vector(-50, -10), 130, 20)
					self.ControlPanelLZPressTimes[player + 1] = nil
				end

				if self.MissionStatus ~= nil then
					local l = CF.GetStringPixelWidth(self.MissionStatus)
					CF.DrawString(self.MissionStatus, pos + Vector(-l / 2, 16), 130, 25)
				end
			elseif self.BombsControlPanelSelectedModes[selectedpanel] == self.BombsControlPanelModes.BOMB then
				if not self.BombsControlPanelInBombMode then
					self.BombsControlPanelSelectedItem = 1

					self.Bombs = CF.GetBombsArray(self.GS)
					n = #self.Bombs + 1
					self.Bombs[n] = {}
					self.Bombs[n]["Preset"] = "Request orbital strike"
					self.Bombs[n]["Class"] = ""
					self.Bombs[n]["Count"] = 0

					self.BombPayload = {}
				end

				self.BombsControlPanelInBombMode = true

				if cont:IsState(Controller.PRESS_UP) then
					if self.BombsControlPanelSelectedItem > 1 then
						self.BombsControlPanelSelectedItem = self.BombsControlPanelSelectedItem - 1
					end
				end

				if cont:IsState(Controller.PRESS_DOWN) then
					if self.BombsControlPanelSelectedItem < #self.Bombs then
						self.BombsControlPanelSelectedItem = self.BombsControlPanelSelectedItem + 1
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

						if self.Bombs[self.BombsControlPanelSelectedItem] ~= nil then
							if
								self.Bombs[self.BombsControlPanelSelectedItem]["Preset"] == "Request orbital strike"
								and #self.BombPayload > 0
							then
								-- Start targeting
								self.BombsControlPanelSelectedModes[selectedpanel] = self.BombsControlPanelModes.RETURN
								self:InitBombsControlPanelUI()
								if MovableMan:IsActor(self.BombsControlPanelActor) then
									-- Remove orbital strike option from bombs array because bombing actor will commit changes made here
									self.Bombs[#self.Bombs] = nil

									--print (self.LastKnownBombingPosition)
									if self.LastKnownBombingPosition == nil then
										self.BombsControlPanelActor.Pos = Vector(pos.X, 0)
									else
										self.BombsControlPanelActor.Pos = self.LastKnownBombingPosition
									end

									self:SwitchToActor(self.BombsControlPanelActor, player, CF.PlayerTeam)
									return
								else
									print("ERROR: Bomb control actor not created!")
								end
							else
								-- Add bomb to payload
								if
									self.Bombs[self.BombsControlPanelSelectedItem]["Count"] > 0
									and #self.BombPayload
										< tonumber(self.GS["Player0VesselBombBays"]) * CF.BombsPerBay
								then
									self.Bombs[self.BombsControlPanelSelectedItem]["Count"] = self.Bombs[self.BombsControlPanelSelectedItem]["Count"]
										- 1

									local n = #self.BombPayload + 1
									self.BombPayload[n] = {}
									self.BombPayload[n]["Preset"] =
										self.Bombs[self.BombsControlPanelSelectedItem]["Preset"]
									self.BombPayload[n]["Class"] =
										self.Bombs[self.BombsControlPanelSelectedItem]["Class"]
									self.BombPayload[n]["Module"] =
										self.Bombs[self.BombsControlPanelSelectedItem]["Module"]
								end
							end
						end
					end
				else
					self.FirePressed[player] = false
				end

				self.BombControlPanelListStart = self.BombsControlPanelSelectedItem
					- (self.BombsControlPanelSelectedItem - 1) % self.BombsControlPanelItemsPerPage

				self:PutGlow("ControlPanel_LZ_Button", pos)

				CF.DrawString("PAYLOAD: ", pos + Vector(-40, -8) + Vector(0, -10), 120, 10)
				CF.DrawString(
					tostring(#self.BombPayload) .. " / " .. self.GS["Player0VesselBombBays"] * CF.BombsPerBay,
					pos + Vector(20, -8) + Vector(0, -10),
					120,
					10
				)

				-- Draw list
				for i = self.BombControlPanelListStart, self.BombControlPanelListStart + self.BombsControlPanelItemsPerPage - 1 do
					if i <= #self.Bombs and i > 0 then
						local loc = i - self.BombControlPanelListStart

						if i == self.BombsControlPanelSelectedItem then
							CF.DrawString(
								"> " .. self.Bombs[i]["Preset"],
								pos + Vector(-60, -8) + Vector(0, loc * 12),
								130,
								10
							)
						else
							CF.DrawString(self.Bombs[i]["Preset"], pos + Vector(-60, -8) + Vector(0, loc * 12), 130, 10)
						end
						if self.Bombs[i]["Preset"] ~= "Request orbital strike" then
							CF.DrawString(
								tostring(self.Bombs[i]["Count"]),
								pos + Vector(56, -8) + Vector(0, loc * 12),
								120,
								10
							)
						end
					end
				end
			end
		end
	end

	-- Reset panel states when they are not selected
	if not anypanelselected and self.BombsControlPanelActor == nil then
		self.BombsControlPanelInBombMode = false

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			self.BombsControlPanelSelectedModes[player + 1] = self.BombsControlPanelModes.RETURN
		end
	end

	if self.DeployedActors then
		if self.MissionAvailable and not self.MissionCompleted then
			self:GiveMissionPenalties()
		end

		if self.MissionAvailable then
			-- Generate new missions
			CF.GenerateRandomMissions(self.GS)
		end

		-- Update casualties report
		if self.MissionDeployedTroops > #self.DeployedActors then
			local s = ""
			local a = ""
			if self.MissionDeployedTroops - #self.DeployedActors > 1 then
				s = "S"
				a = "ALL "
			end

			if #self.DeployedActors == 0 then
				self.MissionReport[#self.MissionReport + 1] = a .. "UNIT" .. s .. " LOST"
			else
				self.MissionReport[#self.MissionReport + 1] = tostring(
					self.MissionDeployedTroops - #self.DeployedActors
				) .. " UNIT" .. s .. " LOST"
			end
		else
			self.MissionReport[#self.MissionReport + 1] = "NO CASUALTIES"
		end

		-- Collect items
		if safe then
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
				if CF.CountUsedStorageInArray(storage) < tonumber(self.GS["Player0VesselStorageCapacity"]) then
					CF.PutItemToStorageArray(storage, item.PresetName, item.ClassName, item.ModuleName)
				else
					break
				end
			end

			CF.SetStorageArray(self.GS, storage)

			if #items > 0 then
				self.MissionReport[#self.MissionReport + 1] = tostring(#items)
					.. " item"
					.. (#items > 1 and "s" or "")
					.. " collected"
			end
		end
		if totalGoldCarried > 0 then
			self.MissionReport[#self.MissionReport + 1] = totalGoldCarried .. " oz of gold collected"
			CF.SetPlayerGold(self.GS, 0, CF.GetPlayerGold(self.GS, 0) + totalGoldCarried)
		end

		-- Save fog of war
		if self.GS["FogOfWar"] and self.GS["FogOfWar"] == "true" then
			self:SaveFogOfWarState(self.GS)
		end

		-- Dump mission report to config to be saved
		CF.SaveMissionReport(self.GS, self.MissionReport)

		local scene = CF.VesselScene[self.GS["Player0Vessel"]]
		-- Set new operating mode
		self.GS["Mode"] = "Vessel"
		self.GS["SceneType"] = "Vessel"
		self.GS["Scene"] = scene
		
		self:SaveCurrentGameState()

		self:LaunchScript(scene, "Tactics.lua")
		self.EnableBrainSelection = false
		self:DestroyLZControlPanelUI()

		-- Destroy mission and ambient specific objects
		if self.AmbientDestroy ~= nil then
			self:AmbientDestroy()
		end

		if self.MissionDestroy ~= nil then
			self:MissionDestroy()
		end

		-- Clean everything
		self.MissionCreate = nil
		self.MissionUpdate = nil
		self.MissionDestroy = nil

		self.AmbientCreate = nil
		self.AmbientUpdate = nil
		self.AmbientDestroy = nil

		print(collectgarbage('count'))
		collectgarbage("collect")
		print(collectgarbage('count'))
		return
	end
end
