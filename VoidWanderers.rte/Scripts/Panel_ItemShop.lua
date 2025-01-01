-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitItemShopControlPanelUI()
	local x, y;

	x = tonumber(self.SceneConfig["ItemShopControlPanelX"]);
	y = tonumber(self.SceneConfig["ItemShopControlPanelY"]);

	if x ~= nil and y ~= nil then
		self.ItemShopControlPanelPos = Vector(x, y);
	else
		self.ItemShopControlPanelPos = nil;
	end

	if self.ItemShopControlPanelPos ~= nil then
		self:LocateItemShopControlPanelActor();

		if not MovableMan:IsActor(self.ItemShopControlPanelActor) then
			self.ItemShopControlPanelActor = CreateActor("Item Shop Control Panel");

			if self.ItemShopControlPanelActor ~= nil then
				self.ItemShopControlPanelActor.Pos = self.ItemShopControlPanelPos;
				self.ItemShopControlPanelActor.Team = CF.PlayerTeam;
				MovableMan:AddActor(self.ItemShopControlPanelActor);
			end
		end
	end

	-- Init variables
	self.ItemShopControlPanelItemsPerPage = 10;
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
	};

	texts = {};
	texts[self.ItemShopControlPanelModes.EVERYTHING] = "All items";
	texts[self.ItemShopControlPanelModes.PISTOL] = "Secondary";
	texts[self.ItemShopControlPanelModes.RIFLE] = "Primary";
	texts[self.ItemShopControlPanelModes.SHOTGUN] = "Shotguns";
	texts[self.ItemShopControlPanelModes.SNIPER] = "Sniper rifles";
	texts[self.ItemShopControlPanelModes.HEAVY] = "Heavy weapons";
	texts[self.ItemShopControlPanelModes.SHIELD] = "Shields";
	texts[self.ItemShopControlPanelModes.DIGGER] = "Tools - Diggers";
	texts[self.ItemShopControlPanelModes.GRENADE] = "Explosives";
	texts[self.ItemShopControlPanelModes.TOOL] = "Tools";
	texts[self.ItemShopControlPanelModes.BOMB] = "Bombs";
	self.ItemShopControlPanelModesTexts = texts;

	self.ItemShopControlMode = self.ItemShopControlPanelModes.EVERYTHING;
	self.ItemShopSelectedItem = 1;

	self.ItemShopTradeStar = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR);
	self.ItemShopBlackMarket = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET);

	if self.ItemShopTradeStar then
		self.ItemShopItems, self.ItemShopFilters = CF.GetItemShopArray(self.GS, true);
	end

	if self.ItemShopBlackMarket then
		self.ItemShopItems, self.ItemShopFilters = CF.GetItemBlackMarketArray(self.GS, true);
	end
