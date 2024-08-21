-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitClonesControlPanelUI()
	--self:DestroyClonesControlPanelUI()
	-- Clone Control Panel
	local x, y

	x = tonumber(self.SceneConfig["ClonesControlPanelX"])
	y = tonumber(self.SceneConfig["ClonesControlPanelY"])
	if x ~= nil and y ~= nil then
		self.ClonesControlPanelPos = Vector(x, y)
	else
		self.ClonesControlPanelPos = nil
	end

	x = tonumber(self.SceneConfig["ClonesDeployX"])
	y = tonumber(self.SceneConfig["ClonesDeployY"])
	if x ~= nil and y ~= nil then
		self.ClonesDeployPos = Vector(x, y)
	else
		self.ClonesDeployPos = nil
	end

	x = tonumber(self.SceneConfig["ClonesInputX"])
	y = tonumber(self.SceneConfig["ClonesInputY"])
	if x ~= nil and y ~= nil then
		self.ClonesInputPos = Vector(x, y)
	else
		self.ClonesInputPos = nil
	end

	-- Create actor
	-- Ship
	if self.ClonesControlPanelPos ~= nil then
		if not MovableMan:IsActor(self.ClonesControlPanelActor) then
			self.ClonesControlPanelActor = CreateActor("Clones Control Panel")
			if self.ClonesControlPanelActor ~= nil then
				self.ClonesControlPanelActor.Pos = self.ClonesControlPanelPos
				self.ClonesControlPanelActor.Team = CF["PlayerTeam"]
				MovableMan:AddActor(self.ClonesControlPanelActor)
			end
		end
	end

	self.ClonesInputDelay = 3
	self.ClonesInputRange = 35
	self.ClonesControlLastMessageTime = -1000
	self.ClonesControlMessageIntrval = 3
	self.ClonesControlMessageText = ""

	self.ClonesControlPanelLinesPerPage = 9

	self.ClonesControlPanelModes = { SELL = 0, CLONES = 1, INVENTORY = 2, ITEMS = 3 }
	self.ClonesControlPanelModesTexts = {}
	self.ClonesControlPanelModesHelpTexts = {}

	self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.SELL] = "SELL BODIES"
	self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.CLONES] = "Bodies"
	self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.INVENTORY] = "Inventory"
	self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.ITEMS] = "Items"

	self.ClonesControlPanelModesHelpTexts[self.ClonesControlPanelModes.SELL] = "L/R/U/D - Select, FIRE - Sell"
	self.ClonesControlPanelModesHelpTexts[self.ClonesControlPanelModes.CLONES] = "L/R/U/D - Select, FIRE - Deploy"
	self.ClonesControlPanelModesHelpTexts[self.ClonesControlPanelModes.INVENTORY] =
		"L/R/U/D - Select, FIRE - Remove from inventory"
	self.ClonesControlPanelModesHelpTexts[self.ClonesControlPanelModes.ITEMS] =
		"L/R/U/D - Select, FIRE - Add to inventory"

	self.Clones = CF["GetClonesArray"](self.GS)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyClonesControlPanelUI()
	if self.ClonesControlPanelActor ~= nil then
		self.ClonesControlPanelActor.ToDelete = true
		self.ClonesControlPanelActor = nil
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessClonesControlPanelUI()
	local showidle = true

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player)

		if act and MovableMan:IsActor(act) and act.PresetName == "Clones Control Panel" then
			showidle = false

			local pos = Vector(act.Pos.X, act.Pos.Y)

			-- Process controls
			local cont = act:GetController()

			-- Clone selection screen
			-- Init control panel
			if not self.ClonesControlPanelInitialized then
				if #self.Clones > 0 then
					self.SelectedClone = 1
				else
					self.SelectedClone = 0
				end

				self.ClonesStorageSelectedItem = 1
				self.ClonesInventorySelectedItem = 1

				self.ClonesControlPanelInitialized = true

				self.ClonesControlMode = self.ClonesControlPanelModes.CLONES
			end

			if self.SelectedClone ~= 0 then
				if cont:IsState(Controller.PRESS_LEFT) then
					self.ClonesControlMode = self.ClonesControlMode - 1
				end

				if cont:IsState(Controller.PRESS_RIGHT) then
					self.ClonesControlMode = self.ClonesControlMode + 1
				end

				if self.ClonesControlMode <= self.ClonesControlPanelModes.SELL - 1 then
					self.ClonesControlMode = self.ClonesControlPanelModes.SELL
				end

				-- don't let players dump bodies during assaults, that would not be good
				if self.GS["Mode"] == "Assault" and self.ClonesControlMode <= self.ClonesControlPanelModes.CLONES - 1 then
					self.ClonesControlMode = self.ClonesControlPanelModes.CLONES
				end

				if self.ClonesControlMode >= self.ClonesControlPanelModes.ITEMS + 1 then
					self.ClonesControlMode = self.ClonesControlPanelModes.ITEMS
				end

				if self.SelectedClone > 0 then
					if #self.Clones[self.SelectedClone]["Items"] < self.ClonesInventorySelectedItem then
						self.ClonesInventorySelectedItem = #self.Clones[self.SelectedClone]["Items"]
					end

					if self.ClonesInventorySelectedItem < 1 and #self.Clones[self.SelectedClone]["Items"] > 0 then
						self.ClonesInventorySelectedItem = 1
					end
				end
			end

			-- Clones list screen
			if
				self.ClonesControlMode == self.ClonesControlPanelModes.CLONES
				or self.ClonesControlMode == self.ClonesControlPanelModes.SELL
			then
				if self.ClonesControlMode == self.ClonesControlPanelModes.SELL then
					if
						CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].TRADESTAR)
						or CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].BLACKMARKET)
					then
						self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.SELL] = "SELL BODIES "
							.. CF["GetPlayerGold"](self.GS, 0)
							.. " oz"
						self.ClonesControlPanelModesHelpTexts[self.ClonesControlPanelModes.SELL] =
							"L/R/U/D - Select, FIRE - Sell"
					else
						self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.SELL] = "DUMP BODIES"
						self.ClonesControlPanelModesHelpTexts[self.ClonesControlPanelModes.SELL] =
							"L/R/U/D - Select, FIRE - Dump"
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
					if #self.Clones > 0 then
						self.SelectedClone = self.SelectedClone - 1

						if self.SelectedClone < 1 then
							self.SelectedClone = #self.Clones
						end
					end
				end

				if down then
					if #self.Clones > 0 then
						self.SelectedClone = self.SelectedClone + 1

						if self.SelectedClone > #self.Clones then
							self.SelectedClone = 1
						end
					end
				end

				self.ClonesControlCloneListStart = self.SelectedClone
					- (self.SelectedClone - 1) % self.ClonesControlPanelLinesPerPage

				self.SelectedClonePrice = 0
				local sellCoeff = CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].BLACKMARKET)
						and math.sqrt(CF["SellPriceCoeff"])
					or CF["SellPriceCoeff"]

				-- Draw clones list
				for i = self.ClonesControlCloneListStart, self.ClonesControlCloneListStart + self.ClonesControlPanelLinesPerPage - 1 do
					if i <= #self.Clones and i > 0 then
						local loc = i - self.ClonesControlCloneListStart

						local name = (
									self.Clones[i]["Prestige"]
									and self.Clones[i]["Name"]
									and self.Clones[i]["Name"] ~= ""
								)
								and self.Clones[i]["Name"]
							or self.Clones[i]["Preset"]
						if i == self.SelectedClone then
							CF["DrawString"]("> " .. name, pos + Vector(-130, -40) + Vector(0, loc * 12), 120, 10)
							-- Calculate actor price
							local fact, indx = CF["FindActorInFactions"](self.Clones[i]["Preset"], self.Clones[i]["Class"])
							self.SelectedClonePrice = math.floor(
								(
										(fact and indx) and self.SelectedClonePrice + CF["ActPrices"][fact][indx]
										or CF["UnknownActorPrice"]
									) * sellCoeff
							)

							--if self.ClonesControlMode == self.ClonesControlPanelModes.SELL and self.GS["Planet"] == "TradeStar" and self.GS["Location"] ~= nil then
							--	CF["DrawString"](tostring(self.SelectedClonePrice).."oz", pos + Vector(-20,-40) + Vector(0, (loc) * 12), 120, 10)
							--end
						else
							CF["DrawString"](name, pos + Vector(-130, -40) + Vector(0, loc * 12), 120, 10)
						end
					end
				end

				-- Draw selected clone items
				if self.SelectedClone ~= nil and self.SelectedClone > 0 then
					local drawPos = Vector(pos.X, pos.Y)
					local headless = self.Clones[self.SelectedClone]["HEAD"] == "Null"
					local armless = self.Clones[self.SelectedClone]["FG1"] == "Null"
						and self.Clones[self.SelectedClone]["BG1"] == "Null"
					local legless = self.Clones[self.SelectedClone]["FG2"] == "Null"
						and self.Clones[self.SelectedClone]["BG2"] == "Null"
					-- Include rank if any
					local info = ""
					local xp = self.Clones[self.SelectedClone]["XP"]
					if xp then
						xp = tonumber(xp)
						local showRank = 0
						for rank = 1, #CF["Ranks"] do
							if xp >= CF["Ranks"][rank] then
								showRank = rank
							else
								break
							end
						end
						local prestige = tonumber(self.Clones[self.SelectedClone]["Prestige"])
						if showRank ~= 0 or prestige ~= 0 then
							if prestige ~= 0 then
								showRank = showRank .. "x" .. prestige
							end
							info = "Rank: " .. showRank .. " "
						end
					end
					-- Print inventory
					CF["DrawString"](
						info .. "Inventory: " .. #self.Clones[self.SelectedClone]["Items"] .. "/" .. CF["MaxItems"],
						drawPos + Vector(12, -60),
						300,
						20
					)
					if headless or armless or legless then
						info = ""
						drawPos.Y = drawPos.Y + 12
						if headless then
							info = "HEADLESS"
						end
						if armless or legless then
							info = (info == "" and "" or info .. ", ")
								.. ((armless and legless) and "LIMBLESS" or (armless and "ARMLESS" or "LEGLESS"))
						end
						CF["DrawString"](info, drawPos + Vector(12, -60), 300, 20)
					end

					for i = 1, #self.Clones[self.SelectedClone]["Items"] do
						-- Calculate inventory price
						local fact, indx = CF["FindItemInFactions"](
							self.Clones[self.SelectedClone]["Items"][i]["Preset"],
							self.Clones[self.SelectedClone]["Items"][i]["Class"]
						)

						local price = math.floor(
							((fact and indx) and CF["ItmPrices"][fact][indx] or CF["UnknownItemPrice"]) * sellCoeff
						)
						self.SelectedClonePrice = self.SelectedClonePrice + price

						local prefix = ""
						if self.ClonesControlMode == self.ClonesControlPanelModes.SELL then
							if
								CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].TRADESTAR)
								or CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].BLACKMARKET)
							then
								prefix = tostring(price) .. "oz "
							end
						end

						CF["DrawString"](
							prefix .. self.Clones[self.SelectedClone]["Items"][i]["Preset"],
							drawPos + Vector(12, -40) + Vector(0, (i - 1) * 12),
							120,
							10
						)
					end
				end

				if self.ClonesControlMode == self.ClonesControlPanelModes.SELL then
					if
						CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].TRADESTAR)
						or CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].BLACKMARKET)
					then
						CF["DrawString"]("Sell price: " .. self.SelectedClonePrice, pos + Vector(12, 60), 300, 10)
					end
				end

				-- Print clone storage capacity
				CF["DrawString"](
					"Capacity: "
						.. CF["CountUsedClonesInArray"](self.Clones)
						.. "/"
						.. self.GS["Player0VesselClonesCapacity"],
					pos + Vector(-130, -60),
					300,
					10
				)

				-- Change panel text to show life support capacity
				self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.CLONES] = "Bodies - Life support usage: "
					.. CF["CountActors"](CF["PlayerTeam"])
					.. "/"
					.. self.GS["Player0VesselLifeSupport"]

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						if self.ClonesControlMode == self.ClonesControlPanelModes.SELL then
							if self.SelectedClone ~= 0 then
								if
									CF["IsLocationHasAttribute"](self.GS["Location"], CF["LocationAttributeTypes"].TRADESTAR)
									or CF["IsLocationHasAttribute"](
										self.GS["Location"],
										CF["LocationAttributeTypes"].BLACKMARKET
									)
								then
									CF["SetPlayerGold"](self.GS, 0, CF["GetPlayerGold"](self.GS, 0) + self.SelectedClonePrice)
								end

								-- Remove actor from array
								local newarr = {}
								local ii = 1

								for i = 1, #self.Clones do
									if i ~= self.SelectedClone then
										newarr[ii] = self.Clones[i]
										ii = ii + 1
									end
								end

								self.Clones = newarr

								-- Update game state data
								CF["SetClonesArray"](self.GS, self.Clones)

								if self.SelectedClone > #self.Clones then
									self.SelectedClone = #self.Clones
								end
							else
								self.ClonesControlLastMessageTime = self.Time
								self.ClonesControlMessageText = "Clone storage is empty"
							end
						else
							if CF["CountActors"](CF["PlayerTeam"]) < tonumber(self.GS["Player0VesselLifeSupport"]) then
								-- Create new unit
								if self.SelectedClone ~= 0 then
									if MovableMan:GetMOIDCount() < CF["MOIDLimit"] then
										-- Spawn actor
										local limbData = {}
										for j = 1, #CF["LimbID"] do
											limbData[j] = self.Clones[self.SelectedClone][CF["LimbID"][j]]
											if not CF["PermanentLimbLoss"] and limbData[j] == "Null" then
												limbData[j] = nil
											end
										end
										local a = CF["MakeActor"](
											self.Clones[self.SelectedClone]["Preset"],
											self.Clones[self.SelectedClone]["Class"],
											self.Clones[self.SelectedClone]["Module"],
											self.Clones[self.SelectedClone]["XP"],
											self.Clones[self.SelectedClone]["Identity"],
											self.Clones[self.SelectedClone]["Player"],
											self.Clones[self.SelectedClone]["Prestige"],
											self.Clones[self.SelectedClone]["Name"],
											limbData
										)
										if a ~= nil then
											a.Team = CF["PlayerTeam"]
											a.AIMode = Actor.AIMODE_SENTRY

											for i = 1, #self.Clones[self.SelectedClone]["Items"] do
												local itm = CF["MakeItem"](
													self.Clones[self.SelectedClone]["Items"][i]["Preset"],
													self.Clones[self.SelectedClone]["Items"][i]["Class"],
													self.Clones[self.SelectedClone]["Items"][i]["Module"]
												)
												if itm ~= nil then
													if
														itm:HasScript(CF["ModuleName"] .. "/Items/Limb.lua")
														and CF["AttemptReplaceLimb"](a, itm)
													then
														DeleteEntity(itm)
													else
														a:AddInventoryItem(itm)
													end
												else
													self.ClonesControlLastMessageTime = self.Time
													self.ClonesControlMessageText = "ERROR!!! Can't create item!!!"
												end
											end
											if IsAHuman(a) and ToAHuman(a).Head == nil then
												a.DeathSound = nil
												a.Status = Actor.DEAD
											end
											a.Pos = self.ClonesDeployPos or self.ClonesControlPanelPos

											a.RestThreshold = -1
											MovableMan:AddActor(a)

											self:AddPreEquippedItemsToRemovalQueue(a)

											-- Remove actor from array
											local newarr = {}
											local ii = 1

											for i = 1, #self.Clones do
												if i ~= self.SelectedClone then
													newarr[ii] = self.Clones[i]
													ii = ii + 1
												end
											end

											self.Clones = newarr

											-- Update game state data
											CF["SetClonesArray"](self.GS, self.Clones)

											if self.SelectedClone > #self.Clones then
												self.SelectedClone = #self.Clones
											end
										else
											self.ClonesControlLastMessageTime = self.Time
											self.ClonesControlMessageText = "ERROR!!! Can't create actor!!!"
										end
									else
										self.ClonesControlLastMessageTime = self.Time
										self.ClonesControlMessageText = "Too many objects in simulation"
									end
								else
									self.ClonesControlLastMessageTime = self.Time
									self.ClonesControlMessageText = "Clone storage is empty"
								end
							else
								if self.SelectedClone == 0 then
									self.ClonesControlLastMessageTime = self.Time
									self.ClonesControlMessageText = "Clone storage is empty"
								else
									self.ClonesControlLastMessageTime = self.Time
									self.ClonesControlMessageText = "Too many units. Upgrade life support."
								end
							end
						end -- If not sell mode
					end
				else
					self.FirePressed[player] = false
				end
			end

			-- Inventory list screen
			if self.ClonesControlMode == self.ClonesControlPanelModes.INVENTORY then
				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						if
							self.SelectedClone > 0
							and CF["CountUsedStorageInArray"](self.StorageItems) < tonumber(
								self.GS["Player0VesselStorageCapacity"]
							)
							and #self.Clones[self.SelectedClone]["Items"] > 0
						then
							-- Put item to storage array
							CF["PutItemToStorageArray"](
								self.StorageItems,
								self.Clones[self.SelectedClone]["Items"][self.ClonesInventorySelectedItem]["Preset"],
								self.Clones[self.SelectedClone]["Items"][self.ClonesInventorySelectedItem]["Class"],
								self.Clones[self.SelectedClone]["Items"][self.ClonesInventorySelectedItem]["Module"]
							)
							CF["SetStorageArray"](self.GS, self.StorageItems)

							-- Refresh storage items array and filters
							self.StorageItems, self.StorageFilters = CF["GetStorageArray"](self.GS, true)

							-- Remove item from inventory via temp array
							local inv = {}
							local ii = 1

							for i = 1, #self.Clones[self.SelectedClone]["Items"] do
								if i ~= self.ClonesInventorySelectedItem then
									inv[ii] = {}

									inv[ii]["Preset"] = self.Clones[self.SelectedClone]["Items"][i]["Preset"]
									inv[ii]["Class"] = self.Clones[self.SelectedClone]["Items"][i]["Class"]
									inv[ii]["Module"] = self.Clones[self.SelectedClone]["Items"][i]["Module"]

									ii = ii + 1
								end
							end

							self.Clones[self.SelectedClone]["Items"] = inv

							CF["SetClonesArray"](self.GS, self.Clones)

							self.ClonesInventorySelectedItem = math.max(self.ClonesInventorySelectedItem - 1, 1)
						end
					end
				else
					self.FirePressed[player] = false
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
					self.ClonesInventorySelectedItem = self.ClonesInventorySelectedItem - 1

					if self.ClonesInventorySelectedItem < 1 then
						self.ClonesInventorySelectedItem = #self.Clones[self.SelectedClone]["Items"]
					end
				end

				if down then
					self.ClonesInventorySelectedItem = self.ClonesInventorySelectedItem + 1

					if self.ClonesInventorySelectedItem > #self.Clones[self.SelectedClone]["Items"] then
						self.ClonesInventorySelectedItem = 1
					end
				end
			end

			if self.ClonesControlMode == self.ClonesControlPanelModes.ITEMS then
				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						if
							self.SelectedClone > 0
							and #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING] > 0
						then
							local itm =
								self.StorageFilters[self.StorageControlPanelModes.EVERYTHING][self.ClonesStorageSelectedItem]

							--Add item to unit's inventory
							if #self.Clones[self.SelectedClone]["Items"] < CF["MaxItems"] then
								if self.StorageItems[itm]["Count"] > 0 then
									local newitm = #self.Clones[self.SelectedClone]["Items"] + 1
									self.StorageItems[itm]["Count"] = self.StorageItems[itm]["Count"] - 1
									self.Clones[self.SelectedClone]["Items"][newitm] = {}
									self.Clones[self.SelectedClone]["Items"][newitm]["Preset"] =
										self.StorageItems[itm]["Preset"]
									self.Clones[self.SelectedClone]["Items"][newitm]["Class"] =
										self.StorageItems[itm]["Class"]
									self.Clones[self.SelectedClone]["Items"][newitm]["Module"] =
										self.StorageItems[itm]["Module"]

									-- Update game state
									CF["SetClonesArray"](self.GS, self.Clones)
									CF["SetStorageArray"](self.GS, self.StorageItems)

									-- Refresh storage array and filters
									if self.StorageItems[itm]["Count"] == 0 then
										self.StorageItems, self.StorageFilters = CF["GetStorageArray"](self.GS, true)
									end
								else
									self.ClonesControlLastMessageTime = self.Time
									self.ClonesControlMessageText = "No more items in storage"
								end
							else
								self.ClonesControlLastMessageTime = self.Time
								self.ClonesControlMessageText = "Unit inventory full"
							end
						else
							self.ClonesControlLastMessageTime = self.Time
							self.ClonesControlMessageText = "Clone storage empty"
						end
					end
				else
					self.FirePressed[player] = false
				end

				-- Bacause StorageFilters may change outside of this panel by other players always check for out-of-bounds
				if
					self.ClonesStorageSelectedItem > #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING]
					and #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING] > 0
				then
					self.ClonesStorageSelectedItem = #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING]
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
					if #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING] > 0 then
						self.ClonesStorageSelectedItem = self.ClonesStorageSelectedItem - 1

						if self.ClonesStorageSelectedItem < 1 then
							self.ClonesStorageSelectedItem =
								#self.StorageFilters[self.StorageControlPanelModes.EVERYTHING]
						end
					end
				end

				if down then
					if #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING] > 0 then
						self.ClonesStorageSelectedItem = self.ClonesStorageSelectedItem + 1

						if
							self.ClonesStorageSelectedItem
							> #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING]
						then
							self.ClonesStorageSelectedItem = 1
						end
					end
				end
			end

			-- Draw clones inventory and stored items lists
			if
				self.ClonesControlMode == self.ClonesControlPanelModes.INVENTORY
				or self.ClonesControlMode == self.ClonesControlPanelModes.ITEMS
			then
				-- Draw selected clone items
				if self.SelectedClone ~= nil and self.SelectedClone > 0 then
					-- Print inventory
					local name = (
								self.Clones[self.SelectedClone]["Prestige"]
								and self.Clones[self.SelectedClone]["Name"]
								and self.Clones[self.SelectedClone]["Name"] ~= ""
							)
							and self.Clones[self.SelectedClone]["Name"]
						or self.Clones[self.SelectedClone]["Preset"]
					CF["DrawString"](
						name .. ": " .. #self.Clones[self.SelectedClone]["Items"] .. "/" .. CF["MaxItems"],
						pos + Vector(-141 + 12, -60),
						300,
						10
					)

					for i = 1, #self.Clones[self.SelectedClone]["Items"] do
						if
							self.ClonesControlMode == self.ClonesControlPanelModes.INVENTORY
							and self.ClonesInventorySelectedItem == i
						then
							CF["DrawString"](
								"> " .. self.Clones[self.SelectedClone]["Items"][i]["Preset"],
								pos + Vector(-141 + 12, -40) + Vector(0, (i - 1) * 12),
								120,
								10
							)
							self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.INVENTORY] = self.Clones[self.SelectedClone]["Items"][i]["Preset"]
								.. " - Inventory"
						else
							CF["DrawString"](
								self.Clones[self.SelectedClone]["Items"][i]["Preset"],
								pos + Vector(-141 + 12, -40) + Vector(0, (i - 1) * 12),
								120,
								10
							)
						end
					end
				end

				local liststart = self.ClonesStorageSelectedItem
					- (self.ClonesStorageSelectedItem - 1) % self.ClonesControlPanelLinesPerPage

				-- Draw items list
				for i = liststart, liststart + self.ClonesControlPanelLinesPerPage - 1 do
					if i <= #self.StorageFilters[self.StorageControlPanelModes.EVERYTHING] then
						local itm = self.StorageFilters[self.StorageControlPanelModes.EVERYTHING][i]
						local loc = i - liststart

						if
							self.ClonesControlMode == self.ClonesControlPanelModes.ITEMS
							and self.ClonesStorageSelectedItem == i
						then
							CF["DrawString"](
								"> " .. self.StorageItems[itm]["Preset"],
								pos + Vector(12, -40) + Vector(0, loc * 12),
								110,
								10
							)
							self.ClonesControlPanelModesTexts[self.ClonesControlPanelModes.ITEMS] = self.StorageItems[itm]["Preset"]
								.. " - Items"
						else
							CF["DrawString"](
								self.StorageItems[itm]["Preset"],
								pos + Vector(12, -40) + Vector(0, loc * 12),
								110,
								10
							)
						end

						CF["DrawString"](
							tostring(self.StorageItems[itm]["Count"]),
							pos + Vector(12, -40) + Vector(110, loc * 12),
							110,
							10
						)
					end
				end

				-- Print storage capacity
				CF["DrawString"](
					"Capacity: "
						.. CF["CountUsedStorageInArray"](self.StorageItems)
						.. "/"
						.. self.GS["Player0VesselStorageCapacity"],
					pos + Vector(12, -60),
					300,
					10
				)
			end

			-- Draw generic UI
			if self.ClonesControlMode ~= self.ClonesControlPanelModes.SELL then
				self:PutGlow("ControlPanel_Clones_Left", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Clones_Right", pos + Vector(70, 0))
				self:PutGlow("ControlPanel_Clones_HorizontalPanel", pos + Vector(0, -77))
			else
				self:PutGlow("ControlPanel_Clones_Left_Red", pos + Vector(-71, 0))
				self:PutGlow("ControlPanel_Clones_Right_Red", pos + Vector(70, 0))
				self:PutGlow("ControlPanel_Clones_HorizontalPanel_Red", pos + Vector(0, -77))
			end

			-- Print help text or error message text
			if self.Time < self.ClonesControlLastMessageTime + self.ClonesControlMessageIntrval then
				self:PutGlow("ControlPanel_Clones_HorizontalPanel_Red", pos + Vector(0, 78))
				CF["DrawString"](self.ClonesControlMessageText, pos + Vector(-130, 78), 300, 10)
			else
				if self.ClonesControlMode ~= self.ClonesControlPanelModes.SELL then
					self:PutGlow("ControlPanel_Clones_HorizontalPanel", pos + Vector(0, 78))
				else
					self:PutGlow("ControlPanel_Clones_HorizontalPanel_Red", pos + Vector(0, 78))
				end

				CF["DrawString"](
					self.ClonesControlPanelModesHelpTexts[self.ClonesControlMode],
					pos + Vector(-130, 78),
					300,
					10
				)
			end

			-- Print Selected mode text
			CF["DrawString"](self.ClonesControlPanelModesTexts[self.ClonesControlMode], pos + Vector(-130, -77), 250, 10)
		end
	end

	if showidle and self.ClonesControlPanelPos ~= nil and self.ClonesControlPanelActor ~= nil then
		self.ClonesControlPanelInitialized = false
		self:PutGlow("ControlPanel_Clones", self.ClonesControlPanelPos)
		--CF["DrawString"]("CLONES",self.ClonesControlPanelPos + Vector(-16,0),120,20 )
		--print (self.ClonesControlPanelActor)
	end

	-- Process clones input
	if
		self.ClonesInputPos ~= nil
		and self.ClonesControlPanelActor ~= nil
		and self.GS["Mode"] ~= "Assault"
		and not self.RandomEncounterAttackLaunched
	then
		local count = CF["CountUsedClonesInArray"](self.Clones)
		local toresettimer = true
		
		if count < tonumber(self.GS["Player0VesselClonesCapacity"]) then
			local hasactor = false

			-- Search for body and put it in storage
			for actor in MovableMan:GetMOsInRadius(self.ClonesInputPos, self.ClonesInputRange, Activity.NOTEAM, true) do
				if IsActor(actor) and actor.Team == CF.PlayerTeam then
					actor = ToActor(actor)
					local controller = actor:GetController()
					local moving = controller:IsState(Controller.MOVE_LEFT)
						or controller:IsState(Controller.MOVE_RIGHT)
						or controller:IsState(Controller.BODY_JUMP)
						or controller:IsState(Controller.BODY_CROUCH)

					local actorDead = actor.Status == Actor.DEAD
					if actorDead then
						if IsACrab(actor) then
							local crab = ToACrab(actor)
							if crab.Jetpack then 
								crab.Jetpack:EnableEmission(false)
							end
						elseif IsAHuman(actor) then
							local human = ToAHuman(actor)
							if human.Jetpack then 
								human.Jetpack:EnableEmission(false)
							end
						end
						moving = false
					end

					if not moving and actor.PresetName ~= "Clones Control Panel" and not actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") then
						toresettimer = false

						if actorDead then
							actor.Vel = actor.Vel * 0.95 + Vector(0, -0.01) - (actor.Pos - self.ClonesInputPos) / 200
						end

						if self.ClonesLastDetectedBodyTime ~= nil then
							-- Put clone to storage
							if
								self.Time >= self.ClonesLastDetectedBodyTime + self.ClonesInputDelay
								and CF["CountUsedClonesInArray"](self.Clones)
									< tonumber(self.GS["Player0VesselClonesCapacity"])
							then
								local c = #self.Clones + 1

								self.Clones[c] = {}
								self.Clones[c]["Preset"] = actor.PresetName
								self.Clones[c]["Class"] = actor.ClassName
								self.Clones[c]["Module"] = actor.ModuleName
								self.Clones[c]["XP"] = actor:GetNumberValue("VW_XP")
								self.Clones[c]["Identity"] = actor:GetNumberValue("Identity")
								self.Clones[c]["Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
								self.Clones[c]["Prestige"] = actor:GetNumberValue("VW_Prestige")
								self.Clones[c]["Name"] = actor:GetStringValue("VW_Name")
								for j = 1, #CF["LimbID"] do
									self.Clones[c][CF["LimbID"][j]] = CF["GetLimbData"](actor, j)
								end

								-- Store inventory
								local inv, cls, mdl = CF["GetInventory"](actor)

								self.Clones[c]["Items"] = {}

								for i = 1, #inv do
									-- First store items in clone storage
									if i <= CF["MaxItems"] then
										self.Clones[c]["Items"][i] = {}
										self.Clones[c]["Items"][i]["Preset"] = inv[i]
										self.Clones[c]["Items"][i]["Class"] = cls[i]
										self.Clones[c]["Items"][i]["Module"] = mdl[i]
									else
										-- Try to store other items in items storage
										-- If we have free space add items to storage, spawn nearby otherwise
										if
											CF["CountUsedStorageInArray"](self.StorageItems)
											< tonumber(self.GS["Player0VesselStorageCapacity"])
										then
											-- Put item to storage array
											CF["PutItemToStorageArray"](self.StorageItems, inv[i], cls[i], mdl[i])

											-- Store everything
											CF["SetStorageArray"](self.GS, self.StorageItems)

											-- Refresh storage items array and filters
											self.StorageItems, self.StorageFilters = CF["GetStorageArray"](self.GS, true)
										else
											local itm = CF["MakeItem"](inv[i], cls[i], mdl[i])
											if itm ~= nil then
												itm.Pos = self.ClonesInputPos
												MovableMan:AddItem(itm)
											end
										end
									end
								end

								if actor:IsPlayerControlled() then
									self:SwitchToActor(self.ClonesControlPanelActor, controller.Player, CF["PlayerTeam"])
								end
								if actor.GoldCarried > 0 then
									CF["SetPlayerGold"](self.GS, 0, CF["GetPlayerGold"](self.GS, 0) + actor.GoldCarried)
								end

								actor.ToDelete = true

								-- Store everything
								CF["SetClonesArray"](self.GS, self.Clones)

								-- Refresh storage items array and filters
								self.Clones = CF["GetClonesArray"](self.GS, true)

								self.ClonesLastDetectedBodyTime = nil
							end

							hasactor = true
						else
							self.ClonesLastDetectedBodyTime = self.Time
						end
					end
				end
			end

			if showidle then
				if hasactor and self.ClonesLastDetectedBodyTime ~= nil then
					self:AddObjectivePoint(
						"Store in " .. self.ClonesLastDetectedBodyTime + self.ClonesInputDelay - self.Time,
						self.ClonesInputPos,
						CF["PlayerTeam"],
						GameActivity.ARROWDOWN
					)
				else
					self:AddObjectivePoint(
						"Stand here to store body\n" .. count .. " / " .. self.GS["Player0VesselClonesCapacity"],
						self.ClonesInputPos,
						CF["PlayerTeam"],
						GameActivity.ARROWDOWN
					)
				end
			end
		else
			self:AddObjectivePoint(
				"Clone storage is full",
				self.ClonesInputPos + Vector(0, -40),
				CF["PlayerTeam"],
				GameActivity.ARROWUP
			)
			self.ClonesLastDetectedBodyTime = nil
		end

		if toresettimer then
			self.ClonesLastDetectedBodyTime = nil
		end
	end

	if MovableMan:IsActor(self.CloneControlPanelActor) then
		self.CloneControlPanelActor.Health = 100
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
