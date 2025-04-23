-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitClonesControlPanelUI()
	local x, y;

	x = tonumber(self.SceneConfig["ClonesControlPanelX"]);
	y = tonumber(self.SceneConfig["ClonesControlPanelY"]);

	if x ~= nil and y ~= nil then
		self.ClonesControlPanelPos = Vector(x, y);
	else
		self.ClonesControlPanelPos = nil;
	end

	x = tonumber(self.SceneConfig["ClonesDeployX"])
	y = tonumber(self.SceneConfig["ClonesDeployY"]);

	if x ~= nil and y ~= nil then
		self.ClonesDeployPos = Vector(x, y);
	else
		self.ClonesDeployPos = nil;
	end

	x = tonumber(self.SceneConfig["ClonesInputX"]);
	y = tonumber(self.SceneConfig["ClonesInputY"]);

	if x ~= nil and y ~= nil then
		self.ClonesInputPos = Vector(x, y);
	else
		self.ClonesInputPos = nil;
	end

	if self.ClonesControlPanelPos ~= nil then
		self:LocateClonesControlPanelActor();

		if not MovableMan:IsActor(self.ClonesControlPanelActor) then
			self.ClonesControlPanelActor = CreateActor("Clones Control Panel");

			self.ClonesControlPanelActor.Pos = self.ClonesControlPanelPos;
			self.ClonesControlPanelActor.Team = CF.PlayerTeam;

			MovableMan:AddActor(self.ClonesControlPanelActor);
		end
	end

	-- Init variables
	self.ClonesControlPanelModes = {
		SELL = 0,
		CLONES = 1,
		INVENTORY = 2,
		STORAGE = 3
	};
	self.ClonesControlMode = self.ClonesControlPanelModes.CLONES;

	self.ClonesInputDelay = 3;
	self.ClonesInputRange = 35;

	self.ClonesControlMessageTime = -1;
	self.ClonesControlMessagePeriod = 3;
	self.ClonesControlMessageText = "";

	self.ClonesSelectedClone = 1;
	self.ClonesInventorySelectedItem = 1;
	self.ClonesStorageSelectedItem = 1;

	self.ClonesControlPanelLinesPerPage = 10;
	self.ClonesControlPanelModesTexts = {};
	self.ClonesControlPanelModesHelpTexts = {};

	local texts = {};
	texts[self.ClonesControlPanelModes.SELL] = "DISCARD";
	texts[self.ClonesControlPanelModes.CLONES] = "CLONES";
	texts[self.ClonesControlPanelModes.INVENTORY] = "INVENTORY";
	texts[self.ClonesControlPanelModes.STORAGE] = "STORAGE";
	self.ClonesControlPanelModesTexts = texts;

	local texts = {};
	texts[self.ClonesControlPanelModes.SELL] = "L/R/U/D - Select, FIRE - Discard, P/N - Inventory";
	texts[self.ClonesControlPanelModes.CLONES] = "L/R/U/D - Select, FIRE - Deploy, P/N - Inventory";
	texts[self.ClonesControlPanelModes.INVENTORY] = "L/R/U/D - Select, FIRE - Deposit";
	texts[self.ClonesControlPanelModes.STORAGE] = "L/R/U/D - Select, FIRE - Withdraw";
	self.ClonesControlPanelModesHelpTexts = texts;

	self.Clones = CF.GetClonesArray(self.GS)