end
-----------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------
function VoidWanderers:LocateItemShopControlPanelActor()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Item Shop Control Panel" then
			self.ItemShopControlPanelActor = actor;
			break;
		end
	end end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyItemShopControlPanelUI()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Item Shop Control Panel" then
			local actor = MovableMan:RemoveActor(actor);
			DeleteEntity(actor);
			actor = nil;
			self.ItemShopControlPanelActor = nil;
		end
	end end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessItemShopControlPanelUI()
	local showIdle = true;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player);

		if act and MovableMan:IsActor(act) and act.PresetName == "Item Shop Control Panel" then
			showIdle = false;
			local pos = act.Pos;

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

			local itemSelected = self.ItemShopSelectedItem;
			local mode = self.ItemShopControlMode;

			if cont:IsState(Controller.PRESS_LEFT) then
				mode = mode - 1;
				itemSelected = 1;
			end

			if cont:IsState(Controller.PRESS_RIGHT) then
				mode = mode + 1;
				itemSelected = 1;
			end

			if mode > self.ItemShopControlPanelModes.BOMB then
				mode = self.ItemShopControlPanelModes.EVERYTHING;
			end

			if mode < self.ItemShopControlPanelModes.EVERYTHING then
				mode = self.ItemShopControlPanelModes.BOMB;
			end

			self.ItemShopControlMode = mode;

			if up then
				itemSelected = itemSelected - 1;
			end

			if down then
				itemSelected = itemSelected + 1;
			end

			if itemSelected < 1 then
				itemSelected = #self.ItemShopFilters[mode];
			end

			if itemSelected > #self.ItemShopFilters[mode] then
				itemSelected = 1;
			end

			local menuPalette = CF.MenuNormalIdle;
				
			local highBarLeftText = "";
			local highBarCenterText = self.ItemShopControlPanelModesTexts[mode];
			local highBarRightText = "";
			local highBarPalette = CF.MenuNormalIdle;

			local lowBarCenterText = "L/R - Change filter, U/D - Select, FIRE - Buy";
			local lowBarPalette = CF.MenuNormalIdle;
				
			local linesPerPage = 12;
			local topOfPage = -68;

			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 70, pos.X, pos.Y + 70, menuPalette);

			if self.ItemShopTradeStar then
				local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_ItemShop_Description.png";
				PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(91, 0), path, 0, false, false);
			elseif self.ItemShopBlackMarket then
				local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_ItemBlackMarket_Description.png";
				PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(91, 0), path, 0, false, false);
			end

			local index = self.ItemShopFilters[mode][itemSelected];
			local item = self.ItemShopItems[index];
			local isBomb = item and item.Type == CF.WeaponTypes.BOMB;
			local category, usage, capacity;

			if isBomb or mode == self.ItemShopControlPanelModes.BOMB then
				category = "Bombs storage: ";
				usage = CF.CountUsedBombsInArray(self.Bombs);
				capacity = tonumber(self.GS["PlayerVesselBombStorage"]);
			else
				category = "Items storage: ";
				usage = CF.CountUsedStorageInArray(self.StorageItems);
				capacity = tonumber(self.GS["PlayerVesselStorageCapacity"]);
			end

			if cont:IsState(Controller.WEAPON_FIRE) then
				if not self.FirePressed[player] then
					self.FirePressed[player] = true

					local index = self.ItemShopFilters[mode][itemSelected];
					local item = self.ItemShopItems[index];

					if item then
						if item.Price <= CF.GetPlayerGold(self.GS, 0) then
							if usage < capacity then
								if item.Type == CF.WeaponTypes.BOMB then
									CF.PutBombToStorageArray(self.Bombs, item.Preset, item.Class, item.Module);
									CF.SetBombsArray(self.GS, self.Bombs);
								else
									CF.PutItemToStorageArray(self.StorageItems, item.Preset, item.Class, item.Module);
									CF.SetStorageArray(self.GS, self.StorageItems);
									self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true);
								end

								CF.ChangePlayerGold(self.GS, -item.Price);
							else
								self.ClonesShopControlMessageTime = self.Time;
								self.ClonesShopControlMessageText = "No space within item storage.";
							end
						else
							self.ClonesShopControlMessageTime = self.Time;
							self.ClonesShopControlMessageText = "Insufficient funds for purchase.";
						end
					else
						self.ClonesShopControlMessageTime = self.Time;
						self.ClonesShopControlMessageText = "No items for purchase.";
					end
				end
			else
				self.FirePressed[player] = false
			end

			local lineOffset = topOfPage;

			-- Print capacity
			CF.DrawString(category, pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0);
			CF.DrawString(usage .. " / " .. capacity, pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2);
			lineOffset = lineOffset + 22;
			
			local itemsPerPage = self.ItemShopControlPanelItemsPerPage;
			local listStart = itemSelected - (itemSelected - 1) % itemsPerPage;

			-- Draw items list
			for i = listStart, listStart + itemsPerPage - 1 do
				local item = self.ItemShopItems[self.ItemShopFilters[mode][i]];
				
				if item then
					local prefix = i == itemSelected and "> " or "";
					CF.DrawString(prefix .. item.Preset, pos + Vector(-138, lineOffset), 90, 11, nil, nil, 0);

					local price = item.Price;
					local digits = math.ceil(math.log10(price)) - 3;
					price = math.floor(price / math.pow(10, digits)) * math.pow(10, digits);
					price = math.ceil(price) .. (price >= 1000 and "k" or "");
					CF.DrawString("\198 " .. price .. " oz", pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 11;
				end
			end

			if item then
				local displayPreset = ToMOSprite(PresetMan:GetPreset(item.Class or "HDFirearm", item.Preset, item.Module));
				local sellCoeff = blackMarket and math.sqrt(CF.SellPriceCoeff) or CF.SellPriceCoeff;
				local description, manufacturer, price;
				local f, i = CF.FindItemInFactions(item.Preset, item.Class or "HDFirearm");

				if f and i then
					description = CF.ItmDescriptions[f][i];
					manufacturer = CF.FactionNames[f];
					price = math.floor(CF.ItmPrices[f][i] * sellCoeff);
				else
					description = displayPreset.Description;
					manufacturer = "Unknown";
					price = math.floor(CF.UnknownItemPrice * sellCoeff);
				end

				local lineOffset = topOfPage;

				if displayPreset then
					lineOffset = lineOffset + 22;
					local drawPos = pos + Vector(90, lineOffset);
					local palette = discarding and CF.MenuDeniedMouseOver or CF.MenuSelectIdle;
					CF.DrawMenuBox(Activity.PLAYER_NONE, drawPos.X - 87, drawPos.Y - 22, drawPos.X + 88, drawPos.Y + 23, palette);
					PrimitiveMan:DrawBitmapPrimitive(drawPos, displayPreset, 0, 0);

					if manufacturer ~= nil then
						local text = "Manufacturer: " .. manufacturer;
						CF.DrawString(text, pos + Vector(6, topOfPage + 1), 175, 11, true, nil);
					end

					lineOffset = lineOffset + 22;
				end

				if discarding then
					if selling then
						if price ~= nil then
							local text = "Market Value: " .. price .. " oz";
							CF.DrawString(text, pos + Vector(92, lineOffset + 3), 175, 11, true, nil, 1);
							lineOffset = lineOffset + 11;
						end
					end
				end

				-- Print description
				local text = description or "--Description Unavailable--";
				text = CF.SplitStringToFitWidth(text, 165, false)
				CF.DrawString(text, pos + Vector(92, (lineOffset - topOfPage) / 2), 175, 88, nil, nil, 1, 1);
			end

			if self.ItemShopControlMessageText then
				if self.Time <= self.ItemShopControlMessageTime + self.ItemShopControlMessagePeriod then
					lowBarPalette = CF.MenuDeniedIdle;
					lowBarCenterText = self.ItemShopControlMessageText;
				end
			end

			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 77 - 7, pos.X + 180, pos.Y - 77 + 6, highBarPalette);
			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y + 78 - 7, pos.X + 180, pos.Y + 78 + 6, lowBarPalette);

			CF.DrawString(highBarLeftText, pos + Vector(-138, -77), 316, 11, nil, nil, 0, 1);
			CF.DrawString(highBarCenterText, pos + Vector(20, -77), 316, 11, nil, nil, 1, 1);
			CF.DrawString(highBarRightText, pos + Vector(178, -77), 316, 11, nil, nil, 2, 1);

			CF.DrawString(lowBarCenterText, pos + Vector(20, 78), 316, 11, nil, nil, 1, 1);

			self.ItemShopSelectedItem = itemSelected;
		end
	end

	if showIdle and MovableMan:ValidMO(self.ItemShopControlPanelActor) and self.ItemShopControlPanelActor.Team == Activity.TEAM_1 then
		local player = Activity.PLAYER_NONE;
		local pos = self.ItemShopControlPanelActor.Pos;
		local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_ItemShop.png";
		PrimitiveMan:DrawBitmapPrimitive(player, pos, path, 0, false, false);
	end

	if MovableMan:IsActor(self.ItemShopControlPanelActor) then
		self.ItemShopControlPanelActor.Health = 100
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
