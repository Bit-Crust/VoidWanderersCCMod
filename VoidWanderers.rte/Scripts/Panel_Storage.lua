-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitStorageControlPanelUI()
	local x, y;
	x = tonumber(self.SceneConfig["StorageControlPanelX"]);
	y = tonumber(self.SceneConfig["StorageControlPanelY"]);

	if x and y then
		self.StorageControlPanelPos = Vector(x, y);
	else
		self.StorageControlPanelPos = nil;
	end

	local left, top, right, bottom;
	left = tonumber(self.SceneConfig["StorageInputLeft"]);
	top = tonumber(self.SceneConfig["StorageInputTop"])
	right = tonumber(self.SceneConfig["StorageInputRight"]);
	bottom = tonumber(self.SceneConfig["StorageInputBottom"]);

	if left and top and right and bottom then
		self.StorageInputBox = Box(left, top, right, bottom);
	else
		self.StorageInputBox = nil;
	end

	if self.StorageControlPanelPos ~= nil then
		self:LocateStorageControlPanelActor();

		if not MovableMan:IsActor(self.StorageControlPanelActor) then
			self.StorageControlPanelActor = CreateActor("Storage Control Panel");

			self.StorageControlPanelActor.Pos = self.StorageControlPanelPos;
			self.StorageControlPanelActor.Team = CF.PlayerTeam;

			MovableMan:AddActor(self.StorageControlPanelActor);
		end
	end

	--[[Crate debug
	local crt = CreateMOSRotating("Case", self.ModuleName)
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

	-- Init variables
	self.StorageControlPanelItemsPerPage = 10
	self.StorageInputRange = 150
	self.StorageInputDelay = 3
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
	
	self.StorageControlMessageTime = -1;
	self.StorageControlMessagePeriod = 3;
	self.StorageControlMessageText = "";

	self.StorageControlMode = self.StorageControlPanelModes.EVERYTHING;
	self.StorageSelectedItem = 1;

	self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true)
	self.Bombs = CF.GetBombsArray(self.GS)
end
-----------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------
function VoidWanderers:LocateStorageControlPanelActor()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Storage Control Panel" then
			self.StorageControlPanelActor = actor;
			break;
		end
	end end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyStorageControlPanelUI()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Storage Control Panel" then
			actor.ToDelete = true;
		end
	end end
	
	self.StorageControlPanelActor = nil;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessStorageControlPanelUI()
	local showIdle = true;

	if self.StorageControlPanelActor then
		local pos = self.StorageControlPanelPos;

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local act = self:GetControlledActor(player);

			if act and act.PresetName == "Storage Control Panel" then
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

				local itemSelected = self.StorageSelectedItem;
				local mode = self.StorageControlMode;

				if cont:IsState(Controller.PRESS_LEFT) then
					mode = mode - 1
					itemSelected = 1

					if mode == self.StorageControlPanelModes.SELL - 1 then
						mode = self.StorageControlPanelModes.TOOL
					end
				end

				if cont:IsState(Controller.PRESS_RIGHT) then
					mode = mode + 1
					itemSelected = 1

					if mode == self.StorageControlPanelModes.TOOL + 1 then
						mode = self.StorageControlPanelModes.SELL
					end
				end

				if up then
					if #self.StorageFilters[mode] > 0 then
						itemSelected = itemSelected - 1;

						if itemSelected < 1 then
							itemSelected = #self.StorageFilters[mode];
						end
					end
				end

				if down then
					if #self.StorageFilters[mode] > 0 then
						itemSelected = itemSelected + 1

						if itemSelected > #self.StorageFilters[mode] then
							itemSelected = 1
						end
					end
				end

				local menuPalette = CF.MenuNormalIdle;
				
				local highBarLeftText = "";
				local highBarCenterText = "";
				local highBarRightText = "";
				local highBarPalette = CF.MenuNormalIdle;

				local lowBarCenterText = "";
				local lowBarPalette = CF.MenuNormalIdle;
				
				local linesPerPage = 12;
				local topOfPage = -68;
				
				lowBarCenterText = "L/R - Change filter, U/D - Select, FIRE - Dispense";

				-- Sell mode UI shift
				local discarding = mode == self.StorageControlPanelModes.SELL;
				local blackMarket = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET);
				local tradeStar = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR);
				local selling = tradeStar or blackMarket;
				if discarding then
					menuPalette = CF.MenuDeniedIdle;
					highBarPalette = CF.MenuDeniedIdle;
					lowBarPalette = CF.MenuDeniedIdle;

					if selling then
						lowBarCenterText = "L/R - Change filter, U/D - Select, FIRE - Sell";
						highBarLeftText = "SELL ITEMS";
						highBarRightText = CF.GetPlayerGold(self.GS, 0) .. " oz";
					else
						lowBarCenterText = "L/R - Change filter, U/D - Select, FIRE - Dump";
						highBarLeftText = "DUMP ITEMS";
					end
				else
					highBarLeftText = self.StorageControlPanelModesTexts[mode];
				end

				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 70, pos.X + 0, pos.Y + 70, menuPalette);
				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X + 1, pos.Y - 70, pos.X + 180, pos.Y + 70, menuPalette);

				-- Because StorageFilters may change outside of this panel by other players always check for out-of-bounds
				if itemSelected > #self.StorageFilters[mode] and #self.StorageFilters[mode] > 0 then
					itemSelected = #self.StorageFilters[mode]
				end

				-- Dispense/sell/dump items
				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true;

						local index = self.StorageFilters[mode][itemSelected];
						local item = self.StorageItems[index];

						if item then
							if not discarding then
								local foundActor = nil;

								for actor in MovableMan.Actors do
									local closeEnough = CF.Dist(actor.Pos, self.StorageInputBox.Center) < self.StorageInputRange;

									if closeEnough and actor.ClassName == "AHuman" then
										foundActor = actor;
										break;
									end
								end

								local item = CF.MakeItem(item.Class, item.Preset, item.Module);

								if item ~= nil then
									if foundActor then
										foundActor:AddInventoryItem(item);
										foundActor:FlashWhite(100);
									else
										item.Pos = self.StorageInputBox.Center;
										MovableMan:AddItem(item);
									end
								end
							else
								if selling then
									local sellCoeff = blackMarket and math.sqrt(CF.SellPriceCoeff) or CF.SellPriceCoeff;
									local price;
									local f, i = CF.FindItemInFactions(item.Preset, item.Class or "HDFirearm");

									if f and i then
										price = math.floor(CF.ItmPrices[f][i] * sellCoeff);
									else
										price = math.floor(CF.UnknownItemPrice * sellCoeff);
									end
									
									CF.ChangePlayerGold(self.GS, price);
								end
							end

							item.Count = item.Count - 1;
							CF.SetStorageArray(self.GS, self.StorageItems);
							if item.Count == 0 then
								self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true);
							end
						else
							self.StorageControlMessageText = "No item to dispense.";
							self.StorageControlMessageTime = self.Time;
						end
					end
				else
					self.FirePressed[player] = false
				end
				
				local lineOffset = topOfPage;

				local text = "Capacity: " .. CF.CountUsedStorageInArray(self.StorageItems) .. "/" .. self.GS["PlayerVesselStorageCapacity"];
				CF.DrawString(text, pos + Vector(-138, topOfPage), 135, 11)
				lineOffset = lineOffset + 22;

				local itemsPerPage = self.StorageControlPanelItemsPerPage
				local listStart = itemSelected - (itemSelected - 1) % itemsPerPage

				for i = listStart, listStart + itemsPerPage - 1 do
					if i <= #self.StorageFilters[mode] then
						local index = self.StorageFilters[mode][i]
						local loc = i - listStart
						local preset = self.StorageItems[index].Preset;
						local count = tostring(self.StorageItems[index].Count);
						local prefix = i == itemSelected and "> " or "";

						CF.DrawString(count, pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2)
						CF.DrawString(prefix .. preset, pos + Vector(-138, lineOffset), 120, 11)
						lineOffset = lineOffset + 11;
					end
				end

				-- Get selected item info
				local index = self.StorageFilters[mode][itemSelected];
				local item = self.StorageItems[index];

				if item then
					-- Get item description
					local displayPreset = ToMOSprite(PresetMan:GetPreset(item.Class or "HDFirearm", item.Preset, item.Module));
					local sellCoeff = blackMarket and math.sqrt(CF.SellPriceCoeff) or CF.SellPriceCoeff;
					local description, manufacturer, price;
					local f, i = CF.FindItemInFactions(item.Preset, item.Class or "HDFirearm");

					if f and i then
						description = CF.ItmDescriptions[f][i];
						manufacturer = CF.FactionNames[f];
						price = math.floor(CF.ItmPrices[f][i] * sellCoeff);
					else
						description = displayPreset and displayPreset.Description ~= "" and displayPreset.Description or nil;
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
								local text = "Market Value: \213 " .. price .. " oz";
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

				if self.StorageControlMessageText then
					if self.Time <= self.StorageControlMessageTime + self.StorageControlMessagePeriod then
						lowBarPalette = CF.MenuDeniedIdle;
						lowBarCenterText = self.StorageControlMessageText;
					end
				end

				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 77 - 7, pos.X + 180, pos.Y - 77 + 6, highBarPalette);
				CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y + 78 - 7, pos.X + 180, pos.Y + 78 + 6, lowBarPalette);

				CF.DrawString(highBarLeftText, pos + Vector(-138, -77), 316, 11, nil, nil, 0, 1);
				CF.DrawString(highBarCenterText, pos + Vector(20, -77), 316, 11, nil, nil, 1, 1);
				CF.DrawString(highBarRightText, pos + Vector(178, -77), 316, 11, nil, nil, 2, 1);

				CF.DrawString(lowBarCenterText, pos + Vector(20, 78), 316, 11, nil, nil, 1, 1);

				self.StorageSelectedItem = itemSelected;
				self.StorageControlMode = mode;
			end
		end
	end
	
	if showIdle and MovableMan:ValidMO(self.StorageControlPanelActor) and self.StorageControlPanelActor.Team == Activity.TEAM_1 then
		local player = Activity.PLAYER_NONE;
		local pos = self.StorageControlPanelActor.Pos;
		local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Storage.png";
		PrimitiveMan.DrawPrimitives(PrimitiveMan, DrawBlendMode.NoBlend, 080, 080, 080, 080, { BitmapPrimitive(player, pos, path, 0, false, false) });

		local text = "Capacity: " .. CF.CountUsedStorageInArray(self.StorageItems) .. " / " .. self.GS["PlayerVesselStorageCapacity"];
		CF.DrawString(text, pos + Vector(0, -40), 100, 11, nil, nil, 1);
	end

	-- Process weapons input
	if self.StorageInputBox ~= nil and self.StorageControlPanelActor ~= nil then
		--PrimitiveMan:DrawBoxPrimitive(Activity.PLAYER_NONE, self.StorageInputBox.Corner, self.StorageInputBox.Corner + (self.StorageInputBox.Center - self.StorageInputBox.Corner) * 2, 5)
		local count = CF.CountUsedStorageInArray(self.StorageItems);

		if count < tonumber(self.GS["PlayerVesselStorageCapacity"]) then
			local foundItem = nil;

			for item in MovableMan.Items do
				if IsHeldDevice(item) and self.StorageInputBox:IsWithinBox(item.Pos) and self.vesselData["ship"]:IsInside(item.Pos) then
					item = ToHeldDevice(item);

					if IsHDFirearm(item) then
						item = ToHDFirearm(item);
					elseif IsTDExplosive(item) then
						item = ToTDExplosive(item);
					end

					local activated = item:IsActivated();

					if not item.UnPickupable and not activated then
						foundItem = item;
					end
				end
			end

			if foundItem then
				if not self.StorageLastDetectedItemTime then
					self.StorageLastDetectedItemTime = self.Time;
				end
				
				local timeLeft = (self.StorageLastDetectedItemTime + self.StorageInputDelay - self.Time);

				if showIdle then
					local text = "Store in " .. timeLeft;
					self:AddObjectivePoint(text, foundItem.Pos + Vector(0, -40), CF.PlayerTeam, GameActivity.ARROWDOWN);
				end
				
				if timeLeft <= 0 then
					local needrefresh = CF.PutItemToStorageArray(self.StorageItems, foundItem.PresetName, foundItem.ClassName, foundItem.ModuleName);
					CF.SetStorageArray(self.GS, self.StorageItems);
					self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true);

					foundItem.ToDelete = true;
					self.StorageLastDetectedItemTime = nil;
				end
			else
				self.StorageLastDetectedItemTime = nil;
			end
		end
	end

	if MovableMan:IsActor(self.StorageControlPanelActor) then
		self.StorageControlPanelActor.Health = 100;
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
