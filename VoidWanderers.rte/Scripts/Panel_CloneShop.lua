-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitCloneShopControlPanelUI()
	-- CloneShop Control Panel
	local x, y

	x = tonumber(self.SceneConfig["CloneShopControlPanelX"])
	y = tonumber(self.SceneConfig["CloneShopControlPanelY"])
	if x ~= nil and y ~= nil then
		self.CloneShopControlPanelPos = Vector(x, y)
	else
		self.CloneShopControlPanelPos = nil
	end

	if self.CloneShopControlPanelPos ~= nil then
		self:LocateCloneShopControlPanelActor()
		if not MovableMan:IsActor(self.CloneShopControlPanelActor) then
			self.CloneShopControlPanelActor = CreateActor("Clone Shop Control Panel")
			if self.CloneShopControlPanelActor ~= nil then
				self.CloneShopControlPanelActor.Pos = self.CloneShopControlPanelPos
				self.CloneShopControlPanelActor.Team = CF["PlayerTeam"]
				MovableMan:AddActor(self.CloneShopControlPanelActor)
			end
		end
	end

	-- Init variables
	self.CloneShopControlPanelItemsPerPage = 8
	self.CloneShopControlPanelModes = { EVERYTHING = -1, LIGHT = 0, HEAVY = 1, ARMOR = 2, TURRET = 3 }
	self.CloneShopControlPanelModesTexts = {}

	self.CloneShopControlPanelModesTexts[self.CloneShopControlPanelModes.EVERYTHING] = "All bodies"
	self.CloneShopControlPanelModesTexts[self.CloneShopControlPanelModes.LIGHT] = "Light bodies"
	self.CloneShopControlPanelModesTexts[self.CloneShopControlPanelModes.HEAVY] = "Heavy bodies"
	self.CloneShopControlPanelModesTexts[self.CloneShopControlPanelModes.ARMOR] = "Armored bodies"
	self.CloneShopControlPanelModesTexts[self.CloneShopControlPanelModes.TURRET] = "Turrets"

	self.CloneShopControlMode = self.CloneShopControlPanelModes.EVERYTHING

	self.CloneShopTradeStar = false
	self.CloneShopBlackMarket = false

	if CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].TRADESTAR) then
		self.CloneShopItems, self.CloneShopFilters = CF["GetCloneShopArray"](self.GS, true)
		self.CloneShopTradeStar = true
	end

	if CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].BLACKMARKET) then
		self.CloneShopItems, self.CloneShopFilters = CF["GetCloneBlackMarketArray"](self.GS, true)
		self.CloneShopBlackMarket = true
	end
