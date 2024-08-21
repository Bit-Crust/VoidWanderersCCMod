-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitItemShopControlPanelUI()
	-- ItemShop Control Panel
	local x, y

	x = tonumber(self.SceneConfig["ItemShopControlPanelX"])
	y = tonumber(self.SceneConfig["ItemShopControlPanelY"])
	if x ~= nil and y ~= nil then
		self.ItemShopControlPanelPos = Vector(x, y)
	else
		self.ItemShopControlPanelPos = nil
	end

	-- Create actor
	if self.ItemShopControlPanelPos ~= nil then
		if not MovableMan:IsActor(self.ItemShopControlPanelActor) then
			self.ItemShopControlPanelActor = CreateActor("Item Shop Control Panel")
			if self.ItemShopControlPanelActor ~= nil then
				self.ItemShopControlPanelActor.Pos = self.ItemShopControlPanelPos
				self.ItemShopControlPanelActor.Team = CF["PlayerTeam"]
				MovableMan:AddActor(self.ItemShopControlPanelActor)
			end
		end
	end

	self.ItemShopControlPanelItemsPerPage = 8

	-- Init variables
	self.ItemShopControlPanelModes = {
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
		BOMB = 9,
	}
	self.ItemShopControlPanelModesTexts = {}
	
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.EVERYTHING] = "All items"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.PISTOL] = "Secondary"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.RIFLE] = "Primary"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.SHOTGUN] = "Shotguns"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.SNIPER] = "Sniper rifles"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.HEAVY] = "Heavy weapons"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.SHIELD] = "Shields"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.DIGGER] = "Tools - Diggers"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.GRENADE] = "Explosives"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.TOOL] = "Tools"
	self.ItemShopControlPanelModesTexts[self.ItemShopControlPanelModes.BOMB] = "Bombs"

	self.ItemShopControlMode = self.ItemShopControlPanelModes.EVERYTHING

	self.ItemShopTradeStar = false
	self.ItemShopBlackMarket = false

	if CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].TRADESTAR) then
		self.ItemShopItems, self.ItemShopFilters = CF["GetItemShopArray"](self.GS, true)
		self.ItemShopTradeStar = true
	end

	if CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].BLACKMARKET) then
		self.ItemShopItems, self.ItemShopFilters = CF["GetItemBlackMarketArray"](self.GS, true)
		self.ItemShopBlackMarket = true
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyItemShopControlPanelUI()
	if self.ItemShopControlPanelActor ~= nil then
		self.ItemShopControlPanelActor.ToDelete = true
		self.ItemShopControlPanelActor = nil
	end

	if self.ItemShopControlPanelObject then
		self.ItemShopControlPanelObject = nil
	end
	--print (self.ItemShopControlPanelActor)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessItemShopControlPanelUI()
	local showidle = true

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player)

		if act and MovableMan:IsActor(act) and act.PresetName == "Item Shop Control Panel" then
			showidle = false

			self.LastItemShopSelectedItem = self.ItemShopSelectedItem

			-- Init control panel
			if not self.ItemShopControlPanelInitialized then
				self.ItemShopSelectedItem = 1
				self.LastItemShopSelectedItem = 0
				self.ItemShopControlPanelInitialized = true
			end

			-- Draw generic UI
			local pos = act.Pos
			self:PutGlow("ControlPanel_Storage_List", pos + Vector(-71, 0))
			if self.ItemShopTradeStar then
				self:PutGlow("ControlPanel_ItemShop_Description", pos + Vector(90, 0))
			end
			if self.ItemShopBlackMarket then
				self:PutGlow("ControlPanel_ItemBlackMarket_Description", pos + Vector(90, 0))
			end
			self:PutGlow("ControlPanel_Storage_HorizontalPanel", pos + Vector(20, -77))
			self:PutGlow("ControlPanel_Storage_HorizontalPanel", pos + Vector(20, 78))

			-- Print help text
			CF["DrawString"]("L/R - Change filter, U/D - Select, FIRE - Buy", pos + Vector(-130, 78), 300, 10)

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

			if self.HoldTimer:IsPastSimMS(CF["KeyRepeatDelay"]) then
				self.HoldTimer:Reset()

				if cont:IsState(Controller.HOLD_UP) then
					up = true
				end

				if cont:IsState(Controller.HOLD_DOWN) then
					down = true
				end
			end

			if up then
				if #self.ItemShopFilters[self.ItemShopControlMode] > 0 then
					self.ItemShopSelectedItem = self.ItemShopSelectedItem - 1

					if self.ItemShopSelectedItem < 1 then
						self.ItemShopSelectedItem = #self.ItemShopFilters[self.ItemShopControlMode]
					end
				end
			end

			if down then
				if #self.ItemShopFilters[self.ItemShopControlMode] > 0 then
					self.ItemShopSelectedItem = self.ItemShopSelectedItem + 1

					if self.ItemShopSelectedItem > #self.ItemShopFilters[self.ItemShopControlMode] then
						self.ItemShopSelectedItem = 1
					end
				end
			end

			if cont:IsState(Controller.PRESS_LEFT) then
				self.ItemShopControlMode = self.ItemShopControlMode - 1
				self.ItemShopSelectedItem = 1
				self.LastItemShopSelectedItem = 0

				if self.ItemShopControlMode == -2 then
					self.ItemShopControlMode = self.ItemShopControlPanelModes.BOMB

					if self.ItemShopBlackMarket then
						self.ItemShopControlMode = self.ItemShopControlPanelModes.TOOL
					end
				end
			end

			if cont:IsState(Controller.PRESS_RIGHT) then
				self.ItemShopControlMode = self.ItemShopControlMode + 1
				self.ItemShopSelectedItem = 1
				self.LastItemShopSelectedItem = 0

				if self.ItemShopBlackMarket then
					if self.ItemShopControlMode == 9 then
						self.ItemShopControlMode = self.ItemShopControlPanelModes.EVERYTHING
					end
				else
					if self.ItemShopControlMode == 10 then
						self.ItemShopControlMode = self.ItemShopControlPanelModes.EVERYTHING
					end
				end
			end

			self.ItemShopControlItemsListStart = self.ItemShopSelectedItem
				- (self.ItemShopSelectedItem - 1) % self.ItemShopControlPanelItemsPerPage

			-- Get selected item info
			if self.ItemShopSelectedItem ~= self.LastItemShopSelectedItem then
				local itm = self.ItemShopFilters[self.ItemShopControlMode][self.ItemShopSelectedItem]

				-- Delete old item object
				if self.ItemShopControlPanelObject then
					self.ItemShopControlPanelObject = nil
				end

				if itm ~= nil then
					-- Get item description
					self.ItemShopSelectedItemDescription = self.ItemShopItems[itm]["Description"]
					self.ItemShopSelectedItemManufacturer = CF["FactionNames"][self.ItemShopItems[itm]["Faction"]]
					self.ItemShopSelectedItemPrice = self.ItemShopItems[itm]["Price"]
					self.ItemShopSelectedItemType = self.ItemShopItems[itm]["Type"]

					-- Create new item object
					if self.ItemShopItems[itm]["Preset"] then
						self.ItemShopControlPanelObject = CF["MakeItem"](
							self.ItemShopItems[itm]["Preset"],
							self.ItemShopItems[itm]["Class"],
							self.ItemShopItems[itm]["Module"]
						)
						if self.ItemShopControlPanelObject then
							self.ItemShopControlPanelObject.HitsMOs = false
							self.ItemShopControlPanelObject.GetsHitByMOs = false
						end
					end
				else
					self.ItemShopSelectedItemDescription = ""
					self.ItemShopSelectedItemManufacturer = ""
					self.ItemShopSelectedItemPrice = nil
					self.ItemShopSelectedItemType = nil
				end
			end

			-- Dispense/sell/dump items
			if cont:IsState(Controller.WEAPON_FIRE) then
				if not self.FirePressed[player] then
					self.FirePressed[player] = true

					if self.ItemShopSelectedItem > 0 then
						local itm = self.ItemShopFilters[self.ItemShopControlMode][self.ItemShopSelectedItem]

						if itm ~= nil then
							if self.ItemShopItems[itm]["Type"] == CF["WeaponTypes"].BOMB then
								if
									CF["CountUsedBombsInArray"](self.Bombs)
										< tonumber(self.GS["Player0VesselBombStorage"])
									and self.ItemShopSelectedItemPrice <= CF["GetPlayerGold"](self.GS, 0)
								then
									CF["PutBombToStorageArray"](
										self.Bombs,
										self.ItemShopItems[itm]["Preset"],
										self.ItemShopItems[itm]["Class"],
										self.ItemShopItems[itm]["Module"]
									)
									CF["SetBombsArray"](self.GS, self.Bombs)
									CF["SetPlayerGold"](
										self.GS,
										0,
										CF["GetPlayerGold"](self.GS, 0) - self.ItemShopSelectedItemPrice
									)
								end
							else
								if
									self.ItemShopItems[itm]["Preset"]
									and CF["CountUsedStorageInArray"](self.StorageItems) < tonumber(
										self.GS["Player0VesselStorageCapacity"]
									)
									and self.ItemShopSelectedItemPrice <= CF["GetPlayerGold"](self.GS, 0)
								then
									local needrefresh = CF["PutItemToStorageArray"](
										self.StorageItems,
										self.ItemShopItems[itm]["Preset"],
										self.ItemShopItems[itm]["Class"],
										self.ItemShopItems[itm]["Module"]
									)

									CF["SetPlayerGold"](
										self.GS,
										0,
										CF["GetPlayerGold"](self.GS, 0) - self.ItemShopSelectedItemPrice
									)

									-- Store everything
									CF["SetStorageArray"](self.GS, self.StorageItems)

									-- Refresh storage items array and filters
									if needrefresh then
										self.StorageItems, self.StorageFilters = CF["GetStorageArray"](self.GS, true)
									end
								end
							end
						end
					end
				end
			else
				self.FirePressed[player] = false
			end
			-- Draw items list
			for i = self.ItemShopControlItemsListStart, self.ItemShopControlItemsListStart + self.ItemShopControlPanelItemsPerPage - 1 do
				if i <= #self.ItemShopFilters[self.ItemShopControlMode] then
					local itm = self.ItemShopFilters[self.ItemShopControlMode][i]
					local loc = i - self.ItemShopControlItemsListStart

					CF["DrawString"](
						(i == self.ItemShopSelectedItem and "> " or "")
							.. (self.ItemShopItems[itm]["Preset"] or "SHIPPING ERROR"),
						pos + Vector(-130, -26) + Vector(0, loc * 12),
						90,
						10
					)
					local priceString = tostring(self.ItemShopItems[itm]["Price"])
					if self.ItemShopItems[itm]["Price"] >= 1000 then
						if self.ItemShopItems[itm]["Price"] >= 10000 then
							priceString = tostring(math.floor(self.ItemShopItems[itm]["Price"] * 0.001)) .. "k"
						else
							priceString = tostring(math.floor(self.ItemShopItems[itm]["Price"] * 0.01) * 0.1) .. "k"
						end
					end
					CF["DrawString"](priceString, pos + Vector(-130, -26) + Vector(110, loc * 12), 90, 10)
				end
			end

			-- Draw item object
			if self.ItemShopControlPanelObject then
				local drawPos = pos + Vector(85, -45)
				--[[ Draw attachables?
				local drawnBefore, drawnAfter = {}, {}
				for att in self.ItemShopControlPanelObject.Attachables do
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
				PrimitiveMan:DrawBitmapPrimitive(drawPos, self.ItemShopControlPanelObject, 0, 0)
				--[[
				for i = 1, #drawnAfter do
					PrimitiveMan:DrawBitmapPrimitive(drawPos + drawnAfter[i].ParentOffset - drawnAfter[i].JointOffset, drawnAfter[i], 0, 0)
				end]]
				--
			end

			-- Print description
			if self.ItemShopSelectedItemDescription ~= nil then
				CF["DrawString"](self.ItemShopSelectedItemDescription, pos + Vector(10, -10), 170, 70)
			end

			-- Print manufacturer
			CF["DrawString"](
				"Manufacturer: " .. (self.ItemShopSelectedItemManufacturer or "Unknown"),
				pos + Vector(10, -25),
				170,
				10
			)

			-- Print Selected mode text
			CF["DrawString"](
				self.ItemShopControlPanelModesTexts[self.ItemShopControlMode],
				pos + Vector(-130, -77),
				170,
				10
			)

			-- Print ItemShop capacity
			-- Print defferent capacity and storage for bombs
			if self.ItemShopSelectedItemType ~= nil and self.ItemShopSelectedItemType == CF["WeaponTypes"].BOMB then
				CF["DrawString"](
					"Bomb capacity: "
						.. CF["CountUsedBombsInArray"](self.Bombs)
						.. "/"
						.. self.GS["Player0VesselBombStorage"],
					pos + Vector(-130, -60),
					300,
					10
				)
			else
				CF["DrawString"](
					"Capacity: "
						.. CF["CountUsedStorageInArray"](self.StorageItems)
						.. "/"
						.. self.GS["Player0VesselStorageCapacity"],
					pos + Vector(-130, -60),
					300,
					10
				)
			end
			CF["DrawString"]("Gold: " .. CF["GetPlayerGold"](self.GS, 0) .. " oz", pos + Vector(-130, -44), 300, 10)
		end
	end

	if showidle and self.ItemShopControlPanelPos ~= nil and self.ItemShopControlPanelActor ~= nil then
		self:PutGlow("ControlPanel_ItemShop", self.ItemShopControlPanelPos)
		--CF["DrawString"]("Item\nStore ",self.ItemShopControlPanelPos + Vector(-16,0), 120, 20)

		self.ItemShopControlPanelInitialized = false

		-- Delete sample weapon
		if self.ItemShopControlPanelObject then
			self.ItemShopControlPanelObject = nil
		end
	end

	if MovableMan:IsActor(self.ItemShopControlPanelActor) then
		self.ItemShopControlPanelActor.Health = 100
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
