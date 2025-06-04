-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitCloneShopControlPanelUI()
	-- CloneShop Control Panel
	local x, y;

	x = tonumber(self.SceneConfig["CloneShopControlPanelX"]);
	y = tonumber(self.SceneConfig["CloneShopControlPanelY"]);

	if x ~= nil and y ~= nil then
		self.CloneShopControlPanelPos = Vector(x, y);
	else
		self.CloneShopControlPanelPos = nil;
	end

	if self.CloneShopControlPanelPos ~= nil then
		self:LocateCloneShopControlPanelActor();

		if not MovableMan:ValidMO(self.CloneShopControlPanelActor) then
			self.CloneShopControlPanelActor = CreateActor("Clone Shop Control Panel");

			self.CloneShopControlPanelActor.Pos = self.CloneShopControlPanelPos;
			self.CloneShopControlPanelActor.Team = CF.PlayerTeam;

			MovableMan:AddActor(self.CloneShopControlPanelActor);
		end
	end

	-- Init variables
	self.CloneShopControlPanelItemsPerPage = 10;
	self.CloneShopControlPanelModes = { EVERYTHING = -1, LIGHT = 0, HEAVY = 1, ARMOR = 2, TURRET = 3 };

	texts = {};
	texts[self.CloneShopControlPanelModes.EVERYTHING] = "All bodies";
	texts[self.CloneShopControlPanelModes.LIGHT] = "Light bodies";
	texts[self.CloneShopControlPanelModes.HEAVY] = "Heavy bodies";
	texts[self.CloneShopControlPanelModes.ARMOR] = "Armored bodies";
	texts[self.CloneShopControlPanelModes.TURRET] = "Turrets";
	self.CloneShopControlPanelModesTexts = texts;

	self.ClonesShopControlMessageTime = -1;
	self.ClonesShopControlMessagePeriod = 3;
	self.ClonesShopControlMessageText = "";

	self.CloneShopControlMode = self.CloneShopControlPanelModes.EVERYTHING;
	self.CloneShopSelectedClone = 1;

	self.CloneShopTradeStar = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR);
	self.CloneShopBlackMarket = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET);

	if self.CloneShopTradeStar then
		self.CloneShopItems, self.CloneShopFilters = CF.GetCloneShopArray(self.GS, true);
	end

	if self.CloneShopBlackMarket then
		self.CloneShopItems, self.CloneShopFilters = CF.GetCloneBlackMarketArray(self.GS, true);
	end
