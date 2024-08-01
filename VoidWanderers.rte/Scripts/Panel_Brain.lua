-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitBrainControlPanelUI() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyBrainControlPanelUI() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessBrainControlPanelUI()
	if self.GS["Mode"] == "Assault" or self.RandomEncounterAttackLaunched then
		return;
	end

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player);

		if act and MovableMan:IsActor(act) then
			-- Process brain detachment
			if act.PresetName == "Brain Case" then

				self:AddObjectivePoint(
					"Press DOWN to detach",
					act.Pos + Vector(0, -56 + (player + 1) * 8),
					CF["PlayerTeam"],
					GameActivity.ARROWDOWN
				);

				local cont = act:GetController();
				local pos = act.Pos;

				if cont:IsState(Controller.PRESS_DOWN) then
					-- Determine which player's brain it is
					-- I don't know why this was ever a concern, we know who's brain it is because we got the brain by who's it was
					-- it was probably a necessary step somehow, TODO: find out if this could be at all necessary, somehow
					local bplayer = player;

					local tough = math.max(math.min(tonumber(self.GS["Brain" .. player .. "Toughness"]), 5), 0);

					local mo = SceneMan:CastMORay(act.Pos, Vector(0, 250), act.ID, Activity.NOTEAM, rte.airID, false, 5);
					
					--[[local rb, candidate
					local mo = SceneMan:CastMORay(act.Pos, Vector(0, 250), act.ID, Activity.NOTEAM, rte.airID, false, 5)
					if mo ~= rte.NoMOID then
						candidate = MovableMan:GetMOFromID(mo)
						if
							candidate.Team == CF["PlayerTeam"]
							and IsAHuman(candidate)
							and ToAHuman(candidate).Status < Actor.INACTIVE
						then
							candidate = candidate
						end
					end
					if candidate and candidate.Head then
						local headOffset = candidate.Head.ParentOffset
						local newHead = CreateAttachable("Brainbot RPG Head LVL" .. tough, "VoidWanderers.rte")
						newHead.ParentOffset = headOffset
						candidate.Head = newHead
						rb = candidate
					else
						rb = CreateAHuman("RPG Brain Robot LVL" .. tough .. " PLR" .. bplr)
						rb.Team = CF["PlayerTeam"]
						rb.Vel = Vector(0, 4)
						MovableMan:AddActor(rb)
					end]]

					local rb = CreateAHuman("RPG Brain Robot LVL" .. tough .. " PLR" .. bplayer);
					rb.Team = CF["PlayerTeam"];
					rb.Vel = Vector(0, 4);
					MovableMan:AddActor(rb);

					if rb then
						rb.AIMode = Actor.AIMODE_SENTRY;
						rb.Health = act.Health;

						-- Give items
						for j = 1, CF["MaxSavedItemsPerActor"] do
							if self.GS["Brain" .. bplayer .. "Item" .. j .. "Preset"] ~= nil then
								local itm = CF["MakeItem"](
									self.GS["Brain" .. bplayer .. "Item" .. j .. "Preset"],
									self.GS["Brain" .. bplayer .. "Item" .. j .. "Class"],
									self.GS["Brain" .. bplayer .. "Item" .. j .. "Module"]
								);
								if itm then
									rb:AddInventoryItem(itm);
								end
							else
								break;
							end
						end

						rb.Pos = act.Pos + Vector(0, 20);
						self:SwitchToActor(rb, player, CF["PlayerTeam"]);
						self:SetPlayerBrain(rb, player);

						self.GS["Brain" .. bplayer .. "Detached"] = "True";
						CF["ClearAllBrainsSupplies"](self.GS, bplayer);
						self.CreatedBrains[bplayer] = nil;
						act.ToDelete = true;
					end
				end
				-- Process brain attachment
			elseif act:IsInGroup("Brains") then
				local s = act.PresetName;
				local pos = string.find(s, "RPG Brain Robot");
				if pos == 1 then
					-- Determine which player's brain it is
					local bplayer = tonumber(string.sub(s, string.len(s), string.len(s)));
					local readytoattach = false;

					if
						act.Pos.X > self.BrainPos[bplayer + 1].X - 10
						and act.Pos.X < self.BrainPos[bplayer + 1].X + 10
						and act.Pos.Y > self.BrainPos[bplayer + 1].Y
						and CF["DistUnder"](act.Pos, self.BrainPos[bplayer + 1], 100)
					then
						readytoattach = true;
						self:AddObjectivePoint(
							"Press UP to attach",
							self.BrainPos[bplayer + 1] + Vector(0, 6 + (bplayer + 1) * 8),
							CF["PlayerTeam"],
							GameActivity.ARROWUP
						);
					else
						self:AddObjectivePoint(
							"Attach brain",
							self.BrainPos[bplayer + 1] + Vector(0, 6 + (bplayer + 1) * 8),
							CF["PlayerTeam"],
							GameActivity.ARROWUP
						);
					end

					local cont = act:GetController();

					if cont:IsState(Controller.PRESS_UP) and readytoattach then
						local rb = CreateActor("Brain Case");
						if rb then
							rb.Team = CF["PlayerTeam"];
							rb.Pos = self.BrainPos[bplayer + 1];
							rb.Health = act.Health;
							MovableMan:AddActor(rb);
							self:SwitchToActor(rb, player, CF["PlayerTeam"]);
							self:SetPlayerBrain(rb, player);

							-- Clear inventory
							for j = 1, CF["MaxSavedItemsPerActor"] do
								self.GS["Brain" .. bplayer .. "Item" .. j .. "Preset"] = nil;
								self.GS["Brain" .. bplayer .. "Item" .. j .. "Class"] = nil;
								self.GS["Brain" .. bplayer .. "Item" .. j .. "Module"] = nil;
							end

							-- Save inventory
							local pre, cls, mdl = CF["GetInventory"](act);

							for j = 1, #pre do
								self.GS["Brain" .. bplayer .. "Item" .. j .. "Preset"] = pre[j];
								self.GS["Brain" .. bplayer .. "Item" .. j .. "Class"] = cls[j];
								self.GS["Brain" .. bplayer .. "Item" .. j .. "Module"] = mdl[j];
							end

							self.GS["Brain" .. bplayer .. "Detached"] = "False";
							self.CreatedBrains[bplayer] = rb;
							--[[
							if IsAHuman(act) and ToAHuman(act).Head then
								act = ToAHuman(act);
								act.DeathSound = nil;
								act.Vel = Vector(0, 4) - SceneMan.GlobalAcc;
								act.AngularVel = 0;
								act.HUDVisible = false;
								act.Lifetime = act.Age + 400;
								
								if act.EquippedItem then
									act.EquippedItem.Lifetime = act.EquippedItem.Age + 1;
								end
								if act.EquippedBGItem then
									act.EquippedBGItem.Lifetime = act.EquippedBGItem.Age + 1;
								end
								
								act:RemoveAttachable(act.Head, false, true);
							else
							]]--
							if act.GoldCarried > 0 then
								CF["SetPlayerGold"](self.GS, 0, CF["GetPlayerGold"](self.GS, 0) + act.GoldCarried);
							end
							act.ToDelete = true;
							--end
						end
					end
				end
			end
		end
	end
end