end
-----------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------
function VoidWanderers:LocateClonesControlPanelActor()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Clones Control Panel" then
			self.ClonesControlPanelActor = actor;
			break;
		end
	end end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyClonesControlPanelUI()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Clones Control Panel" then
			actor.ToDelete = true;
		end
	end end
	
	self.ClonesControlPanelActor = nil;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessClonesControlPanelUI()
	local showIdle = true;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player);

		if act and MovableMan:IsActor(act) and act.PresetName == "Clones Control Panel" then
			showIdle = false;

			local pos = Vector(act.Pos.X, act.Pos.Y);
			local mode = self.ClonesControlMode;

			-- Process direct input
			local cont = act:GetController();
			
			local up = false;
			local down = false;
			local left = false;
			local right = false;

			local prev = false;
			local next = false;

			if cont:IsState(Controller.PRESS_UP) then
				self.HoldTimer[player + 1]:Reset();
				up = true;
			end

			if cont:IsState(Controller.PRESS_DOWN) then
				self.HoldTimer[player + 1]:Reset();
				down = true;
			end

			if cont:IsState(Controller.PRESS_LEFT) then
				left = true;
			end

			if cont:IsState(Controller.PRESS_RIGHT) then
				right = true;
			end

			if cont:IsState(Controller.WEAPON_CHANGE_PREV) then
				prev = true;
			end

			if cont:IsState(Controller.WEAPON_CHANGE_NEXT) then
				next = true;
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

			-- Find bounds for panel modes useable
			local leftBound = self.ClonesControlPanelModes.SELL;
			local rightBound = self.ClonesControlPanelModes.STORAGE;

			if self.GS["Mode"] == "Assault" then
				leftBound = self.ClonesControlPanelModes.CLONES;
			end

			if #self.Clones <= 0 then
				rightBound = self.ClonesControlPanelModes.CLONES;
			end

			-- Process mode switching
			if left then
				mode = mode - 1;
			end

			if right then
				mode = mode + 1;
			end

			if mode <= leftBound - 1 then
				mode = leftBound;
			end

			if mode >= rightBound + 1 then
				mode = rightBound;
			end

			-- Set up default panel displays and UI info
			local menuPalette = CF.MenuNormalIdle;
				
			local highBarLeftText = self.ClonesControlPanelModesTexts[mode];
			local highBarCenterText = "";
			local highBarRightText = "";
			local highBarPalette = CF.MenuNormalIdle;

			local lowBarCenterText = self.ClonesControlPanelModesHelpTexts[mode];
			local lowBarPalette = CF.MenuNormalIdle;
				
			local linesPerPage = 12;
			local topOfPage = -68;

			local isDiscarding = mode == self.ClonesControlPanelModes.SELL;
			local isBrowsingClones = mode == self.ClonesControlPanelModes.CLONES;
			local isBrowsingInventory = mode == self.ClonesControlPanelModes.INVENTORY;
			local isBrowsingStorage = mode == self.ClonesControlPanelModes.STORAGE;

			local isBlackMarket = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.BLACKMARKET);
			local isTradeStar = CF.IsLocationHasAttribute(self.GS["Location"], CF.LocationAttributeTypes.TRADESTAR);
			local isSelling = isTradeStar or isBlackMarket;

			-- Sell mode ui effects
			if isDiscarding then
				menuPalette = CF.MenuDeniedIdle;
				highBarPalette = CF.MenuDeniedIdle;
				lowBarPalette = CF.MenuDeniedIdle;
			end

			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 70, pos.X + 0, pos.Y + 70, menuPalette);
			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X + 1, pos.Y - 70, pos.X + 140, pos.Y + 70, menuPalette);

			if isDiscarding then
				local itemsPerPage = self.ClonesControlPanelLinesPerPage;
				local cloneSelected = self.ClonesSelectedClone;

				if up then
					cloneSelected = cloneSelected - 1;
				end

				if down then
					cloneSelected = cloneSelected + 1;
				end

				if cloneSelected < 1 then
					cloneSelected = #self.Clones;
				end

				if cloneSelected > #self.Clones then
					cloneSelected = 1;
				end

				local cloneValues = {};
				local cloneInventoryValues = {};
				local cloneIndividualValues = {};
				local sellCoeff = isBlackMarket and math.sqrt(CF.SellPriceCoeff) or CF.SellPriceCoeff;

				if isSelling then
					for i = 1, #self.Clones do
						local clone = self.Clones[i];
						local faction, index = CF.FindActorInFactions(clone.Preset, clone.Class or "AHuman");
						local factionValues = CF.ActPrices[faction] or {};
						local value = factionValues[index] or CF.UnknownActorPrice;
						value = value * (1 + (clone.Prestige or 0) + (clone.XP or 0) / 1000);
						table.insert(cloneIndividualValues, math.floor(value * sellCoeff));
						local itemValues = {};

						for i = 1, #clone.Items do
							local item = clone.Items[i];
							local faction, index = CF.FindItemInFactions(item.Preset, item.Class or "HDFirearm");
							local factionValues = CF.ItmPrices[faction] or {};
							local price = factionValues[index] or CF.UnknownItemPrice;
							value = value + price;
							table.insert(itemValues, math.floor(price * sellCoeff));
						end

						table.insert(cloneInventoryValues, itemValues);
						table.insert(cloneValues, math.floor(value * sellCoeff));
					end
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true;

						if cloneSelected ~= 0 then
							if isSelling then
								CF.ChangePlayerGold(self.GS, cloneValues[cloneSelected]);
							end

							table.remove(self.Clones, cloneSelected);
							table.remove(cloneValues, cloneSelected);
							table.remove(cloneInventoryValues, cloneSelected);

							-- Update game state data
							CF.SetClonesArray(self.GS, self.Clones);

							if cloneSelected > #self.Clones then
								cloneSelected = #self.Clones;
							end
						end
					end
				else
					self.FirePressed[player] = false;
				end

				-- Print clone storage capacity
				highBarRightText = "Life support usage: " .. CF.CountActors(CF.PlayerTeam) .. "/" .. self.GS["PlayerVesselLifeSupport"];

				local clone = self.Clones[cloneSelected];

				local lineOffset = topOfPage;
				local text = "Capacity: ";
				CF.DrawString(text, pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0);
				local text = CF.CountUsedClonesInArray(self.Clones) .. "/" .. self.GS["PlayerVesselClonesCapacity"];
				CF.DrawString(text, pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2);
				lineOffset = lineOffset + 22;

				-- Draw clones list
				local listStart = cloneSelected - (cloneSelected - 1) % itemsPerPage;

				for i = listStart, listStart + itemsPerPage - 1 do
					local clone = self.Clones[i];

					if clone then
						local name = self.Clones[i].Name ~= "" and self.Clones[i].Name or self.Clones[i].Preset;
						local prefix = i == cloneSelected and "> " or "";
						CF.DrawString(prefix .. name, pos + Vector(-138, lineOffset), 135, 11);
						
						if isSelling then
							local prefix = "\198 " .. tostring(cloneValues[i]) .. " oz";
							CF.DrawString(prefix, pos + Vector(-2, lineOffset), 135, 11, false, nil, 2);
						end

						lineOffset = lineOffset + 11;
					end
				end

				local lineOffset = topOfPage;

				if clone then
					local itemSelected = self.ClonesInventorySelectedItem;

					if prev then
						itemSelected = itemSelected - 10;
					end

					if next then
						itemSelected = itemSelected + 10;
					end

					if itemSelected < 1 then
						itemSelected = #clone.Items;
					end

					if itemSelected > #clone.Items then
						itemSelected = 1;
					end

					local head = clone.Head ~= "Null";
					local fgArm = clone.FGArm ~= "Null";
					local bgArm = clone.BGArm ~= "Null";
					local fgLeg = clone.FGLeg ~= "Null";
					local bgLeg = clone.BGLeg ~= "Null";
					local xp = tonumber(clone.XP) or 0;
					local prestige = tonumber(clone.Prestige) or 0;
					local name = clone.Name ~= "" and clone.Name or clone.Preset;
					local rank = 0;

					if xp > 0 then
						local showRank = #CF.Ranks;

						for rank = 1, #CF.Ranks do
							if xp < CF.Ranks[rank] then
								showRank = rank - 1;
								break;
							end
						end

						rank = showRank;
					end

					if rank ~= 0 or prestige ~= 0 then
						CF.DrawRankIcon(Activity.PLAYER_NONE, pos + Vector(9, lineOffset + 9), rank, prestige);
					end

					local text;
					text = name;
					CF.DrawString(text, pos + Vector(94, lineOffset), 135, 11, nil, nil, 1);
					lineOffset = lineOffset + 16;
					text = "Inventory: ";
					CF.DrawString(text, pos + Vector(50, lineOffset), 135, 11, nil, nil, 0);
					text = #clone.Items .. "/" .. CF.MaxStoredActorInventory;
					CF.DrawString(text, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 11;
					text = "Rank: ";
					CF.DrawString(text, pos + Vector(50, lineOffset), 135, 11, nil, nil, 0);
					text = tostring(rank);
					CF.DrawString(text, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 11;
					text = "Prestige: ";
					CF.DrawString(text, pos + Vector(50, lineOffset), 135, 11, nil, nil, 0);
					text = tostring(prestige);
					CF.DrawString(text, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 16;

					local bodyCenter = pos + Vector(26, -40);
					local path = "Mods/VoidWanderers.rte/UI/Generic/HumanTorsoSymbol.png";
					PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter, path, 0, false, false);

					if head then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanHeadSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(0, -18), path, 0, false, false);
					end

					if fgArm then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanFGArmSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(-12, -5), path, 0, false, false);
					end

					if bgArm then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanBGArmSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(12, -5), path, 0, false, false);
					end

					if fgLeg then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanFGLegSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(-5, 14), path, 0, false, false);
					end

					if bgLeg then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanBGLegSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(5, 14), path, 0, false, false);
					end

					local listings = cloneInventoryValues[cloneSelected];
					if #clone.Items > 0 then
						local listStart = itemSelected - (itemSelected - 1) % itemsPerPage;

						for i = listStart, listStart + itemsPerPage - 1 do
							local item = clone.Items[i];

							if item then
								CF.DrawString(item.Preset, pos + Vector(4, lineOffset), 135, 11, true, nil, 0);
							
								if isSelling then
									CF.DrawString("\213 " .. listings[i] .. " oz", pos + Vector(138, lineOffset), 135, 11, true, nil, 2);
								end

								lineOffset = lineOffset + 8;
							end
						end
					else
						CF.DrawString("-- NO ITEMS --", pos + Vector(70, (lineOffset - topOfPage) / 2), 135, 11, true, nil, 1, 1);
					end

					self.ClonesInventorySelectedItem = itemSelected;
				else
					CF.DrawString("-- NO CLONES --", pos + Vector(70, 0), 135, 11, nil, nil, 1, 1);
				end

				self.ClonesSelectedClone = cloneSelected;
			elseif isBrowsingClones then
				local itemsPerPage = self.ClonesControlPanelLinesPerPage;
				local cloneSelected = self.ClonesSelectedClone;

				if up then
					cloneSelected = cloneSelected - 1;
				end

				if down then
					cloneSelected = cloneSelected + 1;
				end

				if cloneSelected < 1 then
					cloneSelected = #self.Clones;
				end

				if cloneSelected > #self.Clones then
					cloneSelected = 1;
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true;

						if #self.Clones ~= 0 then
							if CF.CountActors(CF.PlayerTeam) < tonumber(self.GS["PlayerVesselLifeSupport"]) then
								local clone = self.Clones[cloneSelected];

								local limbData = {};

								for _, limbName in ipairs(CF.LimbIDs[clone.Class]) do
									limbData[limbName] = clone[limbName];
								end

								local actor = CF.MakeActor(
									clone.Class,
									clone.Preset,
									clone.Module,
									clone.XP,
									clone.Identity,
									clone.Player,
									clone.Prestige,
									clone.Name,
									limbData
								);

								if actor ~= nil then
									actor.Team = CF.PlayerTeam;
									actor.AIMode = Actor.AIMODE_SENTRY;

									for i = 1, #clone.Items do
										local item = clone.Items[i];
										local item = CF.MakeItem(item.Class, item.Preset, item.Module);

										if item ~= nil then
											if item:HasScript(CF.ModuleName .. "/Items/Limb.lua") and CF.AttemptReplaceLimb(actor, item) then
												DeleteEntity(item);
											else
												actor:AddInventoryItem(item);
											end
										else
											self.ClonesControlMessageTime = self.Time;
											self.ClonesControlMessageText = "Can't create item. Very bad.";
										end
									end

									if IsAHuman(actor) and ToAHuman(actor).Head == nil then
										actor.DeathSound = nil;
										actor.Status = Actor.DEAD;
									end

									actor.Pos = self.ClonesDeployPos or self.ClonesControlPanelPos;
									actor.RestThreshold = -1;
									MovableMan:AddActor(actor);
									self:AddPreEquippedItemsToRemovalQueue(actor);
									table.remove(self.Clones, cloneSelected);
									CF.SetClonesArray(self.GS, self.Clones);

									if cloneSelected < 1 then
										cloneSelected = #self.Clones;
									end

									if cloneSelected > #self.Clones then
										cloneSelected = 1;
									end
								else
									self.ClonesControlMessageTime = self.Time;
									self.ClonesControlMessageText = "Actor could not be created. Very bad.";
								end
							else
								self.ClonesControlMessageTime = self.Time;
								self.ClonesControlMessageText = "Too many units. Upgrade life support.";
							end
						else
							self.ClonesControlMessageTime = self.Time;
							self.ClonesControlMessageText = "Clone storage is empty.";
						end
					end
				else
					self.FirePressed[player] = false;
				end

				-- Change panel text to show life support capacity
				highBarRightText = "Life support usage: " .. CF.CountActors(CF.PlayerTeam) .. "/" .. self.GS["PlayerVesselLifeSupport"];

				local clone = self.Clones[cloneSelected];

				local clonesPerPage = self.ClonesControlPanelLinesPerPage;
				local listStart = cloneSelected - (cloneSelected - 1) % clonesPerPage;
				
				local lineOffset = topOfPage;
				local text = "Capacity: ";
				CF.DrawString(text, pos + Vector(-138, lineOffset), 135, 11, nil, nil, 0);
				local text = CF.CountUsedClonesInArray(self.Clones) .. "/" .. self.GS["PlayerVesselClonesCapacity"];
				CF.DrawString(text, pos + Vector(-2, lineOffset), 135, 11, nil, nil, 2);
				lineOffset = lineOffset + 22;

				-- Draw clones list
				for i = listStart, listStart + clonesPerPage - 1 do
					local clone = self.Clones[i];

					if clone then
						local name = self.Clones[i].Name ~= "" and self.Clones[i].Name or self.Clones[i].Preset;
						local prefix = i == cloneSelected and "> " or "";
						CF.DrawString(prefix .. name, pos + Vector(-138, lineOffset), 135, 11);
						lineOffset = lineOffset + 11;
					end
				end
				
				local lineOffset = topOfPage;

				if clone then
					local itemSelected = self.ClonesInventorySelectedItem;

					if prev then
						itemSelected = itemSelected - 10;
					end

					if next then
						itemSelected = itemSelected + 10;
					end

					if itemSelected < 1 then
						itemSelected = #clone.Items;
					end

					if itemSelected > #clone.Items then
						itemSelected = 1;
					end

					local head = clone.Head ~= "Null";
					local fgArm = clone.FGArm ~= "Null";
					local bgArm = clone.BGArm ~= "Null";
					local fgLeg = clone.FGLeg ~= "Null";
					local bgLeg = clone.BGLeg ~= "Null";
					local xp = tonumber(clone.XP) or 0;
					local prestige = tonumber(clone.Prestige) or 0;
					local name = clone.Name ~= "" and clone.Name or clone.Preset;
					local rank = 0;

					if xp > 0 then
						local showRank = #CF.Ranks;

						for rank = 1, #CF.Ranks do
							if xp < CF.Ranks[rank] then
								showRank = rank - 1;
								break;
							end
						end

						rank = showRank;
					end

					if rank ~= 0 or prestige ~= 0 then
						CF.DrawRankIcon(Activity.PLAYER_NONE, pos + Vector(9, lineOffset + 9), rank, prestige);
					end

					local text;
					text = name;
					CF.DrawString(text, pos + Vector(94, lineOffset), 135, 11, nil, nil, 1);
					lineOffset = lineOffset + 16;
					text = "Inventory: ";
					CF.DrawString(text, pos + Vector(50, lineOffset), 135, 11, nil, nil, 0);
					text = #clone.Items .. "/" .. CF.MaxStoredActorInventory;
					CF.DrawString(text, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 11;
					text = "Rank: ";
					CF.DrawString(text, pos + Vector(50, lineOffset), 135, 11, nil, nil, 0);
					text = tostring(rank);
					CF.DrawString(text, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 11;
					text = "Prestige: ";
					CF.DrawString(text, pos + Vector(50, lineOffset), 135, 11, nil, nil, 0);
					text = tostring(prestige);
					CF.DrawString(text, pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
					lineOffset = lineOffset + 16;

					local bodyCenter = pos + Vector(26, -40);
					local path = "Mods/VoidWanderers.rte/UI/Generic/HumanTorsoSymbol.png";
					PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter, path, 0, false, false);

					if head then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanHeadSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(0, -18), path, 0, false, false);
					end

					if fgArm then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanFGArmSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(-12, -5), path, 0, false, false);
					end

					if bgArm then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanBGArmSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(12, -5), path, 0, false, false);
					end

					if fgLeg then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanFGLegSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(-5, 14), path, 0, false, false);
					end

					if bgLeg then
						local path = "Mods/VoidWanderers.rte/UI/Generic/HumanBGLegSymbol.png";
						PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, bodyCenter + Vector(5, 14), path, 0, false, false);
					end

					if #clone.Items > 0 then
						local listStart = itemSelected - (itemSelected - 1) % itemsPerPage;

						for i = listStart, listStart + itemsPerPage - 1 do
							local item = clone.Items[i];

							if item then
								CF.DrawString(clone.Items[i].Preset, pos + Vector(4, lineOffset), 135, 11, true, nil, 0);
								lineOffset = lineOffset + 8;
							end
						end
					else
						CF.DrawString("-- NO ITEMS --", pos + Vector(70, (lineOffset - topOfPage) / 2), 135, 11, true, nil, 1, 1);
					end

					self.ClonesInventorySelectedItem = itemSelected;
				else
					CF.DrawString("-- NO CLONES --", pos + Vector(70, 0), 135, 11, nil, nil, 1, 1);
				end

				self.ClonesSelectedClone = cloneSelected;
			elseif isBrowsingInventory then
				local itemSelected = self.ClonesInventorySelectedItem;
				local clone = self.Clones[self.ClonesSelectedClone];

				if up then
					itemSelected = itemSelected - 1;
				end

				if down then
					itemSelected = itemSelected + 1;
				end

				if itemSelected < 1 then
					itemSelected = #clone.Items;
				end

				if itemSelected > #clone.Items then
					itemSelected = 1;
				end

				local item = clone.Items[itemSelected];
				
				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true;
						local storageFull = CF.CountUsedStorageInArray(self.StorageItems) >= tonumber(self.GS.PlayerVesselStorageCapacity);

						if not storageFull then
							if #clone.Items > 0 then
								CF.PutItemToStorageArray(self.StorageItems, item.Preset, item.Class, item.Module);
								CF.SetStorageArray(self.GS, self.StorageItems);

								self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true);
								table.remove(clone.Items, itemSelected);
								CF.SetClonesArray(self.GS, self.Clones);

								itemSelected = math.min(#clone.Items, itemSelected);
							else
								self.ClonesControlMessageText = "Clone has no items!";
								self.ClonesControlMessageTime = self.Time;
							end
						else
							self.ClonesControlMessageText = "Item storage full!";
							self.ClonesControlMessageTime = self.Time;
						end
					end
				else
					self.FirePressed[player] = false;
				end

				local lineOffset = topOfPage;

				local name = clone.Name ~= "" and clone.Name or clone.Preset;
				local text = name .. ": " .. #clone.Items .. "/" .. CF.MaxStoredActorInventory;
				CF.DrawString(text, pos + Vector(-138, lineOffset), 135, 11);
				lineOffset = lineOffset + 22;

				local itemsPerPage = self.ClonesControlPanelLinesPerPage;
				local listStart = itemSelected - (itemSelected - 1) % itemsPerPage;
				
				for i = listStart, listStart + itemsPerPage - 1 do
					local item = clone.Items[i];

					if item then
						local prefix = self.ClonesInventorySelectedItem == i and "> " or "";
						local text = prefix .. item.Preset;
						CF.DrawString(text, pos + Vector(-138, lineOffset), 135, 11);
						lineOffset = lineOffset + 11;
					end
				end

				local lineOffset = topOfPage;

				local text = "Storage: " .. CF.CountUsedStorageInArray(self.StorageItems) .. "/" .. tonumber(self.GS.PlayerVesselStorageCapacity);
				CF.DrawString(text, pos + Vector(4, lineOffset), 135, 11);
				lineOffset = lineOffset + 22;
				
				local itemsPerPage = self.ClonesControlPanelLinesPerPage;
				local liststart = self.ClonesStorageSelectedItem - (self.ClonesStorageSelectedItem - 1) % itemsPerPage;

				for i = liststart, liststart + itemsPerPage - 1 do
					local item = self.StorageItems[i];

					if item then
						CF.DrawString(item.Preset, pos + Vector(4, lineOffset), 135, 11, nil, nil, 0)
						CF.DrawString(tostring(item.Count), pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
						lineOffset = lineOffset + 11;
					end
				end

				self.ClonesInventorySelectedItem = itemSelected;
			elseif isBrowsingStorage then
				local itemSelected = self.ClonesStorageSelectedItem;
				local clone = self.Clones[self.ClonesSelectedClone];

				if up then
					itemSelected = itemSelected - 1;
				end

				if down then
					itemSelected = itemSelected + 1;
				end

				if itemSelected > #self.StorageItems then
					itemSelected = 1;
				end

				if itemSelected < 1 then
					itemSelected = #self.StorageItems;
				end

				if cont:IsState(Controller.WEAPON_FIRE) then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true;

						local fullInventory = #clone.Items >= CF.MaxStoredActorInventory;

						if #self.StorageItems > 0 then
							if not fullInventory then
								local item = self.StorageItems[itemSelected];
								item.Count = item.Count - 1;

								local newItem = {};
								newItem.Preset = item.Preset;
								newItem.Class = item.Class;
								newItem.Module = item.Module;
								table.insert(clone.Items, newItem);

								CF.SetClonesArray(self.GS, self.Clones);
								CF.SetStorageArray(self.GS, self.StorageItems);

								if item.Count == 0 then
									self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true);
								end

								itemSelected = math.min(#self.StorageItems, itemSelected);
							else
								self.ClonesControlMessageText = "Clone has no inventory space left.";
								self.ClonesControlMessageTime = self.Time;
							end
						else
							self.ClonesControlMessageText = "No items in storage.";
							self.ClonesControlMessageTime = self.Time;
						end
					end
				else
					self.FirePressed[player] = false;
				end

				local lineOffset = topOfPage;

				local name = clone.Name ~= "" and clone.Name or clone.Preset;

				local text = name .. ": " .. #clone.Items .. "/" .. CF.MaxStoredActorInventory;
				CF.DrawString(text, pos + Vector(-138, lineOffset), 135, 11);
				lineOffset = lineOffset + 22;

				local itemsPerPage = self.ClonesControlPanelLinesPerPage;
				local listStart = self.ClonesInventorySelectedItem - (self.ClonesInventorySelectedItem - 1) % itemsPerPage;
				
				for i = listStart, listStart + itemsPerPage - 1 do
					local item = clone.Items[i];

					if item then
						local prefix = "";
						local text = prefix .. item.Preset;
						CF.DrawString(text, pos + Vector(-138, lineOffset), 135, 11);
						lineOffset = lineOffset + 11;
					end
				end

				local lineOffset = topOfPage;

				local text = "Storage: " .. CF.CountUsedStorageInArray(self.StorageItems) .. "/" .. tonumber(self.GS.PlayerVesselStorageCapacity);
				CF.DrawString(text, pos + Vector(4, lineOffset), 135, 11);
				lineOffset = lineOffset + 22;
				
				local itemsPerPage = self.ClonesControlPanelLinesPerPage;
				local liststart = self.ClonesStorageSelectedItem - (self.ClonesStorageSelectedItem - 1) % itemsPerPage;

				-- Draw items list
				for i = liststart, liststart + itemsPerPage - 1 do
					local item = self.StorageItems[i];

					if item then
						local prefix = self.ClonesStorageSelectedItem == i and "> " or "";
						local text = prefix .. item.Preset;
						CF.DrawString(text, pos + Vector(4, lineOffset), 135, 11, nil, nil, 0)
						CF.DrawString(tostring(item.Count), pos + Vector(138, lineOffset), 135, 11, nil, nil, 2);
						lineOffset = lineOffset + 11;
					end
				end

				self.ClonesStorageSelectedItem = itemSelected;
			end

			if self.ClonesControlMessageText then
				if self.Time <= self.ClonesControlMessageTime + self.ClonesControlMessagePeriod then
					lowBarPalette = CF.MenuDeniedIdle;
					lowBarCenterText = self.ClonesControlMessageText;
				end
			end
			
			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y - 84, pos.X + 140, pos.Y - 71, highBarPalette);
			CF.DrawMenuBox(Activity.PLAYER_NONE, pos.X - 141, pos.Y + 71, pos.X + 140, pos.Y + 84, lowBarPalette);

			CF.DrawString(highBarLeftText, pos + Vector(-138, -77), 276, 11, nil, nil, 0, 1);
			CF.DrawString(highBarCenterText, pos + Vector(0, -77), 276, 11, nil, nil, 1, 1);
			CF.DrawString(highBarRightText, pos + Vector(138, -77), 276, 11, nil, nil, 2, 1);

			CF.DrawString(lowBarCenterText, pos + Vector(0, 78), 276, 11, nil, nil, 1, 1);

			self.ClonesControlMode = mode;
		end
	end
	
	if showIdle and MovableMan:ValidMO(self.ClonesControlPanelActor) and self.ClonesControlPanelActor.Team == Activity.TEAM_1 then
		local player = Activity.PLAYER_NONE;
		local pos = self.ClonesControlPanelActor.Pos;
		local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Clones.png";
		PrimitiveMan.DrawPrimitives(PrimitiveMan, DrawBlendMode.NoBlend, 080, 080, 080, 080, { BitmapPrimitive(player, pos, path, 0, false, false) });

		local text = "Capacity: " .. CF.CountUsedClonesInArray(self.Clones) .. "/" .. self.GS["PlayerVesselClonesCapacity"];
		CF.DrawString(text, pos + Vector(0, -40), 100, 11, nil, nil, 1);
	end

	-- Process clones input
	if
		self.ClonesInputPos ~= nil
		and self.ClonesControlPanelActor ~= nil
		and self.GS["Mode"] == "Vessel"
		and not self.RandomEncounterAttackLaunched
	then
		local count = CF.CountUsedClonesInArray(self.Clones)
		local toResetTimer = true
		
		if count < tonumber(self.GS["PlayerVesselClonesCapacity"]) then
			local foundActor = false

			-- Search for body and put it in storage
			for actor in MovableMan:GetMOsInRadius(self.ClonesInputPos, self.ClonesInputRange, Activity.NOTEAM, true) do
				if IsActor(actor) and actor.Team == CF.PlayerTeam then
					actor = ToActor(actor);
					local controller = actor:GetController();
					local moving = controller:IsState(Controller.MOVE_LEFT)
						or controller:IsState(Controller.MOVE_RIGHT)
						or controller:IsState(Controller.BODY_JUMP)
						or controller:IsState(Controller.BODY_CROUCH);

					local actorDead = actor.Status == Actor.DEAD;
					if actorDead then
						if IsACrab(actor) then
							local crab = ToACrab(actor);

							if crab.Jetpack then 
								crab.Jetpack:EnableEmission(false);
							end
						elseif IsAHuman(actor) then
							local human = ToAHuman(actor);

							if human.Jetpack then 
								human.Jetpack:EnableEmission(false);
							end
						end

						moving = false;
					end

					if not moving and actor.PresetName ~= "Clones Control Panel" and not CF.IsBrain(actor) then
						toResetTimer = false

						if actorDead then
							actor.Vel = actor.Vel * 0.95 + Vector(0, -0.01) - (actor.Pos - self.ClonesInputPos) / 200
						end

						if self.ClonesLastDetectedBodyTime ~= nil then
							-- Put clone to storage
							if
								self.Time >= self.ClonesLastDetectedBodyTime + self.ClonesInputDelay
								and CF.CountUsedClonesInArray(self.Clones)
									< tonumber(self.GS["PlayerVesselClonesCapacity"])
							then
								local c = #self.Clones + 1;

								clone = {};
								clone.Preset = actor.PresetName;
								clone.Class = actor.ClassName;
								clone.Module = actor.ModuleName;
								clone.XP = actor:GetNumberValue("VW_XP");
								clone.Identity = actor:GetNumberValue("Identity");
								clone.Player = actor:GetNumberValue("VW_BrainOfPlayer");
								clone.Prestige = actor:GetNumberValue("VW_Prestige");
								clone.Name = actor:GetStringValue("VW_Name");

								for _, limbName in ipairs(CF.LimbIDs[clone.Class]) do
									clone[limbName] = CF.GetLimbData(actor, limbName);
								end

								-- Store inventory
								local inv, cls, mdl = CF.GetInventory(actor)

								clone.Items = {}

								for i = 1, #inv do
									-- First store items in clone storage
									if i <= CF.MaxStoredActorInventory then
										clone.Items[i] = {}
										clone.Items[i].Preset = inv[i]
										clone.Items[i].Class = cls[i]
										clone.Items[i].Module = mdl[i]
									else
										-- Try to store other items in items storage
										-- If we have free space add items to storage, spawn nearby otherwise
										if
											CF.CountUsedStorageInArray(self.StorageItems)
											< tonumber(self.GS["PlayerVesselStorageCapacity"])
										then
											-- Put item to storage array
											CF.PutItemToStorageArray(self.StorageItems, inv[i], cls[i], mdl[i])

											-- Store everything
											CF.SetStorageArray(self.GS, self.StorageItems)

											-- Refresh storage items array and filters
											self.StorageItems, self.StorageFilters = CF.GetStorageArray(self.GS, true)
										else
											local itm = CF.MakeItem(cls[i], inv[i], mdl[i])
											if itm ~= nil then
												itm.Pos = self.ClonesInputPos
												MovableMan:AddItem(itm)
											end
										end
									end
								end

								table.insert(self.Clones, clone);

								if actor:IsPlayerControlled() then
									self:SwitchToActor(self.ClonesControlPanelActor, controller.Player, CF.PlayerTeam);
								end

								if actor.GoldCarried > 0 then
									CF.ChangePlayerGold(self.GS, actor.GoldCarried);
								end

								actor.ToDelete = true;

								-- Store everything
								CF.SetClonesArray(self.GS, self.Clones);

								-- Refresh storage items array and filters
								self.Clones = CF.GetClonesArray(self.GS);

								self.ClonesLastDetectedBodyTime = nil;
							end

							foundActor = actor;
						else
							self.ClonesLastDetectedBodyTime = self.Time;
						end
					end
				end
			end

			if showIdle then
				if foundActor and self.ClonesLastDetectedBodyTime ~= nil then
					text = "Store in " .. self.ClonesLastDetectedBodyTime + self.ClonesInputDelay - self.Time;
					self:AddObjectivePoint(text, foundActor.EyePos + Vector(0, -10), CF.PlayerTeam, GameActivity.ARROWDOWN);
				end
			end
		else
			toResetTimer = true;
		end

		if toResetTimer then
			self.ClonesLastDetectedBodyTime = nil;
		end
	end

	if MovableMan:IsActor(self.CloneControlPanelActor) then
		self.CloneControlPanelActor.Health = 100;
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------