end
-----------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------
function VoidWanderers:LocateCloneShopControlPanelActor()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Clone Shop Control Panel" then
			self.CloneShopControlPanelActor = actor;
			break;
		end
	end end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyCloneShopControlPanelUI()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Clone Shop Control Panel" then
			actor.ToDelete = true;
		end
	end end
	
	self.CloneShopControlPanelActor = nil;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessCloneShopControlPanelUI()
	local showIdle = true;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player);

		if act and MovableMan:IsActor(act) and act.PresetName == "Clone Shop Control Panel" then
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

			local itemSelected = self.CloneShopSelectedClone;
			local mode = self.CloneShopControlMode;

			if cont:IsState(Controller.PRESS_LEFT) then
				mode = mode - 1;
				itemSelected = 1;
			end

			if cont:IsState(Controller.PRESS_RIGHT) then
				mode = mode + 1;
				itemSelected = 1;
			end

			if mode > self.CloneShopControlPanelModes.TURRET then
				mode = self.CloneShopControlPanelModes.EVERYTHING;
			end

			if mode < self.CloneShopControlPanelModes.EVERYTHING then
				mode = self.CloneShopControlPanelModes.TURRET;
			end

			self.CloneShopControlMode = mode;

			if up then
				itemSelected = itemSelected - 1;
			end

			if down then
				itemSelected = itemSelected + 1;
			end

			if itemSelected < 1 then
				itemSelected = #self.CloneShopFilters[mode];
			end

			if itemSelected > #self.CloneShopFilters[mode] then
				itemSelected = 1;
			end

			self.CloneShopSelectedClone = itemSelected;

			local menuPalette = CF.MenuNormalIdle;
				
			local highBarLeftText = "";
			local highBarCenterText = self.CloneShopControlPanelModesTexts[mode];
			local highBarRightText = "";
			local highBarPalette = CF.MenuNormalIdle;

			local lowBarCenterText = "L/R - Change filter, U/D - Select, FIRE - Buy";
			local lowBarPalette = CF.MenuNormalIdle;
				
			local linesPerPage = 12;
			local topOfPage = -68;

			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 70, pos.X, pos.Y + 71, menuPalette);

			if self.CloneShopTradeStar then
				local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_CloneShop_Description.png";
				PrimitiveMan.DrawPrimitives(PrimitiveMan, DrawBlendMode.NoBlend, 080, 080, 080, 080, { BitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(90, 0), path, 0, false, false) });
			elseif self.CloneShopBlackMarket then
				local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_CloneBlackMarket_Description.png";
				PrimitiveMan.DrawPrimitives(PrimitiveMan, DrawBlendMode.NoBlend, 080, 080, 080, 080, { BitmapPrimitive(Activity.PLAYER_NONE, pos + Vector(90, 0), path, 0, false, false) });
			end

			local index = self.CloneShopFilters[mode][itemSelected];
			local clone = self.CloneShopItems[index];
			local isTurret = clone and clone.Type == CF.ActorTypes.TURRET;
			local category, usage, capacity;

			if isTurret or mode == self.CloneShopControlPanelModes.TURRET then
				category = "Turrets: ";
				usage = CF.CountUsedTurretsInArray(self.Turrets);
				capacity = tonumber(self.GS["PlayerVesselTurretStorage"]);
			else
				category = "Capacity: ";
				usage = CF.CountUsedClonesInArray(self.Clones);
				capacity = tonumber(self.GS["PlayerVesselClonesCapacity"]);
			end

			if cont:IsState(Controller.WEAPON_FIRE) then
				if not self.firePressed[player] then
					self.firePressed[player] = true;

					if clone then
						if clone.Price <= CF.GetPlayerGold(self.GS, 0) then
							if usage < capacity then
								if isTurret then
									CF.PutTurretToStorageArray(self.Turrets, clone.Preset, clone.Class, clone.Module);
									CF.SetTurretsArray(self.GS, self.Turrets);
								else
									local unit = {};
									unit.Preset = clone.Preset;
									unit.Class = clone.Class;
									unit.Module = clone.Module;
									unit.Items = {};
									table.insert(self.Clones, unit);

									CF.SetClonesArray(self.GS, self.Clones);
								end

								CF.ChangePlayerGold(self.GS, -clone.Price);
							else
								self.ClonesShopControlMessageTime = tonumber(self.GS["Time"]);
								self.ClonesShopControlMessageText = "No space within clone storage.";
							end
						else
							self.ClonesShopControlMessageTime = tonumber(self.GS["Time"]);
							self.ClonesShopControlMessageText = "Can not afford.";
						end
					else
						self.ClonesShopControlMessageTime = tonumber(self.GS["Time"]);
						self.ClonesShopControlMessageText = "No clones for purchase.";
					end
				end
			else
				self.firePressed[player] = false;
			end

			local lineOffset = topOfPage;

			-- Print capacity
			CF.DrawString(category, pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0);
			CF.DrawString(usage .. " / " .. capacity, pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2);
			lineOffset = lineOffset + 22;

			local itemsPerPage = self.CloneShopControlPanelItemsPerPage;
			local listStart = itemSelected - (itemSelected - 1) % itemsPerPage;

			-- Draw items list
			for i = listStart, listStart + itemsPerPage - 1 do
				local clone = self.CloneShopItems[self.CloneShopFilters[mode][i]];
				
				if clone then
					local prefix = i == itemSelected and "> " or "";
					CF.DrawString(prefix .. clone.Preset, pos + Vector(-138, lineOffset), 90, 11, nil, nil, 0);
					CF.DrawString("\198 " .. CF.FormatLargeQuantity(clone.Price) .. " oz", pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 11;
				end
			end

			local lineOffset = topOfPage;

			if clone then
				-- Print item name
				local text = clone.Preset;
				CF.DrawString(text, pos + Vector(90, lineOffset), 175, 11, false, nil, 1);
				lineOffset = lineOffset + 14;

				-- Print manufacturer
				local text = "Manufacturer: " .. (CF.FactionNames[clone.Faction] or "Unknown");
				CF.DrawString(text, pos + Vector(90, lineOffset), 175, 11, true, nil, 1);
				lineOffset = lineOffset + 8;

				-- Print description
				local text = CF.SplitStringToFitWidth(clone.Description, 155, false);
				CF.DrawString(text, pos + Vector(12, lineOffset), 155, 110, nil, nil, 0, 0);
			end

			if self.ClonesShopControlMessageText then
				if tonumber(self.GS["Time"]) <= self.ClonesShopControlMessageTime + self.ClonesShopControlMessagePeriod then
					lowBarPalette = CF.MenuDeniedIdle;
					lowBarCenterText = self.ClonesShopControlMessageText;
				end
			end

			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 77 - 7, pos.X + 181, pos.Y - 77 + 7, highBarPalette);
			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y + 78 - 7, pos.X + 181, pos.Y + 78 + 7, lowBarPalette);

			CF.DrawString(highBarLeftText, pos + Vector(-138, -77), 316, 11, nil, nil, 0, 1);
			CF.DrawString(highBarCenterText, pos + Vector(20, -77), 316, 11, nil, nil, 1, 1);
			CF.DrawString(highBarRightText, pos + Vector(178, -77), 316, 11, nil, nil, 2, 1);

			CF.DrawString(lowBarCenterText, pos + Vector(20, 78), 316, 11, nil, nil, 1, 1);
		end
	end
	
	if showIdle and MovableMan:ValidMO(self.CloneShopControlPanelActor) and self.CloneShopControlPanelActor.Team == Activity.TEAM_1 then
		local player = Activity.PLAYER_NONE;
		local pos = self.CloneShopControlPanelActor.Pos;
		local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_CloneShop.png";
		PrimitiveMan.DrawPrimitives(PrimitiveMan, DrawBlendMode.NoBlend, 080, 080, 080, 080, { BitmapPrimitive(player, pos, path, 0, false, false) });
	end

	if MovableMan:IsActor(self.CloneShopControlPanelActor) then
		self.CloneShopControlPanelActor.Health = 100;
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
