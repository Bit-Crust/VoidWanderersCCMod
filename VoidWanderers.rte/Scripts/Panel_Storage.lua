-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitStorageControlPanelUI()
	-- Storage Control Panel
	local x, y

	x = tonumber(self.LS["StorageControlPanelX"])
	y = tonumber(self.LS["StorageControlPanelY"])
	if x ~= nil and y ~= nil then
		self.StorageControlPanelPos = Vector(x, y)
	else
		self.StorageControlPanelPos = nil
	end

	x = tonumber(self.LS["StorageInputX"])
	y = tonumber(self.LS["StorageInputY"])
	if x ~= nil and y ~= nil then
		self.StorageInputPos = Vector(x, y)
	else
		self.StorageInputPos = nil
	end
	--[[
	x = tonumber(self.LS["StorageDeployX"])
	y = tonumber(self.LS["StorageDeployY"])
	if x~= nil and y ~= nil then
		self.StorageDeployPos = Vector(x,y)
	else
		self.StorageDeployPos = nil
	end
	]]
	--
	-- Create actor
	if self.StorageControlPanelPos ~= nil then
		if not MovableMan:IsActor(self.StorageControlPanelActor) then
			self.StorageControlPanelActor = CreateActor("Storage Control Panel")
			if self.StorageControlPanelActor ~= nil then
				self.StorageControlPanelActor.Pos = self.StorageControlPanelPos
				self.StorageControlPanelActor.Team = CF_PlayerTeam
				MovableMan:AddActor(self.StorageControlPanelActor)
			end
		end

		-- Crate debug
		--[[local crt = CreateMOSRotating("Case", self.ModuleName)
		if crt then
			crt.Pos = self.StorageControlPanelPos
			MovableMan:AddParticle(crt)
		end

		local crt = CreateMOSRotating("Crate", self.ModuleName)
		if crt then
			crt.Pos = self.StorageControlPanelPos + Vector(30,0)
			MovableMan:AddParticle(crt)
		end

		--]]
		--
	end

	self.StorageControlPanelItemsPerPage = 9

	self.StorageInputRange = 50
	self.StorageInputDelay = 3

	-- Init variables
	self.StorageControlPanelModes = {
		SELL = -3,
		UNKNOWN = -2,
		EVERYTHING = -1,
		PISTOL = 0,
		RIFLE = 1,
		SHOTGUN = 2,
		SNIPER = 3,
		HEAVY = 4,
		SHIELD = 5,
		DIGGER = 6,
		GRENADE = 7,
		TOOL = 8,
	}
	self.StorageControlPanelModesTexts = {}

	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.SELL] = "SELL ITEMS"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.UNKNOWN] = "Unknown items"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.EVERYTHING] = "All items"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.PISTOL] = "Secondary"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.RIFLE] = "Primary"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.SHOTGUN] = "Shotguns"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.SNIPER] = "Sniper rifles"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.HEAVY] = "Heavy weapons"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.SHIELD] = "Shields"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.DIGGER] = "Tools - Diggers"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.GRENADE] = "Explosives"
	self.StorageControlPanelModesTexts[self.StorageControlPanelModes.TOOL] = "Tools"

	self.StorageControlMode = self.StorageControlPanelModes.EVERYTHING

	self.StorageItems, self.StorageFilters = CF_GetStorageArray(self.GS, true)
	self.Bombs = CF_GetBombsArray(self.GS)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyStorageControlPanelUI()
	if self.StorageControlPanelActor ~= nil then
		self.StorageControlPanelActor.ToDelete = true
		self.StorageControlPanelActor = nil
	end

	if self.StorageControlPanelObject then
		self.StorageControlPanelObject = nil
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessStorageControlPanelUI()
	local showidle = true

	for plr = 0, self.PlayerCount - 1 do
		local act = self:GetControlledActor(plr)

		if act and MovableMan:IsActor(act) and act.PresetName == "Storage Control Panel" then
			showidle = false

			self.LastStorageSelectedItem = self.StorageSelectedItem

			-- Init control panel
			if not self.StorageControlPanelInitialized then
				self.StorageSelectedItem = 1
				self.LastStorageSelectedItem = 0
				self.StorageControlPanelInitialized = true
			end

			-- Draw generic UI
			local pos = act.Pos
			if self.StorageControlMode ~= self.StorageControlPanelModes.SELL then
				self:PutGlow("ControlPanel_Storage_List", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Storage_Description", pos + Vector(90, 0))
				self:PutGlow("ControlPanel_Storage_HorizontalPanel", pos + Vector(20, -77))
				self:PutGlow("ControlPanel_Storage_HorizontalPanel", pos + Vector(20, 78))

				-- Print help text
				CF_DrawString("L/R - Change filter, U/D - Select, FIRE - Dispense", pos + Vector(-130, 78), 300, 10)
			else
				self:PutGlow("ControlPanel_Storage_ListRed", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Storage_DescriptionRed", pos + Vector(90, 0))
				self:PutGlow("ControlPanel_Storage_HorizontalPanelRed", pos + Vector(20, -77))
				self:PutGlow("ControlPanel_Storage_HorizontalPanelRed", pos + Vector(20, 78))

				self.StorageControlPanelModesTexts[self.StorageControlPanelModes.SELL] = "DUMP ITEMS"

				if
					CF_IsLocationHasAttribute(self.GS["Location"], CF_LocationAttributeTypes.TRADESTAR)
					or CF_IsLocationHasAttribute(self.GS["Location"], CF_LocationAttributeTypes.BLACKMARKET)
				then
					self.StorageControlPanelModesTexts[self.StorageControlPanelModes.SELL] = "SELL ITEMS Gold: "
						.. CF_GetPlayerGold(self.GS, 0)
						.. "oz"
					CF_DrawString("L/R - Change filter, U/D - Select, FIRE - Sell", pos + Vector(-130, 78), 300, 10)
				else
					CF_DrawString("L/R - Change filter, U/D - Select, FIRE - Dump", pos + Vector(-130, 78), 300, 10)
				end
			end

			-- Bacause StorageFilters my change outside of this panel by other players always check for out-of-bounds
			if
				self.StorageSelectedItem > #self.StorageFilters[self.StorageControlMode]
				and #self.StorageFilters[self.StorageControlMode] > 0
			then
				self.StorageSelectedItem = #self.StorageFilters[self.StorageControlMode]
			end

			-- Process controls
			local cont = act:GetController()
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

			if self.HoldTimer:IsPastSimMS(CF_KeyRepeatDelay) then
				self.HoldTimer:Reset()

				if cont:IsState(Controller.HOLD_UP) then
					up = true
				end

				if cont:IsState(Controller.HOLD_DOWN) then
					down = true
				end
			end

			if up then
				if #self.StorageFilters[self.StorageControlMode] > 0 then
					self.StorageSelectedItem = self.StorageSelectedItem - 1

					if self.StorageSelectedItem < 1 then
						self.StorageSelectedItem = #self.StorageFilters[self.StorageControlMode]
					end
				end
			end

			if down then
				if #self.StorageFilters[self.StorageControlMode] > 0 then
					self.StorageSelectedItem = self.StorageSelectedItem + 1

					if self.StorageSelectedItem > #self.StorageFilters[self.StorageControlMode] then
						self.StorageSelectedItem = 1
					end
				end
			end

			if cont:IsState(Controller.PRESS_LEFT) then
				self.StorageControlMode = self.StorageControlMode - 1
				self.StorageSelectedItem = 1
				self.LastStorageSelectedItem = 0

				if self.StorageControlMode == -4 then
					self.StorageControlMode = self.StorageControlPanelModes.TOOL
				end
			end

			if cont:IsState(Controller.PRESS_RIGHT) then
				self.StorageControlMode = self.StorageControlMode + 1
				self.StorageSelectedItem = 1
				self.LastStorageSelectedItem = 0

				if self.StorageControlMode == 9 then
					self.StorageControlMode = self.StorageControlPanelModes.SELL
				end
			end

			self.StorageControlItemsListStart = self.StorageSelectedItem
				- (self.StorageSelectedItem - 1) % self.StorageControlPanelItemsPerPage

			local refreshsample = false

			-- Check if sample object is the one we're currently selecting
			if self.StorageControlPanelObject then
				local itm = self.StorageFilters[self.StorageControlMode][self.StorageSelectedItem]

				if
					itm ~= nil
					and (
						self.StorageControlPanelObject.PresetName ~= self.StorageItems[itm]["Preset"]
						or self.StorageControlPanelObject.ClassName ~= self.StorageItems[itm]["Class"]
					)
				then
					refreshsample = true
				end
			end

			-- Get selected item info
			if self.StorageSelectedItem ~= self.LastStorageSelectedItem or refreshsample then
				local itm = self.StorageFilters[self.StorageControlMode][self.StorageSelectedItem]

				-- Delete old item object
				if self.StorageControlPanelObject then
					self.StorageControlPanelObject = nil
				end

				if itm ~= nil then
					-- Get item description
					local f, i = CF_FindItemInFactions(
						self.StorageItems[itm]["Preset"],
						self.StorageItems[itm]["Class"]
					)

					local sellCoeff = CF_IsLocationHasAttribute(
						self.GS["Location"],
						CF_LocationAttributeTypes.BLACKMARKET
					) and math.sqrt(CF_SellPriceCoeff) or CF_SellPriceCoeff

					if f and i then
						self.StorageSelectedItemDescription = CF_ItmDescriptions[f][i]
						self.StorageSelectedItemManufacturer = CF_FactionNames[f]
						self.StorageSelectedItemPrice = math.floor(CF_ItmPrices[f][i] * sellCoeff)
					else
						self.StorageSelectedItemDescription = "Unknown item"
						self.StorageSelectedItemManufacturer = "Unknown"
						self.StorageSelectedItemPrice = math.floor(CF_UnknownItemPrice * sellCoeff)
					end

					-- Create new item object
					self.StorageControlPanelObject = CF_MakeItem(
						self.StorageItems[itm]["Preset"],
						self.StorageItems[itm]["Class"],
						self.StorageItems[itm]["Module"]
					)
					if self.StorageControlPanelObject then
						self.StorageControlPanelObject.HitsMOs = false
						self.StorageControlPanelObject.GetsHitByMOs = false
					end
				else
					self.StorageSelectedItemDescription = ""
					self.StorageSelectedItemManufacturer = ""
					self.StorageSelectedItemPrice = nil
				end
			end

			-- Dispense/sell/dump items
			if cont:IsState(Controller.WEAPON_FIRE) then
				if not self.FirePressed[plr] then
					self.FirePressed[plr] = true

					if self.StorageSelectedItem > 0 then
						local itm = self.StorageFilters[self.StorageControlMode][self.StorageSelectedItem]

						if self.StorageItems[itm]["Count"] > 0 then
							-- Remove item from storage and spawn it
							self.StorageItems[itm]["Count"] = self.StorageItems[itm]["Count"] - 1

							if self.StorageControlMode ~= self.StorageControlPanelModes.SELL then
								local foundActor = nil

								-- Try to find actor or put item as is otherwise
								for actor in MovableMan.Actors do
									if
										CF_DistUnder(actor.Pos, self.StorageInputPos, self.StorageInputRange)
										and actor.ClassName == "AHuman"
									then
										foundActor = actor
										break
									end
								end

								local item = CF_MakeItem(
									self.StorageItems[itm]["Preset"],
									self.StorageItems[itm]["Class"],
									self.StorageItems[itm]["Module"]
								)
								if item ~= nil then
									if foundActor then
										foundActor:AddInventoryItem(item)
										foundActor:FlashWhite(100)
									else
										item.Pos = self.StorageInputPos
										MovableMan:AddItem(item)
									end
								end
							else
								if
									CF_IsLocationHasAttribute(self.GS["Location"], CF_LocationAttributeTypes.TRADESTAR)
									or CF_IsLocationHasAttribute(
										self.GS["Location"],
										CF_LocationAttributeTypes.BLACKMARKET
									)
								then
									if self.StorageSelectedItemPrice ~= nil then
										CF_SetPlayerGold(
											self.GS,
											0,
											CF_GetPlayerGold(self.GS, 0) + self.StorageSelectedItemPrice
										)
									end
								end
							end
							-- Update game state
							CF_SetStorageArray(self.GS, self.StorageItems)

							-- Refresh storage array and filters
							if self.StorageItems[itm]["Count"] == 0 then
								self.StorageItems, self.StorageFilters = CF_GetStorageArray(self.GS, true)
							end
						end
					end
				end
			else
				self.FirePressed[plr] = false
			end

			-- Draw items list
			for i = self.StorageControlItemsListStart, self.StorageControlItemsListStart + self.StorageControlPanelItemsPerPage - 1 do
				if i <= #self.StorageFilters[self.StorageControlMode] then
					local itm = self.StorageFilters[self.StorageControlMode][i]
					local loc = i - self.StorageControlItemsListStart

					if i == self.StorageSelectedItem then
						CF_DrawString(
							"> " .. self.StorageItems[itm]["Preset"],
							pos + Vector(-130, -40) + Vector(0, loc * 12),
							90,
							10
						)
					else
						CF_DrawString(
							self.StorageItems[itm]["Preset"],
							pos + Vector(-130, -40) + Vector(0, loc * 12),
							90,
							10
						)
					end
					CF_DrawString(
						tostring(self.StorageItems[itm]["Count"]),
						pos + Vector(-130, -40) + Vector(110, loc * 12),
						90,
						10
					)
				end
			end

			-- Draw item object
			if self.StorageControlPanelObject then
				local drawPos = pos + Vector(85, -45)
				--[[ Draw attachables?
				local drawnBefore, drawnAfter = {}, {}
				for att in self.StorageControlPanelObject.Attachables do
					if att.DrawnAfterParent then
						table.insert(drawnAfter, att)
					else
						table.insert(drawnBefore, att)
					end
				end
				for i = 1, #drawnBefore do
					PrimitiveMan:DrawBitmapPrimitive(drawPos + drawnBefore[i].ParentOffset - drawnBefore[i].JointOffset, drawnBefore[i], 0, 0)
				end]]
				--
				PrimitiveMan:DrawBitmapPrimitive(drawPos, self.StorageControlPanelObject, 0, 0)
				--[[
				for i = 1, #drawnAfter do
					PrimitiveMan:DrawBitmapPrimitive(drawPos + drawnAfter[i].ParentOffset - drawnAfter[i].JointOffset, drawnAfter[i], 0, 0)
				end]]
				--
			end

			-- Print description
			if self.StorageSelectedItemDescription ~= nil then
				CF_DrawString(self.StorageSelectedItemDescription, pos + Vector(10, -10), 170, 70)
			end

			-- Print manufacturer or price
			if self.StorageControlMode ~= self.StorageControlPanelModes.SELL then
				if self.StorageSelectedItemManufacturer ~= nil and self.StorageSelectedItemManufacturer ~= "" then
					CF_DrawString(
						"Manufacturer: " .. self.StorageSelectedItemManufacturer,
						pos + Vector(10, -25),
						170,
						120
					)
				end
			else
				if
					CF_IsLocationHasAttribute(self.GS["Location"], CF_LocationAttributeTypes.TRADESTAR)
					or CF_IsLocationHasAttribute(self.GS["Location"], CF_LocationAttributeTypes.BLACKMARKET)
				then
					if self.StorageSelectedItemPrice ~= nil then
						CF_DrawString(
							"Sell price: " .. self.StorageSelectedItemPrice .. " oz",
							pos + Vector(10, -25),
							170,
							120
						)
					end
				end
			end

			-- Print Selected mode text
			CF_DrawString(self.StorageControlPanelModesTexts[self.StorageControlMode], pos + Vector(-130, -77), 170, 10)

			-- Print storage capacity
			CF_DrawString(
				"Capacity: "
					.. CF_CountUsedStorageInArray(self.StorageItems)
					.. "/"
					.. self.GS["Player0VesselStorageCapacity"],
				pos + Vector(-130, -60),
				300,
				10
			)
		end
	end

	if showidle and self.StorageControlPanelPos ~= nil and self.StorageControlPanelActor ~= nil then
		self:PutGlow("ControlPanel_Storage", self.StorageControlPanelPos)
		--CF_DrawString("STORAGE",self.StorageControlPanelPos + Vector(-16,0), 120, 20)

		self.StorageControlPanelInitialized = false

		-- Delete sample weapon
		if self.StorageControlPanelObject then
			self.StorageControlPanelObject = nil
		end
	end

	-- Process weapons input
	if self.StorageInputPos ~= nil and self.StorageControlPanelActor ~= nil then
		local count = CF_CountUsedStorageInArray(self.StorageItems)

		if count < tonumber(self.GS["Player0VesselStorageCapacity"]) then
			local hasitem = false
			local toreset = true

			-- Search for item and put it in storage
			for item in MovableMan.Items do
				if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
					item = ToHeldDevice(item)
					local activated = false
					if IsHDFirearm(item) then
						activated = ToHDFirearm(item):IsActivated()
					elseif IsTDExplosive(item) then
						activated = ToTDExplosive(item):IsActivated()
					end
					--if CF_Dist(item.Pos, self.StorageInputPos) <= self.StorageInputRange then
					if self.Ship:IsInside(item.Pos) and not activated then
						toreset = false

						-- Debug
						--self:AddObjectivePoint("X", item.Pos , CF_PlayerTeam, GameActivity.ARROWDOWN);

						if self.StorageLastDetectedItemTime ~= nil then
							self:AddObjectivePoint(
								"Store in " .. self.StorageLastDetectedItemTime + self.StorageInputDelay - self.Time,
								item.Pos + Vector(0, -40),
								CF_PlayerTeam,
								GameActivity.ARROWDOWN
							)

							-- Put item to storage
							if
								self.Time >= self.StorageLastDetectedItemTime + self.StorageInputDelay
								and CF_CountUsedStorageInArray(self.StorageItems)
									< tonumber(self.GS["Player0VesselStorageCapacity"])
							then
								local needrefresh = CF_PutItemToStorageArray(
									self.StorageItems,
									item.PresetName,
									item.ClassName,
									item.ModuleName
								)

								item.ToDelete = true

								-- Store everything
								CF_SetStorageArray(self.GS, self.StorageItems)

								-- Refresh storage items array and filters
								if needrefresh then
									self.StorageItems, self.StorageFilters = CF_GetStorageArray(self.GS, true)
								end

								self.StorageLastDetectedItemTime = nil
							end

							hasitem = true
							break
						else
							self.StorageLastDetectedItemTime = self.Time
						end
					end
				end
			end

			if toreset then
				self.StorageLastDetectedItemTime = nil
			end

			if showidle then
				if hasitem and self.StorageLastDetectedItemTime ~= nil then
				else
					self:AddObjectivePoint(
						"Stand here to receive items\n" .. count .. " / " .. self.GS["Player0VesselStorageCapacity"],
						self.StorageInputPos,
						CF_PlayerTeam,
						GameActivity.ARROWDOWN
					)
				end
			end
		else
			self:AddObjectivePoint(
				"Storage is full",
				self.StorageInputPos + Vector(0, -40),
				CF_PlayerTeam,
				GameActivity.ARROWUP
			)
			self.StorageLastDetectedItemTime = nil
		end
	end

	if MovableMan:IsActor(self.StorageControlPanelActor) then
		self.StorageControlPanelActor.Health = 100
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