end
-----------------------------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------------------------
function VoidWanderers:LocateCloneShopControlPanelActor()
	for actor in MovableMan.Actors do
		if actor.PresetName == "Clone Shop Control Panel" then
			self.CloneShopControlPanelActor = actor
			break
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyCloneShopControlPanelUI()
	if self.CloneShopControlPanelActor ~= nil then
		self.CloneShopControlPanelActor.ToDelete = true
		self.CloneShopControlPanelActor = nil
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessCloneShopControlPanelUI()
	local showidle = true

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player)

		if act and MovableMan:IsActor(act) and act.PresetName == "Clone Shop Control Panel" then
			showidle = false

			self.LastCloneShopSelectedClone = self.CloneShopSelectedClone

			-- Init control panel
			if not self.CloneShopControlPanelInitialized then
				self.CloneShopSelectedClone = 1
				self.LastCloneShopSelectedClone = 0
				self.CloneShopControlPanelInitialized = true
			end

			-- Draw generic UI
			local pos = act.Pos
			self:PutGlow("ControlPanel_Storage_List", pos + Vector(-71, 0))
			if self.CloneShopTradeStar then
				self:PutGlow("ControlPanel_CloneShop_Description", pos + Vector(90, 0))
			end
			if self.CloneShopBlackMarket then
				self:PutGlow("ControlPanel_CloneBlackMarket_Description", pos + Vector(90, 0))
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
				if #self.CloneShopFilters[self.CloneShopControlMode] > 0 then
					self.CloneShopSelectedClone = self.CloneShopSelectedClone - 1

					if self.CloneShopSelectedClone < 1 then
						self.CloneShopSelectedClone = #self.CloneShopFilters[self.CloneShopControlMode]
					end
				end
			end

			if down then
				if #self.CloneShopFilters[self.CloneShopControlMode] > 0 then
					self.CloneShopSelectedClone = self.CloneShopSelectedClone + 1

					if self.CloneShopSelectedClone > #self.CloneShopFilters[self.CloneShopControlMode] then
						self.CloneShopSelectedClone = 1
					end
				end
			end

			if cont:IsState(Controller.PRESS_LEFT) then
				self.CloneShopControlMode = self.CloneShopControlMode - 1
				self.CloneShopSelectedClone = 1
				self.LastCloneShopSelectedClone = 0

				if self.CloneShopControlMode == -2 then
					self.CloneShopControlMode = self.CloneShopControlPanelModes.TURRET
				end
			end

			if cont:IsState(Controller.PRESS_RIGHT) then
				self.CloneShopControlMode = self.CloneShopControlMode + 1
				self.CloneShopSelectedClone = 1
				self.LastCloneShopSelectedClone = 0

				if self.CloneShopControlMode == 4 then
					self.CloneShopControlMode = self.CloneShopControlPanelModes.EVERYTHING
				end
			end

			self.CloneShopControlItemsListStart = self.CloneShopSelectedClone
				- (self.CloneShopSelectedClone - 1) % self.CloneShopControlPanelItemsPerPage

			-- Get selected item info
			if self.CloneShopSelectedClone ~= self.LastCloneShopSelectedClone then
				local cln = self.CloneShopFilters[self.CloneShopControlMode][self.CloneShopSelectedClone]

				if cln ~= nil then
					-- Get item description
					self.CloneShopSelectedCloneDescription = self.CloneShopItems[cln]["Description"]
					self.CloneShopSelectedCloneManufacturer = CF["FactionNames"][self.CloneShopItems[cln]["Faction"]]
					self.CloneShopSelectedClonePrice = self.CloneShopItems[cln]["Price"]
				else
					self.CloneShopSelectedCloneDescription = ""
					self.CloneShopSelectedCloneManufacturer = ""
					self.CloneShopSelectedClonePrice = nil
				end
			end

			-- Dispense/sell/dump items
			if cont:IsState(Controller.WEAPON_FIRE) then
				if not self.FirePressed[player] then
					self.FirePressed[player] = true

					if self.CloneShopSelectedClone > 0 then
						local cln = self.CloneShopFilters[self.CloneShopControlMode][self.CloneShopSelectedClone]

						if cln ~= nil then
							if self.CloneShopItems[cln]["Type"] == CF["ActorTypes"].TURRET then
								if
									CF["CountUsedTurretsInArray"](self.Turrets)
										< tonumber(self.GS["PlayerVesselTurretStorage"])
									and self.CloneShopSelectedClonePrice <= CF["GetPlayerGold"](self.GS, 0)
								then
									--[[local c = #self.Turrets + 1
									
									self.Turrets[c] = {}
									self.Turrets[c]["Preset"] = self.CloneShopItems[cln]["Preset"]
									self.Turrets[c]["Class"] = self.CloneShopItems[cln]["Class"]--]]
									--

									CF["PutTurretToStorageArray"](
										self.Turrets,
										self.CloneShopItems[cln]["Preset"],
										self.CloneShopItems[cln]["Class"],
										self.CloneShopItems[cln]["Module"]
									)

									CF["SetTurretsArray"](self.GS, self.Turrets)
									CF.ChangeGold(self.GS, -self.CloneShopSelectedClonePrice)
								end
							else
								if
									CF["CountUsedClonesInArray"](self.Clones)
										< tonumber(self.GS["PlayerVesselClonesCapacity"])
									and self.CloneShopSelectedClonePrice <= CF["GetPlayerGold"](self.GS, 0)
								then
									local c = #self.Clones + 1
									
									self.Clones[c] = {}
									self.Clones[c]["Preset"] = self.CloneShopItems[cln]["Preset"]
									self.Clones[c]["Class"] = self.CloneShopItems[cln]["Class"]
									self.Clones[c]["Module"] = self.CloneShopItems[cln]["Module"]
									self.Clones[c]["Items"] = {}

									CF["SetClonesArray"](self.GS, self.Clones)

									CF.ChangeGold(self.GS, -self.CloneShopSelectedClonePrice)
								end
							end
						else
							print("Error in Panel_CloneShop.lua - cln is nil")
						end
					end
				end
			else
				self.FirePressed[player] = false
			end

			-- Draw items list
			for i = self.CloneShopControlItemsListStart, self.CloneShopControlItemsListStart + self.CloneShopControlPanelItemsPerPage - 1 do
				if i <= #self.CloneShopFilters[self.CloneShopControlMode] then
					local cln = self.CloneShopFilters[self.CloneShopControlMode][i]
					local loc = i - self.CloneShopControlItemsListStart

					if i == self.CloneShopSelectedClone then
						CF["DrawString"](
							"> " .. self.CloneShopItems[cln]["Preset"],
							pos + Vector(-130, -26) + Vector(0, loc * 12),
							90,
							10
						)
					else
						CF["DrawString"](
							self.CloneShopItems[cln]["Preset"],
							pos + Vector(-130, -26) + Vector(0, loc * 12),
							90,
							10
						)
					end
					local priceString = tostring(self.CloneShopItems[cln]["Price"])
					if self.CloneShopItems[cln]["Price"] >= 1000 then
						if self.CloneShopItems[cln]["Price"] >= 10000 then
							priceString = tostring(math.floor(self.CloneShopItems[cln]["Price"] * 0.001)) .. "k"
						else
							priceString = tostring(math.floor(self.CloneShopItems[cln]["Price"] * 0.01) * 0.1) .. "k"
						end
					end
					CF["DrawString"](priceString, pos + Vector(-130, -26) + Vector(110, loc * 12), 90, 10)
				end
			end

			-- Print description
			if self.CloneShopSelectedCloneDescription ~= nil then
				CF["DrawString"](self.CloneShopSelectedCloneDescription, pos + Vector(10, -40), 170, 140)
			end

			-- Print manufacturer
			CF["DrawString"](
				"Manufacturer: " .. (self.CloneShopSelectedCloneManufacturer or "Unknown"),
				pos + Vector(10, -58),
				170,
				120
			)

			-- Print Selected mode text
			CF["DrawString"](
				self.CloneShopControlPanelModesTexts[self.CloneShopControlMode],
				pos + Vector(-130, -77),
				170,
				10
			)

			-- Print CloneShop capacity
			local cln = self.CloneShopFilters[self.CloneShopControlMode][self.CloneShopSelectedClone]

			if cln ~= nil and self.CloneShopItems[cln]["Type"] == CF["ActorTypes"].TURRET then
				CF["DrawString"](
					"Turrets: "
						.. CF["CountUsedTurretsInArray"](self.Turrets)
						.. "/"
						.. self.GS["PlayerVesselTurretStorage"],
					pos + Vector(-130, -60),
					300,
					10
				)
			else
				CF["DrawString"](
					"Capacity: "
						.. CF["CountUsedClonesInArray"](self.Clones)
						.. "/"
						.. self.GS["PlayerVesselClonesCapacity"],
					pos + Vector(-130, -60),
					300,
					10
				)
			end
			CF["DrawString"]("Gold: " .. CF["GetPlayerGold"](self.GS, 0) .. " oz", pos + Vector(-130, -44), 300, 10)
		end
	end

	if showidle and self.CloneShopControlPanelPos ~= nil and self.CloneShopControlPanelActor ~= nil then
		self:PutGlow("ControlPanel_CloneShop", self.CloneShopControlPanelPos)
		--CF["DrawString"]("Body\nStore ",self.CloneShopControlPanelPos + Vector(-16,0), 120, 20)

		self.CloneShopControlPanelInitialized = false
	end

	if MovableMan:IsActor(self.CloneShopControlPanelActor) then
		self.CloneShopControlPanelActor.Health = 100
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
